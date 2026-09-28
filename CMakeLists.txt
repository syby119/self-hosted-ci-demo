cmake_minimum_required(VERSION 3.20)

project(self_hosted_ci_demo VERSION 1.0.0 LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_EXTENSIONS OFF)

add_library(greeter src/greeting.cpp)
target_include_directories(greeter PUBLIC include)

add_executable(greeting_app src/main.cpp)
target_link_libraries(greeting_app PRIVATE greeter)

find_package(CUDAToolkit REQUIRED)
add_library(cuda_vector_add src/vector_add.cu)
target_include_directories(cuda_vector_add PUBLIC include)
target_link_libraries(cuda_vector_add PUBLIC CUDA::cudart)
set_target_properties(cuda_vector_add PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    CUDA_RESOLVE_DEVICE_SYMBOLS ON
)

include(CTest)
if(BUILD_TESTING)
  add_subdirectory(external/Catch2)

  add_executable(greeter_tests tests/greeting_tests.cpp)
  target_link_libraries(greeter_tests PRIVATE greeter Catch2::Catch2WithMain)
  add_test(NAME greeter_tests COMMAND greeter_tests)

  add_executable(cuda_vector_add_tests tests/vector_add_tests.cu)
  target_link_libraries(cuda_vector_add_tests
    PRIVATE cuda_vector_add Catch2::Catch2WithMain)
  add_test(NAME cuda_vector_add_tests COMMAND cuda_vector_add_tests)
  set_tests_properties(cuda_vector_add_tests PROPERTIES SKIP_RETURN_CODE 4)
endif()
