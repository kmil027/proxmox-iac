terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.10.178:8006/api2/json"
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "nodos_k3s" {
  count       = 4
  name        = "nodo${count.index + 1}"
  target_node = "proxmox-lab"
  clone       = "ubuntu-2404-template"
  vmid        = 300 + count.index
  
  # Forzar clonación completa y arranque automático
  full_clone = true
  onboot     = true
  agent      = 1

  # Recursos
  cores   = 2
  sockets = 1
  memory  = 2048
  cpu     = "host"

  # Configuración Cloud-Init (Evita el error de conversión de datos)
  os_type    = "cloud-init"
  ciuser     = "root"
  cipassword = "Camilo08"
  
  # Estos parámetros ayudan a que el plugin no reciba valores nulos de la API
  nameserver   = "8.8.8.8"
  searchdomain = "local.lan"
  ipconfig0    = "ip=192.168.10.${223 + count.index}/24,gw=192.168.10.1"
  
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmxDrS6ZLy/HxPdP5mN135maZcrWyGeF2NpfQbiB4IC
  EOF

  disk {
    size    = "20G"
    type    = "scsi"
    storage = "local"
  }
}

variable "proxmox_api_token_id" {}
variable "proxmox_api_token_secret" {}