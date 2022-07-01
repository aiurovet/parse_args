// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:parse_args/src/str_ext.dart';

/// Class to store all found options and their values both as
/// dynamic values and strings
///
class ParseArgsResult {
  /// Allows to get the list of related option string values
  ///
  final strings = <String, List<String>>{};

  /// Allows to get the list of related option typed values
  ///
  final values = <String, List>{};

  /// Get plain (valueless) option presence flag
  ///
  int addArg(
      OptDef? optDef, String? string, bool isSubName, String valueSeparator,
      {bool isGlued = false}) {
    if (optDef == null) {
      throw OptPlainArgException();
    }

    if (isGlued && (string != null)) {
      string = string.unquote();
    }

    final name = optDef.lastName;
    final newStrings = <String>[];

    switch (optDef.valueType) {
      case OptValueType.glob:
      case OptValueType.regExp:
        if ((string != null) && string.isNotEmpty) {
          newStrings.add(string);
        }
        break;
      default:
        if ((string != null) && string.isNotEmpty) {
          if (valueSeparator.isEmpty) {
            newStrings.add(string);
          } else {
            newStrings.addAll(string.split(valueSeparator));
          }
        }
        break;
    }

    final isNewName = !strings.containsKey(name);
    final valueCount = newStrings.length;

    if (valueCount <= 0) {
      if (isNewName) {
        strings[name] = [];
        values[name] = [];
      }
    } else {
      final newValues = List.from(isSubName
          ? [newStrings[0]]
          : newStrings.map((x) => optDef.toTypedValue(name, x)));

      if (isNewName) {
        strings[name] = newStrings;
        values[name] = newValues.toList();
      } else {
        strings[name]!.addAll(newStrings);
        values[name]!.addAll(newValues);
      }
    }

    if (isSubName) {
      return 0;
    }

    if (isGlued || (valueCount > 1)) {
      return optDef.maxValueCount;
    }

    return strings[name]?.length ?? 0;
  }

  /// Get plain (valueless) option presence flag
  ///
  bool isSet(String name) => strings.containsKey(name);

  /// Get the first value related to an option (all checks passed beforehand)
  ///
  String getString(String name, [String defValue = '']) =>
      strings[name]?.first ?? defValue;

  /// Get all values related to an option, including sub-options (all checks passed beforehand)
  ///
  List<String> getStrings(String name) => strings[name] ?? [];

  /// Get the first value as string related to an option (all checks passed beforehand)
  ///
  dynamic getValue(String name, dynamic defValue) =>
      values[name]?.first ?? defValue;

  /// Get all values as strings related to an option, including sub-options (all checks passed beforehand)
  ///
  List getValues(String name) => values[name] ?? [];
}
