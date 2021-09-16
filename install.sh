#!/usr/bin/env bash

set -eux

for f in $(find . -name '.*' -maxdepth 1 -not -name '.git' | grep -v '^.$' ); do
    n=$(basename ${f})
    src=$(pwd)/${n}
    dist=${HOME}/${n}
    ln -snf ${src} ${dist}
done