# Jetson Robotics Docker

This repo contains dockerfile and script to build/pull, run docker images for cross-compilation on a powerful desktop/laptop, or directly run on Jetson hardware platforms out-of-the-box.

## Docker

* This repository uses `docker buildx` to (cross-)compile docker image, check your available target architecture by executing `docker buildx ls` in a shell terminal
  * If it doesn't support the desired architecture, install emulator from [binfmt](https://github.com/tonistiigi/binfmt) by executing `docker run --privileged --rm tonistiigi/binfmt --install all` in a shell terminal
* The base is from [Nvidia NGC L4T ML container images](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/l4t-ml)
  * Supports JetPack > 4.4, i.e. L4T > R32.4.2
  * Contains PyTorch, TensorFlow, onnx, CUDA, cuDNN, etc. Check the website Overview for more info on distribution-specific libraries.
* The dockerfile in this repo further extends the libraries by installing the following libraries for robotics applications:
  * [Torch-TensorRT](https://github.com/pytorch/TensorRT) (depends on cuDNN, CUDA, and CUDA Arch BIN version)
  * [VPI](https://docs.nvidia.com/vpi/)
  * [Ceres Solver](http://ceres-solver.org/)
  * [oh-my-zsh](https://ohmyz.sh/) (for devel purpose)
* For more hardware specific installs, please login to your Jetson hardware, and then:
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
