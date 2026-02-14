terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      # Cambiamos de 2.9.11 a una versión que corrige el crash de Cloud-Init
      version = "3.0.2-rc07" 
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
  count       = 1
  name        = "nodo${count.index + 1}" [cite: 10]
  target_node = "proxmox-lab" [cite: 10]
  clone       = "ubuntu-2404-template" [cite: 10]
  vmid        = 300 + count.index [cite: 10]
  
  full_clone = true [cite: 10]
  onboot     = true [cite: 10]
  agent      = 1 [cite: 10]

  # --- MEJORAS DE ESTABILIDAD ---
  boot       = "order=scsi0;ide2"
  scsihw     = "virtio-scsi-pci"
  
  cores     = 2 [cite: 10]
  sockets   = 1 [cite: 10]
  cpu_type  = "host" [cite: 10]
  memory    = 2048 [cite: 11]

  network {
    id     = 0 [cite: 11]
    model  = "virtio" [cite: 11]
    bridge = "vmbr0" [cite: 11]
  }

  disk {
    slot    = "scsi0" [cite: 11]
    size    = "20G" [cite: 11]
    type    = "disk" [cite: 11]
    storage = "local" [cite: 11]
  }

  disk {
    slot    = "ide2" 
    type    = "cloudinit" 
    storage = "local" 
  }

  os_type    = "cloud-init" 
  ciuser     = "root" 
  cipassword = "Camilo08" 
  nameserver = "8.8.8.8" 
  ipconfig0  = "ip=192.168.10.${223 + count.index}/24,gw=192.168.10.1" 
  
  sshkeys = <<EOF
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmxDrS6ZLy/HxPdP5mN135maZcrWyGeF2NpfQbiB4IC
  EOF
}

variable "proxmox_api_token_id" {}
variable "proxmox_api_token_secret" {}