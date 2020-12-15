#!/bin/sh


#update Ubuntu
sudo apt upate && sudo apt upgrade


# To enable undervolting and overlocking of AMD GPU's, A "ppfeaturemask" Kernel Paramter Is Required
# You can use amdgpu.ppfeaturemask=0xffffffff but a higher value causes artifacts on some models under the RX 400/500 series)

### Install AMDGPU Driver + OpenCL + ROCm