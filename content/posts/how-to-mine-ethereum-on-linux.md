---
title: "How to mine Ethereum on Ubuntu  20.04. LTS"
date: "2020-11-20"
draft: false
author: "Albert"
cover: "/img/mining.png"
description: "A working installation of Ubuntu 20.04 LTS is required. An Advanced user can install the server version while a neophyte can install the desktop version. The installation process for the Ubuntu Server Edition is slightly different from the Desktop Edition"

---



# Prerequisites

A working installation of [Ubuntu 20.04 LTS](https://releases.ubuntu.com/20.04/) is required. An Advanced user can install the server version  while a neophyte can install the desktop version. The installation process for  Ubuntu Server Edition is slightly different from the Desktop Edition;  Ubuntu Server doesn't have a GUI by default. The guide assumes you have root privileges to the system.
This guide also assumes you already have the necessary hardware to mine Ethereum using the  ETHASH algorithm. 

### disclaimer 

This guide was tested using 5 AMD RX580 gpu's with 8GB GDDR5 memory (samsung).
{{< code language="bash" title="update ubuntu" id="1" collapse="" isCollapsed="false" >}}
#!/bin/sh
Sudo apt install & sudo apt upgrade
sudo apt install nano
{{< /code >}}

## Enable  kernel boot option that allows control of GPU power states 

To enable undervolting and overclocking of AMD GPU's, A "ppfeaturemask" Kernel Parameter Is Required. This is often accomplished via a system's
  boot loader (E.g. GRUB). If manually loading the driver, pass ppfeaturemask=<mask> as a modprobe parameter.

* Replace ```GRUB_CMDLINE_LINUX_DEFAULT``` and ```GRUB_CMDLINE_LINUX``` lines with the parameters below:

{{< code language="sh" title="edit Grub config" id="2" collapse="" isCollapsed="false" >}}
sudo nano /etc/default/grub
{{< /code >}}

```sh
GRUB_CMDLINE_LINUX_DEFAULT="amdgpu.ppfeaturemask=0xfffd7fff"
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"

```

  You can also use ```amdgpu.ppfeaturemask=0xffffffff``` but a higher value causes artifacts on some models under the RX 400/500 series.

{{< code language="sh" title="update Grub config" id="3" collapse="" isCollapsed="false" >}}
sudo update-grub && sudo update-grub2 && sudo update-initramfs -u -k all

{{< /code >}}

## Install AMDGPU Driver + OpenCL 

The commands below simplify the installation of the AMDGPU graphics and compute stack by encapsulating the distribution specific package installation logic by using command line options that allow specifying the Variant of the AMDGPU stack to be installed. For GPU mining, we will be using the Pro variant only.  

```Download the driver```




```sh
wget https://drivers.amd.com/drivers/linux/amdgpu-pro-20.40-1147286-ubuntu-20.04.tar.xz --referer https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-40
```

{{< code language="sh" title="```Extract the tallbar```" id="" collapse="" isCollapsed="false" >}}
 tar -Jxvf amdgpu-pro-20.40-1147286-ubuntu-20.04.tar.xz
{{< /code >}}

{{< code language="sh" title="```Change Directory to driver folder```" id="" collapse="" isCollapsed="false" >}}
cd amdgpu-pro-20.40-1147286-ubuntu-20.04.tar.xz
{{< /code >}}

{{< code language="sh" title="```install  Pro drivers```" id="" collapse="" isCollapsed="false" >}}
./amdgpu-pro-install -y --opencl=pal,legacy,rocm --headless
{{< /code >}}

The parameters ``` --opencl=pal,legacy,rocm```  specify the OpenCl implementation to install.  OpenCL is an optional component of the Pro variant and is installed only if it is specifically requested.
| Option       | Description  |
| :-------| :----------: | 
|```Pal``` | Provides support for Vega 10 and newer hardware.| 
|```Legacy```| Provides support for hardware older than Vega 10.| 
|```rocm```|Optional component.| 


The parameter ```--headless```  specifies to install only the OpenCL portion of the Pro variant (omitting the OpenGL portion). This  is desirable because the GPU's will be operating in headless compute mode.

```optional```

```s
sudo apt install amdgpu-dkms libdrm-amdgpu-amdgpu1 libdrm2-amdgpu opencl-amdgpu-pro opencl-amdgpu-pro-dev
```

### Add yourself to the Video and Render group

 To access the GPU's, you must be a user in the video and render groups.           
  **Note:** render group is required only for Ubuntu v20.04. 

{{< code language="sh" title="```add user to vid and render group```" id="" collapse="" isCollapsed="false" >}}
sudo usermod -a -G video $LOGNAME
sudo usermod -a -G render $LOGNAME
{{< /code >}}

By default, you must add any future users to the video and render groups. To add future users to the video and render groups, run the following optional command:
{{< code language="sh" title="```add future user to vid and render group```" id="" collapse="" isCollapsed="false" >}}
echo 'ADD_EXTRA_GROUPS=1' | sudo tee -a /etc/adduser.conf
echo 'EXTRA_GROUPS=video' | sudo tee -a /etc/adduser.conf
echo 'EXTRA_GROUPS=render' | sudo tee -a /etc/adduser.conf
{{< /code >}}

## Add amdgpu-pro PATH to new line

{{< code language="sh" title="```edit ~profile```" id="" collapse="" isCollapsed="false" >}}
Export PATH="/opt/amdgpu-pro/bin:$PATH"
{{< /code >}}

### Hard reboot

  It would be safer to do a <kbd>Alt</kbd>+<kbd>SysRq</kbd>+(<kbd>R</kbd>,<kbd>E</kbd>,<kbd>I</kbd>,<kbd>S</kbd>,<kbd>U</kbd>,<kbd>B or O</kbd>) than force a *hard* reboot.

 - <kbd>R</kbd> Switch the keyboard from raw mode to XLATE mode
 - <kbd>E</kbd> SIGTERM everything except init
 - <kbd>I</kbd> SIGKILL everything except init
- <kbd>S</kbd> Syncs the mounted filesystem
 - <kbd>U</kbd> Remounts the mounted filesystem in read-only mode
- <kbd>B</kbd> Reboot the system, or <kbd>O</kbd> Turn off the system

>The SysRq key is a key combination understood by the Linux kernel, which allows the user to perform various low-level commands regardless of the system's state. It is often used to recover from freezes, or to reboot a computer without corrupting the filesystem. Its effect is similar to the computer's hardware reset button (or power switch) but with many more options and much more control. 

~~~sh

    for i in s u b; do echo $i | sudo tee /proc/sysrq-trigger; sleep 5; done  # reboot
    for i in s u o; do echo $i | sudo tee /proc/sysrq-trigger; sleep 5; done  # halt
~~~

Data loss is possible from running applications but it shouldn't knacker your filesystem. If you a have particularly huge disk write cache it might be best to increase the `sleep` value.


## Install and run your favorite miner

At this point, you can run your preferred Ethash GPU mining worker.

## Install ROCm System Management Interface

The `rocm-smi` tool exposes functionality for clock, power and temperature management of your system. We will be running the tool directly in this guide instead.

~~~s
wget https://github.com/RadeonOpenCompute/ROC-smi/archive/rocm-3.9.0.tar.gz
~~~
| Option    | Description  |
| :-------| :----------: | 
| --setsclk LEVEL [LEVEL ...]        |  Set GPU Clock Frequency Level(s) (requires manual Perf level) |
| --setmclk LEVEL [LEVEL ...]        |  Set GPU Memory Clock Frequency Level(s) (requires manual Perf level) |                
|--setpcie LEVEL [LEVEL ...]         |  Set PCIE Clock Frequency Level(s) (requires manual Perf level) |
|--setslevel SCLKLEVEL SCLK SVOLT    |  Change GPU Clock frequency (MHz) and Voltage (mV) for a specific Level      
| --setmlevel MCLKLEVEL MCLK MVOLT   |  Change GPU Memory clock frequency (MHz) and Voltage for (mV) a specific Level
| --setfan LEVEL                     |  Set GPU Fan Speed (Level or %)
| --setperflevel LEVEL               |  Set Performance Level
| --setoverdrive %                   |  Set GPU OverDrive level (requires manual|high Perf level)
| --setmemoverdrive %                |  Set GPU Memory Overclock OverDrive level (requires manual|high Perf level)  
| --setpoweroverdrive WATTS          |  Set the maximum GPU power using Power OverDrive in Watts

Read more about the tool on github [here](https://github.com/RadeonOpenCompute/ROC-smi)




```html

BTC: 1EqpVbnmVLczTe6TVzis5LuJfrm2AATjNB 
ETH: 0x0ee9cfbbcbdcf11f9248084da8faf7eeeb4580b8
```



    
