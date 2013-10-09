###
Copyright 2013 Simon Lydell

This file is part of throws.

throws is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

throws is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General
Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with throws. If not,
see <http://www.gnu.org/licenses/>.
###

{assert, throws, equal} = require "./common"

parse = require "../src/parse"


describe "parse", ->

	it "is a function", ->
		assert typeof parse is "function"


	it "requires a string as first argument", ->
		assert throws TypeError("string"), -> parse()
		assert throws TypeError("string"), -> parse(null)
		assert throws TypeError("string"), -> parse(1)
		assert throws TypeError("string"), -> parse([1, 2])
		assert throws TypeError("string"), -> parse({})

		assert not throws -> parse("string", "|")


	it "requires a single character as second argument", ->
		assert throws Error("single character"), -> parse("string")
		assert throws Error("single character"), -> parse("string", null)
		assert throws Error("single character"), -> parse("string", 1)
		assert throws Error("single character"), -> parse("string", [1, 2])
		assert throws Error("single character"), -> parse("string", {})
		assert throws Error("single character"), -> parse("string", "")
		assert throws Error("single character"), -> parse("string", "12")

		assert not throws -> parse("string", "1")


	it "requires the first argument not to equal the second argument", ->
		assert throws Error("not|only|splitChar"), -> parse("1", "1")
		assert not throws -> parse("2", "1")


	it "returns the string basically unaltered if it starts and ends with the split character", ->
		assert parse("|/could have been a regex | contains the split character/|", "|") is
			"/could have been a regex | contains the split character/"


	it "returns an array otherwise", ->
		assert parse("", "|").constructor is Array


	it "splits on the split character", ->
		assert equal parse("abc", "|"), ["abc"]
		assert equal parse("a|b|c|", "|"), ["a", "b", "c", ""]
		assert equal parse("a;b;c;", ";"), ["a", "b", "c", ""]


	it "treats a substring as a regex if it starts with something regex-like", ->
		assert equal parse("/a/g", "|"), [/a/g]
		assert equal parse("/a/g| /a/g|/b/", "|"), [/a/g, " /a/g", /b/]


	it "handles escaped slashes", ->
		assert equal parse("/a\\/g/|/a\\\\/g", "|"), [/a\/g/, /a\\/g]


	it "allows regexes to contain the split character", ->
		assert equal parse("/a|b/|/[^|]/", "|"), [/a|b/, /[^|]/]


	it "allows escaping from treating as a regex by doubling the initial slash", ->
		assert equal parse("//", "|"), ["/"]
		assert equal parse("//a/", "|"), ["/a/"]
		assert equal parse("///a/", "|"), ["//a/"]
		assert equal parse("////a/", "|"), ["///a/"]


	it "implicitly throws errors for invalid regexes (including their modifiers)", ->
		assert throws SyntaxError,          -> parse("/(/", "|")
		assert throws SyntaxError("flags"), -> parse("/a/o", "|")
		assert throws SyntaxError("flags"), -> parse("/a//;%", "|")


	it "throws an error for unterminated regexes", ->
		assert throws SyntaxError("unterminated"), -> parse("/", "|")
		assert throws SyntaxError("unterminated"), -> parse("foo|/a", "|")
		assert throws SyntaxError("unterminated"), -> parse("foo|/a\\/", "|")
