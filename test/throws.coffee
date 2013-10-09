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
sinon  = require "sinon"

_throws = require "../src/throws"


describe "throws", ->

	beforeEach ->
		_throws.messageHolder = {}

	it "is a function", ->
		assert typeof throws is "function"


	it "requires an error instance, error constructor or a function as first argument", ->
		assert throws TypeError("instanceof Error|subclass"), -> _throws()
		assert throws TypeError("instanceof Error|subclass"), -> _throws(null)
		assert throws TypeError("instanceof Error|subclass"), -> _throws(1)
		assert throws TypeError("instanceof Error|subclass"), -> _throws("string")
		assert throws TypeError("instanceof Error|subclass"), -> _throws([1, 2])
		assert throws TypeError("instanceof Error|subclass"), -> _throws({})

		assert not throws -> _throws(new Error,     ->)
		assert not throws -> _throws(Error(),       ->)
		assert not throws -> _throws(Error,         ->)
		assert not throws -> _throws(new TypeError, ->)
		assert not throws -> _throws(TypeError(),   ->)
		assert not throws -> _throws(TypeError,     ->)

		CustomError = (args...)-> Error.apply(this, args)
		CustomError.prototype = new Error
		CustomError.constructor = CustomError
		assert not throws -> _throws(new CustomError, ->)
		assert not throws -> _throws(CustomError(),   ->)
		assert not throws -> _throws(CustomError,     ->)

		NotError = ->
		assert throws TypeError("instanceof Error|subclass"), -> _throws(new NotError, ->)
		assert throws TypeError("instanceof Error|subclass"), -> _throws(NotError(),   ->)
		assert not throws -> _throws(NotError, ->) # Same as `_throws(-> NotError(->))`.

		assert not throws -> _throws(->)


	it "requires a function as second argument (if the first argument is an error instance)", ->
		assert throws TypeError("function"), -> _throws(new Error)
		assert throws TypeError("function"), -> _throws(new Error, null)
		assert throws TypeError("function"), -> _throws(new Error, 1)
		assert throws TypeError("function"), -> _throws(new Error, "string")
		assert throws TypeError("function"), -> _throws(new Error, [1, 2])
		assert throws TypeError("function"), -> _throws(new Error, {})

		assert not throws -> _throws(new Error, ->)


	it "returns `no` if a function does not throw", ->
		assert _throws(->) is no
		assert _throws.messageHolder.message is "Expected function to throw"


	it "returns `yes` if a function does throw", ->
		assert _throws(-> throw new Error) is yes


	it "runs the function with the rest of the arguments", ->
		obj1 = {}; obj2 = {}
		fn = sinon.spy()
		_throws(fn, obj1, obj2)
		assert fn.calledWith(obj1, obj2)
		_throws(Error, fn, 1, 2, 3)
		assert fn.calledWith(1, 2, 3)


	it "calls `throws.compare` if the first argument is an error instance and the function throws", ->
		error = new Error

		sinon.spy(_throws, "compare")
		_throws(new TypeError("|message|"), -> throw error)

		assert _throws.compare.calledWith(error, TypeError, "message", _throws.messageHolder)

		_throws.compare.restore()


	it "first calls `throws.parse` and passes `throws.splitChar`", ->
		originalSplitChar = throws.splitChar
		_throws.splitChar = {}

		obj = {}

		sinon.stub(_throws, "parse").returns(obj)
		sinon.spy(_throws, "compare")

		_throws(new TypeError("|message|"), -> throw new Error)

		assert _throws.parse.calledWith("|message|", _throws.splitChar)
		assert _throws.compare.getCall(0).args[2] is obj

		_throws.splitChar = originalSplitChar
		_throws.parse.restore()
		_throws.compare.restore()


	describe "throws.splitChar", ->

		it "defaults to |", ->
			assert _throws.splitChar is "|"

