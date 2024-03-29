terraform {
    required_providers {
    scaleway = {
        source = "scaleway/scaleway"
        }
    }
    required_version = ">= 0.13"
}

provider "scaleway" {
    zone   = "fr-par-1"
    region = "fr-par"
}


resource "scaleway_account_project" "pgbackrest_poc" {
  name = "pgbackrest-poc"
}

resource "scaleway_object_bucket" "some_bucket" {
    name = "pgbackrest-backup-bucket2"
    project_id = scaleway_account_project.pgbackrest_poc.id
}


resource "scaleway_account_ssh_key" "stephane-klein-public-ssh-key" {
    name        = "stephane-klein-public-ssh-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEzyNFlEuHIlewK0B8B0uAc9Q3JKjzi7myUMhvtB3JmA2BqHfVHyGimuAajSkaemjvIlWZ3IFddf0UibjOfmQH57/faxcNEino+6uPRjs0pFH8sNKWAaPX1qYqOFhB3m+om0hZDeQCyZ1x1R6m+B0VJHWQ3pxFaxQvL/K+454AmIWB0b87MMHHX0UzUja5D6sHYscHo57rzJI1fc66+AFz4fcRd/z+sUsDlLSIOWfVNuzXuGpKYuG+VW9moiMTUo8gTE9Nam6V2uFwv2w3NaOs/2KL+PpbY662v+iIB2Yyl4EP1JgczShOoZkLatnw823nD1muC8tYODxVq7Xf7pM/NSCf3GPCXtxoOEqxprLapIet0uBSB4oNZhC9h7K/1MEaBGbU+E2J5/5hURYDmYXy6KZWqrK/OEf4raGqx1bsaWcONOfIVXbj3zXTUobsqSkyCkkR3hJbf39JZ8/6ONAJS/3O+wFZknFJYmaRPuaWiLZxRj5/gw01vkNVMrogOIkQtzNDB6fh2q27ghSRkAkM8EVqkW21WkpB7y16Vzva4KSZgQcFcyxUTqG414fP+/V38aCopGpqB6XjnvyRorPHXjm2ViVWbjxmBSQ9aK0+2MeKA9WmHN0QoBMVRPrN6NBa3z20z1kMQ/qlRXiDFOEkuW4C1n2KTVNd6IOGE8AufQ== contact@stephane-klein.info"
    project_id = scaleway_account_project.pgbackrest_poc.id
}

resource "scaleway_instance_ip" "server1_public_ip" {
    project_id = scaleway_account_project.pgbackrest_poc.id
}

resource "scaleway_instance_server" "server1" {
    project_id = scaleway_account_project.pgbackrest_poc.id
    name = "server1"
    type  = "DEV1-S"
    image = "ubuntu_jammy" # Last Ubuntu LTS version 22.04
                           # Execute "scw marketplace image list" to comsult the list of images proposed by Scaleway
    ip_id = scaleway_instance_ip.server1_public_ip.id
    root_volume {
        size_in_gb = 10
    }
}

resource "scaleway_instance_ip" "server2_public_ip" {
    project_id = scaleway_account_project.pgbackrest_poc.id
}

resource "scaleway_instance_server" "server2" {
    project_id = scaleway_account_project.pgbackrest_poc.id
    name = "server2"
    type  = "DEV1-S"
    image = "ubuntu_jammy" # Last Ubuntu LTS version 22.04
                           # Execute "scw marketplace image list" to comsult the list of images proposed by Scaleway
    ip_id = scaleway_instance_ip.server2_public_ip.id
    root_volume {
        size_in_gb = 10
    }
}
