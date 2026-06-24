variable "ami_id" {
    #default = "ami-0874aa40645e0545d" #my-snapshot-image
    default = "ami-00adafae70b8029d8" #rhel-10 base AMI
  
}

variable "ami_name" {
    default = "Redhat-10-DevOps-Practice-trail"
  
}

variable "sg_ami" {
    default = "sg_ami"
  
}