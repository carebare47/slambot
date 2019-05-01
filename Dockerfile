FROM ros:indigo-ros-base
RUN apt-get update

ENV MY_USER="slambot"

RUN set +x && \ 
    apt-get update && \
    apt-get install -y \
        g++ \
         ros-indigo-hector-mapping \
         ros-indigo-hector-slam && \
#        ros-indigo-urdf \
#        ros-indigo-tf \
#        ros-indigo-diagnostic-updater
	    useradd -ms /bin/bash $MY_USER && \
    adduser $MY_USER sudo && \
    rm -f /etc/ros/rosdep/sources.list.d/20-default.list && \
#    /bin/bash -c '. rosdep init' && \
    echo $MY_USER:root | chpasswd && \
    echo root:root | chpasswd


RUN sudo rosdep init
USER $MY_USER	
RUN rosdep update


RUN set +x && \ 
#    rosdep update && \
    mkdir -p /home/$MY_USER/project/catkin_ws && \
    \
    cd /home/$MY_USER/project/catkin_ws && \
    curl -sqL "https://raw.githubusercontent.com/carebare47/slambot/master/src.tar.gz" | \
    tar -C /home/$MY_USER/project/catkin_ws -zx && \
    #git clone https://github.com/carebare47/src.git && \
    cd /home/$MY_USER/project/catkin_ws/src && \
    rm CMakeLists.txt && \
    cd /home/$MY_USER/project/catkin_ws/src && \    
    /bin/bash -c '. /opt/ros/indigo/setup.bash; \
        catkin_init_workspace'

USER root

RUN set +x && \ 
    cd /home/$MY_USER/project/catkin_ws && \
    /bin/bash -c 'source /opt/ros/indigo/setup.bash && rosdep install --from-paths src --ignore-src -r -y; \
        catkin_make' && \
    echo "source /home/slambot/project/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc 

USER $MY_USER
#RUN useradd $MY_USER




