#include "vector_add.hpp"

#include <catch2/catch_test_macros.hpp>

#include <cuda_runtime.h>

#include <cstdlib>
#include <vector>

TEST_CASE("CUDA vectorAdd adds ten integers") {
  int device_count = 0;
  const auto device_query = cudaGetDeviceCount(&device_count);
  if (device_query != cudaSuccess || device_count == 0) {
    if (std::getenv("REQUIRE_CUDA_DEVICE") != nullptr) {
      FAIL("A CUDA device is required for this test");
    }
    SKIP("No CUDA device is available on this runner");
  }

  const std::vector<int> lhs{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  const std::vector<int> rhs{10, 11, 12, 13, 14, 15, 16, 17, 18, 19};

  REQUIRE(cuda_demo::vector_add(lhs, rhs) ==
          std::vector<int>{10, 12, 14, 16, 18, 20, 22, 24, 26, 28});
}
