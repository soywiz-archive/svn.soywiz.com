/* time.h -- An implementation of the standard Unix <sys/time.h> file.
   Written by Geoffrey Noer <noer@cygnus.com>
   Public domain; no rights reserved. */

module pspsdk.csystime;

public import std.c.time;

extern (C) {

alias int suseconds_t;

struct timeval {
  time_t      tv_sec;
  suseconds_t tv_usec;
}

struct timezone {
  int tz_minuteswest;
  int tz_dsttime;
}


const int ITIMER_REAL = 0;
const int ITIMER_VIRTUAL =  1;
const int ITIMER_PROF =     2;

struct  itimerval {
 timeval it_interval;
 timeval it_value;
}

}

