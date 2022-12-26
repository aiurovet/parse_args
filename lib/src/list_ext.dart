// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Extension methods to manipulate generic lists
///
extension ListEx on List {
  /// A method to get thye first element or null (if the list is empty)
  ///
  dynamic firstOrDefault({dynamic defValue}) => (isEmpty ? defValue : first);
}
