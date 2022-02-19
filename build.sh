#!/bin/sh

if [ ! -d build ]; then
  mkdir build
fi
pushd build

odin build ../main.odin -out:sandbox -show-timings -debug -vet -strict-style -warnings-as-errors -verbose-errors

popd
