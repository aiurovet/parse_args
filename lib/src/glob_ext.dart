import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:parse_args/src/glob_opt.dart';

/// Helper to create glob objects based on file system and default
/// file system-specific flags
///
extension GlobExt on Glob {
  /// Convert [pattern] string into a proper glob object considering the required
  /// file system [fileSystem] and possible extra flags [caseSensitive] and [recursive]
  ///
  static Glob create(FileSystem fileSystem, String? pattern,
      {bool? caseSensitive, bool? recursive}) {
    var options = GlobOpt(fileSystem,
        caseSensitive: caseSensitive,
        recursive: recursive ?? GlobOpt.isRecursivePattern(pattern));

    var filter = Glob(
        ((pattern == null) || pattern.isEmpty ? GlobOpt.anyPattern : pattern),
        context: options.fileSystem.path,
        recursive: options.recursive,
        caseSensitive: options.caseSensitive);

    return filter;
  }
}