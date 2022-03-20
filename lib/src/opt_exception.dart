// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Base exception class for command-line options parsing
///
class OptException implements Exception {
  /// Free text explaining what is this exception about
  ///
  String get description => '';

  /// Option name and values stringized
  ///
  String details = '';

  /// Option name
  ///
  final String name;

  /// Option values
  ///
  final List? values;

  /// Exception's constructor: mandatory option [name] and the list of values if relevant
  ///
  OptException(this.name, [this.values]) {
    var hasValue = (values?.isNotEmpty ?? false);
    details = '"$name"${hasValue ? ': ${values.toString()}' : ''}';
  }

  /// An override of the default toString() showing explanation and data
  ///
  @override
  String toString() {
    return '$description $details';
  }
}

/// When encountered an unrecognised option
///
class OptNameException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Undefined option';

  /// Specific constructor
  ///
  OptNameException(optName) : super(optName);
}

/// When encountered an option with no value
///
class OptValueMissingException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Missing value for the option';

  /// Specific constructor
  ///
  OptValueMissingException(optName) : super(optName);
}

/// When encountered an option with more than one value when only one expected
///
class OptValueTooManyException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Too many values for the option';

  /// Specific constructor
  ///
  OptValueTooManyException(optName, [values]) : super(optName, values);
}

/// When failed either to recognise the verb or to parse the string value
///
class OptValueTypeException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Bad value type for the option';

  /// Specific constructor
  ///
  OptValueTypeException(optName, [values]) : super(optName, values);
}

/// When encountered an option with value(s) instead of a flag
///
class OptValueUnexpectedException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Value is not expected for the option';

  /// Specific constructor
  ///
  OptValueUnexpectedException(optName, [values]) : super(optName, values);
}
