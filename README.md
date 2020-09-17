# CentOS Source-build GCC and CMake

This project defines a Docker image which builds precisely specified versions of GCC, G++ and CMake
from their source distributions on CentOS for Intel x64.

The build command for GCC includes
a workaround for `make install` failing due to a shared-library which the build requires, and
isn't available to it. The workaround is specific to Intel x64, although it should be possible to
adapt it.
