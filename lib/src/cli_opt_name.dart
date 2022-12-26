// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// Extension to [String] for command-line option name manipulations
///
extension CliOptName on String {
  /// Constant for the standard option name prefix
  ///
  static final prefix = '-';

  /// Constant for the standard negative option name prefix
  ///
  static final negPrefix = '+';

  /// Internal constant for the option name test
  ///
  static final _isValidRE = RegExp(r'^\s*[\-\+]+[a-z]', caseSensitive: false);

  /// Internal constant for the sub-command name test
  ///
  static final _isValidSubCmdRE = RegExp(r'^\s*[a-z]', caseSensitive: false);

  /// Internal constant for option name cleansing
  ///
  static final _shrinkRE = RegExp(r'[\-\+]+');

  /// Checks whether the given string represents a kind of a flag
  /// indicating there is no more option name to expect
  ///
  CliOptStopMode getCliOptStopMode() {
    switch (this) {
      case '---':
        return CliOptStopMode.last;
      case '--':
        return CliOptStopMode.stop;
      default:
        return CliOptStopMode.none;
    }
  }

  /// Prepend option name with prefix depending on flag [isPositive]
  ///
  String addPrefix({bool isPositive = true}) =>
      (isEmpty ? this : (isPositive ? prefix : negPrefix)) + this;

  /// Removes all unwanted characters from the given string and convert case
  /// depending on mode specified
  ///
  String getCliOptName(CliOptCaseMode caseMode, {bool withPrefix = false}) =>
      shrinkCliOptName(withPrefix: withPrefix).toLowerCliOptName(caseMode);

  /// Returns true of the string represents potential short option name
  ///
  bool isCliOptNameShort() => shrinkCliOptName().length == 1;

  /// Returns true if the string starts with [prefix]
  ///
  bool isCliOptPositive() => startsWith(prefix);

  /// Returns true if the string represents any kind of an 'end-of-options'
  ///
  bool isCliOptStopMode() => (getCliOptStopMode() != CliOptStopMode.none);

  /// Checks whether the string can be treated as an option name
  ///
  bool isCliOptNameValid([CliOptStopMode stopMode = CliOptStopMode.none]) =>
      ((stopMode == CliOptStopMode.none) && _isValidRE.hasMatch(this));

  /// Checks whether the string can be treated as an option name
  ///
  bool isCliSubCmdValid() => _isValidSubCmdRE.hasMatch(this);

  /// Removes all unwanted characters from the given string
  ///
  String shrinkCliOptName({bool withPrefix = false}) {
    var result = replaceAll(_shrinkRE, '');
    var length = result.length;

    if (length <= 0) {
      return this;
    }

    return (withPrefix ? this[0] + result : result);
  }

  /// Breaks the string into an option name and value (without unbundling)
  ///
  List<String> splitCliOptNameValue() {
    final breakPos = indexOf('=');

    if (breakPos < 0) {
      return [this, ''];
    }

    return [substring(0, breakPos), substring(breakPos + 1)];
  }

  /// Prepends option name with prefix depending on [isPositive]
  ///
  String toFullCliOptName(bool isPositive) {
    switch (this[0]) {
      case '-':
      case '+':
        return this;
      default:
        return (isPositive ? '-' : '+') + this;
    }
  }

  /// Converts the string to lower depending on case mode
  ///
  String toLowerCliOptName(CliOptCaseMode caseMode) {
    switch (caseMode) {
      case CliOptCaseMode.lower:
        return toLowerCase();
      case CliOptCaseMode.smart:
        return (length <= 1 ? this : toLowerCase());
      default:
        return this;
    }
  }
}
