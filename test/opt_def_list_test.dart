// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  group('getLongNames -', () {
    test('empty', () {
      var optDefs = OptDefList.fromString('');
      expect(optDefs.getLongNames().isEmpty, true);
    });
    test('no shorts', () {
      var optDefs = OptDefList.fromString('ab,cd|efg');
      expect(optDefs.getLongNames(), ['ab', 'cd', 'efg']);
    });
    test('no shorts with sub-opts', () {
      var optDefs = OptDefList.fromString('ab,cd|efg>hi|::>jkl,mn');
      expect(optDefs.getLongNames(), ['ab', 'cd', 'efg', 'hi', 'jkl', 'mn']);
    });
    test('no clash', () {
      var optDefs = OptDefList.fromString('a,ab,c,cd|efg>hi|::>jkl,mn');
      expect(optDefs.getLongNames(), ['ab', 'cd', 'efg', 'hi', 'jkl', 'mn']);
    });
    test('with clash - release', () {
      var optDefs = OptDefList.fromString('b,ab,c,cd|efg>hi|::>jkl,a,mn');
      expect(optDefs.getLongNames(), ['ab', 'cd', 'efg', 'hi', 'jkl', 'mn']);
    });
    test('with clash - test', () {
      expect(
          () => OptDefList.fromString('b,ab,c,cd|efg>hi|::>jkl,a,mn')
              .testLongNames(),
          throwsA((e) => e is OptBadLongNameException));
    });
  });
}
