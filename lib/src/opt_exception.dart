import 'dart:io';

///
/// Base exception class for command-line options parsing
///
class OptException implements Exception {
  String displayData = '';
  String get displayType => '';

  final String optName;
  final List? values;

  OptException(this.optName, [this.values]) {
    String displayData;

    if (values == null) {
      displayData = '';
    } else if ((values?.length ?? 0) == 1) {
      displayData = values?.first?.toString() ?? '';
    } else {
      displayData = values.toString();
    }

    displayData = '"$optName"$displayData';
  }

  @override String toString() {
    return '$displayType - $displayData';
  }

  void print() =>
    stderr.writeln(toString());
}

class OptNameException extends OptException {
  @override String get displayType => 'Invalid option';

  OptNameException(optName, [values]) : super(optName, values);
}

class OptValueExpectedException extends OptException {
  @override String get displayType => 'Expected value';

  OptValueExpectedException(optName, [values]) : super(optName, values);
}

class OptValueMissingException extends OptException {
  @override String get displayType => 'Missing value';

  OptValueMissingException(optName, [values]) : super(optName, values);
}

class OptValueTooManyException extends OptException {
  @override String get displayType => 'Too many values';

  OptValueTooManyException(optName, [values]) : super(optName, values);
}

class OptValueTypeException extends OptException {
  @override String get displayType => 'Bad value type';

  OptValueTypeException(optName, [values]) : super(optName, values);
}

class OptValueUnexpectedException extends OptException {
  @override String get displayType => 'Value is not expected ';

  OptValueUnexpectedException(optName, [values]) : super(optName, values);
}

