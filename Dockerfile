FROM ros:indigo-ros-base
RUN apt-get update

ENV MY_USER="slambot"

#RUN set +x && \ 
#    apt-get update && \
#    apt-get install -y \
#        g++ \
#        ros-indigo-urdf \
#        ros-indigo-tf \
#        ros-indigo-diagnostic-updater && \ 
#    \
    #useradd -ms /bin/bash $MY_USER && \
    #adduser $MY_USER sudo && \
    #echo $MY_USER:root | chpasswd && \
    #echo root:root | chpasswd && \
	

RUN set +x && \ 
    mkdir -p /home/$MY_USER/project/catkin_ws && \
    \
    cd /home/$MY_USER/project/catkin_ws && \
    git clone https://github.com/carebare47/src.git && \
    cd /home/$MY_USER/project/catkin_ws/src && \
    rm CMakeLists.txt && \
    /bin/bash -c '. /opt/ros/indigo/setup.bash; \
        catkin_init_workspace; \
        cd /home/$MY_USER/project/catkin_ws; \
        rosdep install --from-paths src --ignore-src -r -y; \
        catkin_make' && \
    echo "source /home/slambot/project/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc 

RUN useradd $MY_USER
USER $MY_USER



