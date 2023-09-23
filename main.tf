# Interpolate variables in strings:
# Terraform configuration supports string interpolation — via the "${}"" operator
# inserting the output of an expression into a string.
# This allows you to use variables, local values, and the output of functions 
# to create strings in your configuration.
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS#interpolate-variables-in-strings

# Use locals to name resources:
# In the configuration's main.tf file, several resource names consist of interpolations 
# of the resource type and the project and environment values from the resource_tags variable. 
# Reduce duplication and simplify the configuration by setting the shared part 
# of each name as a local value to re-use across your configuration.
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/locals#use-locals-to-name-resources
locals {
  namespace_suffix = "${var.resource_tags["namesp"]}"
  name_svc_suffix = "${var.resource_tags["project"]}-${var.resource_tags["namesp"]}-${var.resource_tags["service"]}"
}

# Namespaces in Kubernetes are logical isolation for deployment.
# Creating namespace with the Kubernetes provider is better than auto-creation in the helm_release.
# You can reuse the namespace and customize it with quotas and labels.
# resource "kubernetes_namespace_v1" "namespace" {
#     metadata {
#         name    = "${local.namespace_suffix}"
#         labels  = {
#           "app" = "${var.resource_tags["namesp"]}"
#         }
#     }
# }

### PROVIDER
provider "google" {
  project = var.project-id
  region  = var.region
  zone    = var.zone
}

### NETWORK
data "google_compute_network" "default" {
  name                    = "default"
}

## SUBNET
resource "google_compute_subnetwork" "subnet-1" {
  name                     = var.subnet-name
  ip_cidr_range            = var.subnet-cidr
  network                  = data.google_compute_network.default.self_link
  region                   = var.region
  private_ip_google_access = var.private_google_access
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.firewall-ports
  }

  source_tags = var.compute-source-tags
}

## BUCKETS
resource "google_storage_bucket" "environment_buckets" {
  # for_each only works with sets and maps. so we need to convert a list variable to a set
  # When using for-each, the set becomes the indexer, 
  # whereas count uses count.index to access the numerical value of the index for-each loop, 
  # for-each uses each.key, which we can see here. 
  # Bucket names have to be globally unique, so appending the project ID here to the names of the buckets, 
  # to ensure that they're unique. 
  for_each = toset(var.environment_list)
  name = "${lower(each.key)}_${var.project-id}"
  location = "US"
  versioning {
    enabled = true
  }
}

### COMPUTE
## NGINX PROXY
resource "google_compute_instance" "nginx_instance" {
  name         = "nginx-proxy"
  machine_type = var.environment_machine_type[var.target_environment]
  labels = {
    # Eg 
    # address list items using the element value or position
    # environment = var.environment_map["DEV"]
    # the "DEV" element in the environment_map var object
    environment = var.environment_map[var.target_environment]
  }
  tags = var.compute-source-tags
 
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
    access_config {
  
    }
  }
}

# Looping with for_each 
# Simplifies looping further over the looping with count approach
## WEBSERVERS-MAP
resource "google_compute_instance" "web-map-instances" {
  for_each = var.environment_instance_settings
  # When iterating over a map, for-each uses each.key and each.value 
  # to access the map keys and values respectively. 
  # Done here for the machine type, and for the labels
  name = "${lower(each.key)}-web"
  machine_type = each.value.machine_type
  labels = each.value.labels

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }  
}

# Looping with count
## WEBSERVERS
resource "google_compute_instance" "web-instances" {
  count        = 3
  name         = "web${count.index}"
  machine_type = var.environment_machine_type[var.target_environment]
  labels       = {
    environment = var.environment_map[var.target_environment]
  }
     boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }
}

## Looping with count replaces this code
# # WEB1
# resource "google_compute_instance" "web1" {
#   name         = "web1"
#   machine_type = var.environment_machine_type[var.target_environment]
#   labels = {
#     environment = var.environment_map[var.target_environment]
#   }
  
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     # A default network is created for all GCP projects
#     network = data.google_compute_network.default.self_link
#     subnetwork = google_compute_subnetwork.subnet-1.self_link
#   }
# }

# ## WEB2
# resource "google_compute_instance" "web2" {
#   name         = "web2"
#   machine_type = var.environment_machine_type[var.target_environment]
#   labels = {
#     environment = var.environment_map[var.target_environment]
#   }
  
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     network = data.google_compute_network.default.self_link
#     subnetwork = google_compute_subnetwork.subnet-1.self_link
#   }
# }
# ## WEB3
# resource "google_compute_instance" "web3" {
#   name         = "web3"
#   machine_type = var.environment_machine_type[var.target_environment]
#   labels = {
#     environment = var.environment_map[var.target_environment]
#   }
  
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     network = data.google_compute_network.default.self_link
#     subnetwork = google_compute_subnetwork.subnet-1.self_link
#   }  
# }

## DB
resource "google_compute_instance" "mysqldb" {
  name         = "mysqldb"
  machine_type = var.environment_machine_type[var.target_environment]
  labels = {
    environment = var.environment_map[var.target_environment]
  }
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = data.google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.subnet-1.self_link
  }  
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

## CLOUD SQL
resource "google_sql_database_instance" "cloudsql" {
  name             = "web-app-db-${random_id.db_name_suffix.hex}"
  database_version = "MYSQL_8_0"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
  deletion_protection = false
}

## CLOUD SQL USER
resource "google_sql_user" "users" {
  name     = var.dbusername
  instance = google_sql_database_instance.cloudsql.name
  password = var.dbpassword
}
