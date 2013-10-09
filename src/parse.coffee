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

regexRegex = ///
	^
	/
	(
		(?:
			\\[\s\S] # An escape sequence: a backslash followed by anything
			|        # or
			[^\\/]   # anything but slash and backslash.
		)+
	)
	/
	///

parse = (string, splitChar)->
	unless typeof string is "string"
		throw new TypeError "`string` must be a string."

	unless typeof splitChar is "string" and splitChar.length is 1
		throw new Error "`splitChar` must be a single character."

	if string is splitChar
		throw new Error "`string` must not contain only `splitChar`."

	if string[0] is splitChar and string[string.length-1] is splitChar
		exactString = string[1...-1]
		return exactString

	reachedEnd = no
	until reachedEnd
		isRegex = string[0] is "/" and string[1] isnt "/"

		if isRegex
			match = string.match(regexRegex)
			unless match
				throw new SyntaxError "Unterminated regular expression: #{string}"
			[wholeMatch, regex] = match
			string = string[wholeMatch.length..]

		splitCharPos = string.indexOf(splitChar)
		if splitCharPos is -1
			splitCharPos = string.length
			reachedEnd = yes

		subString = string[...splitCharPos]
		string = string[splitCharPos+1..]

		if isRegex
			modifiers = subString
			RegExp(regex, modifiers)
		else
			# Support escaping of regex by doubling the initial slash.
			subString.replace(/// ^/{2,} ///, (slashes)-> slashes[1..])

module.exports = parse
