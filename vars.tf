variable "vpc" {
  default="vpc-bbd1adc1"
}

variable "amis" {
  default = "ami-035b3c7efe6d061d5"
}

variable "key_name" {
  default = "poc"
}

variable "subnets" {
  default = ["subnet-4a0c2264","subnet-a0eb18ed","subnet-e7e104e9","subnet-0862416f","subnet-b0072bec","subnet-2e483f10"]
}
