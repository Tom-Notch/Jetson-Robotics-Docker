#!/usr/bin/env bash
#
# Created on Tue Jun 13 2023 16:39:40
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

export XAUTH=/tmp/.docker.xauth
export AVAILABLE_CORES=$(($(nproc) - 1))

export DOCKER_USER=theairlab
export IMAGE_NAME=jetson-robotics
export IMAGE_TAG=Xavier-NX-R32.7.1-cuda-torch-tensorrt-ros-melodic

export CONTAINER_NAME="$IMAGE_NAME"
export CONTAINER_HOME_FOLDER=/root

HOST_UID=$(id -u)
HOST_GID=$(id -g)
export HOST_UID
export HOST_GID

export DATASET_PATH="/home/$USER/bags" #! modify the dataset path with yours
