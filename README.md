# Personal Docker image useful for scientific computing

Based on Ubuntu 14.04 LTS. Dependencies not in Ubuntu repositories are kept
in [source tree](./environment/resources) for easier reproducibility
(Ubuntu repository mirrors are widespread and expected to be available
for the foreseeable future).

See [Dockerfile](./environment/Dockerfile) for list of installed packages.
See also [bjodahimgbase](https://github.com/bjodah/bjodahimgbase)

## How to build the image

In principle the following steps are executed:

```
$ ./tools/10_generate_Dockerfile.sh
$ ./tools/20_download_python_packages.sh
$ ./tools/40_build_packages.sh
$ ./tools/60_upload_resources.sh
$ ./tools/80_build_image.sh
```

See [deb-buildscripts/](deb-buildscripts/) for packages built by
[tools/40_build_packages.sh](tools/40_build_packages.sh).

If tests pass in the last step the Dockerfile is commited in git and
pushed to github which triggers a trusted build on [docker hub](
https://hub.docker.com/r/bjodah/bjodahimg).
