#*****************************************************************************************************************************
#Name:Shashi shekhar

#Email id: meshashi29@gmail.com,sshekhar@scu.edu
#AIM: This terraform script creates  AWS ELB  , unibuntu 14.04 ,Key pair, virtual instance and  AWS scaling  group 
#Here all VM instances  belongs to free tier. Name of vm instances are mentioned in variable.tf file
#It  uses ASW provider "aws_elb" , "aws_autoscaling_group" ,"aws_key_pair" as well as  "aws_launch_configuration"
#Files:nginx.sh,varibles.tf,project.rf
#It uses varables.tf to  replace dynamic  value and nginx.sh to install nginx in new created VM
#It also create the key  for accesing the virtual machine . 
#But  downloading the  PEM file option is not working that's why i  coomented the key pair provider
#Terrform  must be installed in ur system. I  created VM  in Amazon EC2 cluster . Then  installed terraform on VM
#**************************************************************************************************************************************


#**************************** provider details ********************************************************************

# Specify the provider and access details
provider "aws" {
  #access key  according to user 
  access_key = "AKIAII7HSCAYDWJBQ"
  #access  secretkey  according to user 
  secret_key = "XPeM/Sfxk4dPt/cnuim2Et0yWk7/okKyuSQ"
  #region for creating vm
  region = "${var.aws_region}"
}

#*******************************************************************************************************************


#*******************************Launch configuration ***************************************************************

resource "aws_launch_configuration" "LC" {
  name = "terraformAWSLaunch"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  #Already created key pair name "ubuntu"
  key_name = "ubuntu"
  #Security group  which keeps the permission  to login from any place with  appropriate key  (static as wll as dynmaic)
  #security_groups = ["sg-641f6d02","sg-641f6d02"]
  security_groups = ["${aws_security_group.SG.name}"]
  #script which run on created  VM
  user_data = "${file("nginx.sh")}"
  
}
#*******************************************************************************************************************

#********************************* ELB Configuration ****************************************************************


resource "aws_elb" "ELB" {
  name = "terraformELB"
# availability zone as our instances
availability_zones =["us-west-2a","us-west-2b","us-west-2c"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval =  60
  }

}

#*******************************************************************************************************************

#********************************* Auto scaling Configuration ****************************************************************




resource "aws_autoscaling_group" "ASG" {

  availability_zones =["us-west-2a","us-west-2b","us-west-2c"]
  name = "terraformScalingScript"
  force_delete = true
  desired_capacity = "1"
  max_size = "2"
  min_size = "1"
  #launch configuration provider
  launch_configuration = "${aws_launch_configuration.LC.name}"
  #load balancer provider
  load_balancers = ["${aws_elb.ELB.name}"]
  tag {
    key = "Name"
    value = "ASG"
    propagate_at_launch = "true"
  }
}

#*******************************************************************************************************************

#********************************* Seurity Configuration ****************************************************************




resource "aws_security_group" "SG" {
  name = "terraformSG"
  description = "Seurity Configuration for newly created VM"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }


#*******************************************************************************************************************

#********************************* Key pair Configuration ****************************************************************




#dyanmically create key pair for authntication 
#resource "aws_key_pair" "auth" {
 # key_name   = "Ubuntu14"
 # public_key = "${file("rsa-APKAJNP5VSB77XQ.pem")}"
#}


#*******************************************************************************************************************

#Testing 
#It  creates  Ubuntu14.04 VM and with nginx tool 
#which coomand  : It will display nginx  and it's path
#Command To execute 
#Change the access key as well as secrety key according to   your amazon account 
#Change key_name according   your key name  . AWS provides option to create key  pair before  creating ec2 system
#Modify the places according to  your zone  .Amazon.com will help you to find the zone for youe places 
#terraform plan 
#terraform apply
#terraform  show
#terraform  destroy





