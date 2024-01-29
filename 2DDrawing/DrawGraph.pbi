;   Description: Draws a graph
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=67464
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 Lunasole
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

;{ Simple Graph }

; Yet another stuff for simple 'visuals'
;   2017         (c) Luna Sole
;    v1.0.0.4       (+ mouse interaction)         


; Draws graph with 2 lines on given image using PB vector library
; hImgOut            PB image to draw on it, can be any size [except maybe "extremely low" resolutions ^^]
; GraphData()         array with items to visualise, should have at least 1 item [starting from 0]
; OutGeoData()         map to receive data required to handle mouse interaction. map key = X coordinate on graph image, value = related index of GraphData()
; Average            how many items use to calculate averaged value for current item? 2 is minimum, if less it will be disabled
; GridStepX            X grid resolution [vertical lines], measured in GraphData() count. use 0 to disable
; GridStepY            Y grid resolution [horizontal lines], measured in GraphData() values. 0 to disable
; FontSize            font size of text labels. use 0 to disable labels
; ColorN            colors for graph elements (RGB)
; RETURN:            none, image modified on success
Procedure DrawSimpleGraph (hImgOut, Array GraphData(1), Map OutGeoData(), Average, GridStepX = 10, GridStepY = 10, FontSize = 9, Color1 = $00DDDD, Color2 = $DDDD00)
  ClearMap(OutGeoData())                  ; reset mouse data
  
  Protected maxItems = ArraySize(GraphData())   ; count of items  (X)
  Protected maxValues                           ; count of values (Y)
  Protected highValue, lowValue                 ; highest and lowest GraphData values
  Protected t                                   ; generic temp variable
  If maxItems < 0 : ProcedureReturn :   EndIf   ; quit if GraphData array is invalid
  
  ; detect higher/lower values
  Protected Dim TData(0)
  CopyArray(GraphData(), TData())
  SortArray(TData(), #PB_Sort_Ascending)
  lowValue = TData(0)
  highValue = TData(maxItems)
  FreeArray(TData())
  
  ; do some stuff to better fit background grid
  If GridStepY > 0
    If highValue >= 0
      highValue + GridStepY - highValue % GridStepY
    ElseIf highValue
      highValue - highValue % GridStepY
    EndIf
    If lowValue > 0
      lowValue  - lowValue  % GridStepY
    ElseIf lowValue < 0
      lowValue  - (GridStepY + lowValue  % GridStepY)
    EndIf
  EndIf
  maxValues = highValue - lowValue
  If maxValues <= 0
    maxValues = 1
  EndIf
  ; load font for text labels
  Protected Font
  If FontSize > 0
    Font = LoadFont(#PB_Any, "arial", FontSize)
    If Not IsFont(Font) ; and so on
      Font = LoadFont(#PB_Any, "tahoma", FontSize)
      If Not IsFont(Font) ; and so on.. :)
        Font = LoadFont(#PB_Any, "consolas", FontSize)
      EndIf
    EndIf
  EndIf
  
  ; draw data to image
  If StartVectorDrawing(ImageVectorOutput(hImgOut, #PB_Unit_Pixel))
    ; [n] - define graph offsets / text labels sizes / etc
    Protected.d oX = 1.0, oY = oX
    Protected.d mtW = 1.0, mtH = mtW
    If IsFont(Font)
      VectorFont(FontID(Font), FontSize)
      If VectorTextWidth(Str(highValue)) > VectorTextWidth(Str(lowValue))
        oX = VectorTextWidth(Str(highValue)) + 2.0
      Else
        oX = VectorTextWidth(Str(lowValue)) + 2.0
      EndIf
      oY = VectorTextHeight("0A") + 2.0
      If oX > oY
        oY = oX
      Else
        oX = oY
      EndIf
      mtW = VectorTextWidth(Str(maxItems)) * 1.2
      mtH = VectorTextHeight(Str(highValue)) * 0.8
    EndIf
    ;    line width (pixels)
    Protected.d LineWidth = 1.0
    ;    multipliers to scale graph coordinates
    Protected.d mX = (VectorOutputWidth() - oX * 2.0) / (maxItems + Bool(maxItems = 0))   
    Protected.d mY = (VectorOutputHeight() - oY * 2.0) / maxValues
    ;   tmp variables used in drawing
    Protected.d cX, cY
    
    ; [0] - draw text labels and grid lines
    VectorSourceColor($77FFFFFF)
    Protected.d tLast
    ;   horizontal lines/labels
    tLast = oY + maxValues * mY + 5.0
    If GridStepY > 0
      For t = maxValues To 0 Step -1
        If t % GridStepY = 0 Or t = maxValues
          cY = oY + t * mY
          ; draw text label
          If IsFont(Font) And cY < tLast
            MovePathCursor(oX - (2.0 + VectorTextWidth(Str(highValue - t))), cY - VectorTextHeight(Str(highValue - t)) * 0.5)
            DrawVectorText(Str(highValue - t))
            tLast = cY - mtH
          EndIf
          ; draw grid line
          MovePathCursor(oX, oY + mY * t)            
          AddPathLine(oX + maxItems * mX, oY + mY * t)
        EndIf
      Next t
    EndIf
    ;   vertical lines/labels
    tLast = 0.0
    If GridStepX > 0   
      ;GridStepX + 1
      For t = 0 To maxItems
        If t % GridStepX = 0 Or t = maxItems
          cX = oX + t * mX
          cY = oY + maxValues * mY
          ; draw text label
          If IsFont(Font) And cX > tLast
            MovePathCursor(cX - VectorTextWidth(Str(t)) * 0.5, cY + 2.0)
            DrawVectorText(Str(t))
            tLast = cX + mtW
          EndIf
          ; draw grid line
          MovePathCursor(cX, oY)
          AddPathLine(cX, cY)
        EndIf
      Next t
    EndIf
    ;   fin
    If GridStepX > 0 Or GridStepY > 0
      DashPath(1.0, 3.0)
    EndIf
    
    
    ; [1] - draw main line/items and form "geodata"
    Protected.d gX = oX
    Protected.d gX2
    VectorSourceColor(Color1 | $FF000000)
    MovePathCursor(oX, oY + mY * (highValue - GraphData(0)))
    For t = 0 To maxItems
      cX = oX + mX * t
      cY = oY + mY * (highValue - GraphData(t))
      AddPathLine(cX, cY)         ; add line
      AddPathCircle(cX, cY, 2.0)  ; add spot at the edge
      MovePathCursor(cX, cY)      ; restore cursor pos
      
      ; build that "geodata" used to handle mouse
      gX2 = gX + (cX - gX) * 0.5
      While gX < gX2
        OutGeoData(Str(Int(gX))) = t - 1
        gX + 1.0
      Wend
      While gX < cX
        OutGeoData(Str(Int(gX))) = t
        gX + 1.0
      Wend
      gX = cX
    Next t
    StrokePath(LineWidth)
    
    
    ; [2] - draw "trend"/averaged line
    Protected NewList Avg() ; stack to store recent values
    Protected.d Avg         ; to calculate current result
    If Average > maxItems + 1
      Average = maxItems + 1
    EndIf
    If Average > 1            ; it makes sense to draw only if it is greater than 1
      While ListSize(Avg()) < Average
        AddElement(Avg())   ; 'extrapolate' using first item data, without that it looks worst as for me :3
        Avg() = GraphData(0)
      Wend
      MovePathCursor(oX, oY + (highValue - GraphData(0)) * mY)
      For t = 0 To maxItems
        FirstElement(Avg())      ; this all works like a stack structure, with max deepth = Average
        DeleteElement(Avg())   
        LastElement(Avg())      
        AddElement(Avg())
        Avg() = GraphData(t)   ; push new element
        Avg = 0.0              ; calculate averaged value from recent elements
        ForEach Avg()
          Avg + Avg()
        Next
        cX = oX + mX * t
        cY = oY + (highValue - Avg / Average) * mY
        AddPathLine(cX, cY)
        AddPathCircle(cX, cY, 1.0)   ; add spot at the edge
        MovePathCursor(cX, cY)       ; restore cursor pos
      Next t
      VectorSourceColor(Color2 | $FF000000)
      StrokePath(LineWidth)
    EndIf
    
    ; cls
    FreeList(Avg())
    StopVectorDrawing()
  EndIf
  
  ; cls
  If IsFont(Font)
    FreeFont(Font)
  EndIf
EndProcedure

;}

;-Example
CompilerIf #PB_Compiler_IsMainFile
  ; used to handle graph mouse clicks
  ; mapkey is X coordinate of graph image, value is corresponding index in GraphData() array
  Global NewMap GraphGeodata()
  
  ; Graph dimensions
  Global W = 800, H = 600
  ; Image to draw graph
  Global tImg
  ; Window and canvas to display graph
  Global tWindow, tCanvas
  
  
  ; This procedure handles mouse events of graph canvas
  Procedure GraphCB()
    Protected cX = GetGadgetAttribute(tCanvas, #PB_Canvas_MouseX)
    Select EventType()
      Case #PB_EventType_LeftButtonDown:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "LMB down on item " + GraphGeodata()
        EndIf
      Case #PB_EventType_LeftButtonUp:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "LMB up on item " + GraphGeodata()
        EndIf
      Case #PB_EventType_LeftClick:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "LMB click on item " + GraphGeodata()
        EndIf
        
      Case #PB_EventType_RightButtonDown:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "RMB down on item " + GraphGeodata()
        EndIf
      Case #PB_EventType_RightButtonUp:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "RMB up on item " + GraphGeodata()
        EndIf
      Case #PB_EventType_RightClick:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "RMB click on item " + GraphGeodata()
        EndIf
        
      Case #PB_EventType_MouseMove:
        If FindMapElement(GraphGeodata(), Str(cX))
          Debug "Mouse hover on item " + GraphGeodata()
        EndIf
    EndSelect
  EndProcedure
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; generate some graph data
  Dim GraphValues (127)
  Define t
  RandomSeed(4980819)
  For t = 0 To ArraySize(GraphValues())
    GraphValues(t) = Random(127, 0)
    If Random(1, 0)
      GraphValues(t) = -GraphValues(t)
    EndIf
  Next t
  
  ; create image to receive output
  tImg = CreateImage(#PB_Any, W, H, 32, $405050)
  ; draw graph to created image
  DrawSimpleGraph(tImg, GraphValues(), GraphGeodata(), 16, 10, 10, 11)
  
  ; show
  tWindow = OpenWindow(#PB_Any, 0, 0, W, H, "SomeGraphWindow", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  tCanvas = CanvasGadget(#PB_Any, 0, 0, W, H)
  SetGadgetAttribute(tCanvas, #PB_Canvas_Image, ImageID(tImg))
  ; bind events required for mouse interaction
  BindEvent(#PB_Event_Gadget, @GraphCB(), tWindow, tCanvas, #PB_All)
  
  ; release img
  FreeImage(tImg)
  
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
CompilerEndIf
