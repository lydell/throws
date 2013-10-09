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

compare = (error, errorConstructor, arg=null, messageHolder={})->
	messageHolder.message = "Expected error to be an instance of `#{errorConstructor.name}`"
	return false unless error instanceof errorConstructor

	return true if arg is null

	{message} = error

	if typeof arg is "string"
		exactString = arg
		messageHolder.message = "Expected `#{message}` to exactly equal `#{exactString}`"
		return false unless message == exactString

	else
		array = arg
		for item in array
			valid =
				if typeof item is "string"
					subString = item.toLowerCase()
					messageLowerCase = message.toLowerCase()
					messageHolder.message =
						"Expected `#{subString}` to be present in `#{messageLowerCase}`"
					messageLowerCase.indexOf(subString.toLowerCase()) >= 0
				else
					regex = item
					messageHolder.message = "Expected #{regex} to match `#{message}`"
					regex.test(message)
			return false unless valid

	true

module.exports = compare
