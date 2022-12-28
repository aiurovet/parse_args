// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:parse_args/src/str_ext.dart';

/// Class representing actual command-line option with arguments
/// retrieved from the parsed arguments
///
class CliOpt {
  /// The first index in the list of the actual arguments
  /// Is relevant to the first argument containing that option name
  /// This includes plain arguments as values of an option with empty
  /// name (useful when the order of options matters)
  ///
  final int argNo;

  /// Option full name (if this is an option, should contain prefix)
  ///
  late final String fullName;

  /// Value attached to the last option
  ///
  final values = <String>[];

  /// Reference to an option definintion (if found)
  ///
  final CliOptDef optDef;

  /// The constructor
  ///
  CliOpt(this.optDef, {String? fullName, this.argNo = -1}) {
    this.fullName = fullName ?? '';
  }

  /// Adding values
  ///
  int addValue(String? value) {
    if ((value == null) || value.isEmpty) {
      return 0;
    }

    if (optDef.isFlag) {
      throw CliOptValueUnexpectedException(fullName);
    }

    final unquoted = value.unquote();

    if (optDef.valueSeparator.isEmpty) {
      values.add(unquoted);
      return 1;
    }

    var newValues = unquoted.split(optDef.valueSeparator);
    values.addAll(newValues);

    return newValues.length;
  }

  /// Validating value count
  ///
  void validateValueCount() {
    if (optDef.isFlag) {
      if (values.isNotEmpty) {
        throw CliOptValueUnexpectedException(fullName, values);
      }
      return;
    }

    if (values.isEmpty) {
      throw CliOptValueMissingException(fullName);
    }

    if (!optDef.hasManyValues && (values.length > 1)) {
      throw CliOptValueTooManyException(fullName, values);
    }
  }

  /// Standard serializer
  ///
  @override
  String toString() {
    return '"$fullName": $values';
  }
}
