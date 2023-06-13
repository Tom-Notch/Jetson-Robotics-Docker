#!/usr/bin/env bash
#
# Created on Tue Jun 13 2023 17:09:00
# Author: Mukai (Tom Notch) Yu
# Email: mukaiy@andrew.cmu.edu
# Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
#
# Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
#

echo "Removing all containers"
docker rm -f $(docker ps -aq)
echo "Done"
