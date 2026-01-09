variable "prefix" { type = string }
variable "location" { type = string }

variable "sql_admin_login" {
  type    = string
  default = "sqladminuser"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "container_image" {
  type        = string
  description = "Напр: myacr.azurecr.io/backend:1.0.0"
}

variable "tags" {
  type    = map(string)
  default = { project = "BeStrong" }
}
