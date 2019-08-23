;   Description: Simplified use of VectorDrawing
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=73051
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31538
; -----------------------------------------------------------------------------

;/ ===================================
;/ =    DrawVectorEx - Module.pbi    =
;/ ===================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Simplified use of the VectorDrawing library 
;/
;/ © 2019 Thorsten1867 (06/2019)
;/

; Last Update: 


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
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
;}


;{ _____ DrawEx - Commands _____

; Draw::AlphaColor_()   - similar to RGBA()
; Draw::Box_()          - similar to Box()
; Draw::Circle_()       - similar to Circle()
; Draw::CircleArc_()    - draws a arc of a circle
; Draw::CircleSector_() - draws a circle sector
; Draw::Ellipse_()      - similar to Ellipse()
; Draw::EllipseArc_()   - draws a arc of a ellipse
; Draw::Font_()         - similar to DrawingFont()
; Draw::Line_()         - similar to Line()
; Draw::HLine_()        - draws a horizontal line
; Draw::VLine_()        - draws a vertical line
; Draw::LineXY_()       - similar to LineXY()
; Draw::MixColor_()     - mixes 2 colours in a mixing ratio of 1% - 99%
; Draw::SetStroke_()    - changes the stroke width
; Draw::StartVector_()  - similar to StartVectorDrawing()
; Draw::StopVector_()   - similar to StopVectorDrawing()
; Draw::Text_()         - similar to DrawText()
; Draw::TextHeight_()   - similar to TextHeight()
; Draw::TextWidth_()    - similar to TextWidth()

;}


DeclareModule Draw
  
  EnumerationBinary
    #Text_Default  = #PB_VectorText_Default 
    #Text_Visible  = #PB_VectorText_Visible
    #Text_Offset   = #PB_VectorText_Offset
    #Text_Baseline = #PB_VectorText_Baseline
    #Vertical
    #Horizontal
    #Diagonal
    #Window
    #Image
    #Printer
    #Canvas
    #DPI
  EndEnumeration
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================  
  
  Declare.q AlphaColor_(Color.i, Alpha.i)
  Declare.q MixColor_(Color1.i, Color2.i, Factor.i=50)
  
  Declare   Box_(X.i, Y.i, Width.i, Height.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Rotate.i=0, Flags.i=#False)
  Declare   Circle_(X.i, Y.i, Radius.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Flags.i=#False)
  Declare   CircleArc_(X.i, Y.i, Radius.i, startAngle.i, endAngle.i, Color.q, Flags.i=#False)
  Declare   CircleSector_(X.i, Y.i, Radius.i, startAngle.i, endAngle.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Flags.i=#False)
  Declare   Ellipse_(X.i, Y.i, RadiusX.i, RadiusY.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Rotate.i=0, Flags.i=#False)
  Declare   EllipseArc_(X.i, Y.i, RadiusX.i, RadiusY.i, startAngle.i, endAngle.i, Color.q, Flags.i=#False)
  Declare   Font_(FontID.i, Size.i=#PB_Default, Flags.i=#False)
  Declare   Line_(X.i, Y.i, Width.i, Height.i, Color.q, Flags.i=#False)
  Declare   HLine_(X.i, Y.i, Width.i, Color.q, Flags.i=#False)
  Declare   VLine_(X.i, Y.i, Height.i, Color.q, Flags.i=#False)
  Declare   LineXY_(X1.i, Y1.i, X2.i, Y2.i, Color.q, Flags.i=#False)
  Declare.i StartVector_(PB_Num.i, Type.i=#Canvas, Unit.i=#PB_Unit_Pixel)
  Declare   StopVector_() 
  Declare   SetStroke_(Width.i=1)
  Declare   Text_(X.i, Y.i, Text$, Color.q, Angle.i=0, Flags.i=#False)
  Declare.f TextHeight_(Text.s, Flags.i=#PB_VectorText_Default) ; [ #Text_Default / #Text_Visible / #Text_Offset / #Text_Baseline ]
  Declare.f TextWidth_(Text.s,  Flags.i=#PB_VectorText_Default) ; [ #Text_Default / #Text_Visible / #Text_Offset ]

EndDeclareModule


Module Draw
  
  EnableExplicit
  
  Global Stroke.i
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
    Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
    Define.f Blend = Factor / 100
    
    Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
    Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)
    
    ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
  EndProcedure

  Procedure   _LineXY(X1.f, Y1.f, X2.f, Y2.f, Color.q)
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    MovePathCursor(X1, Y1)
    AddPathLine(X2, Y2)
    VectorSourceColor(Color)
    StrokePath(Stroke)
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure.q AlphaColor_(Color.i, Alpha.i) 
    ProcedureReturn RGBA(Red(Color), Green(Color), Blue(Color), Alpha)
  EndProcedure
  
  Procedure.q MixColor_(Color1.i, Color2.i, Factor.i=50)
    
    ProcedureReturn BlendColor_(Color1, Color2, Factor)
    
  EndProcedure
 
  Procedure Box_(X.i, Y.i, Width.i, Height.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Rotate.i=0, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    If Rotate : RotateCoordinates(X, Y, Rotate) : EndIf
    
    AddPathBox(X, Y, Width, Height)
    VectorSourceColor(Color)
    
    If FillColor <> #PB_Default
      
      If Alpha(FillColor) = #False : FillColor = RGBA(Red(FillColor), Green(FillColor), Blue(FillColor), 255) : EndIf
      
      If GradientColor <> #PB_Default
        If Alpha(GradientColor) = #False : GradientColor = RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255) : EndIf
        If Flags & #Horizontal
          VectorSourceLinearGradient(X, Y, X + Width, Y)
        ElseIf Flags & #Diagonal
          VectorSourceLinearGradient(X, Y, X + Width, Y + Height)
        Else
          VectorSourceLinearGradient(X, Y, X, Y + Height)
        EndIf
        VectorSourceGradientColor(FillColor, 1.0)
        VectorSourceGradientColor(GradientColor, 0.0)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(FillColor)
        FillPath(#PB_Path_Preserve)
      EndIf
      
    EndIf
    
    VectorSourceColor(Color)
    StrokePath(Stroke)
    
    If Rotate : RotateCoordinates(X, Y, -Rotate) : EndIf
    
  EndProcedure
  
  Procedure Circle_(X.i, Y.i, Radius.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Radius = dpiX(Radius)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    AddPathCircle(X, Y, Radius)
    
    If FillColor <> #PB_Default
      
      If Alpha(FillColor) = #False : FillColor = RGBA(Red(FillColor), Green(FillColor), Blue(FillColor), 255) : EndIf
      
      If GradientColor <> #PB_Default
        If Alpha(GradientColor) = #False : GradientColor = RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255) : EndIf
        VectorSourceCircularGradient(X, Y, Radius)
        VectorSourceGradientColor(FillColor, 1.0)
        VectorSourceGradientColor(GradientColor, 0.0)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(FillColor)
        FillPath(#PB_Path_Preserve)
      EndIf
      
    EndIf
    
    VectorSourceColor(Color)
    StrokePath(Stroke)
  
  EndProcedure
  
  Procedure CircleArc_(X.i, Y.i, Radius.i, startAngle.i, endAngle.i, Color.q, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Radius = dpiX(Radius)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    AddPathCircle(X, Y, Radius, startAngle, endAngle)
    VectorSourceColor(Color)
    StrokePath(Stroke)
    
  EndProcedure
  
  Procedure CircleSector_(X.i, Y.i, Radius.i, startAngle.i, endAngle.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Radius = dpiX(Radius)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf

    MovePathCursor(X, Y)
    AddPathCircle(X, Y, Radius, startAngle, endAngle, #PB_Path_Connected)
    ClosePath()
    
    If FillColor <> #PB_Default
      
      If Alpha(FillColor) = #False : FillColor = RGBA(Red(FillColor), Green(FillColor), Blue(FillColor), 255) : EndIf
      
      If GradientColor <> #PB_Default
        If Alpha(GradientColor) = #False : GradientColor = RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255) : EndIf
        VectorSourceCircularGradient(X, Y, Radius)
        VectorSourceGradientColor(FillColor, 0.0)
        VectorSourceGradientColor(GradientColor, 1.0)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(FillColor)
        FillPath(#PB_Path_Preserve)
      EndIf
      
    EndIf
    
    VectorSourceColor(Color)
    StrokePath(Stroke)
    
  EndProcedure
  
  Procedure Ellipse_(X.i, Y.i, RadiusX.i, RadiusY.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Rotate.i=0, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      RadiusX = dpiX(RadiusX)
      RadiusY = dpiY(RadiusY)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    If Rotate : RotateCoordinates(X, Y, Rotate) : EndIf
    
    AddPathEllipse(X, Y, RadiusX, RadiusY)
    
    If FillColor <> #PB_Default
      
      If Alpha(FillColor) = #False : FillColor = RGBA(Red(FillColor), Green(FillColor), Blue(FillColor), 255) : EndIf
      
      If GradientColor <> #PB_Default
        If Alpha(GradientColor) = #False : GradientColor = RGBA(Red(GradientColor), Green(GradientColor), Blue(GradientColor), 255) : EndIf
        If RadiusX > RadiusY
          VectorSourceCircularGradient(X, Y, RadiusX)
        Else
          VectorSourceCircularGradient(X, Y, RadiusY)
        EndIf 
        VectorSourceGradientColor(FillColor, 1.0)
        VectorSourceGradientColor(GradientColor, 0.0)
        FillPath(#PB_Path_Preserve)
      Else
        VectorSourceColor(FillColor)
        FillPath(#PB_Path_Preserve)
      EndIf
      
    EndIf
    
    VectorSourceColor(Color)
    StrokePath(Stroke)
    
    If Rotate : RotateCoordinates(X, Y, -Rotate) : EndIf
    
  EndProcedure
  
  Procedure EllipseArc_(X.i, Y.i, RadiusX.i, RadiusY.i, startAngle.i, endAngle.i, Color.q, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      RadiusX = dpiX(RadiusX)
      RadiusY = dpiY(RadiusY)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    AddPathEllipse(X, Y, RadiusX, RadiusY, startAngle, endAngle)
    VectorSourceColor(Color)
    StrokePath(Stroke)
    
  EndProcedure

  Procedure Line_(X.i, Y.i, Width.i, Height.i, Color.q, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
    EndIf
    
    If Width And Height
      
      If Width > 1
        
        _LineXY(X, Y, X + Width, Y, Color)
        
      Else
        
        _LineXY(X, Y, X, Y + Height, Color)
        
      EndIf
      
    EndIf
  EndProcedure
  
  Procedure VLine_(X.i, Y.i, Height.i, Color.q, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Height = dpiY(Height)
    EndIf
    
    If Height
      _LineXY(X, Y, X, Y + Height, Color)
    EndIf
      
  EndProcedure
  
  Procedure HLine_(X.i, Y.i, Width.i, Color.q, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
      Width  = dpiX(Width)
    EndIf
    
    If Width 
      _LineXY(X, Y, X + Width, Y, Color)
    EndIf    

  EndProcedure
  
  Procedure LineXY_(X1.i, Y1.i, X2.i, Y2.i, Color.q, Flags.i=#False)
    
    If Flags & #DPI
      X1 = dpiX(X1)
      Y1 = dpiY(Y1)
      X2 = dpiX(X2)
      Y2 = dpiY(Y2)
    EndIf
    
    _LineXY(X1, Y1, X2, Y2, Color)
    
  EndProcedure
  
  Procedure Font_(FontID.i, Size.i=#PB_Default, Flags.i=#False)
    
    If Flags & #DPI
      Size = dpiY(Size)
    EndIf
    
    If Size <= 0
      VectorFont(FontID)
    Else
      VectorFont(FontID, Size)
    EndIf

  EndProcedure
  
  Procedure Text_(X.i, Y.i, Text$, Color.q, Rotate.i=0, Flags.i=#False)
    
    If Flags & #DPI
      X = dpiX(X)
      Y = dpiY(Y)
    EndIf
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    If Rotate : RotateCoordinates(X, Y, Rotate) : EndIf
    
    MovePathCursor(X, Y)
    VectorSourceColor(Color)
    DrawVectorText(Text$)

    If Rotate : RotateCoordinates(X, Y, -Rotate) : EndIf
    
  EndProcedure
  
  Procedure.f TextWidth_(Text.s, Flags.i=#PB_VectorText_Default)
    
    ProcedureReturn VectorTextWidth(Text, Flags)

  EndProcedure
  
  Procedure.f TextHeight_(Text.s, Flags.i=#PB_VectorText_Default)
    
    ProcedureReturn VectorTextHeight(Text, Flags)
    
  EndProcedure
  
  Procedure   SetStroke_(Width.i=1)
    Stroke = Width
  EndProcedure
  
  Procedure.i StartVector_(PB_Num.i, Type.i=#Canvas, Unit.i=#PB_Unit_Pixel) 
    
    Stroke = 1
    
    Select Type
      Case #Canvas
        ProcedureReturn StartVectorDrawing(CanvasVectorOutput(PB_Num, Unit))
      Case #Image
        ProcedureReturn StartVectorDrawing(ImageVectorOutput(PB_Num, Unit))
      Case #Window
        ProcedureReturn StartVectorDrawing(WindowVectorOutput(PB_Num, Unit))
      Case #Printer
        ProcedureReturn StartVectorDrawing(PrinterVectorOutput(Unit))
    EndSelect

  EndProcedure
  
  Procedure   StopVector_() 
    
    Stroke = #False
    StopVectorDrawing()

  EndProcedure
  
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window = 0
  #Gadget = 1
  #Font   = 2
  
  LoadFont(#Font, "Arial", 16, #PB_Font_Bold)

  If OpenWindow(#Window, 0, 0, 200, 200, "VectorDrawing Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered)
    
    CanvasGadget(#Gadget, 10, 10, 180, 180)

    If Draw::StartVector_(#Gadget, Draw::#Canvas)
      
      Draw::Font_(FontID(#Font))
      
      Draw::Box_(2, 2, 176, 176, $CD0000, $FACE87, $FFF8F0, 0, Draw::#DPI) ; Draw::#Horizontal / Draw::#Diagonal
      Draw::Text_(65, 65, "Text", $701919, #False, Draw::#DPI)
      Draw::CircleSector_(90, 90, 70, 40, 90, $800000, $00D7FF, $008CFF, Draw::#DPI)
      Draw::SetStroke_(2)
      Draw::LineXY_(90, 90, 90 + 80 * Cos(Radian(150)), 90 + 80 * Sin(Radian(150)), $228B22, Draw::#DPI)
      Draw::Circle_(90, 90, 80, $800000, #PB_Default, #PB_Default, Draw::#DPI)
      ;Draw::Ellipse_(90, 90, 80, 60, $800000, $FACE87, $FFF8F0, 30, Draw::#DPI)
      Draw::SetStroke_(4)
      Draw::EllipseArc_(90, 90, 70, 45, 160, 240, $CC3299, Draw::#DPI)
      Draw::SetStroke_(1)
      Draw::CircleArc_(90, 90, 70, 250, 340, $008CFF, Draw::#DPI)
      Draw::Line_(10, 90, 160, 1, $8515C7, Draw::#DPI)
      
      Draw::StopVector_()
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  EndIf

  
CompilerEndIf  
