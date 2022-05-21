@echo off
setlocal ENABLEDELAYEDEXPANSION

REM CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat" > nul

IF NOT EXIST build mkdir build
pushd build

"../../Odin/odin" build ../src -out:sandbox.exe -define:DEBUG_DRAW_TIMINGS=true -show-timings -debug -pdb-name:sandbox.pdb -vet -strict-style -warnings-as-errors -verbose-errors

popd
