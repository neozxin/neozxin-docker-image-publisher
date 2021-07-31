# neozxin-docker-image-publisher

## Docker image build and upload

#### Update environment variables in `.github/workflows/github-workflow-docker-publish.yml`

e.g.
 - ENV_CI_DOCKER_USERNAME: `"neozxin"`
 - ENV_CI_DOCKERIMAGE_FEATURENAME: `"dev-gate-server"`
 - ENV_CI_DOCKERIMAGE_REPOURL: `"https://github.com/neozxin/ubuntu-init.git"`
 - ENV_CI_DOCKERIMAGE_REPOYML: `"./dev-servers/docker-compose.yml"`

e.g.
 - ENV_CI_DOCKER_USERNAME: `"neozxin"`
 - ENV_CI_DOCKERIMAGE_FEATURENAME: `"node12-ci"`
 - ENV_CI_DOCKERIMAGE_REPOURL: `""`
 - ENV_CI_DOCKERIMAGE_REPOYML: `""`
