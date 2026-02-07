#!/bin/bash

# --- Configuration options 

BUILD_DIR=build
BUILD_TYPE=Release
FC=`which gfortran`

# --- Build application

if [ -d "./$BUILD_DIR" ]; then
    pushd $BUILD_DIR
    cmake -DCMAKE_BUILD_TYPE="Release" -DCMAKE_Fortran_COMPILER=$FC ..
    make
    popd
fi 

# --- Copy Python extension module

cp $BUILD_DIR/src/particle-lib/*.so .
cp $BUILD_DIR/src/particles/particles .
