title: Photometry of Contaminated *Kepler* Pixels
author: Aleksa Sarai
published:
updated: 2015-11-03 05:45:00
description: >
  As part of the [Talented Student Program](https://sydney.edu.au/science/tsp),
  I undertook my first research project in the School of Physics (and hopefully
  the first of many). Specifically, this research involved designing a novel
  technique for making use of halo contamination from bright stars in *Kepler*
  K2 fields to do high-precision photometry. I'm planning on doing further
  research on this topic during the summer, and hopefully will get a paper
  published as a result.
tags:
  - tsp
  - usyd
  - research
  - physics
  - astronomy
  - kepler
  - k2

I've always loved science, and have always wanted to do research ever since I
was a kid. The sense of discovery and learning more about the universe speaks to
me on a very fundamental level.

I recently participated in the [Talented Student Program][tsp], where
undergraduate students are given the opportunity to conduct real-world research.
After talking to a few different research groups, I settled on an interesting
project idea pitched by [Tim Bedding][bedding], [Daniel Huber][huber], and
[Simon Murphy][murphy]. Is it possible to do analysis of light coming from a
star using a telescope that hasn't explicitly collected data for the star?

[tsp]: https://sydney.edu.au/science/tsp
[bedding]: http://www.physics.usyd.edu.au/~bedding/
[huber]: https://sites.google.com/site/danxhuber/
[murphy]: http://simonmurphy.info/

## Asteroseismology ##

Before discussing the research I've been working on for the past few months, I
should probably explain what modern astrophysics consists of. One of the more
interesting fields in astrophysics is a field called "asteroseismology". Not
unlike it's Earth counter-part, asteroseismology is concerned with oscillations
of stars.

Not all stars are not static balls of hot gas. Some are quite active, and vibrate
through several different driving forces. Sound waves travel from the center of
the star to the surface, which are known as **p**-modes (because **p**ressure is
the restoring force). Similarly, there are **g**-modes, where the restoring force
is buoyancy. These oscillations are affected by the structure and other parameters
of the star. In particular, the frequency of the oscillations (as well as which
modes of oscillation are excited and the amplitude of the oscillations) are very
strongly defined by stellar parameters.

As such, you should be able to convince yourself that an understanding of the
underlying physics would allow for otherwise impossibly accurate measurement of
stellar parameters through the measurement of the oscillation of stars. As it
turns out, such an understanding **does** exist (you can even read
[very expensive textbooks on the subject][springer-astro]).

But how do we detect these oscillations?

[springer-astro]: http://www.springer.com/us/book/9781402051784

### Photometry ###

One of the many techniques of detecting these oscillations is photometry. And,
in a way, it's the most obvious one: count how many photons of light you detect
coming from a star over a certain exposure, do a bunch of exposures and store the
timestamp of each one, and analyse that time series. There are some issues with
this technique (as being limited to only detecting low-degree oscillations), but
it is fairly robust and works pretty well.

## *Kepler* and the K2 Mission ##

So, what is *Kepler* and what is K2? *Kepler* is a space telescope which uses
photometry to try and detect transiting exoplanets. However, due to its incredibly
accurate photometric detectors (CCDs) it is also an invaluable asteroseismic
instrument. It's original task was to observe a fairly uninteresting part of the
sky (which contained no bright stars and was slightly above the ecliptic plane),
and store photometric data for hundreds of thousands of targets.

However, by 2013 (4 years after launch) two of the four reaction wheels used to
provide fine pointing control had malfunctioned. As a result, *Kepler* could no
longer observe the original field (as radiation pressure from our Sun would make
it unstable). As such, a [new mission was proposed][k2-proposal] to observe fields
along the ecliptic plane. As a result, *Kepler* would observe a very different
set of stars to the original mission. This mission would be called K2, and with
it would come plenty of fascinating astrophysics research.

However, for the purpose of my research, what is most interesting about K2 is
that there are many more **very** bright stars in the new fields. Bright stars
are interesting for a variety of reasons (mainly that they have been well studied
from the ground for hundreds of years, and that accurate data on their oscillations
can be used to improve existing models of stars).

[k2-proposal]: http://arxiv.org/abs/1402.5163

### Postage Stamps ###

Unfortunately, bandwidth is limited. Due to *Kepler*'s distance from the Earth,
and the sheer amount of data available, not all of the photometric data (which
is taken every 30 minutes) can be downloaded for all *Kepler* pixels. To deal
with this, *Kepler* provides only certain pre-determined pixel masks. Only about
5% of pixels captured by *Kepler* are actually sent to Earth. These pixel masks
are called "postage stamps".

It was generally believed that the only way to do photometry for bright stars is
to count **all** of the light (flux) from the star. Making postage stamps for
bright stars was therefore too expensive in terms of bandwidth, because bright
stars have halos and other effects such that they require many more pixels (more
than 100 times as many) to contain all of the light from the star.

The main point of my research project was to determine if this assumption was
true, and to see if it would be possible to do bright star photometry without
having all of the light from the star.

## Contamination ##

Optics in *Kepler* (or any telescope for that matter) are far from perfect.
Incident photons are diffracted on the supports for the sensors and internally
reflected inside the actual photometric sensors. These result in the target star
(which would normally be considered a point source, due to the distance from the
sensor to the star being much larger than the diameter of the region of pixels
its photons land on), having a "halo". More information can be found [here][halo].

We assume that this halo has a photon count proportional to the incident photon
count, as there doesn't appear to be any bias within the optics regarding halo
production. As such, it should be **in principle** possible to do photometry
using nothing but the halo of a star (and further, only a subset of pixels in the
halo of a star).

However, this idea was not known about (it's entirely novel), so there are no
nice postage stamps of subsets of halo pixels of bright stars. As a result, we
had to find serendipitous postage stamps which happen to fall inside a bright
stars halo. As it turns out, these postage stamps are not as rare as you might
assume. While pixel bandwidth is very precious, many postage stamp proposals
don't appear to be too mindful of whether they are very close to an exceptionally
bright star that will render that postage stamp useless to that researcher.

[halo]: http://arxiv.org/abs/0909.3320

## Method ##

So, with all of that background in order, let's get to the nitty-gritty. The
first problem to deal with is the fact that *Kepler*'s pointing malfunctions
result in an apparent motion of targets on the detector. This introduces a
pseudo-variability, due to flux moving between pixels and crossing the postage
stamp boundaries. As a result, accurate digital tracking data is required.

As the *Kepler* systematics are rotational in nature, a rotational model was
created by [Benjamin Pope][pope] (a fellow researcher) by computing the centroid
of each postage stamp and tracking it for each timestamp. This apparent motion
is used to accurately predict the rotational offset for each timestamp.

An aperture was manually selected to contain all halo flux which does not leave
the postage stamp or become otherwise contaminated by the intended target. This
aperture was then converted to a polygon with feathered edges, which is then
integrated over for each cadence. From this, a time series is created which can
then be analysed.

[pope]: https://www2.physics.ox.ac.uk/contacts/people/popeb

## So ... did it work? ##

Yes. Yes it did. We did only attempt this technique on a dozen postage stamps or
so, due to time constraints. However, I will be continuing this research during
the summer (and will hopefully get a paper published on the topic). Incidentally,
I was also co-author [on a paper][k2-smear] which discusses a different technique
for doing bright star photometry with *Kepler* smear data (which was discovered
as a result of the research I've been doing).

I'm very excited about all of this, and have been absolutely enthralled in all
of the things I've learnt as part of this project. While I know that I have a lot
more to learn, and hopefully much more research to do, I am glad to now be able
to point to something and say "I've done something real".

[k2-smear]: http://arxiv.org/abs/1510.00008

## Where's the code at? ##

Of course, the code has been made open source and [is available on GitHub][git],
licensed under the GNU General Public License (version 2 only). The reason for
using the GPL, rather than my usual choice of the MIT license is mainly
philosophical (and I should probably write up a blog post on this topic) and is
better explained [here][proprietary-poison].

[git]: https://github.com/cyphar/keplerk2-halo
[proprietary-poison]: research-code-licensing
