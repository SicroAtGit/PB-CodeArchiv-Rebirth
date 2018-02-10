;   Description: Change mouse cursor
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=395725#p395725
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

EnableExplicit


Define CursorName.S
Define i.I
Define NewCursor.I
Define NumCursors.I

NewList CursorName.S()

OpenWindow(0, 200, 100, 300, 100, "Display all available system cursors")
CreateStatusBar(0, WindowID(0))
AddStatusBarField(#PB_Ignore)
ButtonGadget(0, WindowWidth(0) / 2 - 80, 30, 160, 25, "Change cursor")


; 4 Addition Cursor from OS10.0 to 10.8    
;     10.0-10.2:  2
;     10.3-10.4: 13
;     10.5     : 14
;     10.6     : 17
;     10.7-10.8: 18

If OSVersion() < #PB_OS_MacOSX_10_3
  NumCursors = 2
ElseIf OSVersion() < #PB_OS_MacOSX_10_5
  NumCursors = 13
ElseIf OSVersion() < #PB_OS_MacOSX_10_6
  NumCursors = 14
ElseIf OSVersion() < #PB_OS_MacOSX_10_7
  NumCursors = 17
Else
  NumCursors = 18
EndIf

For i = 1 To NumCursors
  AddElement(CursorName())
  Read.S CursorName()
Next i

FirstElement(CursorName())
StatusBarText(0, 0, "Current cursor: " + CursorName(), #PB_StatusBar_Center)

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      If EventGadget() = 0 And EventType() = #PB_EventType_LeftClick
        If NextElement(CursorName()) = 0
          FirstElement(CursorName())
        EndIf
        
        StatusBarText(0, 0, "Current cursor: " + CursorName())
        
        NewCursor = CocoaMessage(0, 0, "NSCursor " + CursorName())
        CocoaMessage(0, NewCursor, "set")
      EndIf
  EndSelect
ForEver

End

DataSection
  Data.S "arrowCursor"
  Data.S "IBeamCursor"
  Data.S "crosshairCursor"
  Data.S "closedHandCursor"
  Data.S "openHandCursor"
  Data.S "pointingHandCursor"
  Data.S "resizeLeftCursor"
  Data.S "resizeRightCursor"
  Data.S "resizeLeftRightCursor"
  Data.S "resizeUpCursor"
  Data.S "resizeDownCursor"
  Data.S "resizeUpDownCursor"
  Data.S "disappearingItemCursor"
  Data.S "operationNotAllowedCursor"
  Data.S "dragLinkCursor"
  Data.S "dragCopyCursor"
  Data.S "contextualMenuCursor"
  Data.S "IBeamCursorForVerticalLayout"
EndDataSection
