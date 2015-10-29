#!/bin/bash -e

# Extract absolute path of dir above script, from:
# http://unix.stackexchange.com/a/9546
absolute_repo_path_x="$(readlink -fn -- "$(dirname $0)/.."; echo x)"
absolute_repo_path="${absolute_repo_path_x%x}"
cd "$absolute_repo_path"

tmpdir=$(mktemp -d)
trap "rm -r $tmpdir" SIGINT SIGTERM EXIT
virtualenv $tmpdir
source $tmpdir/bin/activate
pip install --no-use-wheel --download pypi_download $(cat resources/python_packages.txt | tr '\n' ' ')

echo '#!/bin/bash -e'>tests/test_python_packages.sh
for pypkg in $(cat resources/python_packages.txt); do
    if [[ $pypkg == *-* ]]; then
        continue
    fi
    echo "python -c \"import $pypkg\"">>tests/test_python_packages.sh
done
