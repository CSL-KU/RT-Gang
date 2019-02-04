#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/syscall.h>
#include <time.h>

#define SYS_bwlock 245

int main(int argc, char *argv [])
{
	int opt;
	int pid = -1,
	    bw_val = -1,
	    cte = -1;

	while ((opt = getopt (argc, argv, "p:v:e:")) != -1)
	{
		switch (opt) {
			case 'p':
				pid = strtol (optarg, NULL, 0);
				break;
			case 'v':
				bw_val = strtol (optarg, NULL, 0);
				break;
			case 'e':
				cte = strtol (optarg, NULL, 0);
				break;
		}
	}

	if (pid == -1 || bw_val == -1 || cte == -1) {
		printf ("Usage: %s -p <pid> -v <bw_val> -e <events>\n", argv [0]);
		return -1;
	}

	printf ("[DRIVER] Process: %d | Bwlock: %d | Events: %d\n",
	       pid, bw_val, cte);
	syscall (SYS_bwlock, pid, bw_val, cte);

	return 0;
}
