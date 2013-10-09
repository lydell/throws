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

parse   = require "./parse"
compare = require "./compare"


throws = (test, fn, args...)->
	switch
		when test instanceof Error
			errorConstructor = test.constructor
		when test?.prototype instanceof Error or test is Error
			errorConstructor = test
		when typeof test is "function"
			args.unshift(fn)
			fn = test
			test = null
		else
			throw new TypeError """
				`test` must be an error instance (`test instanceof Error`),
				or an error constructor (a subclass of `Error` or `Error` itself).
				"""

	# If `fn` happens not to be a function, trying to call it below will throw, and the error will
	# be caught, which will produce confusion. So we must make sure it really is a function first.
	unless typeof fn is "function"
		throw new TypeError "`fn` must be a function."

	try
		fn(args...)
		throws.messageHolder.message = "Expected function to throw"
		return no
	catch error
		return yes unless test

	arg = throws.parse(test.message ? "", throws.splitChar)
	throws.compare(error, errorConstructor, arg, throws.messageHolder)

throws.parse     = parse
throws.compare   = compare
throws.splitChar = "|"
throws.messageHolder = {}

switch
	when typeof define is "function" and define.amd
		define(throws)
	when typeof module is "object"
		module.exports = throws
	else
		@throws = throws
