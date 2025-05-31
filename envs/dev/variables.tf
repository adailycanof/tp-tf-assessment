# Variables file (variables.tf)
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "simhill"
}

# variable "container_image" {
#   description = "Container image URI"
#   type        = string
#   default     = "flask-tp-app"
# }

variable "container_image" {
  description = "Container image URI"
  type        = string
  default     = "946760796955.dkr.ecr.eu-west-2.amazonaws.com/flask-tp-app:latest"
}