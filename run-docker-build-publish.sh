#!/bin/sh

printArgs() {
  local IFS="|"
  printf -- "\n[$(date) @ X] 检测命令行参数 Command arguments separated by '|': $*\n"
}

run__DockerBuildPublish() {
  printf -- "\n[$(date) @ X] Info: 执行构建与发布 Docker Image Build & Publish - Run\n"
  local var_common_scriptdir="$(cd "$(dirname "$0")" && pwd)"
  local var_main_dist_dirname="neozxin-dist-docker-images"
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

    # init project directories
    mkdir -p "${var_main_dist_dirname}" || break

    [ -z "${ENV_CI_DOCKER_USERNAME}" ] && local ENV_CI_DOCKER_USERNAME="$2"  # "${{ github.actor }}"
    [ -z "${ENV_CI_DOCKER_TOKEN}" ] && local ENV_CI_DOCKER_TOKEN="$3"  # "${{ secrets.DOCKERHUB_TOKEN }}"
    [ -z "${ENV_CI_DOCKERIMAGE_THISTAG}" ] && local ENV_CI_DOCKERIMAGE_THISTAG="$4"  # "$GITHUB_RUN_NUMBER"
    [ -z "${ENV_CI_DOCKERIMAGE_FEATURENAME}" ] && local ENV_CI_DOCKERIMAGE_FEATURENAME="$5"  # e.g. "node12-ci", "dev-gate-server"
    [ -z "${ENV_CI_DOCKERIMAGE_REPOURL}" ] && local ENV_CI_DOCKERIMAGE_REPOURL="$6"  # e.g. "https://github.com/neozxin/neozxin-docker-image-publisher.git"
    [ -z "${ENV_CI_DOCKERIMAGE_REPOYML}" ] && local ENV_CI_DOCKERIMAGE_REPOYML="$7"  # e.g. "./dev-servers/docker-compose.yml"

    local var_dockerimage_featurename="${ENV_CI_DOCKERIMAGE_FEATURENAME}"
    local var_dockerimage_imagename="${ENV_CI_DOCKER_USERNAME}/${var_dockerimage_featurename}"
    local var_dockerimage_filebasename="dockerimg@${ENV_CI_DOCKER_USERNAME}@${var_dockerimage_featurename}"

    echo "本地构建 Docker Image: ${var_dockerimage_featurename}"
    if [ -n "${ENV_CI_DOCKERIMAGE_REPOURL}" ]; then
      local var_localrepopath=".${ENV_CI_DOCKERIMAGE_THISTAG}-$(basename "${ENV_CI_DOCKERIMAGE_REPOURL}")"
      git clone "${ENV_CI_DOCKERIMAGE_REPOURL}" "${var_localrepopath}" || break
      sudo env ENV_DOCKERC_TAG="${ENV_DOCKERIMAGE_THISTAG}" docker-compose -f "${var_localrepopath}/${ENV_CI_DOCKERIMAGE_REPOYML}" build || break
    else
      sudo docker build . --file "Dockerfile_${ENV_CI_DOCKER_USERNAME}@${var_dockerimage_featurename}" \
        --tag "${var_dockerimage_imagename}:$ENV_CI_DOCKERIMAGE_THISTAG" || break
    fi

    sudo docker tag "${var_dockerimage_imagename}:$ENV_CI_DOCKERIMAGE_THISTAG" \
      "${var_dockerimage_imagename}:latest" || break

    echo "即将发布 Docker Image: ${var_dockerimage_imagename}:$ENV_CI_DOCKERIMAGE_THISTAG"
    # echo "${ENV_CI_DOCKER_TOKEN}" | sudo docker login -u "${ENV_CI_DOCKER_USERNAME}" --password-stdin || break
    sudo docker login -u "${ENV_CI_DOCKER_USERNAME}" -p "${ENV_CI_DOCKER_TOKEN}" || break
    
    sudo docker push "${var_dockerimage_imagename}:$ENV_CI_DOCKERIMAGE_THISTAG" || break
    sudo docker push "${var_dockerimage_imagename}:latest" || break
    
    sudo docker logout || break
    # sudo docker images
    sudo docker save "${var_dockerimage_imagename}:$ENV_CI_DOCKERIMAGE_THISTAG" \
      > "${var_main_dist_dirname}/${var_dockerimage_filebasename}@$ENV_CI_DOCKERIMAGE_THISTAG.tar" || break

    echo "已顺利发布 Docker Image: ${var_dockerimage_imagename}:$ENV_CI_DOCKERIMAGE_THISTAG"
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
