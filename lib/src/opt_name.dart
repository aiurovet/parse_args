// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

enum OptNameStopMode { none, stop, stopAndDrop }

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

  /// Option for 'plain arguments only beyond this point'
  ///
  static const stop = '$prefix$prefix';

  /// Private regex to validate option name
  ///
  static final RegExp _isValid =
      RegExp('^[$prefix]+[a-z\\?\\-]', caseSensitive: false);

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
  static bool isValid(String name) => _isValid.hasMatch(name);
}
