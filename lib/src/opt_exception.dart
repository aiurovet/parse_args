// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'dart:io';

///
/// Base exception class for command-line options parsing
///
class OptException implements Exception {
  String get description => '';

  String details = '';
  final String name;
  final List? values;

  OptException(this.name, [this.values]) {
    var hasValue = (values?.isNotEmpty ?? false);
    details = '"$name"${hasValue ? ': ${values.toString()}' : ''}';
  }

  @override
  String toString() {
    return '$description - $details';
  }

  void print() => stderr.writeln(toString());
}

///
/// When encountered an unrecognised option
///
class OptNameException extends OptException {
  @override
  String get description => 'Invalid option';

  OptNameException(optName) : super(optName);
}

///
/// When encountered an option with no value
///
class OptValueMissingException extends OptException {
  @override
  String get description => 'Missing value';

  OptValueMissingException(optName) : super(optName);
}

///
/// When encountered an option with more than one value when only one expected
///
class OptValueTooManyException extends OptException {
  @override
  String get description => 'Too many values';

  OptValueTooManyException(optName, [values]) : super(optName, values);
}

///
/// When failed either to recognise the verb or to parse the string value
///
class OptValueTypeException extends OptException {
  @override
  String get description => 'Bad value type';

  OptValueTypeException(optName, [values]) : super(optName, values);
}

///
/// When encountered an option with value(s) instead of a flag
///
class OptValueUnexpectedException extends OptException {
  @override
  String get description => 'Value is not expected ';

  OptValueUnexpectedException(optName, [values]) : super(optName, values);
}
