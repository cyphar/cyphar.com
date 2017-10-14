title: Debugging why `ping` was Broken in Docker Images
author: Aleksa Sarai
published: 2016-03-04 21:05:00
updated: 2016-12-20 19:20:00
description: >
  All complicated bugs start with the simplest of observations. I recently was
  assigned a bug on our openSUSE Docker images complaining that `ping` didn't
  work. After a couple of days of debugging, I was taken into a deep and dark
  world where ancient Unix concepts, esoteric filesystem features and new
  kernel privilege models culminate to produce this bug. Strap yourself in, this
  is going to be a fun ride.
tags:
  - suse
  - docker
  - kernel
  - kiwi
  - free software
  - bugs

Every once in a while you find a bug that just sucks you into a deep, dark hole
of weird things you wish you never knew about. I recently saw a fairly innocent
looking bug report which lead me down such a rabbit hole, and I thought I'd like
to share the experience with you.

### The Report ###

The [bug in question][bug-report] was quite simple, and looked like an unusual
bug (although similar bugs have been reported and fixed in Docker before). It
essentially reads as follows:

> If you try to use the openSUSE images, you'll find that ping doesn't work.
> You can reproduce this using the following steps: *[insert steps]*

The steps to reproduce it are fairly straightforward:

```language-text
% docker run -it opensuse:13.2 sh
sh-4.2# ping -c1 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.026 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.026/0.026/0.026/0.000 ms
sh-4.2# useradd user
sh-4.2# su user
sh-4.2$ ping -c1 127.0.0.1
ping: icmp open socket: Operation not permitted
```

The first thing to check is whether this is openSUSE specific. I could reproduce
this with Alpine Linux, Debian and a few other base images. Weirdly, Ubuntu didn't
appear to have this bug. But before we start tackling the actual bug, it's time
for a quick recap of the past 40 years of Unix history. A permission related
error tells us that something is very wrong in the animal brain.

[bug-report]: https://github.com/openSUSE/docker-containers-build/issues/8

### Unix Privilege Model ###

Most people agree that the Unix privilege model is a hold-over from an older
time. Concepts like "binding to a lower port requires root" are warts of the
original design of Unix. One of these historical warts is that the creation of
raw sockets, which is how `ping` sends ICMP packets, requires `root`. Thus,
in order to use `ping` you need to have the process run as root.

Now, I know what you're thinking. "But I don't need to be root in order to run
`ping`, what's going on here?" Hold up, Sparky. The history lesson isn't over
yet.

Very early in the development of the privilege model, it became clear that you
sometimes needed to grant a user the right to execute code that the user couldn't
modify as root. `passwd` is a great example: you need root in order to read and
modify `/etc/shadow`, but allowing the user to read and modify `/etc/shadow`
directly would be a security vulnerability. Thus, several special bits in file
modes were created (the `setuid` and `setgid`, allowing an executable file to be
executed as the owner's user and group respectively).

You probably knew all of the above, it's Unix 101. However, the story doesn't
end there. Several different Unixes have moved on from the antiquated, binary
root-or-nothing approach to priviliges. On Linux, this mechanism is known as
"capabilities" (there is a similar system with the same name which predate Linux's
on a few BSDs). Essentially, the concept of "UID 0" has been broken up into a
bitwise mask of a set of "capabilities" that a process can have (and another mask
that defines which of those capabilities can be inherited by children). Examples
of capabilities include things like `CAP_NET_BIND`, which allows you to bind to
low port numbers. The capability we're interested in with `ping` is `CAP_NET_RAW`.

This was all just to bring you up to speed with all of the stuff I recalled when
I took a look at this bug report. We'll return to this history in a minute.

### Where Did All the Capabilities Go? ###

When you start a Docker container, the "init" process has a certain capability
set by default. This isn't the full capability set, so root inside the container
doesn't have all the capabilities of real root. This explains why `ping` works
before switching users with `su` -- the shell has `CAP_NET_RAW` but `su` removes
all of the capabilities.

So, that all sounds fairly fine. However, if you think about it for a moment, why
does "`su` removing the capabilities" break ping? If you try to do the **exact**
same set of steps on your host, you'll find something like this:

```language-text
# ping -c1 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.031 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.031/0.031/0.031/0.000 ms
# su user
% ping -c1 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.033 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.033/0.033/0.033/0.000 ms
```

So, there appears to be a discontinuity between how my host and my container are
acting. Linux "containers" (scare quotes because the kernel doesn't actually
understand the concept of a "container") are **precisely** identical to normal
processes, the only real difference is what namespace they execute within (which
changes their percieved layout of the system). Since this was before 1.10 was
released, I'm not running with user namespaces so there should be no discontinuity
regarding permissions.

Just to double-check my sanity (I was thinking it was a bug in `su` at this point
for dropping capabilities it shouldn't), I decided to run `capsh` on both my
host and inside my container to compare what happens after `su`. Inside the
container:

```language-text
% docker run -it opensuse:13.2 sh
sh-4.2# zypper in libcap-progs
[...]
sh-4.2# capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap+eip
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
[...]
sh-4.2# su user
sh-4.2$ capsh --print
Current: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap+i
Bounding set =cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
[...]
```

Uhm, okay that's a bit weird. The capabilities aren't being dropped from the
"inheritable" set (note that there's a `+eip` at the end of the first output and
`+i` at the end of the second). But they are being dropped from the "effective"
(`+e`) and "permitted" (`+p`) sets. That's *basically* what we expected, the
capabilities are dropped when we do `su`. Now, if we try the same for our host,
we should see something different:

```language-text
# capsh --print
Current: = cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read+ep
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read
[...]
# su user
% capsh --print
Current: =
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read
[...]
```

... wait, what? `ping` works even though the `su`'d user doesn't have the right
capabilities! And if you try the same check for your own user (just using a
standard login shell), you'll see that you **never** had the capabilities needed
for `ping` to work:

```language-text
cyphar@majora :: ~ % capsh --print
Current: =
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read
[...]
```

At this point I'm thinking "what the hell is going on here?" Because this all
seemed quite unexpected. A couple more bits of debugging caused me more and more
confusion. For example, I tried copying the `ping` binary into the container --
maybe the code was different and I was grasping at straws here:

```language-text
% container=$(docker run -dit opensuse:13.2 sh)
% docker cp $(which ping) $container:$(which ping)
% docker attach $container
/ # su user
/ $ ping -c1 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.023 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.023/0.023/0.023/0.000 ms
```

Whoa. Okay, so maybe the code is different? After running `ldd`, I noticed an
interestingly named `libcap.so` ("cap" for "capability", not "pcap"). I then
tried to replace the version of `libcap.so` on the container with my host's
version:

```language-text
% container=$(docker run -dit opensuse:13.2 sh)
% docker cp -L /lib64/libcap.so.2 $container:/lib64/libcap.so.2
% docker attach $container
```

Okay, so that *doesn't* work. Maybe the code inside `ping` is different, but why
would it be? I was very confused. After a few hours of Googling, I decided to
take a look at how `ping` was packaged by openSUSE (you can find out by looking
in the [OBS][obs-ping]). I noticed a very peculiar line:

```language-text
%post
%set_permissions %{_bindir}/ping %{_bindir}/ping6
```

The `%set_permissions` is an `rpm` macro defined somewhere else. However, the name
gives you a hint as to what it does: it "sets the permissions of the binary". This
doesn't make sense, because in the `%install` section, they are using `install`
which can set permissions for them. Something seemed fishy, and searching for
`%set_permissions` gives you [a page on the openSUSE wiki about `rpm` macros][opensuse-macros].

> `%set_permissions` needs to be called in the `%post` script of packages that
> install files handled by `/etc/permissions.*`. The `permissions` package needs
> to be in `PreReq` so `chkstat` is guaranteed to be available at install time.
> The parameter is the name of the permissions config file of the package (usually
> identical to the package name).

Looking at the [OBS package for `permissions`][obs-permissions], and the [source
code][github-permissions], you find several permission profiles. After looking
through a few of them, I found `permissions.secure`, which had the following lines:

```language-text
#
# networking (need root for the privileged socket)
#
/usr/bin/ping                                           root:root         0755
 +capabilities cap_net_raw=ep
/usr/bin/ping6                                          root:root         0755
 +capabilities cap_net_raw=ep
```

Okay, so you can ... set capabilities on a file? How does that work? What the hell
is going on?

[obs-ping]: https://build.opensuse.org/package/view_file/network:utilities/iputils/iputils.spec?expand=1
[opensuse-macros]: https://en.opensuse.org/openSUSE:Packaging_Conventions_RPM_Macros#.25set_permissions
[obs-permissions]: https://build.opensuse.org/package/view_file/Base:System/permissions/permissions.spec?expand=1
[github-permissions]: https://github.com/openSUSE/permissions

### Extended Atrributes ###

Some time ago, a filesystem developer got bored and decided that classic (portable)
filesystem mode bits are too mainstream. They then created "extended attributes",
which are set of additional, non-portable file mode bits. This is traditionally
used to make files "immutable" or "invisible" or other seemingly odd features.

However, when capabilities were being designed, someone noticed that the new
concept of "sets of capabilities" didn't map well to a single-bit flag in the
file mode of an executable. They then decided to add "set capability flags" to
extended attributes. Naturally, since this is a very strong Linux-ism and doesn't
even work on all modern filesystems Linux supports, this can present some problems.

I didn't know this earlier to finding this bug, so maybe you made this leap
faster than me (in which case I apologise for dancing around the cause of the
issue, but I love a good twisting and turning story). The weird thing is what I
discovered later.

You can check the capabilities on a file using the following commands, if you
want to follow along on this journey:

```language-text
% getcap <file>
% setcap <caps> <file>
```

#### Who is Stripping the Damn Extended Attributes? ####

My first thought was that Docker was accidentally stripping these capability flags
from its images. This was a worrying thought, because depending on where in the
codebase the bug lay, it could cause issues from every Docker image being invalid
all the way through to all running Docker containers to be invalid. **Luckily**,
this isn't the case. Some rudimentary testing showed that Docker dealt with
extended attributes perfectly fine when creating, loading, saving, spawning,
pushing and pulling images. So clearly our issue is somewhere else.

I took a look at the **raw** image `tar` archives that we generate and
automatically package (or push to the Docker Hub), and it turns out that the
actual **images** are missing the extended attributes. The `tar` format supports
extended attributes perfectly fine (and Docker does too, as I tested earlier).
So it's clearly a problem with what we're using to generate the `tar` archives,
which is a tool known as [kiwi][kiwi].

This is as far as I got in the day or two I'd been working on this issue. I then
put it on the backburner (we had other things to worry about, which will be the
topic of their own blog post). We figured that it probably wasn't an issue with
kiwi, and that it's some issue with our packaging scripts. If it wasn't for what
happened next, I probably wouldn't have ever made a blog post about this.

[kiwi]: https://github.com/openSUSE/kiwi
[migration-fiasco]: packaging-docker-image-migrator-fiasco

### Kiwi ###

Then about two weeks ago, I was in Nürnberg for a team get-together. We'd gone
out for a few beers with a few of the people at SUSE. I was talking to
[Richard Brown][richard] over a beer and we were swapping "horrible bug
stories". He mentioned there was some very, **very** unholy things about how kiwi
does its packaging of virtual machines. I reckoned that it's possible that there
are equally unholy things going on with the packaging of Docker containers (because
I **know** that the actual packages kiwi installs have the right set-capability
bits set).

Fortunately, the way kiwi packages Docker images is *much* less crazy than the
way it packages virtual machines. All you need to do to create a Docker image is
to create a `tar` archive of a rootfs, and then use `docker import`. Essentially,
the process is something like this:

1. Create a directory for the rootfs image, bootstrap it and then install all of
   the packages specified in the [kiwi configuration file][kiwi-docker-config].
2. Use `rsync` to copy the rootfs directory to somewhere else. This is done because
   kiwi allows you to build many different formats of OS images (VMs, etc) from
   the same rootfs.
3. Replace a bunch of files in the new rootfs directory that are specific to
   Docker and LXC.
4. Use `tar` to create an `<image>.tar.xz` file.

Now, I know what you're thinking. "Aha! They're not using the right `rsync` flag
to preserve extended attributes!" Well, *actually* they were using the right flag
for the job (`-X`), as you can see in this function inside `modules/KIWIContainerBuilder.pm`:

```language-perl
#==========================================
# __copyUnpackedTreeContent
#------------------------------------------
sub __copyUnpackedTreeContent {
    # ...
    # Copy the unpacked image tree content to the given target directory
    # ---
    my $this      = shift;
    my $targetDir = shift;
    my $cmdL = $this->{cmdL};
    my $kiwi = $this->{kiwi};
    my $locator = $this->{locator};
    $kiwi -> info('Copy unpacked image tree');
    my $origin = $cmdL -> getConfigDir();
    my $tar = $locator -> getExecPath('tar');
    my $cmd = "rsync -aHXA --one-file-system $origin/ $targetDir 2>&1";
    my $data = KIWIQX::qxx ($cmd);
    my $code = $? >> 8;
    if ($code != 0) {
        $kiwi -> failed();
        $kiwi -> error('Could not copy the unpacked image tree data');
        $kiwi -> failed();
        return;
    }
    $kiwi -> done();
    return 1;
}
```

Oh, didn't I mention that it was written in Perl? Yes. It's written in Perl
(although there is [another SUSE project][kiwi-ng] that implements it in Python,
and has many improvements to the original, but it not what we currently use to
generate Docker images for openSUSE and SLE). Anyway, that's not where the problem
lied. As it turns out, `tar` doesn't support extended attributes by default. You
have to use the flag `--xattrs`, which has been available since `1.2.7` (2013).
So the diff ended up being quite small:

```language-diff
commit 419d55400edf800527b2cd4836e94190326bd10f
Author: Aleksa Sarai <asarai@suse.com>
Date:   Fri Mar 4 16:42:05 2016 +1100

    modules: KIWIContainerBuilder: preserve xattrs

    tar doesn't preserve extended attributes by default, causing Docker
    images to not have any correct set-capabilities bits set on binaries
    such as ping. Fix this by adding the --xattrs flag to the tar command
    run to generate the root filesystem image.

    Signed-off-by: Aleksa Sarai <asarai@suse.com>

diff --git a/modules/KIWIContainerBuilder.pm b/modules/KIWIContainerBuilder.pm
index 305ecf024da9..5672c870ef12 100644
--- a/modules/KIWIContainerBuilder.pm
+++ b/modules/KIWIContainerBuilder.pm
@@ -367,7 +367,7 @@ sub __createContainerBundle {
         return;
     }
     my $data = KIWIQX::qxx (
-        "$tar -C $origin -cJf $baseBuildDir/$imgFlName @dirlist 2>&1"
+        "$tar --xattrs -C $origin -cJf $baseBuildDir/$imgFlName @dirlist 2>&1"
     );
     my $code = $? >> 8;
     if ($code != 0) {
```

Naturally there were some outstanding problems with the CI (such as it running
on Ubuntu 12.04 which packages GNU tar `1.2.6`, which is from 2011). All of those
issues aside, this problem was finally fixed. The code was merged a few hours
after I opened [the pull request][kiwi-pr556]. The maintainer [Marcus
Schäfer][marcus] also [ported my fix to kiwi-ng][kiwi-ng-ping-commit]. Phew.
Time to go grab a beer.

**UPDATE**: Since posting this blog post, I found out that you need to also
apply an extra flag (`--xattrs-include=*`) which instructs GNU tar to include
all of the extended attributes (including `security.capability`). This [has
also been fixed in KIWI][kiwi-pr561].

[richard]: https://twitter.com/sysrich
[kiwi-docker-config]: https://github.com/openSUSE/docker-containers
[kiwi-ng]: https://github.com/SUSE/kiwi
[kiwi-pr556]: https://github.com/openSUSE/kiwi/pull/556
[kiwi-pr561]: https://github.com/openSUSE/kiwi/pull/561
[marcus]: https://github.com/schaefi
[kiwi-ng-ping-commit]: https://github.com/SUSE/kiwi/commit/49aaa59bf0cfd4fcddee70bfdcbd5501d1a8bc82

### Loose Ends ###

I can hear you shouting "but wait, why does Ubuntu work?" Well, imaginary reader,
it's all down to how Ubuntu packages `ping`. And yes, this applies to the Ubuntu
that you have installed on your servers, desktop machines or the laptop you gave
your mum. If you do a simple `ls -la $(which ping)`, you'll notice the following:

```language-text
% ls -la $(which ping)
-rwsr-xr-x 1 root root 44168 May  7  2014 /bin/ping
```

I don't know about you, but having `ping` be a set-uid binary definitely gives me
the chills. Luckily, if you actually [read the code][ping-src] (don't worry, I've
done it for you so you don't have to), they do all of the right dropping of
privileges. As long as there isn't [another set-uid vulnerability][mempodipper],
this should be okay. So it's not *that* bad, it was just a bit shocking to see
that's why Ubuntu images don't suffer from this problem.

Anyway, that's all folks!

[ping-src]: https://github.com/iputils/iputils
[mempodipper]: https://git.zx2c4.com/CVE-2012-0056/tree/mempodipper.c
