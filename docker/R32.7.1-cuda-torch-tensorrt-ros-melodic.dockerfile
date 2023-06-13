 # =============================================================================
 # Created on Mon Jun 12 2023 18:34:46
 # Author: Mukai (Tom Notch) Yu
 # Email: mukaiy@andrew.cmu.edu
 # Affiliation: Carnegie Mellon University, Robotics Institute, the AirLab
 #
 # Copyright Ⓒ 2023 Mukai (Tom Notch) Yu
 # =============================================================================

ARG ARCH=arm64
ARG HOME_FOLDER=/root
FROM --platform=linux/$ARCH nvcr.io/nvidia/l4t-ml:r32.7.1-py3
WORKDIR $HOME_FOLDER/

# Fix apt install stuck problem
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# update all obsolete packages to latest, install sudo, and cleanup
RUN apt update -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true && \
    apt full-upgrade -y && \
    apt install -y sudo && \
    apt autoremove -y && \
    apt autoclean -y

# fix local time problem
RUN apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# install python3 and pip3
RUN apt install -y python3-dev python3-pip python3-setuptools python3-wheel && \
    pip3 install --upgrade pip

# install python2 and pip2
RUN apt install -y python-dev python-pip python-setuptools python-wheel && \
    pip2 install --upgrade pip

# set default python version to 2
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2 2 && \
    update-alternatives --set python /usr/bin/python2

# set default pip version to pip2
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 2 && \
    update-alternatives --set pip /usr/bin/pip2

# install some goodies
RUN apt install -y lsb-release apt-utils software-properties-common zsh unzip ncdu git less screen tmux tree locate perl net-tools vim nano emacs htop curl wget build-essential cmake ffmpeg

# install jtop
RUN pip3 install -U jetson-stats

# copy all config files to home folder
COPY --from=home-folder-config ./. $HOME_FOLDER/

# install zsh, Oh-My-Zsh, and plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/romkatv/powerlevel10k \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/CraigCarey/gstreamer-tab \
    -a "[[ ! -f $HOME_FOLDER/.p10k.zsh ]] || source $HOME_FOLDER/.p10k.zsh" \
    -a "bindkey -M emacs '^[[3;5~' kill-word" \
    -a "bindkey '^H' backward-kill-word" \
    -a "autoload -U compinit && compinit"

# change default shell for the $USER in the image building process for extra environment safety
RUN chsh -s $(which zsh) $USER
SHELL [ "/bin/zsh", "-c" ]

#! Install ROS melodic workspace
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt update -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true && \
    apt install -y ros-melodic-ros-base && \
    echo "source /opt/ros/melodic/setup.zsh" >> $HOME_FOLDER/.zshrc && \
    echo "source /opt/ros/melodic/setup.bash" >> $HOME_FOLDER/.bashrc && \
    apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool && \
    rosdep init && \
    rosdep update

# Install catkin tools and rosmon
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' && \
    wget http://packages.ros.org/ros.key -O - | apt-key add - && \
    apt update -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true && \
    apt install -y python3-catkin-tools ros-melodic-rosmon

#! add L4T R32.7.* apt repo, t194 is the xavier nx specific repo
RUN apt install -y gnupg && \
    apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc && \
    apt install -y software-properties-common && \
    add-apt-repository 'deb https://repo.download.nvidia.com/jetson/common r32.7 main' && \
    add-apt-repository 'deb https://repo.download.nvidia.com/jetson/t194 r32.7 main' && \
    apt update

# Install VPI 1
RUN apt install -y nvidia-vpi libnvvpi1 vpi1-dev vpi1-samples python-vpi1 python3-vpi1

# Install Ceres
# RUN apt install -y git cmake libgoogle-glog-dev libgflags-dev libatlas-base-dev libeigen3-dev libsuitesparse-dev && \
#     wget -q http://ceres-solver.org/ceres-solver-2.0.0.tar.gz && \
#     tar -zxf ceres-solver-2.0.0.tar.gz && \
#     mkdir ceres-bin && \
#     cd ceres-bin && \
#     cmake ../ceres-solver-2.0.0 && \
#     make -j$(($(nproc)-1)) && \
#     make install
# RUN rm -rf $HOME_FOLDER/ceres-solver-2.0.0.tar.gz $HOME_FOLDER/ceres-solver-2.0.0 $HOME_FOLDER/ceres-bin

# # Install Torch-TensorRT
# RUN mkdir -p $HOME_FOLDER/Torch-TensorRT
# COPY --from=torch-tensorrt-config . $HOME_FOLDER/Torch-TensorRT/
# ENV BAZEL_VERSION=4.2.1
# RUN wget -q https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-linux-$ARCH -O /usr/bin/bazel && \
#     chmod a+x /usr/bin/bazel

# end of apt installs
RUN apt autoremove -y && \
    apt autoclean -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
# ENV NVIDIA_DRIVER_CAPABILITIES \
#     ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}

# Entrypoint command
ENTRYPOINT [ "/bin/zsh", "-c", "source $HOME_FOLDER/.zshrc; zsh" ]
