;   Description: Gets the current desktop (the mouse cursor is on it)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 Sicro
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

Procedure.i GetCurrentDesktop()
  
  Protected i, Desktops, CurrentDesktop
  Protected DesktopX, DesktopY
  Protected DesktopMouseX, DesktopMouseY
  
  Desktops = ExamineDesktops()
  If Desktops = 0
    ProcedureReturn -1
  EndIf
  
  For i = Desktops - 1 To 0 Step -1
    DesktopX      = DesktopX(i)
    DesktopY      = DesktopY(i)
    DesktopMouseX = DesktopMouseX()
    DesktopMouseY = DesktopMouseY()
    
    If DesktopMouseX >= DesktopX And DesktopMouseX <= (DesktopX + DesktopWidth(i))
      If DesktopMouseY >= DesktopY And DesktopMouseY <= (DesktopY + DesktopHeight(i))
        CurrentDesktop = i
        Break
      EndIf
    EndIf
  Next
  
  ProcedureReturn CurrentDesktop
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile

  Debug "Current desktop: " + GetCurrentDesktop()

CompilerEndIf
