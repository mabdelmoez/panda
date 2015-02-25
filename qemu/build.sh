#!/bin/bash

set -e

# creates api code for plugins
python ../scripts/apigen.py

# creates pandalog code
sh ./pp.sh


# only 
LLVM_BIT=""
if [ -e ../llvm/Release ]
then
  echo "Found ../llvm -- LLVM SUPPORT IS ENABLED"
  LLVM_BIT="--enable-llvm --with-llvm=../llvm/Release"
else
  if llvm-config --version >/dev/null && [ $(llvm-config --version) == "3.3" ]
  then
    echo "Found system llvm -- LLVM SUPPORT IS ENABLED"
    LLVM_BIT="--enable-llvm --with-llvm=$(llvm-config --prefix)"
  else
    echo "No llvm dir found -- LLVM SUPPORT IS DISABLED"
  fi
fi  

./configure --target-list=x86_64-softmmu,i386-softmmu,arm-softmmu \
--cc=${CC:=gcc-4.7} \
--cxx=${CXX:=g++-4.7} \
--prefix=`pwd`/install \
--disable-pie \
--disable-xen \
--disable-libiscsi \
$LLVM_BIT \
--extra-cflags="-O2 -I/usr/local/include" \
--extra-cxxflags="-O2" \
--extra-ldflags="-L/usr/local/lib -L/usr/local/lib64 -L/usr/local/lib -lprotobuf-c -lprotobuf -lpthread" \
&& make -j $(nproc)