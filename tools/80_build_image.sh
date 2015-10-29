#!/bin/bash -x
TAG=${1:-latest}
REGISTRY_USER=bjodah
DOCKERFILE_NAME=bjodahimg

absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"/environment
docker build -t $REGISTRY_USER/$DOCKERFILE_NAME:$TAG . | tee ../docker_build.log && \
docker run --name bjodah-bjodahimg-tests -e TERM -v $absolute_repo_path/tests:/tests:ro $REGISTRY_USER/$DOCKERFILE_NAME:$TAG /tests/run_tests.sh
TEST_EXIT=$(docker wait bjodah-bjodahimg-tests)
docker rm bjodah-bjodahimg-tests
if [[ "$TEST_EXIT" != "0" ]]; then
    echo "Tests failed"
    exit 1
else
    echo "Tests passed"
    echo "You may now push your image:"
    echo "    $ docker push $REGISTRY_USER/$DOCKERFILE_NAME:$TAG"
fi
