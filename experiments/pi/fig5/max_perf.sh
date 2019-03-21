#!/bin/sh
# This script manually sets the Pi's CPU clock rates to the maximum
# value and puts them under performance governor

echo "WARNING - Must Be Run Sudo"
echo "WARNING - Use Only on Pi"

# service lightdm stop

for core in `seq 0 3`; do
	echo performance > /sys/devices/system/cpu/cpu$core/cpufreq/scaling_governor
	cat /sys/devices/system/cpu/cpu$core/cpufreq/scaling_max_freq > /sys/devices/system/cpu/cpu$core/cpufreq/scaling_min_freq
done

echo -1 >/proc/sys/kernel/sched_rt_runtime_us

echo "Max Performance Settings Done"
