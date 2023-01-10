// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Base exception class for command-line options parsing
///
class CliOptException implements Exception {
  /// Free text explaining what is this exception about
  ///
  String get description =>
      (name.isEmpty ? descriptionForArg : descriptionForOpt);

  /// Explanation for a plain argument
  ///
  String get descriptionForArg => '';

  /// Explanation for an option
  ///
  String get descriptionForOpt => '';

  /// Option name and values stringized
  ///
  late final String details;

  /// Option name
  ///
  final String name;

  /// Option values
  ///
  final List? values;

  /// Exception's constructor: mandatory option [name] and the list of values if relevant
  ///
  CliOptException([this.name = '', this.values]) {
    var details = '"$name"';

    final length = values?.length ?? 0;

    if (length == 0) {
      this.details = details;
      return;
    }

    details += ': ';

    if (length == 1) {
      details += values![0].toString();
    } else {
      details += values.toString();
    }

    this.details = details;
  }

  /// An override of the default toString() showing explanation and data
  ///
  @override
  String toString() => details.isEmpty ? description : '$description $details';
}

/// When encountered a sub-option name containing invalid characters
///
class CliOptBadSubNameException extends CliOptException {
  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt => 'Bad sub-option name';

  /// Specific constructor
  ///
  CliOptBadSubNameException(super.optName);
}

/// When encountered a long option name consisting of some short option
/// names only (might happen only if smart bundling is turned on)
///
class CliOptLongNameAsBundleException extends CliOptException {
  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt => 'Bad long option name';

  /// Specific constructor
  ///
  CliOptLongNameAsBundleException(super.optName);
}

/// When encountered an unrecognised option
///
class CliOptUndefinedNameException extends CliOptException {
  /// Explanation for a plain argument
  ///
  @override
  String get descriptionForArg => 'Plain arguments are not supported';

  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt => 'Undefined option';

  /// Specific constructor
  ///
  CliOptUndefinedNameException(super.optName, [super.values]);
}

/// When encountered an option with no value
///
class CliOptValueMissingException extends CliOptException {
  /// Explanation for a plain argument
  ///
  @override
  String get descriptionForArg => 'Missing plain argument(s)';

  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt => 'Missing value for the option';

  /// Specific constructor
  ///
  CliOptValueMissingException(super.optName);
}

/// When encountered an option with more than one value when only one expected
///
class CliOptValueTooManyException extends CliOptException {
  /// Explanation for a plain argument
  ///
  @override
  String get descriptionForArg => 'Too many plain arguments';

  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt => 'Too many values for the option';

  /// Specific constructor
  ///
  CliOptValueTooManyException(super.optName, [super.values]);
}

/// When failed either to recognise the verb or to parse the string value
///
class CliOptValueTypeException extends CliOptException {
  /// Name of the type
  ///
  final String? typeName;

  /// Explanation for a plain argument
  ///
  @override
  String get descriptionForArg => 'Failed to parse plain $typeName argument';

  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt =>
      'Failed to parse $typeName value for the option';

  /// Specific constructor
  ///
  CliOptValueTypeException(super.optName, this.typeName, [super.values]);
}

/// When encountered an option with value(s) instead of a flag
///
class CliOptValueUnexpectedException extends CliOptException {
  /// Explanation for a plain argument
  ///
  @override
  String get descriptionForArg => 'Plain argument is not expected';

  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt => 'Value is not expected for the option';

  /// Specific constructor
  ///
  CliOptValueUnexpectedException(super.optName, [super.values]);
}

/// When encountered an unrecognised option
///
class CliSubOptMismatchException extends CliOptException {
  /// Explanation for a plain argument
  ///
  @override
  String get descriptionForArg => 'Plain arguments do not have a sub-option';

  /// Explanation for an option
  ///
  @override
  String get descriptionForOpt =>
      'Option "$parentOptName" does not have a sub-option';

  /// Name of the option containing [name] as a sub-option
  ///
  final String parentOptName;

  /// Specific constructor
  ///
  CliSubOptMismatchException(this.parentOptName, super.optName);
}
