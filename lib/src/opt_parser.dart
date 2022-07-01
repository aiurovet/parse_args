// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// A class which holds a single option definition
/// It will be used to look for every option while going through the list
/// of application arguments as well as validate its name and possible values
///
class OptParser {
  /// Flag indicating that if an option name does not have a long  name
  /// match, then it should be treated as a bundle of short names
  ///
  final bool isBundlingEnabled;

  /// How to compare option names
  ///
  final OptNameCaseMode caseMode;

  /// List of all options definitions parsed from the options definition string
  ///
  List<OptDef> get optDefs => _optDefs;
  var _optDefs = <OptDef>[];

  /// How to break any option value into a list of values (if not empty)
  ///
  final result = ParseArgsResult();

  /// How to break any option value into a list of values (if not empty)
  ///
  final String valueSeparator;

  /// Option definition for plain args (name is empty)
  ///
  OptDef? _argOptDef;

  /// Current option definition
  ///
  OptDef? _curOptDef;

  /// Current option definition
  ///
  final List<String> _subNames = [];

  /// Default constructor
  ///
  OptParser(
      {this.isBundlingEnabled = true,
      this.caseMode = OptNameCaseMode.smart,
      this.valueSeparator = ''});

  /// Engine
  ///
  ParseArgsResult exec(String? optDefStr, List<String> args) {
    final newArgs = prepare(optDefStr, args);

    var argCount = newArgs.length;
    var isValueOnly = false;
    var valueCount = 0;

    for (var argNo = 0; argNo < argCount; argNo++) {
      var arg = newArgs[argNo];

      if ((_curOptDef != null) && (valueCount >= _curOptDef!.maxValueCount)) {
        valueCount = _setCurOptDef(_argOptDef);
      }

      var optNameStopMode = OptName.getStopMode(arg);

      if (optNameStopMode != OptNameStopMode.none) {
        isValueOnly = true;

        if (optNameStopMode == OptNameStopMode.stopAndDrop) {
          valueCount = _setCurOptDef(_argOptDef);
        }

        continue;
      }

      final isOption = (!isValueOnly && OptName.isValid(arg));

      if (!isOption) {
        valueCount = result.addArg(_curOptDef, arg, false, valueSeparator);
        continue;
      }

      final nameValue = _splitArg(arg);
      final name = OptName.normalize(nameValue[0], caseMode);
      final value = nameValue[1];
      final isGlued = value.isNotEmpty;

      final newOptDef = _optDefs.find(name);

      if (newOptDef != null) {
        _setCurOptDef(newOptDef);
        valueCount = result.addArg(_curOptDef, value, false, valueSeparator,
            isGlued: isGlued);
        continue;
      }

      if (_subNames.contains(name)) {
        if ((_curOptDef != null) && !_curOptDef!.subNames.contains(name)) {
          throw SubOptMismatchException(_curOptDef!.lastName, name);
        }
        valueCount =
            result.addArg(_curOptDef, '${OptName.prefix}$name', true, '');
      } else if (_curOptDef == null) {
        throw OptNameException(name);
      }

      if (isGlued) {
        valueCount = result.addArg(_curOptDef, value, false, valueSeparator,
            isGlued: isGlued);
      }
    }

    for (final optDef in _optDefs) {
      final values = result.strings[optDef.lastName];

      if (values != null) {
        optDef.validateValueCount(values.length);
      }
    }

    return result;
  }

  /// and adjust [args]
  ///
  List<String> prepare(String? optDefStr, List<String> args) {
    _optDefs = OptDefList.fromString(optDefStr, caseMode);

    _subNames
      ..clear()
      ..addAll(_optDefs.map((x) => x.subNames).expand((x) => x).toSet());

    _argOptDef = _optDefs.find(OptName.plainArgs);
    _curOptDef = _argOptDef;

    return (isBundlingEnabled ? unbundle(args) : args);
  }

  /// Set current OptDef and return the number of its values
  ///
  int _setCurOptDef(OptDef? newOptDef) {
    _curOptDef = newOptDef;

    if (_curOptDef == null) {
      return 0;
    }

    return result.strings[_curOptDef!.lastName]?.length ?? 0;
  }

  /// Split argument into an option name and value
  ///
  static List<String> _splitArg(String arg, {bool isValuePrepended = false}) {
    var valueStart = arg.indexOf(OptName.valueSeparator);

    if (valueStart < 0) {
      return [arg, ''];
    }

    final nameEnd = valueStart;

    if (!isValuePrepended) {
      ++valueStart;
    }

    return [arg.substring(0, nameEnd), arg.substring(valueStart)];
  }

  /// Unbundle short option names
  ///
  List<String> unbundle(List<String> args) {
    final longNames = _optDefs.getLongNames();
    final result = <String>[];
    var isSkip = false;

    for (final arg in args) {
      if (OptName.getStopMode(arg) != OptNameStopMode.none) {
        isSkip = true;
      }

      if (isSkip || !OptName.isValid(arg)) {
        result.add(arg);
        continue;
      }

      final nameValue = _splitArg(arg, isValuePrepended: true);

      if (nameValue[0].length <= 1) {
        continue;
      }

      final normName = OptName.normalize(nameValue[0], caseMode);

      if (longNames.any((x) => x.contains(normName))) {
        result.add(arg);
        continue;
      }

      for (var i = 0, lastNo = normName.length - 1;; i++) {
        final optName = OptName.prefix + normName[i];

        if (i == lastNo) {
          result.add(optName + nameValue[1]);
          break;
        } else {
          result.add(optName);
        }
      }
    }

    return result;
  }
}
