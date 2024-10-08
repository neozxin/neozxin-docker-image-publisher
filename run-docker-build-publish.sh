#!/bin/sh

printArgs() {
  local IFS="|"
  printf -- "\n[$(date) @ X] 检测命令行参数 Command arguments separated by '|': $*\n"
}

run__DockerBuildPublish() {
  printf -- "\n[$(date) @ X] Info: 执行构建与发布 Docker Image Build & Publish - Run\n"
  local var_common_scriptdir="$(cd "$(dirname "$0")" && pwd)"
  while true; do
    set -x
    cd "${var_common_scriptdir}"

    # make sure prerequisites
    ## install Docker
    docker version 2>/dev/null || {
      printf -- "\n[$(date) @ X] 安装Docker应用 Install Docker\n"
      wget -qO- http://get.docker.io | sh \
      && sudo usermod -aG docker $USER \
      && docker version 2>/dev/null
    } || break

    # get parameters ready
    [ -z "${ENV_CI_DOCKER_USERNAME}" ] && local ENV_CI_DOCKER_USERNAME="$2"  # "${{ github.actor }}"
    [ -z "${ENV_CI_DOCKER_TOKEN}" ] && local ENV_CI_DOCKER_TOKEN="$3"  # "${{ secrets.DOCKERHUB_TOKEN }}"
    [ -z "${ENV_CI_DOCKERIMAGE_THISTAG}" ] && local ENV_CI_DOCKERIMAGE_THISTAG="$4"  # "${GITHUB_RUN_NUMBER}"
    [ -z "${ENV_CI_DOCKERIMAGE_FEATURENAME}" ] && local ENV_CI_DOCKERIMAGE_FEATURENAME="$5"  # e.g. "node12-ci", "dev-gate-server"
    [ -z "${ENV_CI_DOCKERIMAGE_REPOURL}" ] && local ENV_CI_DOCKERIMAGE_REPOURL="$6"  # e.g. "https://github.com/neozxin/neozxin-docker-image-publisher.git"
    [ -z "${ENV_CI_DOCKERIMAGE_REPOYML}" ] && local ENV_CI_DOCKERIMAGE_REPOYML="$7"  # e.g. "./dev-servers/docker-compose.yml"
    [ -z "${ENV_CI_DIST_DIR}" ] && local ENV_CI_DIST_DIR="$8"  # e.g. "dist-artifact"
    local var_dockerimage_name_thistag="${ENV_CI_DOCKER_USERNAME}/${ENV_CI_DOCKERIMAGE_FEATURENAME}:${ENV_CI_DOCKERIMAGE_THISTAG}"
    local var_dockerimage_name_latest="${ENV_CI_DOCKER_USERNAME}/${ENV_CI_DOCKERIMAGE_FEATURENAME}:latest"

    # init project directories
    mkdir -p "${ENV_CI_DIST_DIR}" || break

    echo "本地构建 Docker Image: ${var_dockerimage_name_thistag}"
    if [ -n "${ENV_CI_DOCKERIMAGE_REPOURL}" ]; then
      local var_localrepopath=".${ENV_CI_DOCKERIMAGE_THISTAG}-$(basename "${ENV_CI_DOCKERIMAGE_REPOURL}")"
      git clone "${ENV_CI_DOCKERIMAGE_REPOURL}" "${var_localrepopath}" || break
      sudo env ENV_DOCKERC_TAG="${ENV_CI_DOCKERIMAGE_THISTAG}" docker-compose -f "${var_localrepopath}/${ENV_CI_DOCKERIMAGE_REPOYML}" build || break
    else
      sudo docker build . --file "Dockerfile_${ENV_CI_DOCKER_USERNAME}@${ENV_CI_DOCKERIMAGE_FEATURENAME}" \
        --tag "${var_dockerimage_name_thistag}" || break
    fi

    echo "标记为最新镜像 + 保存为文件: ${var_dockerimage_name_latest}"
    sudo docker tag "${var_dockerimage_name_thistag}" \
      "${var_dockerimage_name_latest}" || break
    local var_dockerimage_savename="dockerimg_$(echo "${var_dockerimage_name_thistag}" | sed -e 's/\//~/g' -e 's/:/@/g')_$(date +'%Y-%m-%dT%H-%M-%S%z')"
    sudo docker save "${var_dockerimage_name_thistag}" | gzip > "${ENV_CI_DIST_DIR}/${var_dockerimage_savename}.tar.gz" || break

    echo "即将发布 Docker Image: ${var_dockerimage_name_thistag}"
    # echo "${ENV_CI_DOCKER_TOKEN}" | sudo docker login -u "${ENV_CI_DOCKER_USERNAME}" --password-stdin || break
    sudo docker login -u "${ENV_CI_DOCKER_USERNAME}" -p "${ENV_CI_DOCKER_TOKEN}" || break
    sudo docker push "${var_dockerimage_name_thistag}" || break
    sudo docker push "${var_dockerimage_name_latest}" || break
    sudo docker logout || break

    echo "已顺利发布 Docker Image: ${var_dockerimage_name_thistag}"
    return
  done
  return 1
}

main() {
  printArgs "$@"
  while true; do
    if [ -z "$1" ]; then
      run__DockerBuildPublish "$@" || break
    elif [ "use.files" = "$1" ]; then
      echo "Feature coming soon" || break
    elif [ "use.account" = "$1" ]; then
      echo "Feature coming soon" || break
    else
      printf -- "\n使用示例 Usage example: $0\n"
      printf -- "\n使用示例 Usage example: $0 '' USERNAME USERTOKEN 'latest' 'node12-ci'\n"
      printf -- "\n使用示例 Usage example: $0 use.files\n"
      printf -- "\n使用示例 Usage example: $0 use.account\n"
      break
    fi
    set +x
    printf -- "\n[$(date) @ X] 成功 Success!\n"
    return
  done
  printf -- "\n[$(date) @ X] 失败 Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
