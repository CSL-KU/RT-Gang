#include "common.h"

/**************************************************************************
 * Global Variables
 **************************************************************************/
extern struct core_info __percpu	*core_info;
extern int				g_period_us;
extern int                              g_hw_counter_id;

/*
 * perf_event_count
 * This function calculates the number of performance monitoring events which have
 * been registered so far in the current period
 */
u64 perf_event_count (struct perf_event *event)
{
	u64 event_count = local64_read (&event->count);
	u64 child_count = atomic64_read (&event->child_count);
	u64 total_count = event_count + child_count;

	/* Return the total PMC event count */
	return total_count;
}

/*
 * init_counter
 * This function initializes the performance counters to count the desired
 * events
 */
struct perf_event* init_counter (int cpu,
				 int budget)
{
	struct perf_event *event = NULL;

	/* Describe the attributes of the PMC event to be counted */
	struct perf_event_attr sched_perf_hw_attr = {
		.type		= PERF_TYPE_RAW,
		.config		= g_hw_counter_id,
		.size		= sizeof (struct perf_event_attr),
		.pinned		= 1,
		.disabled	= 1,
		.exclude_kernel	= 1,
		.sample_period	= budget
	};

	/* Create perf kernel counter with the desired attributes */
	event = perf_event_create_kernel_counter (&sched_perf_hw_attr,
						  cpu,
						  NULL,
						  event_overflow_callback,
						  NULL
						  );

	/* Return the created event to caller */
	return event;
}

/*
 * __disable_counter
 * This function disables the performance counter on a particular core
 */
void __disable_counter (void *info)
{
	struct core_info *cinfo = this_cpu_ptr (core_info);

	/* Stop the perf counter */
	cinfo->event->pmu->stop (cinfo->event, PERF_EF_UPDATE);

	/* Stop throttling */
	cinfo->throttled_task = NULL;

	/* Return to caller */
	return;
}

/*
 * disable_counters
 * This function invokes counter disable function on each system core
 */
void disable_counters (void)
{
	/* Invoke the __disable_counter function on each cpu */
	on_each_cpu (__disable_counter, NULL, 0);

	/* All done here */
	return;
}
