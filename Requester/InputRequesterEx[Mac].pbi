;   Description: InputRequester with cancel button and ability to set default text
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=465129#p465129
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 wilbert
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

CompilerIf #PB_Compiler_OS<>#PB_OS_MacOS
  CompilerError "MacOs only!"
CompilerEndIf

Procedure.s InputRequesterEx(Title.s, Info.s, DefaultInput.s = "")
  Protected.i Alert, InputField, Frame.NSRect
  Frame\size\width = 300
  Frame\size\height = 24
  InputField = CocoaMessage(0, CocoaMessage(0, CocoaMessage(0, 0, "NSTextField alloc"), "initWithFrame:@", Frame), "autorelease")
  CocoaMessage(0, InputField, "setStringValue:$", @DefaultInput)
  Alert = CocoaMessage(0, CocoaMessage(0, 0, "NSAlert new"), "autorelease")
  CocoaMessage(0, Alert, "setMessageText:$", @Title)
  CocoaMessage(0, Alert, "setInformativeText:$", @Info)
  CocoaMessage(0, Alert, "addButtonWithTitle:$", @"OK")   
  CocoaMessage(0, Alert, "addButtonWithTitle:$", @"Cancel")
  CocoaMessage(0, Alert, "setAccessoryView:", InputField)
  If CocoaMessage(0, Alert, "runModal") = 1000
    ProcedureReturn PeekS(CocoaMessage(0, CocoaMessage(0, InputField, "stringValue"), "UTF8String"), -1, #PB_UTF8)
  Else
    ProcedureReturn ""
  EndIf
EndProcedure



;-Example
CompilerIf #PB_Compiler_IsMainFile
  Debug InputRequesterEx("Title", "Informative text", "Default input")
CompilerEndIf
