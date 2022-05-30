// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

enum OptNameStopMode { none, stop, stopAndDrop }

/// A class which holds a single option definition
/// It will be used to look for every option while going through the list
/// of application arguments as well as validate its name and possible values
///
class OptName {
  /// A constant option name prefix
  ///
  static const prefix = '-';

  /// An option meaning 'no more option'
  ///
  static const stop = '$prefix$prefix';

  /// An option meaning 'no more option and drop the last option name'
  ///
  static const stopAndDrop = '$stop$prefix';

  /// Private: a regex to validate option name
  ///
  static final RegExp _isValid =
      RegExp('^[$prefix]+[a-z\\?\\-]', caseSensitive: false);

  /// Get the kind of end-of-options sign
  ///
  static OptNameStopMode getStopMode(String arg) {
    if (arg == stop) {
      return OptNameStopMode.stop;
    }
    if (arg == stopAndDrop) {
      return OptNameStopMode.stopAndDrop;
    }
    return OptNameStopMode.none;
  }

  /// Check whether a string is a valid option name
  ///
  static bool isValid(String name) => _isValid.hasMatch(name);
}
