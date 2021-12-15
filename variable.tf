# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {
  "Add Your API token here"
}

#Put your remote machine ssh publickey fingerprint to below after you put it to digital ocean.
variable "ssh_keys" {
  type = list(any)
  default = [
    "add your ssh publickey fingerprint here"
  ]
}
