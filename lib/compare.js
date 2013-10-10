// Generated by CoffeeScript 1.6.3
/*
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
*/

var compare;

compare = function(error, errorConstructor, arg, messageHolder) {
  var array, exactString, item, message, messageLowerCase, regex, subString, valid, _i, _len;
  if (arg == null) {
    arg = null;
  }
  if (messageHolder == null) {
    messageHolder = {};
  }
  messageHolder.message = "Expected error to be an instance of `" + errorConstructor.name + "`";
  if (!(error instanceof errorConstructor)) {
    return false;
  }
  if (arg === null) {
    return true;
  }
  message = error.message;
  if (typeof arg === "string") {
    exactString = arg;
    messageHolder.message = "Expected `" + message + "` to exactly equal `" + exactString + "`";
    if (message !== exactString) {
      return false;
    }
  } else {
    array = arg;
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      item = array[_i];
      valid = typeof item === "string" ? (subString = item.toLowerCase(), messageLowerCase = message.toLowerCase(), messageHolder.message = "Expected `" + subString + "` to be present in `" + messageLowerCase + "`", messageLowerCase.indexOf(subString.toLowerCase()) >= 0) : (regex = item, messageHolder.message = "Expected " + regex + " to match `" + message + "`", regex.test(message));
      if (!valid) {
        return false;
      }
    }
  }
  return true;
};

module.exports = compare;