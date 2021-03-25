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
FILE="temp/${DTR_REPO}.json"


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

function login() {
  LOGIN_FILE="temp/.login"
  curl -sSL -D $LOGIN_FILE \
    -X "POST" \
    -H "Connection: keep-alive" \
    -H "Pragma: no-cache" \
    -H "Cache-Control: no-cache" \
    -H "sec-ch-ua: \"Google Chrome\";v=\"89\", \"Chromium\";v=\"89\", \";Not A Brand\";v=\"99\"" \
    -H "Accept: application/json, text/plain, */*" \
    -H "X-Csrf-Token: undefined" \
    -H "sec-ch-ua-mobile: ?0" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Origin: https://$DTR_URL" \
    -H "Sec-Fetch-Site: same-origin" \
    -H "Sec-Fetch-Mode: cors" \
    -H "Sec-Fetch-Dest: empty" \
    -H "Referer: https://$DTR_URL/login" \
    -H "Accept-Language: en-US,en;q=0.9" \
    --data-raw "username=$DTR_USER&password=$DTR_PASSWORD" \
    "https://$DTR_URL/login_submit"

  SESSION=$(cat $LOGIN_FILE | grep root_session | sed -n -e 's/.*root_session=\([^;]*\);.*/\1/p')
  TOKEN=$(cat $LOGIN_FILE | grep csrftoken | sed -n -e 's/.*csrftoken=\([^;]*\);.*/\1/p')
}

function delete_tag() {
  TAG=$1
  URL="https://${DTR_URL}/api/v0/repositories/${DTR_REPO}/tags/$TAG"
  curl \
    -X "DELETE" \
    -H "Connection: keep-alive" \
    -H "Pragma: no-cache" \
    -H "Cache-Control: no-cache" \
    -H "sec-ch-ua: \"Google Chrome\";v=\"89\", \"Chromium\";v=\"89\", \";Not A Brand\";v=\"99\"" \
    -H "accept: application/json" \
    -H "X-Csrf-Token: $TOKEN" \
    -H "sec-ch-ua-mobile: ?0" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36" \
    -H "Content-Type: application/json" \
    -H "Origin: https://dtr.cnvr.net" \
    -H "Sec-Fetch-Site: same-origin" \
    -H "Sec-Fetch-Mode: cors" \
    -H "Sec-Fetch-Dest: empty" \
    -H "Referer: https://dtr.cnvr.net/docs/api" \
    -H "Accept-Language: en-US,en;q=0.9" \
    -H "Cookie: _ga=GA1.2.1648158083.1603721138; root_session=$SESSION; csrftoken=$TOKEN" \
    ${URL}
}

# if file exists .docker/config.json
if [[ ! -z $DTR_PASSWORD ]] ; then
  login
  while read LINE; do
    TAG=$(echo $LINE | jq -r '.name')
    echo "DELETING $TAG..."
    delete_tag $TAG
  done < $FILE
fi
