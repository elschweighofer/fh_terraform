# terraform/variables.tf

variable "project" {
  type        = string
  default     = "cloudplatforms"
  description = "Project name"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Azure region to deploy module to"
}