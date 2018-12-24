# [Work-in-Progress] RT-Gang: Real-Time Gang Scheduling for Safety Critical Systems
This repository contains all the scripts needed to reproduce experiments related
to RT-Gang.

# Pre-requisites
### Hardware
+ NVIDIA Jetson TX-2 Board
+ Raspberry Pi 3 (Rev B) [*Instructions Pending...*]

### Software
+ Linux for Tegra (Version 28.1)
+ Python (Version 2.7)
+ Git
+ Matplotlib

# Directory Structure
  * [l4t: Placeholder directory for hosting Linux for Tegra kernel]( ./kernel)
     * [miscs: Contains required kernel patches]( ./kernel/miscs)
       * [diffs]( ./kernel/miscs/diffs)
       * [devfreq]( ./kernel/miscs/diffs/devfreq)
       * [nvgpu]( ./kernel/miscs/diffs/nvgpu)
       * [tegra-alt]( ./kernel/miscs/diffs/tegra-alt)

# Step-by-step Instructions

1. Launch a bash shell. Install Git
```bash
sudo apt-get install git
```

2. Clone this repository
```bash
git clone https://github.com/wali-ku/RT-Gang.git
```

3. Launch a sudo shell
```
sudo bash
```

4. Install **RT-Gang + BWLOCK** patched kernel on board (Long Operation). All
   the steps required to do so are automated in this [script]( ./l4t/RUN-ME.sh).
   (NOTE: This step requires an active internet connection)
```bash
cd RT-Gang/l4t/
./RUN-ME.sh
```

5. Reboot the system.

6. Relaunch a bash shell and verify that **GANG-LOCK** is available as a
   scheduling feature (NOTE: The feature is disabled by default so the phrase
   **NO\_RT\_GANG\_LOCK** should be visible in the file below)
```bash
sudo bash
cat /sys/kernel/debug/sched_features
```

RT-Gang is now ready for testing.
