############### Solo Experiment
# echo "[STATUS] Running tau_1 solo"
# echo $$ > cpuset/set1/tasks
# trace-cmd record -e sched_switch tau_1 -o -n 2 -m 800 -t 1000 -i 50 --period 20 -d 20 -u 20 --jobs 1000 -v 1 &> tau_1.solo.trace
# mv trace.dat tau_1.trace

# sleep 2
# echo "[STATUS] Running tau_2 solo"
# echo $$ > cpuset/set2/tasks
# trace-cmd record -e sched_switch tau_2 -o -n 2 -m 800 -t 1000 -i 100 --period 30 -d 30 -u 30 --jobs 1000 -v 1 &> tau_2.solo.trace
# mv trace.dat tau_2.trace

############### Corun Experiment
# sleep 2
# echo "[STATUS] Corun Experiment"
# perf stat -o tau_be_mem.corun.trace tau_be_mem -c 4 -t 1000 -m 16384 -a write &> /dev/null &
# perf stat -o tau_be_cpu.corun.trace tau_be_cpu -c 5 -t 1000 -m 16 &> /dev/null &
# 
# echo $$ > cpuset/set1/tasks
# trace-cmd record -e sched_switch tau_1 -o -n 2 -m 800 -t 1000 -i 50 --period 20 -d 20 -u 20 --jobs 1000 -v 1 &> tau_1.becorun.trace &
# 
# echo $$ > cpuset/set2/tasks
# tau_2 -o -n 2 -m 800 -t 1000 -i 100 --period 30 -d 30 -u 30 --jobs 1000 -v 1 &> tau_2.becorun.trace
# 
# killall -s SIGTERM tau_be_mem
# killall -s SIGTERM tau_be_cpu
# mv trace.dat corun.trace

############### RT-Gang Experiment
# sleep 2
echo "[STATUS] RT-Gang Experiment"
echo "enable 1" > /sys/kernel/debug/throttle/control
echo "regulate 0x17 1638400" > /sys/kernel/debug/throttle/control
echo "start 1" > /sys/kernel/debug/throttle/control
echo "RT_GANG_LOCK" > /sys/kernel/debug/sched_features
sleep 2

perf stat -o tau_be_mem.rtg.trace tau_be_mem -c 4 -t 1000 -m 16384 -a write &> /dev/null &
perf stat -o tau_be_cpu.rtg.trace tau_be_cpu -c 5 -t 1000 -m 16 &> /dev/null &

echo $$ > cpuset/set1/tasks
trace-cmd record -e sched_switch tau_1 -o -n 2 -m 800 -t 1000 -i 50 --period 20 -d 20 -u 20 --jobs 1000 -v 1 &> tau_1.bertg.trace &

echo $$ > cpuset/set2/tasks
tau_2 -o -n 2 -m 800 -t 1000 -i 100 --period 30 -d 30 -u 30 --jobs 1000 -v 1 &> tau_2.bertg.trace

killall -s SIGTERM tau_be_mem
killall -s SIGTERM tau_be_cpu
mv trace.dat rtg.trace
