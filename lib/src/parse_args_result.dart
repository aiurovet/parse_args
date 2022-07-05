// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:parse_args/src/str_ext.dart';

/// Custom value converter
///
typedef ValueConverter = dynamic Function(OptDef optDef, String value,
    {dynamic param});

/// Class to store all found options and their values both as
/// dynamic values and strings
///
class ParseArgsResult {
  /// Allows to get the list of related option values
  ///
  Map<OptDef, List<String>> get values => _values;
  final _values = <OptDef, List<String>>{};

  @override
  String toString() {
    final result = StringBuffer();

    result.write('{');

    for (final entry in _values.entries) {
      if (result.length > 1) {
        result.write(', ');
      }
      result.write('\'${entry.key.lastName}\': ${entry.value}');
    }

    result.write('}');

    return result.toString();
  }

  /// Get plain (valueless) option presence flag
  ///
  int addArg(
      OptDef? optDef, String? value, bool isSubName, String? valueSeparator,
      {bool isGlued = false}) {
    if (optDef == null) {
      throw OptPlainArgException();
    }

    if (isGlued && (value != null)) {
      value = value.unquote();
    }

    final newStrings = <String>[];

    switch (optDef.valueType) {
      case OptValueType.glob:
      case OptValueType.regExp:
        if ((value != null) && value.isNotEmpty) {
          newStrings.add(value);
        }
        break;
      default:
        if ((value != null) && value.isNotEmpty) {
          if (valueSeparator == null) {
            newStrings.add(value);
          } else {
            newStrings.addAll(value.split(valueSeparator));
          }
        }
        break;
    }

    final isNewOpt = !_values.containsKey(optDef);
    final valueCount = newStrings.length;

    if (valueCount <= 0) {
      if (isNewOpt) {
        _values[optDef] = [];
      }
    } else {
      if (isNewOpt) {
        _values[optDef] = newStrings;
      } else {
        _values[optDef]!.addAll(newStrings);
      }
    }

    if (isSubName) {
      return 0;
    }

    if (isGlued || (valueCount > 1)) {
      return optDef.maxValueCount;
    }

    return _values[optDef]?.length ?? 0;
  }

  /// Find the key (option definition)
  ///
  OptDef? findByName(String name) {
    for (final key in _values.keys) {
      if (key.names.contains(name)) {
        return key;
      }
    }
    return null;
  }

  /// Get the first or default value of an array
  ///
  dynamic firstOrNull(List? values) =>
      ((values == null) || values.isEmpty ? null : values.first);

  /// Get the first integer value related to an option
  /// (use custom converter if sub-options expected)
  ///
  int? getIntValue(String name, {bool isRequired = false}) =>
      firstOrNull(getValues(name, isRequired: isRequired, isFirstOnly: true, converter: toIntValues))
          as int?;

  /// Get all integer values related to an option
  /// (use custom converter if sub-options expected)
  ///
  List<int>? getIntValues(String name, {bool isRequired = false, bool isFirstOnly = false}) =>
      getValues(name, isRequired: isRequired, isFirstOnly: isFirstOnly, converter: toIntValues)
          as List<int>;

  /// Get the first numeric value related to an option
  /// (use custom converter if sub-options expected)
  ///
  num? getNumValue(String name, {bool isRequired = false}) =>
      firstOrNull(getValues(name, isRequired: isRequired, isFirstOnly: true, converter: toNumValues))
          as num?;

  /// Get all numeric values related to an option
  /// (use custom converter if sub-options expected)
  ///
  List<num>? getNumValues(String name, {bool isRequired = false, bool isFirstOnly = false}) =>
      getValues(name, isRequired: isRequired, isFirstOnly: isFirstOnly, converter: toNumValues)
          as List<num>?;

  /// Get the first numeric value related to an option
  ///
  String? getStrValue(String name, {bool isRequired = false}) =>
      firstOrNull(getValues(name, isRequired: isRequired, isFirstOnly: true)) as String?;

  /// Get all numeric values related to an option
  ///
  List<String>? getStrValues(String name, {bool isRequired = false, bool isFirstOnly = false}) =>
      getValues(name, isRequired: isRequired, isFirstOnly: isFirstOnly) as List<String>?;

  /// Get the first value related to an option
  /// (use custom converter for non-string values when sub-options expected)
  ///
  dynamic getValue(String name, {bool isRequired = false, ValueConverter? converter, dynamic param}) =>
      firstOrNull(getValues(name, isRequired: isRequired, isFirstOnly: true, converter: converter));

  /// Get all values (including sub-option names) related to an option
  /// (use custom converter for non-string values when sub-options expected)
  ///
  List? getValues(String name,
      {bool isRequired = false, bool isFirstOnly = false, ValueConverter? converter, dynamic param}) {
    final optDef = findByName(name);

    if (optDef == null) {
      if (isRequired) {
        throw OptNameException(name);
      }
      return null;
    }

    var selected = _values[optDef]!;

    if (isRequired && selected.isEmpty) {
      throw OptValueMissingException(optDef.lastName);
    }

    if (isFirstOnly) {
      selected = (selected.length <= 1 ? selected : [selected.first]);
    }

    if (converter == null) {
      return selected;
    }

    final result = [];

    for (final value in selected) {
      result.add(converter(optDef, value, param: param));
    }

    return result;
  }

  /// Get plain (valueless) option presence flag
  ///
  bool isSet(String name) => (findByName(name) != null);

  /// Get the number of options if [name] is null or the number of values for option [name]
  ///
  int? length([String? name]) {
    if (name == null) {
      return _values.length;
    }

    final optDef = findByName(name);
    return (optDef == null ? null : _values[optDef]?.length);
  }

  /// Converter: to integer values
  ///
  static dynamic toIntValues(OptDef optDef, String string, {dynamic param}) =>
      int.parse(string, radix: ((param as int?) ?? 10));

  /// Converter: to numeric values
  ///
  static dynamic toNumValues(OptDef optDef, String string, {dynamic param}) =>
      num.parse(string);
}
