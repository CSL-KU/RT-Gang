#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <linux/unistd.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <sys/syscall.h>
#include <pthread.h>

#define gettid() syscall(__NR_gettid)

#define SCHED_DEADLINE	6

/* XXX use the proper syscall numbers */
#ifdef __x86_64__
#define __NR_sched_setattr		314
#define __NR_sched_getattr		315
#endif

#ifdef __i386__
#define __NR_sched_setattr		351
#define __NR_sched_getattr		352
#endif

#ifdef __arm__
#define __NR_sched_setattr		380
#define __NR_sched_getattr		381
#endif

static volatile int done;

struct sched_attr {
       __u32 size;

       __u32 sched_policy;
       __u64 sched_flags;

       /* SCHED_NORMAL, SCHED_BATCH */
       __s32 sched_nice;

       /* SCHED_FIFO, SCHED_RR */
       __u32 sched_priority;

       /* SCHED_DEADLINE (nsec) */
       __u64 sched_runtime;
       __u64 sched_deadline;
       __u64 sched_period;
};

int sched_setattr(pid_t pid,
       	  const struct sched_attr *attr,
       	  unsigned int flags)
{
       return syscall(__NR_sched_setattr, pid, attr, flags);
}

int sched_getattr(pid_t pid,
       	  struct sched_attr *attr,
       	  unsigned int size,
       	  unsigned int flags)
{
       return syscall(__NR_sched_getattr, pid, attr, size, flags);
}

typedef struct {
	int	runtime_msec;
	int	period_msec;
} params_t;

void *run_deadline(void *data)
{
       struct sched_attr attr;
       int x = 0;
       int ret;
       unsigned int flags = 0;
       int runtime_msec = ((params_t *)data)->runtime_msec;
       int period_msec = ((params_t *)data)->period_msec;

       printf("deadline thread started [%ld]\n", gettid());

       attr.size = sizeof(attr);
       attr.sched_flags = 0;
       attr.sched_nice = 0;
       attr.sched_priority = 0;

       /* This creates a 10ms/30ms reservation */
       attr.sched_policy = SCHED_DEADLINE;
       attr.sched_runtime = runtime_msec * 1000 * 1000;
       attr.sched_period = attr.sched_deadline = period_msec * 1000 * 1000;

       ret = sched_setattr(0, &attr, flags);
       if (ret < 0) {
       	done = 0;
       	perror("sched_setattr");
       	exit(-1);
       }

       while (!done) {
       	x++;
       }

       printf("deadline thread dies [%ld]\n", gettid());
       return NULL;
}

#define	NUM_OF_THREADS	3

int main (int argc, char **argv)
{
	pthread_t thread [NUM_OF_THREADS];
       	params_t params [NUM_OF_THREADS];

       	params [0].runtime_msec = 40;
       	params [0].period_msec  = 100;
       	params [1].runtime_msec = 40;
       	params [1].period_msec  = 150;
       	params [2].runtime_msec = 100;
       	params [2].period_msec  = 350;

	printf("main thread [%ld]\n", gettid());

       	for (int i = 0; i < NUM_OF_THREADS; ++i)
       	        pthread_create(&thread [i], NULL, run_deadline, (void *)&params [i]);

       	sleep(10);

       	done = 1;

	for (int i = 0; i < NUM_OF_THREADS; ++i)
		pthread_join(thread [i], NULL);

	printf("main dies [%ld]\n", gettid());
       	return 0;
}
