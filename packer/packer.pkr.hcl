variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "base_ami" {
  type    = string
  default = "ami-06616b7884ac98cdd"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../networkTerraform/terraform.tfstate"
  }
}

variable "subnet_id" {
  type    = string
  default = "${data.terraform_remote_state.network.outputs.public_subnets[0]}"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "base_instance" {
  access_key                  = "${var.aws_access_key}"
  ami_name                    = "packer-base-${local.timestamp}"
  associate_public_ip_address = true
  instance_type               = "${var.instance_type}"
  region                      = "${var.region}"
  secret_key                  = "${var.aws_secret_key}"
  source_ami                  = "${var.base_ami}"
  ssh_username                = "${var.ssh_username}"
  subnet_id                   = "${var.subnet_id}"
  tags = {
    Name = "Packer-Ansible"
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.amazon-ebs.base_instance"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
  }

}