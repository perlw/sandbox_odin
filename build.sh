#!/bin/sh

if [ ! -d build ]; then
  mkdir build
fi
pushd build

odin build ../src -out:sandbox -define:DEBUG_DRAW_TIMINGS=true -show-timings -debug -vet -strict-style -warnings-as-errors -verbose-errors

popd
