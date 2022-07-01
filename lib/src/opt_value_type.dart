// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Enumeration for the possible datatypes of expected values,
/// used to decide on how to parse input values before calling
/// the user-defined handler
///
enum OptValueType {
  /// No type (default value)
  ///
  nil,

  /// Binary int (radix = 2)
  ///
  bit,

  /// Decimal int (radix = 10)
  ///
  dec,

  /// Glob pattern
  ///
  glob,

  /// Hexadecimal int (radix= 16)
  ///
  hex,

  /// Double precision float
  ///
  num,

  /// Octal in (radix = 10)
  ///
  oct,

  /// Regular expression pattern
  ///
  regExp,

  /// String
  ///
  str
}
