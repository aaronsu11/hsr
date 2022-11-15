# ======== ROS/Colcon Dockerfile ========
# This sample Dockerfile will build a Docker image
# in any ROS workspace where all of the dependencies are managed by rosdep.
# 
# Adapt the file below to include your additional dependencies/configuration outside of rosdep.
# =======================================

# ==== Arguments ====
# Override the below arguments to match your application configuration.
# ===================

# ROS Distribution (ex: melodic, foxy, etc.)
ARG ROS_DISTRO=melodic
# Application Name (ex: helloworld)
ARG APP_NAME=robomaker_app
# Path to workspace directory on the host (ex: ./robot_ws)
ARG LOCAL_WS_DIR=workspace
# User to create and use (default: robomaker)
ARG USERNAME=robomaker
# The gazebo version to use if applicable (ex: gazebo-9, gazebo-11)
ARG GAZEBO_VERSION=gazebo-9
# Where to store the built application in the runtime image.
ARG IMAGE_WS_DIR=/home/$USERNAME/workspace

# ======== ROS Build Stages ========
# ${ROS_DISTRO}-ros-base
#   -> ros-robomaker-base 
#      -> ros-robomaker-application-base
#         -> ros-robomaker-build-stage
#         -> ros-robomaker-app-runtime-image
# ==================================

# ==== ROS Base Image ============
# If running in production, you may choose to build the ROS base image 
# from the source instruction-set to prevent impact from upstream changes.
# ARG UBUNTU_DISTRO=focal
# FROM public.ecr.aws/lts/ubuntu:${UBUNTU_DISTRO} as ros-base
# Instruction for each ROS release maintained by OSRF can be found here: https://github.com/osrf/docker_images
# ==================================

# ==== Build Stage with AWS RoboMaker Dependencies ====
# This stage creates the robomaker user and installs dependencies required to run applications in RoboMaker.
# ==================================

FROM public.ecr.aws/docker/library/ros:${ROS_DISTRO}-ros-base AS ros-robomaker-base
ARG USERNAME

# Install:
# - git (and git-lfs), for git operations (to e.g. push your work).
#   Also required for setting up your configured dotfiles in the workspace.
# - sudo, while not required, is recommended to be installed, since the
#   workspace user (`gitpod`) is non-root and won't be able to install
#   and use `sudo` to install any other tools in a live workspace.
RUN apt-get update && apt-get install -yq \
    git \
    git-lfs \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Create the gitpod user. UID must be 33333.
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod

USER gitpod

RUN apt-get update && apt-get install -y \
    lsb  \
    unzip \
    wget \
    curl \
    xterm \
    python3-colcon-common-extensions \
    devilspie \
    xfce4-terminal

RUN groupadd $USERNAME && \
    useradd -ms /bin/bash -g $USERNAME $USERNAME && \
    sh -c 'echo "$USERNAME ALL=(root) NOPASSWD:ALL" >> /etc/sudoers'

