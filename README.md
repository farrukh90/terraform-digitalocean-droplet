# terraform-digitalocean-droplet
```
module "swarm" {
  source   = "../"
  do_token = "YOUR_TOKEN"
  ssh_keys = ["FINGERPRINT"]
}


output "full" {
  value = module.swarm.full
}
```