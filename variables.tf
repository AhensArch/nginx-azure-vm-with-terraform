variable "admin_username" {
  description = "The admin username for the Linux VM"
  type        = string
  default     = "stellar"
}

variable "admin_ssh_public_key" {
  description = "The public SSH key to install on the VM"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH. Leave empty to disable SSH access."
  type        = string
  default     = ""
}
