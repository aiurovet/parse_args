// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// Class representing an option definition (parsed from an options definition string)
///
class CliOptDef {
  /// If true, then the option is a flag (no value)
  ///
  late final bool isFlag;

  /// If true, then no value allowed (values are optional, useful for plain arguments)
  ///
  late final bool isNoValueAllowed;

  /// If true, then multiple values expected to follow (either as a delimited list or as separate arguments)
  ///
  late final bool hasManyValues;

  /// The highest number of values allowed
  ///
  late final int maxValueCount;

  /// The lowest number of values allowed
  ///
  late final int minValueCount;

  /// The main option name (the last specified in the option definition)
  ///
  late final String name;

  /// Delimiter for values passed as a single string
  ///
  late final String valueSeparator;

  /// List of names (either long or short)
  ///
  final names = <String>[];

  /// List of long names
  ///
  final longNames = <String>[];

  /// List of long sub-names
  ///
  final longSubNames = <String>[];

  /// List of long names with the negation prefix
  ///
  final negLongNames = <String>[];

  /// List of long sub-names with the negation prefix
  ///
  final negLongSubNames = <String>[];

  /// List of short names
  ///
  final shortNames = <String>[];

  /// List of short sub-names
  ///
  final shortSubNames = <String>[];

  /// List of sub-names (long or short)
  ///
  final subNames = <String>[];

  /// The constructor
  ///
  CliOptDef(String optDefStr, CliOptCaseMode caseMode) {
    // Filling subNames
    //
    var parts = optDefStr.split('>');

    if (parts.length > 1) {
      final list = parts[1].split(',');
      subNames.addAll(list.map((x) => x.getCliOptName(caseMode)));
    }

    // Determining the expectation of values and possible value separator
    //
    final allNamesStr = parts[0].trim();
    final hasNames = allNamesStr.isNotEmpty;

    final valueInfoBeg = allNamesStr.indexOf(':');
    isFlag = hasNames && (valueInfoBeg < 0);
    isNoValueAllowed = allNamesStr.endsWith('?');

    var valueInfoLen = 0;

    if (!isFlag && hasNames) {
      valueInfoLen = (allNamesStr.length - valueInfoBeg);

      if (isNoValueAllowed) {
        --valueInfoLen;
      }
    }

    hasManyValues = (valueInfoLen >= 2);

    final valueSeparator = (hasManyValues
        ? allNamesStr.substring(valueInfoBeg + 1, valueInfoBeg + 2)
        : '');
    this.valueSeparator = (valueSeparator == ':' ? '' : valueSeparator);

    // Filling all kinds of names
    //
    names.addAll((isFlag || !hasNames
            ? allNamesStr
            : allNamesStr.substring(0, valueInfoBeg))
        .split(',')
        .map((x) => x.getCliOptName(caseMode)));

    name = (names.isEmpty ? '' : names[names.length - 1]);

    longNames.addAll(names.where((x) => x.length > 1));
    longSubNames.addAll(subNames.where((x) => x.length > 1));

    shortNames.addAll(names.where((x) => x.length == 1));
    shortSubNames.addAll(subNames.where((x) => x.length == 1));

    if (isFlag && hasNames) {
      negLongNames.addAll(longNames.map((x) => 'no$x'));
    }

    negLongSubNames.addAll(longSubNames.map((x) => 'no$x'));
  }
}
