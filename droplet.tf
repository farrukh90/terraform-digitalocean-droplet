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
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "docker swarm init --advertise-addr ${digitalocean_droplet.manager1.ipv4_address} | grep 'docker swarm join --token SWM' >> token.sh",
    ]
  }
}
      // "ssh-keygen -t rsa -b 4096 -N '' <<<$'\ny\n'",
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
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "ssh-keyscan -H ${digitalocean_droplet.manager1.ipv4_address} >> ~/.ssh/known_hosts",
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
        "ssh-keyscan -H ${digitalocean_droplet.workers[0].ipv4_address} >> ~/.ssh/known_hosts",
        "ssh root@${digitalocean_droplet.workers[0].ipv4_address} | bash token.sh"
       ]
  }
}
