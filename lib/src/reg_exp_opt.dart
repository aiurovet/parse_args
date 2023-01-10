// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Helper class to accumulate RegExp options then to pass
/// those as a user-defined parameter (a single object)
/// to the method like `CliOptList.toRegExpValue(...)`
///
class RegExpOpt {
  /// Option indicating case-sensitive search
  ///
  var caseSensitive = true;

  /// Option indicating whether to match any character by
  /// using '.' in the whole string or only until
  /// the nearest newline character (default)
  ///
  var dotAll = false;

  /// Option indicating whether ^ and $ look for the start
  /// and the end of the whole string (default) or of every line
  ///
  var multiLine = false;

  /// Option indicating whether to search for the Unicode
  /// characters or not (this search would be slower)
  ///
  var unicode = false;

  /// Default constructor
  ///
  RegExpOpt(
      {this.caseSensitive = true,
      this.dotAll = false,
      this.multiLine = false,
      this.unicode = false});

  /// Create options from a string
  ///
  static RegExpOpt fromString(String options) => RegExpOpt(
        caseSensitive: !options.contains('i'),
        dotAll: options.contains('s'),
        multiLine: options.contains('m'),
        unicode: options.contains('u'),
      );
}
