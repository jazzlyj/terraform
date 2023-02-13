
# CENTOS/RHEL
## install terraform
sudo apt update
sudo apt install wget curl unzip
TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
unzip terraform_${TER_VER}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
which terraform
terraform --version


sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo modprobe vhost_net
echo vhost_net | sudo tee -a /etc/modules

curl -s https://api.github.com/repos/dmacvicar/terraform-provider-libvirt/releases/latest   | grep browser_download_url   | grep linux_amd64.zip   | cut -d '"' -f 4   | wget -i -
unzip terraform-provider-libvirt_*_linux_amd64.zip
rm -f terraform-provider-libvirt_*_linux_amd64.zip
mv terraform-provider-libvirt_* ~/.terraform.d/plugins/terraform-provider-libvirt




## Create 2 files
* main.tf
```terraform

```

* libvirt.tf
```terraform

```







# Ubuntu
## one file - ubuntu.tf

* Create ubuntu.tf
```yaml
provider "libvirt" {
 uri = "qemu:///system"
}

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}


# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-disk" {
 name   = "ubuntu-qcow2"
 pool   = "default"
 source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
 format = "qcow2"
}

#resource "libvirt_cloudinit_disk" "commoninit" {
# name           = "commoninit.iso"
# pool           = "default" #CHANGEME
# user_data      = data.template_file.user_data.rendered
# network_config = data.template_file.network_config.rendered
#}

#data "template_file" "user_data" {
# template = file("${path.module}/cloud_init.cfg")
#}

#data "template_file" "network_config" {
# template = file("${path.module}/network_config.cfg")
#}

# Create the machine
resource "libvirt_domain" "ubuntu-vm" {
 name   = "ubuntu-vm"
 memory = "512"
 vcpu   = 1

 #cloudinit = libvirt_cloudinit_disk.commoninit.id

 network_interface {
   network_name = "default"
 }

 # IMPORTANT
 # Ubuntu can hang is a isa-serial is not present at boot time.
 # If you find your CPU 100% and never is available this is why
 console {
   type        = "pty"
   target_port = "0"
   target_type = "serial"
 }

 console {
   type        = "pty"
   target_type = "virtio"
   target_port = "1"
 }

 disk {
   volume_id = libvirt_volume.ubuntu-disk.id
 }
 graphics {
   type        = "spice"
   listen_type = "address"
   autoport    = "true"
 }
}

```


terraform init
terraform plan
terraform apply -auto-approve