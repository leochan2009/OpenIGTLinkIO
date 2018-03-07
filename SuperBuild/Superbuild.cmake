#---------------------------------------------------
SET(OpenIGTLinkIO_DEPENDENCIES)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/External_OpenIGTLink.cmake)
IF(NOT OpenIGTLink_FOUND)
  LIST(APPEND OpenIGTLinkIO_DEPENDENCIES OpenIGTLink)
ENDIF()

ExternalProject_Add( OpenIGTLinkIO
  DOWNLOAD_COMMAND ""
  INSTALL_COMMAND ""
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  BINARY_DIR "${CMAKE_BINARY_DIR}/OpenIGTLinkIO-build"
  #--Configure step-------------
  CMAKE_ARGS
      ${PLATFORM_SPECIFIC_ARGS}
      -DOpenIGTLinkIO_SUPERBUILD:BOOL=OFF
      -DOpenIGTLink_DIR:PATH=${OpenIGTLink_DIR}
      -DOpenIGTLinkIO_BINARY_INSTALL:STRING=${OpenIGTLinkIO_BINARY_INSTALL}
      -DOpenIGTLinkIO_ARCHIVE_INSTALL:STRING=${OpenIGTLinkIO_ARCHIVE_INSTALL}
      -DOpenIGTLinkIO_LIBRARY_INSTALL:STRING=${OpenIGTLinkIO_LIBRARY_INSTALL}
      -DOpenIGTLinkIO_CMAKE_INSTALL:STRING=${OpenIGTLinkIO_CMAKE_INSTALL}
      -DOpenIGTLinkIO_PACKAGE_INSTALL:STRING=${OpenIGTLinkIO_PACKAGE_INSTALL}
      -DOpenIGTLinkIO_INCLUDE_INSTALL:STRING=${OpenIGTLinkIO_INCLUDE_INSTALL}
      -DOpenIGTLinkIO_CMAKE_INSTALL:STRING=${OpenIGTLinkIO_CMAKE_INSTALL}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:STRING=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:STRING=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:STRING=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DIGTLIO_QT_VERSION:STRING=${IGTLIO_QT_VERSION}
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS} 
      -DBUILD_TESTING:BOOL=${BUILD_TESTING}
      -DIGTLIO_USE_EXAMPLES:BOOL=${IGTLIO_USE_EXAMPLES}  
      -DIGTLIO_USE_GUI:BOOL=${IGTLIO_USE_GUI}
      -DVTK_DIR:PATH=${VTK_DIR}
      -DQt5_DIR:PATH=${Qt5_DIR}
      -DQt4_DIR:PATH=${Qt4_DIR}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  #--Build step-----------------
  BUILD_ALWAYS 1
  #--Install step-----------------
  INSTALL_COMMAND ""
  DEPENDS ${OpenIGTLinkIO_DEPENDENCIES}
  )