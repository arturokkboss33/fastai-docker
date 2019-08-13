# base image
FROM nvidia/cuda:9.0-base-ubuntu16.04
# mantainer
LABEL maintener="a.gomezchavez@jacobs-university.de"

# arguments passed when image is created
ARG user
ARG userid
ARG group
ARG groupid

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

# update system repos and libraries
RUN apt-get update -y && apt-get upgrade -y
# install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    iputils-ping \
    libjpeg-dev \
    libpng-dev \
    net-tools \
    python-qt4 \
    sudo \
    unzip \
    vim \
    zip && \
    rm -rf /var/lib/apt/lists/*

## set up users and groups
RUN addgroup --gid $groupid $group && \
    adduser --uid $userid --gid $groupid --gecos "" --shell /bin/bash $user && \
    echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$user && \
    chmod 0440 /etc/sudoers.d/$user

# define environment variables necessary for conda installation
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PYTHON_VERSION=3.6

# install miiniconda for python packages and worksapce management
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install conda-build
ENV PATH=$PATH:/opt/conda/bin/

# Create conda enviroment for fast-ai
COPY enviroment-local.yaml /enviroment-local.yaml
RUN conda env create -f enviroment-local.yaml

# Create main workspace directory -- to be mapped to directory in the host computer
WORKDIR /home/$user/workspace
RUN chown -R $user:$user /home/$user/workspace
RUN chmod a+rw /home/$user/workspace

# Create an alias to run jupyter notebooks easier
USER $user
RUN echo "alias showIP=' ifconfig eth0 | sed -n \"2s/[^:]*:\\\([^ ]*\\\).*/\\\\1/p\" '" >> /home/$user/.bashrc
RUN echo "alias runJupyterNotebook='jupyter notebook --allow-root --ip=\`showIP\` --port=8889'" >> /$HOME/.bashrc
RUN /bin/bash -c 'source $HOME/.bashrc'

#WORKDIR /notebooks
# Activate Source
#CMD source activate fastai
#CMD source ~/.bashrc

#RUN chmod -R a+w /notebooks
#WORKDIR /notebooks

# Clone course-v3
#RUN git clone https://github.com/fastai/course-v3.git

#COPY config.yml /root/.fastai/config.yml
#COPY run.sh /run.sh

#CMD ["/run.sh"]
