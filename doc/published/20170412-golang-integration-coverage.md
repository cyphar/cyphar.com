title: Generating Coverage Profiles for Golang Integration Tests
author: Aleksa Sarai
published: 2017-04-12 15:30:00
updated: 2017-04-12 15:30:00
short_description: >
  An interesting hack I figured out to give you far more coverage information
  for your test suite, by abusing test packages and a splash of AWK.
description: >
  While Go's system for unit tests is very seamless and full-featured, allowing
  for coverage reports to be generated as well as various other cool features,
  the integration testing story is far less full-featured. In particular, most
  projects don't use `go test` for integration tests and thus don't have a full
  picture of how their entire test suite stands in terms of code coverage.
tags:
  - free software
  - golang
  - testing

I think most developers agree that testing is quite important, and we all know
that there is no single style of testing that "fits all". In particular, many
projects use a combination of unit tests and integration tests (as well as many
additional tests such as conformance or end-to-end tests, but those are just
large forms of integration tests at the end of the day). In different
languages, the line between integration and unit tests shifts quite a bit, but
in Go the line is quite clear.

To be clear, when I refer to "integration testing" I'm referring to taking a
compiled Go binary and making sure it acts in a way that a user might expect.
Some people call this "end-to-end testing" with integration testing referring
to the testing of discrete modules rather than functions. While this might be a
more accurate description, I'm more used to calling them "integration tests".

If you want to create unit tests, use `go test` and the `testing` package
available in the standard library. Because the concept of testing is built into
the compiler, `go test` gives users many features they expect from unit testing
frameworks such as coverage analysis. However, the integration testing story
is much less full-featured. In the projects I maintain and contribute to,
generic integration testing frameworks like [`bats`][bats] are used to test
binaries. So, how can we get some of the cool features from `go test` in our
integration tests?

[bats]: https://github.com/sstephenson/bats

### How `go test` Works ###

Before we get into the nuts and bolts of how to add coverage profiles to
integration tests, it's helpful to know what `go test` is actually doing. For
anyone unfamiliar with how Go unit tests work, the general idea is that you
call `go test` on a particular package and the unit tests in that package are
executed. In effect `go test` is a modified compilation pipeline that adds all
of the code that runs unit tests (and rather than executing your `main.main`
function it runs the `go test` code). Unit tests are stored in source files
that have names ending with `_test.go` (which are not compiled normally) and
are filled with code that looks like this:

```language-go
package thepackage

import "testing"

func TestThisIsATest(t *testing.t) {
	// Test contents here. @t has a bunch of methods that can be used to
	// control the test run and pass/fail the current test. All unit tests must
	// have a function name starting with "Test".
}
```

And you can get this special "test binary" if you pass `-c -o <file>` to `go
test`, allowing you to run the tests separately (without recompiling the source
code each time). As an aside, this is how we build our `docker.test` binaries
for openSUSE so that we can run the integration tests on a separate system from
where the source code and packages were built. Note that the test binary will
only include the tests in the package that you explicitly state in the package
line (imported packages won't have their tests run implicitly).

While this is all pretty standard there doesn't appear to be any clear benefit
to using `go test` for integration here, since it seems to just be running a
series of functions (that happen to not be `main.main`). However, this changes
quite drastically when it comes to code coverage reports. For a full
understanding of how coverage profiles are generated in Go, [here's the Go blog
explaining it][go-blog-cover]. The basic gist is that when you pass `-cover` to
`go test` the compiler will add a bunch of instrumentation to your source code
to count how often a line of code was executed. Unfortunately it's not (easily)
possible to get this cover tool to generate such instrumentation using `go
build`. So if you want code coverage you need to use `go test`.

[go-blog-cover]: https://blog.golang.org/cover

### Turning `main` Into a Test ###

Since we can compile a test binary and execute it, the obvious solution to
having coverage profiles for your "real binary" would be to just create a
`main_test.go` file in your `main` package:

```language-go
package main

import "testing"

func TestMain(t *testing.T) {
	main()
}
```

Simple, right? *Blog post over, everyone!* Well, not quite. There are quite a
few problems with this naive solution that need to be handled in order for this
hack to work properly. The first problem will hit you pretty quickly, as soon
as you try to run your normal unit tests (assuming you're doing the standard
"recursive, run-all-tests" `go test` incantations):

```language-bash
% go test -v scm/your/project/...
[ the rest of your tests ]
=== RUN   TestProject
[ your help page ]
--- FAIL: TestProject (0.00s)
FAIL    scm/your/project/cmd/project     0.003s
```

This one is pretty easy to solve. You just need to do something like this,
which will work for most usecases (the final version is more robust, this is
just as an example).

```language-go
package main

import (
	"os"
	"testing"
)

func TestMain(t *testing.T) {
	if os.Args[0] == "your-binary-name" {
		main()
	}
}
```

Effectively your `main` test will only run if `argv[0]` is
`"your-binary-name"`, which shouldn't be true when you use `go test`. So now
your normal unit tests should be unaffected.

The next issue you will probably run into is that if your program accepts
Unix-style flags you'll find that `go test` has its own set of flags and flag
parsing code. And it definitely doesn't like your flags. Luckily, we have a few
saving graces:

* Go is kind enough to follow C and allow us to modify `os.Args` (it's just a
  global slice, not some weird getter function that we couldn't mess with).

* `go test`s flag parsing code will halt if it hits a non-flag. Unfortunately
  it will error our if it hits an unknown flag, but that's easily resolved.
  Note that all `go test` flags are also prefixed as `-test`.

* In addition, `go test` does not modify `os.Args` when it does its flag
  parsing.

So in order to make `go test` binaries behave while also allowing our own flags
to be passed un-touched to our un-modified `main` function, we can do the
following:

```language-go
func TestMain(t *testing.T) {
	var args []string
	for _, arg := range os.Args {
		if !strings.HasPrefix(arg, "-test") {
			args = append(args, arg)
		}
	}
	os.Args = args

	if os.Args[0] == "your-binary-name" {
		main()
	}
}
```

In order for this to run properly though, you'll have to call your program like
this:

```language-bash
% go test -c -o your-binary-name scm/your/project/cmd/project
% ./your-binary-name -test.v dummy-argument-to-end-parsing --your-flags
[ your program ]
```

Most programs wouldn't like this style of interface (your `main` function would
see the `dummy-argument-to-end-parsing` argument) and you shouldn't have to
modify your `main` to make it work. So to make it cleaner we can define a
"flag" (though it can't start with `-`) that specifies that we want to run the
`TestMain` test.

```language-go
func TestMain(t *testing.T) {
	var (
		args []string
		run  bool
	)

	for _, arg := range os.Args {
		switch {
		case arg == "__DEVEL--i-heard-you-like-tests":
			run = true
		case strings.HasPrefix(arg, "-test"):
		case strings.HasPrefix(arg, "__DEVEL"):
		default:
			args = append(args, arg)
		}
	}
	os.Args = args

	if run {
		main()
	}
}
```

This is the same function [we use in `umoci`][umoci-TestUmoci], and it works
pretty well. However, if you want to actually profile your entire codebase and
also accumulate multiple test runs you need some extra tricks.

[umoci-TestUmoci]: https://github.com/opencontainers/umoci/blob/v0.4.6/cmd/umoci/main_test.go

### Coverage Profiles ###

Now that we have a `go test` binary that actually works, it's important to make
sure that the cover instrumentation is added to all of the packages we care
about -- otherwise we're only going to be instrumenting the `main` package
(which isn't very useful). Luckily there's a flag for that that can be provided
during building: `-covermode=./...`. You can also specify
`scm/your/project/...` as the package list if you prefer to be explicit.

But now that you have all of this coverage instrumentation, how are you mean to
make sense of it? A new coverage profile will be created for each execution of
your `go test` binary. Unless you have some very weird development style, it's
unlikely that your program can test all of its code paths with a single
invocation. So, you'll need to collate the various coverage profiles so you get
a cohesive picture of what the *actual* code coverage is in aggregate. Luckily
this will also allow you to add the coverage profiles from your unit tests to
the mix as well (giving you a full-picture view of what lines of code have been
tested by some test).

First you need to specify `-covermode=count` when compiling your binary (this
is the default but better explicit than sorry). Then for each invocation of
your test binary you need to specify a **unique** path for the coverage profile
with `-test.coverprofile=path`. I wrote the following `awk` script [for
`umoci`][umoci-collate.awk] that will read a bunch of concatenated coverage
profiles and output a "super profile" that combines everything.

```language-awk
# collate.awk allows you to collate a bunch of Go coverprofiles for a given
# binary (generated with -test.coverprofile), so that the statistics actually
# make sense. The input to this function is just the concatenated versions of
# the coverage reports, and the output is the combined coverage report.
#
# NOTE: This will _only_ work on coverage binaries compiles with
# -covermode=count. The other modes aren't supported.

{
	# Every coverage file in the set will start with a "mode:" header. Just make
	# sure they're all set to "count".
	if ($1 == "mode:") {
		if ($0 != "mode: count") {
			print "Invalid coverage mode", $2 > "/dev/stderr"
			exit 1
		}
		next
	}

	# The format of all other lines is as follows.
	#   <file>:<startline>.<startcol>,<endline>.<endcol> <numstmt> <count>
	# We only care about the first field and the count.
	statements[$1] = $2
	counts[$1] += $3
}

END {
	print "mode: count"
	for (block in statements) {
		print block, statements[block], counts[block]
	}
}
```

[umoci-collate.awk]: https://github.com/opencontainers/umoci/blob/v0.4.6/hack/collate.awk

### Conclusion ###

All-in-all with a few hacks and messing around with Go's unit test builder you
can create a special binary that will generate coverage profiles for normal
execution of your binary. [`umoci`][umoci] has been using this for a while now,
and it's been working pretty well.

There are various tools you can use to actually understand the final collated
coverage profile such as `go tool cover` which even allows you to generate a
fancy static HTML page (with `-html`) that shows your codebase with text
colouring indicating how many times a particular line of code was executed in
your tests. Within `umoci`'s extensive test suite we output [a final coverage
profile for `umoci`][umoci-coverage-example] so we can keep track of the code
coverage percentages. Hopefully you can use something similar for your own
projects.

Hope you enjoyed and happy hacking!

[umoci]: https://umo.ci/
[umoci-coverage-example]: https://travis-ci.org/opencontainers/umoci/jobs/221181536#L1846-L2074
