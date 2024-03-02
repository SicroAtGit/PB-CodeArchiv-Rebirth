
EnableExplicit

IncludeFile ".." + #PS$ + "RegExEngine.pbi"

Define *regEx = RegEx::UseDfaFromMemory(?dfa)

If *regEx
  If RegEx::Match(*regEx, @"Test")
    Debug "Match!"
  Else
    Debug "No match!"
  EndIf
  RegEx::Free(*regEx)
Else
  Debug "Error!"
EndIf

DataSection
  dfa:
  IncludeBinary "DFA_in_DataSection.dfa"
EndDataSection
