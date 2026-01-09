terraform {
    required_version = ">= 0.15"
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.9.11"
        }
    }
}

# Var to use secret file 
variable "PM_API_TOKEN_ID" {
  description = "The username for the DB master user"
  type        = string
  sensitive = true
}

variable "PM_API_TOKEN_SECRET" {
  description = "The password for the DB master user"
  type        = string
  sensitive = true
}

variable "SSH_KEY" {
  description = "The password for the DB master user"
  type        = string
  sensitive = true
}

# Token information for non login info
provider "proxmox" {
    pm_api_url          = "http://192.168.1.169:8006/api2/json"
    pm_api_token_id     = var.PM_API_TOKEN_ID
    pm_api_token_secret = var.PM_API_TOKEN_SECRET
    pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "vm-instance" {
    # VM Settings
    count = 2
    name                = "vm-${count.index + 1}"
    target_node         = var.proxmox_host #pve
    clone               = var.template_name   #Ubuntu-2024-init
    agent = 1
    os_type = "cloud-init"
    full_clone          = true
    sockets = 1
    cores               = 2
    memory              = 2048

    # Disk settings for VM
    disk {
        size            = "12G"
        type            = "scsi"
        storage         = "local-lvm"
        discard         = "on"
    }

    # Network settings for VM
    network {
        model     = "virtio"
        bridge    = "vmbr0"
        firewall  = false
        link_down = false
    }

    lifecycle {
      ignore_changes = [
        network,
      ]
    }

    # Assign IP address using count var to increase count for each VM created
    ipconfig0 = "ip=192.168.1.17${count.index + 1}/24,gw=192.168.1.1"

    # sshkeys set using variables. The variable contains the text of the key
    sshkeys = <<EOF
    ${var.SSH_KEY}
    EOF
}
