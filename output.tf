output "full" {
    value = <<EOF
      "Please login to this host



            root@${digitalocean_droplet.manager1.ipv4_address}

            and then run the following command:



            docker node ls 

            "
      EOF
}