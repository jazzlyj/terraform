provider "libvirt" {
uri = "qemu:///system"}
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
} ## 1. --------> Section that declares the provider in Terraform registry

# 2. ----> We fetch the smallest ubuntu image from the cloud image repo
resource "libvirt_volume" "ubuntu-disk" {
name   = "ubuntu-qcow2"
pool   = "default" ## ---> This should be same as your disk pool name 
source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
format = "qcow2"
}

# 3. -----> Create the compute vm
resource "libvirt_domain" "ubuntu-vm" {
name   = "ubuntu-vm"
memory = "8192"
vcpu   = 2
 network_interface {
   network_name = "default" ## ---> This should be the same as your network name 
  }

 console { # ----> define a console for the domain.
   type        = "pty"
   target_port = "0"
   target_type = "serial" }
 disk {   volume_id = libvirt_volume.ubuntu-disk.id } # ----> map/attach the disk 
graphics { ## ---> graphics settings
   type        = "spice"
   listen_type = "address"
   autoport    = "true"}
}