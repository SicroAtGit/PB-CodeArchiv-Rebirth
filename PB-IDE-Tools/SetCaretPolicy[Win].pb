;   Description: Enable scrolling before the cursor reach the border
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29179
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 GPI
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

;Select as "Event to trigger the tool": "Sourcecode loaded" and "New Sourcecode created"

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf

;MessageRequester("test",GetEnvironmentVariable("PB_TOOL_Scintilla" ))
handle=Val(GetEnvironmentVariable("PB_TOOL_Scintilla" ))
If handle
  SendMessage_(handle,#SCI_SETXCARETPOLICY,#CARET_SLOP|#CARET_EVEN|#CARET_STRICT    ,100);100 Pixel in x-Richtung
  SendMessage_(handle,#SCI_SETYCARETPOLICY,#CARET_SLOP|#CARET_EVEN|#CARET_STRICT    ,3)  ;3 Zeilen
EndIf
