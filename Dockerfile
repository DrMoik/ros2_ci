# Use the official ROS2 Galactic desktop image as the base image
FROM osrf/ros:galactic-desktop

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        gazebo11 \
        ros-galactic-gazebo-ros-pkgs \
        ros-galactic-ros2-controllers \
        ros-galactic-joint-state-publisher \
        ros-galactic-robot-state-publisher \
        ros-galactic-robot-localization \
        ros-galactic-xacro \
        ros-galactic-tf2-ros \
        ros-galactic-tf2-tools \
        ros-galactic-robot-state-publisher \
        ros-galactic-ament-cmake \
    && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /ros2_ws

# Copy your ROS2 package(s) into the workspace
COPY ./tortoisebot/ /ros2_ws/src/tortoisebot/
COPY ./tortoisebot_waypoints/ /ros2_ws/src/tortoisebot_waypoints/
COPY ./custom_interfaces/ /ros2_ws/src/custom_interfaces/


# Build the workspace
RUN /bin/bash -c "source /opt/ros/galactic/setup.bash && colcon build --packages-select custom_interfaces && source /ros2_ws/install/setup.bash && colcon build --symlink-install"

# Create a startup script
RUN echo "#!/bin/bash\n\
source /opt/ros/galactic/setup.bash\n\
source /ros2_ws/install/setup.bash\n\
ros2 run tortoisebot_waypoints tortoisebot_action_server &\n\
ros2 launch tortoisebot_bringup bringup.launch.py use_sim_time:=True &\n\
exec tail -f /dev/null" > /start.sh && chmod +x /start.sh

# Specify the command to run the startup script
CMD ["/start.sh"]
