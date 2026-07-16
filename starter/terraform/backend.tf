# State stocké dans HCP Terraform (workspace simplon-terraform-tp)
terraform {
  cloud {
    organization = "WhiteMuush-Organizations"

    workspaces {
      name = "simplon-terraform-tp"
    }
  }
}
