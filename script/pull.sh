#!/usr/bin/env bash
#
# Created on Mon Jun 12 2023 18:35:31
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

source $(dirname "$0")/variables.sh

docker pull $DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG
