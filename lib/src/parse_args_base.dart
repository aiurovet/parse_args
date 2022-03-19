// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/src/opt_def.dart';

/// A type for the user-defined handler which gets called on every option
/// with the list of values (non-optional arguments between this option
/// and the next one).

typedef ParseArgsHandler = void Function(
    bool isFirstRun, String name, List values);

/// Loops through all command-line arguments [args], determines options,
/// collects possible values, validates those against the [format] and
/// calls a user-defined [handler]. Optional [format] should be defined
/// as a space-separated list string. Use a single colon for a single
/// value, two colons for multiple values, _b_ for binary int, _i_ for
/// decimal int, _o_ for octal int, _x_ for hex int, _f_ for floating point.
///
/// Example: r'\\?,h,help f,force i,inpfiles:: m,min:i n,max:i r,rate:f'

void parseArgs(String? optDefStr, List<String> args, ParseArgsHandler handler) {
  final optStop = '--';

  var optDefs = OptDef.listFromString(optDefStr);
  var isMultiRun = (OptDef.find(optDefs, OptDef.optMultiRun) != null);

  var argCount = args.length;
  var argMap = <String, List>{};
  var isValueOnly = false;

  // Loop through all arguments

  for (var argNo = 0; argNo < argCount;) {
    var arg = args[argNo];

    // If found an indicator of the end of options, don't treat any further argument as an option

    if (arg == optStop) {
      isValueOnly = true;
      continue;
    }

    // Get the option name if encountered

    var isOption = (!isValueOnly && arg.startsWith(OptDef.optPrefix));
    var name = (isOption ? arg : '');
    var normName = OptDef.normalize(name);
    var optDef = OptDef.find(optDefs, normName, canThrow: true);

    if (isOption) {
      ++argNo;
    }

    // Populate the list of values for the current option (all arguments beyond that and prior to the next one)

    var values = [];

    for (; argNo < argCount; argNo++) {
      arg = args[argNo];

      if (arg == optStop) {
        isValueOnly = true;
        continue;
      }

      if (!isValueOnly &&
          arg.startsWith(OptDef.optPrefix) &&
          (arg != OptDef.optPrefix)) {
        break;
      }

      if (optDef == null) {
        values.add(arg);
      } else {
        values.add(optDef.toTypedValue(normName, arg));
      }
    }

    // Find the option definition (throws exception if not found) and store in the arg map

    optDef?.validateMode(normName, values.length);
    var lastNorm =
        (optDef == null ? normName : optDef.names[optDef.names.length - 1]);
    argMap[lastNorm] = values;
  }

  // Call the user-defined handler for the actual processing in the order of appearance of definitions

  for (var step = 1, lastStep = (isMultiRun ? 2 : 1);
      step <= lastStep;
      step++) {
    argMap.forEach((name, values) {
      handler((step == 1), name, values);
    });
  }

  // Finish
}
