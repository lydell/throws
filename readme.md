[![Build Status](https://travis-ci.org/lydell/throws.png?branch=master)](https://travis-ci.org/lydell/throws)

Overview
========

Test if a function throws or not, and optionally if it throws the right thing.

Created to ease testing of errors when using [yaba], but can be used anywhere you'd like.

```javascript
function fn(arg) {
	if (typeof arg !== "number") {
		throw new TypeError("The argument is invalid. " + arg + " is not a number.")
	}
}

// The following assertions pass.

assert(throws(fn))
assert(throws(TypeError, fn))
assert(throws(TypeError("the argument"), fn)) // Note case insensitivity.
assert(throws(TypeError(/invalid|is not/), fn, "args", "to", "be", "passed", "to", fn))

// The following assertions do not pass (wrong error type, non-matching message).

assert(throws(Error("contains|both these strings"), fn))
assert(throws(Error("|matches this exact string|"), fn))
assert(throws(Error("contains this string|" + /and matches this regex/i), fn))
assert(throws(Error("contains this string|/and matches this regex/i"), fn))

throws.splitChar = ";"
assert(throws(Error("using a different split character, so that a pipe (|) can be matched"), fn))
throws.splitChar = "|"
assert(throws(Error(/regexes never have to worry about pipes [|], though/), fn))
throws.splitChar = ","
assert(throws(Error(["using a comma as split character", "allows for using", /an array/]), fn))

// Note that you can put `new` in front of `Error` and `TypeError` if you think that reads better.
```

What it can look like in CoffeeScript:

```coffeescript
assert throws Error("string|#{/regex/}|string2"), -> fn("invalid", "args")
```

[yaba]: https://github.com/lydell/yaba


Installation
============

`npm install throws` or `component install lydell/throws`

CommonJS: `var throws = require("throws")`

AMD and regular old browser globals: Use ./throws.js


Tests
=====

Node.js: `npm test`

Browser: Open ./test/browser/index.html


Usage
=====

`throws(fn, ...args)`
---------------------

Runs `fn(...args)`. Returns `true` if it throws. Otherwise `false`.

`throws(test, fn, ...args)`
---------------------------

Runs `fn(...args)`. Returns `false` if it does not throw. Otherwise the caught `error` is compared
to `test`.

First off, `test` must be one of two things:

  - An error instance (`test instanceof Error`). If so, `error instanceof test.constructor` is
    checked.
  - An error constructor (a subclass of `Error` or `Error` itself). If so, `error instanceof test`
    is checked.

Secondly, the `message` properties (if any) of `error` and `test` are compared. `test.message` is a
pipe ("|") separated string of substrings and regexes. `error.message` must contain all substrings,
case insensitively, and match all regexes.

  - To keep things simple, a substring cannot contain a pipe ("|")—there are no escape rules.
    Instead there is the possibility to change it to something else, via **`throws.splitChar`**.

  - It is, however, possible to escape a regex. They are recognized by a substring beginning with a
    slash ("/"). Double it to denote an actual substring starting with a slash: `"/a/"` is the regex
    `/a/`, while `"//a/"` is the substring `"/a/"`.

  - If the string starts and ends with a pipe, the **whole** `message` property of the error must
    exactly match the string.

If both these tests pass, `true` is returned. Otherwise `false`.

`throws.messageHolder`
----------------------

When throws returns `false`, it sets `throws.messageHolder.message` to a string explaining why it
did so. This way, you could let other tools use that information.

For example, if you use [yaba], you can set `throws.messageHolder = yaba`. Then yaba will put the
reason the throws test failed in its assertion errors.


Background
==========

I like testing with `assert`, but testing error throwing without a helper function is cumbersome. I
wanted something that fit well with the use of a simple assert function, and let me check the type
of the error, and that certain important key words were present in the error message. After a while
I came up with the idea of comparing to another error instance. Initially I thought about passing an
array of substrings and regexes (`new Error(["a", "b", /c/])`), but I then realized that the message
is always converted to a string. After finding out that `.toString()` on regexes give a perfect
representation, I understood that it was still possible (and I enjoyed parsing the string!). Best of
all is that passing `new Error(/my regex/i)` is totally possible—it looks really nice!


"But I want to check more things on my errors!"
===============================================

Then `throws` probably isn't for you (but don't hesitate to open new issues about it). Either find
something else, or use a good old try/catch:

```javascript
var error
try {fn(invalid, args)}
catch(err) {error = err}
assert(error && error.lineNumber === 4)
```

```coffeescript
try fn(invalid, args)
catch error
assert error?.lineNumber is 4
```


License
=======

[LGPLv3](COPYING).
