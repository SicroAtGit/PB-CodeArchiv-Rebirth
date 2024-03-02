
EnableExplicit

IncludeFile ".." + #PS$ + "DfaMatcher.pbi"

If DfaMatcher::Match(?dfa, @"Test")
  Debug "Match!"
Else
  Debug "No match!"
EndIf

DataSection
  dfa:
  IncludeBinary "DFA_in_DataSection.dfa"
EndDataSection
