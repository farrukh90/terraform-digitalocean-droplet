# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {
   default ="Add your api token here"
}

#Put your remote machine ssh publickey fingerprint to below after you put it to digital ocean.
variable "ssh_keys" {
  type = list(any)
  default = [
    "Add your ssh publickey fingerprint here"
  ]
}
