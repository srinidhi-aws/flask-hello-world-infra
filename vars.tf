variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AMI" {
    type = map(string)
    default = {
        us-east-1 = "ami-0a8b4cd432b1c3063"
    }
}


variable "PRIVATE_KEY_PATH" {
  default = "hello-world-kp"
}

variable "PUBLIC_KEY_PATH" {
  default = "hello-world-kp.pub"
}

variable "EC2_USER" {
  default = "ec2-user"
}
