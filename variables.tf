### VARIABLES
variable "project-id" {
  type = string
}

variable "region" {
  type = string
  # if no value for this var is specified then the default value will be used
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-a"
}

variable "dbusername" {
  type = string
  default = "db-user"
  sensitive = true
}

variable "dbpassword" {
  type = string
  sensitive = true
}

variable "subnet-name" {
  type = string
  default = "subnet1"
}

variable "subnet-cidr" {
  type = string
  default = "10.127.0.0/20"
}

variable "private_google_access" {
  type = bool
  default = true
}

variable "firewall-ports" {
  type = list
  default = ["80", "8080", "1000-2000", "22"]
}

variable "compute-source-tags" {
    type = list
    default = ["web"]
}

variable "target_environment" {
  default = "DEV"
}

variable "environment_list" {
  type = list(string)
  default = ["DEV","QA","STAGE","PROD"]
}

# Key value pair
variable "environment_map" {
  type = map(string)
  default = {
    "DEV" = "dev",
    "QA" = "qa",
    "STAGE" = "stage",
    "PROD" = "prod"
  }
}

variable "environment_machine_type" {
  type = map(string)
  default = {
    "DEV" = "f1-micro",
    "QA" = "e2-micro",
    "STAGE" = "e2-micro",
    "PROD" = "e2-medium"
  }
}

variable "environment_instance_settings" {
  # map(objects) can contain multiple different values 
  # eg the "DEV" key has a map of its own with mutliple key values as 
  # opposed to the environment_machine_type map in the block above
  type = map(object({machine_type=string, labels=map(string)}))
  default = {
    "DEV" = {
      machine_type = "f1-micro"
      labels = {
        environment = "dev"
      }
    },
   "QA" = {
      machine_type = "e2-micro"
      labels = {
        environment = "qa"
      }
    },
    "STAGE" = {
      machine_type = "e2-micro"
      labels = {
        environment = "stage"
      }
    },
    "PROD" = {
      machine_type = "e2-medium"
      labels = {
        environment = "prod"
      }
    }
  }
}

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

# Map resource tags
# Each of the resources and modules declared in main.tf includes two tags: project_name and environment. 
# Assign these tags with a map variable type.
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS#map-resource-tags
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    namesp      = "nsexample"
    project     = "projectexample",
    service     = "serviceexmaple"
  }
}
