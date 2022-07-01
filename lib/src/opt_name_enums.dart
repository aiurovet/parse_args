// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// The way to compare and find option and sub-option names
///
enum OptNameCaseMode {
  /// Case-sensitive for any name
  ///
  force,

  /// Case-insensitive for any name
  ///
  ignore,

  /// Case-sensitive short names and case-insensitive long ones (default)
  ///
  smart,
}

/// The way to stop treating arguments as option names
///
enum OptNameStopMode {
  /// No stop yet (initializer)
  ///
  none,

  /// Stop testing arguments on representing option names, but
  /// keep the last option active (the following arguments are its values)
  ///
  stop,

  /// Stop testing arguments on representing option names and
  /// drop the last active option name (the following arguments are plain)
  ///
  stopAndDrop
}
