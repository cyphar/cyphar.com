title: Dockerinit and Dead Code
author: Aleksa Sarai
published: 2016-01-21 17:30:00
updated: 2016-01-21 17:30:00
description: >
  After running into insane amounts of very weird issues with `gccgo` with Docker,
  some of which were actual compiler bugs, someone on my team at SUSE asked the
  very pertinent question "just exactly what is dockerinit, and why are we packaging
  it?". I've since written a patch to remove it, but I thought I'd take the time
  to talk about `dockerinit` and more generally dead code (or more importantly,
  code that won't die).
tags:
  - docker
  - free software
  - programming
  - suse

The one thing that separates dead code from other types of code is that it doesn't
(or more correctly, shouldn't) cause bugs. Like vestigial organs, you don't lose
much by having dead code. However, what it does cause is nothing but confusion.
Most developers assume the person who wrote the software knew what they were doing
at the time (okay, that's probably a bit too strong, maybe they assume the person
at least thought about what they were doing). The point is, a developer that is
new to a project won't assume that any chunk of code is dead code. All code "must
have a purpose", which is why it is dangerous to have dead code lying around in
projects. Not to mention that the "developer new to the project" might be you in
a few months after you've come back from doing something else.

Dead code increases confusion, and `dockerinit` is a perfect example of this. It
is such an old piece of code that has survived all of the large changes in Docker,
and has been part of Docker since `0.0.3` (it was introduced in [this commit][dockerinit]).
If you're running Docker on any modern distribution, you'll find this binary
tucked away in somewhere like `/usr/lib/docker/dockerinit`. It's been there since
February 2013, and it hasn't been used since everyone started using the `native`
execdriver (known as [`libcontainer`][libcontainer], or [`runc`][runc] to her
friends).

While technically LXC support hasn't been removed until `1.10` is released, it's
a well-known fact that using LXC with Docker should be filed under "exceptionally
bad idea that should never be a thing you do". The `native` execdriver came out
in `0.10` (early 2014) and has been the execdriver of choice since its initial
release. Thus, this code hasn't *really* been used for about 2 years, which is
quite a long time for a project that became free software only 3 years ago.

[dockerinit]: https://github.com/docker/docker/commit/58a22942602f9035a1ed44c65ae2c501420600a3
[libcontainer]: https://github.com/docker/libcontainer
[runc]: https://github.com/opencontainers/runc

### LXC and libcontainer ###

LXC is *allegedly* an initialism for "Linux Containers" (hint: it isn't). At the
time it was the only container runtime, and it was quite rudimentary. You could
define a container, start the container, put more processes in the container, etc.
All of this was managed by a bunch of small C programs (like `lxc-start`,
`lxc-stop`, etc), and you had to write very complicated configuration files in
order to set up a container properly (it didn't have safe defaults, or any defaults
at all). It didn't manage any of the packaging of containers, management of how
container metadata should be stored, or any other higher-level features Docker
offers.

To be fair, that was LXC's intention. They wanted to create a low-level and very
configurable runtime for containers, and left all of the other stuff up to the
users. Unfortunately, when Docker came along and had to use LXC, this made things
quite difficult. Scattered throughout the `git` history are references to
"horrible hacks for LXC", of which there are a fair number. `dockerinit` is a
perfect example of one of these hacks. But we'll get to that later.

`libcontainer` was Docker's response to LXC, after having wrangled with it for
almost a year at that point. The big issue that Docker had with using LXC was that
it was hard to work with in an automated fashion (such as required by Docker)
without requiring the user to answer a bunch of really detail questions. The
configuration for LXC is just a stream of configuration options which you have
to specify in **excruciating** detail. Any misconfiguration could cause issues
with security or stability. This was clearly an issue, and the Docker community
resolved to fix it before Docker was declared "production-ready" in `1.0.0`.

In many ways, `libcontainer` is a Docker-aware LXC. It is essentially a set of
language bindings that take very minimal `JSON` configuration payloads and deal
with all of the nastiness of actually creating a container. This allowed Docker
to have control over what features would be supported and how it would fit into
Docker.

### `dockerinit` ###

As I mentioned above, the LXC execdriver was well known for the amount of hacks
required to get Docker to run containers. After all of the horrid configuration
templating and slaying of kittens, Docker had nothing left up its sleeves to do
the final configuration steps required for LXC. This includes small things like
"setting up networking" and "changing the user", since LXC couldn't do it in a
way that Docker felt was necessary.

`dockerinit` was a hack to solve this problem. Rather than starting the process
the user wanted, Docker would first start `dockerinit` in the container which
would "clean the environment" and then actually start the container process. At
first, `dockerinit` was just a function inside the `docker` binary which would
be executed if the execname was `/sbin/init`. Why `/sbin/init`? Because Docker
would bind-mount itself into `/sbin/init` inside the container so it could execute
itself. This caused quite a few bugs with Ubuntu and Debian, so they resolved to
bind-mount to a path that wasn't a real binary -- like `/.dockerinit`.

After a while, people were annoyed with there being a three-fold use to the
`docker` binary. It was the client, the server and `dockerinit`. So, `dockerinit`
was separated into a separate binary, but it was vital that the two binaries be
built from the same codebase. So they did a bunch of things to try to fix this
(embedding the `sha1sum` of the `dockerinit` binary inside the `docker` binary
during compile-time and checking it at runtime was the weirdest). In addition,
packagers were *warned* that **you must always package `dockerinit` and `docker`
as one thing**.

Over time, the amount of code in `dockerinit` dwindled. The transient file
`/.dockerinit` stayed in every running container for the next few years, and
some people even used it to figure out whether they were in a container. In
general, the code was dead (except in the rare case when LXC was used, which
hasn't been common in a long time). But the code lay in the source tree under
the name `dockerinit/dockerinit.go`, with references to it scattered around.

The pull request I've opened to actually remove `dockerinit`, once and for all,
can be found [here][purge-dockerinit]. Hopefully it'll be merged for the release
after `1.10`, and we'll be able to finally say goodbye to this old hack. I'm kinda
annoyed that the patch isn't all `-`s, but I needed to update some comments. I
haven't actually added any instructions in that pull request, which just feels
great.

[purge-dockerinit]: https://github.com/docker/docker/pull/19490

### The Actual Point ###

So, why bring up this weirdly specific hack which I'm hoping to get removed soon?
Surely if the code is going to be gone, there's nothing to be said. Well, I think
there's something to be learned here about software and dead code. Software is
odd in the fact that running software doesn't generate heat or attract mass or
make a noise. So vestigial components of software usually go unnoticed, and that's
bad because people who don't know about the inner workings of the code won't
realise that a particular part is dead code and just needs to be removed.

But while dead code doesn't cause any problems when your software has already
been packaged and arrives on a silver platter, the maintainers are really the ones
who have to deal with the code. While dead code doesn't cause bugs, it may cause
dependencies or other horrible issues.

So, if you're maintaining or contributing to a large project, take a step back
and ask yourself "is there anything here that we don't actually need". Because
dead code is much more frustrating to deal with than just removing it.
