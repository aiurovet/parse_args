// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Extension methods for the string manipulations
///
extension StrExt on String {
  /// A function to return a string with surrounding quotes removed from [input]
  ///
  String unquote() {
    final lastPos = (length - 1);

    if (lastPos < 1) {
      return this;
    }

    final quote = this[0];

    if ((quote == '"') || (quote == "'")) {
      if (this[lastPos] == quote) {
        return substring(1, lastPos);
      }
    }

    return this;
  }
}
