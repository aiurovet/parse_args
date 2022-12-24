// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:file/file.dart';
import 'package:file/local.dart';

/// Helper class to accumulate Glob options then to pass
/// those as a user-defined parameter (a single object)
/// to the method like `CliOptList.toGlobValue(...)`
///
class GlobOpt {
  /// Default file system (singleton)
  ///
  static final LocalFileSystem localFileSystem = LocalFileSystem();

  /// POSIX-compatible path element separator
  ///
  static const String pathSeparatorPosix = r'/';

  /// Windows path element separator
  ///
  static const String pathSeparatorWindows = r'\';

  /// Option indicating case-sensitive search
  ///
  var caseSensitive = false;

  /// Option indicating recursive search (sub-directories)
  ///
  var recursive = false;

  /// FileSystem object to link to the glob and touse for
  /// the default case sensitivity
  ///
  late final FileSystem fileSystem;

  /// Determine file system style
  ///
  bool isPosix() => (fileSystem.path.separator == pathSeparatorPosix);

  /// Default constructor
  ///
  GlobOpt(
      {FileSystem? fileSystem, bool? caseSensitive, this.recursive = false}) {
    this.fileSystem = (fileSystem ?? localFileSystem);
    this.caseSensitive = (caseSensitive ?? isPosix());
  }
}
