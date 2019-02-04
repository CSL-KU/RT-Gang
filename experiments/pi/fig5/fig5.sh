# Run two periodic bandwidth-rt (2-threads each) with two best-effort BwRead
# (single threaded) tasks. Collect traces for kernelshark.

echo 'Co-Sched Experiment'
echo NO_RT_GANG_LOCK > /sys/kernel/debug/sched_features
sleep 2

tau_be_mem -t 0 -c 2 -n 1 -m 1024 -i 1000000000 --jobs 100000 --period 1000 &> tau_be_mem.mint &
tau_be_cpu -t 0 -c 3 -n 1 -m 8 -i 1000000000 --jobs 100000 --period 1000 &> tau_be_cpu.mint &
chrt -f 5 tau_2 -t 0 -c 2 -n 2 -m 384 -i 75 --jobs 500 --period 30 -v 1 &> tau_2.mint &
trace-cmd record -e sched_switch chrt -f 10 tau_1 -t 0 -c 0 -n 2 -m 384 -i 50 --jobs 500 --period 20 -v 1 &> tau_1.mint
killall -s SIGTERM tau_2
killall -s SIGTERM tau_be_mem
killall -s SIGTERM tau_be_cpu
mv trace.dat trace.mint
sleep 5

insmod kernel_module/exe/bwlockmod.ko
echo 'RT-Gang Experiment'
echo RT_GANG_LOCK > /sys/kernel/debug/sched_features
sleep 2

tau_be_mem -t 0 -c 2 -n 1 -m 1024 -i 1000000000 --jobs 100000 --period 1000 &> tau_be_mem.rtg &
tau_be_cpu -t 0 -c 3 -n 1 -m 8 -i 1000000000 --jobs 100000 --period 1000 &> tau_be_cpu.rtg &
chrt -f 5 tau_2 -t 0 -c 2 -n 2 -m 384 -i 75 --jobs 500 --period 30 -v 1 &> tau_2.rtg &
trace-cmd record -e sched_switch chrt -f 10 tau_1 -t 0 -c 0 -n 2 -m 384 -i 50 --jobs 500 --period 20 -v 1 &> tau_1.rtg
killall -s SIGTERM tau_2
killall -s SIGTERM tau_be_mem
killall -s SIGTERM tau_be_cpu
mv trace.dat trace.rtg
sleep 5

rmmod bwlockmod
echo NO_RT_GANG_LOCK > /sys/kernel/debug/sched_features
