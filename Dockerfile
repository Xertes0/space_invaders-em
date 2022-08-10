FROM debian:11 as build-base

RUN apt-get -y update && apt-get -y install ninja-build cmake python3-pip
RUN pip3 install conan

FROM build-base as build-cross-linux-mingw64

RUN apt-get -y install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 wget zip