# Fig-5: Evaluation of RT-Gang with Synthetic Tasksets
The experiment described herein can be used to reproduce Fig-5 from our paper.

## Pre-Requisites
The following software packages are required for this experiment:
- IsolBench
- trace-cmd
- kernelshark

## Setup
1. Clone IsolBench git repository.
```
git clone https://github.com/CSL-KU/IsolBench.git
```

2. Compile **bandwidth-rt** benchmark from IsolBench.
```
cd IsolBench/benchmarks
make bandwidth-rt
```

3. Create symbolic links to bandwidth-rt executable as described below:
```
sudo ln -s <full-path-to-IsolBench>/benchmarks/bandwidth-rt /usr/bin/tau_1
sudo ln -s <full-path-to-IsolBench>/benchmarks/bandwidth-rt /usr/bin/tau_2
sudo ln -s <full-path-to-IsolBench>/benchmarks/bandwidth-rt /usr/bin/tau_be_mem
sudo ln -s <full-path-to-IsolBench>/benchmarks/bandwidth-rt /usr/bin/tau_be_cpu
```

4. Install trace-cmd and kernelshark.
```
sudo apt install trace-cmd kernelshark
```

5. Build BWLOCK kernel module and user-application.
> NOTE: The script used for this experiment **assumes** that BWLOCK can be
found via the relative path from *this folder* to the *throttling* folder as
per the default locations of these folders in this repository.

6. Place the platform in the maximum performance mode. The script
   [max\_perf.sh](../max_perf.sh) can be used for this purpose.

5. **Verify** that:
  - Symbolic links have been successfully created
  - trace-cmd and kernelshark have been correctly installed
  - BWLOCK is built and located in its default folder
  - Platform is in maximum performance mode ([script](../perf\_state.sh))

6. You can now proceed with the experiment.

## Experiment
Once the setup is complete, performing the actual experiment is straight-forward:
```
. fig5.sh
```

Once the experiment is complete, please do the following:
1. Open the **trace.rtg** file with kernelshark.
```
kernelshark -i trace.dat
```

2. Zoom into the trace. We recommend using middle part of the execution for
   this purpose. It ensures that tasks have reached their steady-state and
   their trace is as close to the snapshot used in the paper as possible.

3. The zoom window should be set to **60-msec** which is equal to the
   hyper-period of the taskset used in this experiment. The convention we have
   used in the paper is to align the zoom window with the invocation of the
   high-priority task (*tau\_1*).

## Expected Outcome
This experiment produces two trace files:
- trace.mint (Trace of the taskset under default Linux RT-class scheduling)
- trace.rtg  (Trace of the taskset under RT-Gang)

The user should be able to observe following salient differences between the two traces:
1. Under RT-Gang, the execution of tau\_1 (higher-priority RT task) never overlaps with the execution of tau\_2 (lower-priority RT task)

2. Whenever the execution of best-effort memory-intensive task (tau\_be\_mem) overlaps with the execution of any of the RT-tasks under RT-Gang, it is throttled. User should be able to verify that by noticing the execution of **kthrottle** in the CPU timeline of Core-2
