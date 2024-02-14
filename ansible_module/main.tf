
    ## instance ##
resource "aws_instance" "ansible-remote" {
    ami           = var.AMIS[var.region]
    instance_type = "t2.micro"
    subnet_id     = var.public_subnet1    
    key_name      = var.key
    vpc_security_group_ids = ["sg-0416f10b97744c453"]
    tags = {
        Name = "TF-anisble-ariel-goingon"
    }
    provisioner "file" {                    # provision/copy script file for ansible deployment on instance
            source     = "ansible_module/script.sh"
            destination= "/tmp/script.sh"
    }
    
    provisioner "remote-exec" {
        inline = [                   # execute the script file
            "chmod +x /tmp/script.sh", # then apply script that uses file
            "sudo sed -i -e 's/\r$//' /tmp/script.sh", # remove the CR characters
            "sudo /tmp/script.sh",   #invoke script
        ]
    }        
    connection {                   # connect with instance
        host = coalesce(self.public_ip, self.private_ip)
        type = "ssh"
        user = "${var.INSTANCE_USERNAME}"
        private_key = file("${var.PATH_TO_PRIVATE_KEY}")
    }  
        
    
}    
   # output check for subnets and vpc id

data "aws_vpc" "existing_vpc" {
    tags = {
        Name = "ariel-vpc-project" # selecting the right VPC
    }
}
     # iteration over all subnets via vpc #
data "aws_subnets" "existing_vpc_subnets" {
     filter {
        name = "vpc-id"  # pulling the id from the selected VPC
        values = [data.aws_vpc.existing_vpc.id]
     } 
}
  # selecting public subnets only
locals {
  selected_subnet_ids = [
    element(data.aws_subnets.existing_vpc_subnets.ids, 0),  # Subnet 1
    element(data.aws_subnets.existing_vpc_subnets.ids, 4),  # Subnet 4
    element(data.aws_subnets.existing_vpc_subnets.ids, 5)   # Subnet 5
  ]
}

resource "aws_instance" "master-k8s" { # instance for cluster
    ami           = var.AMIS[var.region]
    instance_type = "t2.xlarge"
    count = var.instance_count_master
       # using selected public subnets only for even distribution of instances over AZ's
    subnet_id     = element(local.selected_subnet_ids, count.index % length(local.selected_subnet_ids))    
    key_name      = var.key
     # this role allows CSI EBS driver to connect with AWS allowing persistent volume provisioning
    iam_instance_profile = "ariel-kubespray-ansible-role"
    vpc_security_group_ids = ["sg-0416f10b97744c453"] # to open all related k8s ports
    root_block_device {
        volume_size = 30  # Specify the size of the root volume in GB
        volume_type = "gp2"  # Specify the volume type (e.g., gp2, io1)
  }
    tags = {
        Name = "TF-master-ariel-goingon"
    }
    provisioner "remote-exec" {
       inline = [
           "echo '*******providing pub********' ",
           "echo '${file("~/.ssh/id_rsa.pub")}' | tee -a /home/ubuntu/.ssh/authorized_keys > /dev/null",    
        ]
    }
   
    connection {                   # connect with instance
        host = coalesce(self.public_ip, self.private_ip)
        type = "ssh"
        user = "${var.INSTANCE_USERNAME}"
        private_key = file("${var.PATH_TO_PRIVATE_KEY}")
    }        
   
}


   #         deploy instances over different AZ's for HA    **
data "aws_availability_zones" "available" {
  state = "available"
}



                             ## worker nodes instance  ##

resource "aws_instance" "worker-k8s" {
    ami           = var.AMIS[var.region]
    instance_type = "t2.large"   
    key_name      = var.key
    count         = var.instance_count_worker
             # Distribute instances across the available AZs
    subnet_id     = element(local.selected_subnet_ids, count.index % length(local.selected_subnet_ids))    
    vpc_security_group_ids = ["sg-0416f10b97744c453"] # to open all related k8s ports
     # this role allows CSI EBS driver to connect with AWS allowing persistent volume provisioning
    iam_instance_profile = "ariel-kubespray-ansible-role"
    root_block_device {
        volume_size = 25  # Specify the size of the root volume in GB
        volume_type = "gp2"  # Specify the volume type (e.g., gp2, io1)
  }
    tags = {
        Name = "TF-worker-ariel-goingon"
    }
    provisioner "remote-exec" {
       inline = [
           "echo '*******providing pub********' ",
           "echo '${file("~/.ssh/id_rsa.pub")}' | sudo tee -a /home/ubuntu/.ssh/authorized_keys > /dev/null",    
        ]
    }
   
    connection {                   # connect with instance
        host = coalesce(self.public_ip, self.private_ip)
        type = "ssh"
        user = "${var.INSTANCE_USERNAME}"
        private_key = file("${var.PATH_TO_PRIVATE_KEY}")
    }   
}

