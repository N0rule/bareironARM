#!/usr/bin/env bash

# Check for registries before attempting to compile
if [ ! -f "include/registries.h" ]; then
  echo "Error: 'include/registries.h' is missing."
  echo "Please follow the 'Compilation' section of the README to generate it."
  exit 1
fi

# Detect architecture
ARCH=$(uname -m)

# Figure out executable suffix
case "$OSTYPE" in
  msys*|cygwin*|win32*) exe=".exe" ;;
  *) exe="" ;;
esac

# mingw64-specific linker options
windows_linker=""
unameOut="$(uname -s)"
case "$unameOut" in
  MINGW64_NT*)
    windows_linker="-static -lws2_32 -pthread"
    ;;
esac

# Default compiler and optimization flags
compiler="gcc"
opt_flags="-O3"

# ARM-specific optimizations
if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
  echo "Detected ARM64 architecture - applying optimizations..."
  # Use native CPU optimization for best performance on target hardware
  opt_flags="$opt_flags -march=native -mtune=native"
  # Enable link-time optimization for better performance
  opt_flags="$opt_flags -flto"
  # Additional ARM optimizations
  opt_flags="$opt_flags -fomit-frame-pointer"
elif [[ "$ARCH" == "armv7l" ]] || [[ "$ARCH" == "armhf" ]]; then
  echo "Detected ARM32 architecture - applying optimizations..."
  opt_flags="$opt_flags -march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard"
  opt_flags="$opt_flags -flto -fomit-frame-pointer"
fi

# Handle arguments for windows 9x build
for arg in "$@"; do
  case $arg in
    --9x)
      if [[ "$unameOut" == MINGW64_NT* ]]; then
        compiler="/opt/bin/i686-w64-mingw32-gcc"
        windows_linker="$windows_linker -Wl,--subsystem,console:4"
      else
        echo "Error: Compiling for Windows 9x is only supported when running under the MinGW64 shell."
        exit 1
      fi
      ;;
    --no-run)
      NO_RUN=1
      ;;
  esac
done

rm -f "bareiron$exe"

# Build with appropriate flags
if [[ "$unameOut" != MINGW64_NT* ]]; then
  echo "Building statically linked binary for Linux with flags: $opt_flags"
  $compiler src/*.c $opt_flags -Iinclude -static -o "bareiron$exe"
else
  $compiler src/*.c $opt_flags -Iinclude -o "bareiron$exe" $windows_linker
fi

# Only run if not in Docker build context
if [[ -z "$NO_RUN" ]]; then
  "./bareiron$exe"
fi
