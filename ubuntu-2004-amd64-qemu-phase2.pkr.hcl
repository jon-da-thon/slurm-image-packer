source "qemu" "ubuntu-2004-amd64-qemu-phase2" {
  vm_name           = "ubuntu-2004-amd64-qemu-provision"
  iso_url           = "output-ubuntu-2004-amd64-qemu-phase1/ubuntu-2004-amd64-qemu-osinstall"
  iso_checksum      = "none"
  headless          = var.headless
  memory            = 4096
  disk_image        = true
  output_directory  = "output-ubuntu-2004-amd64-qemu-phase2"
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
  name              = "provision"

  sources           = ["source.qemu.ubuntu-2004-amd64-qemu-phase2"]

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/phase2/trim.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/phase2/provision-nomad.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/phase2/provision-slurm.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/phase2/install-rust.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/phase2/install-gitlab-ci-runner.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }

  provisioner "shell" {
    use_env_var_file = true
    script          = "scripts/ubuntu-2004-amd64-qemu/common/cleanup.sh"
    execute_command = "chmod +x {{.Path}}; . {{.EnvVarFile}} && sudo -E bash {{.Path}}"
  }
}

