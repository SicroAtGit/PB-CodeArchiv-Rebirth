
; Creates the case folding table in reversed form (content of
; `Source/UnicodeTables/SimpleCaseUnfolding.pbi`). After execution, the
; complete PB code is in the clipboard.
; 
; The characters that are considered identical by the case folding table are
; not normalized to a single character, but a single character is mapped to a
; list that includes all characters considered identical to the character,
; including the character itself.
; For example:
;   [a] maps to [Aa]
; and not as the offical case folding table does:
;   [Aa] maps to [a]
; This is necessary because case folding is not applied during the NFA/DFA
; match process, but already during NFA/DFA creation.

EnableExplicit

Structure SubListStruc
  List chars.i()
EndStructure

Define.SubListStruc NewList subLists()
Define file, code, mapping, isFound, currentChar
Define offsetOfCountOfChars, countOfChars, maxHexCodeLength
Define line$, status$, allDataLines$, allDataSectionLines$, chars$

If Not ReceiveHTTPFile("https://www.unicode.org/Public/14.0.0/ucd/CaseFolding.txt", "CaseFolding.txt")
  Debug "ReceiveHTTPFile(): Error"
  End
EndIf

file = ReadFile(#PB_Any, "CaseFolding.txt")
If file = 0
  Debug "ReadFile(): Error"
  End
EndIf

While Not Eof(file)
  line$ = ReadString(file)
  
  ; Skip comments
  If Left(line$, 1) = "#"
    Continue
  EndIf
  
  code = Val("$" + Trim(StringField(line$, 1, ";")))
  status$ = Trim(StringField(line$, 2, ";"))
  mapping = Val("$" + Trim(StringField(line$, 3, ";")))
  
  isFound = #False
  Select status$
    Case "C", "S" ; Status symbols for simple case folding
      
      ; PureBasic supports character codes only up to $FFFF, because
      ; UCS-2 encoding is used.
      If code > $FFFF
        Continue
      EndIf
      
      ; Needed to determine the number of required leading zeros of the
      ; hexadecimal numbers
      maxHexCodeLength = Len(Hex(code))
      
      ; Sublists are created to group characters considered identical by the
      ; case folding table.
      If ListSize(subLists())
        ForEach subLists()
          ForEach subLists()\chars()
            If subLists()\chars() = mapping
              AddElement(subLists()\chars()) : subLists()\chars() = code
              isFound = #True
              Break 2
            EndIf
          Next
        Next
        If isFound = #False
          AddElement(subLists())
          AddElement(subLists()\chars()) : subLists()\chars() = code
          AddElement(subLists()\chars()) : subLists()\chars() = mapping
        EndIf
      Else
        AddElement(subLists())
        AddElement(subLists()\chars()) : subLists()\chars() = code
        AddElement(subLists()\chars()) : subLists()\chars() = mapping
      EndIf
      
  EndSelect
Wend

CloseFile(file)

allDataLines$ = #CRLF$ +
                "; Version: 14.0.0" + #CRLF$ +
                "; Date: 2021-03-08, 19:35:41 GMT" + #CRLF$ +
                "; https://www.unicode.org/Public/UCD/latest/ucd/CaseFolding.txt" + #CRLF$ +
                #CRLF$ +
                "Structure CaseUnfoldStruc" + #CRLF$ +
                "  charsCount.a" + #CRLF$ +
                "  chars.u[0] ; Maximum array index is the value of `charsCount`" + #CRLF$ +
                "EndStructure" + #CRLF$ +
                #CRLF$ +
                "Global Dim *caseUnfold.CaseUnfoldStruc($FFFF)" + #CRLF$ +
                #CRLF$ +
                "; *caseUnfold((charCode) = ?caseUnfoldTable + offset" + #CRLF$ +
                #CRLF$

allDataSectionLines$ = "DataSection" + #CRLF$ +
                       "  caseUnfoldTable:" + #CRLF$

ForEach subLists()
  ForEach subLists()\chars()
    PushListPosition(subLists()\chars())
    currentChar = subLists()\chars()
    allDataLines$ + "*caseUnfold($" + RSet(Hex(currentChar), maxHexCodeLength, "0") + ") = ?caseUnfoldTable + $" +
                    RSet(Hex(offsetOfCountOfChars), maxHexCodeLength, "0") + #CRLF$
    offsetOfCountOfChars + SizeOf(Ascii)
    chars$ = ""
    countOfChars = -1
    ForEach subLists()\chars()
      If subLists()\chars() = currentChar
        Continue
      EndIf
      If chars$ <> ""
        chars$ + ","
      EndIf
      chars$ + "$" + RSet(Hex(subLists()\chars()), maxHexCodeLength, "0")
      countOfChars + 1
      offsetOfCountOfChars + SizeOf(Unicode)
    Next
    PopListPosition(subLists()\chars())
    allDataSectionLines$ + "  Data.a " + Str(countOfChars) + #CRLF$ +
                           "  Data.u " + chars$ + #CRLF$
  Next
Next

allDataSectionLines$ + "EndDataSection"

allDataLines$ + #CRLF$ + allDataSectionLines$ + #CRLF$

SetClipboardText(allDataLines$)
