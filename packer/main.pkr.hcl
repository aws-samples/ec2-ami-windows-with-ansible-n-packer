packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "NEXUS_USERNAME" {
  type =  string
  // Sensitive vars are hidden from output as of Packer v1.6.5
  default = env("NEXUS_USERNAME")
}

variable "NEXUS_PASSWORD" {
  type =  string
  default = env("NEXUS_PASSWORD")
}

variable "USER_PASSWORD" {
  type =  string
  default = env("USER_PASSWORD")
}

variable "NEXUS_SERVER" {
  type =  string
  default = env("NEXUS_SERVER")
}

source "amazon-ebs" "windows" {
   region = "${var.region}"
   instance_type = "${var.instance_type}"
   communicator =  "winrm"
   winrm_use_ssl =  "true"
   winrm_use_ntlm =  "true"
   winrm_insecure =  "true"
   winrm_username =  "${var.winrm_username}"
   winrm_password = "${var.USER_PASSWORD}"
   winrm_port =  "${var.winrm_port}"
   pause_before_connecting = "1m"
   user_data_file =  "./bootstrap_win.ps1"
   ami_name = "customapp-app-windows-ami-${formatdate("YYYY-MM-DD'T'hh-mm-ssZ", timestamp())}"
   ami_description = "${var.ami_description}"
   
   source_ami_filter {
      filters = {
          name= "Windows_Server-2016-English-Full-Base-2024.01.16"
      }
      owners = ["amazon"]
      most_recent = true
   }

   launch_block_device_mappings {
      device_name = "/dev/sda1"
      volume_type = "gp3"
      delete_on_termination = "${var.delete_on_termination}"
   }

   tags = {
      Name = "${var.build_ami_name_prefix}-${formatdate("YYYY-MM-DD'T'hh-mm-ssZ", timestamp())}"
      AppName = "${var.app_name}"
   }
}

build {
    sources = [
        "source.amazon-ebs.windows",
    ]
    provisioner "ansible" {
          playbook_file = "../ansible/sysprep.yml"
          use_proxy = false
          extra_arguments = [ "--connection", "packer", "-vvv", "--extra-vars",
          "ansible_winrm_server_cert_validation=ignore ansible_port=${var.winrm_port} ansible_user=${var.winrm_username} ansible_winrm_transport=ntlm nexus_username=${var.NEXUS_USERNAME} nexus_password=${var.NEXUS_PASSWORD} nexus_server_ip=${var.NEXUS_SERVER}" ]
       }
}
