perf stat -o tau_be_mem.rtg.trace tau_be_mem -c 4 -t 1000 -m 16384 -a write &> /dev/null &
perf stat -o tau_be_cpu.rtg.trace tau_be_cpu -c 5 -t 1000 -m 16 &> /dev/null &

echo $$ > cpuset/set1/tasks
trace-cmd record -e sched_switch tau_1 -o -n 2 -m 800 -t 1000 -i 50 --period 10 -d 10 -u 7 --jobs 1000 -v 1 &> tau_1.bertg.trace &

echo $$ > cpuset/set2/tasks
tau_2 -o -n 2 -m 800 -t 1000 -i 100 --period 20 -d 20 -u 14 --jobs 1000 -v 1 &> tau_2.bertg.trace

killall -s SIGTERM tau_be_mem
killall -s SIGTERM tau_be_cpu
