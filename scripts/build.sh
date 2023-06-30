#!/usr/bin/env bash
#
# Created on Mon Jun 12 2023 18:35:15
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

. "$(dirname "$0")"/variables.sh

docker buildx build \
	--platform linux/arm64 \
	--build-context home-folder-config="$(dirname "$0")"/../docker/build-context/home-folder \
	--build-context torch-tensorrt-config="$(dirname "$0")"/../docker/build-context/Torch-TensorRT \
	-t "$DOCKER_USER"/"$IMAGE_NAME":"$IMAGE_TAG" \
	- <"$(dirname "$0")"/../docker/"$IMAGE_TAG".dockerfile

echo "Base container built, now building Torch-TensorRT and OpenCV with CUDA support"

# start container
. "$(dirname "$0")"/run.sh

# clone Torch-TensorRT tag v1.0.0 for Xavier NX and build inside docker, must be performed outside of dockerfile since it uses nvidia runtime
docker exec "$CONTAINER_NAME" /bin/zsh -c "git clone --recursive https://github.com/pytorch/TensorRT.git $CONTAINER_HOME_FOLDER/Torch-TensorRT -b v1.0.0"
docker cp "$(dirname "$0")"/../docker/build-context/Torch-TensorRT/WORKSPACE "$CONTAINER_NAME":"$CONTAINER_HOME_FOLDER"/Torch-TensorRT/WORKSPACE

# build python3 package
docker exec "$CONTAINER_NAME" /bin/zsh -c "cd $CONTAINER_HOME_FOLDER/Torch-TensorRT/py && \
                                         python3 setup.py install --jetpack-version 4.6 --use-cxx11-abi"

# clean up
docker exec "$CONTAINER_NAME" /bin/zsh -c "cd $CONTAINER_HOME_FOLDER/Torch-TensorRT && \
                                         bazel clean --expunge"
docker exec "$CONTAINER_NAME" /bin/zsh -c "rm -rf $CONTAINER_HOME_FOLDER/Torch-TensorRT"

# clone opencv and opencv_contrib
docker exec "$CONTAINER_NAME" /bin/zsh -c "git clone --recursive https://github.com/opencv/opencv.git $CONTAINER_HOME_FOLDER/opencv -b 4.5.0"
docker exec "$CONTAINER_NAME" /bin/zsh -c "git clone --recursive https://github.com/opencv/opencv_contrib.git $CONTAINER_HOME_FOLDER/opencv_contrib -b 4.5.0"

# build and install
# Starting with v2.0 Ceres requires a fully C++14-compliant compiler. In versions <= 1.14, C++11 was an optional requirement. https://github.com/colmap/colmap/issues/905#issuecomment-731138700
docker exec "$CONTAINER_NAME" /bin/zsh -c "mkdir -p $CONTAINER_HOME_FOLDER/opencv/build && \
                                         cd $CONTAINER_HOME_FOLDER/opencv/build && \
                                         cmake \
                                         -D CMAKE_CXX_STANDARD=14 \
                                         -D WITH_CUDA=ON \
                                         -D WITH_CUDNN=ON \
                                         -D WITH_CUBLAS=ON \
                                         -D CUDA_ARCH_BIN=7.2 \
                                         -D CUDA_ARCH_PTX="" \
                                         -D CUDA_FAST_MATH=ON \
                                         -D OPENCV_DNN_CUDA=ON \
                                         -D ENABLE_NEON=ON \
                                         -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
                                         -D OPENCV_GENERATE_PKGCONFIG=ON \
                                         -D BUILD_opencv_python3=ON \
                                         -D OPENCV_ENABLE_NONFREE=ON \
                                         -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
                                         -D WITH_GSTREAMER=ON \
                                         -D WITH_V4L=ON \
                                         -D WITH_OPENGL=ON \
                                         -D BUILD_TESTS=OFF \
                                         -D BUILD_PERF_TESTS=OFF \
                                         -D BUILD_EXAMPLES=OFF \
                                         -D CMAKE_BUILD_TYPE=RELEASE \
                                         -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
                                         sudo make install -j${AVAILABLE_CORES}"

# bake library paths into environment
docker exec "$CONTAINER_NAME" /bin/zsh -c "echo OpenCV_DIR=/usr/local/lib/cmake/opencv4/ >> /etc/environment"
docker exec "$CONTAINER_NAME" /bin/zsh -c "source $CONTAINER_HOME_FOLDER/.zshrc && \
                                         sudo ldconfig"

# clean up
docker exec "$CONTAINER_NAME" /bin/zsh -c "rm -rf $CONTAINER_HOME_FOLDER/opencv && \
                                         rm -rf $CONTAINER_HOME_FOLDER/opencv_contrib"

# commit and finalize
docker commit "$CONTAINER_NAME" "$DOCKER_USER"/"$IMAGE_NAME":"$IMAGE_TAG"
docker rm -f "$CONTAINER_NAME"

echo "Docker image $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG successfully built"
