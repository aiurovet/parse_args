/// A type for the user-defined handler which gets called on every option
/// with the list of values (non-optional arguments between this option
/// and the next one)

typedef ParseArgsHandler = bool Function(String optName, List<String> values);

/// Loops through all command-line arguments [args], determines options,
/// collects possible values and calls a user-defined [handler]

void parseArgs(List<String> args, ParseArgsHandler handler) {
  final optNamePrefix = '-';
  final optNameStop = '--';

  var argCount = args.length;
  var isValueOnly = false;
  var values = <String>[];

  // Loop through all arguments

  for (var argNo = 0; argNo < argCount;) {
    var arg = args[argNo];

    // If found an indicator of the end of options, don't treat any further argument as an option

    if (arg == optNameStop) {
      isValueOnly = true;
      continue;
    }

    // Get the option name if encountered

    var isOption = (!isValueOnly && arg.startsWith(optNamePrefix));
    var optName = (isOption ? arg : '');
    var optNorm = optName.replaceAll(optNamePrefix, '').toLowerCase();

    if (isOption) {
      ++argNo;
    }

    // Populate the list of values for the current option (all arguments beyond that and prior to the next one)

    values = [];

    for (; argNo < argCount; argNo++) {
      arg = args[argNo];

      if (arg == optNameStop) {
        isValueOnly = true;
        continue;
      }

      if (!isValueOnly &&
          arg.startsWith(optNamePrefix) &&
          (arg != optNamePrefix)) {
        break;
      }

      values.add(arg);
    }

    // Call the user-defined handler for the actual application processing

    if (!handler(optNorm, values)) {
      break;
    }
  }

  // Finish
}
