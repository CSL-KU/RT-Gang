# RT-Gang: Real-Time Gang Scheduling for Safety Critical Systems
The aim of RT-Gang is to provide a **safe way to efficiently utilize a multicore platform for running safety critical real-time tasks**. It does so by allowing only one (parallel) real-time task to execute at any given time across all cores of a multicore platform. The design philosophy of RT-Gang is based on the following simple realization:

> The problem of inter-task interference is too complex to be solved on COTS multicore platforms.

This is due to the following reasons:

- All the sources of interference and contention cannot be realistically taken into account when scheduling disparate real-time tasks simultaneously on different cores of a multicore platform; due to the proprietary and often black-box nature of such hardware platforms.

- Even if one takes into account the **known** sources of contention in such platforms (e.g., shared caches, shared structures inside the caches such as MSHR, write-back buffers etc., memory bus, memory controller, DRAM banks etc.), the resulting schedulability analysis is too pessimistic because the interfence due to these sources can lead to more than 100x performance degradation in the worst-case.

In light of this cosideration, **RT-Gang does not try to solve the inter-task interfence problem; it eliminates it by design**. With its design, *RT-Gang reduces the complex problem of multicore scheduling of real-time tasks to simple and well-understood problem of unicore scheduling*.

## Tested Platforms
The development version of RT-Gang hosted under this tree has been tested on the following platform:

- NVIDIA Jetson TX-2 with Linux Kernel v4.4.38 (Linux for Tegra r28.1)

Porting the code-base to a different hardware platform is straight-forward since 99% code of RT-Gang is hardware agnostic. This section will be updated as we test RT-Gang on more hardware platforms.

## Setup
The code following the instructions in this section is written for TX-2. However, the instructions themselves can be replicated on any hardware platform running a Linux kernel which is close enough to v4.4.38 used in Linux for Tegra. Please make sure that the chosen platform has enough disk-space to host and build Linux kernel from source.

- Create a working directory:
```
$ mkdir rtg-workspace
$ cd rtg-workspace
```

- Check out the Linux kernel source
> The complete instructions for building Linux for Tegra on TX-2 can be seen in this [git repository](https://github.com/jetsonhacks/buildJetsonTX2Kernel)

- Patch the kernel with RT-Gang patch from this repository:
```
$ cd <kernel-root-directory>
$ wget https://raw.githubusercontent.com/CSL-KU/RT-Gang/devel/rtgang_v4.4.patch
$ patch -p1 < rtgang_v4.4.patch
```

- Enable the following options in the kernel configuration:
```
CONFIG_SCHED_RTGANG
CONFIG_SCHED_THROTTLE
CONFIG_SCHED_DEBUG
```

- Build the kernel and update the kernel image in the boot directory. Reboot the platform

- **Make sure** that the *NO_RT_GANG_LOCK* appears as a kernel feature in this file (```/sys/kernel/debug/sched_features```)

## Usage
- RT-Gang can be enabled with the following command:
```
$ echo RT_GANG_LOCK > /sys/kernel/debug/sched_features
```

- RT-Gang can be disabled with the following command:
```
$ echo NO_RT_GANG_LOCK > /sys/kernel/debug/sched_features
```

- The **throttling framework** can be enabled with the following command:
```
$ echo 'start 1' > /sys/kernel/debug/throttle/control
```

