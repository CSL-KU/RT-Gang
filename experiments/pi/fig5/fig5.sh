#==============================================================================
# Fig-5
#
# Run two periodic bandwidth-rt (2-threads each) with two best-effort (single
# threaded) tasks. Collect traces for kernelshark.
#==============================================================================

WS=192 # big: 1280 (for Intel/AMD), small=192 (for ARM)
TH_PERF_COUNTER=0x17  # AMD: 0x0964, ARM: 0x17, Intel: 0x412e 

do_solo()
{
    echo 'Solo Experiments'
    chrt -f 5 tau_2 -o -t 0 -c 2 -n 2 -m ${WS} -i 210 --jobs 333 --period 30 -v 1    \
	&> /tmp/tau_2.solo
    sleep 2
    trace-cmd record -e sched_switch chrt -f 10 tau_1 -o -t 0 -c 0 -n 2 -m ${WS}     \
	      -i 110 --jobs 500 --period 20 -v 1 &> /tmp/tau_1.solo

    sleep 5
    mv trace.dat solo.dat
    mv /tmp/*.solo .
}
#==============================================================================

do_mint()
{
    echo 'Co-Sched Experiment'
    echo NO_RT_GANG_LOCK > /sys/kernel/debug/sched/features
    sleep 2

    tau_be_mem -t 0 -c 2 -n 1 -m 1024 &> /tmp/tau_be_mem.mint &
    tau_be_cpu -t 0 -c 3 -n 1 -m 8 &> /tmp/tau_be_cpu.mint &

    chrt -f 5 tau_2 -o -t 0 -c 2 -n 2 -m ${WS} -i 210 --jobs 333 --period 30 -v 1    \
	&> /tmp/tau_2.mint &
    trace-cmd record -e sched_switch chrt -f 10 tau_1 -o -t 0 -c 0 -n 2 -m ${WS}     \
	      -i 110 --jobs 500 --period 20 -v 1 &> /tmp/tau_1.mint
    killall -s SIGTERM tau_be_mem
    killall -s SIGTERM tau_be_cpu
    sleep 5
    mv trace.dat mint.dat
    mv /tmp/*.mint .
}
#==============================================================================

do_rtg()
{
    echo 'RT-Gang Experiment'
    echo RT_GANG_LOCK > /sys/kernel/debug/sched/features

    # AMD: 0x0964, ARM: 0x17, Intel: 0x412e 
    insmod ../../../throttling/kernel_module/exe/bwlockmod.ko g_hw_counter_id=${TH_PERF_COUNTER}
    # insmod ../../../throttling/kernel_module/exe/bwlockmod.ko

    chrt -f 5 tau_2 -o -t 0 -c 2 -n 2 -m ${WS} -i 210 --jobs 333 --period 30 -v 1    \
	&> /tmp/tau_2.rtg &

    tau_be_mem -t 0 -c 2 -n 1 -m 1024 &> /tmp/tau_be_mem.rtg &
    tau_be_cpu -t 0 -c 3 -n 1 -m 8 &> /tmp/tau_be_cpu.rtg &

    trace-cmd record -e sched_switch chrt -f 10 tau_1 -o -t 0 -c 0 -n 2 -m ${WS}     \
	      -i 110 --jobs 500 --period 20 -v 1 &> /tmp/tau_1.rtg

    killall -s SIGTERM tau_be_mem
    killall -s SIGTERM tau_be_cpu
    sleep 5
    mv trace.dat rtg.dat
    mv /tmp/*.rtg .

    echo NO_RT_GANG_LOCK > /sys/kernel/debug/sched/features
    rmmod bwlockmod
}


do_solo
do_mint
do_rtg 
