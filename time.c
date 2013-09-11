#include "time.h"
#include <stdio.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

double getDoubleTime(void)
{
	mach_timebase_info_data_t base;
	mach_timebase_info(&base);
	
	double seconds = (double)mach_absolute_time()*((double)base.numer/(double)base.denom)*1.0e-9;
	return seconds;
}
