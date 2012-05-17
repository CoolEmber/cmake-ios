# This file is based off of the Platform/Darwin.cmake file which are included with CMake 2.8.8
# and toolchain/iOS.cmake file from http://code.google.com/p/ios-cmake/
# It has been altered for iOS development

SET(APPLE 1)

# iOS version
STRING(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\1" IOS_MAJOR_VERSION "${CMAKE_SYSTEM_VERSION}")
STRING(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\2" IOS_MINOR_VERSION "${CMAKE_SYSTEM_VERSION}")

# Darwin (Host) version
STRING(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\1" DARWIN_MAJOR_VERSION "${CMAKE_HOST_SYSTEM_VERSION}")
STRING(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\2" DARWIN_MINOR_VERSION "${CMAKE_HOST_SYSTEM_VERSION}")

IF(NOT DEFINED HAVE_FLAG_SEARCH_PATHS_FIRST)
  SET(HAVE_FLAG_SEARCH_PATHS_FIRST 1)
ENDIF(NOT DEFINED HAVE_FLAG_SEARCH_PATHS_FIRST)
# More desirable, but does not work:
  #INCLUDE(CheckCXXCompilerFlag)
  #CHECK_CXX_COMPILER_FLAG("-Wl,-search_paths_first" HAVE_FLAG_SEARCH_PATHS_FIRST)

SET(CMAKE_SHARED_LIBRARY_PREFIX "lib")
SET(CMAKE_SHARED_LIBRARY_SUFFIX ".dylib")
SET(CMAKE_SHARED_MODULE_PREFIX "lib")
SET(CMAKE_SHARED_MODULE_SUFFIX ".so")
SET(CMAKE_MODULE_EXISTS 1)
SET(CMAKE_DL_LIBS "")

SET(CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG "-compatibility_version ")
SET(CMAKE_C_OSX_CURRENT_VERSION_FLAG "-current_version ")
SET(CMAKE_CXX_OSX_COMPATIBILITY_VERSION_FLAG "${CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG}")
SET(CMAKE_CXX_OSX_CURRENT_VERSION_FLAG "${CMAKE_C_OSX_CURRENT_VERSION_FLAG}")

SET(CMAKE_C_LINK_FLAGS "-Wl,-headerpad_max_install_names")
SET(CMAKE_CXX_LINK_FLAGS "-Wl,-headerpad_max_install_names")

IF(HAVE_FLAG_SEARCH_PATHS_FIRST)
  SET(CMAKE_C_LINK_FLAGS "-Wl,-search_paths_first ${CMAKE_C_LINK_FLAGS}")
  SET(CMAKE_CXX_LINK_FLAGS "-Wl,-search_paths_first ${CMAKE_CXX_LINK_FLAGS}")
ENDIF(HAVE_FLAG_SEARCH_PATHS_FIRST)

SET(CMAKE_PLATFORM_HAS_INSTALLNAME 1)
SET(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-dynamiclib -Wl,-headerpad_max_install_names")
SET(CMAKE_SHARED_MODULE_CREATE_C_FLAGS "-bundle -Wl,-headerpad_max_install_names")
SET(CMAKE_SHARED_MODULE_LOADER_C_FLAG "-Wl,-bundle_loader,")
SET(CMAKE_SHARED_MODULE_LOADER_CXX_FLAG "-Wl,-bundle_loader,")
SET(CMAKE_FIND_LIBRARY_SUFFIXES ".dylib" ".so" ".a")

# hack: if a new cmake (which uses CMAKE_INSTALL_NAME_TOOL) runs on an old build tree
# (where install_name_tool was hardcoded) and where CMAKE_INSTALL_NAME_TOOL isn't in the cache
# and still cmake didn't fail in CMakeFindBinUtils.cmake (because it isn't rerun)
# hardcode CMAKE_INSTALL_NAME_TOOL here to install_name_tool, so it behaves as it did before, Alex
IF(NOT DEFINED CMAKE_INSTALL_NAME_TOOL)
  FIND_PROGRAM(CMAKE_INSTALL_NAME_TOOL install_name_tool)
  MARK_AS_ADVANCED(CMAKE_INSTALL_NAME_TOOL)
ENDIF(NOT DEFINED CMAKE_INSTALL_NAME_TOOL)

# IOS_PLATFORM should be defined by toolchain file.
if (NOT DEFINED IOS_PLATFORM)
    MESSAGE(FATAL_ERROR "IOS_PLATFORM is not defined. Please use proper toolchain with IOS_PLATFORM definition.")
endif (NOT DEFINED IOS_PLATFORM)
set (IOS_PLATFORM ${IOS_PLATFORM} CACHE STRING "Type of iOS Platform")

# Check the platform selection and setup for developer root
if (${IOS_PLATFORM} STREQUAL "DEVICE")
	set (IOS_PLATFORM_LOCATION "iPhoneOS.platform")
	SET (CMAKE_SYSTEM_PROCESSOR "arm")
	# This causes the installers to properly locate the output libraries
	set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos")
elseif (${IOS_PLATFORM} STREQUAL "SIMULATOR")
	set (IOS_PLATFORM_LOCATION "iPhoneSimulator.platform")
	SET (CMAKE_SYSTEM_PROCESSOR "i386")
	# This causes the installers to properly locate the output libraries
	set (CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphonesimulator")
else (${IOS_PLATFORM} STREQUAL "DEVICE")
	message (FATAL_ERROR "Unsupported IOS_PLATFORM value selected. Please choose DEVICE or SIMULATOR")
endif (${IOS_PLATFORM} STREQUAL "DEVICE")

# Setup iOS developer location unless specified manually with CMAKE_IOS_DEVELOPER_ROOT
# Note Xcode 4.3 changed the installation location, choose the most recent one available
set (XCODE_POST_43_ROOT "/Applications/Xcode.app/Contents/Developer/Platforms/${IOS_PLATFORM_LOCATION}/Developer")
set (XCODE_PRE_43_ROOT "/Developer/Platforms/${IOS_PLATFORM_LOCATION}/Developer")
if (NOT DEFINED CMAKE_IOS_DEVELOPER_ROOT)
	if (EXISTS ${XCODE_POST_43_ROOT})
		set (CMAKE_IOS_DEVELOPER_ROOT ${XCODE_POST_43_ROOT})
	elseif(EXISTS ${XCODE_PRE_43_ROOT})
		set (CMAKE_IOS_DEVELOPER_ROOT ${XCODE_PRE_43_ROOT})
	else (EXISTS ${XCODE_POST_43_ROOT})
      # Use the xcode-select tool if it's available (Xcode >= 3.0 installations)
      FIND_PROGRAM(CMAKE_XCODE_SELECT xcode-select)
      MARK_AS_ADVANCED(CMAKE_XCODE_SELECT)
      IF(CMAKE_XCODE_SELECT)
        EXECUTE_PROCESS(COMMAND ${CMAKE_XCODE_SELECT} "-print-path"
          OUTPUT_VARIABLE CMAKE_IOS_DEVELOPER_ROOT
          OUTPUT_STRIP_TRAILING_WHITESPACE)
      ENDIF(CMAKE_XCODE_SELECT)
	endif (EXISTS ${XCODE_POST_43_ROOT})
endif (NOT DEFINED CMAKE_IOS_DEVELOPER_ROOT)
set (CMAKE_IOS_DEVELOPER_ROOT ${CMAKE_IOS_DEVELOPER_ROOT} CACHE PATH "Location of iOS Platform")

# Find and use the most recent iOS sdk unless specified manually with CMAKE_IOS_SDK_ROOT
if (NOT DEFINED CMAKE_IOS_SDK_ROOT)
	file (GLOB _CMAKE_IOS_SDKS "${CMAKE_IOS_DEVELOPER_ROOT}/SDKs/*")
	if (_CMAKE_IOS_SDKS) 
		list (SORT _CMAKE_IOS_SDKS)
		list (REVERSE _CMAKE_IOS_SDKS)
		list (GET _CMAKE_IOS_SDKS 0 CMAKE_IOS_SDK_ROOT)
	else (_CMAKE_IOS_SDKS)
		message (FATAL_ERROR "No iOS SDK's found in default seach path ${CMAKE_IOS_DEVELOPER_ROOT}. Manually set CMAKE_IOS_SDK_ROOT or install the iOS SDK.")
	endif (_CMAKE_IOS_SDKS)
	message (STATUS "Toolchain using default iOS SDK: ${CMAKE_IOS_SDK_ROOT}")
endif (NOT DEFINED CMAKE_IOS_SDK_ROOT)
set (CMAKE_IOS_SDK_ROOT ${CMAKE_IOS_SDK_ROOT} CACHE PATH "Location of the selected iOS SDK")

# Set the sysroot default to the most recent SDK
set (CMAKE_OSX_SYSROOT ${CMAKE_IOS_SDK_ROOT} CACHE PATH "Sysroot used for iOS support")

IF("${CMAKE_BACKWARDS_COMPATIBILITY}" MATCHES "^1\\.[0-6]$")
  SET(CMAKE_SHARED_MODULE_CREATE_C_FLAGS
    "${CMAKE_SHARED_MODULE_CREATE_C_FLAGS} -flat_namespace -undefined suppress")
ENDIF("${CMAKE_BACKWARDS_COMPATIBILITY}" MATCHES "^1\\.[0-6]$")

IF(NOT XCODE)
  # Enable shared library versioning.  This flag is not actually referenced
  # but the fact that the setting exists will cause the generators to support
  # soname computation.
  SET(CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "-install_name")
ENDIF(NOT XCODE)

# Xcode does not support -isystem yet.
IF(XCODE)
  SET(CMAKE_INCLUDE_SYSTEM_FLAG_C)
  SET(CMAKE_INCLUDE_SYSTEM_FLAG_CXX)
ENDIF(XCODE)

SET(CMAKE_C_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS -w)
SET(CMAKE_CXX_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS -w)
SET(CMAKE_C_CREATE_SHARED_LIBRARY
  "<CMAKE_C_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
SET(CMAKE_CXX_CREATE_SHARED_LIBRARY
  "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
SET(CMAKE_Fortran_CREATE_SHARED_LIBRARY
  "<CMAKE_Fortran_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")

SET(CMAKE_CXX_CREATE_SHARED_MODULE
      "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

SET(CMAKE_C_CREATE_SHARED_MODULE
      "<CMAKE_C_COMPILER>  <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

SET(CMAKE_Fortran_CREATE_SHARED_MODULE
      "<CMAKE_Fortran_COMPILER>  <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_Fortran_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

SET(CMAKE_C_CREATE_MACOSX_FRAMEWORK
      "<CMAKE_C_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
SET(CMAKE_CXX_CREATE_MACOSX_FRAMEWORK
      "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> -install_name <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")

# default to searching for frameworks first
SET(CMAKE_FIND_FRAMEWORK FIRST)

# set up the default search directories for frameworks
set (CMAKE_SYSTEM_FRAMEWORK_PATH
	${CMAKE_IOS_SDK_ROOT}/System/Library/Frameworks
	${CMAKE_IOS_SDK_ROOT}/System/Library/PrivateFrameworks
	${CMAKE_IOS_SDK_ROOT}/Developer/Library/Frameworks
)

# default to searching for application bundles first
SET(CMAKE_FIND_APPBUNDLE FIRST)
# set up the default search directories for application bundles
SET(_apps_paths)
FOREACH(_path
  "~/Applications"
  "/Applications"
  "${OSX_DEVELOPER_ROOT}/../Applications" # Xcode 4.3+
  "${OSX_DEVELOPER_ROOT}/Applications"    # pre-4.3
  )
  GET_FILENAME_COMPONENT(_apps "${_path}" ABSOLUTE)
  IF(EXISTS "${_apps}")
    LIST(APPEND _apps_paths "${_apps}")
  ENDIF()
ENDFOREACH()
LIST(REMOVE_DUPLICATES _apps_paths)
SET(CMAKE_SYSTEM_APPBUNDLE_PATH
  ${_apps_paths})
UNSET(_apps_paths)

#INCLUDE(Platform/UnixPaths)
LIST(APPEND CMAKE_SYSTEM_PREFIX_PATH
  /sw        # Fink
  /opt/local # MacPorts
  )

# This little macro lets you set any XCode specific property
macro (set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE)
	set_property (TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} ${XCODE_VALUE})
endmacro (set_xcode_property)
