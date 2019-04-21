echo $$ >> cpuset/cpu3/tasks
trace-cmd record -e sched_switch -e 'sched_wakeup*' tau_1 -u 40  -d 100 -m 32 -t 10 &
echo $$ >> cpuset/cpu4/tasks
tau_2 -u 40  -d 150 -m 32 -t 10 &
echo $$ >> cpuset/cpu5/tasks
tau_3 -u 100 -d 350 -m 32 -t 10 &
