#!/usr/bin/env bash
#
# Created on Mon Jun 12 2023 18:35:25
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

. "$(dirname "$0")"/variables.sh

xhost +local:root

if [ -n "$XAUTH" ]; then
	touch "$XAUTH"
	xauth_list="$(xauth nlist :0 | sed -e 's/^..../ffff/')"
	if [ -n "$xauth_list" ]; then
		echo "$xauth_list" | xauth -f "$XAUTH" nmerge -
	else
		touch "$XAUTH"
	fi
	chmod a+r "$XAUTH"
fi

if [ "$(docker ps -a -q -f name="$CONTAINER_NAME")" ]; then
	echo "A container with name $CONTAINER_NAME is running, force removing it"
	docker rm -f "$CONTAINER_NAME"
	echo "Done"
fi

docker run \
	--name "$CONTAINER_NAME" \
	--hostname "$(hostname)" \
	--privileged \
	--platform=linux/arm64 \
	--cpus "$AVAILABLE_CORES" \
	--gpus all \
	--runtime nvidia \
	--network host \
	--ipc host \
	--ulimit core=-1 \
	--group-add audio \
	--group-add video \
	-e DISPLAY="$DISPLAY" \
	-e QT_X11_NO_MITSHM=1 \
	-e XAUTHORITY="$XAUTH" \
	-v "$XAUTH":"$XAUTH" \
	-v /run/jtop.sock:/run/jtop.sock \
	-v /var/lib/systemd/coredump:/cores \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	-v /usr/local/cuda-10.2:/usr/local/cuda-10.2:ro \
	-v "$DATASET_PATH":"$CONTAINER_HOME_FOLDER"/data \
	-v /home/airlab/code/Multi-Spectral-Inertial-Odometry:"$CONTAINER_HOME_FOLDER"/Multi-Spectral-Inertial-Odometry \
	-w "$CONTAINER_HOME_FOLDER"/Multi-Spectral-Inertial-Odometry \
	--rm \
	-itd "$DOCKER_USER"/"$IMAGE_NAME":"$IMAGE_TAG"
