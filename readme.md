# dtr-prune

Run

``` sh
ORG="gui"
REPO="my-repo"

mkdir -p temp/${ORG}
sh get-tags.sh ${ORG}/${REPO}

code temp/${ORG}/${REPO}.json
```

**WARNING!**
Remove all `tags` you wish to keep!!!

``` sh
sh del-tags.sh ${ORG}/${REPO}
```
