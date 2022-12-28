// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:glob/glob.dart';
import 'package:parse_args/parse_args.dart';

/// Single value custom converter
///
typedef CliOptValueConverter = dynamic Function(CliOptDef optDef, String value,
    {dynamic param});

/// Extension methods to manipulate command-line arguments.
/// Returns true if more values can be added, or false otherwise.
///
extension CliOptList on List<CliOpt> {
  /// Add new option and/or value to the list of parsed options
  ///
  bool addCliOpt(List<CliOptDef> optDefs, String? name,
      {bool isPositive = true, String? value, int argNo = -1}) {
    var opt = findCliOptByName(name);
    CliOptDef? optDef;

    if (opt == null) {
      optDef = optDefs.findCliOptDef(name);

      if (optDef == null) {
        return false;
      }

      opt = CliOpt(optDef,
          argNo: argNo,
          fullName: optDef.name.addPrefix(isPositive: isPositive));
      add(opt);
    }

    final newValueCount = opt.addValue(value);
    optDef = opt.optDef;

    // If the option allows any number of values, then can continue adding values
    //
    if (optDef.hasManyValues) {
      return (optDef.name.isEmpty || (newValueCount <= 1));
    }

    // If the option is flag, then no more value can be added
    //
    if (optDef.isFlag) {
      return false;
    }

    // In case of an option with single value, can add value only if no value has been added yet
    //
    return opt.values.isEmpty;
  }

  /// Finds existing argument by option name (no prefix)
  ///
  CliOpt? findCliOptByName(String? name) {
    if (name == null) {
      return null;
    }

    for (final opt in this) {
      if (opt.optDef.names.contains(name)) {
        return opt;
      }
    }

    return null;
  }

  /// Get string value
  ///
  DateTime? getDateValue(String name) => getDateValues(name).firstOrDefault();

  /// Get string values
  ///
  List<DateTime> getDateValues(String name) {
    var result = getValues(name, (int).toString(), toDateValue);

    return (result.isEmpty
        ? <DateTime>[]
        : result.map((x) => (x as DateTime)).toList());
  }

  /// Get int value
  ///
  int? getIntValue(String name, {int radix = 10}) =>
      getIntValues(name, radix: radix).firstOrDefault();

  /// Get int values
  ///
  List<int> getIntValues(String name, {int radix = 10}) {
    var result = getValues(name, (int).toString(), toIntValue, param: radix);

    return (result.isEmpty ? <int>[] : result.map((x) => (x as int)).toList());
  }

  /// Get Glob value
  ///
  Glob? getGlobValue(String name, {GlobOpt? options}) =>
      getGlobValues(name, options: options).firstOrDefault();

  /// Get Glob values
  ///
  List<Glob> getGlobValues(String name, {GlobOpt? options}) {
    var result =
        getValues(name, (Glob).toString(), toGlobValue, param: options);

    return (result.isEmpty
        ? <Glob>[]
        : result.map((x) => (x as Glob)).toList());
  }

  /// Get num value
  ///
  num getNumValue(String name) => getValue(name, (num).toString(), toNumValue);

  /// Get num values
  ///
  List<num> getNumValues(String name) {
    var result = getValues(name, (num).toString(), toNumValue);

    return (result.isEmpty ? <num>[] : result.map((x) => (x as num)).toList());
  }

  /// Get RegExp value
  ///
  RegExp? getRegExpValue(String name, {RegExpOpt? options}) =>
      getRegExpValues(name, options: options).firstOrDefault();

  /// Get RegExp values
  ///
  List<RegExp> getRegExpValues(String name, {RegExpOpt? options}) {
    var result =
        getValues(name, (RegExp).toString(), toRegExpValue, param: options);

    return (result.isEmpty
        ? <RegExp>[]
        : result.map((x) => (x as RegExp)).toList());
  }

  /// Get string value
  ///
  String? getStrValue(String name) =>
      getValue(name, (String).toString(), null) as String?;

  /// Get string values
  ///
  List<String> getStrValues(String name) {
    var result = getValues(name, (String).toString(), null);

    return (result.isEmpty
        ? <String>[]
        : result.map((x) => (x as String)).toList());
  }

  /// Get abstract single value
  ///
  dynamic getValue(
          String name, String typeName, CliOptValueConverter? converter,
          {dynamic param}) =>
      getValues(name, typeName, converter, param: param).firstOrDefault();

  /// Get abstract values
  ///
  List getValues(String name, String typeName, CliOptValueConverter? converter,
      {dynamic param}) {
    final values = [];
    final opt = findCliOptByName(name);
    final optDef = opt?.optDef;

    if ((opt == null) || (optDef == null)) {
      return values;
    }

    if (converter == null) {
      values.addAll(opt.values);
      return values;
    }

    for (final strValue in opt.values) {
      final value = converter(optDef, strValue, param: param);

      if (value == null) {
        throw CliOptValueTypeException(name, typeName, [strValue]);
      }

      values.add(value);
    }

    return values;
  }

  /// Get the flag
  ///
  bool isSet(String name) {
    var opt = findCliOptByName(name);

    if (opt == null) {
      return false;
    }

    if (!(opt.optDef.isFlag)) {
      return false;
    }

    return opt.fullName.isCliOptPositive();
  }

  /// Converter: to date/time value
  ///
  static DateTime? toDateValue(CliOptDef optDef, String value,
          {dynamic param}) =>
      DateTime.tryParse(value);

  /// Converter: to Glob value
  ///
  static Glob? toGlobValue(CliOptDef optDef, String value, {dynamic param}) {
    if (param == null) {
      return Glob(value);
    }

    if (param is GlobOpt) {
      return Glob(
        value,
        context: param.fileSystem.path,
        caseSensitive: param.caseSensitive,
        recursive: param.recursive,
      );
    }

    return null;
  }

  /// Converter: to integer value
  ///
  static int? toIntValue(CliOptDef optDef, String value, {dynamic param}) =>
      int.tryParse(value, radix: ((param as int?) ?? 10));

  /// Converter: to numeric value
  ///
  static num? toNumValue(CliOptDef optDef, String value, {dynamic param}) =>
      num.tryParse(value);

  /// Converter: to RegExp value
  ///
  static RegExp? toRegExpValue(CliOptDef optDef, String value,
      {dynamic param}) {
    if (param == null) {
      return RegExp(value);
    }

    if (param is RegExpOpt) {
      return RegExp(
        value,
        caseSensitive: param.caseSensitive,
        dotAll: param.dotAll,
        multiLine: param.multiLine,
        unicode: param.unicode,
      );
    }

    if (param is String) {
      var rxo = RegExpOpt.fromString(param);

      return RegExp(
        value,
        caseSensitive: rxo.caseSensitive,
        dotAll: rxo.dotAll,
        multiLine: rxo.multiLine,
        unicode: rxo.unicode,
      );
    }

    return null;
  }

  /// Converter: to numeric value
  ///
  Map<String, List<String>> toSimpleMap() {
    final result = <String, List<String>>{};

    for (final x in this) {
      result[x.fullName] = x.values;
    }

    return result;
  }

  /// Validate the number of values for each option
  ///
  void validateValueCounts() {
    for (final x in this) {
      x.validateValueCount();
    }
  }
}
