FROM ros:indigo-ros-base
RUN apt-get update

ENV MY_USERNAME="slambot"

RUN set +x && \ 
    echo "Updating apt and installing packages" && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:tianon/gosu -y && \
    apt-get update && \
    apt-get install -y \
        g++ \
        gosu \
        terminator \
        ros-indigo-joint-state-publisher \
        ros-indigo-joint-state-controller \
        ros-indigo-robot-state-publisher \
        ros-indigo-hector-mapping \
        ros-indigo-hokuyo-node \
        ros-indigo-hector-slam && \
    \
    echo "Creating user account" && \
    useradd -ms /bin/bash $MY_USERNAME && \
    adduser $MY_USERNAME sudo && \
    echo $MY_USERNAME:root | chpasswd && \
    echo root:root | chpasswd && \
    \
    echo "Configuring rosdep" && \
    rm -f /etc/ros/rosdep/sources.list.d/20-default.list && \
    sudo rosdep init && \
    gosu $MY_USERNAME rosdep update && \
    \
    echo "Setting up catkin workspace" && \
    gosu $MY_USERNAME mkdir -p /home/$MY_USERNAME/project/catkin_ws && \
    cd /home/$MY_USERNAME/project/catkin_ws && \
    curl -sqL "https://raw.githubusercontent.com/carebare47/slambot/master/src.tar.gz" | \
    gosu $MY_USERNAME tar -C /home/$MY_USERNAME/project/catkin_ws -zx && \
    cd /home/$MY_USERNAME/project/catkin_ws/src && \
    rm CMakeLists.txt && \
    cd /home/$MY_USERNAME/project/catkin_ws/src && \    
    gosu $MY_USERNAME /bin/bash -c '. /opt/ros/indigo/setup.bash; \
        catkin_init_workspace' && \
    \
    echo "Installing all required ros dependencies" && \
    cd /home/$MY_USERNAME/project/catkin_ws && \
    /bin/bash -c 'source /opt/ros/indigo/setup.bash && rosdep install --from-paths src --ignore-src -r -y; \
        catkin_make' && \
    echo "sourcing environments" && \
    echo "source /home/slambot/project/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc 
                 /home/slambot/project/catkin_ws/devel

ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["terminator"]

