@echo off
setlocal ENABLEDELAYEDEXPANSION

REM CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat" > nul

IF NOT EXIST build mkdir build
pushd build

odin build ../main.odin -out:sandbox.exe -show-timings -debug -vet -strict-style -warnings-as-errors -verbose-errors

popd
