// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:glob/glob.dart';
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
  static const subNameSeparator = '>';

  /// Character meaning that an option requires a value
  ///
  static const valueMarker = ':';

  /// Indicates an option without a value (the flag)
  ///
  late final bool isFlag;

  /// List of all long names across main and sub-option names
  ///
  List<String> get longNames => _longNames;
  final _longNames = <String>[];

  /// List of option name lists
  ///
  final List<String> names = [];

  /// Return the last name
  ///
  get lastName => (names.isEmpty ? '' : names[names.length - 1]);

  /// Radix for integer values
  ///
  late final int? radix;

  /// List of all short names across main and sub-option names
  ///
  String get shortNames => _shortNames;
  var _shortNames = '';

  /// List of sub-option names (wil be treated as special values)
  ///
  final List<String> subNames = [];

  /// Expected maximum number of values
  ///
  late final int maxValueCount;

  /// Expected minimum number of values
  ///
  late final int minValueCount;

  /// Expected type of values
  ///
  late final OptValueType valueType;

  /// Private: option name validator
  ///
  static final RegExp _nameChecker =
      RegExp(r'^([a-z]+[a-z0-9]*|[0-9]+)|$', caseSensitive: false);

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
    'g': OptValueType.glob,
    'x': OptValueType.hex,
    'o': OptValueType.oct,
    'r': OptValueType.regExp,
  };

  /// Construct an option definition by parsing a string which comprises
  /// regex pattern followed by 0 (flag), 1 (single) or 2 (multiple)
  /// colons, then, possibly, by a value type character
  ///
  OptDef(String optDefStr, [OptNameCaseMode caseMode = OptNameCaseMode.smart]) {
    var optDefStrNorm = OptName.normalize(optDefStr, OptNameCaseMode.force);
    var valuePos = optDefStrNorm.lastIndexOf(valueMarker);
    var valueTypeStr = '';

    // Set indicators
    //
    isFlag = (valuePos < 0);

    // Set sub-options
    //
    final subNameStart = optDefStrNorm.indexOf(OptDef.subNameSeparator);

    if (subNameStart > 0) {
      subNames.clear();
      optDefStrNorm
          .substring(subNameStart + 1)
          .split(nameSeparator)
          .forEach((x) {
        subNames.add(OptName.normalize(x, caseMode));
      });
      optDefStrNorm = optDefStrNorm.substring(0, subNameStart);
    }

    // Determine value count type and break the option definition string into
    // the list of names, value count type and extract value type as substring
    //
    if (isFlag) {
      minValueCount = 0;
      maxValueCount = 0;
    } else {
      if ((valuePos > 0) && (optDefStrNorm[valuePos - 1] == valueMarker)) {
        minValueCount = 1;
        maxValueCount = 9999999999;
      } else {
        minValueCount = 1;
        maxValueCount = 1;
      }

      var typePos = valuePos + 1;

      if (typePos < optDefStrNorm.length) {
        valueTypeStr = optDefStrNorm[typePos];
      }

      if (maxValueCount > 1) {
        --valuePos;
      }

      optDefStrNorm = optDefStrNorm.substring(0, valuePos);
    }

    // Break the list of names, normalize and validate those, then add to the names list
    //
    optDefStrNorm.split(nameSeparator).forEach((x) {
      var name = OptName.normalize(x, caseMode);

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

    getShortNames();
    getLongNames();
  }

  /// Add value or values
  ///
  void addValues(OptDef? optDef, String value) {}

  /// Fill [_longNames]
  ///
  void getLongNames({bool isTest = false}) {
    _longNames.clear();
    _getLongNamesFrom(names, isTest);
    _getLongNamesFrom(subNames, isTest);
  }

  /// Throw an exception if some long [name] consists solely
  /// of characters in [againstShortNames]
  ///
  void _getLongNamesFrom(List<String> allNames, [bool isTest = false]) {
    for (final name in allNames) {
      if (name.length <= 1) {
        continue;
      }

      if (!isTest) {
        _longNames.add(name);
        continue;
      }

      for (var i = 0, n = name.length;; i++) {
        if (i >= n) {
          throw OptBadLongNameException(name);
        }
        if (!_shortNames.contains(name[i])) {
          _longNames.add(name);
          break;
        }
      }
    }
  }

  /// Retrieve all short option names (main and sub)
  ///
  void getShortNames() {
    _getShortNamesFrom(names);
    _getShortNamesFrom(subNames);
  }

  /// Retrieve all short option names from [allNames]
  ///
  void _getShortNamesFrom(List<String> allNames) {
    final buffer = StringBuffer();

    for (final name in allNames) {
      if (name.length == 1) {
        buffer.write(name);
      }
    }

    _shortNames += buffer.toString();
  }

  /// Convert a string value [strValue] of an option [name] to the strongly typed one
  ///
  Object toTypedValue(String name, String strValue) {
    if (radix == null) {
      switch (valueType) {
        case OptValueType.glob:
          return Glob(strValue);
        case OptValueType.regExp:
          return RegExp(strValue);
        default:
          return strValue;
      }
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

  /// Validate the [actualCount] of values against the expected one for the option [actualName]
  ///
  void validateValueCount(int actualCount) {
    if ((minValueCount <= 0) && (maxValueCount <= 0)) {
      if (actualCount != 0) {
        throw OptValueUnexpectedException(lastName);
      }
    } else if ((minValueCount == 1) && (maxValueCount == 1)) {
      if (actualCount < minValueCount) {
        throw OptValueMissingException(lastName);
      }
      if (actualCount > maxValueCount) {
        throw OptValueTooManyException(lastName);
      }
    } else if (minValueCount > 0) {
      if (actualCount < 1) {
        throw OptValueMissingException(lastName);
      }
    }
  }
}
