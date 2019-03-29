TGT_CPU=(3 4 5)
mkdir -p cpuset
mount -t cgroup -o cpuset cpuset cpuset

cd cpuset
for cpu in ${TGT_CPU[@]}; do
	mkdir cpu${cpu}
	echo ${cpu} > cpu${cpu}/cpuset.cpus
	echo 0 > cpu${cpu}/cpuset.mems
done
cd -
