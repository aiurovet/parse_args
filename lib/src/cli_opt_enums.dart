// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

/// The way to compare and find option and sub-option names
///
enum CliOptCaseMode {
  /// Do not convert any case and perform exct match
  ///
  exact,

  /// Convert any name to lower case (default)
  ///
  lower,

  /// Convert long names to lower case and keep the short ones intact
  ///
  smart,
}

/// The way to stop treating arguments as option names
///
enum CliOptStopMode {
  /// No stop yet (initializer)
  ///
  none,

  /// Stop testing arguments on representing option names, but
  /// keep the last option active (the following arguments are its values)
  ///
  last,

  /// Stop testing arguments on representing option names and
  /// drop the last active option name (the following arguments are plain)
  ///
  stop,
}
