// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  group('CliOptName - getStopMode -', () {
    test('empty', () {
      expect(''.getCliOptStopMode(), CliOptStopMode.none);
    });
    test('stop', () {
      expect('---'.getCliOptStopMode(), CliOptStopMode.last);
    });
    test('stop and drop', () {
      expect('--'.getCliOptStopMode(), CliOptStopMode.stop);
    });
    test('other', () {
      expect('-'.getCliOptStopMode(), CliOptStopMode.none);
    });
  });
  group('CliOptName - isOption -', () {
    test('empty', () {
      expect(''.isCliOptNameValid(), false);
    });
    test('a letter', () {
      expect('a'.isCliOptNameValid(), false);
    });
    test('single prefix only', () {
      expect('-'.isCliOptNameValid(), false);
    });
    test('multiple prefices only', () {
      expect('-+-'.isCliOptNameValid(), false);
    });
    test('short', () {
      expect('-a'.isCliOptNameValid(), true);
    });
    test('short negative', () {
      expect('+a'.isCliOptNameValid(), true);
    });
    test('long', () {
      expect('--ab'.isCliOptNameValid(), true);
    });
    test('long negative', () {
      expect('--no-ab'.isCliOptNameValid(), true);
    });
    test('with value', () {
      expect('-a=bcd'.isCliOptNameValid(), true);
    });
  });
  group('CliOptName - isShort -', () {
    test('empty', () {
      expect(''.isCliOptNameShort(), false);
    });
    test('single prefix', () {
      expect('-'.isCliOptNameShort(), true);
    });
    test('single letter', () {
      expect('a'.isCliOptNameShort(), true);
    });
    test('multiple prefices followed by a single letter', () {
      expect('--a'.isCliOptNameShort(), true);
    });
    test(
        'multiple prefices followed by a negative suffix, then a single letter',
        () {
      expect('-+-no-A'.isCliOptNameShort(), false);
    });
    test('multiple letters', () {
      expect('ab'.isCliOptNameShort(), false);
    });
    test('multiple prefices followed by multiple letters', () {
      expect('--a-b'.isCliOptNameShort(), false);
    });
    test(
        'multiple prefices followed by a negative suffix, then a multiple letters',
        () {
      expect('-+=no-Ab'.isCliOptNameShort(), false);
    });
  });
  group('CliOptName - get without prefix -', () {
    test('empty', () {
      expect(''.getCliOptName(CliOptCaseMode.exact), '');
    });
    test('short', () {
      expect('-A'.getCliOptName(CliOptCaseMode.lower), 'a');
    });
    test('short negative', () {
      expect('+A'.getCliOptName(CliOptCaseMode.lower), 'a');
    });
    test('long', () {
      expect('-A-b--c'.getCliOptName(CliOptCaseMode.lower), 'abc');
    });
    test('long negative', () {
      expect('+A-b--c'.getCliOptName(CliOptCaseMode.lower), 'abc');
    });
  });
  group('CliOptName - get with prefix -', () {
    test('empty', () {
      expect(''.getCliOptName(CliOptCaseMode.exact, withPrefix: true), '');
    });
    test('short', () {
      expect('-A'.getCliOptName(CliOptCaseMode.lower, withPrefix: true), '-a');
    });
    test('short negative', () {
      expect('+A'.getCliOptName(CliOptCaseMode.lower, withPrefix: true), '+a');
    });
    test('long', () {
      expect('-A-b--c'.getCliOptName(CliOptCaseMode.lower, withPrefix: true),
          '-abc');
    });
    test('long negative', () {
      expect('+A-b--c'.getCliOptName(CliOptCaseMode.lower, withPrefix: true),
          '+abc');
    });
  });
  group('CliOptName - shrink -', () {
    test('empty', () {
      expect(''.shrinkCliOptName(), '');
    });
    test('short with a single prefix', () {
      expect('-a'.shrinkCliOptName(), 'a');
    });
    test('short negative with a single prefix', () {
      expect('+a'.shrinkCliOptName(), 'a');
    });
    test('short with a double prefix', () {
      expect('--a'.shrinkCliOptName(), 'a');
    });
    test('short negative with a double prefix', () {
      expect('++a'.shrinkCliOptName(), 'a');
    });
    test('short with a triple prefix', () {
      expect('---a'.shrinkCliOptName(), 'a');
    });
    test('short negative with a triple prefix', () {
      expect('+++a'.shrinkCliOptName(), 'a');
    });
    test('long with a single prefix', () {
      expect('-abc'.shrinkCliOptName(), 'abc');
    });
    test('long with a double prefix', () {
      expect('--abc'.shrinkCliOptName(), 'abc');
    });
    test('long with a triple prefix', () {
      expect('---abc'.shrinkCliOptName(), 'abc');
    });
    test('long with multiple prefices', () {
      expect('---ab--c-de-f'.shrinkCliOptName(), 'abcdef');
    });
    test('long negative with multiple prefices', () {
      expect('+-+ab-c+de-f'.shrinkCliOptName(), 'abcdef');
    });
  });
  group('CliOptName - toCase -', () {
    test('force - short lowercase', () {
      expect('a'.toLowerCliOptName(CliOptCaseMode.exact), 'a');
    });
    test('force - short uppercase', () {
      expect('A'.toLowerCliOptName(CliOptCaseMode.exact), 'A');
    });
    test('force - long', () {
      expect('AbC'.toLowerCliOptName(CliOptCaseMode.exact), 'AbC');
    });
    test('ignore - short lowercase', () {
      expect('a'.toLowerCliOptName(CliOptCaseMode.lower), 'a');
    });
    test('ignore - short uppercase', () {
      expect('A'.toLowerCliOptName(CliOptCaseMode.lower), 'a');
    });
    test('ignore - long', () {
      expect('AbC'.toLowerCliOptName(CliOptCaseMode.lower), 'abc');
    });
    test('smart - short lowercase', () {
      expect('a'.toLowerCliOptName(CliOptCaseMode.smart), 'a');
    });
    test('smart - short uppercase', () {
      expect('A'.toLowerCliOptName(CliOptCaseMode.smart), 'A');
    });
    test('smart - long', () {
      expect('AbC'.toLowerCliOptName(CliOptCaseMode.smart), 'abc');
    });
  });
}
