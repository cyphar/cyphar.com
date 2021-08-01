title: Licenses, licenses, licenses
author: Aleksa Sarai
published: 2015-12-07 22:30:00
updated: 2015-12-07 22:30:00
short_description: >
  An overview of what I think about licenses.
description: >
  There are many different types of works, and it can often be difficult to decide
  what license you should use (assuming that you intend to release it so that
  others may benefit). It's important to remember that not only software requires
  free licenses, other works do too. There are lots of opinions on this topic,
  and I'm just adding mine to the fire.
tags:
  - licensing
  - free software

The first and most important thing to remember is that, if a work is yours, **you
and you alone have the right to decide what license is good for you**. While I
might prefer that you use a license which respects the freedom of users of your
work, the decision of whether you find that to be important is yours. Licenses
are irrevocable, once you've released something under a certain license then
anyone may use the work under that license -- so you'd better be sure about the
license you pick.

## Software ##

Let's start with the big one: code. What should free software be licensed under?
There are a couple of obvious choices, and each has certain advantages and
disadvantages.

### GNU General Public License ###

This is the license published by the Free Software Foundation, and is the one
recommended by Richard Stallman and the Free Software Foundation. There are two
major versions in circulation: version 2 and version 3. There are some fairly
important version differences, and also some caveats.

However, in general you should use the GPL if you feel that creating a community
where improvements are circulated to benefit the whole community is important. If
you don't want to create a community around your code, then you should choose a
different license.

As the GPL is copyleft, you should consider the fact that some users may chose to
not use your software because they do not wish to be required to make their changes
also free software. While this is very selfish, it is also understandable and you
should consider it while choosing a license.

#### Version 2 ####

In my personal opinion, version 2 of the GPL is a very good license, as long as
you are not concerned with "tivoisation" of your software. While "tivoisation"
is a slightly unfair term (TiVo aren't the devil), introduction of effective
anti-circumvention measures to free software that restrict users is very harmful
behaviour. If you decide to ship free software, you need to play by the rules.

Unfortunately, version 2 of the license is not as internationalised as version 3,
and it is very likely that it may not apply in certain jurisdictions. While this
isn't a problem for me (Australia has copyright law very similar to the US), this
might be a problem for you.

#### Version 3 ####

I personally agree with the view on anti-circumvention. Such technology is entirely
valid, so long as the user has control over the software (and that's the entire
point of free software). While it is true that "tivoised" software can contribute
useful patches back to the original project (as happened with TiVo), one can
imagine a dystopia where no users can run modified versions of the free software
they have been given. At that point, their freedoms are all but useless, and that
is the dystopia Richard Stallman and the FSF are trying to counteract. I was not
always in favour of version 3 of the GPL, mainly because the anti-circumvention
clause always hit me as being vague. However, what's quite important to establish
upfront is the intent of the author.

The GPL version 3 also has much nicer patent protections for users, resulting in
much more explicit patent grants from all contributors and distributors to all
users. This is nice, and if you agree with the "tivoisation" clause (or you don't
care) you should use version 3 as it is a superior license in several respects.

#### The Danger of "Or Any Later Version" ####

Unfortunately, all versions of the GPL have "unsafe defaults" to use the software
vernacular. Specifically, the Free Software Foundation recommends that you use
the following statement to show that the software is licensed under the GPL
(emphasis added):

```language-text
<one line to give the program's name and a brief idea of what it does.>
Copyright (C) <year <name of author>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; **either version 2 of the License, or
(at your option) any later version.**

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
```

The phrase "or (at your option) any later version" is very clearly a bug in this
statement, as it results in ambiguity regarding what license the software is
licensed under. As I said earlier, it is the choice of the developer to state
what license the code is under, not the user. If you feel that "tivoisation" is
not an issue for you and you will not license your code under the GPLv3, the
"or later" clause can allow someone to improve your software and license the
improvements under the GPLv3. Due to the license incompatibilities, you will be
unable to use their improvements without changing your license to the GPLv3.

This is quite bad. I've discussed this with Richard Stallman, and he considers
the above scenario very unlikely. He claims that it's worse to create a license
incompatibility with other projects which might want to use my code than to ensure
that all modifications to my project are actually usable.

Either way you feel, the entire concept of "or any later version" is just dangerous
and you should omit that section of the statement -- specifying **clearly** what
license **you** chose.

### Apache ###

The Apache license is probably the best license for large bodies of free software,
where you don't really care about the idea of copyleft. It provides very nice
protections against software patents created from the software you've licensed,
and is in general a very nice license with little to no flaws.

### MIT / BSD ###

Now we come to the runt of the litter: the short licenses. For small projects,
these may be adequate.

### Unlicense (Public Domain) ###

Sometimes you wish your code to be dedicated to the public domain (which is very
admirable), but you want to ensure that people in jurisdictions without a concept
of public domain can also have the same freedoms as the rest of the world. Notable
examples of public domain software include SQLite, qmail, PyCrypto and other such
software projects.

If you *do* decide to make your code public domain, be aware that there's no
requirement that you be referenced as an author in any of the code. So if you
care about attribution, making your code public domain will not ensure that.

### Creative Commons ###

I would **not** recommend using the Creative Commons licenses for software. They
are intended for media or other such works, not something like code.

There are some issues with CC0, namely that releasing a work under the CC0 does
not waive patents that the artist may have. Therefore, you may actually not have
the freedom to practically use the work despite it being licensed under the CC0.
As software patents are a broken system by design, you should not use a license
which explicitly exposes your users to patent trolls.

## Media ##

An important question about media (text, video, audio, etc) is what the text
actually is. Does it represent someone's personal views? Is it an artistic work?
Or is it a functional work (such as a recipe or instructional video)? These are
quite important questions, because each might require certain restrictions.

In general, I recommend the Creative Commons suite of licenses for all forms of
media. The only question is which version of the Creative Commons license you
should use.

For personal views, I very seriously suggest that you should use a No Derivatives
Creative Commons license. As they are *your views*, it wouldn't make sense that
people should have the right to distribute changed versions of your views with
your name still attached. This is why all of my blog posts are licensed under
the [Creative Commons BY-ND 4.0 license][BY-ND].

[BY-ND]: https://creativecommons.org/licenses/by-nd/4.0/

### Non Commercial ###

I don't really agree with the idea of licensing works such that they cannot be
used for commercial purposes (money isn't evil). But at the same time, it is the
right of the artist to decide what license they will choose. If you feel that
commercial use of your work should be disallowed without your express permission,
then use this license.

### Share Alike ###

If you feel that copyleft is important, that users of modifications of your work
deserve the same freedoms as users of your original work, then you should consider
using a Creative Commons Share-Alike license.

### No Derivatives ###

This is quite important if the work is your personal views, or if they are some
other work where the freedom to make modifications to it doesn't make sense. You
should be wary of using this license for artistic works, as much of art is based
on the age-old idea of plagiarism (or rather, appropriation and derivative works).

### CC0 (Public Domain) ###

As with the Unlicense, CC0 is the Creative Commons public domain license. It
ensures that even in jurisdictions without the concept of public domain, the work
provides broadly the same freedoms as everywhere else. Media being put into the
public domain is always a very positive thing, as it allows other artists to
build on your work. However, you should be aware of the fact that a lack of
obligation to attribute you will probably result in much less attribution than
if you used a different Creative Commons license.

As CC0 has an explicit exception for patents, permitting artists to maintain a
patent monopoly over a work in the public domain is a fairly major contradiction.
Due to the lack of patent exemptions, CC0 should not be used for works which are
reasonably patentable (because someone else might patent the work and then go
after your users).
