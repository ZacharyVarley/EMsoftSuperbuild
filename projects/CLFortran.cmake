
#--------------------------------------------------------------------------------------------------
# Are we building CLFortran (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_CLFortran "Build CLFortran" ON)
if("${BUILD_CLFortran}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "CLFortran")
set(CLFortran_VERSION "0.0.1")
message(STATUS "Building: ${extProjectName} ${CLFortran_VERSION}: -DBUILD_CLFortran=${BUILD_CLFortran}" )


if(MSVC_IDE)
  set(CLFortran_INSTALL "${EMsoftOO_SDK}/${extProjectName}-${CLFortran_VERSION}")
elseif(WIN32)
  set(CLFortran_INSTALL "${EMsoftOO_SDK}/${extProjectName}-${CLFortran_VERSION}-${CMAKE_BUILD_TYPE}")
else()
  set(CLFortran_INSTALL "${EMsoftOO_SDK}/${extProjectName}-${CLFortran_VERSION}-${CMAKE_BUILD_TYPE}")
endif()

if( CMAKE_BUILD_TYPE MATCHES Debug )
  set(CLFortran_SUFFIX "_debug")
ENDif( CMAKE_BUILD_TYPE MATCHES Debug )

set_property(DIRECTORY PROPERTY EP_BASE ${EMsoftOO_SDK}/superbuild)

if(WIN32)
  set(CXX_FLAGS "/DWIN32 /D_WINDOWS /W3 /GR /EHsc /MP")
elseif(APPLE)
  set(CXX_FLAGS "-stdlib=libc++ -std=c++11")
else()
  if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CXX_FLAGS "-stdlib=libc++ -std=c++11")
  else()
    set(CXX_FLAGS "-std=c++11")
  endif()
endif()

if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "GNU" AND ${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 9.9)
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fallow-invalid-boz")
  message(STATUS "Adjusting CMAKE_Fortran_FLAGS for gfortran-10 compatibility: '${CMAKE_Fortran_FLAGS}'")
endif()

ExternalProject_Add(${extProjectName}
  #DOWNLOAD_NAME ${extProjectName}-${CLFortran_VERSION}.tar.gz
  #URL ${CLFortran_URL}
  GIT_REPOSITORY http://www.github.com/bluequartzsoftware/clfortran
  GIT_TAG "develop"
  TMP_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR ${EMsoftOO_SDK}/superbuild/${extProjectName}
  SOURCE_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/Source/${extProjectName}"
  BINARY_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${CLFortran_INSTALL}"

  CMAKE_ARGS
  #  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_Fortran_FLAGS:STRING=${CMAKE_Fortran_FLAGS}
    -DOpenCL_INCLUDE_DIR:PATH=${OpenCL_INCLUDE_DIR}
    -DOpenCL_LIBRARY:FILEPATH=${OpenCL_LIBRARY}

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

#--------------------------------------------------------------------------------------------------
# FORTRAN CL Library
# set(CLFortran_INSTALL "${EMsoftOO_SDK_ROOT}/CLFortran")
# set(CLFortran_DIR "${EMsoftOO_SDK_ROOT}/CLFortran/lib/CMake/CLFortran")
if(WIN32)
  FILE(APPEND ${EMsoftOO_SDK_FILE} "\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "# OpenCL Library and Include directories\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(OpenCL_LIBRARY \"${OpenCL_LIBRARY}\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(OpenCL_INCLUDE_DIR \"${OpenCL_INCLUDE_DIR}\")\n")

endif()

#-- Append this information to the EMsoftOO_SDK CMake file that helps other developers
#-- configure EMsoft for building
FILE(APPEND ${EMsoftOO_SDK_FILE} "\n")
FILE(APPEND ${EMsoftOO_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${EMsoftOO_SDK_FILE} "# CLFORTRAN Library Location\n")
if(APPLE)
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}-\${BUILD_TYPE}/lib/cmake/CLFortran\" CACHE PATH \"\")\n")
elseif(MSVC_IDE)
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}/lib/cmake/CLFortran\" CACHE PATH \"\")\n")
elseif(WIN32)
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}-\${BUILD_TYPE}/lib/cmake/CLFortran\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CLFortran_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${CLFortran_VERSION}-\${BUILD_TYPE}/lib/cmake/CLFortran\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${CLFortran_DIR})\n")
FILE(APPEND ${EMsoftOO_SDK_FILE} "Check3rdPartyDir(DIR \${CLFortran_DIR})\n")

