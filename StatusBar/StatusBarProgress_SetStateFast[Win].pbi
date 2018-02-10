;   Description: Sets the state of a StatusBarProgress fast without animation
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=295657#p295657
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

Procedure SetStatusBarProgressStateFast(StatusBar, Field, State, Style = 0, MinState = 0, MaxState = 100)
  
  If State < MaxState
    StatusBarProgress(StatusBar, Field, State + 1, Style, MinState, MaxState)
    StatusBarProgress(StatusBar, Field, State,     Style, MinState, MaxState)
  Else
    StatusBarProgress(StatusBar, Field, MaxState + 1, Style, MinState, MaxState + 1)
    StatusBarProgress(StatusBar, Field, MaxState,     Style, MinState, MaxState)
  EndIf
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  ;#StatusBarProgressState = 100
  #StatusBarProgressState = 50
  
  If OpenWindow(0, 0, 0, 340, 50, "StatusBarProgress", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    If Not CreateStatusBar(0, WindowID(0)): End: EndIf
    AddStatusBarField(340)
    StatusBarProgress(0, 0, 0, 0, 0, 100)
  
    AddWindowTimer(0,1,2000)
  
    Repeat
      Event = WaitWindowEvent()
  
      If Event = #PB_Event_Timer
        SetStatusBarProgressStateFast(0, 0, #StatusBarProgressState, 0, #PB_Ignore, 100)
      EndIf
    Until Event = #PB_Event_CloseWindow
  EndIf
  
CompilerEndIf
