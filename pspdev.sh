#!/bin/bash
# pspdev.sh

# Load and export shared functions
source common.sh
export -f auto_extract
export -f download_and_extract
export -f clone_git_repo

# Parallelize build
export MAKEFLAGS="-j`num_cpus`"

# Enter the pspdev directory.
cd "`dirname $0`" || { echo "ERROR: Could not enter the pspdev directory."; exit 1; }

# Create the build directory.
mkdir -p build || { echo "ERROR: Could not create the build directory."; exit 1; }

# Enter the build directory.
cd build || { echo "ERROR: Could not enter the build directory."; exit 1; }

# Fetch the depend scripts.
DEPEND_SCRIPTS=(`ls ../depends/*.sh | sort`)

# Run all the depend scripts.
for SCRIPT in ${DEPEND_SCRIPTS[@]}; do
  "$SCRIPT" || { echo "$SCRIPT: Failed."; exit 1; }
done

# Fetch the build scripts.
BUILD_SCRIPTS=(`ls ../scripts/*.sh | sort`)

# If specific steps were requested...
if [ $1 ]; then
  # Run the requested build scripts.
  for STEP in $@; do
    "${BUILD_SCRIPTS[$STEP-1]}" || { echo "${BUILD_SCRIPTS[$STEP-1]}: Failed."; exit 1; }
  done
else
  # Run the all build scripts.
  for SCRIPT in ${BUILD_SCRIPTS[@]}; do
    "$SCRIPT" || { echo "$SCRIPT: Failed."; exit 1; }
  done
fi
