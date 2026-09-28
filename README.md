# Self-hosted CI Demo

一个使用 CMake 管理的 C++20/CUDA 示例项目，包含 Catch2 单元测试，以及
Windows GitHub-hosted runner 和 Linux self-hosted GPU runner 的 CI 工作流。

## 内容

- `greeting_app`：简单的 C++ 示例程序，输出 `Hello, world!`。
- `cuda_vector_add`：CUDA `vectorAdd` 实现，对两个整数向量逐元素相加。
- Catch2 测试：验证 greeting，并使用 10 个整数验证 CUDA 向量加法。
- Catch2 以固定的 `external/Catch2` Git submodule（v3.7.1）管理。

## 前置条件

- CMake 3.20 或更高版本
- 支持 C++20 的 C++ 编译器
- CUDA Toolkit（项目使用 CUDA 语言并链接 CUDA Runtime）
- Git，用于初始化 Catch2 submodule

执行 CUDA 测试还需要可访问的 NVIDIA GPU 和正确安装的驱动程序。

## 构建与测试

克隆时递归获取 Catch2：

```bash
git clone --recurse-submodules https://github.com/syby119/self-hosted-ci-demo.git
cd self-hosted-ci-demo
```

若仓库已存在，初始化 submodule：

```bash
git submodule update --init --recursive
```

配置、构建并运行测试：

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

没有可访问 GPU 时，`cuda_vector_add_tests` 会显示为 skipped，其他测试仍会运行。
如需把缺少 GPU 视为测试失败，设置 `REQUIRE_CUDA_DEVICE`：

```bash
REQUIRE_CUDA_DEVICE=1 ctest --test-dir build --output-on-failure
```

## CI

工作流仅在 `main` 分支的 push 和面向 `main` 的 pull request 时运行。

- Windows：使用 `windows-latest`，安装 CUDA 12.6.3 后构建和测试；GitHub-hosted
  runner 没有 GPU 时，CUDA 测试会跳过。
- Linux：使用 `[self-hosted, linux]`，要求 runner 预装 Git、CMake、g++、CUDA Toolkit
  和可访问的 NVIDIA GPU。此工作流设置 `REQUIRE_CUDA_DEVICE=1`，因此 GPU 不可用时 CI
  会失败。

为避免共享工作目录冲突，建议为 GPU runner 配置专属标签，并确保同一标签只对应一个
runner 实例，或在工作流中设置 GitHub Actions concurrency 组。
