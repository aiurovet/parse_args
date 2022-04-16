// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/src/opt_def.dart';
import 'package:parse_args/src/str_ext.dart';

/// A type for the user-defined handler which gets called on every option
/// with the list of values (non-optional arguments between this option
/// and the next one).
///
typedef ParseArgsHandler = void Function(
    bool isFirstRun, String name, List values);

/// Loops through all command-line arguments [args], determines options,
/// collects possible values, validates those against the [format] and
/// calls a user-defined [handler]. Optional [format] should be defined
/// as a pipe-separated list string. Use a single colon for a single
/// value, two colons for multiple values, 'b' for binary int, _f_ for
/// double-precision float, 'i' for decimal int, 'o' for octal int,
/// 'x' for hex int. Use a leading '+|' to request a double pass through
/// the arguments (this allows to 'look-ahead' in case of dependent options)
///
/// '+|?,h,help|f,force|i,inpfiles::|min:i|max:i|r,rate:f'
///
void parseArgs(String? optDefStr, List<String> args, ParseArgsHandler handler,
    {String valueSeparator = ''}) {
  var optDefs = OptDef.listFromString(optDefStr);
  var isMultiRun = (OptDef.find(optDefs, OptDef.optMultiRun) != null);

  var argCount = args.length;
  var argMap = <String, List>{};
  var ordMap = <int, String>{};
  var isValueOnly = false;

  // Loop through all arguments
  //
  for (var argNo = 0; argNo < argCount;) {
    var arg = args[argNo];

    // If found an indicator of the end of options, don't treat any further argument as an option
    //
    if (arg == OptDef.optStop) {
      isValueOnly = true;
      ++argNo;
      continue;
    }

    // Get the option name if encountered
    //
    final isOption = (!isValueOnly && arg.startsWith(OptDef.optPrefix));
    var name = (isOption ? arg : '');
    var value = '';

    if (isOption) {
      final breakPos = name.indexOf('=');

      if (breakPos >= 0) {
        value = name.substring(breakPos + 1).unquote();
        name = name.substring(0, breakPos);
      }
    }

    final normName = OptDef.normalize(name);
    final optDef = OptDef.find(optDefs, normName, canThrow: true);
    final lastName = optDef?.lastName ?? '';

    if (isOption) {
      ++argNo;
    }

    // Populate the list of values for the current option
    // (either the next argument split by the non-empty valueSeparator,
    // or all arguments beyond that and prior to the next option)
    //
    var values = [];

    if (value.isEmpty) {
      for (; argNo < argCount; argNo++) {
        arg = args[argNo];

        if (arg == OptDef.optStop) {
          isValueOnly = true;
          if (optDef?.isFlag ?? false) {
            break;
          }
          continue;
        }

        if (!isValueOnly &&
            arg.startsWith(OptDef.optPrefix) &&
            (arg != OptDef.optPrefix)) {
          break;
        }

        // Add the actual values

        if (valueSeparator.isEmpty) {
          values.add(optDef?.toTypedValue(lastName, arg) ?? arg);
        } else {
          for (var v in arg.split(valueSeparator)) {
            values.add(optDef?.toTypedValue(lastName, v) ?? v);
          }
          ++argNo;
          break;
        }
      }
    } else {
      if (valueSeparator.isEmpty) {
        values.add(optDef?.toTypedValue(lastName, arg) ?? arg);
      } else {
        for (var v in value.split(valueSeparator)) {
          values.add(optDef?.toTypedValue(lastName, v) ?? v);
        }
      }
    }

    // Ensure the actual number of values matches the expected one
    //
    optDef?.validateValueCount(normName, values.length);

    // Set the actual option name and values
    //
    argMap[lastName] = values;

    // Set the order number (the position in the definitions string)
    //
    var ordNo = (optDef == null ? -1 : optDefs.indexOf(optDef));
    ordMap[ordNo] = lastName;
  }

  // Call the user-defined handler for the actual processing in the order of appearance of definitions
  //
  var lastStep = (isMultiRun ? 2 : 1);
  var sortedOrdKeys = ordMap.keys.toList()..sort();
  var emptyList = [];

  for (var step = 1; step <= lastStep; step++) {
    for (var i in sortedOrdKeys) {
      var name = ordMap[i] ?? '';
      handler((step == 1), name, argMap[name] ?? emptyList);
    }
  }

  // Finish
}
