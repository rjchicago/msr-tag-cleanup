#!/bin/sh
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}


IMAGE=$1
if [[ -z $IMAGE ]] ; then
  echo "IMAGE is required. E.g. 'my.msr-registry.com/org/my-service'"
  exit 1
fi

MSR_URL=$(echo $IMAGE  | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\1/p')
ORG=$(echo $IMAGE      | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\2/p')
REPO=$(echo $IMAGE     | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\3/p')

mkdir -p temp/${ORG}
FILE="temp/${ORG}/${REPO}.json"
URL="https://${MSR_URL}/api/v1/repositories/${ORG}/${REPO}/tags?includeManifests=false&pageSize=5000"
curl --compressed $URL \
  | jq -r '.[] | {updated: .updatedAt, created: .createdAt, name: .name} | @json' \
  | sort > $FILE

echo && echo "Tags: ./$FILE" && echo
