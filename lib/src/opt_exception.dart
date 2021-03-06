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
  OptException([this.name = '', this.values]) {
    details = '"$name"';

    if (values?.isNotEmpty ?? false) {
      details += ': ';
      details += values.toString();
    }
  }

  /// An override of the default toString() showing explanation and data
  ///
  @override
  String toString() => details.isEmpty ? description : '$description $details';
}

/// When encountered a long option name consisting of some short option
/// names only (might happen only if smart bundling is turned on)
///
class OptBadLongNameException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Bad long name option';

  /// Specific constructor
  ///
  OptBadLongNameException(super.optName);
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
  OptNameException(super.optName);
}

/// When plain arguments are not supported
///
class OptPlainArgException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Plain arguments are not supported';

  /// Specific constructor
  ///
  OptPlainArgException();
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
  OptValueMissingException(super.optName);
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
  OptValueTooManyException(super.optName, [super.values]);
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
  OptValueTypeException(super.optName, [super.values]);
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
  OptValueUnexpectedException(super.optName, [super.values]);
}

/// When encountered an unrecognised option
///
class SubOptMismatchException extends OptException {
  /// Name of the option containing [name] as a sub-option
  ///
  final String parentOptName;

  /// An implementation of the explanation
  ///
  @override
  String get description =>
      'Option "$parentOptName" does not have a sub-option';

  /// Specific constructor
  ///
  SubOptMismatchException(this.parentOptName, super.optName);
}

/// When encountered an unrecognised option
///
class SubOptOrphanException extends OptException {
  /// An implementation of the explanation
  ///
  @override
  String get description => 'Sub-option does not belong to any option';

  /// Specific constructor
  ///
  SubOptOrphanException(super.optName);
}
