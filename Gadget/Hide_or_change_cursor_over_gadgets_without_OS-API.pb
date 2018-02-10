;   Description: Hide/Change Cursor over Gadgets without OS-API
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=68169
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 ChrisR
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

Enumeration FormGadget
  #WinMain
  #CanvaButton
  #Button
  #CanvaCheckBox
  #CheckBox
EndEnumeration

OpenWindow(#WinMain, 0, 0, 220, 130, "Change Cursor over Gadgets", #PB_Window_SystemMenu)
CanvasGadget(#CanvaButton, 30, 30, 160, 25, #PB_Canvas_Container)
SetGadgetAttribute(#CanvaButton, #PB_Canvas_Cursor, #PB_Cursor_Hand)
ButtonGadget(#Button, 0, 0, 160, 25, "ClickMe for Busy Cursor")
CloseGadgetList()
CanvasGadget(#CanvaCheckBox, 20, 80, 180, 25, #PB_Canvas_Container)
If StartDrawing(CanvasOutput(#CanvaCheckBox))   ;Opaque background on: CheckBoxGadget, FrameGadget, HyperlinkGadget, OptionGadget, TextGadget, And TrackBarGadget
  Box(0, 0, OutputWidth(), OutputHeight(), $F0F0F0)   ;#PB_OS_MacOS: $C0C0C0
  StopDrawing()
EndIf
SetGadgetAttribute(#CanvaCheckBox, #PB_Canvas_Cursor, #PB_Cursor_Hand)
CheckBoxGadget(#CheckBox, 0, 0, 180, 25, "To show Cursor on other Gadgets", #PB_CheckBox_ThreeState)
CloseGadgetList()

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      End

    Case #PB_Event_Gadget
      Select EventGadget()
        Case #Button
          Select GetGadgetAttribute(#CanvaButton, #PB_Canvas_Cursor)
            Case #PB_Cursor_Hand
              SetGadgetText(#Button, "ClickMe for Invisible Cursor")
              SetGadgetAttribute(#CanvaButton, #PB_Canvas_Cursor, #PB_Cursor_Busy)
              SetGadgetState(#CheckBox, #PB_Checkbox_Checked)
              SetGadgetAttribute(#CanvaCheckBox, #PB_Canvas_Cursor, #PB_Cursor_Busy)
            Case #PB_Cursor_Busy
              SetGadgetText(#Button, "ClickMe for Hand Cursor")
              SetGadgetAttribute(#CanvaButton, #PB_Canvas_Cursor, #PB_Cursor_Invisible)
              SetGadgetState(#CheckBox, #PB_Checkbox_Inbetween)
              SetGadgetAttribute(#CanvaCheckBox, #PB_Canvas_Cursor, #PB_Cursor_Invisible)
            Case #PB_Cursor_Invisible
              SetGadgetText(#Button, "ClickMe for Busy Cursor")
              SetGadgetAttribute(#CanvaButton, #PB_Canvas_Cursor, #PB_Cursor_Hand)
              SetGadgetState(#CheckBox, #PB_Checkbox_Unchecked)
              SetGadgetAttribute(#CanvaCheckBox, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          EndSelect
      EndSelect
  EndSelect
ForEver
