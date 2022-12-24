// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// Extension methods to manipulate generic lists
///
extension ListEx on List {
  dynamic firstOrDefault({dynamic defValue}) => (isEmpty ? defValue : first);
}
