#!/bin/bash

# initialize global variables
containerName=fastai-v3
containerTag=1.0
GREEN='\033[1;32m'
BLUE='\e[34m'
NC='\033[0m' # no color
user=`id -u -n`
userid=`id -u`
group=`id -g -n`
groupid=`id -g`
myhostname=docker-fastai

if [ $1 = "help" ];then
    echo -e "${GREEN}>>> Possible commands:\n ${NC}"
    echo -e "${BLUE}build [Image Name][Tag] --- Build an image based on DockerFile in current dir, and\nuse the provided name and tag${NC}\n"
    echo -e "${BLUE}run [Container name][Image name] --- Create and start container${NC}\n"
    echo -e "${BLUE}git-fastai --- CLones the fastai/course-v3 into the workspace directory${NC}\n"
    echo -e "${BLUE}start [Container Name] --- Starts an already instantiated container${NC}\n"
    echo -e "${BLUE}stop [Container Name] --- Stops a running container${NC}\n"
    echo -e "${BLUE}console [Container Name] --- Gives terminal access (/bin/bash) access to a running container${NC}\n"
fi

if [ "$1" = "build" ]; then
    imageName=$2
    imageTag=$3
    echo -e "${GREEN}>>> Building ${imageName}:${imageTag} image ...${NC}"
    #docker build --build-arg user=$user --build-arg userid=$userid --build-arg group=$group \
    #--build-arg groupid=$groupid -t ${user}/${imageName}:${imageTag} .
    docker build --build-arg user=$user -t ${user}/${imageName}:${imageTag} .
fi

if [ "$1" = "run" ]; then    
    imageName=$2

    echo -e "${GREEN}>>> Creating container ${containerName} from image ${imageName}...${NC}"
    
    if [ -d /dev/dri ]; then

            DRI_ARGS=""
            for f in `ls /dev/dri/*`; do
                    DRI_ARGS="$DRI_ARGS --device=$f"
            done

            DRI_ARGS="$DRI_ARGS --privileged"
        fi

    # Run container with NVIDIA driver
    # Map port 8889 to be used by Jupyter notebooks
    # Map workspace folder to local computer
    docker run --runtime=nvidia -d -it \
    $DRI_ARGS \
    --name="${containerName}" \
    --hostname="${myhostname}" \
    --net=default \
    --publish 8889:8889 \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume=`pwd`/workspace:/home/$user/workspace:rw \
    ${imageName}
fi

if [ $1 = "start" ]; then
    echo -e "${GREEN}>>> Starting container ${containerName} ...${NC}"
    docker start $(docker ps -aqf "name=${containerName}")
fi

if [ $1 = "stop" ]; then
    echo -e "${GREEN}>>> Stopping container ${containerName} ...${NC}"
    docker stop $(docker ps -aqf "name=${containerName}")
fi

if [ $1 = "console" ]; then
    echo -e "${GREEN}>>> Entering console in container ${containerName} ...${NC}"
    docker exec -ti ${containerName} /bin/bash 
fi

if [ $1 = "git-fastai" ]; then
    echo -e "${GREEN}>>> Cloning fastai github repository ...${NC}"
    git clone -b master https://github.com/fastai/course-v3.git `pwd`/workspace/fastai/course-v3
fi
