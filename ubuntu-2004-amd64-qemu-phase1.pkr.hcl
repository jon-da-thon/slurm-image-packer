source "qemu" "ubuntu-2004-amd64-qemu-phase1" {
  vm_name           = "ubuntu-2004-amd64-qemu-osinstall"
  iso_url           = "http://www.releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
  iso_checksum      = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
  headless          = var.headless
  memory            = 4096
  disk_image        = false
  output_directory  = "output-ubuntu-2004-amd64-qemu-phase1"
  accelerator       = "kvm"
  disk_size         = "8G"
  disk_interface    = "virtio"
  disk_cache        = "unsafe"
  format            = "qcow2"
  net_device        = "virtio-net"
  boot_wait         = "3s"
  boot_command      = [
    "<eOn><wait5s><eOff><esc><esc><enter><wait>",
    "/casper/vmlinuz initrd=/casper/initrd autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-2004-amd64-qemu/",
    "<enter>"
  ]
  http_directory    = "http-server"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username      = "ubuntu"
  ssh_password      = "ubuntu"
  ssh_timeout       = "60m"
}

build {
  name              = "osinstall"

  sources           = ["source.qemu.ubuntu-2004-amd64-qemu-phase1"]
}
