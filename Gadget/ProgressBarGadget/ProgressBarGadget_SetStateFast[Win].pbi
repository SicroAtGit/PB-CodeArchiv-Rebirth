;   Description: Sets the state of a ProgressBarGadget fast without animation
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=295616#p295616
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2011 Sicro
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

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "Supported OS are only: Windows"
CompilerEndIf

Procedure SetProgressBarStateFast(Gadget, State)
  
  MaxState = GetGadgetAttribute(Gadget, #PB_ProgressBar_Maximum)
  
  If State < MaxState
    SetGadgetState(Gadget, State + 1)
    SetGadgetState(Gadget, State)
  Else
    SetGadgetAttribute(Gadget, #PB_ProgressBar_Maximum, MaxState + 1)
    SetGadgetState(Gadget, MaxState + 1)
    SetGadgetAttribute(Gadget, #PB_ProgressBar_Maximum, MaxState)
  EndIf
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  ;#ProgressBarState = 100
  #ProgressBarState = 50
  
  If OpenWindow(0, 0, 0, 570, 100, "ProgressBarGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ProgressBarGadget(0,  35, 35, 500,  30, 0, 100)
    
    AddWindowTimer(0, 1, 2000)
    
    Repeat
      Event = WaitWindowEvent()
      
      If Event = #PB_Event_Timer
        SetProgressBarStateFast(0, #ProgressBarState)
        RemoveWindowTimer(0, 1)
      EndIf
    Until Event = #PB_Event_CloseWindow
  EndIf
  
CompilerEndIf
