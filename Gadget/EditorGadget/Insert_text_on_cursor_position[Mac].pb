;   Description: Insert text at the cursor position
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=409531#p409531
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 J. Baker
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

If OpenWindow(0, 0, 0, 322, 180, "EditorGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  EditorGadget(0, 8, 8, 306, 133)
  For a = 0 To 5
    AddGadgetItem(0, a, "Line "+Str(a))
  Next
  
  SetActiveGadget(0)
  
  ButtonGadget(1, 115, 150, 100, 25, "Insert Text")
  
  Repeat
    
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Gadget
      
      Select EventGadget()
          
        Case 1
          CocoaMessage(0, GadgetID(0), "insertText:$", @" My inserted test!")
          
      EndSelect
      
    EndIf
    
  Until Event = #PB_Event_CloseWindow
  
EndIf
