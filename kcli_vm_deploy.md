
# Install
curl https://raw.githubusercontent.com/karmab/kcli/main/install.sh | sudo bash
sudo apt-get -y install python3-kcli
sudo kcli create pool -p /var/lib/libvirt/images default
sudo setfacl -m u:$(id -un):rwx /var/lib/libvirt/images
kcli create host kvm -H 127.0.0.1 local
kcli create network  -c 192.168.122.0/24 default


# Reference
https://kcli.readthedocs.io/en/latest/#



# [Typical commands](https://kcli.readthedocs.io/en/latest/#typical-commands)
