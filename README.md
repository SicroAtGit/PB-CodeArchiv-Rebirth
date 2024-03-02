# RegEx-Engine

https://github.com/SicroAtGit/RegEx-Engine

## About

This RegEx engine compiles a regular expression string into an NFA, and can optionally convert the NFA into a DFA, which executes much faster; the generated NFA/DFA can then be executed against a string.

The RegEx engine will always return the longest possible match among several possible matches. During this process no backtracking is required, because all alternations are checked simultaneously.

RegExes can be assigned unique RegEx ID numbers, which allow to determine which RegEx matched when executing multiple RegExs simultaneously. This feature is useful for creating lexers, which is the main focus of the project. At the same time, the RegEx engine is kept flexible, so that it might be employed in a variety of other contexts, beside lexers creation.

## Examples

### Simple Match

```purebasic
*regEx = RegEx::Init()
If *regEx
  RegEx::AddNfa(*regEx, "test|example")
  If RegEx::Match(*regEx, @"example")
    Debug "Match!"
  Else
    Debug "No match!"
  EndIf
  RegEx::Free(*regEx)
Else
  Debug "Error!"
EndIf
```

### Multiple RegExes Simultaneously

```purebasic
Enumeration
  #RegExId_Word
  #RegExId_Number
EndEnumeration

*regEx = RegEx::Init()
If *regEx
  RegEx::AddNfa(*regEx, "\w+", #RegExId_Word)
  RegEx::AddNfa(*regEx, "\d+", #RegExId_Number)
  If RegEx::Match(*regEx, @"example", @regExId)
    Select regExId
      Case #RegExId_Word:   Debug "Match is a word!"
      Case #RegExId_Number: Debug "Match is a number!"
    EndSelect
  Else
    Debug "No match!"
  EndIf
  RegEx::Free(*regEx)
Else
  Debug "Error!"
EndIf
```

More code examples can be found in the [`Source/Examples/`][Examples] directory.

## Supported Syntax

| Syntax  | Meaning |
| ------- | ------- |
| `xy`    | `x` followed by `y` (Concatenation) |
| `x\|y`  | `x` or `y` (Alternation) |
| `x*`    | Zero or more consecutive `x` |
| `x+`    | One or more consecutive `x` |
| `x?`    | Zero or one `x` |
| `(` `)` | Groups a regular expression. Groups inherit the active modes of their parent context. Mode changes within a group have no effect on the surrounding contexts. |
| `\*`    | Escapes the metacharacter `*` and treats it as a literal character.<br>Works also with the other metacharacters: `\|` `+` `?` `(` `)` `\` |
| `\r`    | Matches the carriage return character (`\x0D`) |
| `\n`    | Matches the line feed character (`\x0A`) |
| `\t`    | Matches the horizontal tab character (`\x09`) |
| `\f`    | Matches the form feed character (`\x0C`) |
| `[x]`   | Where `x` can be a combination of: single literal character, escape sequence, or range (`a-c`) |
| `.`     | Matches any character except `\r` and `\n` |
| `\d`    | Matches Unicode characters class [Nd] |
| `\D`    | Matches any character except those in Unicode characters class [Nd] |
| `\s`    | Matches Unicode characters class [White_Space] |
| `\S`    | Matches any character except those in Unicode characters class [White_Space] |
| `\w`    | Matches Unicode characters classes [Alphabetic, M, Nd, Pc and Join_Control] |
| `\W`    | Matches any character except those in Unicode characters classes [Alphabetic, M, Nd, Pc and Join_Control] |
| `\x`    | Matches the character represented by the two digit hex code `x` (`\x01`–`\xFF`) |
| `\u`    | Matches the character represented by the four digit hex code `u` (`\u0001`–`\uFFFF`) |
| `(?m)`  | Toggles the RegEx mode states. `m` can be one or more flags. To deactivate a RegEx mode prefix a flag with a minus sign |

## Unicode Support

Like the native string functions in PureBasic: UCS-2 character encoding, UTF-16 surrogate pairs are interpreted as two single UCS-2 characters.

## Case-Insensitive Mode

Flag: `i`

The implementation uses [Unicode's Simple Case Folding] variant, but in reverse: instead of mapping all character variations to a single character (folding), a single character is mapped to all character variations (unfolding). This is necessary because the DFA must know all valid characters.

## ASCII Mode

Flag: `a`

When active, the predefined character classes will only match the corresponding ASCII characters. For example, `(?a)\w` will match only `[a-zA-Z0-9_]`. The character encoding remains UCS-2 in this mode, i.e. `(?a)\W` matches all UCS-2 characters except `[a-zA-Z0-9_]`.

This RegEx mode is also useful in combination with `#RegExMode_NoCase` when you want to lex for keywords within source code, case-insensitively, but no case-folding should be applied:

- `(?i)set` corresponds to `[Ss\u017F][Ee][Tt]`
- `(?ia)set` corresponds to `[Ss][Ee][Tt]`

## Public Constants

```purebasic
EnumerationBinary RegExModes
  #RegExMode_NoCase ; Activates case-insensitive mode
  #RegExMode_Ascii  ; Activates ASCII mode
EndEnumeration
```

```purebasic
Enumeration NfaStateTypes
  #StateType_EpsilonMove ; Used for NFA epsilon moves
  #StateType_SymbolMove  ; Used for NFA symbol moves
  #StateType_SplitMove   ; Used for NFA unions
  #StateType_Final       ; Used for NFA final state
EndEnumeration
```

```purebasic
#State_DfaDeadState = 0 ; Index number of the DFA dead state
```

## Public Structures

```purebasic
Structure ByteRangeStruc
  min.a ; Minimum byte value (0-255)
  max.a ; Maximum byte value (0-255)
EndStructure
```

```purebasic
Structure NfaStateStruc
  stateType.u               ; Type of the NFA state (regExId = stateType - #StateType_NfaFinal)
  byteRange.ByteRangeStruc  ; A byte range is used as a transition symbol
  *nextState1.NfaStateStruc ; Pointer to the first next NFA state
  *nextState2.NfaStateStruc ; Pointer to the second next NFA state
EndStructure
```

```purebasic
Structure DfaStateStruc
  nextState.u[256] ; Index is the symbol (0-255) and the value is the next DFA state
  isFinalState.u   ; Positive number if the DFA state is a final state, otherwise null
EndStructure
```

```purebasic
Structure DfaStatesArrayStruc
  states.DfaStateStruc[0] ; Array pointer to the DFA states
EndStructure
```

```purebasic
Structure NfaPoolStruc
  List nfaStates.NfaStateStruc() ; Holds all NFA states of the NFA pool
  *initialNfaState.NfaStateStruc ; Pointer to the NFA initial state
EndStructure
```

```purebasic
Structure RegExEngineStruc
  List nfaPools.NfaPoolStruc()       ; Holds all NFA pools
  *dfaStatesPool.DfaStatesArrayStruc ; Holds all DFA states
  isUseDfaFromMemory.b               ; `#True` if `UseDfaFromMemory()` was used, otherwise `#False`
EndStructure
```

## Public Macros

- **`GetString(_memoryAddress_, _lengthInBytes_)`**<br><br>
Simplifies extracting the matched string via its memory address and length info obtained from a `Match()` call.

## Public Functions

- **`Init()`**<br><br>
Creates a new RegEx engine and returns the pointer to the `RegExEngineStruc` structure. If an error occurred null is returned.

- **`AddNfa(*regExEngine.RegExEngineStruc, regExString$, regExId = 0, regExModes = 0)`**<br><br>
Compiles the RegEx string into an NFA which is added to the NFAs pool in the RegEx engine. On success `#True` is returned, otherwise `#False`. A unique number can be passed to `regExId` to determine later which RegEx has matched. The optional `regExModes` parameter allows defining which RegEx modes should be activated at the beginning; its currently supported values are:

    - `#RegExMode_NoCase` — Activates case-insensitive mode
    - `#RegExMode_Ascii` — Activates ASCII mode

    To set multiple parameters, combine them with the `|` operator (bitwise OR).

- **`CreateDfa(*regExEngine.RegExEngineStruc, clearNfa = #True)`**<br><br>
Creates a single DFA from the existing NFAs in the RegEx engine. `Match()` will henceforth always use the DFA, which is much faster. Because the NFAs are no longer used after this, they are cleared by default; to preserve them set parameter `clearNfa` to `#False`. On success `#True` is returned, otherwise `#False`. If a DFA already exists, the DFA will be freed before creating a new DFA.

- **`Free(*regExEngine.RegExEngineStruc)`**<br><br>
Frees the RegEx engine.

- **`UseDfaFromMemory(*dfaMemory)`**<br><br>
Creates a new RegEx engine and assigns an existing DFA stored in external memory to the RegEx engine. After calling this procedure, the RegEx engine is immediately ready for use, without requiring to call `Init()`, `AddNfa()` or `CreateDfa()`. On success the pointer to `RegExEngineStruc` is returned, otherwise null.

- **`Match(*regExEngine.RegExEngineStruc, *string.Unicode, *regExId.Integer = 0)`**<br><br>
Runs the RegEx engine against the target string, passed via a pointer. The match search will start from the beginning of the string. If a match is found, the byte length of the match is returned, otherwise null. If the address of an integer variable was passed as the optional `*regExId` parameter, the RegEx ID number of the matching RegEx is written into it. If multiple RegExes match the same string, each having been assigned a different RegEx ID number, the RegEx ID number of the last matching RegEx will be picked, i.e. the matching RegEx that was last added with the `AddNfa()` function.

- **`GetLastErrorMessages()`**<br><br>
Returns the error messages of the last `AddNfa()` call, as a human-readable string.

- **`ExportDfa(*regExEngine.RegExEngineStruc, filePath$)`**<br><br>
Exports the created DFA as a binary file. On success `#True` is returned, otherwise `#False`.

## Reduced DFA Matcher Module

The reduced module `DfaMatcher` provides only a DFA matcher which uses the precompiled DFAs created with the main module.

If only the precompiled DFAs are needed in the software, for matching, and no new NFAs/DFAs are to be created at runtime, then the reduced module can be used. This way the software is not unnecessarily bloated with the large Unicode tables and the rest of the code found in the main module.

### Public Constants

```purebasic
#State_DfaDeadState = 0 ; Index number of the DFA dead state
```

### Public Structures

```purebasic
Structure DfaStateStruc
  nextState.u[256] ; Index is the symbol (0-255) and the value is the next DFA state
  isFinalState.u   ; Positive number if the DFA state is a final state, otherwise null
EndStructure
```

```purebasic
Structure DfaStatesArrayStruc
  states.DfaStateStruc[0] ; Array pointer to the DFA states
EndStructure
```

### Public Macros

- **`GetString(_memoryAddress_, _lengthInBytes_)`**<br><br>
Simplifies extracting the matched string via its memory address and length info obtained from a `Match()` call.

### Public Functions

- **`Match(*dfaMemory, *string.Unicode, *regExId.Integer = 0)`**<br><br>
Runs the DFA against the target string, passed via a pointer. The match search will start from the beginning of the string. If a match is found, the byte length of the match is returned, otherwise null. If the address of an integer variable was passed as the optional `*regExId` parameter, the RegEx ID number of the matching RegEx is written into it. If multiple RegExes match the same string, each having been assigned a different RegEx ID number, the RegEx ID number of the last matching RegEx will be picked, i.e. the matching RegEx that was last added with the `AddNfa()` function.

## Would you like to contribute to the project?

Then please check out [CONTRIBUTING] for details.

## License

The project is licensed under the [MIT license].

<!--------------------------------------------------------------------------->

[Unicode's Simple Case Folding]: https://unicode.org/reports/tr18/#Simple_Loose_Matches "Unicode Regular Expressions (TR#18) » §1.5 Simple Loose Matches"

[Nd]: https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3ANd%3A%5D&abb=on&esc=on&g=&i= "UnicodeSet Utility: characters class 'Nd'"
[White_Space]: https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AWhite_Space%3A%5D&abb=on&esc=on&g=&i= "UnicodeSet Utility: characters class 'White_Space'"
[Alphabetic, M, Nd, Pc and Join_Control]: https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3AAlphabetic%3A%5D%5B%3AM%3A%5D%5B%3ANd%3A%5D%5B%3APc%3A%5D%5B%3AJoin_Control%3A%5D&abb=on&esc=on&g=&i= "UnicodeSet Utility: characters classes 'Alphabetic', 'M', 'Nd', 'Pc' and 'Join_Control'"

[MIT license]: ./LICENSE
[CONTRIBUTING]: ./CONTRIBUTING.md
[Examples]: ./Source/Examples/ "Navigate to examples folder"
