SETS=(1 2)
mkdir -p cpuset
mount -t cgroup -o cpuset cpuset cpuset

cd cpuset
for id in ${SETS[@]}; do
	mkdir set${id}

	if [ "${id}" == "1" ]; then
		echo 0,3 > set${id}/cpuset.cpus
	else
		echo 4,5 > set${id}/cpuset.cpus
	fi

	echo 0 > set${id}/cpuset.mems
done
cd -
