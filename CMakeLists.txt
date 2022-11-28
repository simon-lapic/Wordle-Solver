cmake_minimum_required(VERSION 3.1)
project(wordle-bot LANGUAGES CUDA CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "-Wall -O2 -Wextra -Wno-missing-field-initializers")

if(NOT DEFINED CMAKE_CUDA_STANDARD)
    set(CMAKE_CUDA_STANDARD 11)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

# add_executable(name src/name.ext)
# target_include_directories(name PRIVATE include)

add_executable(wordle_bot src/wordle_bot.cu)
target_include_directories(wordle_bot PRIVATE include)