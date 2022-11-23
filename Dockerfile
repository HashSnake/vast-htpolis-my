FROM nvidia/cuda:10.2-devel-ubuntu18.04

LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN apt update && apt install -y --no-install-recommends \
  ocl-icd-libopencl1 \
  clinfo pkg-config \
  zip \
  git \
  python3 \
  python3-psutil \
  python3-requests \
  pciutils \
  curl && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
################################ end nvidia opencl driver ################################

RUN git clone https://github.com/s3inlc/hashtopolis-agent-python.git && \
  cd hashtopolis-agent-python && \
  ./build.sh && \
  mv hashtopolis.zip ../ && \
  cd ../ && rm -R hashtopolis-agent-python
  
# Update & install packages for installing hashcat
RUN apt-get update && \
    apt-get install -y wget make clinfo build-essential git libcurl4-openssl-dev libssl-dev zlib1g-dev libcurl4-openssl-dev libssl-dev pciutils

# Fetch PCI IDs list to display proper GPU names
RUN update-pciids

CMD mkdir /root/htpclient

WORKDIR /root/htpclient

RUN git clone https://github.com/s3inlc/hashtopolis-agent-python.git && \
  cd hashtopolis-agent-python && \
  ./build.sh && \
  mv hashtopolis.zip ../ && \
  cd ../ && rm -R hashtopolis-agent-python

  
