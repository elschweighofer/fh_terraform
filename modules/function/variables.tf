# terraform/variables.tf

variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type        = string
  description = "Azure region to deploy module to"
}
variable "resource_group_name" {
  type = string
}

variable "endpoint" {
  type = string
}

variable "key" {
  type = string
}
