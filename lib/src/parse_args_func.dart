// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/src/opt_name_enums.dart';
import 'package:parse_args/src/opt_parser.dart';
import 'package:parse_args/src/parse_args_result.dart';

/// Loops through all command-line arguments [args], determines options,
/// collects possible values, validates those against [optDefStr] and
/// calls a user-defined [handler]. Optional [optDefStr] should be defined
/// as a pipe-separated list string. Use a single colon for a single
/// value, two colons for multiple values, 'b' for binary int, _f_ for
/// double-precision float, 'i' for decimal int, 'o' for octal int,
/// 'x' for hex int. Use a leading '+|' to request a double pass through
/// the arguments (this allows to 'look-ahead' in case of dependent options)
///
/// '+|?,h,help|f,force|i,inpfiles::|min:i|max:i|r,rate:f'
///
ParseArgsResult parseArgs(String? optDefStr, List<String> args,
        {isBundlingEnabled = true,
        OptNameCaseMode caseMode = OptNameCaseMode.smart,
        String valueSeparator = ''}) =>
    OptParser(
            isBundlingEnabled: isBundlingEnabled,
            caseMode: caseMode,
            valueSeparator: valueSeparator)
        .exec(optDefStr, args);
