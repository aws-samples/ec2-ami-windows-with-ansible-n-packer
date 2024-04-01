//  variables.pkr.hcl

// For those variables that you don't provide a default for, you must
// set them from the command line, a var-file, or the environment.

variable "source_base_ami" {
  type = string
  default = "Windows_Server-2016-English-Full-Base-2024.01.16"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "ami_description" {
  type = string
  default = "Application Baked AMI for micro service app - Windows"
}

variable "app_name" {
  type = string
  default = "win_download_artifact_from_nexus"
}

variable "instance_type" {
  type = string
  default = "t3.medium"
}

variable "winrm_username" {
  type = string
  default = "Administrator"
}

variable "winrm_port" {
  type = number
  default = 5986
}

variable "instance_name" {
  type = string
  default = "customapp-windows-golden-ami"
  }

variable "delete_on_termination" {
  type = bool
  default = true
}

variable "build_ami_name_prefix" {
  type = string
  default = "customapp-app-windows-ami"
}

