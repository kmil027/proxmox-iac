terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      # Cambiamos de 2.9.11 a una versión que corrige el crash de Cloud-Init
      version = "3.0.1-rc6" 
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.10.178:8006/api2/json"
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true
  
  # Aumentamos el timeout para evitar que el plugin "no responda" durante el clonado
  pm_timeout = 600 
}

resource "proxmox_vm_qemu" "nodos_k3s" {
  count       = 4
  name        = "nodo${count.index + 1}"
  target_node = "proxmox-lab"
  clone       = "ubuntu-2404-template"
  vmid        = 300 + count.index
  
  full_clone = true
  onboot     = true
  agent      = 1

  cores   = 2
  sockets = 1
  memory  = 2048
  cpu     = "host"

  os_type    = "cloud-init"
  ciuser     = "root"
  cipassword = "Camilo08"
  
  # Obligatorio para evitar que la API devuelva valores vacíos que rompan el plugin
  nameserver   = "8.8.8.8"
  ipconfig0    = "ip=192.168.10.${223 + count.index}/24,gw=192.168.10.1"
  
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmxDrS6ZLy/HxPdP5mN135maZcrWyGeF2NpfQbiB4IC
  EOF

  network {
    id     = 0       # <--- Este es el argumento que te falta (corresponde a net0)
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    slot    = 0      # <--- Obligatorio en v3.x (corresponde a scsi0)
    size    = "20G"
    type    = "scsi"
    storage = "local"
  }
}

variable "proxmox_api_token_id" {}
variable "proxmox_api_token_secret" {}