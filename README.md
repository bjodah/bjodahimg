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
$ ./20_download_python_packages.sh
$ ./40_build_packages.sh
$ ./60_upload_to_repo.sh
$ ./70_generate_Dockerfile.sh
$ ./80_build_image.sh
```

See [deb-buildscripts/](deb-buildscripts/) for packages built by
[tools/40_build_packages.sh](tools/40_build_packages.sh).

If tests pass in the last step the new ``Dockerfile`` is commited in
git and pushed to
[bjodahimg-dockerfile](https://github.com/bjodah/bjodahimg-dockerfile) 
which triggers a trusted build on
[docker hub](https://hub.docker.com/r/bjodah/bjodahimg).
