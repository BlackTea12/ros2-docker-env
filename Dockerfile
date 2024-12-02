# Use the official ROS2 Humble base image
FROM ubuntu:22.04
FROM ros:humble
ARG ROS_DISTRO=humble

ENV USER_NAME=nav
ENV USER_PASS=bo

# Create a new user and set the password
RUN useradd -m $USER_NAME && \
  echo "$USER_NAME:$USER_PASS" | chpasswd

# Install sudo and create a custom sudoers file to require password authentication
RUN apt-get update && \
    apt-get install -y sudo && \
    echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD: ALL, !/bin/bash" > /etc/sudoers.d/custom_sudoers && \
    chmod 0440 /etc/sudoers.d/custom_sudoers

# Create a custom shell script to enforce password authentication for ls
RUN echo '#!/bin/bash\nsudo /bin/ls "$@"' > /usr/local/bin/ls && \
    chmod +x /usr/local/bin/ls

# Add /usr/local/bin to the beginning of PATH
ENV PATH="/usr/local/bin:${PATH}"

# Set the default user
USER $USER_NAME

RUN sudo apt update && sudo apt install -y software-properties-common
RUN sudo add-apt-repository universe

# Install dependencies (tools and libraries)
RUN sudo apt-get install -y \
  python3-pip \
  python3-colcon-common-extensions \
  build-essential \
  ros-${ROS_DISTRO}-teleop-twist-keyboard \
  git \
  vim 

# Install navigation 2 and delete cache
RUN sudo apt-get install -y \
  ros-${ROS_DISTRO}-ros-base \
  ros-${ROS_DISTRO}-navigation2 \
  ros-${ROS_DISTRO}-nav2-bringup \
  ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
  && sudo rm -rf /var/lib/apt/lists/*

# Create and set the workspace directory
WORKDIR /home/$USER_NAME

# Copy the ROS 2 workspace sources (replace this with your actual source path)
COPY ./ros2_ws /home/$USER_NAME/ros2_ws

# Source the ROS 2 Humble setup script and build the workspace
# RUN /bin/bash -c "source /opt/ros/humble/setup.bash && \
#     colcon build --symlink-install"
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc

RUN /bin/bash -c "source ~/.bashrc"

# Set the entry point to bash
ENTRYPOINT ["/bin/bash"]