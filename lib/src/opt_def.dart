// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/src/opt_exception.dart';
import 'package:parse_args/src/opt_value_mode.dart';
import 'package:parse_args/src/opt_value_type.dart';

/// A class which holds a single option definition
/// It will be used to look for every option while going through the list
/// of application arguments as well as validate its name and possible values

class OptDef {
  // Constants: special characters in options definition strings

  static const defSeparator = '|';
  static const nameSeparator = ',';
  static const optMultiRun = '+';
  static const optPrefix = '-';
  static const valueMarker = ':';

  /// Constants: option name validator

  static final RegExp nameChecker =
      RegExp(r'^([a-z]+[a-z0-9]*|[0-9]+)|$', caseSensitive: false);

  /// Constants: OptValueType => radix mapping

  static const radixMap = {
    OptValueType.bit: 2,
    OptValueType.num: 0,
    OptValueType.dec: 10,
    OptValueType.hex: 16,
    OptValueType.oct: 8,
  };

  /// Constants: flag => OptValueType mapping

  static const valueTypeMap = {
    'b': OptValueType.bit,
    'f': OptValueType.num,
    'i': OptValueType.dec,
    'x': OptValueType.hex,
    'o': OptValueType.oct,
  };

  /// Indicates an option without a value (the flag)

  late final bool isFlag;

  /// A level (reflects the order no)

  late final int level;

  /// A list of option name lists

  final List<String> names = [];

  /// A radix for integer values

  late final int? radix;

  /// An enum for expected number of values

  late final OptValueMode valueMode;

  /// An enum for expected type of values

  late final OptValueType valueType;

  /// Construct an option definition by parsing a string which comprises
  /// regex pattern followed by 0 (flag), 1 (single) or 2 (multiple)
  /// colons, then, possibly, by a value type character

  OptDef(String optDefStr, this.level) {
    var optDefStrNorm = normalize(optDefStr);
    var optDefStrNormLen = optDefStrNorm.length;
    var valuePos = optDefStrNorm.lastIndexOf(valueMarker);
    var valueTypeStr = '';

    // Set the flag indicator

    isFlag = (valuePos < 0);

    // Determine value mode and break the option definition string into
    // the list of names, value mode and extract value type as substring

    if (isFlag) {
      valueMode = OptValueMode.none;
    } else {
      if ((valuePos > 0) && (optDefStrNorm[valuePos - 1] == valueMarker)) {
        valueMode = OptValueMode.multiple;
      } else {
        valueMode = OptValueMode.single;
      }

      var typePos = valuePos + 1;

      if (typePos < optDefStrNormLen) {
        valueTypeStr = optDefStrNorm[typePos];
      }

      optDefStrNorm = optDefStrNorm.substring(
          0, (valueMode == OptValueMode.multiple ? valuePos - 1 : valuePos));
    }

    // Break the list of names, normalize and validate those, then add to the names list

    optDefStrNorm.split(nameSeparator).forEach((x) {
      var name = normalize(x);

      if (!nameChecker.hasMatch(name)) {
        throw OptNameException(name);
      }

      names.add(name);
    });

    // Determine value type and radix

    if (isFlag) {
      valueType = OptValueType.nil;
      radix = null;
    } else {
      if (valueTypeStr.isEmpty) {
        valueType = OptValueType.str;
        radix = null;
      } else {
        valueType = valueTypeMap[valueTypeStr] ?? OptValueType.nil;

        if (valueType == OptValueType.nil) {
          throw OptValueTypeException(optDefStrNorm);
        }

        radix = radixMap[valueType];
      }
    }
  }

  /// Find an option definition by the option name

  static OptDef? find(List<OptDef> optDefs, String name,
      {bool canThrow = false}) {
    if (optDefs.isEmpty) {
      return null;
    }

    for (var optDef in optDefs) {
      if (optDef.names.contains(name)) {
        return optDef;
      }
    }

    if (canThrow) {
      throw OptNameException(name);
    } else {
      return null;
    }
  }

  /// Create a list of option definitions by splitting a space-separated
  /// option definitions string.

  static List<OptDef> listFromString(String? optDefStr) {
    var result = <OptDef>[];

    if (optDefStr == null) {
      return result;
    }

    var list = optDefStr.trim().split(defSeparator);

    if (list.isEmpty) {
      return result;
    }

    var level = 1;

    for (var x in list) {
      if (x.isEmpty) {
        ++level;
      } else {
        result.add(OptDef(x, level));
      }
    }

    return result;
  }

  /// Make a normalized option: no space, no dash, lowercase

  static String normalize(String name) =>
      name.replaceAll(' ', '').replaceAll(optPrefix, '').toLowerCase();

  /// Convert a string value [strValue] of an option [name] to the strongly typed one

  Object toTypedValue(String name, String strValue) {
    if (radix == null) {
      return strValue;
    } else if (radix == 0) {
      var value = num.tryParse(strValue);

      if (value != null) {
        return value;
      }
    } else {
      var value = int.tryParse(strValue, radix: radix);

      if (value != null) {
        return value;
      }
    }

    throw OptValueTypeException(name, strValue);
  }

  /// Validate the [actualCount] of values against the expected one for the option [name]

  void validateMode(String name, int actualCount) {
    switch (valueMode) {
      case OptValueMode.none:
        if (actualCount != 0) {
          throw OptValueMissingException(name);
        }
        break;
      case OptValueMode.single:
        if (actualCount < 1) {
          throw OptValueMissingException(name);
        }
        if (actualCount > 1) {
          throw OptValueTooManyException(name);
        }
        break;
      case OptValueMode.multiple:
        if (actualCount < 1) {
          throw OptValueMissingException(name);
        }
        break;
    }
  }
}
