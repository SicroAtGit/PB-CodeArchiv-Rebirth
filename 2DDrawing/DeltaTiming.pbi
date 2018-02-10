;   Description: Helps that the program always runs at the same speed. Useful for games.
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29492
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 gekkonier
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

DeclareModule Delta

  EnableExplicit

  Declare New() ; use this in front of your mainloop
  Declare Measure() ; use this right at the end of your mainloop
  Declare.f Delta(value.f) ; multiplies your value for cpu independent transformation

EndDeclareModule

Module Delta

  Global oldtime.i
  Global newtime.i

  Procedure New()
    oldtime = ElapsedMilliseconds()
    newtime = ElapsedMilliseconds()
  EndProcedure

  Procedure Measure()
    oldtime = newtime
    newtime = ElapsedMilliseconds()
  EndProcedure

  Procedure.f Delta(value.f)
    ProcedureReturn value * (newtime - oldtime)
  EndProcedure

EndModule

Macro delta(value)
  Delta::Delta(value)
EndMacro

;-Example
CompilerIf #PB_Compiler_IsMainFile
  InitSprite()
  InitKeyboard()
  
  Global x.f = 1024/2
  Global y.f = 768/2
  
  OpenWindow(0, 0, 0, 1024, 768, "Hello Delta", #PB_Window_ScreenCentered)
  OpenWindowedScreen(WindowID(0), 0, 0, 1024, 768, #True, 0, 0)
  
  ; Change parameter to test it out
  ;SetFrameRate(10)
  
  Delta::New()
  
  Repeat
  
    ; flush all window events
    Repeat
      Define event.i = WindowEvent()
    Until event = 0
  
    ; handle input
  
    ExamineKeyboard()
  
    If KeyboardPushed(#PB_Key_Escape)
      End
    EndIf
  
    ; without macro
  
    If KeyboardPushed(#PB_Key_Left)
      x = x - Delta::Delta(0.1)
    EndIf
  
    If KeyboardPushed(#PB_Key_Right)
      x = x + Delta::Delta(0.1)
    EndIf
  
    ; with macro
  
    If KeyboardPushed(#PB_Key_Up)
      y = y - delta(0.1)
    EndIf
  
    If KeyboardPushed(#PB_Key_Down)
      y = y + delta(0.1)
    EndIf
  
    ; draw
  
    ClearScreen(RGB(0,0,0))
    StartDrawing(ScreenOutput())
    DrawText(x,y, "Use cursors to move me, press <esc> to quit.")
    StopDrawing()
    FlipBuffers()
  
    Delta::Measure()
  
  ForEver
CompilerEndIf
