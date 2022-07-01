// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// A class which holds a single option definition
/// It will be used to look for every option while going through the list
/// of application arguments as well as validate its name and possible values
///
class OptName {
  /// Name as indicator of multiple runs over the list of arguments
  /// (used in the beginning of the options definition string)
  ///
  static const multiRun = '+';

  /// Option for 'no more argument should be treated as an option name, but rather added as a value to the last option'
  ///
  static const noMore = '$prefix$prefix$prefix';

  /// Name for the plain args
  ///
  static const plainArgs = '';

  /// Constant option name prefix
  ///
  static const prefix = '-';

  /// Constant name/value separator
  ///
  static const valueSeparator = '=';

  /// Option for 'plain arguments only beyond this point'
  ///
  static const stop = '$prefix$prefix';

  /// Private: regex to validate option name
  ///
  static final RegExp _isValidRE =
      RegExp('^[$prefix]+[a-z\\?\\-]', caseSensitive: false);

  /// Private: regex for an option definition name
  ///
  static final RegExp _normalizeRE = RegExp('[\\s\\$prefix]');

  /// Get the kind of end-of-options sign
  ///
  static OptNameStopMode getStopMode(String arg) {
    if (arg == noMore) {
      return OptNameStopMode.stop;
    }
    if (arg == stop) {
      return OptNameStopMode.stopAndDrop;
    }
    return OptNameStopMode.none;
  }

  /// Check whether a string is a valid option name
  ///
  static bool isValid(String name) => _isValidRE.hasMatch(name);

  /// Make a normalized option from [name]: no space, no dash, lowercase
  ///
  static String normalize(String name,
      [OptNameCaseMode caseMode = OptNameCaseMode.smart]) {
    var result = name.replaceAll(_normalizeRE, '');

    switch (caseMode) {
      case OptNameCaseMode.force:
        return result;
      case OptNameCaseMode.smart:
        return (result.length <= 1 ? result : result.toLowerCase());
      default:
        return result.toLowerCase();
    }
  }
}
