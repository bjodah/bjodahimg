#!/bin/bash -xu
TAG=${1}
REGISTRY_USER=${2}  # avoid clash with trusted build
DOCKERFILE_NAME=bjodahimg

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"/bjodahimg-dockerfile/environment

docker build -t $REGISTRY_USER/$DOCKERFILE_NAME:$TAG . | tee ../../$(basename $0).log
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    docker run --name bjodah-bjodahimg-tests -e TERM -v $absolute_repo_path/tests:/tests:ro \
        $REGISTRY_USER/$DOCKERFILE_NAME:$TAG /tests/run_tests.sh
else
    exit 1
fi

TEST_EXIT=$(docker wait bjodah-bjodahimg-tests)
docker rm bjodah-bjodahimg-tests

if [[ "$TEST_EXIT" != "0" ]]; then
    echo "Tests failed"
    exit 1
else
    cat <<EOF
Tests passed


You should now commit the changes to trigger a trusted build:

    $ cd bjodahimg-dockerfile/
    $ git commit -am 'Updated version'
    $ git push
EOF
fi
