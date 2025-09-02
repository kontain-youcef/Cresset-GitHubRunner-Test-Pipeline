locals {
  # Per-OS metadata for runner setup
  os = {
    linux = {
      desired_var    = "linux_desired"
      instance_type  = var.linux_instance_type
      ami_param_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
      label_string   = "self-hosted,aws,linux"
      user_data_tpl  = "${path.module}/user_data/runner-linux.sh"
    }
    windows = {
      desired_var    = "windows_desired"
      instance_type  = var.windows_instance_type
      ami_param_name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
      label_string   = "self-hosted,aws,windows"
      user_data_tpl  = "${path.module}/user_data/runner-windows.ps1"
    }
  }

  # Map of desired counts (comes from tfvars JSON)
  desired = {
    linux   = var.linux_desired
    windows = var.windows_desired
  }
}
