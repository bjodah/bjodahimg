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
$ ./tools/20_download_python_packages.sh
$ ./tools/40_build_packages.sh latest
$ ./tools/60_upload_to_repo.sh latest
$ ./tools/70_generate_Dockerfile.sh latest
$ ./tools/80_build_image.sh latest dummy_reg_user
```

See [deb-buildscripts/](deb-buildscripts/) for packages built by
[tools/40_build_packages.sh](tools/40_build_packages.sh).

If tests pass in the last step the new ``Dockerfile`` is commited in
git and pushed to
[bjodahimg-dockerfile](https://github.com/bjodah/bjodahimg-dockerfile) 
which triggers a trusted build on
[docker hub](https://hub.docker.com/r/bjodah/bjodahimg):

```
$ cd bjodahimg-dockerfile
$ git commit -am "various updates"
$ git tag -a vX.Y -m vX.Y
$ git push
$ git push --tags
$ cd ../
$ git commit -am "new release X.Y"
$ git push
```
