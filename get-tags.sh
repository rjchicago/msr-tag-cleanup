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

DAYS=${2:-182}
CUTOFF_DATE=$(($(date +%s)-$DAYS*86400))

mkdir -p temp/${ORG}
FILE="temp/${ORG}/${REPO}.json"
URL="https://${MSR_URL}/api/v1/repositories/${ORG}/${REPO}/tags?includeManifests=false&pageSize=100"

curl --compressed $URL \
  | jq -r ".[] | select ( .updatedAt | sub(\".[0-9]+Z$\"; \"Z\") | fromdateiso8601 < $CUTOFF_DATE ) | {updated: .updatedAt, created: .createdAt, name: .name} | @json" \
  | sort > $FILE

echo && echo "Tags: ./$FILE" && echo
