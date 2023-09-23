
# Install Terraform
```bash
sudo apt-get install wget curl unzip software-properties-common gnupg2 -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
sudo apt-get install terraform -y
terraform -v
```


# Input Variables

_variables.tf_

## Setting values

Multiple ways

1. _terraform.tfvars_ file
2. command-line options
3. env vars

- Command line example

```bash
terraform plan -var="project-id=advterraform"
```

```bash
terraform plan -var="project-id=advterraform" -var="target_environment=DEV"
```

# Output Variables

_outputs.tf_

# Sensitive Data

Hide output of sensitive data in the output of the terraform **_plan_**, **_apply_** and **_show_** commands

1. var in the block in the _main.tf_
   eg:

```terraform
## CLOUD SQL USER
resource "google_sql_user" "users" {
  name     = var.dbusername
  instance = google_sql_database_instance.cloudsql.name
  password = var.dbpassword
}
```

2. sensitive in the _variables.tf_ declaration

```terraform
variable "dbusername" {
  type = string
  sensitive = true
}

variable "dbpassword" {
  type = string
  sensitive = true
}
```

3. add the key value pairs of the actual secrets in the _terraform.tfvars_

```
dbusername = "chip"
dbpassword = "asdfasdf"
```

However the actual password is still stored as clear text in the state files.
A way around this is remote state. Storing the state in a S3 bucket or some other shared file system.
NOT in the repo or locally on a dev's host.

# Refreshing State

1. After either manually outside of terraform adding/updating/deleting resources check state

```bash
terraform state list
```

2. Update state. Terraform will check the plan, find the differences with the plan and the real world infrastructure and will ask to confirm to update the state file to reflect the detected changes.

```bash
terraform apply -refresh-only
```

3. To create the resource again, run the terraform apply command.
   State has changed but the configuration file still has the resource, so the resource will get created.

# [Import](https://developer.hashicorp.com/terraform/tutorials/state/state-import)

Bringing existing infrastructure under terraform management.

- Configuration-driven import relies on the import block, which has two required arguments:
  - _id_ is the provider-specific identifier for the infrastructure you want to import
  - _to_ is the identifier Terraform will give the resource in state, consisting of the resource type and name

0. get docker container hash
   Run the following command to return the full SHA256 container ID of the target (docker) container.

```bash
docker inspect --format="{{.ID}}" hashicorp-learn
```

1. Create the resource.tf file, eg docker.tf and define import block

```
import {
  id = "FULL_CONTAINER_ID"
  to = docker_container.web
}
```

2. Generate config
   When importing a resource, you must both bring the resource into your state file, and define a corresponding resource block for it in your configuration.

```
terraform plan -generate-config-out=generated.tf
```

3. Add key pieces to the resource definition (block)

In the case of a docker container add the necessary [docker resource container schema](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container?ajs_aid=26421394-9a36-43bf-b4cf-d9c39318f06d&product_intent=terraform#env) items

- env with string type: env = []
- the image hash (gotten above): image = "72d53edc26459adc666d60be2d57e6b8973238b6cedcc59fcb4e95639816b0bb"
- name
- ports block

```
resource "docker_container" "web" {
  env = []
  image = "..."
  name  = "hashicorp-learn"
  ports {
    external = 8080
    internal = 80
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
}
```

4. Terraform plan

```bash
terraform plan
```

Terraform now plans to import the resource, and then make changes in place to add the _attach_, _container_read_refresh_timeout_milliseconds_, _logs_, _must_run_, _remove_volumes_, _start_, _wait_, and _wait_timeout attributes_. These are non-destructive changes.

Terraform uses these attributes to create Docker containers, but Docker does not store them. Since Docker does not track these attributes, Terraform did not include them in the generated configuration. When you apply your configuration, the Docker provider will assign the default values for these attributes and save them in state, but they will not affect the running container.

4. Terraform apply

```bash
terraform apply
```



# [Terraform VM Deployment](./terraform_vm_deployment.md)


# [KCLI VM Deployment](./kcli_vm_deployment.md)