# Generic inputs
variable "region"                      { type = string }
variable "org"                         { type = string } # GitHub org slug, e.g. "kontain-co"
variable "runner_version"              { type = string } # e.g. "2.317.0"
variable "runner_token_parameter_name" { type = string } # SSM name where workflow wrote token

# Networking
variable "vpc_id"     { 
    type = string 
    default = "vpc-0e17e1f6059b9f8bd"
}
variable "subnet_ids" { 
    type = list(string)
    default = [ "subnet-05e0a6eff000312a3", "subnet-07f8013217f2c2eb7" ]
 }

 variable "runner_security_grp" {
   type = string
   default = "sg-01a1aaea7c90095a0"
 }

# Scaling (set dynamically by GitHub workflow in gha.auto.tfvars.json)
variable "linux_desired"   { type = number }
variable "windows_desired" { type = number }

# Instance types (defaults mirror your on-prem notion)
variable "linux_instance_type"   { 
type = string 
default = "t3.medium" 
}
variable "windows_instance_type" { 
    type = string 
    default = "t3.large" 
}

# Upper bound to stop runaway scaling
variable "asg_max_size" { 
    type = number 
    default = 100 
}

# Optional tagging
variable "tags" { 
type = map(string)
 default = {} 
 }
