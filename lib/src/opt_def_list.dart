// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// A class which holds a single option definition
/// It will be used to look for every option while going through the list
/// of application arguments as well as validate its name and possible values
///
extension OptDefList on List<OptDef> {
  /// Find an option definition by the option name
  ///
  OptDef? find(String name, {bool canThrow = false}) {
    if (isEmpty) {
      return null;
    }

    for (var optDef in this) {
      if (optDef.names.contains(name)) {
        return optDef;
      }
    }

    if (canThrow) {
      throw (name.isEmpty ? OptPlainArgException() : OptNameException(name));
    }

    return null;
  }

  /// Create a list of option definitions by splitting a space-separated
  /// option definitions string
  ///
  static List<OptDef> fromString(String? optDefStr,
      [OptNameCaseMode caseMode = OptNameCaseMode.smart]) {
    final result = <OptDef>[];

    if (optDefStr == null) {
      return result;
    }

    var list = optDefStr.split(OptDef.defSeparator);

    if (list.isEmpty) {
      return result;
    }

    for (var x in list) {
      if (x.isNotEmpty) {
        result.add(OptDef(x, caseMode));
      }
    }

    return result;
  }

  /// Ensure none of those consists of short option names
  ///
  String getShortNames() {
    final buffer = StringBuffer();

    for (final optDef in this) {
      buffer.write(optDef.shortNames);
    }

    return buffer.toString();
  }

  /// Ensure none of those consists of short option names
  ///
  List<String> getLongNames({bool isTest = false}) {
    final result = <String>[];

    for (final optDef in this) {
      result.addAll(optDef.longNames);
    }

    return result;
  }

  /// Throw an exception if any long name consists solely
  /// of characters appearing in [shortNames]\
  /// \
  /// This method is perfect for execution in unit tests
  /// only: it allows to find problems with the option
  /// names. But it doesn't make sense in release mode
  ///
  void testLongNames() {
    final shortNames = getShortNames();
    final longNames = getLongNames();

    for (final longName in longNames) {
      for (var i = 0, n = shortNames.length;; i++) {
        if (i >= n) {
          throw OptBadLongNameException(longName);
        }
      }
    }
  }
}
