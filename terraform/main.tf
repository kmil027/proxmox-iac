terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox" # El "conector" oficial para Proxmox
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.10.178:8006/api2/json" # IP de tu Proxmox
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true # Como es un lab con certificados self-signed
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
}

resource "proxmox_lxc" "nuevo_contenedor" {
  count       = 4  # <--- Esto creará nodo1, nodo2 y nodo3
  target_node = "proxmox-lab" # Nombre de tu nodo Proxmox
  hostname    = "nodo${count.index + 1}" # nodo1, nodo2, nodo3
  ostemplate  = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password    = "Camilo08"
  unprivileged = true 
  start        = true # ¡Importante! Si no arrancan, Ansible no puede entrar
  vmid  = 200 + count.index # Esto forzará los IDs 200, 201 y 202 siempre
  
  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmxDrS6ZLy/HxPdP5mN135maZcrWyGeF2NpfQbiB4IC
  EOT

  features {
    nesting = true
    # keyctl  = true
    mount   = "nfs;cifs" #
  }

  // Definición de recursos
  cores  = 1
  memory = 1024
  
  rootfs {
    storage = "local" # O "local", dependiendo de tu Proxmox
    size    = "8G"
  }

  // Configuración de red
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.10.${223 + count.index}/24"
    gw     = "192.168.10.1"
  }
}

variable "proxmox_api_token_id" {}
variable "proxmox_api_token_secret" {}