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
/// as a pipe-separated list string. Use a single colon for a single
/// value, two colons for multiple values, 'b' for binary int, _f_ for
/// double-precision float, 'i' for decimal int, 'o' for octal int,
/// 'x' for hex int:
///
/// '+|?,h,help|f,force|i,inpfiles::|min:i|max:i|r,rate:f'

void parseArgs(String? optDefStr, List<String> args, ParseArgsHandler handler) {
  var optDefs = OptDef.listFromString(optDefStr);
  var isMultiRun = (OptDef.find(optDefs, OptDef.optMultiRun) != null);

  var argCount = args.length;
  var argMap = <String, List>{};
  var isValueOnly = false;

  // Loop through all arguments

  for (var argNo = 0; argNo < argCount;) {
    var arg = args[argNo];

    // If found an indicator of the end of options, don't treat any further argument as an option

    if (arg == OptDef.optStop) {
      isValueOnly = true;
      ++argNo;
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

      if (optDef == null) {
        values.add(arg);
      } else {
        values.add(optDef.toTypedValue(normName, arg));
      }
    }

    // Find the option definition (throws exception if not found) and store in the arg map

    optDef?.validateValueCount(normName, values.length);
    var names = optDef?.names;
    var nameCount = names?.length ?? 0;
    argMap[names == null ? normName : names[nameCount - 1]] = values;
  }

  // Call the user-defined handler for the actual processing in the order of appearance of definitions

  var lastStep = (isMultiRun ? 2 : 1);

  for (var step = 1; step <= lastStep; step++) {
    argMap.forEach((name, values) {
      handler((step == 1), name, values);
    });
  }

  // Finish
}
