variable "access_key" {

        default = "xxxxxxxxxxxx"
}
variable "secret_key"{
        default = "xxxxxxxxxxxxxxxxx"
}
variable "region"{
}

variable "images"{
        type = "map"
        default = {
                us-west-2 = "ami-01bbe152bf19d0289"
                us-east-1 = "ami-009d6802948d06e52"
        }
}

variable "zone" {
  default = ["us-east-1a","us-west-2b"]
}
