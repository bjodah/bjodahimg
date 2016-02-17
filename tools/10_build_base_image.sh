#!/bin/bash -x
TAG=${1:-latest}
REGISTRY_USER=${2}
DOCKERFILE_NAME=bjodahimgbase

ABS_REPO_PATH=$(unset CDPATH && cd "$(dirname "$0")/.." && echo $PWD)
cd "$ABS_REPO_PATH"/bjodahimgbase-dockerfile/environment
docker build -t $REGISTRY_USER/$DOCKERFILE_NAME:$TAG . | tee $ABS_REPO_PATH/$(basename $0).log && \
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    docker run --name bjodah-bjodahimgbase-tests -e TERM -v $ABS_REPO_PATH/tests_base:/tests:ro \
        $REGISTRY_USER/$DOCKERFILE_NAME:$TAG /tests/run_tests.sh
else
    exit 1
fi
TEST_EXIT=$(docker wait bjodah-bjodahimgbase-tests)
docker rm bjodah-bjodahimgbase-tests

if [[ "$TEST_EXIT" != "0" ]]; then
    echo "Tests failed"
    exit 1
fi

cat <<EOF
Tests passed


You should now commit the changes to trigger a trusted build:

    $ cd bjodahimgbase-dockerfile/
    $ git commit -am 'Updated version'
    $ git push
EOF
