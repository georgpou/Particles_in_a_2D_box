# Skeleton code for particle simulation application

This directory contains the files required to build a particle simulation application including a python extension module.

The source directory contains:

* src/common - Main modules which is used by both the main fortran code as well as the extension module.
* src/particle-lib - Library containing the main modules. Used by the Python extension library.
* src/particles - Main fortran code. Uses the modules from src/common.

# Requirements Windows

To build the application the following must be installed:

* Qt Creator with MinGW toolchain for desktop development 
* CMake
* Anaconda Python

# Requirements Linux / macOS

To build the application the following must be installed:

* Fortran compiler (gfortran 8.x or higher)
* Anaconda Python
* CMake

# Opening project in Qt Creator

To build the application in Qt Creator open the CMakeLists.txt file in the root source directory.

# Creating an environment for running Python

To be able to use the **vedo** visualisation library a suitable environment must be created:

    $ conda create -n sciprog-project python=3.7
    $ conda activate sciprog-project
    $ pip install vedo

# Building the application and Python module - Windows

To build the application and extension module issue the following commands

    C:\...\> configure_build.cmd

To clean the build:

    C:\...\> clean.cmd

To build without configure:

    C:\...\> build.cmd

# Building the application and Python module - Linux / macOS

To build the application and extension module issue the following commands

    $ ./configure_build

To clean the build:

    $ ./clean

To build without configure:

    $ ./build

# Running the applications - Windows

Running Fortran code (generates particle.state):

    C:\...\> run_fortran.cmd

Visualising particle traces:

    C:\...\> run_particles_player_vedo.cmd

Running the Python code:

    C:\...\> run_python.cmd

Running the interactive Python simulator:

    C:\...\> run_python_vedo.cmd

# Running the applications - Linux

Running Fortran code (generates particle.state):

    $ ./run_fortran.sh

Visualising particle traces:

    $ ./run_particles_player_vedo.sh

Running the Python code:

    $ ./run_python.sh

Running the interactive Python simulator:

    $ ./run_python_vedo.sh

