variable "host_os" {
  type    = string
  default = "linux"
}

variable "allowed_ip" {
  description = "Allowed source IP address for security rule"
  type = string
}