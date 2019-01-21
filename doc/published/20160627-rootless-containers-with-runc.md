title: Rootless Containers with runC
author: Aleksa Sarai
published: 2016-06-27 21:05:00
updated: 2016-06-27 17:00:00
short_description: >
  I've been working on being able to run fully unprivileged (rootless)
  containers within runc for a while, and this is the fruit of my efforts -- it
  all seems to work now and is on its way to getting merged.
description: >
  There has been a lot of work within the runC community recently to get proper
  "rootless containers". I've been working on this for a couple of months now,
  and it looks like it's ready. This will be the topic of my talk at
  ContainerCon Japan 2016.
tags:
  - containers
  - free software
  - runc
  - suse

runC is the canonical [Open Containers Initiative (OCI)][oci] runtime
implementation. It came from the container runtime that Docker developed
[to replace LXC within Docker a few years ago][libcontainer-blog],
called [`libcontainer`][libcontainer] (not to be confused with
Virtuozzo's [`libct`][libct]). Currently runC is used by Docker (through
[containerd][containerd]) to run containers. If you're using Docker 1.11
or later, you're using runC explicitly. If you're using Docker 1.8 or
later, you're using `libcontainer` code that was developed as part of
runC. All of this means that runC is a very widely used container
runtime, though many people are not using it to its full potential. It
has support for things that the Docker engine does not (such as
checkpoint and restore of containers). Many features that are developed
in runC today won't be available in Docker for a fairly long while.

All of that being said, let's talk about what's been cooking in the runC
kitchen.

[oci]: https://www.opencontainers.org/
[libcontainer-blog]: https://blog.docker.com/2014/03/docker-0-9-introducing-execution-drivers-and-libcontainer/
[libcontainer]: https://github.com/docker/libcontainer
[libct]: https://github.com/xemul/libct
[containerd]: https://github.com/docker/containerd

### Problem to be Solved ####

First, a quick introduction into what "rootless containers" are. A
rootless container is a container that was entirely set up without *any*
privileges. This includes things like installing PAM modules or starting
privileged daemons. Why is this important? Surely this doesn't matter to
people who want to use containers (we control our machines after all,
which was the point of the Free Software movement). Unfortunately,
that's not always the case. A good example is research faculties inside
universities, and so here follows a hypothetical researcher called
James and a system administrator called Susan.

James decided to write his analysis scripts in Python 3, using some
libraries that are not available for Python 2. Unfortunately, his
faculty's computing cluster only supports Python 2 and Susan doesn't
want to deal with supporting a different Python version. But James knows
about containers, and writes a Dockerfile for his analysis scripts. But
Susan also won't install Docker, because Docker [doesn't have any
builtin ACLs][acl] and thus will allow anyone to get root on the
machine. Susan doesn't want that to happen, because it would violate the
university's policy on privileged access to university resources.

So what should James do? Well, James could try to compile Python 3 and
all of the necessary dependencies on the computing cluster. If you've
ever had to do that, you'll know that it doesn't end well. And it
doesn't. James goes down the rabbit hole and emerges trying to modify an
`.so` library to work with the older version of `glibc` that is running
on the server. It doesn't work, and he decides that he'll just run his
analysis scripts on his small laptop instead.

So, what James clearly needed was a way to run containers without
**any** privileges. There must be no step where James would have to ask
Susan to do anything on his behalf. And to be fair, Susan is
understandably concerned about allowing researches to access the Docker
daemon (it's a part of the security model of Docker that anyone with
access to `docker.sock` has full access to your machine). So there must
be a solution. And there is -- it's called rootless containers.

Oh, and the researcher I called "James"? That was me about 6 months ago.
I've also gotten emails from people at CERN that talk about about
similar issues they're having with the computing cluster used for the
Large Hadron Collider, so this issue isn't just isolated to one faculty
at my university.

[acl]: https://docs.docker.com/engine/extend/plugins_authorization/

### Unprivileged User Namespaces ###

Since Linux 3.8, it has been possible to create unprivileged user
namespaces. User namespaces are different to the other namespaces, in
that they change the privilege model that the process sees. Some
operations require privileges in the root user namespace, others only
require it in the process's namespace. This means that having the
ability to create unprivileged user namespaces results in users being
able to gain certain privileges (with many caveats). The important code
looks like this:

```language-c
/* As any user. */
unshare(CLONE_NEWUSER);
/* We now have the full capability set in a new user namespace. */
```
There are some additional steps that need to be done in order for the
unprivileged user namespace to be useful. You have to disable the
`setgroups(2)` syscall, and then map your own user (and **only** your
own user) into the namespace. Every other namespace pins what user
namespace they were created in, and this information is used to
determine what privileges an operation requires. So, after creating an
unprivileged user namespace you just have to create all of the other
namespaces you want to use and set up the container.

It should be noted that this feature would not be considered strictly
safe until Linux 3.19. There were many different semantic and security
discussions that happened after Linux 3.8, including the `setgroups(2)`
syscall that I mentioned. Ultimately, as a user of runC you don't really
care about that. But as an administrator, you might have strong views on
whether or not user namespaces are safe for general use. I don't have a
dog in that fight, I'm just creating some cool technology on top of the
kernel technology.

### Current State ###

So, what works right now? Currently all of the basic functionality of
runC works with rootless containers (and where applicable, it works with
with both privileged and unprivileged users). The current checklist is
visible in the [pull request][rootless-pr]. Please refrain from
commenting on the pull request unless you have something constructive to
add (please use the reactions provided by GitHub if you want to `:+1:`
the issue). Unfortunately, there are still some outstanding issues that
need to be resolved before I feel that rootless containers are ready to
be merged, but we'll get into those in a second.

Currently, you can do the following operations with rootless containers.
There are some exceptions that I'll get into later.

* `runc create`
* `runc delete`
* `runc exec`
* `runc kill`
* `runc list`
* `runc run`
* `runc spec`
* `runc state`

The following operations have been entirely disabled, since I'm either
unsure about whether or not they'll work properly or they cannot work in
most configurations. We'll get back to those later as well.

* `runc checkpoint`
* `runc events`
* `runc pause`
* `runc restore`
* `runc resume`
* `runc update`

[rootless-pr]: https://github.com/opencontainers/runc/pull/774

### Consoles and Pain ###

<!-- TODO: Fix this up. -->

There has been a long-standing bug within libcontainer with regards to
console handling. In order to create a new pseudo TTY, you need to open
the magical file `/dev/ptmx` and then do a few `ioctl(2)`s on it.
However, all of this handling is done in the **host** within
libcontainer. `runc run` "works" because it uses `/dev/ptmx` and is all
managed internally. However, if you want to detach a container (or use
the [new create-start semantics][create-start] with a terminal) then
you're going to run into some issues. You're going to have to write a
[wrapper around runC][console-wrapper] in order to use it properly. And
it starts with this little thing called `devpts` and Linus' devotion to
backwards compatibility.

A long time ago, it was decided that it should be possible for different
mount namespaces to see different sets of `pty`s such that a privileged
user in a particular mount namespace won't be able to manipulate another
namespace's consoles. This is important for security reasons, as users
that can read or write to your console can do quite a lot of nasty
things. Thus, a new option was added to `devpts` called `newinstance`.
If you give that option, then a new instance of the `pts` "namespace" is
created where all `pty`s created in that namespace are only visible in
that namespace. However, most GNU/Linux distributions don't ship with
that option enabled for the host's `devpts` mount. If the option is not
set, then the semantics will mirror the old semantics (one set of `pty`s
visible to everyone). In addition, the file `/dev/pts/ptmx` is only
usable by `root` on the host (it has file mode `0000`).

[create-start]: https://github.com/opencontainers/runc/pull/827
[console-wrapper]: https://gist.github.com/cyphar/0275b174f35e29cb1e2190db1f68ca5c

### Unmapped Users and Oddness ###

While everything works fine as "root" inside an unprivileged user
namespace, the fact that you can only map your current user (and there's
a lot of additional restrictions added by the kernel) causes programs to
act strangely. The most obvious example of this is package managers like
`apt`:

```language-txt
% runc run ubuntu
# apt-get update
E: setgroups 65534 failed - setgroups (1: Operation not permitted)
E: setegid 65534 failed - setegid (22: Invalid argument)
E: seteuid 104 failed - seteuid (22: Invalid argument)
E: setgroups 0 failed - setgroups (1: Operation not permitted)
Reading package lists... Done
W: chown to _apt:root of directory /var/lib/apt/lists/partial failed - SetupAPTPartialDirectory (22: Invalid argument)
E: setgroups 65534 failed - setgroups (1: Operation not permitted)
E: setegid 65534 failed - setegid (22: Invalid argument)
E: seteuid 104 failed - seteuid (22: Invalid argument)
E: setgroups 0 failed - setgroups (1: Operation not permitted)
E: Method gave invalid 400 URI Failure message: Failed to setgroups - setgroups (1: Operation not permitted)
E: Method http has died unexpectedly!
E: Sub-process http returned an error code (112)
# apt-get install python
Reading package lists... Done
Building dependency tree
Reading state information... Done
E: Unable to locate package python
#
```

The issue here is that `apt` is trying to drop privileges, even though
it doesn't have any! Unfortunately, because of some regrettable
decisions made by the implementors of user namespaces, a process inside
a user namespace will be exposed to the oddness of unmapped uids and
gids. You can both be in an unmapped group, but also have no permissions
to a file with the same gid. In addition, `setgroups(2)` is disabled but
you can see unmapped supplementary groups and you cannot leave them.
Interestingly, `zypper` (which is openSUSE's package manager) doesn't
suffer from this problem (though some packages have scripts that try to
change the ownership of files).

Unfortunately, there isn't a way to fix this from the kernel as it is
now baked into the kernel ABI (and Linus doesn't take kindly to people
trying to fix the ABI). So, I had to work on a different solution. The
full story will be in [another blog post][remainroot-blog], but you can
[take a look at the code][remainroot].

[remainroot-blog]:
[remainroot]: https://github.com/cyphar/remainroot

### Networking ###

Currently creating a new network namespace will drop you into an
environment with no network devices except `lo`. This means that you
won't have a network connection inside a rootless container that uses
the network namespace. In order to create a bridge between two
namespaces you need `CAP_NET_ADMIN` in both pinned user namespaces
(including the host user namespace which is where your internet comes
from in the host). You can fix this by just not using the network
namespace. While this means that you can't use `iptables(8)` it also
means that you now have a network connection. There's no security issue
with not using a namespace, since we never have any privileges when
setting up a rootless container.

There has apparently been some discussion upstream about solving this
problem, but it's quite a hard problem to solve. FreeBSD had a similar
issue with the Jails implementation and it took a very long time to
figure out how to securely expand network namespacing so that it could
be secure and useful.

### cgroups ###

Now for the big question: can we use cgroups in rootless containers?
Unfortunately, in the general case it is not currently possible use
cgroups in rootless containers. The reason for this is that the cgroup
API uses a virtual filesystem, and the permissions model is based
exclusively around that idea. There was the recent addition of a [cgroup
namespace][cgroupns], but it is not relevant to rootless containers.

However, it makes sense that (at least for [cgroupv2][cgroupv2]) a
process inside a particular cgroup should be allowed to manage its own
resources (with the obvious caveat that it must obey the resource
restrictions assigned to it). Unfortunately, currently there is no
support for such a system within the kernel. I [sent some patches to
LKML][unprivcgroup] and they were rejected on the grounds that the
maintainer doesn't want the cgroup API to deviate too far from VFS. I
don't agree with that, but I'm thinking about how we could implement
this without needing to break the VFS API.

It should be noted that we could, in principle, use cgroups if we happen
to have the right permissions. This is something that a colleague of
mine, [Christian Brauner][chb], was helping me implement. You can see
the current state of that [here][chb-cgroup].

Once we have a way to use cgroups with the same constraints as the rest
of the rootless containers implementation, we will be able to re-enable
so many of the other operations that we had to disable (including
`pause` and `resume` which are very useful).

[cgroupns]: https://www.phoronix.com/scan.php?page=news_item&px=CGroup-Namespaces-Linux-4.6
[cgroupv2]: https://www.kernel.org/doc/Documentation/cgroup-v2.txt
[unprivcgroup]: http://marc.info/?l=linux-kernel&m=146319604331859&w=2
[chb]: https://github.com/brauner
[chb-cgroup]: https://github.com/cyphar/runc/pull/1

### Miscellaneous ###

Apart from the big issues I outlined above, there are a few remaining
issues. These are mainly trivial things that shouldn't take too long to
fix, I just need to put in the time.

Currently, `runc ps` uses cgroups to get the list of processes in a
container. This is nice because it does `PID` translation for us.
Unfortunately, this also means that we can't use it within rootless
containers. Solving this requires a lot of messy engineering for very
little gain. Essentially you have to create an `AF_UNIX` socket, then
fork a process which will join the relevant namespaces in the container.
That process can then enumerate the PIDs and send them to the runC
process as ancillary data over the `AF_UNIX` socket. The `PID`s will be
translated and then we can carry on as before.

`checkpoint` and `restore` are currently disabled as a precautionary
measure. I haven't really used those features, and I'm unsure how well
they would deal with having a rootless container that has some
intricacies about how it is set up. The tool we use for the checkpoint
and restore of containers is [CRIU][criu]. CRIU 2.0 brought support for
[unprivileged checkpointing of processes][criu-2.0], and there are plans
to support unprivileged restore in the future. So currently this isn't a
*critical* thing to support.
