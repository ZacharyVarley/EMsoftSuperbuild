#--------------------------------------------------------------------------------------------------
# Are we building HDF5_plugins (ON by default)
#--------------------------------------------------------------------------------------------------
OPTION(BUILD_HDF5_plugins "Build HDF5 Plugins" ON)
if("${BUILD_HDF5_plugins}" STREQUAL "OFF")
  return()
endif()

set(extProjectName "hdf5pl")
if(WIN32)
  set(HDF5PL_VERSION "1.12.2")
  set(HDF5PL_GIT_TAG "release/1_12_2")
else()
  set(HDF5PL_VERSION "1.12.2")
  set(HDF5PL_GIT_TAG "release/1_12_2")
endif()

message(STATUS "Building: ${extProjectName} ${HDF5_VERSION}: -DBUILD_HDF5_plugins=${BUILD_HDF5_plugins}" )

set(HDF5PL_BUILD_SHARED_LIBS ON)
set(HDF5PL_INSTALL "${EMsoftOO_SDK}/${extProjectName}-${HDF5_VERSION}-${CMAKE_BUILD_TYPE}")
set(HDF5_ROOT "${HDF5_INSTALL}")
set(PLUGIN_SOURCE "${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}/Source/${extProjectName}")
set(TGZstring "TGZ")

# if( CMAKE_BUILD_TYPE MATCHES Debug )
#   set(HDF5PL_SUFFIX "_debug")
# ENDif( CMAKE_BUILD_TYPE MATCHES Debug )

set_property(DIRECTORY PROPERTY EP_BASE ${EMsoftOO_SDK}/superbuild)

if(WIN32)
  set(CXX_FLAGS "/DWIN32 /D_WINDOWS /W3 /GR /EHsc /MP")
  set(C_FLAGS "/DWIN32 /D_WINDOWS /W3 /MP")
  set(C_CXX_FLAGS -DCMAKE_CXX_FLAGS=${CXX_FLAGS} -DCMAKE_C_FLAGS=${C_FLAGS})
endif()

ExternalProject_Add(${extProjectName}
  # DOWNLOAD_NAME ${extProjectName}-${HDF5_VERSION}.tar.gz
  # URL ${HDF5_URL}
  # TMP_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/tmp/${CMAKE_BUILD_TYPE}"
  # STAMP_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/Stamp/${CMAKE_BUILD_TYPE}"
  # DOWNLOAD_DIR ${EMsoftOO_SDK}/superbuild/${extProjectName}
  # SOURCE_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/Source/${extProjectName}"
  # BINARY_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}/Build/${CMAKE_BUILD_TYPE}"
  # INSTALL_DIR "${HDF5_INSTALL}"

  GIT_REPOSITORY "https://github.com/HDFGroup/hdf5_plugins/"
  GIT_PROGRESS 1
  GIT_TAG ${HDF5PL_GIT_TAG}
  TMP_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}/tmp/${CMAKE_BUILD_TYPE}"
  STAMP_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}/Stamp/${CMAKE_BUILD_TYPE}"
  DOWNLOAD_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}"
  SOURCE_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}/Source/${extProjectName}"
  BINARY_DIR "${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}/Build/${CMAKE_BUILD_TYPE}"
  INSTALL_DIR "${HDF5PL_INSTALL}"

  CMAKE_ARGS
    -C ${EMsoftOO_SDK}/superbuild/${extProjectName}-${HDF5PL_VERSION}/Source/${extProjectName}/config/cmake/cacheinit.cmake
    -DBUILD_SHARED_LIBS:BOOL=${HDF5_BUILD_SHARED_LIBS}
    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${HDF5_ROOT}
    ${C_CXX_FLAGS}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_DEPLOYMENT_TARGET}
    -DCMAKE_OSX_SYSROOT=${OSX_SDK}
    -DCMAKE_CXX_STANDARD=11
    -DCMAKE_C_STANDARD=11
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DHDF5_BUILD_WITH_INSTALL_NAME=ON 
    -DHDF5_BUILD_CPP_LIB=ON 
    -DHDF5_BUILD_HL_LIB=ON
    -DHDF_PACKAGE_NAMESPACE=hdf5pl::
    -DHDF5_LINK_LIBS=${HDF5_ROOT}/lib
    -DHDF5_INCLUDE_DIR=${HDF5_ROOT}/include
    -DUSE_SHARED_LIBS:BOOL=ON 
    -DBUILD_SHARED_LIBS:BOOL=ON 
    -DTGZPATH:PATH=${PLUGIN_SOURCE}/libs 
    -DH5PL_ALLOW_EXTERNAL_SUPPORT:STRING=${TGZstring}
    -DHDF5_BUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF

  DEPENDS 
    hdf5

  LOG_DOWNLOAD 1
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_TEST 1
  LOG_INSTALL 1
)

#-- Append this information to the EMsoftOO_SDK CMake file that helps other developers
#-- configure EMsoftOO for building
FILE(APPEND ${EMsoftOO_SDK_FILE} "\n")
FILE(APPEND ${EMsoftOO_SDK_FILE} "#--------------------------------------------------------------------------------------------------\n")
FILE(APPEND ${EMsoftOO_SDK_FILE} "# HDF5_plugins Library Location\n")
if(APPLE)
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${HDF5PL_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${HDF5PL_VERSION}-\${BUILD_TYPE}/cmake\" CACHE PATH \"\")\n")
elseif(WIN32)
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${HDF5_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${HDF5_VERSION}-\${BUILD_TYPE}/cmake/hdf5\" CACHE PATH \"\")\n")
else()
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_INSTALL \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${HDF5_VERSION}-\${BUILD_TYPE}\" CACHE PATH \"\")\n")
  FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_DIR \"\${EMsoftOO_SDK_ROOT}/${extProjectName}-${HDF5_VERSION}-\${BUILD_TYPE}/cmake\" CACHE PATH \"\")\n")
endif()
FILE(APPEND ${EMsoftOO_SDK_FILE} "set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} \${HDF5PL_DIR})\n")
FILE(APPEND ${EMsoftOO_SDK_FILE} "set(HDF5PL_VERSION \"${HDF5PL_VERSION}\" CACHE STRING \"\")\n")
