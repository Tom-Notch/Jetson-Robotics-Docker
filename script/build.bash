#!/bin/sh
#
# Created on Mon Jun 12 2023 18:35:15
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

TAG=R32.7.1-cuda-torch-tensorrt-ros-melodic

docker buildx build --platform linux/arm64 \
                    --build-context home-folder-config=$(dirname "$0")/../home-folder-config \
                    --build-context torch-tensorrt-config=$(dirname "$0")/../Torch-TensorRT \
                    -t $USER/jetson-robotics:$TAG \
                    - < $(dirname "$0")/../docker/$TAG.dockerfile
