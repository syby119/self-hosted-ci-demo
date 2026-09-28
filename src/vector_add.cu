#include "vector_add.hpp"

#include <cuda_runtime.h>

#include <cstddef>
#include <stdexcept>
#include <string>

namespace {

__global__ void vector_add_kernel(const int* lhs, const int* rhs, int* result,
                                  std::size_t count) {
  const auto index = static_cast<std::size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
  if (index < count) {
    result[index] = lhs[index] + rhs[index];
  }
}

void check_cuda(cudaError_t error, const char* operation) {
  if (error != cudaSuccess) {
    throw std::runtime_error(std::string(operation) + ": " + cudaGetErrorString(error));
  }
}

}  // namespace

namespace cuda_demo {

std::vector<int> vector_add(const std::vector<int>& lhs,
                            const std::vector<int>& rhs) {
  if (lhs.size() != rhs.size()) {
    throw std::invalid_argument("vector sizes must match");
  }

  const auto count = lhs.size();
  std::vector<int> result(count);
  if (count == 0) {
    return result;
  }

  int* device_lhs = nullptr;
  int* device_rhs = nullptr;
  int* device_result = nullptr;
  const auto bytes = count * sizeof(int);

  try {
    check_cuda(cudaMalloc(&device_lhs, bytes), "cudaMalloc lhs");
    check_cuda(cudaMalloc(&device_rhs, bytes), "cudaMalloc rhs");
    check_cuda(cudaMalloc(&device_result, bytes), "cudaMalloc result");
    check_cuda(cudaMemcpy(device_lhs, lhs.data(), bytes, cudaMemcpyHostToDevice),
               "copy lhs to device");
    check_cuda(cudaMemcpy(device_rhs, rhs.data(), bytes, cudaMemcpyHostToDevice),
               "copy rhs to device");

    constexpr int threads_per_block = 256;
    const auto blocks = static_cast<unsigned int>(
        (count + threads_per_block - 1) / threads_per_block);
    vector_add_kernel<<<blocks, threads_per_block>>>(device_lhs, device_rhs,
                                                       device_result, count);
    check_cuda(cudaGetLastError(), "launch vector_add_kernel");
    check_cuda(cudaDeviceSynchronize(), "synchronize vector_add_kernel");
    check_cuda(cudaMemcpy(result.data(), device_result, bytes, cudaMemcpyDeviceToHost),
               "copy result to host");
  } catch (...) {
    cudaFree(device_lhs);
    cudaFree(device_rhs);
    cudaFree(device_result);
    throw;
  }

  cudaFree(device_lhs);
  cudaFree(device_rhs);
  cudaFree(device_result);
  return result;
}

}  // namespace cuda_demo
