;   Description: Converts clipboard text directly to a PB comment block
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2018 Sicro
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

; Tool Settings:
; - Event: Menu Or Shortcut
; For MacOS, the field "Commandline" must contain the full path to the executable
; file, e.g.: .../Program.app/Contents/MacOS/Program

Procedure$ DetermineNewLineFormat(ClipBoardText$)
  Protected i
  Protected Character$, Result$
  
  Repeat
    i + 1
    Character$ = Mid(ClipBoardText$, i, 1)
    
    Select Character$
        
      Case #CR$
        If Mid(ClipBoardText$, i + 1, 1) = #LF$
          Result$ = #CRLF$
        Else
          Result$ = #CR$
        EndIf
        Break
        
      Case #LF$
        Result$ = #LF$
        Break
        
    EndSelect
    
  Until Character$ = ""
  
  ProcedureReturn Result$
EndProcedure

Define ClipBoardText$ = GetClipboardText()
Define NewLineFormat$

If Left(ClipBoardText$, 1) = ";"
  ; The text in the clipboard has apparently already been converted
  End
EndIf

NewLineFormat$ = DetermineNewLineFormat(ClipBoardText$)

ClipBoardText$ = "; " + ReplaceString(ClipBoardText$, NewLineFormat$, NewLineFormat$ + "; ")

SetClipboardText(ClipBoardText$)
