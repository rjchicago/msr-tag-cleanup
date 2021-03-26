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

## Troubleshooting

### I get an error with `immutability` turned on

> You cannot delete tags with immutability on. Turn immutability off, delete, then re-enable as needed.
