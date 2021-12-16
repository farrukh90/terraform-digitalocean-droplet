# Create a manager server
resource "digitalocean_droplet" "manager1" {
  image    = "centos-7-x64"
  name     = "manager-1"
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
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "systemctl status docker",
    ]
  }
}


# Create a worker server
resource "digitalocean_droplet" "workers" {
  count    = 3
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
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "systemctl status docker",
    ]
  }
}

resource "null_resource" "workers2" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.workers[1].ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "systemctl status docker",
    ]
  }
}

resource "null_resource" "workers3" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    host        = digitalocean_droplet.workers[2].ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "systemctl status docker",
    ]
  }
}


resource "null_resource" "cluster_joiner" {
  depends_on = [
    null_resource.cluster,
    null_resource.workers1,
    null_resource.workers2,
    null_resource.workers3,
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
        RESULT=`ssh root@${digitalocean_droplet.manager1.ipv4_address}  "docker swarm init --advertise-addr ${digitalocean_droplet.manager1.ipv4_address}"   | grep "docker swarm join --token SWM"`
        ssh -o StrictHostKeyChecking=no root@${digitalocean_droplet.workers[0].ipv4_address} $RESULT
        ssh -o StrictHostKeyChecking=no root@${digitalocean_droplet.workers[1].ipv4_address} $RESULT
        ssh -o StrictHostKeyChecking=no root@${digitalocean_droplet.workers[2].ipv4_address} $RESULT
        RESULT=`ssh root@${digitalocean_droplet.manager1.ipv4_address}  "docker node ls"`
        echo $RESULT
      EOT
  }
}
