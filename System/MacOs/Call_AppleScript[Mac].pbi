;   Description: Call Apple Script
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=393553#p393553
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 wilbert
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

Procedure.s AppleScript(Script.s)
  Protected retVal.s, strVal, numItems, i
  Protected aScript = CocoaMessage(0, CocoaMessage(0, CocoaMessage(0, 0, "NSAppleScript alloc"), "initWithSource:$", @Script), "autorelease")
  Protected eventDesc = CocoaMessage(0, aScript, "executeAndReturnError:", #nil)
  If eventDesc
    numItems = CocoaMessage(0, eventDesc, "numberOfItems")
    If numItems
      For i = 1 To numItems
        strVal = CocoaMessage(0, CocoaMessage(0, eventDesc, "descriptorAtIndex:", i), "stringValue")
        If strVal
          retVal + PeekS(CocoaMessage(0, strVal, "UTF8String"), -1, #PB_UTF8)
          If i <> numItems : retVal + #LF$ : EndIf
        EndIf
      Next
    Else
      strVal = CocoaMessage(0, eventDesc, "stringValue")
      If strVal : retVal = PeekS(CocoaMessage(0, strVal, "UTF8String"), -1, #PB_UTF8) : EndIf
    EndIf
  EndIf
  ProcedureReturn retVal
EndProcedure


;-Example
CompilerIf #PB_Compiler_IsMainFile
  MessageRequester("", AppleScript("tell application " + Chr(34) + "Finder" + Chr(34) + " To get the name of every item in the desktop"))
CompilerEndIf
