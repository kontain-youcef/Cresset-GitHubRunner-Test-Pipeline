#!/bin/bash
set -euxo pipefail

ORG="${org}"
SSM_NAME="${ssm_name}"          # Path like /gha/runner-token/<run-id>-<run-attempt>
RUNNER_VERSION="${runner_ver}"
LABELS="${labels}"              # e.g. self-hosted,aws,linux
REGION="${region}"

# Install deps
command -v curl >/dev/null || (dnf -y install curl || yum -y install curl)
command -v tar  >/dev/null || (dnf -y install tar  || yum -y install tar)

# Runner user
id -u runner >/dev/null 2>&1 || useradd -m -s /bin/bash runner
install -d -o runner -g runner /opt/actions-runner
cd /opt/actions-runner

# Fetch registration token from Parameter Store
TOKEN="$(aws ssm get-parameter \
  --name "${SSM_NAME}" \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text \
  --region "${REGION}")"

# Download runner
curl -L -o actions-runner.tar.gz \
  "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
tar xzf actions-runner.tar.gz
chown -R runner:runner /opt/actions-runner

# Configure ephemeral runner (dies after one job)
sudo -u runner bash -lc "
  cd /opt/actions-runner
  ./config.sh \
    --unattended \
    --ephemeral \
    --url https://github.com/${ORG} \
    --token '${TOKEN}' \
    --name \$(hostname) \
    --labels '${LABELS}' \
    --work _work
  ./run.sh
"

# Shut down after job (so ASG scaling matches Terraform desired)
shutdown -h now || true
