#!/bin/sh
set -ex

inst_docker_via_apt() {
  # Uninstall all conflicting packages
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  # Install the latest version
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Linux postinstall section
  sudo usermod -aG docker $USER && newgrp docker

  echo '[zx] inst_docker_via_apt success!!!'
}

inst_docker_via_deb() {
  # Install Docker via .deb
  INST_TMP_DIR="./temp$(date +%s)" \
  INST_OS_ID="$(. /etc/os-release && echo "$ID")" # "ubuntu"
  INST_OS_VERSION_ID="$(. /etc/os-release && echo "$VERSION_ID")" # "22.04"
  INST_OS_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")" # "jammy"
  INST_OS_ARCH="$(dpkg --print-architecture)" # "amd64"
  INST_OS_IVCA="${INST_OS_ID}.${INST_OS_VERSION_ID}~${INST_OS_CODENAME}_${INST_OS_ARCH}"
  INST_PKG_NAMES="containerd.io_1.7.22-1_${INST_OS_ARCH}.deb docker-ce_27.2.1-1~${INST_OS_IVCA}.deb docker-ce-cli_27.2.1-1~${INST_OS_IVCA}.deb docker-buildx-plugin_0.16.2-1~${INST_OS_IVCA}.deb docker-compo>
  INST_FROM_URL="https://download.docker.com/linux/ubuntu/dists/${INST_OS_CODENAME}/pool/stable/${INST_OS_ARCH}/" \
  sudo apt update
  wget -N $(for pkg_name in ${INST_PKG_NAMES}; do printf " ${INST_FROM_URL}${pkg_name}"; done) -P "${INST_TMP_DIR}/"
  test $(ls "${INST_TMP_DIR}" | wc -l) -eq "$(echo "${INST_PKG_NAMES}" | wc -w)"
  sudo apt install -y "${INST_TMP_DIR}/"*
  rm -rf "${INST_TMP_DIR}"
  sudo usermod -aG docker $USER && newgrp docker
  echo '[zx] inst_docker_via_deb success!!!'
}

main() {
  if [ "inst_docker_via_apt" = "$1" ]; then
    inst_docker_via_apt "$@"
  elif [ "inst_docker_via_deb" = "$1" ]; then
    inst_docker_via_deb "$@"
  fi
}

main "$@"
echo '[zx] all success!!!'
