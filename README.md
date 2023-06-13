# Jetson Robotics Docker

This repo contains dockerfile and script to build/pull, run docker images for cross-compilation on a powerful desktop/laptop, or directly run on Jetson hardware platforms out-of-the-box.

## Usage

* To build:
  
  ```Shell
  ./script/build.sh
  ```

* To pull:

  ```Shell
  ./script/pull.sh
  ```

* To run:

  ```Shell
  ./script/run.sh
  ```

## Docker

* This repository uses `docker buildx` to (cross-)compile docker image, check your available target architecture by executing `docker buildx ls` in a shell terminal
  * If it doesn't support the desired architecture, install emulator from [binfmt](https://github.com/tonistiigi/binfmt) by executing `docker run --privileged --rm tonistiigi/binfmt --install all` in a shell terminal
  * With docker image cross-compile enabled, **you can build the non-GPU part of this docker image on your x86_64 desktop/laptop**
* The base is from [Nvidia NGC L4T ML container images](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/l4t-ml)
  * Supports JetPack > 4.4, i.e. L4T > R32.4.2
  * Contains PyTorch, TensorFlow, onnx, CUDA, cuDNN, etc. Check the website Overview for more info on distribution-specific libraries.
* The dockerfile in this repo further extends the libraries by installing the following libraries for robotics applications:
  * [Torch-TensorRT](https://github.com/pytorch/TensorRT) (depends on cuDNN, CUDA, and CUDA Arch BIN version)
  * [VPI](https://docs.nvidia.com/vpi/)
  * [Ceres Solver](http://ceres-solver.org/)
  * [oh-my-zsh](https://ohmyz.sh/) (for devel purpose)
* For more hardware specific installs like VPI, please **login to your Jetson hardware, and then**:
  * Execute `sudo apt update` or `cat /etc/apt/sources.list.d/nvidia-l4t-apt-source.list` in a shell terminal, find the sources contain **repo.download.nvidia.com**, and modify the lines in the dockerfile under [docker folder](./docker) that adds the **apt repo**
    * Check [Jetson apt repo](https://repo.download.nvidia.com/jetson/) for more details
      * Basically, the 1<sup>st</sup> level is the Jetpack version, and the 2<sup>nd</sup> level contains hardware-specific distributions and a `common` for all hardware. e.g., for Xavier NX installed with L4T R32.7.3, it'll go to `Jetpack 4.6.x`, then `t194`, which contains `*nvidia-jetpack*.deb` (the ensemble package of [JetPack SDK](https://developer.nvidia.com/embedded/jetpack)); for `x86_64` development on desktop/laptop platforms, it'll go to `Jetpack 4.6.x`, then `x86_64/bionic` or `x86_64/xenial` depending on your Ubuntu distribution
  * Install [jtop](https://github.com/rbonghi/jetson_stats) if you haven't already, then execute `jtop` in a shell terminal, click `info` tab on the bottom to check versions of all the installed libraries and supported hardware bin, important ones include:
    * CUDA and CUDA Arch BIN
    * L4T and Jetpack
    * cuDNN
    * TensorRT
    * VPI
    * OpenCV

## Known Issue

* If you encountered the following error:

  ```Shell
  unknown flag: --platform
  ```

  Then you need to install `buildx` plugin by

  ```Shell
  sudo apt install docker-buildx-plugin
  ```

  If you do not see `docker-buildx-plugin` available or it doesn't solve the previous problem, please follow [the official guide](https://docs.docker.com/engine/install/ubuntu/) to install the complete `docker engine`
* Building Torch-TensorRT from source
  * On Jetson platforms, NVIDIA hosts [pre-built Pytorch wheel files](https://forums.developer.nvidia.com/t/pytorch-for-jetson-version-1-10-now-available/72048). These wheel files are built with CXX11 ABI. You'll also notice that there're `Pre CXX11 ABI` and `CXX11 ABI` versions of libtorch on [the official download website](https://pytorch.org/get-started/locally/) of PyTorch
  * What's Pre CXX11 ABI and CXX11 ABI? You can ask ChatGPT, and here's its answer:

    ```txt
    C++ Application Binary Interface (ABI) is the specification to which executable code adheres in order to facilitate correct interaction between different executable components. This includes conventions for name mangling, exception handling, calling conventions, and the layout of object code and system libraries.

    The term "Pre-CXX ABI" likely refers to a version of the C++ ABI that was in use before a specific change was introduced. An ABI can change over time as new language features are added, compilers improve, or for other reasons. When such changes occur, binary code compiled with a newer version of the compiler may not be compatible with code compiled with an older version, due to different expectations about how things like name mangling or exception handling work.

    One notable ABI break in C++ occurred with the release of GCC 5.1. This release changed the ABI in a way that was not backwards-compatible, primarily to improve the implementation of C++11's std::string and std::list types. The ABI used by versions of GCC prior to this change is often referred to as the "old" or "pre-CXX11" ABI. Code compiled with the new ABI cannot be safely linked with code compiled with the old ABI.
    ```

    This basically means that `Pre CXX11 ABI` and `CXX11 ABI` are two distinct versions of a library, and cannot be used in a mixture. Since Torch-TensorRT depends on PyTorch, whether to use `Pre CXX11 ABI` or `CXX11 ABI` also depends on how PyTorch is built. To check this, you can directly consult torch in python3:

    ```Python
    python3
    Python 3.6.9 (default, Mar 10 2023, 16:46:00)
    [GCC 8.4.0] on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import torch
    >>> torch._C._GLIBCXX_USE_CXX11_ABI
    True
    ```

    This shows that the installed PyTorch is compiled with `CXX11 ABI`, which means that the libtorch under the hood is also compiled with `CXX11 ABI`
