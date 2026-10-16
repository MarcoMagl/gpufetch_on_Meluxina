#!/bin/bash
#
# setup_gpu_fetch.sh
#
# Author  : Marco Magliulo (LuxProvide)
# Purpose : Build and run the gpufetch tool
#           (https://github.com/Dr-Noob/gpufetch) on the Meluxina supercomputer.
# Usage   : Free to use and share openly.
#

# Fail fast: exit on error, error on unset variables, and fail on broken pipes.
set -euo pipefail

# --- Configuration -----------------------------------------------------------
GPUFETCH_REPO="git@github.com:Dr-Noob/gpufetch.git"
GPUFETCH_DIR="gpufetch"
BUILD_FLAVOR="cuda"

# --- Helpers -----------------------------------------------------------------
log() {
    echo "[setup_gpu_fetch] $*"
}

die() {
    echo "[setup_gpu_fetch] ERROR: $*" >&2
    exit 1
}

# --- Prerequisite checks -----------------------------------------------------
for tool in git ml; do
    command -v "$tool" >/dev/null 2>&1 || die "required tool '$tool' not found in PATH."
done

# --- Load build environment (Meluxina modules) -------------------------------
log "Loading environment modules (CUDA, CMake)..."
ml CUDA CMake

# --- Clone (only if not already present) -------------------------------------
if [ -d "$GPUFETCH_DIR" ]; then
    log "Directory '$GPUFETCH_DIR' already exists; skipping clone."
else
    log "Cloning gpufetch from $GPUFETCH_REPO ..."
    git clone "$GPUFETCH_REPO"
fi

cd "$GPUFETCH_DIR" || die "cannot enter '$GPUFETCH_DIR'."

# --- Build -------------------------------------------------------------------
[ -x ./build.sh ] || chmod +x ./build.sh

log "Building gpufetch for '$BUILD_FLAVOR'..."
./build.sh "$BUILD_FLAVOR"

# --- Verify the build produced a runnable binary -----------------------------
[ -x ./gpufetch ] || die "build did not produce an executable './gpufetch'."

log "Installation done!"
./gpufetch
