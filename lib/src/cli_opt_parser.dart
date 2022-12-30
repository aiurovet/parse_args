// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// Class to parse command-line arguments as options and their values
///
class CliOptParser {
  /// Maximum possible number of arguments
  ///
  static const int maxArgCount = 999999999;

  /// Points to the plain arguments option definintion
  ///
  late final CliOptDef? argOptDef;

  /// Describes when to convert to lower case
  ///
  final CliOptCaseMode caseMode;

  /// List of all option definintions
  ///
  late final List<CliOptDef> optDefs;

  /// List of long names of all option definitions
  ///
  late final List<String> longNames;

  /// List of long sub-names of all option definitions
  ///
  late final List<String> longSubNames;

  /// List of negative long names of all option definitions
  ///
  late final List<String> negLongNames;

  /// List of negative long sub-names of all option definitions
  ///
  late final List<String> negLongSubNames;

  /// List of all unbundled arguments with extra info
  ///
  final parsed = <CliOpt>[];

  /// List of short names of all option definitions
  ///
  late final List<String> shortNames;

  /// List of short sub-names of all option definitions
  ///
  late final List<String> shortSubNames;

  /// Internal members for the current argument processing
  ///
  CliOptDef? _curOptDef;
  var _curStopMode = CliOptStopMode.none;
  var _curFullName = '';
  var _curIsFound = false;
  var _curIsPositive = true;
  var _curIsSubOpt = false;
  var _curName = '';
  var _curValue = '';

  /// The constructor: breaks input string into option definitions
  /// and optionally validates all option and sub-option names
  ///
  CliOptParser(String optDefStr, this.caseMode, {bool validate = false}) {
    optDefs = CliOptDefList.cliOptDefsFromString(optDefStr, caseMode);
    argOptDef = optDefs.findCliOptDef('');
    _curOptDef = argOptDef;

    longNames = optDefs.getCliOptDefsLongNames(isNegative: false);
    longSubNames = optDefs.getCliOptDefsLongSubNames(isNegative: false);

    negLongNames = optDefs.getCliOptDefsLongNames(isNegative: true);
    negLongSubNames = optDefs.getCliOptDefsLongSubNames(isNegative: true);

    shortNames = optDefs.getCliOptDefsShortNames();
    shortSubNames = optDefs.getCliOptDefsShortSubNames();

    if (validate) {
      optDefs.validateCliOptDefs(
          longNames, longSubNames, shortNames, shortSubNames);
    }
  }

  /// The actual parser
  ///
  List<CliOpt> exec(List<String> args) {
    _curOptDef = argOptDef;

    // Loop through all arguments and parse one by one
    //
    var argNo = -1;

    for (var arg in args) {
      ++argNo;

      _resetInternals();

      if (_execStopMode(arg)) {
        continue;
      }
      if (_execPlainArg(arg, argNo)) {
        continue;
      }
      if (_execOption(arg, argNo)) {
        continue;
      }
      argNo = _unbundle(argNo);
    }

    parsed.validateValueCounts();

    _resetInternals(all: true);

    // Return parsed options
    //
    return parsed;
  }

  /// In simple case of a plain argument, adds that as a value to the current option.\
  /// In more complex case, finds a long option name and possible value then adds those.\
  /// Otherwise, unbundles options
  ///
  bool _execOption(String arg, int argNo) {
    _setCurNameAndValue(arg);

    if (_curOptDef == null) {
      return false;
    }

    if (_curName.isEmpty) {
      _curValue = _curFullName;
      _curFullName = '';
      return _execPlainArg(_curValue, argNo, isForced: true);
    }

    // If still not found, and the argument is a sub-option name, then
    // add it as a plain value to the current option
    //
    if (_curIsSubOpt) {
      if (!parsed.addCliOpt(optDefs, _curOptDef!.name,
          isPositive: _curIsPositive, value: _curFullName)) {
        _curOptDef = argOptDef;
      }
      return true;
    }

    // If still not found, then finish
    //
    if (!_curIsFound) {
      return false;
    }

    // If name is empty (an opt def for plain arguments), then
    // check that plain arguments are supported
    //
    if (_curName.isEmpty && (argOptDef == null)) {
      throw CliOptUndefinedNameException(_curName);
    }

    // If name found, then find an option definition and set that as current
    //
    if (_curName.isNotEmpty) {
      _curOptDef = optDefs.findCliOptDef(_curName, canThrow: true);

      parsed.addCliOpt(optDefs, _curOptDef!.name,
          isPositive: _curIsPositive, argNo: argNo);
    }

    // If value found, then add it to the current option and make the plain arguments
    // option def as current, as the argument contains both the option name and value
    //
    if (_curValue.isNotEmpty) {
      parsed.addCliOpt(optDefs, _curOptDef!.name,
          isPositive: _curIsPositive, value: _curValue);
      _curOptDef = argOptDef;
    }

    return true;
  }

  /// If an argument is not an option, then add that as a value to the current option.
  ///
  bool _execPlainArg(String arg, int argNo, {bool isForced = false}) {
    // If the argument can be treated as an option, then finish
    //
    if (!isForced && arg.isCliOptNameValid(_curStopMode)) {
      return false;
    }

    // If the current option definition is undefined or the number of parsed
    // separate argument values exceeds the expected count, reset the current
    // option definition to the one related to the plain arguments
    //
    if (_curOptDef == null) {
      _curOptDef = argOptDef;
    } else if (_curOptDef != argOptDef) {
      final parsedOpt = parsed.findCliOptByName(_curOptDef?.name);

      if (parsedOpt != null) {
        var expArgCount =
            (_curOptDef!.hasManyValues && _curOptDef!.valueSeparator.isEmpty
                ? maxArgCount
                : _curOptDef!.isFlag
                    ? 0
                    : 1);

        if (parsedOpt.values.length >= expArgCount) {
          _curOptDef = argOptDef;
        }
      }
    }

    // If the current option definition is still undefined, then fail
    //
    if (_curOptDef == null) {
      throw CliOptUndefinedNameException('', [arg]);
    }

    // If the current option is a flag, then discard it
    //
    if (_curOptDef!.isFlag) {
      _curOptDef = argOptDef;
    }

    // Add value to the current option and finish
    //
    if (!parsed.addCliOpt(optDefs, _curOptDef!.name,
        value: arg, argNo: argNo)) {
      _curOptDef = argOptDef;
    }

    return true;
  }

  /// If the current stop mode is not set yet, and the current
  /// argument represents a stop sign, then return true.\
  /// Otherwise, set the current stop mode, discard the current
  /// option in case of stopAndDrop, and return true or false
  /// depending on whether any stop sign was encountered or not.
  ///
  bool _execStopMode(String arg) {
    if (_curStopMode != CliOptStopMode.none) {
      return false;
    }

    _curStopMode = arg.getCliOptStopMode();

    switch (_curStopMode) {
      case CliOptStopMode.last:
        return true;
      case CliOptStopMode.stop:
        _curOptDef = argOptDef;
        return true;
      default:
        return false;
    }
  }

  /// Reset internal variables
  ///
  void _resetInternals({bool all = false}) {
    if (all) {
      _curOptDef = null;
      _curStopMode = CliOptStopMode.none;
    }

    _curFullName = '';
    _curIsFound = false;
    _curIsPositive = true;
    _curName = _curFullName;
    _curValue = _curFullName;
  }

  /// Split full option name into a name and value
  ///
  void _setCurNameAndValue(String arg) {
    // Set the current full name and flags
    //
    _curFullName = arg.getCliOptName(caseMode, withPrefix: true);
    _curIsFound = false;
    _curIsPositive = _curFullName.isCliOptPositive();
    _curIsSubOpt = false;

    // Split full name into a name and value (any of those might be empty)
    //
    final parts = _curFullName.splitCliOptNameValue();
    _curFullName = parts[0];
    _curName = _curFullName;
    _curValue = arg.substring(arg.length - parts[1].length);

    // If no name found, finish
    //
    if (_curName.isEmpty) {
      return;
    }

    // Strip the option prefix and find the option definition
    //
    _curName = _curName.substring(1);

    // Check whether this is a sub-option
    //
    if (_curOptDef != null) {
      if (_curOptDef!.longSubNames.contains(_curName) ||
          _curOptDef!.shortSubNames.contains(_curName)) {
        _curIsSubOpt = true;
      } else if (_curOptDef?.negLongSubNames.contains(_curName) ?? false) {
        _curIsPositive = false;
        _curIsSubOpt = true;
      }
    }

    // Make sub-option name consumable by the caller
    //
    if (_curIsSubOpt) {
      _curIsFound = true;
      return;
    }

    // Find the option definition
    //
    final newOptDef = optDefs.findCliOptDef(_curName);
    _curIsFound = (newOptDef != null);

    // If the new option found, switch to that and set positivity flag
    //
    if (_curIsFound) {
      _curOptDef = newOptDef;

      if (negLongNames.contains(_curName)) {
        _curIsPositive = false;
        _curIsFound = true;
      }
    }

    // If an option with the given name found then finish
    //
    if (_curIsFound) {
      return;
    }

    // No new option definition found, so set the current one
    // to the plain args option definition and finish
    //
    _curOptDef = argOptDef;
  }

  /// Split an argument into a list of short options and possibly an argument
  ///
  int _unbundle(int argNo) {
    _curOptDef ??= argOptDef;

    // Split the option name into an array of single chars
    //
    final chars = _curName.split('');
    var curArgNo = argNo - 1;

    // Analyze every char
    //
    for (var char in chars) {
      // If the current character is found among short names, then
      // add that as a short option name and set the current option
      //
      if (shortNames.contains(char)) {
        _curOptDef = optDefs.findCliOptDef(char);
        parsed.addCliOpt(optDefs, char,
            isPositive: _curIsPositive, argNo: ++curArgNo);
        continue;
      }

      // If the current character is found among short sub-names of the
      // current option, then add to that as a short sub-option name
      //
      if ((_curOptDef != null) && _curOptDef!.shortSubNames.contains(char)) {
        final fullShortName = char.toFullCliOptName(_curIsPositive);
        if (!parsed.addCliOpt(optDefs, _curOptDef!.name,
            isPositive: _curIsPositive, value: fullShortName)) {
          _curOptDef = argOptDef;
        }
        continue;
      }

      // If there is a character not recognised as a short option or as
      // a sub-option of the current option, then fail
      //
      throw CliOptUndefinedNameException(char);
    }

    return curArgNo;
  }
}
