## 0.9.2

- Changed default CliOptCaseMode from lower to smart

## 0.9.1

- Removed unused imports

## 0.9.0

- Complete overhaul (an utterly breaking change): allowing short options bundling and negative options, different case modes, getting values directly (no callbacks), allowing sub-options (treated as plain arguments only, no sub-option values), value separator is built into the option definitions string. Value type was removed from the option definintion, no plus sign in the beginning of the options definition string: no need to perform multiple passes at all.

## 0.8.0

- Added optional smart bundling (default) - ability to combine short option names
- Breaking: short options are case-sensitive (default), but the long ones are always not
- Moved OptDef's normalize to OptName

## 0.7.1

- A bugfix for a sub-option of a plain argument
- Added more documentation
- Improved readability of the example

## 0.7.0

- Breaking: if an option has no value and is followed by a non-option, the latter is treated as a plain argument; if an option has a single value followed by more than one non-options, the first of those is treated as an option value, and the following ones are considered as plain arguments until the next option name comes.
- Added OptPlanArgsException which is thrown when the list of possible options does not admit plain arguments

## 0.6.2

- Breaking: swapped the meaning of '--' (now: no more option and stop the last option) and '---' (now: no more option, but don't stop the last option). This is much needed for the compatibility with the standard interpretation of '--'
- Fixed minor issues in the example
- Added documentation

## 0.6.1

- Fixed and enhanced README.md

## 0.6.0

- Added sub-options (see README.md for more detail)
- Breaking: added ability to append "x3" to the list of values of "-o" in case of -o="x1,x2" "x3" (previously, "x3" was added to the list of plain arguments)

## 0.5.3

- Upgraded compiler version to 2.17
- Added the project repo to pubspec.yaml

## 0.5.2

- Changed the project homepage

## 0.5.1

- The function 'unquote' is moved away from the public access in order to avoid possible clashes with the similar ones in consuming applications.

## 0.5.0

- New feature: support for -name=value, -name="value", -name='value', -name="value1,value2,...", -name='value1,value2,...'.
  The next plain argument is not treated as another value of this option in order to avoid the visual confusion.

## 0.4.2

- Bug fix: not the last option name was passed to the handler.

## 0.4.1

- A test for the bad value separator usage.

## 0.4.0

- The ability to pass value separator and to split a single argument coming after the respective option.

## 0.3.1

- The options definitions string can be multi-line, as all blank characters will get removed.
- Several constants in OptDef made private as being insignificant outside the class.

## 0.3.0

- Make calls to the user-defined handler in the order of the options appearing in the definitions list.

## 0.2.3

- Fixed description in pubspec.yaml and README.md.
- Added documentation foer a few constants

## 0.2.2

- Fixed minor bugs.
- Extended comments and made them uniform (same style)
- Got rid of dart:io dependency in OptException
- Removed unused property OptDef.level

## 0.2.1

- Fixed minor bugs.
- Made various parts of documentation consistent.
- Renamed OptValueMode to OptValueCountType.

## 0.2.0

- Added ability to define options to parse as well as to automate options/values validations.
- Added ability to get values pre-converted to one of the known types (binary, decimal, hexadecimal, octal, double-precision float, string).
- Added ability to perform arguments parsing twice (options definition string is parsed once as before). This is useful when you need to know more than one value while parsing. For instance, if the start-in directory and a filename are both options, you can't assign the file path straightaway
- Full compatibility with the older version - just pass the null or empty string.

## 0.1.1

- Fixed Dart formatting issues.
- Minor fixes in documentation.

## 0.1.0

- Initial release.
