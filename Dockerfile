FROM osrf/ros:melodic-desktop-full
LABEL maintainer "zhenyi.z@outlook.com"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get update && apt-get install -y apt-utils build-essential psmisc vim-gtk

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Some packages copied from:
# https://gitlab.com/nvidia/opengl/blob/ubuntu16.04/base/Dockerfile

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    dialog \
    make \
    gcc \
    g++ \
    locales \
    wget \
    software-properties-common \
    sudo \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libxau6 \
    libxdmcp6 \
    libxcb1 \
    libxext6 \
    libx11-6 \
    tmux \
    xdg-utils \
    eog \
  && rm -rf /var/lib/apt/lists/*

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-catkin-tools \
  && rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
        ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
        ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

ENV CATKIN_WS=/home/teb_docker

RUN mkdir -p $CATKIN_WS/src
COPY . $CATKIN_WS/src/

RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    apt-get update && \
    rosdep install -y --from-paths $CATKIN_WS/src && \
    cd $CATKIN_WS && \
    catkin_make && \
    catkin_make install \
  && rm -rf /var/lib/apt/lists/*

# entry point
RUN set -e

RUN source /opt/ros/$ROS_DISTRO/setup.bash
RUN source $CATKIN_WS/devel/setup.bash

RUN exec "$@"

# make sure x11 is accessible https://nelkinda.com/blog/xeyes-in-docker/
RUN useradd -ms /bin/bash user
ENV DISPLAY :0
USER user
