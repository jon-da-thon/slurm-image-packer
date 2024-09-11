source "qemu" "ubuntu-2004-amd64-qemu-softlayer" {
  vm_name           = "ubuntu-2004-amd64-qemu-softlayer"
  iso_url           = "output-ubuntu-2004-amd64-qemu-phase2/ubuntu-2004-amd64-qemu-provision"
  iso_checksum      = "none"
  headless          = var.headless
  memory            = 4096
  disk_image        = true
  output_directory  = "output-ubuntu-2004-amd64-qemu-softlayer"
  accelerator       = "kvm"
  disk_size         = "10G"
  disk_interface    = "virtio"
  disk_cache        = "unsafe"
  format            = "qcow2"
  net_device        = "virtio-net"
  boot_wait         = "3s"
  shutdown_command  = "sudo shutdown -P now"
  ssh_username      = "ubuntu"
  ssh_password      = "ubuntu"
  ssh_timeout       = "60m"
  http_directory    = "http-server"
}

build {
  name              = "softlayer"

  sources           = ["source.qemu.ubuntu-2004-amd64-qemu-softlayer"]

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/softlayer/provision-softlayer.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/common/cleanup.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/common/prime-cloudinit.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  post-processor "manifest" {
    output     = "manifest_softlayer.json"
    strip_path = false
  }

  post-processor "shell-local" {
    inline = [
      "qemu-img resize -f qcow2 $(jq -r \".builds[0].files[0].name\" manifest_softlayer.json) 100G"
    ]
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output = "SHA256SUM_{{.BuildName}}"
  }
}
