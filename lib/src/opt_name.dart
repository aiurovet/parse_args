// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

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

  /// Private: a regex to validate option name
  ///
  static final RegExp _isValid =
      RegExp('^[$prefix]+[a-z]', caseSensitive: false);

  /// Check whether a string is a valid option name
  ///
  static bool isValid(String name) => _isValid.hasMatch(name);
}
