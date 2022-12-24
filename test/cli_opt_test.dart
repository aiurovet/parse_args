// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  group('Constructor + addValue -', () {
    test('flag - got no value', () {
      final opt = CliOpt(CliOptDef('a', CliOptCaseMode.exact));
      expect(opt.values.length, 0);
    });
    test('single value - got no value (null)', () {
      final opt = CliOpt(CliOptDef('a:', CliOptCaseMode.exact))..addValue(null);
      expect(opt.values.length, 0);
    });
    test('single value - got no value (empty)', () {
      final opt = CliOpt(CliOptDef('a:', CliOptCaseMode.exact))..addValue('');
      expect(opt.values.length, 0);
    });
    test('single value - got a value', () {
      final opt = CliOpt(CliOptDef('a:', CliOptCaseMode.exact))..addValue('1');
      expect(opt.values.length, 1);
    });
    test('single value - multiple values will not split', () {
      final opt = CliOpt(CliOptDef('a:', CliOptCaseMode.exact))
        ..addValue('1,2');
      expect(opt.values.length, 1);
    });
    test('multiple values - got no value', () {
      final opt = CliOpt(CliOptDef('a::', CliOptCaseMode.exact))
        ..addValue(null);
      expect(opt.values.length, 0);
    });
    test('multiple values - got a value', () {
      final opt = CliOpt(CliOptDef('a:,:', CliOptCaseMode.exact))
        ..addValue('1');
      expect(opt.values.length, 1);
    });
    test('multiple values - got multiple values', () {
      final opt = CliOpt(CliOptDef('a:,:', CliOptCaseMode.exact))
        ..addValue('1,2');
      expect(opt.values.length, 2);
    });
  });
  group('validateValueCount -', () {
    test('flag - got no value', () {
      CliOpt(CliOptDef('a', CliOptCaseMode.exact)).validateValueCount();
    });
    test('single value - got no value', () {
      expect(
          () => CliOpt(CliOptDef('a:', CliOptCaseMode.exact))
            ..addValue(null)
            ..validateValueCount(),
          throwsA((e) => e is CliOptValueMissingException));
    });
    test('single value - got a value', () {
      CliOpt(CliOptDef('a:', CliOptCaseMode.exact))
        ..addValue('1')
        ..validateValueCount();
    });
    test('single value - multiple values will not split', () {
      CliOpt(CliOptDef('a:', CliOptCaseMode.exact))
        ..addValue('1,2')
        ..validateValueCount();
    });
    test('multiple values - got no value', () {
      expect(
          () => CliOpt(CliOptDef('a::', CliOptCaseMode.exact))
            ..addValue(null)
            ..validateValueCount(),
          throwsA((e) => e is CliOptValueMissingException));
    });
    test('multiple values - got a value', () {
      CliOpt(CliOptDef('a:,:', CliOptCaseMode.exact))
        ..addValue('1')
        ..validateValueCount();
    });
    test('multiple values - got multiple values', () {
      final opt = CliOpt(CliOptDef('a:,:', CliOptCaseMode.exact))
        ..addValue('1,2')
        ..validateValueCount();
      expect(opt.values.length, 2);
    });
  });
}
