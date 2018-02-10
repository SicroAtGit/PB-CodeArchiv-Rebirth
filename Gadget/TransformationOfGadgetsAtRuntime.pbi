;   Description: Transformation of gadgets at runtime
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29423
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 STARGÅTE
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

DeclareModule GadgetTransformation

   EnumerationBinary 1
      #GadgetTransformation_Position
      #GadgetTransformation_Horizontally
      #GadgetTransformation_Vertically
   EndEnumeration

   #GadgetTransformation_Size = #GadgetTransformation_Horizontally|#GadgetTransformation_Vertically
   #GadgetTransformation_All  = #GadgetTransformation_Position|#GadgetTransformation_Horizontally|#GadgetTransformation_Vertically

   Declare DisableGadgetTransformation(Gadget.i)
   Declare EnableGadgetTransformation(Gadget.i, Flags.i=#GadgetTransformation_All, Grid.i=1)

EndDeclareModule

Module GadgetTransformation

   EnableExplicit

   #HandelSize = 5

   Structure GadgetTransformation
      Gadget.i
      Handle.i[10]
      Grid.i
   EndStructure

   Structure DataBuffer
      Handle.i[10]
   EndStructure

   Global NewList GadgetTransformation.GadgetTransformation()

   Procedure.i GridMatch(Value.i, Grid.i, Max.i=$7FFFFFFF)
      Value = Round(Value/Grid, #PB_Round_Nearest)*Grid
      If Value > Max
         ProcedureReturn Max
      Else
         ProcedureReturn Value
      EndIf
   EndProcedure

   Procedure GadgetTransformation_Callback()
      Static Selected.i, X.i, Y.i, OffsetX.i, OffsetY.i, GadgetX0.i, GadgetX1.i, GadgetY0.i, GadgetY1.i
      Protected *GadgetTransformation.GadgetTransformation = GetGadgetData(EventGadget())
      With *GadgetTransformation
         Select EventType()
            Case #PB_EventType_LeftButtonDown
               Selected = #True
               OffsetX = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX)
               OffsetY = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
               GadgetX0 = GadgetX(\Gadget)
               GadgetX1 = GadgetX0 + GadgetWidth(\Gadget)
               GadgetY0 = GadgetY(\Gadget)
               GadgetY1 = GadgetY0 + GadgetHeight(\Gadget)
            Case #PB_EventType_LeftButtonUp
               Selected = #False
            Case #PB_EventType_MouseMove
               If Selected
                  X = WindowMouseX(GetActiveWindow())-OffsetX
                  Y = WindowMouseY(GetActiveWindow())-OffsetY
                  Select EventGadget()
                     Case \Handle[1]
                        ResizeGadget(\Gadget, GridMatch(X+#HandelSize, \Grid, GadgetX1), #PB_Ignore, GadgetX1-GridMatch(X+#HandelSize, \Grid, GadgetX1), GridMatch(Y, \Grid)-GadgetY0)
                     Case \Handle[2]
                        ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(Y, \Grid)-GadgetY0)
                     Case \Handle[3]
                        ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(X, \Grid)-GadgetX0, GridMatch(Y, \Grid)-GadgetY0)
                     Case \Handle[4]
                        ResizeGadget(\Gadget, GridMatch(X+#HandelSize, \Grid, GadgetX1), #PB_Ignore, GadgetX1-GridMatch(X+#HandelSize, \Grid, GadgetX1), #PB_Ignore)
                     Case \Handle[5]
                        ResizeGadget(\Gadget, GridMatch(X-#HandelSize, \Grid), GridMatch(Y+#HandelSize, \Grid), #PB_Ignore, #PB_Ignore)
                     Case \Handle[6]
                        ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(X, \Grid)-GadgetX0, #PB_Ignore)
                     Case \Handle[7]
                        ResizeGadget(\Gadget, GridMatch(X+#HandelSize, \Grid, GadgetX1), GridMatch(Y+#HandelSize, \Grid, GadgetY1), GadgetX1-GridMatch(X+#HandelSize, \Grid, GadgetX1), GadgetY1-GridMatch(Y+#HandelSize, \Grid, GadgetY1))
                     Case \Handle[8]
                        ResizeGadget(\Gadget, #PB_Ignore, GridMatch(Y+#HandelSize, \Grid, GadgetY1), #PB_Ignore, GadgetY1-GridMatch(Y+#HandelSize, \Grid, GadgetY1))
                     Case \Handle[9]
                        ResizeGadget(\Gadget, #PB_Ignore, GridMatch(Y+#HandelSize, \Grid, GadgetY1), GridMatch(X, \Grid)-GadgetX0, GadgetY1-GridMatch(Y+#HandelSize, \Grid, GadgetY1))
                  EndSelect
                  If \Handle[1]
                     ResizeGadget(\Handle[1], GadgetX(\Gadget)-#HandelSize, GadgetY(\Gadget)+GadgetHeight(\Gadget), #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[2]
                     ResizeGadget(\Handle[2], GadgetX(\Gadget)+(GadgetWidth(\Gadget)-#HandelSize)/2, GadgetY(\Gadget)+GadgetHeight(\Gadget), #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[3]
                     ResizeGadget(\Handle[3], GadgetX(\Gadget)+GadgetWidth(\Gadget), GadgetY(\Gadget)+GadgetHeight(\Gadget), #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[4]
                     ResizeGadget(\Handle[4], GadgetX(\Gadget)-#HandelSize, GadgetY(\Gadget)+(GadgetHeight(\Gadget)-#HandelSize)/2, #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[5]
                     ResizeGadget(\Handle[5], GadgetX(\Gadget)+#HandelSize, GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[6]
                     ResizeGadget(\Handle[6], GadgetX(\Gadget)+GadgetWidth(\Gadget), GadgetY(\Gadget)+(GadgetHeight(\Gadget)-#HandelSize)/2, #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[7]
                     ResizeGadget(\Handle[7], GadgetX(\Gadget)-#HandelSize, GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[8]
                     ResizeGadget(\Handle[8], GadgetX(\Gadget)+(GadgetWidth(\Gadget)-#HandelSize)/2, GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                  EndIf
                  If \Handle[9]
                     ResizeGadget(\Handle[9], GadgetX(\Gadget)+GadgetWidth(\Gadget), GadgetY(\Gadget)-#HandelSize, #PB_Ignore, #PB_Ignore)
                  EndIf
               EndIf
         EndSelect
      EndWith
   EndProcedure

   Procedure DisableGadgetTransformation(Gadget.i)
      Protected I.i, *GadgetTransformation.GadgetTransformation
      ForEach GadgetTransformation()
         If GadgetTransformation()\Gadget = Gadget
            For I = 1 To 9
               If GadgetTransformation()\Handle[I]
                  FreeGadget(GadgetTransformation()\Handle[I])
               EndIf
            Next
            DeleteElement(GadgetTransformation())
         EndIf
      Next
   EndProcedure

   Procedure EnableGadgetTransformation(Gadget.i, Flags.i=#GadgetTransformation_All, Grid.i=1)
      Protected Handle.i, I.i
      Protected *GadgetTransformation.GadgetTransformation
      Protected *Cursors.DataBuffer = ?Cursors
      Protected *Flags.DataBuffer = ?Flags
      ForEach GadgetTransformation()
         If GadgetTransformation()\Gadget = Gadget
            For I = 1 To 9
               If GadgetTransformation()\Handle[I]
                  FreeGadget(GadgetTransformation()\Handle[I])
               EndIf
            Next
            DeleteElement(GadgetTransformation())
         EndIf
      Next
      *GadgetTransformation = AddElement(GadgetTransformation())
      *GadgetTransformation\Gadget = Gadget
      *GadgetTransformation\Grid = Grid
      For I = 1 To 9
         If Flags & *Flags\Handle[I] = *Flags\Handle[I]
            Select I
               Case 1
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)-#HandelSize, GadgetY(Gadget)+GadgetHeight(Gadget), #HandelSize, #HandelSize)
               Case 2
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+(GadgetWidth(Gadget)-#HandelSize)/2, GadgetY(Gadget)+GadgetHeight(Gadget), #HandelSize, #HandelSize)
               Case 3
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+GadgetWidth(Gadget), GadgetY(Gadget)+GadgetHeight(Gadget), #HandelSize, #HandelSize)
               Case 4
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)-#HandelSize, GadgetY(Gadget)+(GadgetHeight(Gadget)-#HandelSize)/2, #HandelSize, #HandelSize)
               Case 5
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+#HandelSize, GadgetY(Gadget)-#HandelSize, 2*#HandelSize, #HandelSize)
               Case 6
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+GadgetWidth(Gadget), GadgetY(Gadget)+(GadgetHeight(Gadget)-#HandelSize)/2, #HandelSize, #HandelSize)
               Case 7
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)-#HandelSize, GadgetY(Gadget)-#HandelSize, #HandelSize, #HandelSize)
               Case 8
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+(GadgetWidth(Gadget)-#HandelSize)/2, GadgetY(Gadget)-#HandelSize, #HandelSize, #HandelSize)
               Case 9
                  Handle = CanvasGadget(#PB_Any, GadgetX(Gadget)+GadgetWidth(Gadget), GadgetY(Gadget)-#HandelSize, #HandelSize, #HandelSize)
            EndSelect
            *GadgetTransformation\Handle[I] = Handle
            SetGadgetData(Handle, *GadgetTransformation)
            SetGadgetAttribute(Handle, #PB_Canvas_Cursor, *Cursors\Handle[I])
            If StartDrawing(CanvasOutput(Handle))
               Box(0, 0, OutputWidth(), OutputHeight(), $000000)
               Box(1, 1, OutputWidth()-2, OutputHeight()-2, $FFFFFF)
               StopDrawing()
            EndIf
            BindGadgetEvent(Handle, @GadgetTransformation_Callback())
         EndIf
      Next
      DataSection
         Cursors:
         Data.i 0, #PB_Cursor_LeftDownRightUp, #PB_Cursor_UpDown, #PB_Cursor_LeftUpRightDown, #PB_Cursor_LeftRight
         Data.i #PB_Cursor_Arrows, #PB_Cursor_LeftRight, #PB_Cursor_LeftUpRightDown, #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp
         Flags:
         Data.i 0, #GadgetTransformation_Size, #GadgetTransformation_Vertically, #GadgetTransformation_Size, #GadgetTransformation_Horizontally
         Data.i #GadgetTransformation_Position, #GadgetTransformation_Horizontally, #GadgetTransformation_Size, #GadgetTransformation_Vertically, #GadgetTransformation_Size
      EndDataSection
   EndProcedure

EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  UseModule GadgetTransformation
  
  Enumeration
     #Window
     #GadgetTransformation
     #EditorGadget
     #ButtonGadget
     #TrackBarGadget
     #SpinGadget
  EndEnumeration
  
  OpenWindow(#Window, 0, 0, 600, 400, "WindowTitle", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
  EditorGadget(#EditorGadget, 50, 100, 200, 50, #PB_Editor_WordWrap) : SetGadgetText(#EditorGadget, "Grumpy wizards make toxic brew for the evil Queen and Jack.")
  ButtonGadget(#ButtonGadget, 50, 250, 200, 25, "Hallo Welt!", #PB_Button_MultiLine)
  TrackBarGadget(#TrackBarGadget, 350, 100, 200, 25, 0, 100) : SetGadgetState(#TrackBarGadget, 70)
  SpinGadget(#SpinGadget, 350, 250, 200, 25, 0, 100, #PB_Spin_Numeric) : SetGadgetState(#SpinGadget, 70)
  
  ButtonGadget(#GadgetTransformation, 20, 20, 150, 25, "Enable Transformation", #PB_Button_Toggle)
  
  Repeat
  
     Select WaitWindowEvent()
  
        Case #PB_Event_CloseWindow
           End
  
        Case #PB_Event_Gadget
           Select EventGadget()
              Case #GadgetTransformation
                 Select GetGadgetState(#GadgetTransformation)
                    Case #False
                       SetGadgetText(#GadgetTransformation, "Enable Transformation")
                       DisableGadgetTransformation(#EditorGadget)
                       DisableGadgetTransformation(#ButtonGadget)
                       DisableGadgetTransformation(#TrackBarGadget)
                       DisableGadgetTransformation(#SpinGadget)
                    Case #True
                       SetGadgetText(#GadgetTransformation, "Disable Transformation")
                       EnableGadgetTransformation(#EditorGadget, #GadgetTransformation_All, 10)
                       EnableGadgetTransformation(#ButtonGadget, #GadgetTransformation_All)
                       EnableGadgetTransformation(#TrackBarGadget, #GadgetTransformation_Position|#GadgetTransformation_Horizontally)
                       EnableGadgetTransformation(#SpinGadget, #GadgetTransformation_Position)
                 EndSelect
           EndSelect
  
  
     EndSelect
  
  ForEver
CompilerEndIf
