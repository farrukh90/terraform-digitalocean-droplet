# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {
   default ="b8f4298a8edf0bb82318308ad974d160f89a068fc2a30cc72cab4365af91ece3"
}

#Put your remote machine ssh publickey fingerprint to below after you put it to digital ocean.
variable "ssh_keys" {
  type = list(any)
  default = [
    "a7:02:75:55:06:95:20:96:57:38:e3:49:a4:06:55:3b"
    
  ]
}
