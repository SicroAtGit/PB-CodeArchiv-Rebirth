
; Creates the PureBasic datasection `Data.u ...` code lines for the predefined
; character classes.
; 
; Copy the first output of the Unicode Utilities: UnicodeSet
; (https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp)
; to the clipboard and run this code.
;
; The URLs used can be found in the
; `Source/UnicodeTables/PredefinedCharacterClasses.pbi` file.
;
; NOTE: The output that this code generates still requires some rework.

EnableExplicit

Structure RangeStruc
  startValue.i
  endValue.i
EndStructure

Define text$ = GetClipboardText()
Define num1$, num2$
Define.RangeStruc NewList ranges()
Define lastEndValue

If Not CreateRegularExpression(0, "(?<num1>(\\[^\-\\\[\]]+)|\w)(\-(?<num2>(\\[^\-\\\[\]]+)|\w))?")
  Debug "CreateRegularExpression(): " + RegularExpressionError()
  End
EndIf

If Not ExamineRegularExpression(0, text$)
  Debug "Error: ExamineRegularExpression()"
  End
EndIf

While NextRegularExpressionMatch(0)
  num1$ = RegularExpressionNamedGroup(0, "num1")
  num2$ = RegularExpressionNamedGroup(0, "num2")
  
  If LCase(Left(num1$, 2)) = "\u"
    num1$ = Str(Val("$" + Mid(num1$, 3)))
  ElseIf Left(num1$, 1) = "\"
    num1$ = Str(Asc(Mid(num1$, 2)))
  ElseIf num1$ <> ""
    num1$ = Str(Asc(num1$))
  EndIf
  
  If LCase(Left(num2$, 2)) = "\u"
    num2$ = Str(Val("$" + Mid(num2$, 3)))
  ElseIf Left(num2$, 1) = "\"
    num2$ = Str(Asc(Mid(num2$, 2)))
  ElseIf num2$ <> ""
    num2$ = Str(Asc(num2$))
  EndIf
  
  If num2$ = ""
    Debug "Data.u " + num1$ + ", " + num1$
    If Not AddElement(ranges())
      Debug "Error: AddElement()"
      End
    EndIf
    ranges()\startValue = Val(num1$)
    ranges()\endValue = Val(num1$)
  Else
    Debug "Data.u " + num1$ + ", " + num2$
    If Not AddElement(ranges())
      Debug "Error: AddElement()"
      End
    EndIf
    ranges()\startValue = Val(num1$)
    ranges()\endValue = Val(num2$)
  EndIf
Wend
FreeRegularExpression(0)

Debug "------------- Negated ranges ----------------------"

If Not FirstElement(ranges())
  Debug "Error: FirstElement()"
  End
EndIf

If ranges()\startValue > 1
  Debug "Data.u 1, " + Str(ranges()\startValue - 1)
  lastEndValue = ranges()\endValue
EndIf

While NextElement(ranges())
  If lastEndValue + 1 <> ranges()\startValue
    Debug "Data.u " + Str(lastEndValue + 1) + ", " + Str(ranges()\startValue - 1)
  EndIf
  lastEndValue = ranges()\endValue
Wend
