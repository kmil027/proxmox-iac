terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07" 
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.10.178:8006/api2/json"
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
  pm_timeout          = 600 
}

resource "proxmox_vm_qemu" "nodos_k3s" {
  count       = 1
  name        = "nodo${count.index + 1}"
  target_node = "proxmox-lab"
  clone       = "ubuntu-2404-template"
  vmid        = 300 + count.index
  
  full_clone = true
  onboot     = true
  agent      = 1

  # Estas 2 líneas evitan los reinicios constantes y el bucle de booteo
  boot       = "order=scsi0;ide2"
  scsihw     = "virtio-scsi-pci"

  vga {
    type = "serial0"
  }

  serial {
    id   = 0
    type = "socket"
  }
  
  cores     = 2
  sockets   = 1
  cpu_type  = "host"
  memory    = 2048

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    slot    = "scsi0"
    size    = "20G"
    type    = "disk"
    storage = "local"
  }

  # Drive de Cloud-Init necesario para la v3.x
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