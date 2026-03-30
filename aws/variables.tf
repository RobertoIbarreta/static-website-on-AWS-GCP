variable "aws_region" {
    description = "The AWS region to deploy the static website to"
    type = string
    default = "us-east-1"
}

variable "project_name" {
    description = "The name of the project"
    type = string
}

variable "domain_name" {
  description = "The domain name of the static website"
  type = string
  
}

variable "site_subdomain" {
  description = "The subdomain of the static website"
  type = string
  default = "www"
}

variable "hosted_zone_id" {
    description = "The ID of the hosted zone for the domain"
    type = string    
}

variable "tags" {
    description = "The tags to apply to the resources"
    type = map(string)
    default = {
        Project = "static-website"
        Environment = "development"
    }
}