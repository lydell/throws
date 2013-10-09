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

assert = require "assert"
throws = require "throws"

compare = require "../src/compare"


describe "compare", ->

	it "is a function", ->
		assert typeof compare is "function"


	it "returns `false` if the passed error is not an instance of the passed constructor", ->
		obj = {}
		class Foo
		class Bar
			name: "Bar"
		assert compare(new Foo, Bar, null, obj) is false
		assert obj.message is "Expected error to be an instance of `Bar`"


	it "implicitly throws errors for invalid error constructors", ->
		assert throws TypeError, -> compare()
		assert throws TypeError, -> compare(null)
		assert throws TypeError, -> compare(null, null)
		assert throws TypeError, -> compare(null, "string")
		assert throws TypeError, -> compare(null, [1, 2])
		assert throws TypeError, -> compare(null, {})


	it """otherwise proceeds with other comparison based on the type of third argument, which may be
	   omitted, which means that no further comparison is needed and `true` will be returned""", ->
		class Foo
		assert compare(new Foo, Foo) is true
		assert compare(new Foo, Foo, null) is true


	describe "string", ->

		it "checks if the entire error message is equal to the passed string", ->
			obj = {}
			assert compare({message: "other"},   Object, "string", obj) is false
			assert obj.message is "Expected `other` to exactly equal `string`"
			assert compare({message:  "string"}, Object, "string") is true
			assert compare((new Error "string"), Error,  "string") is true


	describe "array", ->

		it """checks if the error message contains all of the substrings, case insensitively, and
		   matches all regexes in the passed array""", ->
			obj = {}
			assert compare({message: "Other"}, Object, ["A", "b", /a/i, /B/], obj) is false
			assert obj.message is "Expected `a` to be present in `other`"
			assert compare({message: "A b"},   Object, ["A", "b", /a/i, /B/], obj) is false
			assert obj.message is "Expected /B/ to match `A b`"
			assert compare({message: "a B"},   Object, ["A", "b", /a/i, /B/]) is true
			assert compare((new Error "a B"),  Error,  ["A", "b", /a/i, /B/]) is true


		it "throws errors if the array contains things other than strings and regexes", ->
			assert throws -> compare({message: ""}, Object, [null])
			assert throws -> compare({message: ""}, Object, [1])
			assert throws -> compare({message: ""}, Object, [[]])
			assert throws -> compare({message: ""}, Object, [{}])

			# The regex test is duck typed.
			assert not throws -> compare({message: ""}, Object, [{test: ->}])
