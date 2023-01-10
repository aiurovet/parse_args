// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';

typedef CliOptSubCmdMap = Map<String, Function(List<String> args)>;

/// Class to break command-line arguments into a sub-command and its arguments
///
class CliSubCmdParser {
  /// Check the first argument is a sub-command and execute the parser mapped to that
  ///
  static bool exec(List<String> args, {CliOptSubCmdMap? map}) {
    final argCount = args.length;
    final subCmd = (argCount <= 0 ? '' : args[0]);

    if (!subCmd.isCliSubCmdValid()) {
      return false;
    }

    final parser = map?[subCmd];

    if (parser == null) {
      return false;
    }

    parser(args.sublist(1));
    return true;
  }
}
