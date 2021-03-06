if(${PLATFORM} MATCHES "Arduino")
  set(CMAKE_TOOLCHAIN_FILE ${CMAKE_ROOT}/Modules/ArduinoToolchain.cmake) # Arduino Toolchain
  set(ARDUINO_AVRDUDE_PROGRAM avrdude.py) # override arvdude for upload to micro and leonardo
endif(${PLATFORM} MATCHES "Arduino")

cmake_minimum_required (VERSION 2.8.5)
cmake_policy(VERSION 2.8.5)
project(estimation)

# flags for debug version: "-DCMAKE_BUILD_TYPE=Debug/Release"
if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
  message("-- Configuring ${PROJECT_NAME} for Debug")
  add_definitions(-D__DEBUG__)
  set(CMAKE_CC_FLAGS "${CMAKE_CC_CFLAGS} -Wall -Werror -g -O0 -fPIC")
else(${CMAKE_BUILD_TYPE} MATCHES "Debug")
  set(CMAKE_CC_FLAGS "${CMAKE_CC_CFLAGS} -Wall -Werror -O2 -fPIC")
endif(${CMAKE_BUILD_TYPE} MATCHES "Debug")

# define dependencies path
set(BLOB_TYPE_DIR ../types)
set(BLOB_6DOF_DIR ../6dof)

# add include directories (-I)
include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${BLOB_TYPE_DIR}/include)
include_directories(${BLOB_6DOF_DIR}/include)

# sources
set(LIB_SRC src/ukf.cpp src/cf.cpp)

# output files path: libs at /lib and executables at bin/
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)

# build the shared and static libraries
if(${PLATFORM} MATCHES "Arduino")
  generate_arduino_library (blob_estimation
    SRCS ${LIB_SRC}
    BOARD leonardo)
else(${PLATFORM} MATCHES "Arduino")
  add_library(blob_estimation SHARED ${LIB_SRC})
  add_library(blob_estimation_static STATIC ${LIB_SRC})
  target_link_libraries(blob_estimation) # link libraries

endif(${PLATFORM} MATCHES "Arduino")

# compile tests and dependencies only if standalone compilation
string(FIND ${CMAKE_BINARY_DIR} ${PROJECT_NAME} IS_PROJECT) 
if("${IS_PROJECT}" GREATER -1)
  add_subdirectory(test) # compile tests
  add_subdirectory(${BLOB_6DOF_DIR} "${CMAKE_CURRENT_BINARY_DIR}/6dof") # compile 6dof library
endif("${IS_PROJECT}" GREATER -1)
