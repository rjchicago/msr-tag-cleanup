
#!/bin/sh
# set -x
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

IMAGE=${1:-}
if [[ -z $IMAGE ]] ; then
  echo "IMAGE is required. E.g. 'my.msr-registry.com/org/my-service'"
  exit 1
fi


DTR_USER=
DTR_PASSWORD=


if [[ -z $DTR_USER ]] ; then
  echo && echo "DTR User:" 
  read DTR_USER
fi
if [[ ! -z $DTR_USER ]] && [[ -z $DTR_PASSWORD ]] ; then
  echo && echo "Password for $DTR_USER:" 
  read -s DTR_PASSWORD
fi

if [[ -z $DTR_USER ]] || [[ -z $DTR_PASSWORD ]]; then
  echo && echo "User & Password are required."
  exit 1
fi



function get_repo() {
    local DTR_URL=$1
    local ORG=$2
    local REPO=$3
    URL="https://${DTR_URL}/api/v0/repositories/${ORG}/${REPO}"
    local RESPONSE=$(curl \
        -X "GET" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        ${URL} \
        -K- <<< "-u ${DTR_USER}:${DTR_PASSWORD}")
    local ERRORS=$(echo $RESPONSE | jq -r '.errors | length' || 0)
    if (( ERRORS > 0 )) ; then
        echo ""
    else
        echo $RESPONSE
    fi
}

function create_repo() {
    local DTR_URL=$1
    local ORG=$2
    local REPO=$3
    local IMMUTABLE_TAGS=${4:-false}
    local TAG_LIMIT=$([[ $IMMUTABLE_TAGS = true ]] && echo "0" || echo "100")
    local DATA="{
  \"immutableTags\": $IMMUTABLE_TAGS,
  \"longDescription\": \"$REPO\",
  \"name\": \"$REPO\",
  \"shortDescription\": \"$REPO\",
  \"tagLimit\": $TAG_LIMIT,
  \"visibility\": \"public\"
}"
    URL="https://${DTR_URL}/api/v0/repositories/${ORG}/"
    curl \
        -X "POST" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$DATA" \
        ${URL} \
        -K- <<< "-u ${DTR_USER}:${DTR_PASSWORD}"
}

function get_or_create_repo() {
    local DTR_URL=$1
    local ORG=$2
    local REPO=$3
    local IMMUTABLE_TAGS=${4:-false}
    local DTR_REPO=$(get_repo $DTR_URL $ORG $REPO)
    if [[ -z $DTR_REPO ]] ; then
        DTR_REPO=$(create_repo $DTR_URL $ORG $REPO $IMMUTABLE_TAGS)
    fi
    echo $DTR_REPO
}



DTR_URL=$(echo $IMAGE  | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\1/p')
ORG=$(echo $IMAGE      | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\2/p')
REPO=$(echo $IMAGE     | sed -n -e 's/\([^\/]*\)\/\([^\/]*\)\/\(.*\)/\3/p')

DTR_REPO=$(get_or_create_repo $DTR_URL $ORG $REPO)
DTR_REPO_RELEASE=$(get_or_create_repo $DTR_URL $ORG $REPO-release "true")

