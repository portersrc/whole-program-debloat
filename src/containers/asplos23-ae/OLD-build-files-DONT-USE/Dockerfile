FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y cmake

RUN mkdir -p /root/decker

RUN ln -s /mnt/wo/whole-program-debloat /root/decker
                
# ...
# Everything else was done manually and with docker commit
