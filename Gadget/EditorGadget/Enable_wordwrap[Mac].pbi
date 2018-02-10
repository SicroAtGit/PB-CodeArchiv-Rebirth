;   Description: Enables wordwrap in EditorGadget
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=393497#p393497
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 Shardik
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

Procedure EditorGadget_SetWordWrap(EditorGadgetID, wrap)
  Protected Size.NSSize
  Protected Container.i = CocoaMessage(0, EditorGadgetID, "textContainer")
  CocoaMessage(@Size, Container, "containerSize")
  If wrap
    Size\width = GadgetWidth(0) - 2
  Else
    Size\width = $FFFF
  EndIf
  CocoaMessage(0, Container, "setContainerSize:@", @Size)
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  OpenWindow(0, 270, 100, 250, 110, "Word Wrap Test", #PB_Window_SystemMenu)
  EditorGadget(0, 10, 10, 230, 60)
  ButtonGadget(1, 60, 80, 140, 25, "Toggle Word Wrap")
  
  For i = 1 To 5
    Text$ = Text$ + "This is a word wrap test - "
  Next i
  
  SetGadgetText(0, Text$)
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_Gadget
        If EventGadget() = 1
          WordWrap ! 1
          EditorGadget_SetWordWrap(GadgetID(0), WordWrap)
        EndIf
    EndSelect
  ForEver
CompilerEndIf
