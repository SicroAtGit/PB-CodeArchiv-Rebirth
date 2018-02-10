;   Description: Checks if the string contains a numeric value
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28676&start=10#p328016
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 NicTheQuick
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

Procedure.i isNumeric(value.s)
  CompilerIf #True 
    ;Method with pointers    
    Protected *c.Character = @value
    
    ;Skip whitespaces
    While *c\c = ' ' Or *c\c = 9
      *c + SizeOf(Character)
    Wend
    
    ;Skip Minus and Plus signs
    Protected i.i = 0
    While *c\c = '-' Or *c\c = '+'
      *c + SizeOf(Character)
      i + 1
    Wend
    If (i > 1) ; Error if more than one sign
      ProcedureReturn #False
    EndIf
    i = 0   
    
    Select *c\c
      Case '$'   ; Hex
        Repeat
          i + 1
          *c + SizeOf(Character)
        Until Not ((*c\c >= '0' And *c\c <= '9') Or (*c\c >= 'a' And *c\c <= 'f') Or (*c\c >= 'A' And *c\c <= 'F'))
        i - 1
        
      Case '%'   ; Binary
        Repeat
          i + 1
          *c + SizeOf(Character)
        Until *c\c <> '0' And *c\c <> '1'
        i - 1
        
      Case '0' To '9'   ; Decimal
        Protected j = 0
        Repeat
          i + 1
          If (*c\c = '.')
            If (j = 1)   ;Too many commas
              ProcedureReturn #False
            EndIf
            j + 1
          EndIf
          *c + SizeOf(Character)
        Until (*c\c < '0' Or *c\c > '9') And *c\c <> '.'
        
        If (i - j = 0) ; No digits
          ProcedureReturn #False
        EndIf
        
        If (*c\c = 'e' Or *c\c = 'E')   ;Exponent
          *c + SizeOf(Character)
          
          ;Skip Minus and Plus signs
          i = 0
          While *c\c = '-' Or *c\c = '+'
            *c + SizeOf(Character)
            i + 1
          Wend
          If (i > 1) ; Error if more than one sign
            ProcedureReturn #False
          EndIf
          
          While (*c\c >= '0' And *c\c <= '9')
            *c + SizeOf(Character)
            i + 1
          Wend
        EndIf
        
      Default
        ProcedureReturn #False
    EndSelect
    
    While *c\c = ' ' Or *c\c = 9
      *c + SizeOf(Character)
    Wend
    ProcedureReturn Bool(i And *c\c = 0)
  CompilerElse 
    ;Method with RegularExpression
    Static regex.i = 0
    If regex = 0
      ;regex = CreateRegularExpression(#PB_Any, "^\s*(\+|-)?(\$[0-9a-fA-F]+|%[01]+|([0-9]+|[0-9]*\.[0-9]+)([eE](\+|-)?[0-9]+)?)\s*$", #PB_RegularExpression_MultiLine)
      regex = CreateRegularExpression(#PB_Any, "^\s*(\+|-)?(\$[[:xdigit:]]+|%[01]+|(\d+|\d*\.\d+)([eE](\+|-)?\d+)?)\s*$", #PB_RegularExpression_MultiLine)
    EndIf
    ProcedureReturn MatchRegularExpression(regex, value)
  CompilerEndIf
EndProcedure



;-Example
CompilerIf #PB_Compiler_IsMainFile
  ; ===  Test  ===
  Debug "=== Numeric ==="
  Debug IsNumeric("123")
  Debug IsNumeric("1.23")
  Debug IsNumeric("-1.234567890123456")
  Debug IsNumeric("$FF")
  Debug IsNumeric("-%101  ")
  Debug IsNumeric("+1.7e-6")
  Debug IsNumeric("0")
  Debug IsNumeric("  -0.0")
  
  Debug "=== Not Numeric ==="
  Debug isNumeric("--12")
  Debug isNumeric("12.45.6")
  Debug isNumeric("%")
  Debug isNumeric("$g")
  Debug IsNumeric("12c")
  Debug IsNumeric("12c")
  Debug IsNumeric("abc")
  Debug IsNumeric("")
CompilerEndIf
