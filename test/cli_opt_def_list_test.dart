// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  final caseMode = CliOptCaseMode.smart;

  group('fromString -', () {
    test('empty', () {
      var optDefs = CliOptDefList.cliOptDefsFromString('', caseMode);
      expect(optDefs.getCliOptDefsLongNames().isEmpty, true);
    });
    test('general', () {
      var optDefs = CliOptDefList.cliOptDefsFromString(
          'a,ab,cd:,:>i,icase|e,efg|::', caseMode);
      expect(optDefs.getCliOptDefsLongNames(), ['ab', 'cd', 'efg']);
      expect(optDefs.getCliOptDefsLongSubNames(), ['icase']);
      expect(optDefs.getCliOptDefsLongNames(isNegative: true), ['noefg']);
      expect(optDefs.getCliOptDefsLongSubNames(isNegative: true), ['noicase']);
      expect(optDefs.getCliOptDefsShortNames(), ['a', 'e']);
      expect(optDefs.getCliOptDefsShortSubNames(), ['i']);
    });
  });
  group('find -', () {
    test('empty', () {
      var optDefs = CliOptDefList.cliOptDefsFromString('', caseMode);
      expect(optDefs.getCliOptDefsLongNames().isEmpty, true);
    });
    test('general', () {
      var optDefs = CliOptDefList.cliOptDefsFromString(
          'a,ab,cd:,:>i,icase|e,efg|::', caseMode);
      expect(optDefs.findCliOptDef('a')?.name, 'cd');
      expect(optDefs.findCliOptDef('ab')?.name, 'cd');
      expect(optDefs.findCliOptDef('nocd'), null);
      expect(optDefs.findCliOptDef('noefg')?.name, 'efg');
      expect(optDefs.findCliOptDef('i'), null);
    });
  });
}
