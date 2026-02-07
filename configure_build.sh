#!/bin/bash

# --- Configuration options 

BUILD_DIR=build
BUILD_TYPE=Release
FC=`which gfortran`

# --- Remove existing build dir

if [ -d "./$BUILD_DIR" ]; then
	rm -rf ./$BUILD_DIR
fi 

# --- Build application and libraries

mkdir $BUILD_DIR
pushd $BUILD_DIR
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_Fortran_COMPILER=$FC ..
make
popd

# --- Copy Python extension library

cp $BUILD_DIR/src/particle-lib/*.so .
cp $BUILD_DIR/src/particles/particles .
