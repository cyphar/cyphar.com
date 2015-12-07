title: Proprietary Software Poisons Science
author: Aleksa Sarai
published: 2015-11-13 18:05:00
updated: 2015-12-07 22:30:00
description: >
  As a result of my recent research project (and the one I plan to do next year),
  I've developed some strong views on how code should be licensed if it is used
  to prove a result in a journal paper. While papers might explain what their code
  is doing, it is detrimental to peer review for code used by papers to remain
  proprietary and restrict the freedoms of other researchers to verify the results
  of a paper.
tags:
  - research
  - science
  - peer review
  - free software
  - licensing
  - programming

Before I start, I'd like the make the record clear: I am **not** a [GPL][gpl],
GNU or FSF zealot. Most of the code I've written is licensed under the MIT License
(but that's a story for another day), and I don't understand the thinking of people
who use the GPL for every single piece of code they've released as free software.

I agree with [Linus Torvalds][linus-gplv3] on the question of the *purpose* of
the GPL, that what matters is the collaboration aspect of the GPL:

> My argument for liking [GPL] version 2 [...] is that I give you source code,
> you give me changes. We're even.

So it doesn't really make sense to GPL code for which you don't forsee (or
intend) community development. If you want your code to just *exist*, why not
just place it under the MIT license or [Unlicense][unlicense] it so that people
can use it for any project?

[gpl]: http://www.gnu.org/licenses/gpl-2.0.en.html
[linus-gplv3]: https://youtu.be/PaKIZ7gJlRU?t=24
[unlicense]: http://unlicense.org/

### The Problem ###

But anyway, back to scientific research and my grievances with proprietary code
being used to produce results that then must be peer reviewed. One of the main
principles behind all of science is reproducibility. Most papers outline "what
their code basically does", which makes sense if you're outlining an experimental
setup but simply doesn't make sense for code. As any developer will tell you,
what you think your code does and what your code **actually** does are usually
two very different things.

For that reason **alone**, all code used in scientific papers should be released
as free software (and copyleft, to make sure that anybody who uses it in future
research must also make their improvements free software). But of course, it's
not that simple.

And, to be perfectly honest, most of the code I've seen that's written by
researchers isn't particularly pretty anyway. It's a whole mess of no comments
and spaghetti code. Since I've been a programmer for a while, I tend to think
of my code as being cleaner (here is [some code I wrote for my current research][keplerk2-halo]).
So you shouldn't assume that code written by a researcher would be useful for any
other purposes (as it was written with a single purpose in mind, and usually it
was hacked together so it only just works). [Matthew Alger][matt] shares this
view, and he makes a very good point: research builds on research and if you
want other people to build on your code it *needs* to be readable. In my opinion,
apart from experience, feedback from other developers is one of the best ways of
improving your code quality.

[keplerk2-halo]: https://github.com/cyphar/keplerk2-halo
[matt]: http://matthewja.com/programming-in-academia.html

### University ###

When you are part of a research group, you are generally paid in some form. Thus,
you are employed by the university. This means that all code you write is no
longer owned by you, since it was written using university resources and time.
As such, one would need to convince universities to release as free software all
code their researchers write that is used in papers. This is unlikely to go well.

One could also make the case that any data used by that code which is not in
public domain (and is vital to the code running properly) should also be public.
I'm not sure I'd agree with that view, since what's important in reproducibility
is knowing what the **method** was, so you could go get your own data and follow
that method -- as well as check that the method is valid.

But the bottom line is that it's unlikely that any reasonable university would
spend money to then release as free software the code that was written for that
money. However, most researchers' code doesn't have any real applications that
would give it any intrinsic monetary value (it's very ... pragmatically written).

### A New ~~Hope~~ License? ###

While there is a very large population of licenses available to your local
neighbourhood researcher, none of them are really suited to solving this problem.
Sure, you could go overkill and use the GPL (which is what I did), but it doesn't
actually cover the main problem -- people using the code to produce results that
are then published aren't required to distribute the source code.

*Clearly* the only possible solution is a new license. What I would like in a
license, which would solve this problem and be a step in the right direction in
this new world of computational science (where **code** has become your method)
is the following:

1. All four freedoms (as defined [by GNU][freedom]) must be provided to all users
   of the software, **and all readers of publications that made use of the
   software**.

2. The license must be copyleft, any derivative works must be licensed under this
   license and cannot be relicensed under any circumstances.

3. **THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND** ...

Obviously, this license is quite similar to the GPLv2 (it is copyleft and is
designed to uphold all four user freedoms). However, it provides an additional
requirement to all users of the software: if a user uses the software to produce
a publication they must provide the same freedoms under this license to any
readers of that publication.

In my opinion (although I'm unsure if this should be in the license), you should
not charge any **extra** fees to the readers of the publication. If it was published
in a journal, then any journal fees should be considered to have covered both the
paper and any resources in the paper. While I don't agree with [JSTOR][jstor] and
other such publishers' views on freedom of information, at least it's unreasonable
for them to claim they should be paid extra for code they don't host or provide.

You should probably note that I'm not a lawyer, and that these three clauses may
not be sufficient to adequately ensure that research remains reproducible as we
continue to create more and more software. I am considering getting legal advice
to see whether this license should be drafted, if you're interested in seeing this
become a real license shoot me an email: [`cyphar@cyphar.com`][mailto].

[freedom]: http://www.gnu.org/philosophy/free-sw.en.html
[jstor]: https://en.wikipedia.org/wiki/United_States_v._Swartz
[mailto]: mailto:cyphar@cyphar.com

### But what about other licenses? ###

So, there are some licenses which attempt to fix this problem. The first one I
found was the [CRAPL][crapl]. As far as a free software license goes, it's very
shoddy. It's main purpose is to allow peer reviewers to verify the results given
in a paper. While this is the problem we're trying to solve, I don't like the
fact that it's selective and that derivative works require permission from the
original author (or even papers using the original code). The general public
(even people who find the paper on arXiv) should be allowed to modify and run the
code.

There was [a document written by someone at Stanford][stanford] discussing this,
but they stated things that are simply not correct (emphasis added):

> Two of the most common types of open licenses **that rescind copyright** are those
> designed for code (for example, the GNU Public License or GPL and the Berkeley
> Software Distribution or BSD license) or media (for example, the family of Creative
> Commons licenses).

This is utterly false, none of the given licenses rescind copyright, that is not
their purpose. In addition, the proposal given in the paper is not actually a
proper license -- it's a description of a scholarship method that will ensure
researchers release their code as free software and doesn't actually solve the
problems we're discussing. However, it would be nice if all scholarships had a
requirement that code written as part of the research had to be made free software.

So, I couldn't find a proper license (that had been written by a lawyer) which
solved the problem we're trying to solve while simultaneously providing people
with the rights under traditional free software. Clearly this is an important
issue, and I haven't heard much discussion about this topic in the academic community
-- which is slightly troubling.

[crapl]: http://matt.might.net/articles/crapl/
[stanford]: https://web.stanford.edu/~vcs/papers/LFRSR12012008.pdfstanford]
