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

resource "scaleway_object_bucket" "some_bucket" {
    name = "pgbackrest-backup-bucket"
}
