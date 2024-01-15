terraform {
  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
}

provider "b2" {
    endpoint = "production"
}

resource "b2_bucket" "pgbackrest_backup" {
  bucket_name = "pgbackrest-backup-bucket"
  bucket_type = "allPrivate"
}
