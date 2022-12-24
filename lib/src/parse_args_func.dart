// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// Loops through all command-line arguments [args], determines options,
/// collects possible values, validates those against [optDefStr] and
/// returns a list of parsed options for the further queries by using
/// isSet(...), getStrValues(...) etc.
///
List<CliOpt> parseArgs(String optDefStr, List<String> args,
        {CliOptCaseMode caseMode = CliOptCaseMode.lower,
        bool validate = false}) =>
    CliOptParser(optDefStr, caseMode, validate: validate).exec(args);
