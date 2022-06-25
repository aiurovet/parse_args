// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// A class which holds a single option definition
/// It will be used to look for every option while going through the list
/// of application arguments as well as validate its name and possible values
///
class OptDef {
  /// Constant option definitions separator (to have them all in a single string)
  ///
  static const defSeparator = '|';

  /// Constant separator for different names of a single option
  ///
  static const nameSeparator = ',';

  /// Followed by a list of sub-option names
  ///
  static const subOptSeparator = '>';

  /// Character meaning that an option requires a value
  ///
  static const valueMarker = ':';

  /// Indicates an option without a value (the flag)
  ///
  late final bool isFlag;

  /// List of option name lists
  ///
  final List<String> names = [];

  /// Return the last name
  ///
  get lastName => (names.isEmpty ? '' : names[names.length - 1]);

  /// Radix for integer values
  ///
  late final int? radix;

  /// List of sub-option names (wil be treated as special values)
  ///
  final List<String> subOpts = [];

  /// Enum for expected number of values
  ///
  late final OptValueCountType valueCountType;

  /// Expected type of values
  ///
  late final OptValueType valueType;

  /// Private: option name validator
  ///
  static final RegExp _nameChecker =
      RegExp(r'^([a-z]+[a-z0-9]*|[0-9]+)|$', caseSensitive: false);

  /// Private: regex for an option definition name
  ///
  static final RegExp _optDefNameCleaner =
      RegExp('[\\s\\${OptName.prefix}]', caseSensitive: false);

  /// Private: an OptValueType => radix mapping
  ///
  static const _radixMap = {
    OptValueType.bit: 2,
    OptValueType.num: 0,
    OptValueType.dec: 10,
    OptValueType.hex: 16,
    OptValueType.oct: 8,
  };

  /// Private: flag => OptValueType mapping
  ///
  static const _valueTypeMap = {
    'b': OptValueType.bit,
    'f': OptValueType.num,
    'i': OptValueType.dec,
    'x': OptValueType.hex,
    'o': OptValueType.oct,
  };

  /// Construct an option definition by parsing a string which comprises
  /// regex pattern followed by 0 (flag), 1 (single) or 2 (multiple)
  /// colons, then, possibly, by a value type character
  ///
  OptDef(String optDefStr) {
    var optDefStrNorm = normalize(optDefStr);
    var valuePos = optDefStrNorm.lastIndexOf(valueMarker);
    var valueTypeStr = '';

    // Set indicators
    //
    isFlag = (valuePos < 0);

    // Set sub-options
    //
    final subOptStart = optDefStrNorm.indexOf(OptDef.subOptSeparator);

    if (subOptStart > 0) {
      subOpts.clear();
      optDefStrNorm
          .substring(subOptStart + 1)
          .trim()
          .split(nameSeparator)
          .forEach((x) {
        subOpts.add(normalize(x));
      });
      optDefStrNorm = optDefStrNorm.substring(0, subOptStart);
    }

    // Determine value count type and break the option definition string into
    // the list of names, value count type and extract value type as substring
    //
    if (isFlag) {
      valueCountType = OptValueCountType.none;
    } else {
      if ((valuePos > 0) && (optDefStrNorm[valuePos - 1] == valueMarker)) {
        valueCountType = OptValueCountType.multiple;
      } else {
        valueCountType = OptValueCountType.single;
      }

      var typePos = valuePos + 1;

      if (typePos < optDefStrNorm.length) {
        valueTypeStr = optDefStrNorm[typePos];
      }

      if (valueCountType == OptValueCountType.multiple) {
        --valuePos;
      }

      optDefStrNorm = optDefStrNorm.substring(0, valuePos);
    }

    // Break the list of names, normalize and validate those, then add to the names list
    //
    optDefStrNorm.split(nameSeparator).forEach((x) {
      var name = normalize(x);

      if (!_nameChecker.hasMatch(name)) {
        throw (name.isEmpty ? OptPlainArgException() : OptNameException(name));
      }

      names.add(name);
    });

    // Determine value type and radix
    //
    if (isFlag) {
      valueType = OptValueType.nil;
      radix = null;
    } else {
      if (valueTypeStr.isEmpty) {
        valueType = OptValueType.str;
        radix = null;
      } else {
        valueType = _valueTypeMap[valueTypeStr] ?? OptValueType.nil;

        if (valueType == OptValueType.nil) {
          throw OptValueTypeException(optDefStrNorm);
        }

        radix = _radixMap[valueType];
      }
    }
  }

  /// Find an option definition by the option name
  ///
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
      throw (name.isEmpty ? OptPlainArgException() : OptNameException(name));
    }

    return null;
  }

  /// Find an option definition by the option name
  ///
  static OptDef? findBySubOptName(List<OptDef> optDefs, String name,
      {bool canThrow = false}) {
    if (optDefs.isEmpty || name.isEmpty) {
      return null;
    }

    for (var optDef in optDefs) {
      if (optDef.subOpts.contains(name)) {
        return optDef;
      }
    }

    if (canThrow) {
      throw SubOptOrphanException(name);
    }

    return null;
  }

  /// Create a list of option definitions by splitting a space-separated
  /// option definitions string.
  ///
  static List<OptDef> listFromString(String? optDefStr) {
    var result = <OptDef>[];

    if (optDefStr == null) {
      return result;
    }

    var list = optDefStr.split(defSeparator);

    if (list.isEmpty) {
      return result;
    }

    for (var x in list) {
      if (x.isNotEmpty) {
        result.add(OptDef(x));
      }
    }

    return result;
  }

  /// Make a normalized option from [name]: no space, no dash, lowercase
  ///
  static String normalize(String name) =>
      name.replaceAll(_optDefNameCleaner, '').toLowerCase();

  /// Convert a string value [strValue] of an option [name] to the strongly typed one
  ///
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

    throw OptValueTypeException(name, [strValue]);
  }

  /// Validate the [actualCount] of values against the expected one for the option [name]
  ///
  void validateValueCount(String name, int actualCount) {
    switch (valueCountType) {
      case OptValueCountType.none:
        if (actualCount != 0) {
          throw OptValueUnexpectedException(name);
        }
        break;
      case OptValueCountType.single:
        if (actualCount < 1) {
          throw OptValueMissingException(name);
        }
        if (actualCount > 1) {
          throw OptValueTooManyException(name);
        }
        break;
      case OptValueCountType.multiple:
        if (actualCount < 1) {
          throw OptValueMissingException(name);
        }
        break;
    }
  }
}
