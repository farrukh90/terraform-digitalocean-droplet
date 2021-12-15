# Create a manager server
resource "digitalocean_droplet" "manager1" {
  image    = "centos-7-x64"
  name     = "manager1"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = var.ssh_keys
}

resource "null_resource" "cluster" {
  triggers = {
    always_run = timestamp()
  }
  connection {
    host        = digitalocean_droplet.manager1.ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "ssh-keygen -t rsa -b 4096 -N '' <<<$'\ny\n'",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "docker swarm init --advertise-addr ${digitalocean_droplet.manager1.ipv4_address} | grep 'docker swarm join --token SWM' >> token.file",
    ]
  }
}

# Create a worker server
resource "digitalocean_droplet" "workers" {
  count    = 1
  image    = "centos-7-x64"
  name     = "worker-${count.index + 1}"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = var.ssh_keys
}

resource "null_resource" "workers1" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.workers[0].ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "ssh-keygen -t rsa -b 4096 -N '' <<<$'\ny\n'",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
    ]
  }
}


resource "null_resource" "cluster_joiner" {
  depends_on = [
    null_resource.cluster,
    null_resource.workers1,
  ]
  
  triggers = {
    always_run = timestamp()
  }
  connection {
    host        = digitalocean_droplet.manager1.ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
        "grep 'docker swarm join --token SWM' token.file | bash token.file",
        "ssh-keyscan -H ${digitalocean_droplet.workers[0].ipv4_address} >> ~/.ssh/known_hosts",

       ]
  }
}

// resource "null_resource" "cluster_joiner_ssh" {
//   depends_on = [
//     null_resource.cluster_joiner,
//   ]
  
//   triggers = {
//     always_run = timestamp()
//   }
//   connection {
//     host        = digitalocean_droplet.manager1.ipv4_address
//     user        = "root"
//     private_key = file("~/.ssh/id_rsa")
//   }
//   provisioner "remote-exec" {
//     inline = [
//         "scp /root/token.file root@${digitalocean_droplet.workers[0].ipv4_address}:/root",
//         "ssh root@${digitalocean_droplet.workers[0].ipv4_address} | bash token.file",
//        ]
//   }
// }





// resource "null_resource" "workers2" {
//   triggers = {
//     always_run = timestamp()
//   }

//   connection {
//     host        = digitalocean_droplet.workers[1].ipv4_address
//     user        = "root"
//     private_key = file("~/.ssh/id_rsa")
//   }
//   provisioner "remote-exec" {
//     # Bootstrap script called with private_ip of each node in the clutser
//     inline = [
//       "curl -fsSL https://get.docker.com -o get-docker.sh",
//       "sudo sh get-docker.sh",
//       "sudo systemctl start docker",
//       "sudo systemctl enable docker",
//       "systemctl status docker",
//       "ssh-keygen -t rsa -b 4096 -N '' <<<$'\ny\n'",
//     ]
//   }
// }

// resource "null_resource" "workers3" {
//   triggers = {
//     always_run = timestamp()
//   }

//   connection {
//     host        = digitalocean_droplet.workers[2].ipv4_address
//     user        = "root"
//     private_key = file("~/.ssh/id_rsa")
//   }
//   provisioner "remote-exec" {
//     # Bootstrap script called with private_ip of each node in the clutser
//     inline = [
//       "curl -fsSL https://get.docker.com -o get-docker.sh",
//       "sudo sh get-docker.sh",
//       "sudo systemctl start docker",
//       "sudo systemctl enable docker",
//       "systemctl status docker",
//       "ssh-keygen -t rsa -b 4096 -N '' <<<$'\ny\n'",
//     ]
//   }
// }

