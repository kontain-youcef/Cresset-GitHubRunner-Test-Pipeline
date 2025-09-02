<powershell>
$ORG        = "${org}"
$SSMName    = "${ssm_name}"
$RunnerVer  = "${runner_ver}"
$Labels     = "${labels}"
$Region     = "${region}"

# Ensure AWS CLI exists
$cliUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$cliMsi = "$env:TEMP\AWSCLIV2.msi"
if (-not (Get-Command aws.exe -ErrorAction SilentlyContinue)) {
  Invoke-WebRequest -Uri $cliUrl -OutFile $cliMsi
  Start-Process msiexec.exe -ArgumentList "/i `"$cliMsi`" /qn" -Wait
}

# Directory
$runnerDir = "C:\actions-runner"
New-Item -ItemType Directory -Force -Path $runnerDir | Out-Null
Set-Location $runnerDir

# Get registration token from SSM
$token = (aws ssm get-parameter --name $SSMName --with-decryption --query 'Parameter.Value' --output text --region $Region)

# Download runner
$zip = "actions-runner-win-x64-$RunnerVer.zip"
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$RunnerVer/$zip" -OutFile $zip
Expand-Archive -Path $zip -DestinationPath $runnerDir -Force

# Configure ephemeral runner
& .\config.cmd --unattended --ephemeral `
  --url "https://github.com/$ORG" `
  --token "$token" `
  --name $env:COMPUTERNAME `
  --labels "$Labels" `
  --work "_work"

# Run once, then shutdown
& .\run.cmd
Stop-Computer -Force
</powershell>
