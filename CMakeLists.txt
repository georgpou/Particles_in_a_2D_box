cmake_minimum_required(VERSION 3.10)
project(particles)
enable_language(Fortran)

set(F2PY_COMMAND f2py)

subdirs(src)
