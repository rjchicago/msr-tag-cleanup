#!/bin/sh
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

if [[ -f .env ]]; then
  set -a; source .env; set +a
fi

MSR_USER=${MSR_USER:-}
MSR_PASSWORD=${MSR_PASSWORD:-}

IMAGE=${1:-}
if [[ -z $IMAGE ]] ; then
  echo "IMAGE is required. E.g. 'my.msr-registry.com/org/my-service'"
  exit 1
fi

TAG_LIMIT=${2:--1}
if (( TAG_LIMIT < 0 )); then
  echo "TAG_LIMIT:" 
  read TAG_LIMIT
fi

MSR_URL=$(echo $IMAGE | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\1/p')
ORG=$(echo $IMAGE     | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\2/p')
REPO=$(echo $IMAGE    | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\3/p')

if [[ -z $MSR_USER ]] ; then
  echo && echo "MSR User:" 
  read MSR_USER
fi
if [[ ! -z $MSR_USER ]] && [[ -z $MSR_PASSWORD ]] ; then
  echo && echo "Password for $MSR_USER:" 
  read -s MSR_PASSWORD
fi

if [[ -z $MSR_USER ]] || [[ -z $MSR_PASSWORD ]]; then
  echo && echo "User & Password are required."
  exit 1
fi

function update_tag_limit() {
  URL="https://${MSR_URL}/api/v0/repositories/${ORG}/${REPO}"
  curl \
    -X "PATCH" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"tagLimit\": $TAG_LIMIT}" \
    ${URL} \
    -K- <<< "-u ${MSR_USER}:${MSR_PASSWORD}"
}

update_tag_limit

