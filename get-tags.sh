#!/bin/sh
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}


DTR_REPO=$1
if [[ -z $DTR_REPO ]] ; then
  echo "DTR Repo is required. E.g. 'gui/my-service'"
  exit 1
fi

DTR_URL=${bamboo_DTR_URL:-dtr.cnvr.net}
DTR_USER=${bamboo_DTR_USER:-}
DTR_PASSWORD=${bamboo_DTR_PASSWORD:-}

# hook for local testing
if [[ -z $DTR_USER ]] ; then
  echo "DTR User:" 
  read DTR_USER
fi
if [[ ! -z $DTR_USER ]] && [[ -z $DTR_PASSWORD ]] ; then
  echo "DTR Password for $DTR_USER:" 
  read -s DTR_PASSWORD
fi

function get_tags() {
  URL="https://${DTR_URL}/api/v1/repositories/${DTR_REPO}/tags?includeManifests=false&pageSize=5000"
  FILE="temp/${DTR_REPO}.json"
  curl --compressed $URL | jq -r '.[] | {updated: .updatedAt, created: .createdAt, name: .name} | @json' | sort > $FILE
}

function delete_tag() {
  TAG=$1
  URL="https://${DTR_URL}/api/v0/repositories/${DTR_REPO}/tags/$TAG"
  curl -X 'DELETE' -w "$TAG, Status: %{response_code}\\n" --compressed $URL
}


# if file exists .docker/config.json
if [[ ! -z $DTR_PASSWORD ]] ; then
  export DOCKER_CONFIG="${bamboo_build_working_directory:-$(pwd)}/.docker"
  echo "$DTR_PASSWORD" | docker login -u $DTR_USER --password-stdin $DTR_URL
  get_tags
  # delete tags...
  docker logout $DTR_URL
fi
