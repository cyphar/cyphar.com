title: Getting into Linux Kernel Development
author: Aleksa Sarai
published: 2015-07-15 14:20:00
updated: 2015-09-03 12:00:00
description: >
  I've been interested in kernel development for a *long* time, and recently got
  some patches merged into the Linux kernel. Here are my experiences about the
  process of kernel development and what newbies can do to get started.
tags:
  - linux
  - kernel
  - c
  - open source
  - programming

I don't know about you, but I've always found the idea of kernel programming to
be a mysterious and fairly esoteric skill. Its importance and complexity cannot
be overstated, but at the same time I considered kernel and "regular" user-space
programming to be two very separate skills with little overlap. More than
anything else, I was worried about just jumping into kernel development because
I felt it would be overwhelming. So here are a few tips I wish I had when I
started.

I've recently had [some][patches-1] [patches][patches-2] merged into the Linux
kernel, and thought it might be interesting to describe what I learnt from this
brief dip into kernel development and how someone who is new to it might go
about getting into this space.

[patches-1]: https://lkml.org/lkml/2015/6/5/857
[patches-2]: https://lkml.org/lkml/2015/6/9/320

### A Bit of Backstory ###
Over the past year or so, I've been fascinated in reading kernel code. It all
went over my head, of course, but I thought it was interesting seeing how the
syscalls we use every day were implemented. I'd been pining for a good enough
excuse to dip my toe into this weird and wonderful world of which I knew nothing
about.

As luck would have it, I stumbled upon a feature request in libcontainer (now
part of runC, and so the bug report has been deleted), and thought to myself
"well, it's now or never". The bug report stated that "it would be nice if we
could limit the number of PIDs in a cgroup", and I thought it would be a fairly
easy project to do. "I'm quite a dab hand at C, how hard could it be?". The bug
report linked to an [old patchset (circa 2011)][rlimit-patchset] which would
obviously need quite a bit of work to be brought up to date with the current
state of the kernel. It turned out that it needed a complete rewrite, because of
how much the internal APIs had changed in that time (and the fact that some of
the hooks it depended on were removed because they were incredibly racy).

So, with all that in mind, I was ready to start writing a new version of the
same patchset.

[rlimit-patchset]: https://lkml.org/lkml/2011/6/19/170

### Advice for Getting Started ###
The easiest way to get started (from what I've heard) is to find a driver that
doesn't work properly or look for some easy-looking bug report. I wouldn't
recommend going about getting into the Linux kernel the way I did, I was thrown
quite quickly into the deep end with no documentation in sight.

It's also a good idea to find someone on IRC (`##kernel` on
[freenode][freenode-irc]), or just email maintainers to ask them about what the
problem you want to solve is (or even ask them if they have any bugs that you
might be able to fix) and how to go about solving it. Maintainers are people
too, so don't spam them if they don't reply within 15 minutes of your first
email.

[freenode-irc]: https://freenode.net/

### Ever-Changing APIs ###
One of the things that Linux prides itself on is the fact that it has a
completely stable ABI. This is an interesting contrast to the fact that there is
no stable internal API inside the kernel. This, of course, makes perfect sense
in the context of the kernel, but it does make reviving old patchsets nigh
impossible without a complete rewrite.

Although, doing complete rewrites of old patchsets is actually quite a good
thing. It means that you get some pointers as to *where in the kernel* your
changes need to be made (without having to do a manual traceback from a syscall
or trying to `grep` the source tree), but it also doesn't spoon feed you. You
need to figure out which kernel APIs you need to leverage and which locking
semantics you need to obey.

Unfortunately, because of the lack of a stable API, this means that
documentation about things like locking semantics and current APIs is basically
non-existent. If you're okay with asking people about what would be the best way
to do something, then you'll be set (Google won't really help you here). If you
aren't good with asking questions, you might be able to take advantage of some
of the debugging tools Linux has available. Things like `lockdep` and
`PROVE_RCU` are very useful for making sure you're following valid locking
semantics. But ultimately, you'll need to ask someone a question eventually, you
might as well start getting used to emailing around and asking people questions.

### Coding Style ###
Make sure you follow the [Linux kernel coding style][coding-style]. Most
maintainers will not even look at the contents of your patch if the coding style
is not followed. Sure, you might not agree with some of the points (the 8 column
tabs sort of annoy me every once in a while, and the 80 character limit is
really annoying) but it's their choice what coding style they use for their
projects. Sometimes you've got to live and let live.

[coding-style]: https://www.kernel.org/doc/Documentation/CodingStyle

### Iterative Development ###
Once you've got the first version of your patch working and have tested it on
your machine (and hopefully some more machines), you're ready to send it out to
the mailing list. There are scripts to tell you who you should `Cc:` your
patches to, and I'd recommend using them. If you're sending patchsets, I prefer
to just send email using `git send-email`, it's quick and dirty and works pretty
well.

A very important thing to make sure you do when you start sending patchsets is
explaining why your patch is so important, how it is beneficial to users, why
your method of solving the problem is the best, why the problem is a real
problem that needs to be solved in the kernel, etc. If you don't make an
argument for your patch to be merged, it won't be merged (you're really the only
one who is completely behind your patch).

The first thing that'll happen when you send the first version of your patchset
to the mailing list is that it will be outright rejected. It's very uncommon
that a patchset is merged immediately. Maybe you could've done something better,
maybe you didn't grab some locks in the right order, maybe you missed a race
condition, etc. It's important not to be dissuaded when your patch gets
rejected. It happens to everyone, just take the feedback you got and move on.
Sometimes maintainers will reject a patch for very minor things (bad formatting
or other such non-functional changes). It's important to take all of their
considerations on board (unless you *really* disagree with them, in which case
you escalate the issue to some other maintainers or people higher-up in the food
chain), since they probably know more about the code you're changing than you
do.

After the first round of nits have been fixed, you send out the patches again
with your changes pointed out in the cover letter. Then you get some more
feedback, you update your code or discuss it, and the cycle continues. Depending
on how complicated the issue is, it may take up to 10 versions to get a version
that is good enough to be merged into the kernel. At that point, it's out of
your hands. Your patch will be merged into a maintainer's tree, and then that
maintainer's tree will be merged into Linus' tree at some point in the future
(probably the next `-rc1`).

### Why so Complicated? ###
Kernel code is widely considered to be very complicated code. There are whole
bunch of weird APIs that you call out to, with global variables and macros
thrown around everywhere. Trying to figure out which code gets executed from a
given syscall is quite complicated. It gets even more complicated when you
consider the fact that the Linux kernel is basically one of the largest
multi-threaded programs in existence. Lots of attention has to be paid to
potential race conditions, and quite a lot of this is undocumented.

For me, the easiest way to get to understanding code is to just read it. Dive in
feet first, read a section of code and then read the code of all of the
functions it calls out to. Repeat until you've read all of the code that you
can. By doing this process for enough of the sections of the kernel, you start
getting an idea about how the kernel functions, what kind of APIs to use where,
etc.

Linux's complexity doesn't necessarily come from the fact that it is a kernel
(really, kernel space just has a few different rules than user space and you can
get used to that idea quite quickly), rather from the fact that it is an
*extraordinarily* large project with thousands of contributors every release.

### All's Well That Ends Well ###
I got [an email][merged] this morning from Tejun Heo (the maintainer of control
groups in the kernel) that my patches to add the `pids` cgroup have been merged
into his tree. This process took me several long months to reach, but that's
mainly because of my lack of experience with kernel development. A lot of this
stuff is still new to me, and I'm still learning a lot more about the kernel
every day by just reading code and trying to fix bugs.

As of [8bdc69b764013a9b5ebeef7df8f314f1066c5d79][linus] all of the changes I
refer to in this blog post have been merged into Linus' tree during the 4.3
merge window.

So, all's well that ends well. Don't be afraid of diving into kernel development
feet first. Books won't help you (they're all out of date), but reading the code
will. As an old man once told me, "Read the source, Luke!"

[merged]: https://lkml.org/lkml/2015/7/14/711
[linus]: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8bdc69b764013a9b5ebeef7df8f314f1066c5d79
