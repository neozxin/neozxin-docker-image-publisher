#!/bin/sh
# Install Docker via .deb
INST_TMP_DIR="./temp$(date +%s)" \
INST_OS_ID="$(. /etc/os-release && echo "$ID")" # "ubuntu"
INST_OS_VERSION_ID="$(. /etc/os-release && echo "$VERSION_ID")" # "22.04"
INST_OS_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")" # "jammy"
INST_OS_ARCH="$(dpkg --print-architecture)" # "amd64"
INST_OS_IVCA="${INST_OS_ID}.${INST_OS_VERSION_ID}~${INST_OS_CODENAME}_${INST_OS_ARCH}"
INST_PKG_NAMES="containerd.io_1.7.22-1_${INST_OS_ARCH}.deb docker-ce_27.2.1-1~${INST_OS_IVCA}.deb docker-ce-cli_27.2.1-1~${INST_OS_IVCA}.deb docker-buildx-plugin_0.16.2-1~${INST_OS_IVCA}.deb docker-compose-plugin_2.29.2-1~${INST_OS_IVCA}.deb" \
INST_FROM_URL="https://download.docker.com/linux/ubuntu/dists/${INST_OS_CODENAME}/pool/stable/${INST_OS_ARCH}/" \
&& sudo apt update \
&& wget -N $(for pkg_name in ${INST_PKG_NAMES}; do printf " ${INST_FROM_URL}${pkg_name}"; done) -P "${INST_TMP_DIR}/" \
&& test $(ls "${INST_TMP_DIR}" | wc -l) -eq "$(echo "${INST_PKG_NAMES}" | wc -w)" \
&& sudo apt install -y "${INST_TMP_DIR}/"* \
&& rm -rf "${INST_TMP_DIR}" \
&& sudo usermod -aG docker $USER && newgrp docker
