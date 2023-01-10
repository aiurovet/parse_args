// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

/// Parse sub-commands and their arguments
///
bool parseSubCmd(List<String> args, {CliOptSubCmdMap? map}) =>
    CliSubCmdParser.exec(args, map: map);
