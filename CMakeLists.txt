cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_VERBOSE_MAKEFILE on)

add_library(neuro_sys STATIC neuro_sys.cpp signal_buffer.cpp algorithm.cpp data_source.cpp
                                brainbit_source.cpp colibri_source.cpp screen_buffer.cpp
                                channel.cpp brainbit_reader.cpp colibri_reader.cpp
                                signal_reader.cpp eeg_state_calculator.cpp)

# copy out the lib binary... need to leave the static lib around to pass gradle check
set(distribution_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../..)
set_target_properties(neuro_sys
                      PROPERTIES
                      ARCHIVE_OUTPUT_DIRECTORY
                      "${distribution_DIR}/lib/${ANDROID_ABI}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti")

SET_TARGET_PROPERTIES(neuro_sys PROPERTIES PREFIX "")

# copy out lib header file...
add_custom_command(TARGET neuro_sys POST_BUILD
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/neuro_sys.h"
                   "${distribution_DIR}/include/neuro_sys.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/data_source.h"
                   "${distribution_DIR}/include/data_source.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/signal_buffer.h"
                   "${distribution_DIR}/include/signal_buffer.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/algorithm.h"
                   "${distribution_DIR}/include/algorithm.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/screen_buffer.h"
                   "${distribution_DIR}/include/screen_buffer.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/brainbit_source.h"
                   "${distribution_DIR}/include/brainbit_source.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/colibri_source.h"
                   "${distribution_DIR}/include/colibri_source.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/channel.h"
                   "${distribution_DIR}/include/channel.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/source_factory.h"
                   "${distribution_DIR}/include/source_factory.h"
                   COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_SOURCE_DIR}/signal_reader.h"
                   "${distribution_DIR}/include/signal_reader.h"

                   COMMENT "Copying neuro_sys to output directory")

