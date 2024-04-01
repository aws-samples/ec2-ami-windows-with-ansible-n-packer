# EC2 Windows AMI Creation With Ansible And Packer

Description
There are multiple Ansible resources available to download the latest maven artifact on AWS EC2, but this works only on a Linux OS. When we try them on an AWS EC2 with Windows OS it fails. This pattern guides how this problem can be resolved.

Use case is simple create the AMI using the Packer and  download maven artifacts latest version dynamically on AWS EC2 AMI from Nexus by using Ansible resources.

# Quickstart
1. Clone Repo
    ```git clone https://github.com/aws-samples/ec2-ami-windows-with-ansible-n-packer``
2. Update Packer Script
Add or Replace the parameter values in your ec2-ami-windows-with-ansible-n-packer\packer\variables.pkr.hcl file with "parameters", as in sample below. For e.g. The value of instance_type = "t3.medium“  region = "us-east-1”
Replace few parameter value in ansible script ansible/sysprep.yml nexus_server: http://<nexus_server_url>/service/rest/v1/search/assets, artifactId: <com.devops.demo>,  artifactId: <MavenHelloWorld>

```yaml
---
# hardening sysprep.yml
- name: WINDOWS EC2 FOR AMI	
  hosts: all
  gather_facts: no
  vars:
    download_dir: C:\Temp\
    nexus_server: http://{{ nexus_server_ip }}:8081/service/rest/v1/search/assets
    artifactId: MavenHelloWorld
    groupId: com.devops.demo
```   
In this approach, we employ two resources to obtain the artifact. First, we utilize win_uri to generate the URL for the latest Nexus artifact. This URL is then stored in the output variable result
```yaml
 - name: GENERATE DYNAMIC URL IN VARIABLE result
     win_uri:
        url: "{{ nexus_server }}/download?&repository={{ repository_name }}&maven.groupId={{ groupId }}&maven.artifactId={{ artifactId }}&maven.extension=jar&sort=version"
        url_username: "{{ nexus_username }}"
        url_password: "{{ nexus_password }}"
        headers:
          Content-Type: "application/json"
        method: GET
        force_basic_auth: yes
        status_code: 200
        return_content: yes
     register: result
      ignore_errors: true
```
In the second step, we utilize win_get_url to download the latest artifact from Nexus. This is achieved by using the response_uri, which contains the URL of the latest Maven artifact.
```yaml
- name: DOWNLOAD LATEST ARTIFACTS FROM NEXUS
      win_get_url:
        url: "{{ result.response_uri }}"
        dest: '{{ download_dir }}'
        url_username: "{{ nexus_username }}"
        url_password: "{{ nexus_password }}"
```

In provisioner Ansible is used. Which is calling the ansible sysprep.yml file
# Repository Structure:
```gitlab-ci.yml``` GitLab CI/CD pipeline configuration file.
Utilizing the alpinelinux/ansible base image, the GitLab CI pipeline installs the Packer package and required Python dependencies. It then executes Packer scripts for automated image creation.
```packer``` Directory containing Packer scripts to create Windows golden AMI.
bootstrap_win.ps1: To configure WinRM (Windows Remote Management) in a Windows environment, we  execute the bootstrap_win.ps1 script via user data. This script accomplishes the following tasks: setting the EC2 Administrator password, configuring the execution policy, setting up WinRM, and adding a firewall rule to allow TCP port 5986.
```ansible``` Directory containing Ansible scripts.
        sysprep.yml: Ansible playbook config to connect to the Nexus server and download the latest Maven artifact on a Windows machine.
## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

