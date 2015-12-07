title: Android Compilation Headaches
author: Aleksa Sarai
published: 2015-11-28 03:20:00
updated: 2015-12-07 22:30:00
description: >
  I've spent the last week of my life trying to build [TWRP](https://twrp.me/),
  which requires having a full, and working Android build environment. With the
  emphasis on **working**, I've had just about enough of the stupidity of the
  Android build system. Every guide is incomplete or out of date, the build
  system is broken in every possible way and nobody can explain what is going on.
  Here's my experience with trying to build Android and hopefully will help
  somebody realise the futility of trying to build a project with such a complicated
  build system.
tags:
  - android
  - free software
  - rant

*"Free software projects are only useful if you can build them for yourselves."*

I'm sure that most developers would agree with this statement, even if all you
want to do is test changes you've written before sending them upstream. What good
is having access to the code if you can't build and run it? How do you know what's
**actually** running on your machine? Build it and find out!

I've been working on fixing a bug in the [Team Win Recovery Project][twrp] ROM,
and obviously wanted to build it before sending a patch upstream. I wasn't even
sure if my patch would build, due to the **grave** lack of comments throughout
the codebase -- but that's an issue for another day.

Naturally, I typed `make` and nothing happened! Well, some quick Googling showed
that I needed to "build it inside an AOSP environment". I wasn't sure what that
meant, but I was game. I found a [thread][twrp-thread] which was linked to and
is clearly the authority on TWRP compilation. Great! I just have to follow this
to the letter and---

> All of TWRP 2.x source is public. You can compile it on your own. This guide
> isn't going to be a step-by-step, word-for-word type of guide. If you're not
> familiar with basic Linux commands and/or building in AOSP then you probably
> won't be able to do this. [...] There's only so much that you can dumb it down
> and simplify it. There's lots of other guides out there for getting started.

Oh, okay. I mean, that's a little bit flippant, but I guess I can go find these
"other guides". Why they weren't linked is beyond me, but Google exists for a
reason. Just because I haven't built Android before doesn't mean that I "won't be
able to do this".

[twrp]: https://twrp.me/
[twrp-thread]: http://forum.xda-developers.com/showthread.php?t=1943625

### Attempt 1: OS X -- AOSP ###

Before getting your hopes up, note the **1** in the section title. It should hint
at how well this is going to go.

So, I'm going to ignore the **massive** issue of how big the repository was. It
took up a total of 34GB (18 of which was the `.repo` metadata). Anyway, let's go
over the many issues.

The first one was sort of my fault, I tried to build Android with OS X. But the
documentation for CyanogenMod, Android and OmniROM all claim that building on
OS X is supported. I guess I was too gullible believing that anything developer-related
on OS X is **even remotely easy**. Headers were missing, the pre-built toolchain
was badly broken. I managed to patch up these issues with some horrible symlink
hacks.

Secondly was that `repo` didn't actually download all of the source code. As it
turns out, `repo` doesn't actually make sure that the download you asked it to
complete was completed. So, I had to re-run `repo sync` specifying that I only
wanted one network thread and ran it a few times to make sure it actually
downloaded everything.

Thirdly, I tried to follow the guide now that I had an AOSP build environment.
As it turns out, AOSP isn't the source code you need (even though the tutorial
mentions it quite a few times). Okay, my fault for not properly reading the
opening few paragraphs.

Time to download some different source code.

### Attempt 2: OS X -- CyanogenMod ###

I'll make this one quick. The first two problems were still there, and I had to
fix up the toolchain and the source code again. It wasn't so bad the second time
around, but it was still pretty fucking annoying.

It started to build, after running `lunch PLEASE-FUCKING-WORK` or similar. I ran
to get a cup of tea to celebrate and returned to find errors saying that some
library targets weren't accounted for. This was ... bad, given I hadn't touched
anything and I was just trying to build the generic software. I couldn't figure
out what the problem was and I'd had enough of OS X. I was already more than 5
hours into this ordeal and was getting quite pissed off. I'd already switched
from tea to Vodka.

I also realised that I actually needed to build for my new phone (because testing
encryption with a ROM in an emulator is not exactly possible). So I decided to
give it another crack with a more sane operating system: Debian (maybe "less
insane" is a better description).

### Attempt 3: Debian -- CyanogenMod ###

There was actually a [wiki page][cm-bacon-wiki] for this one, which almost made
me think this would be an easy fix.

After spinning up a VPS with Debian, I set about downloading all the required
packages. It was much easier than OS X, so I'll give one point to Debian for this
one. `repo` worked perfectly fine, but I think that's just because of the very
good bandwidth on my VPS provider.

The toolchain was not an issue this time, but on the other hand my locale settings
were. Curiously, `flex` just broke because `LC_COLLATE` was not flex-friendly. I
fixed this (wondering why on Earth was going wrong) and continued on. This problem
kept resurfacing on every Linux distribution I tried, making **every single build**
require special love and care. Fixing this is mostly a shotgun approach, with
doing everything from resetting all of the locale files to reinstalling `glibc`.

I then had to deal with setting up the build environment for my OnePlus One (codename
bacon). Ripping the proprietary blobs from my phone (a process which made me feel
very disillusioned about the state of Android) was not horribly hard. There were
some "missing file" errors, but I just shut my eyes and ignored their existence.
Since you have to run a bunch of disconnected scripts with no apparent logic, I
wasn't exactly sure if I'd downloaded all of the correct configs to the right
places. But it looked about right.

The build was run again, and it broke again. This time a different set of library
targets couldn't be accounted for. "Surely not", I proclaimed. I was getting quite
pissed off now, given that I was building off of `android-5.1`, which shouldn't
be this broken.

However, I could build the `recovery` source code. This sounds good until you
realise that I couldn't build the `recoveryimage` because the build system claimed
that there's "nothing to do". Fuck you, `make`. Stop being so smug. Attempting to
build the `recoveryzip` produced a whole bunch of warnings that showed that the
`Makefile` in question was broken (bad path sanitisation everywhere).

I would like to point out that at this point I stopped mixing my Vodka with any
dilution agents. I didn't need the extra calories.

[cm-bacon-wiki]: https://wiki.cyanogenmod.org/w/Build_for_bacon

### Attempt 4: Debian -- OmniROM [mini] ###

There was a link on the [original guide][twrp-thread] which provided a minified
manifest file which "should work for most cases". It was worth a shot. The
source code for this one was quite a bit smaller and it was missing the entire
Android source and only really had the build system and kernel. It was also
mentioned that using CyanogenMod may cause issues, so I decided to just stick
with using OmniROM (which apparently isn't broken -- I've found otherwise).

I'll cut to the chase: It didn't work, because it was too stripped down. My fault
for assuming that my use case was not standard. At this point I was about 2 days
into trying to build Android and was not having a fun time. I was also running
low on Vodka. This is a bad combination.

### Attempt N: Arch -- OmniROM ###

There were several other attempts I made, all of which were done on Arch. They
all failed miserably, either failing to build anything at all or they couldn't
build a `recoveryimage`. I'm going to omit them here, because I lost count of
the number of issues I ran into.

This was to be my very last attempt. If I couldn't build in this attempt, I would
just send a patch upstream without testing it. There was simply nothing more I
could do, and maybe I could get some help building my code. Or they would shout
at me and I would shout back about how fucking retarded their build system is.

Guess what? It didn't fucking work. But, before I gave up and decided to continue
with my life, I decided to see if I could hack the source tree. As it turns out,
there were some interesting warnings about missing `vendor/` directories. This
sounded like a good start, but for some reason OmniROM didn't include an `extract-files.sh`
shell script to populate this directory. No matter, I can just clone some
published on GitHub. The key ones are the [common vendor blobs][gh-vendor-common]
and the [find7a blobs][gh-vendor-find7a]. These probably aren't officially supported,
but do I sound like I care at this point?

The final secret sauce was to clone the right vendor repos (none of which were
actually for my device `bacon` or `find7op`). This was very odd, and it took me
a while to figure out that we didn't need any of the proprietary stuff from my
actual device in OmniROM. Here's the relevant commands:

```language-bash
$ croot
$ mkdir -p vendor/oppo
$ git clone https://github.com/MoKee/android_vendor_oppo_msm8974-common.git vendor/oppo/msm8974-common
# ...
$ git clone https://github.com/MoKee/android_vendor_oppo_find7a.git vendor/oppo/find7a
# ...
```

Okay, now running `brunch omni_find7op-eng` seemed to work a lot better. Running
`make TW_THEME=portrait_hdpi recoverimage` then appeared to start building Linux
(*hurrah!*). Unfortunately, I ran into yet another problem, with Perl complaining
about some broken code. I'd be damned if I'd let something of the likes of Perl
stop me now. The relevant error was:

```language-bash
$ make TW_THEME=portrait_hdpi recoverimage
# ...
 TIMEC   kernel/timeconst.h
Can't use 'defined(@array)' (Maybe you should just omit the defined()?) at /home/cyphar/build/android/omni/kernel/oppo/msm8974/kernel/timeconst.pl line 373.
# ...
```

Okay, thanks for the hint Perl! After changing the line to omit the `defined()`,
it would now continue to build Linux. This is probably a bug in `HEAD`, but it's
possible there was some Perl versioning issue. Meh, it's not my problem.

The build then continued until we hit our good friend the `flex` `LC_COLLATE`
bug. Changing `LC_COLLATE` didn't want to work, and the bug is actually due to
the prebuilt `flex` being incompatible with the newest version of `glibc`. So,
just decided to change the definition of `$(LEX)` in `build/core/config.mk` to
just point to the host's `flex`. Locales are generally fucked, and I really wish
someone would fix this.

After all of this, the build completed with no other issues! Time to boot into
the recovery to test my changes.

[gh-vendor-common]: https://github.com/MoKee/android_vendor_oppo_msm8974-common
[gh-vendor-find7a]: https://github.com/MoKee/android_vendor_oppo_find7a

#### Booting ####

As it turns out, it wouldn't boot. Even with the unmodified `bootable/recovery/`
code, I couldn't boot to the recovery ROM after flashing it. This is clearly
ridiculous, and it must have something to do with incorrect drivers or some other
bullshit.

I've had enough of this crap. I've tried every guide I could find (none of which
were any help **at all**), I've hacked around the source so that I could include
things not included by the automated build scripts, I've modified Makefiles and
other scripts so they would work properly. I think it's fair to say I've done my
due diligence in trying to compile and test my changes. But I've had enough and
it's time to move on with my life. I'm going to send a PR to the Team Win developers
and see what they have to say.

### Upstream ###

So, I just decided to send my changes to [Gerrit][submitted-patchset] and see
what happens. I have nothing left to give here. I *did* try to compile Android,
and I leave a little older and with a drinking problem. I'm not entirely sure
what else I'm meant to have done in the face of invalid, misleading or otherwise
inadequate documentation. I would be very grateful if someone could solve this
by producing a *conclusive* set of instructions on how to build Android and how
to solve common problems.

[submitted-patchset]: https://gerrit.omnirom.org/#/q/topic:issue/525

### UPDATE: I Booted! ###

So, after I got a response from upstream, I decided I needed to sort this out. I
figured out that I didn't actually need to compile a whole new kernel (and all
of the device problems that causes). All I needed to do was to rip apart an
existing [`recovery.img`][twrp-bacon] and then modify the ramdisk to contain my
changes. In particular you just needed to update these paths:

* `/sbin/recovery`
* `/sbin/twrp` (if you've changed the command-line for TWRP)
* `/twres` (if you've changed the resources)

Afterwards, make sure that you use the **exact same** options for `mkbootimg`
when gluing together all of the pieces (make sure you include everything that
was in the original recovery image too).

This worked and allowed me to boot, allowing me to bypass the compilation of
Android entirely. So, I guess you could call this a success? It's still pretty
messed up though.

[twrp-bacon]: https://twrp.me/devices/oneplusone.html
