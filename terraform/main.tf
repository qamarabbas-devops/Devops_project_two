		terraform {
			  required_providers {
				aws = {
				  source  = "hashicorp/aws"
				  version = "~> 5.0"
				}
			  }
              backend "s3" {
                key = "aws/ec2-deploy/terraform.tfstate"
              }
			}
provider "aws" {
					  region     = var.region
					
					}           
resource "aws_instance" "server" {
					  ami           = "ami-0b20f552f63953f0e"
					  instance_type = "t2.medium"
					  key_name = aws_key_pair.deployer.key_name
					  vpc_security_group_ids = [aws_security_group.main-sg.id]
					  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
                      connection {
                        type = "ssh"
                        host = self.public_ip
                        user = "ubuntu"
                        private_key = var.private_key
                        timeout = "4m"
                      }

					  tags = {
						Name = "DeployVM"
					  }
					}
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = "EC2-ECR-AUTH"
}					
resource "aws_key_pair" "deployer" {
	key_name = var.key_name
	public_key = var.public_key
}
resource "aws_security_group" "main-sg"{


		#Inbound rule for HTTP
		egress =[{
			from_port = 0
			description = ""
			protocol = "all"
			cidr_blocks = ["0.0.0.0/0"]
			ipv6_cidr_blocks = []
			prefix_list_ids = []
			security_groups = []
			self = false
			to_port = 0

		}]
		#Outbound rule 
		ingress =[ {
			from_port = 22
			to_port = 22
			protocol = "tcp"
			cidr_blocks = ["0.0.0.0/0"]
			description = ""
			ipv6_cidr_blocks = []
			prefix_list_ids = []
			security_groups = []
			self = false
		},
		{
			from_port = 80
			to_port = 80
			protocol = "tcp"
			cidr_blocks = ["0.0.0.0/0"]
			description = ""
			ipv6_cidr_blocks = []
			prefix_list_ids = []
			security_groups = []
			self = false
		}]
}
output "intance_pubic_ip" {
  value = aws_instance.server.public_ip
  sensitive = true
}
