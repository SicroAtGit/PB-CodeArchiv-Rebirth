;   Description: Show alert with suppression check box
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=393221#p393221
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

Procedure AlertWithSuppression(Title.s, Text.s, SuppressionText.s)
  Protected Alert = CocoaMessage(0, CocoaMessage(0, 0, "NSAlert new"), "autorelease")
  CocoaMessage(0, Alert, "setMessageText:$", @Title)
  CocoaMessage(0, Alert, "setInformativeText:$", @Text)
  CocoaMessage(0, Alert, "setShowsSuppressionButton:", #YES)
  Protected SuppressionButton = CocoaMessage(0, Alert, "suppressionButton")
  CocoaMessage(0, SuppressionButton, "setTitle:$", @SuppressionText)
  CocoaMessage(0, Alert, "runModal")
  ProcedureReturn CocoaMessage(0, SuppressionButton, "state")
EndProcedure

CompilerIf #PB_Compiler_IsMainFile
  Suppress = #NO
  
  OpenWindow(0, 0, 0, 200, 100, "Alert with suppression", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  ButtonGadget(0, 10, 10, 180, 30, "Button")
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_Gadget
        If Suppress = #NO
          Suppress = AlertWithSuppression("Message", "You pressed the button", "Do not show this message again please")       
        EndIf
    EndSelect
  ForEver
CompilerEndIf
