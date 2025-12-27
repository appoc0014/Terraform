variable "ssh_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUZaVNFPj6uaTawcoppORp+hm2Elbl9Lm/MhsO+JOuP appoc@appoc-LT"
}
variable "proxmox_host" {
    default = "pve"
}
variable "template_name" {
    default = "Ubuntu-2024-init"
}
