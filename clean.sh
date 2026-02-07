#!/bin/bash

# --- Configuration options 

BUILD_DIR=build

# --- Remove existing build dir

if [ -d "./$BUILD_DIR" ]; then
	rm -rf ./$BUILD_DIR
fi 

rm -f *.so
rm -f ./particles
rm -f particle.state