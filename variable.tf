# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {
  default = "d81dcf990f3fb04432d545b2ce32c5ffe28313f7f13971677aeeb41598677d87"
}
variable "ssh_keys" {
  type = list(any)
  default = [
    "e7:68:15:7b:73:24:3b:ac:1f:8f:90:89:8a:88:bf:41"
  ]
}