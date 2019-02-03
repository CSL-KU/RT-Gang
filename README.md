# [Work-in-Progress] RT-Gang: Real-Time Gang Scheduling for Safety Critical Systems
RT-Gang adds the ability to schedule one (parallel) real-time task across all cores of a multicore platform at any given time. It has been developed as a scheduling feature in the Linux kernel. This repository contains the following materials related to RT-Gang:
- Linux kernel patches for the supported platforms
  - Jetson TX-2
  - Raspberry Pi-3
  - x86
- Experiment scripts to reproduce results from our paper
- Documentation

Please note that RT-Gang is **architecture neutral** and one should be able to test it on any (reasonably recent) Linux supported platform. The *supported platforms* listed above are the ones we have officially tested RT-Gang on.

# Pre-requisites
### Hardware
One of the following platforms:
+ NVIDIA's Jetson TX-2 Board
+ Raspberry Pi-3 (Rev B)
+ Any Intel PC capable of running Linux (v4.x.x and later)

### Software
+ Linux for Tegra (Version 28.1) for Jetson TX-2
+ Raspbian Stretch with Linux (v4.4.50)
+ Python (Version 2.7)
+ Git

Supplementary software packages are needed to run experiments and analyze collected data. These are listed with the relevant experiment scripts.

# Step-by-step Instructions

1. Obtain the source of the supported Linux kernel version for the platform under test. Since this step is inherently platform / environment dependent, we leave it to the user to perform this step according to their platform of choice.

2. Patch the kernel source with the relevant RT-Gang patch from this repository.

3. Ensure that **CONFIG_SCHED_DEBUG** is enabled in the kernel configuration. Otherwise, the scheduling features won't be modifiable at runtime.

4. Build and install the kernel on the platform.

5. Once the system has rebooted, ensure that **RT_GANG_LOCK** is available as a scheduling feature in the file */sys/kernel/debug/sched_features*. RT-Gang is now ready for testing.
