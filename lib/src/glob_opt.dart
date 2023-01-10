// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:file/file.dart';

/// Helper class to accumulate Glob options then to pass
/// those as a user-defined parameter (a single object)
/// to the method like `CliOptList.toGlobValue(...)`
///
class GlobOpt {
  /// A pattern to list any file system element
  ///
  static const anyPattern = r'*';

  /// Option indicating case-sensitive search
  ///
  var caseSensitive = false;

  /// Option indicating recursive search (sub-directories)
  ///
  var recursive = false;

  /// FileSystem object to link to the glob and to use for its default case
  /// sensitivity. It is required in order to encourage the use of a singleton
  ///
  final FileSystem fileSystem;

  // PRIVATE AREA

  /// A pattern to locate a combination of glob characters which means recursive directory scan
  ///
  static final _isRecursiveGlobPatternRegex =
      RegExp(r'\*\*|[\*\?][\/\\]', caseSensitive: false);

  // METHODS

  /// Default constructor
  ///
  GlobOpt(this.fileSystem, {bool? caseSensitive, this.recursive = false}) {
    this.caseSensitive = caseSensitive ?? !fileSystem.path.equals('A', 'a');
  }

  /// Check whether [pattern] indicates recursive directory scan
  ///
  static bool isRecursivePattern(String? pattern) =>
      (pattern != null) && _isRecursiveGlobPatternRegex.hasMatch(pattern);
}
