#ifndef __COMMON_H__
#define __COMMON_H__

/**************************************************************************
 * Include Files
 *************************************************************************/
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/hrtimer.h>
#include <linux/ktime.h>
#include <linux/smp.h>
#include <linux/irq_work.h>
#include <linux/hardirq.h>
#include <linux/perf_event.h>
#include <linux/delay.h>
#include <linux/debugfs.h>
#include <linux/seq_file.h>
#include <asm/atomic.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/uaccess.h>
#include <linux/notifier.h>
#include <linux/kthread.h>
#include <linux/printk.h>
#include <linux/interrupt.h>
#include <linux/cpu.h>
#include <linux/sched.h>
#include <linux/signal.h>
#include <linux/sched/rt.h>

#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 13, 0)
#include <linux/sched/types.h>
#endif

/**************************************************************************
 * Public Definitions
 **************************************************************************/
#define CACHE_LINE_SIZE		64

/* Set debug flags */
#define	DEBUG_PERIODIC(x)
#define DEBUG_OVERFLOW(x)
#define DEBUG_TIME(x)		x
#define DEBUG_INTERRUPT(x)
#define DEBUG_MONITOR(x)

/* Define common multipliers */
#define K1			1000ULL
#define M1			(K1 * K1)
#define G1			(K1 * K1 * K1)

#if LINUX_VERSION_CODE > KERNEL_VERSION(4, 10, 0)
#define TM_NS(x)		(x)
#else
#define TM_NS(x)		(x).tv64
#endif

/**************************************************************************
 * Public Types
 **************************************************************************/
struct perfmod_info {
	u64			system_throttle_duration;
	u64			system_throttle_period_cnt;
};


struct core_info {
	/* Per core statistics */
	ktime_t			core_throttle_start_mark;
	u64			core_throttle_duration;
	u64			core_throttle_period_cnt;

	/* HRTIMER relted fields */
	struct hrtimer		hrtimer;
	ktime_t			period_in_ktime;

	/* Throttling related fields */
	wait_queue_head_t	throttle_evt;
	struct task_struct	*throttle_thread;
	struct task_struct	*throttled_task;
	struct irq_work		pending;
	int			throttle_core;

	/* Perf related fields */
	struct perf_event	*event;
	u64			budget;

	/* General fields */
	struct task_struct	*init_thread;
};

/**************************************************************************
 * External Function Prototypes
 **************************************************************************/
extern u32 sysctl_llc_maxperf_events;
extern int be_mem_threshold;

/**************************************************************************
 * Interface functions
 **************************************************************************/

/* Defined in perf.c */
u64 perf_event_count (struct perf_event *);
void __start_counter (void *);
void start_counters (void);
void __disable_counter (void *);
void disable_counters (void);
struct perf_event* init_counter (int, int);

/* Defined in interrupt.c */
enum hrtimer_restart periodic_timer_callback (struct hrtimer *);

/* Defined in overflow.c */
void event_overflow_callback (struct perf_event *, struct perf_sample_data *, struct pt_regs *);
void perfmod_process_overflow (struct irq_work *);
int throttle_thread (void *);

/**************************************************************************
 * Global Inline Function Definitions
 **************************************************************************/


#endif /* __COMMON_H__ */
