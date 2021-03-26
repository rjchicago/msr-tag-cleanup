# msr-tag-cleanup

## who is this for?

For those using Mirantis Secure Registry (MSR) -- formerly Docker Trusted Registry (DTR).

If you have hundreds of tags you wish to clean up, the MSR UI can be less than optimal.

## get tags

Run `get-tags.sh` to get all tags for a given repo:

``` sh
sh get-tags.sh "my.msr-registry.com/org/my-service"
```

## delete tags

After running `get-tags.sh`, review the output before continuing.

> **WARNING!**
>
> See tags output file located in `./temp`
>
> **REMOVE** all `tags` you wish to **KEEP**!!!

Run `del-tags.sh` to delete all tags saved in the output file.

``` sh
sh del-tags.sh "my.msr-registry.com/org/my-service"
```
