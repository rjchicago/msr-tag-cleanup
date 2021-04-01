# MSR Tag Cleanup

## Who is this for?

For those using **Mirantis Secure Registry** (**MSR**) - _formerly **Docker Trusted Registry** (**DTR**)_.

If you have hundreds of tags you wish to clean up, the MSR UI can be less than optimal.

## Requirements

`jq`: can be obtained here: <https://stedolan.github.io/jq/download/>

## Get Tags

Run `get-tags.sh` to get all tags for a given repo:

``` sh
sh get-tags.sh "my.msr-registry.com/org/my-service"
```

## Delete Tags

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

## Update Tag Limit

Per [documentation](https://docs.mirantis.com/containers/v3.1/dockeree-products/msr/msr-user/tag-pruning.html#set-a-tag-limit), users are supposed to be able to set a repositories tag limit. However, this option does not appear unless you have uber admin privileges.

A workaround is to use the MSR API to PATCH the specified repository. See `update_tag_limit.sh`:

``` sh
sh update_tag_limit.sh my.msr-registry.com/org/my-service 50
```

## Troubleshooting

### I get an error with `immutability` turned on

> You cannot delete tags with immutability on. Turn immutability off, delete, then re-enable as needed.
