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
    docker 2>/dev/null || {
      printf -- "\n[$(date) @ X] 安装Docker应用 Install Docker\n"
      wget -qO- http://get.docker.io | sh \
      && sudo usermod -aG docker $USER \
      && docker 2>/dev/null
    } || break

    # init project directories
    mkdir -p "${var_main_dist_dirname}" || break

    [ -z "${ENV_DOCKER_USERNAME}" ] && local ENV_DOCKER_USERNAME="$2"  # "${{ github.actor }}"
    [ -z "${ENV_DOCKER_TOKEN}" ] && local ENV_DOCKER_TOKEN="$3"  # "${{ secrets.DOCKERHUB_TOKEN }}"
    [ -z "${ENV_DOCKERIMAGE_THISTAG}" ] && local ENV_DOCKERIMAGE_THISTAG="$4"  # "$GITHUB_RUN_NUMBER"
    [ -z "${ENV_DOCKERIMAGE_REPONAME}" ] && local ENV_DOCKERIMAGE_REPONAME="$5"  # e.g. "node12-ci"

    local var_dockerimage_reponame="${ENV_DOCKERIMAGE_REPONAME}"
    local var_dockerimage_imagename="${ENV_DOCKER_USERNAME}/${var_dockerimage_reponame}"
    local var_dockerimage_filebasename="dockerimg@@${ENV_DOCKER_USERNAME}@${var_dockerimage_reponame}"

    echo "本地构建 Docker Image: ${var_dockerimage_reponame}"
    docker build . --file "Dockerfile_${ENV_DOCKER_USERNAME}@${var_dockerimage_reponame}" \
      --tag "${var_dockerimage_imagename}:$ENV_DOCKERIMAGE_THISTAG" || break

    docker tag "${var_dockerimage_imagename}:$ENV_DOCKERIMAGE_THISTAG" \
      "${var_dockerimage_imagename}:latest" || break

    echo "即将发布 Docker Image: ${var_dockerimage_imagename}:$ENV_DOCKERIMAGE_THISTAG"
    echo "${ENV_DOCKER_TOKEN}" | docker login -u "${ENV_DOCKER_USERNAME}" --password-stdin || break
    
    docker push "${var_dockerimage_imagename}:$ENV_DOCKERIMAGE_THISTAG" || break
    docker push "${var_dockerimage_imagename}:latest" || break
    
    docker logout || break
    # docker images
    docker save "${var_dockerimage_imagename}:$ENV_DOCKERIMAGE_THISTAG" \
      > "${var_dockerimage_filebasename}@$ENV_DOCKERIMAGE_THISTAG.tar" || break

    echo "已顺利发布 Docker Image: ${var_dockerimage_imagename}:$ENV_DOCKERIMAGE_THISTAG"
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
