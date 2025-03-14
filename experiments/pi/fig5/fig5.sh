#==============================================================================
# Fig-5
#
# Run two periodic bandwidth-rt (2-threads each) with two best-effort (single
# threaded) tasks. Collect traces for kernelshark.
#==============================================================================
if grep "0xd03" /proc/cpuinfo; then
    # cortex-a53
    WS=192
    TH_PERF_COUNTER=0x17
    echo "Cortex-A53. Pi3"
elif grep "0xd08" /proc/cpuinfo; then
    # cortex-a72
    WS=192
    TH_PERF_COUNTER=0x17
    echo "Cortex-A72. Pi4"
elif grep "0xd0b" /proc/cpuinfo; then
    # cortex-a76
    WS=640
    TH_PERF_COUNTER=0x2A
    echo "Cortex-A76. Pi5"
else
    # assume intel/amd
    WS=1280
    TH_PERF_COUNTER=0x412e
fi

MEM_WS=16384 # 16M

# Scheduler features path has been changed in newer kernels
if [ -e /sys/kernel/debug/sched/features ]; then
    SCHED_FEATURES_PATH="/sys/kernel/debug/sched/features"
elif [ -e /sys/kernel/debug/sched_features ]; then
    SCHED_FEATURES_PATH="/sys/kernel/debug/sched_features"
else
    echo "Error: Neither sched features path exists" >&2
    exit 1
fi

do_solo()
{
    echo 'Solo Experiments'

    trace-cmd start -e sched_switch -e sched_wakeup -e sched_wakeup_new

#   on pi5, there's a significant interference between tau_1 and tau_2.
#   for now, disable tau_2 in solo.
#
#    chrt -f 5 tau_2 -o -t 0 -c 2 -n 2 -m ${WS} -i 210 --jobs 333 --period 30 -v 1    \
#	&> /tmp/tau_2.solo &

    chrt -f 10 tau_1 -o -t 0 -c 0 -n 2 -m ${WS}     \
	      -i 110 --jobs 500 --period 20 -v 1 &> /tmp/tau_1.solo

    killall -s SIGTERM tau_2

    trace-cmd stop
    trace-cmd extract

    mv trace.dat solo.dat
    mv /tmp/*.solo .
}
#==============================================================================

do_mint()
{
    echo 'Co-Sched Experiment'
    echo NO_RT_GANG_LOCK > "$SCHED_FEATURES_PATH"
    
    sleep 2
    trace-cmd start -e sched_switch -e sched_wakeup -e sched_wakeup_new

    chrt -f 5 tau_2 -o -t 0 -c 2 -n 2 -m ${WS} -i 210 --jobs 333 --period 30 -v 1    \
	&> /tmp/tau_2.mint &

    tau_be_mem -t 0 -c 2 -n 1 -m ${MEM_WS} &> /tmp/tau_be_mem.mint &
    tau_be_cpu -t 0 -c 3 -n 1 -m 8 &> /tmp/tau_be_cpu.mint &

    chrt -f 10 tau_1 -o -t 0 -c 0 -n 2 -m ${WS}     \
	 -i 110 --jobs 500 --period 20 -v 1 &> /tmp/tau_1.mint

    killall -s SIGTERM tau_be_mem tau_be_cpu tau_2

    trace-cmd stop
    trace-cmd extract

    mv trace.dat mint.dat
    mv /tmp/*.mint .
}
#==============================================================================

do_rtg()
{
    echo 'RT-Gang Experiment'
    echo RT_GANG_LOCK > "$SCHED_FEATURES_PATH"

    # AMD: 0x0964, ARM: 0x17, Intel: 0x412e 
    insmod ../../../throttling/kernel_module/exe/bwlockmod.ko g_hw_counter_id=${TH_PERF_COUNTER}
    # insmod ../../../throttling/kernel_module/exe/bwlockmod.ko

    sleep 2
    trace-cmd start -e sched_switch -e sched_wakeup -e sched_wakeup_new

    chrt -f 5 tau_2 -o -t 0 -c 2 -n 2 -m ${WS} -i 210 --jobs 333 --period 30 -v 1    \
	&> /tmp/tau_2.rtg &

    tau_be_mem -t 0 -c 2 -n 1 -m ${MEM_WS} &> /tmp/tau_be_mem.rtg &
    tau_be_cpu -t 0 -c 3 -n 1 -m 8 &> /tmp/tau_be_cpu.rtg &

    chrt -f 10 tau_1 -o -t 0 -c 0 -n 2 -m ${WS}     \
	 -i 110 --jobs 500 --period 20 -v 1 &> /tmp/tau_1.rtg

    killall -s SIGTERM tau_be_mem tau_be_cpu tau_2

    trace-cmd stop
    trace-cmd extract

    mv trace.dat rtg.dat
    mv /tmp/*.rtg .

    echo NO_RT_GANG_LOCK > "$SCHED_FEATURES_PATH"
    rmmod bwlockmod
}


do_solo
do_mint
do_rtg 
