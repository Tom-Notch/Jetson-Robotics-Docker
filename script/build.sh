#!/usr/bin/env bash
#
# Created on Mon Jun 12 2023 18:35:15
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

source $(dirname "$0")/variables.sh

docker buildx build --platform linux/arm64 \
                    --build-context home-folder-config=$(dirname "$0")/../docker/build-context/home-folder \
                    --build-context torch-tensorrt-config=$(dirname "$0")/../docker/build-context/Torch-TensorRT \
                    -t $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG \
                    - < $(dirname "$0")/../docker/$IMAGE_TAG.dockerfile

echo "Base container built, now building Torch-TensorRT"

source $(dirname "$0")/run.sh

# clone Torch-TensorRT tag v1.0.0 for Xavier NX and build inside docker, must be performed on-boarrd
docker exec $CONTAINER_NAME /bin/zsh -c "git clone --recursive https://github.com/pytorch/TensorRT.git $CONTAINER_HOME_FODLER/Torch-TensorRT -b v1.0.0"
docker cp $(dirname "$0")/../docker/build-context/Torch-TensorRT/WORKSPACE $CONTAINER_NAME:$CONTAINER_HOME_FODLER/Torch-TensorRT/WORKSPACE

# build python3 package
docker exec $CONTAINER_NAME /bin/zsh -c "cd $CONTAINER_HOME_FODLER/Torch-TensorRT/py && \
                                         python3 setup.py install --jetpack-version 4.6 --use-cxx11-abi"
# build C++ library tarball
docker exec $CONTAINER_NAME /bin/zsh -c "cd $CONTAINER_HOME_FODLER/Torch-TensorRT && \
                                         bazel build //:libtorchtrt --platforms //toolchains:jetpack_4.6"

docker exec $CONTAINER_NAME /bin/zsh -c "mkdir -p $CONTAINER_HOME_FODLER/Torch-TensorRT-lib && \
                                         cp -r $CONTAINER_HOME_FODLER/Torch-TensorRT/bazel-bin/* $CONTAINER_HOME_FODLER/Torch-TensorRT-lib/ && \
                                         rm -rf $CONTAINER_HOME_FODLER/Torch-TensorRT"

docker commit $CONTAINER_NAME $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG
docker rm -f $CONTAINER_NAME

echo "Docker image $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG successfully built"
