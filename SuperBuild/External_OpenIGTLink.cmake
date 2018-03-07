cmake_minimum_required(VERSION 2.8.2)
include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)
find_package(OpenIGTLink QUIET)
IF(OpenIGTLink_FOUND)
  # OpenIGTLink has been built already
  MESSAGE(STATUS "Using OpenIGTLink available at: ${OpenIGTLink_INCLUDE_DIR}")
ELSE()
  # OpenIGTLink has not been built yet, so download and build it as an external project
  SET(GIT_REPOSITORY "https://github.com/openigtlink/OpenIGTLink.git")
  SET(GIT_TAG "master")

  IF(MSVC)
    LIST(APPEND PLATFORM_SPECIFIC_ARGS -DCMAKE_CXX_MP_FLAG:BOOL=ON)
  ENDIF()
  
  MESSAGE(STATUS "Downloading OpenIGTLink ${GIT_TAG} from: ${GIT_REPOSITORY}")

  SET (OpenIGTLink_INCLUDE_DIR "${CMAKE_BINARY_DIR}/Deps/OpenIGTLink")
  SET (OpenIGTLink_LIBRARY_DIR "${CMAKE_BINARY_DIR}/Deps/OpenIGTLink-bin")
  SET (OpenIGTLink_DIR "${OpenIGTLink_LIBRARY_DIR}")
  ExternalProject_Add( OpenIGTLink
    PREFIX "${CMAKE_BINARY_DIR}/Deps/OpenIGTLink-prefix"
    SOURCE_DIR "${OpenIGTLink_INCLUDE_DIR}"
    BINARY_DIR "${OpenIGTLink_LIBRARY_DIR}"
    #--Download step--------------
    GIT_REPOSITORY "${GIT_REPOSITORY}"
    GIT_TAG ${GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${PLATFORM_SPECIFIC_ARGS}
      -DCMAKE_INSTALL_PREFIX:PATH="${CMAKE_BINARY_DIR}/Deps/OpenIGTLink-install"
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:STRING=${OpenIGTLink_LIBRARY_DIR}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:STRING=${OpenIGTLink_LIBRARY_DIR}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${OpenIGTLink_LIBRARY_DIR}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_SHARED_LIBS:BOOL=${OpenIGTLink_BUILD_SHARED_LIBS} 
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    #--Build step-----------------
    BUILD_ALWAYS 1
    INSTALL_COMMAND ""
    )
ENDIF()