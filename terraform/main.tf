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
  pm_api_token_id = "root@pam!terraform-token"
  pm_api_token_secret = "8901aab5-0d68-4bd7-a2f0-117ddd23efb6"
  pm_tls_insecure = true # Como es un lab con certificados self-signed
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  # Añade esto si el error persiste para forzar la validación
  pm_parallel = 1
}

resource "proxmox_lxc" "nuevo_contenedor" {
  target_node = "proxmox-lab" # Nombre de tu nodo Proxmox
  hostname    = "lxc-terraform"
  ostemplate  = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password    = "Password123"
  unprivileged = true

  // Definición de recursos
  cores  = 1
  memory = 512

  // Configuración de red
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.10.223/24"
    gw     = "192.168.10.1"
  }
}
