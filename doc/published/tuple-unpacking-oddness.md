title: Tuple Unpacking Oddness
author: Aleksa Sarai
published: 2015-09-01 01:00:00
updated: 2015-09-01 18:10:00
description: >
  While working on tutoring the [NCSS Challenge](https://groklearning.com/), I
  found a very interesting oddity of Python's tuple unpacking execution order.
  While it turns out this is very well documented, it isn't very intuitive (as
  with most edge cases in languages).
tags:
  - programming
  - python

I just wanted to start out by saying that I'm not entirely sure what the
standards people where smoking when they stated that the following is entirely
expected behaviour. I also want to thank my fellow tutors for helping me get to
grips with what is going on here.

### The Code ###
The code in question looks pretty innocuous:

```language-python
a = "a"
b = "b"
L = [a, b]

# Here it comes ...
L[L.index(a)], L[L.index(b)] = b, a
```

Now, what do you expect the above code to do? I personally would expect (with my
experiences with tuple unpacking) that `L` would be `[b, a]`. However, it seems
that Python has other ideas:

```language-python
>>> # Insert code from above.
>>> L == [b, a]
False
>>> L == [a, b]
True
```

... Wait, what? So not only didn't it do what we'd expect (that the values would
be switched), but in addition it didn't even affect the list? Even though
clearly the first portion of the tuple simply **must** modify the list, right?

However, if we switch the order of the list, we see what we'd expect:

```language-python
>>> L = [b, a]
>>> L[L.index(a)], L[L.index(b)] = b, a
>>> L == [b, a]
False
>>> L == [a, b]
True
```

So what the hell is going on here? It looks like the list is always going to end
up being `[a, b]` using this method. There's clearly something fishy going on
here.

### Can't Touch **`dis`**&sup1; ###
So, after staring at the code for ten minutes or so (and some very generous help
from my fellow tutors) we nailed what the problem was. First we busted out `dis`
to see what CPython was **actually** executing and *in what order*.

```language-python
>>> # Insert the code from above in a function called `func`.
>>> import dis
>>> dis.dis(func)
# SNIP: Setup instructions.
  7          24 LOAD_FAST                1 (b)
             27 LOAD_FAST                0 (a)
             30 ROT_TWO
             31 LOAD_FAST                2 (L)
             34 LOAD_FAST                2 (L)
             37 LOAD_ATTR                0 (index)
             40 LOAD_FAST                0 (a)
             43 CALL_FUNCTION            1 (1 positional, 0 keyword pair)
             46 STORE_SUBSCR
             47 LOAD_FAST                2 (L)
             50 LOAD_FAST                2 (L)
             53 LOAD_ATTR                0 (index)
             56 LOAD_FAST                1 (b)
             59 CALL_FUNCTION            1 (1 positional, 0 keyword pair)
             62 STORE_SUBSCR
# SNIP: Return instructions.
```

The key points here are the positions of the `STORE_SUBSCR` instructions in
relation to the calls to `.index`. As you can see, Python decides to modify the
list `L` before evaluating the subscripts. Extracting only the important lines:

```language-python
# SNIP: Loading code.
             43 CALL_FUNCTION            1 (1 positional, 0 keyword pair) # .index(a)
             46 STORE_SUBSCR                                              # b
# SNIP: Loading code.
             59 CALL_FUNCTION            1 (1 positional, 0 keyword pair) # .index(b)
             62 STORE_SUBSCR                                              # a
```

So, what CPython has decided to generate is less like this (which is what we
might expect):

```language-python
# Temporary variables for the indexes (to ensure "correct" order of operations).
ia = L.index(a)
ib = L.index(b)

# Expanded tuple.
L[ia] = b
L[ib] = a
```

And in fact generates something vaguely similar to this:

```language-python
L[L.index(a)] = b
L[L.index(b)] = a
```

Which explains why there's no change! We modify `L[0]` and then revert it
immediately. This seemed to be (at least in my opinion) a violation of the order
of operations of subscripting and tuple unpacking.

<small>&sup1; I'm sorry, I'm so sorry. I just couldn't resist.</small>

### Versions of Python Affected ###
This appeared to affect the following Python versions and implementations:

* CPython 3.4.3
* CPython 2.7.10
* PyPy 2.6.0

Which lead me to believe that this probably isn't some implementation-specific,
hacky bytecode optimisation being done by CPython (which was my first impression
when I was looking at the bytecode `dis` spat out). It must be documented
*somewhere*.

### The Standard ###
So, as with all weirdness, in the event of confusion it is best to refer to the
specification. I want to thank [David Vo][aucg] for linking me the relevant
section of the standard (I don't like trawling through standards docs to find
the one sentence that perfectly defines your situation).

In particular, [&sect;7.2][spec-7.2] states that:

> If the target list is a comma-separated list of targets: [...] the items are
> assigned, **from left to right**, to the corresponding targets. [...]
> Assignment of an object to a single target is recursively defined as follows
> [...] if the target is a subscription: The primary expression in the reference
> is evaluated. It should yield either a mutable sequence object [...] **Next,
> the subscript expression is evaluated.** [emphasis added]

And, in fact, it references a very similar example to ours in the docs:

> Although the definition of assignment implies that overlaps between the
> left-hand side and the right-hand side are 'simultanenous' (for example
> `a, b = b, a` swaps two variables), overlaps within the collection of
> assigned-to variables occur left-to-right, sometimes resulting in confusion.

So, it does seem that this behaviour is very well defined (and is completely
expected). However, it is something to watch out for as it definitely can cause
confusion (as it did me). Panic over.

Happy Pythoning. And remember, there's no such thing as too much magic.

[aucg]: https://vovo.id.au/
[spec-7.2]: https://docs.python.org/3/reference/simple_stmts.html#assignment-statements
