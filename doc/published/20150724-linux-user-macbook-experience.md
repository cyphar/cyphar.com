title: A GNU/Linux User's OS X Experience
author: Aleksa Sarai
published: 2015-07-24 02:00:00
updated: 2015-12-18 00:00:00
description: >
  Someone gave me a new Macbook as a gift, and I decided to give OS X a chance
  before I purge and install Arch Linux on it. As a result, I now need to vent
  for a bit so I can return back to the land of sanity.
tags:
  - personal
  - rant
  - os x
  - apple

**Disclaimer**: There may be some coarse language in this blog post. It's a
rant, so that should be expected by nature. If you're insulted by that, you can
fuck right off.

I just want to start out by saying that I *did* give OS X a chance to impress
me. I used my new Macbook (without any GNU/Linux VMs or anything else) as my daily
driver for almost a full week. I decided against using VMs, because if you have
to supplement your operating system with another (ore useful) operating system
then that's not exactly a good thing.

I also did my best to not be delusional. I am not Apple's target audience, I
like hacking on hardware and software I've been given. However, as a sceptic I
owe it to myself to at least give something a shot before I knock it. And I did.
I really did. So, what's my opinion on OS X?

I can't stand it any more. Get me the fuck out of here.

I'm currently writing this blog post inside `vim` on my Mac. And I'll admit that
the font rendering is nicer than my minimalist GNU/Linux setups. But that's not a
selling point to me. I don't give a shit how far you can zoom in without seeing
pixels. I care about feeling the power of a modern operating system and being
able to build any software I want. I cannot do either with OS X.

### My Use Case ###

I only need my operating system to do a few *exceptionally* simple things:

1. Be customisable. I want to be able to replace any part of the system I would
   like, and it should be easy to replace (because if you follow the Unix
   philosophy, each component is modular and replaceable).

2. Make it easy to compile, test and run any kind of software I'd like. I'd
   argue this falls under the essential [software freedoms][negative-in-the-freedom-dimension].
   As a developer, an operating system that makes it hard to build and test the
   software I am developing is not worth my time.

3. Be transparent in its workings, be easy to understand in principle (though in
   practice, it may be quite complicated to understand in its entirety). I want
   to know *how* the software I am trusting every day to keep my world running
   works under the hood.

4. Should be a separate entity. It should not rely on some third-party service
   in order to function properly. If I can't access the internet (or choose to
   airgap the machine eternally), it should be possible to run all of the
   software I'd like (and to use all of the features I'd like to) without
   needing access to online services.

OS X fails to do *all* of the above things. I'm sure that it's fine for ordinary
people if the above points are not met. But as a developer (and as a lover of
free software), these are not negotiable points for me. I will not permit a
proprietary swipey operating system to make me forgo my ideals.

[negative-in-the-freedom-dimension]: https://www.gnu.org/philosophy/free-sw.html

### The Positives ###

Before I get *too* enraged, I should probably cover the (very few) things that
OS X does right. It would be disingenuous for me to claim that OS X does
everything wrong (though it's not too far from the truth).

1. Encryption by default. FileVault means that almost all OS X users
   automatically are using disk encryption for their data. This is a step in the
   right direction for public adoption of encryption of all personal data (we
   are still a long way off though).

2. Unification. One of the few benefits you have of having an uncustomisable
   system is that the entire system is (by definition) one unit and can work
   seamlessly together. While I don't like the lack of configuration, I do like
   how things like `open` and [f.lux][flux] just work out of the box. GNU/Linux
   does have `xdg-open`, but my experience with it has always been quite dodgy.

3. Pretty nice font rendering. I must admit that getting crisp fonts in GNU/Linux
   has always been a bit of a pain. That said, for terminal work I like
   pixelated fonts like [dina][dina-font] (unfortunately, that doesn't work for
   high pixel density screens like this Macbook). Chrome fonts looks very crisp
   under OS X, and I've had people tell me that my font rendering under GNU/Linux
   is absolute crap.

[flux]: https://justgetflux.com/
[dina-font]: https://www.donationcoder.com/Software/Jibz/Dina/

### Swipey Bullshit ###

Everyone goes on for hours about how OS X is a "better user experience". It's
not. It's literally just a bunch of swipey gestures that get in the way of doing
what I'm trying to do. Pinch this, swipe that, turn around in your chair, etc.
All so I can switch back to my `tmux` session and get back to work. **FUCK THAT**.

As a programmer, I don't want random novelty bloat that gets boring after the
first few hours. Maybe people who have more artsy pursuits might enjoy the
mind-numbing stupidity of all of these skin-deep "pretty" animations. But as a
scientist and as a programmer, I will never understand why people enjoy such
childish things. Computers were originally created to solve **real** problems,
not to distract people from their mundane lives.

### Why Customise Perfection? ###

As an Arch Linux user, I'm used to being able to replace any part of the system
with something I prefer (in fact, in Arch, you have to build your system from
the bare minimum). That's a model I much prefer when it comes to computing. I
knew going into this that OS X would be different. That should be expected. Even
in GNU/Linux systems like Ubuntu, changing components is unreasonably difficult.
However, I would never have thought it would be nigh impossible to change any
aspect of the system in OS X.

With OS X, I feel like I'm constrained in a box. I can't change anything
(something as rudimentary as changing the background on every workspace is a
pain). I can't change anything (you want to use GCC? Fuck off, we're in a
`clang`y world now) and I feel like it's just a bunch of hacks running on top of
a BSD-like kernel.

Sure, you get a shittier version of `pf`, and other BSD features. But you can't
actually use them because OS X makes it hard to do anything. The whole global
keyring is one of the most stupid ideas I've ever heard of. Just use FreeBSD if
you want to use a modern BSD operating system that *actually fucking works*.

In El Capitan, there's a new feature called System Integrity Protection. It
should be called "System Idiocy Perpetuation", because it means that (by default)
you can't modify any system files. That goes against the idea of customisation
so viscerally that it actually hurts. Sure, it might make sense if it added some
security benefits. But you can disable it very trivially if you're root:

```language-clike
# nvram boot-args="rootless=0"
# reboot
```

It's just designed to make it more of a pain to do something as vital as
installing custom libraries to your build toolchain. This is an example of the
sort of decision that is endemic to a system which is designed to lock you into
a software prison.

### Botched Package Management ###

What is the main point of a package manager? If you said something like "to
simply and easily consolidate the installation and maintainership of all
software on a system to one managed system", you know more about package
management than Apple and the community that uses OS X combined.

Sure, you have [Homebrew][homebrew] and [MacPorts][mac-ports] which sort of work.
But the key word in the above description of a package manager is **all**. A
package manager is useless if it doesn't manage **all** of the packages on a
system (especially if some of the packages that it doesn't manage are
dependencies of packages it does manage).

As a quick aside, yes that means that I completely disagree with the idea behind
`pip`, `npm` and other such language-specific package managers. It makes server
maintainership much more of a pain because you keep adding systems that are
gleefully ignorant of one another (`pip` doesn't know if a new version of a
package needs to be patched in order to run on your system, and your package
manager definitely doesn't know what the hell `pip` is doing behind its back).

But anyway, back to OS X. OS X has the App Store, which (for some unknown reason)
also handles operating system updates. I don't really agree with the idea of an
app store either, but that's a separate issue. The fact that you need to log
into iCloud in order to install an update or program is stupid. I understand
that it's necessary in order to implement DRM paid software, but I'm not paying
for updates or gratis software.

[homebrew]: http://brew.sh/
[mac-ports]: https://www.macports.org/

### Horrible Developer Workflow ###

I mentioned this earlier, but most developers use virtual machines in order to
properly use OS X. The very notion that your operating system is so lacking that
it is easier to just run a virtual operating system to fill the gaps shows you
that there is clearly something very wrong with this model.

If you want to build and test your software, you have to run it inside
[Vagrant][vagrant] (which is actually just a wrapper of [VirtualBox][virtualbox]).
Why is this the case? Well, it's because OS X sucks as a development
environment. I've heard some people argue this as a "good thing". That's
bullshit. OS X impotency for development is not a design decision to make
separation of concern part of the operating system. It's just that OS X doesn't
do what a developer needs their operating system to do.

Admittedly, GNU/Linux also has some pain points that make things like Illumos
quite appealing. But at least GNU/Linux does *enough* of it right to make it
useable for development. Honestly, the only "development" work I've done so far
is just writing this blog post and making minor changes to my website's CSS. I've
tried editing some Linux kernel code or trying to hack on some cool Go code and
it just doesn't feel right. I keep finding myself `ssh`ing back into my main rig.

[vagrant]: https://www.vagrantup.com/
[virtualbox]: https://www.virtualbox.org/

### Filesystem Pollution ###

I don't know about you, but I really like the FreeBSD filesystem layout. It's
clean, fully regimented, makes sense and is *completely* predictable. Want an
example config script for the service you just installed? It's in
`/etc/defaults` or in `/usr/local/etc/defaults`. Compare that simplicity with
this:

```language-clike
$ ls /
Applications                    System                          bin
etc                             net                             tmp
Library                         Users                           cores
home                            private                         usr
Network                         Volumes                         dev
installer.failurerequests       sbin                            var
```

I'm not even sure what directory is for what. `Applications/` seems very
descriptive, but then you have `System/` and `Library/` which both contain parts
of applications.

Speaking of filesystems, we might as well mention the elephant in the room:
HFS+. Never have I heard of a more schizophrenic filesystem. Case insensitivity
(fucking seriously?), weird design choices in regards to endian-ness, weird
design choices about normalising Unicode (because HFS+ supports Unicode, but
badly). It's hilarious that certain constructs (like `..`) had to be hacked
around to deal with the normalisation of unicode (where a unicode string could
normalise to `..`). If you want to learn more, read this classic
[Torvalds shitstorm][torvalds-hfs+].

Just please give me ext4 or ZFS. To paraphrase Shakespeare, "A filesystem, a
filesystem! My kingdom for a decent filesystem!" (or at least, I'm sure that's
what he would've written today).

[torvalds-hfs+]: https://plus.google.com/+JunioCHamano/posts/1Bpaj3e3Rru

### Hardware ###

While the rest of this post was dedicated to just OS X, I do feel like I need to
quickly discuss the Macbook hardware. I must admit that this hardware is pretty
nice (it's fairly overpriced, but since I didn't pay for it that isn't a pain
point). The retina display is very beautiful, but I do find myself getting
headaches and thinking that the text is blurry when I'm working on some code.

The EFI firmware on Macbooks has historically been insanely proprietary, and
that still is the case. The only way to update the firmware is through OS X
(this is hardly a surprise, Apple is hardly the "open systems company"). It is
quite annoying though, because it means that when I purge my laptop of OS X I'll
have to keep a small OS X partition so I can update the firmware (and get
support from Apple).

### Update ###

So, I've been using my Mac as my main driver for 5 months. Because Linux doesn't
support the keyboard and trackpad, I can't install any GNU/Linux distribution on
it. Unfortunately, the battery life is such a good selling point that I can't
switch from it at the moment. I am however planning on buying a better laptop
soon, and installing [coreboot][coreboot] and GNU/Linux on it. I still don't like
any of the swishy bullshit, I still don't like the completely broken App Store
updates, I still don't like the fact that I'm treated like a child on my own
machine.

[coreboot]: https://www.coreboot.org/
