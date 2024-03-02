
EnableExplicit

IncludePath ".."
IncludeFile "RegExEngine.pbi"

Define.Character *string
Define *regEx
Define result
Define string$

string$ = "123_123x12 1"

*regEx = RegEx::Init()
If *regEx = 0
  Debug "Error"
  End
EndIf

If RegEx::AddNfa(*regEx, "1|123|12") = #False
  Debug RegEx::GetLastErrorMessages()
  RegEx::Free(*regEx)
  End
EndIf

Debug "== Results with NFA =="
Debug ""

*string = @string$
While *string\c
  result = RegEx::Match(*regEx, *string)
  If result
    Debug RegEx::GetString(*string, result)
  EndIf
  *string + SizeOf(Unicode)
Wend

Debug ""
Debug "== Results with DFA =="
Debug ""
RegEx::CreateDfa(*regEx)

*string = @string$
While *string\c
  result = RegEx::Match(*regEx, *string)
  If result
    Debug RegEx::GetString(*string, result)
  EndIf
  *string + SizeOf(Unicode)
Wend

RegEx::Free(*regEx)
