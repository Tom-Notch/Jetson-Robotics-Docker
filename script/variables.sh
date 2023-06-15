#!/usr/bin/env bash
#
# Created on Tue Jun 13 2023 16:39:40
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

XAUTH=/tmp/.docker.xauth
AVAILABLE_CORES=$(($(nproc) - 1))

DOCKER_USER=tomnotch
IMAGE_NAME=jetson-robotics
IMAGE_TAG=Xavier-NX-R32.7.1-cuda-torch-tensorrt-ros-melodic

CONTAINER_NAME=$IMAGE_NAME
CONTAINER_HOME_FOLDER=/root

HOST_UID=$(id -u)
HOST_GID=$(id -g)

DATASET_PATH="/home/airlab/bags" #! modify the dataset path with yours
