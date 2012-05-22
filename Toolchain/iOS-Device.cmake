# This is a toolchain file for iOS device target.
# This file is based off of toolchain/iOS.cmake file from http://code.google.com/p/ios-cmake/
# It has been modified and split to Platform/iOS.cmake and toolchain files for device and simulator.

# Options:
#
# CMAKE_IOS_DEVELOPER_ROOT = automatic(default) or /path/to/platform/Developer folder
#   By default this location is automatcially chosen based on the IOS_PLATFORM value above.
#   If set manually, it will override the default location and force the user of a particular Developer Platform
#
# CMAKE_IOS_SDK_ROOT = automatic(default) or /path/to/platform/Developer/SDKs/SDK folder
#   By default this location is automatcially chosen based on the CMAKE_IOS_DEVELOPER_ROOT value.
#   In this case it will always be the most up-to-date SDK found in the CMAKE_IOS_DEVELOPER_ROOT path.
#   If set manually, this will force the use of a specific SDK version

# Macros:
#
# set_xcode_property (TARGET XCODE_PROPERTY XCODE_VALUE)
#  A convenience macro for setting xcode specific properties on targets
#  example: set_xcode_property (myioslib IPHONEOS_DEPLOYMENT_TARGET "3.1")
#
# find_host_package (PROGRAM ARGS)
#  A macro used to find executable programs on the host system, not within the iOS environment.
#  Thanks to the android-cmake project for providing the command


# Standard settings
set (CMAKE_SYSTEM_NAME "iOS")
set (CMAKE_SYSTEM_PROCESSOR "arm")
set (IOS_PLATFORM "DEVICE")
if (NOT DEFINED CMAKE_SYSTEM_VERSION)
  set (CMAKE_SYSTEM_VERSION "5.1")
endif (NOT DEFINED CMAKE_SYSTEM_VERSION)

# Force the compilers to clang for iOS
include (CMakeForceCompiler)
CMAKE_FORCE_C_COMPILER (clang Clang)
CMAKE_FORCE_CXX_COMPILER (clang++ Clang)
