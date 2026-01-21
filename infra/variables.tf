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
  description = "Full image name including tag, e.g. bestrongacrqi77nn.azurecr.io/dotnetcrudwebapi:abcd123"
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = { project = "BeStrong" }
}
