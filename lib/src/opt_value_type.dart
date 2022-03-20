// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

///
/// Enumeration for the possible datatypes of expected values,
/// used to decide on how to parse input values before calling
/// the user-defined handler
///

enum OptValueType {
  nil, // no type (default value)
  bit, // binary int (radix = 2)
  dec, // decimal int (radix = 10)
  hex, // hexadecimal int (radix= 16)
  num, // double precision float
  oct, // octal in (radix = 10)
  str // string
}
