title: Adventures into `ptrace(2)` Hell
author: Aleksa Sarai
published: 2016-07-03 19:00:00
updated: 2016-07-03 19:00:00
description: >
  As part of my work on [rootless containers](/blog/rootless-containers-with-runc),
  I found that many tools try to drop privileges. This makes those tools break
  inside rootless containers, so I spent a week or two working on a tool that
  allows users to shim out all of the "drop privileges" syscalls. Here is
  documented the pain that I went through while figuring out how `ptrace(2)` is
  meant to work.
tags:
  - containers
  - free software
  - rant
  - runc
  - suse

Note: All of the code in this blog is part of [remainroot][remainroot] and is
bound by the license of that project. At the time of writing, the license is the
GNU General Public License version 3 (or later).

Because [rootless containers][rootless] only map a single user into their user
namespace, many syscalls will either give confusing values or fail for reasons
that the program doesn't understand. For example, all attempts to `setuid(2)`
will fail because no other user is mapped in the user namespace the process is
in. Similarly, `getgroups(2)` will give very odd results (it returns unmapped
supplementary groups in the array with the magical value of
`/proc/sys/kernel/overflowgid`). There are similar issues with many other
syscalls, but you get the idea.

In order to clean this up, we'll need to override the return values of syscalls the process encounter. There are two way of doing this:

1. Use `LD_PRELOAD` to override `glibc`'s defined symbols for all of the
   syscall wrappers. While this doesn't technically count as modifying
   syscalls, it has a very similar effect. Unfortunately it only works on
   programs that have been linked against `glibc` and don't use `syscall(2)` at
   any point. I implemented this method first, and it's not _really_ that
   useful (it doesn't correctly propogate over `execve` even after I did some
   horrible things with `memfd_create(2)`) or interesting.

2. Use `ptrace(2)` to intercept every syscall entry and exit. If it's a syscall
   we're interested in, pass the syscall arguments to our shims and then
   override the return value of the syscall with the return value of the shim.
   This is the "correct" way of doing this (implying that there is a "correct"
   way of doing something this hacky), but it requires descending into
   something that I like to call "`ptrace(2)` hell". To everyone that I met
   while debugging all of these issues, I apologise for talking your ear off
   about how much pain I was in.

So, time to descend into `ptrace(2)` hell. I hope you brought some popcorn.

[rootless]: /blog/rootless-containers-with-runc
[remainroot]: https://github.com/cyphar/remainroot

### Tracing a Process (and Failing) ###

So, the first step is to create a process and trace it. Naturally, this was far
harder than it needed to be. It turns out that `ptrace(2)` uses **signals** to
message the tracer about debugging events. That is such a horrible idea, I
really don't know what to say. If you're bored, read through the `BUGS` section
in the man page for `ptrace(2)`. It's a pretty good read, if you're not trying
to use the damn thing.

So, there are two (actually three, but we don't care about the third) ways of
attaching a process as a _tracer_ for another process (the _tracee_):

1. `ptrace(PTRACE_ME, 0, NULL, NULL)` will implicitly make the parent process
   the tracer of the current process. This is all done without any consent of
   the parent process (it took me a while to figure this out, but these two
   methods are completely separate and shouldn't **ever** be mixed).

2. `ptrace(PTRACE_ATTACH, pid, NULL, NULL)` will make the current process the
   tracer of `pid`. If `pid` was already a tracee, this call will fail.

It should be noted that none of these techniques are instantaneous, and so
you'll need to know about `ptrace(2)` internals in order to use them. Luckily
this bit of black magic *is* in the man page. To skip forward a bit, each time
that you do `ptrace(PTRACE_SYSCALL, pid, NULL, NULL)` you take the current
process from a "stop" state to a "run" state. So if you use `SIGSTOP` on the
process, the effect will be magically reverted once you try to do anything with
the process. Lovely.

The upshot is that if you want to create a new process and then make it
traceable (nicely) by the parent, you'll need to do this.

```language-c
#define die(...) \
	do { \
		fprintf(stderr, "[E:%s] ", __progname); \
		fprintf(stderr, __VA_ARGS__); \
		fprintf(stderr, "\n"); \
		exit(1); \
	} while(0)

static void tracee(int argc, char **argv)
{
	if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) < 0)
		die("child: ptrace(traceme) failed: %m");

	/* Make sure tracer starts tracing us. */
	if (raise(SIGSTOP))
		die("child: raise(SIGSTOP) failed: %m");

	/* Start the process. */
	execvp(argv[0], argv);

	/* Should never be reached. */
	die("tracee start failed: %m");
}

static void tracer(pid_t pid)
{
	int status = 0;

	/* Wait for child to be ready for us to attach. */
	if (waitpid(pid, &status, 0) < 0)
		die("waitpid failed: %m");
	if (!WIFSTOPPED(status) || WSTOPSIG(status) != SIGSTOP) {
		kill(pid, SIGKILL);
		die("tracer: unexpected wait status: %x", status);
	}
	/* Set ptrace options here if you want to. */

	/*
	 * Note that none of the above code actually explicitly states that
	 * they want to trace a process. That is not a mistake, it's the
	 * ptrace API (but it's very easy to confuse the two).
	 */

	 /* At this point we can safely use PTRACE_SYSCALL. */
}

/* (argc, argv) are for the child process we're going to trace. */
void shim_ptrace(int argc, char **argv)
{
	pid_t pid = fork();
	if (pid < 0)
		die("couldn't fork: %m");
	else if (pid == 0)
		tracee(argc, argv);
	else
		tracer(pid);

	die("should never be reached");
}
```

If you don't use `raise(SIGSTOP)` then you have a race condition against
`execve` and the the process being put into a "stop" state by the
parent. I'm not really sure why `ptrace(TRACE_ME, 0, NULL, NULL)` doesn't
do that, since I can't think of a case where you wouldn't want to do
that.

After that, you're ready to trace syscalls. You always use `waitpid(2)`
to wait for the process to hit a syscall. This fact will be important
later.

### Assembly at a Distance ###

`ptrace(2)` is incredibly odd, in that it feels like you're writing
assembly that operates on a distant purpose. For example, `ptrace(2)`
exposes all of the CPU registers on the current architecture. If you
want to get any information from the process, you're going to need to
essentially write assembly code. In C. Using `ptrace(2)`.

In general, this isn't _too_ bad. Of course, the documentation doesn't
tell you the right header to `#include` in order to get the definition
of the magical register macros. But hey, that's part of the fun! As
another fun kick, they also tell you that another structure exposed by
the kernel (`struct user`) even though it is exposed by the same body of
code that exposes the `ptrace(2)` API. Some questions are best not
asked.

> **NOTES**
> 	The layout of the contents of memory and the USER area are quite
> 	operating-system- and architecture-specific.  The offset
> 	supplied, and the data returned, might not entirely match with
> 	the definition of struct user.

Anyway, ignoring all of that confusion the API is not _that_ bad. You
can just do the following in order to get any argument of a syscall
(this will only work if you're in a syscall entry).

```language-c
/* This is all for amd64. */
#include <sys/reg.h>

/* Gets the syscall number. */
long ptrace_syscall(pid_t pid)
{
	return ptrace(PTRACE_PEEKUSER, pid, sizeof(long)*ORIG_RAX);
}

/* Gets any of the other arguments (I refuse to deal with stack-based syscalls). */
uintptr_t ptrace_argument(pid_t pid, int arg)
{
	int reg = 0;
	switch (arg) {
		/* %rdi, %rsi, %rdx, %rcx, %r8 and %r9 */
		case 0:
			reg = RDI;
			break;
		case 1:
			reg = RSI;
			break;
		case 2:
			reg = RDX;
			break;
		case 3:
			reg = R10;
			break;
		case 4:
			reg = R8;
			break;
		case 5:
			reg = R9;
			break;
	}

	return ptrace(PTRACE_PEEKUSER, pid, sizeof(long) * reg, NULL);
}
```

Why is it `sizeof(long)`? Because of `ptrace(2)` internals. You're
essentially probing into something like `struct user` for the current
state of the program. However, as mentioned before it isn't necessarily
actually `struct user`.

### Entry and Exit ###

It turns out that `ptrace(PTRACE_SYSCALL, 0, NULL, NULL)` doesn't really
have any semantic information for syscalls. In particular, the entry and
exit from a syscall are separate `ptrace(2)` events (which are
**indistinguishable** from each other so you need to keep track
yourself). It also means that you'll have to keep track of the syscall
number and arguments yourself.

### `fork` ###

The section on `fork(2)`-related options is quite benign. It just
mentions that you can use `PTRACE_SETOPTIONS` to enable certain features
of `ptrace`. For example, you can tell `ptrace(2)` to automatically
start tracing any `fork(2)`ed processes:

> `PTRACE_O_TRACECLONE` (since Linux 2.5.46)
>	Stop  the  tracee  at  the  next clone(2) and automatically start
>	tracing the newly cloned process, which will start with a SIGSTOP,
> 	or PTRACE_EVENT_STOP if PTRACE_SEIZE was used.  A waitpid(2) by the
> 	tracer will return a status value such that
>
> 	  status>>8 == (SIGTRAP | (PTRACE_EVENT_CLONE<<8))
>
> 	The PID of the new process can be retrieved with
> 	PTRACE_GETEVENTMSG.
>
> 	This option may not catch clone(2) calls in all cases.  If the
> 	tracee calls clone(2) with the CLONE_VFORK flag, PTRACE_EVENT_VFORK
> 	will be delivered instead if PTRACE_O_TRACEVFORK is set; otherwise
> 	if the  tracee calls clone(2) with the exit signal set to SIGCHLD,
> 	PTRACE_EVENT_FORK will be delivered if PTRACE_O_TRACEFORK is set.

Of course, this is actually quite a bit more complicated. First of all,
the documentation doesn't mention that the event is actually only sent
on the **syscall exit**. So you need to do all of your checks after
that. In addition, this documentation has actually glossed over an
**incredibly** important piece of information.

Once you have more than one process to trace, you need to figure out a
way to use `waitpid(2)` to wait for all of the processes. Something that
I hinted at earlier is that the fact that `waitpid(2)` is used to wait
for syscalls to be hit by a tracee tells you a lot about `ptrace(2)`
internals. If you read the `waitpid(2)` man page (this isn't ever
mentioned in the `ptrace(2)` man page even though it massively changes
the semantics of process forking):

> [`waitpid(2)` is] used to wait for state changes in a child of the
> calling process, and obtain information about the child whose state
> has changed.

What this means (when you read the section on `PTRACE_O_TRACECLONE`) is
that using that flag and all of the related flags will make **every
forked tracee process a pseudo-child of the tracer**. This is _hinted_
towards in the `ptrace(2)` man page, but it doesn't ever actually say
this bit of oddness intentionally.

> Setting the WCONTINUED flag when calling waitpid(2) is not
> recommended: the "continued" state is per-process and consuming it can
> confuse the **real parent** of the tracee. [emphasis added]

The use of the phrase "real parent" hints toward the fact that actually
the tracee doesn't become a "real" child of the tracer. It's just
another odd API quirk, where `waitpid(2)` magically works for traced
processes even though they actually aren't the child of the process. So
that's lovely. Oh, and if you're surprised by the use of the word
"confuse" in a man page don't worry, there's much more dubious language
in the rest of the documentation.

Anyway, all of this means that you can actually wait for all of your
`ptrace(2)`d children like so:

```language-c
pid = waitpid(-1, &status, 0);
if (pid < 0)
	die("waitpid failed: %m");
```

You should note that this means that you could possibly get a different
`pid` after you intercept a syscall *entry*. As I mentioned before,
the two states are entirely **indistinguishable** so you'll need to do
something like keep a hashmap of what state each child process is in.
It's really not that pretty, but I personally needed to do that anyway.
You'll also need to make your tracing loop essentially a coroutine as a
result.

### The Result ###

While all of that might not sound _that_ bad, it did take me a full week
to figure out all of the quirks. I also played around with `autoconf`
for a while as well. The less that's said about that experience, the
better (it was very not good).

If you want to use this tool, you can get the source from [the
repo][remainroot]. It's all free software, so have at it. My plan is for
people to use this in conjunction with [rootless containers][rootless].

[rootless]: /blog/rootless-containers-with-runc
[remainroot]: https://github.com/cyphar/remainroot
