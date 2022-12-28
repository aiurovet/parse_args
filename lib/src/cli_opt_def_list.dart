// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// Extension methods to manipulate option definitions lists
///
extension CliOptDefList on List<CliOptDef> {
  /// Regular expression to remove all blank characters: space, tab, newline
  ///
  static final _blankRE = RegExp(r'[\s]', multiLine: false);

  /// Create list from a single option definitions string
  ///
  static List<CliOptDef> cliOptDefsFromString(
      String optDefStr, CliOptCaseMode caseMode) {
    final result = <CliOptDef>[];
    final parts = optDefStr.replaceAll(_blankRE, '').split('|');

    for (final part in parts) {
      if (part.isNotEmpty) {
        result.add(CliOptDef(part, caseMode));
      }
    }

    return result;
  }

  /// Find specific option definition by [name]
  ///
  CliOptDef? findCliOptDef(String? name, {bool canThrow = false}) {
    if (name != null) {
      for (var optDef in this) {
        if (optDef.names.contains(name) || optDef.negLongNames.contains(name)) {
          return optDef;
        }
      }
    }

    if (canThrow) {
      throw CliOptUndefinedNameException(name ?? '');
    }

    return null;
  }

  /// Get long names of all option definitions (positive or negative)
  ///
  List<String> getCliOptDefsLongNames({bool isNegative = false}) {
    final result = <String>[];

    for (final optDef in this) {
      result.addAll(isNegative ? optDef.negLongNames : optDef.longNames);
    }

    return result;
  }

  /// Get long sub-names of all option definitions (positive or negative)
  ///
  List<String> getCliOptDefsLongSubNames({bool isNegative = false}) {
    final result = <String>[];

    for (final optDef in this) {
      result.addAll(isNegative ? optDef.negLongSubNames : optDef.longSubNames);
    }

    return result;
  }

  /// Get short names of all option definitions
  ///
  List<String> getCliOptDefsShortNames() {
    final result = <String>[];

    for (final optDef in this) {
      result.addAll(optDef.shortNames);
    }

    return result;
  }

  /// Get short sub-names of all option definitions
  ///
  List<String> getCliOptDefsShortSubNames() {
    final result = <String>[];

    for (final optDef in this) {
      result.addAll(optDef.shortSubNames);
    }

    return result;
  }

  /// Checks there is no long option or long sub-option consisting
  /// of short options and short sub-options\
  /// Throws an exception when such match found\
  /// Useful solely for the unit testing or a rare sanity check, as
  /// in release mode, the parser simply prefers long options over
  /// the bundled short ones
  ///
  void validateCliOptDefs(List<String> longNames, List<String> longSubNames,
      List<String> shortNames, List<String> shortSubNames) {
    final allLongNames = <String>[...longNames, ...longSubNames];
    final allShortNames = <String>[...shortNames, ...shortSubNames];

    for (final longName in allLongNames) {
      var isFound = true;

      for (final shortName in longName.split('')) {
        if (!allShortNames.contains(shortName)) {
          isFound = false;
          break;
        }
      }
      if (isFound) {
        throw CliOptLongNameAsBundleException(longName);
      }
    }
  }
}
