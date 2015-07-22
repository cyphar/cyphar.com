title: Making a Simple Scheduler for an Arduino
author: Aleksa Sarai
published: 2015-01-12 03:00:00
updated: 2015-01-16 21:30:00
description: >
  The latest cool thing I worked on for [NCSS](http://ncss.edu.au/summer_school/)
  in order to play "The Final Countdown" on a single Arduino Uno with proper
  chords. Also because I really wanted to write a scheduler, and this was a good
  excuse.
tags:
  - arduino
  - c
  - scheduler
  - programming

Disclaimer: I wrote this scheduler to be a single-purpose tool for doing one
specific task that required the ability to have an arbitrary number of
asynchronous scheduled processes to execute. If you run this code and your
house catches on fire, please don't blame me.

What follows is basically a quick intro into what a scheduler is, and how (and
why) I made one for the Arduino (although it is standard C code, so it works
everywhere).

### The Code ###
They say that code is the best kind of documentation (hint: it isn't). Anyway,
[here's the GitHub repo](https://github.com/cyphar/sched) which contains the
scheduler implementation that I detail below. Feel free to follow along with the
real code.

### What is a Scheduler ###
It turns out that computers are very bad at running multiple things at the same
time. While it is true that you can have multicore CPUs, each individual core
can only run one thing at one point in time. So, you may be wondering "If you
can only run one thing at the same time, how come I can run multiple processes
on my computer at the same time?".

The answer: **scheduling**.

So, what's happening is that your operating system has a kernel which has a
piece of code called a scheduler (which is usually of the preemptive
persuasion). This piece of code's job is to basically give system resources
(specifically CPU time) to particular processes (which are really just kernel
objects from a kernel standpoint) for a particular period of time. There are
quite a few ways to implement a scheduler (the main difference being the logic
behind choosing *which* process to give CPU time to next), but the basic idea
is the same. You want to take a process and run it, but you want to be able to
context switch to a new process every set interval of time.

### What is *my* Scheduler ###
So, I want you to ignore most of the last paragraph, because that's not how my
scheduler operates.

Turns out that preemptive scheduling (where you basically force a process to
stop when you're giving the next process the CPU time) is not easy on something
like an Arduino (which has **very** limited resources). Sure, you can do it
with timer interrupts, but that means that you can only effectively schedule 3
(or 4 if you implement a blocking version which then gets stopped by the
interrupts) tasks to run at the same time. I wanted to make a general purpose
solution which would allow for a very large amount (memory allowing) of tasks
to be scheduled to run at the same time.

However, if you don't have a preemptive scheduler, you need to start breaking
up your blocking code into chunks of asynchronous functions that then are set
up to fire relative to each other. If you've ever worked with an event-driven
language before, you'll realise that I just described an event loop. However,
the overall purpose of this event loop is to act as a scheduler, it's just that
it's more of an event loop than a classical interrupt-based scheduler (such as
you would see in your regular operating system).

### Patterns ###
So, because of its callback-driven nature, my scheduler essentially has a set
of patterns you can use to perform tasks asynchronously. These patterns require
you to break up your blocking functions into a series of asynchronous tasks
that are run ... well ... asynchronously. You can kind of imagine that you are
doing the job of a preemptive sheduler, you are breaking down a process (or
function) into a series of chunks that can run for the prescribed CPU time
segment. Of course, if you register a blocking function, you will block the
entire scheduler and completely ruin your registered events (because they will
all run in one chunk if their timers elapse).

Anyway, here are a few cool patterns that I played around with to get stuff
running and completing the project I describe below. I would like to point out
that the UI is something that I *would* like to make a bit nicer (while I like
the granularity of passing `struct`s it makes for bad code to read for the
callers).

#### Toggling #####
Say you want to toggle a pin asynchronously. If you break up the problem into
two parts (turning the LED on, and turning it off) then you can register each
as separate functions and use timeouts to call them at an appropriate time.
This pattern is general purpose enough that you can practically do essentially
anything of this form of problem by using this pattern.

I do agree that this is not particularly pretty, and if you see the "What's
Next" section, you can see what I would *like* this to look like eventually
(and maybe I'll update this article when I've done that).

```language-c
struct sched_t sched;

void led_on(void *) {
	/* Turn the LED on here. */
	/* ... */

	/* Register the next task. */
	struct task_t next;
	task_clear(&next);
	next.task = led_off;
	next.mtime = 500;
	next.flag = ONCE;
	sched_register(&sched, next);
}

void led_off(void *) {
	/* XXX: Turn the LED off here. */
	/* ... */

	/* Register the next task. */
	struct task_t next;
	task_clear(&next);
	next.task = led_on;
	next.mtime = 500;
	next.flag = ONCE;
	sched_register(&sched, next);
}

void setup() {
	/* Initialise the scheduler. */
	sched_init(&sched);

	/* Register the first task. */
	struct task_t task;
	task_clear(&task);
	task.task = led_off;
	task.mtime = 2000;
	task.flag = ONCE;
	sched_register(&sched, task);
}

void loop() {
	sched_tick(&sched);
}
```

#### Polling ####
Say that you don't really want to use interrupts (because you only have 2
interrupt pins, and `millis()` doesn't work inside an interrupt) when detecting
an event from a sensor. Of course you want to poll asynchronously, so you can
register a periodic task that does a single poll with a small period and does
all of the relevant task registration.

```language-c
struct sched_t sched;
static bool got_data = false;

void check_serial(void *) {
	/* Poll the serial port. If there's nothing, then just bail. */
	if(!Serial.available())
		return;

	/* XXX: Parse the Serial data however you wish here. */
	/*      Feel free to use global variables, since there's no interrupts there
	 *      are no *real* race conditions */
	got_data = true;
}

void did_it_work(void *) {
	/* Print some debug information. */
	if(got_data) {
		Serial.println("Got some data.");
		got_data = false;
	}
}

void setup() {
	/* Start the serial connection. */
	Serial.begin(9600);

	/* Initialise the scheduler. */
	sched_init(&sched);

	/* Register the serial polling task to run every 5ms. */
	struct task_t serial_task;
	task_clear(&serial_task);
	serial_task.task = check_serial;
	serial_task.mtime = 5;
	serial_task.flag = PERIODIC;
	sched_register(&sched, serial_task);

	/* Register the debug output task to run every 200ms. */
	struct task_t debug_task;
	task_clear(&debug_task);
	debug_task.task = did_it_work;
	debug_task.mtime = 200;
	debug_task.flag = PERIODIC;
	sched_register(&sched, debug_task);
}

void loop() {
	sched_tick(&sched);
}
```

### Arguments ###
Say you want to run some scheduled task with an argument. All you have to do is make sure that your function:

* Returns nothing.
* Takes a single pointer (of any type) as an argument.
* Gets cast to a `(task_fp)` when registering it.

The following is the above LED example, rewritten to use arguments instead of two separate functions.

```language-c
/* Global scheduler state. */
struct sched_t sched;

/* Global on/off states so that arguments don't need to be malloc'd. */
bool on = true;
bool off = false;

void led(bool *state) {
	bool *next = NULL;

	/* State machine for the LED. */
	switch(*state) {
		case true:
			/* XXX: Turn the LED on here. */
			/* ... */

			/* Set the next argument. */
			next = &off;
			break;
		case false:
			/* XXX: Turn the LED off here. */
			/* ... */

			/* Set the next argument. */
			next = &on;
			break;
	}

	/* Register the next task. */
	struct task_t task;
	task_clear(&task);
	task.task = (task_fp) led, /* Make sure you cast the function pointer. */
	task.task_arg = next,
	task.mtime = 500,
	task.flag = ONCE,
	sched_register(&sched, task);
}

void setup() {
	/* Initialise the scheduler. */
	sched_init(&sched);

	/* Register the task with the argument &on */
	task_clear(&task);
	task.task = (task_fp) led, /* Make sure you cast the function pointer. */
	task.task_arg = &on,
	task.mtime = 500,
	task.flag = ONCE,
	sched_register(&sched, task);
}

void loop() {
	sched_tick(&sched);
}
```


### How Does it Work? ###
`sched_tick()` is basically a function which checks through each of the
registered tasks and checks if they should be fired. When they are fired, the
correct callbacks and deregistration (or registration) functions are called.
The actual source code for the scheduler is about 200 lines of code, due to
it's relatively simple design.

### What's Next? ###
I really want to do some black magic with "delays" (where I write my own
`delay()`-like function called `sched_delay()` or similar) which would
essentially cause the scheduler to run another task (or set of tasks) until the
timeout expires. This obviously could get quite hairy quite quickly, but you can
think of this as being fairly similar to the Go scheduler (it won't context
switch to another goroutine until the current goroutine is in a blocking
operation like a `select` block). The real benefit of this would be its insane
simplicity (you wouldn't have to break down your functions into smaller tasks
anymore, yay!) and the fact that there would be little to no code changes
between the asynchronous and blocking versions of the same code.

However, there are a few issues. The largest of which is that the only way that
I can think of implementing the above feature requires that I essentially write
the guts of a full operating system scheduler (including the multiple stack
code -- requiring me to write some assembly to copy the values of the registers
and program counter). Not only that, but I'd have to come up with some way of
returning control to the calling function after saving the task state (without
interrupts or trap frames -- both of which are not restrictions for real
kernels) in such a way that I can go back to the point after I leave the
function when the task is rescheduled. This would require a lot of dark magic
with inline assembly, and I can't really imagine how it would play with GCC's
optimisations (GCC loves to mess with your branches such that `ret`s aren't
where you think, and trying to jump the program counter after them is an
exercise in futility). And of course, if I have to write assembly code then it
starts to become more platform specific and then I need to start figuring out a
new hack for every architecture. Another issue is the memory constraints that
having so much data in motion for each task would have. It's unlikely that you
could schedule more than 10 tasks with the 2K limit of dynamic memory on an
Arduino UNO. Also, there are speed constraints to think about. The current
design of the scheduler already is pushing the limits of PWM, it's unlikely
that a more magical implementation would be able to keep up with the speed
requirements of doing PWM effectively.

To get an idea of how I would consider implementing such a feature, it would be
some mixture of how [xv6](http://pdos.csail.mit.edu/6.828/2014/xv6.html) and
[Go](https://golang.org/) do their scheduling.

### But ... why? ###
If I had to explain it in a word: [NCSS](http://ncss.edu.au/summer_school/).

Essentially it was because I was dared by the Chief Architect of Darkness (also
known as [James Curran](http://www.sydney.edu.au/it/~james)) to play "The Final
Countdown" on some Arduinos (in return he would upload some videos which he had
promised some time ago he would upload and had failed to do so). And while I
thought it was a cool project idea, I thought "Why couldn't I just run this on
one Arduino, and just schedule the different chords to play at the same time?"
About an hour later, I had a somewhat-working scheduler and started to come up
with ideas for what patterns I could use to fulfil the requirements of the
project. Then, I was talking to [Nicky Ringland](http://www.sydney.edu.au/it/~nicky)
and realised that it would make a somewhat cool-ish technical blog post to talk
about simple scheduling for an Arduino.
