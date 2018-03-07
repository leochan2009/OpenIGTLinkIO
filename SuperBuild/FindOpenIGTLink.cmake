# - The OpenIGTLink_INCLUDE_DIR library
# Once done this will define
#
#  OpenIGTLink_ROOT - A list of search hints
#
#  OpenIGTLink_INCLUDE_DIR_FOUND - found OpenIGTLink
#  OpenIGTLink_INCLUDE_DIR_INCLUDE_DIR - the OpenIGTLink include directory
#  OpenIGTLink_LIBRARY_DIR - OpenIGTLink_INCLUDE_DIR library directory

#if (UNIX AND NOT ANDROID)
#  find_package(PkgConfig QUIET)
#  pkg_check_modules(PC_OpenIGTLink QUIET OpenIGTLink)
#endif()

SET( OpenIGTLink_PATH_HINTS 
    ${OpenIGTLink_ROOT} 
    ${OpenIGTLink_INCLUDE_DIR}
    )
unset(OpenIGTLink_INCLUDE_DIR CACHE)
find_path(OpenIGTLink_INCLUDE_DIR NAMES OpenIGTLink.h 
  HINTS ${OpenIGTLink_PATH_HINTS} 
  PATH_SUFFIXES source
  )
set(OpenIGTLink_DIR "" CACHE PATH "")
SET( OpenIGTLink_PATH_HINTS 
    ${OpenIGTLink_ROOT} 
    ${OpenIGTLink_DIR}
    )

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenIGTLink REQUIRED_VARS OpenIGTLink_DIR OpenIGTLink_INCLUDE_DIR)

#mark_as_advanced(OpenIGTLink_INCLUDE_DIR OpenIGTLink_LIBRARY_DIR)
