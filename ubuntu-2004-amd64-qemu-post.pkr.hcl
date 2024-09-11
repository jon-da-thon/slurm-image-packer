source "null" "ubuntu-2004-amd64-qemu-post" {
  communicator = "none"
}

build {
  name = "post"

  sources = [
    "source.null.ubuntu-2004-amd64-qemu-post"
  ]

  post-processor "shell-local" {
    inline = [
      "qemu-img convert -p -f qcow2 -O vpc $(jq -r \".builds[0].files[0].name\" manifest_softlayer.json) ubuntu-2004-amd64-nomad.vhd"
    ]
  }

  post-processor "artifice" {
    files = [
      "ubuntu-2004-amd64-nomad.vhd"
    ]
    keep_input_artifact = true
  }

  ## after artifice it doesnt seem to be actually overriding artifacts for subsequent post-processors within this build
  # post-processor "manifest" {
  #   output     = "manifest-post.json"
  #   strip_path = false
  # }
  # post-processor "checksum" {
  #   checksum_types = ["sha256"]
  #   output = "SHA256SUM_{{.BuildName}}"
  # }
}
