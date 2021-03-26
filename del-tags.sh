#!/bin/sh
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

MSR_USER=
MSR_PASSWORD=

IMAGE=${1:-}
if [[ -z $IMAGE ]] ; then
  echo "IMAGE is required. E.g. 'my.msr-registry.com/org/my-service'"
  exit 1
fi

MSR_URL=$(echo $IMAGE | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\1/p')
ORG=$(echo $IMAGE     | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\2/p')
REPO=$(echo $IMAGE    | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\3/p')
FILE="temp/${ORG}/${REPO}.json"

echo
echo "####################### WARNING! #######################"
echo "You are about to delete tags for $IMAGE"
echo "Tags to be deleted are located in ./$FILE"

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

function delete_tag() {
  TAG=$1
  URL="https://${MSR_URL}/api/v0/repositories/${ORG}/${REPO}/tags/${TAG}"
  curl \
    -X "DELETE" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    ${URL} \
    -K- <<< "-u ${MSR_USER}:${MSR_PASSWORD}"
}

echo && echo "DELETING:"
while read LINE; do
  TAG=$(echo $LINE | jq -r '.name')
  delete_tag $TAG
  echo " ✓ $TAG"
done < $FILE

echo
echo "######################### DONE #########################"
echo
