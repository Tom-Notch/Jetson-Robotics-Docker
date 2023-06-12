#!/bin/sh
#
# Created on Mon Jun 12 2023 18:35:25
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

DATASET_PATH="/home/tomnotch/bags" #! modify the following dataset path with yours

xhost +local:root
XAUTH=/tmp/.docker.xauth
AVAILABLE_CORES=$(($(nproc) - 1))
CONTAINER_NAME=jetson-robotics
CONTAINER_HOME_FOLER=/root
HOST_UID=$(id -u)
HOST_GID=$(id -g)

if [ ! -f $XAUTH ]
then
    touch $XAUTH
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

docker run --name $CONTAINER_NAME \
           --hostname $(hostname) \
           --privileged \
           --platform=linux/arm64 \
           --cpus $AVAILABLE_CORES \
           --gpus all \
           --runtime nvidia \
           --network host \
           --ipc host \
           --ulimit core=-1 \
           -e "DISPLAY=$DISPLAY"  \
           -e "QT_X11_NO_MITSHM=1" \
           -e "XAUTHORITY=$XAUTH" \
           -v /var/lib/systemd/coredump/:/cores \
           -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
           -v /run/jtop.sock:/run/jtop.sock \
           -v $XAUTH:$XAUTH \
           -v "$DATASET_PATH:$CONTAINER_HOME_FOLER/data" \
           --rm \
           -itd tomnotch/jetson-robotics:R32.7.1-cuda-torch-tensorrt-ros-melodic
