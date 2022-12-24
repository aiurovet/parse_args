// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// Sub-command mapping
///
CliOptSubCmdMap map = {
  "sub1": (List<String> args) {},
  "sub2": (List<String> args) {},
};

/// The main entry point for tests
///
void main() {
  group('exec -', () {
    test('no sub-command', () {
      expect(CliSubCmdParser.exec([], map: map), false);
    });
    test('invalid sub-command', () {
      expect(CliSubCmdParser.exec(['sub3'], map: map), false);
    });
    test('sub-command hidden by an option', () {
      expect(CliSubCmdParser.exec(['-a', 'sub3'], map: map), false);
    });
    test('correct sub-command', () {
      expect(CliSubCmdParser.exec(['sub2'], map: map), true);
    });
  });
}
