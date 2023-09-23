### OUTPUTS ###
output "nginx-public-ip" {
    # from the terraform plan output we see the path to the object we want:
    # the resource type: google_compute_instance
    # the resource instance name: nginx_instance
    # the network_interface: network_interface
    # attribute of network_interface: access_config
    # attribute of the access_config: nat_ip
    # network_interface and access_config are maps so we need to take the element wanted
    # in this example their is only
    # one network_interface therefore element 0: "[0]" and only one access_config therefore element 0: "[0]"
    # address list items using the element value or position
    value = google_compute_instance.nginx_instance.network_interface[0].access_config[0].nat_ip
}

output "db-private-ip" {
    value = google_compute_instance.mysqldb.network_interface[0].network_ip
}

# Looping with count
output "webserver-ips" {
    # the splat operator "*", equals a "for", for each instance. 
    # there are multiple instances as determined by count in the google_compute_instance block 
    # this is a way to flatten the list of instances [0, 1, 2] (a list of count 3) into a single item 
    # "*", splat, does that.
    value = google_compute_instance.web-instances[*].network_interface[0].network_ip
}

## Looping with count replaces this code
# output "web1-private-ip" {
#     value = google_compute_instance.web1.network_interface[0].network_ip
# }

# output "web2-private-ip" {
#     value = google_compute_instance.web2.network_interface[0].network_ip
# }

# output "web3-private-ip" {
#     value = google_compute_instance.web3.network_interface[0].network_ip
# }
