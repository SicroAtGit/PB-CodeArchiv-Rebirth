;   Description: Extented Time Gadget (CanvasGadget)
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72548
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31376
; -----------------------------------------------------------------------------

;/ ============================
;/ =    TimeExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; Last Update: 2.4.2019


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


;{ _____ TimeEx - Commands _____

; TimeEx::GetColor() - similar to 'GetGadgetColor()'
; TimeEx::GetState() - similar to 'GetGadgetState()'
; TimeEx::GetText()  - similar to 'GetGadgetText()'
; TimeEx::Gadget()   - creates a time gadget
; TimeEx::SetColor() - similar to 'SetGadgetColor()'
; TimeEx::SetFont()  - similar to 'SetGadgetFont()'
; TimeEx::SetText()  - similar to 'SetGadgetText()'
; TimeEx::SetState() - similar to 'SetGadgetState()'

;}

DeclareModule TimeEx
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  EnumerationBinary Flags
    #Borderless
    #Format12Hour
    #NoSeconds
  EndEnumeration
  
  Enumeration Color 1 
    #FrontColor  = #PB_Gadget_FrontColor
    #BackColor   = #PB_Gadget_BackColor
    #BorderColor = #PB_Gadget_LineColor
    #FocusColor
    #HighlightColor
    #HighlightTextColor
  EndEnumeration ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.i GetState(GNum.i)
  Declare.s GetText(GNum.i, Seperator.s=":")
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Time.s, Flags.i=#False, WindowNum.i=#PB_Default) 
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetFont(GNum.i, FontNum.i)
  Declare   SetState(GNum.i, Seconds.i) 
  Declare   SetText(GNum.i, Time.s, Seperator.s=":")
  
EndDeclareModule


Module TimeEx
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================  
  
  #ButtonWidth = 18
  
  #Up   = 1
  #Down = 2 
  
  Enumeration Time 1
    #Hour
    #Minute
    #Second
    #AmPm
  EndEnumeration
  
  EnumerationBinary State
    #Focus
    #FocusUp
    #FocusDown
    #ClickUp
    #ClickDown
    #Input
  EndEnumeration

  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================  
  
  Structure TGEx_Selection_Structure ;{ TGEx()\Selection\...
    hX.f
    hWidth.f
    mX.f
    mWidth.f
    sX.f
    sWidth.f
    uX.f
    uWidth.f
  EndStructure ;}
  
  Structure TGEx_Time_Structure      ;{ TGEx()\Time\...
    Input.s
    Hour.i
    Minute.i
    Second.i
    AmPm.s
    State.i
  EndStructure ;}
  
  Structure TGEx_Button_Structure    ;{ TGEx()\Button\...
    X.f
    Y1.f
    Y2.f
    Height.f
    State.i
  EndStructure ;}
  
  Structure TGEx_Color_Structure     ;{ TGEx()\Color\...
    Front.i
    Back.i
    Focus.i
    Border.i
    Highlight.i
    HighlightText.i
    Button.i
    ButtonBorder.i
  EndStructure ;}
  
  Structure TGEx_Window_Structure    ;{ TGEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  
  Structure TGEx_Structure           ;{ TGEx('GNum')\...
    CanvasNum.i
    
    FontID.i
    State.i
    Flags.i
    
    Button.TGEx_Button_Structure
    Color.TGEx_Color_Structure
    Selection.TGEx_Selection_Structure
    Time.TGEx_Time_Structure
    Window.TGEx_Window_Structure
    
  EndStructure ;}
  Global NewMap TGEx.TGEx_Structure()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================   
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    ; Addition of mk-soft
    
    Procedure OSX_NSColorToRGBA(NSColor)
      Protected.cgfloat red, green, blue, alpha
      Protected nscolorspace, rgba
      nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        CocoaMessage(@alpha, nscolorspace, "alphaComponent")
        rgba = RGBA(red * 255.9, green * 255.9, blue * 255.9, alpha * 255.)
        ProcedureReturn rgba
      EndIf
    EndProcedure
    
    Procedure OSX_NSColorToRGB(NSColor)
      Protected.cgfloat red, green, blue
      Protected r, g, b, a
      Protected nscolorspace, rgb
      nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
        ProcedureReturn rgb
      EndIf
    EndProcedure
    
  CompilerEndIf
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  Procedure  SetInputTime_()
    
    If TGEx()\State & #Input
      Select TGEx()\Time\State
        Case #Hour
          TGEx()\Time\Hour   = Val(TGEx()\Time\Input)
        Case #Minute
          TGEx()\Time\Minute = Val(TGEx()\Time\Input)
        Case #Second
          TGEx()\Time\Second = Val(TGEx()\Time\Input)
      EndSelect
      TGEx()\Time\Input = ""
      TGEx()\State & ~#Input
    EndIf
    
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure  
  
  Procedure   Arrow_(X.i, Y.i, Width.i, Height.i, Flag.i)
    Define.i aX, aY, aWidth, aHeight, Color
    
    Color = BlendColor_($000000, TGEx()\Color\Back, 60)
    
    If dpiX(100) >= 125
      aWidth  = dpiX(8)
      aHeight = dpiX(4)
    Else
      aWidth  = dpiX(6)
      aHeight = dpiX(3)
    EndIf
    
    aX = X + (Width  - aWidth)  / 2
    aY = Y + (Height - aHeight) / 2    

    DrawingMode(#PB_2DDrawing_Default)
    
    Select Flag
      Case #Up 
        Line(aX, aY + aHeight, aWidth, 1, Color)
        LineXY(aX, aY + aHeight, aX + (aWidth / 2), aY, Color)
        LineXY(aX + (aWidth / 2), aY, aX + aWidth, aY + aHeight, Color)
        FillArea(aX + (aWidth / 2), aY+ aHeight - dpiY(1), -1, Color)
      Case #Down
        Line(aX, aY, aWidth, 1, Color)
        LineXY(aX, aY, aX + (aWidth / 2), aY + aHeight, Color)
        LineXY(aX + (aWidth / 2), aY + aHeight, aX + aWidth, aY, Color)
        FillArea(aX + (aWidth / 2), aY + dpiY(1), -1, Color)
    EndSelect
    
  EndProcedure
  
  Procedure   Draw_(GNum.i)
    Define.f X, Y, Width, Height, btX, btY, btHeight
    Define.i TextColor, BackColor, BorderColor, btBackColor, btBorderColor
    Define.s Hour, Minute, Second
    
    If FindMapElement(TGEx(), Str(GNum))
      
      If StartDrawing(CanvasOutput(TGEx()\CanvasNum))
        
        BackColor   = TGEx()\Color\Back
        BorderColor = TGEx()\Color\Border
        TextColor   = TGEx()\Color\Front
        
        If TGEx()\State & #Focus : BorderColor = TGEx()\Color\Focus : EndIf
        
        ;{ _____ Background _____
        DrawingMode(#PB_2DDrawing_Default)
        Box(0, 0, dpiX(GadgetWidth(TGEx()\CanvasNum)), dpiY(GadgetHeight(TGEx()\CanvasNum)), BackColor)
        ;}
        
        Height = dpiY(GadgetHeight(TGEx()\CanvasNum))
        Width  = dpiX(GadgetWidth(TGEx()\CanvasNum) - #ButtonWidth - 4)
        
        ;{ _____ Buttons _____
        If DesktopScaledX(100) >= 125
          TGEx()\Button\X = dpiX(GadgetWidth(TGEx()\CanvasNum) - #ButtonWidth - 1)
          TGEx()\Button\Height = dpiY((GadgetHeight(TGEx()\CanvasNum) - 5) / 2 )
          TGEx()\Button\Y1     = dpiY(3)
        Else
          TGEx()\Button\X = dpiX(GadgetWidth(TGEx()\CanvasNum) - #ButtonWidth - 2)
          TGEx()\Button\Height = dpiY((GadgetHeight(TGEx()\CanvasNum) - 4) / 2 )
          TGEx()\Button\Y1     = dpiY(2)
        EndIf
        
        

        If TGEx()\Button\State & #ClickUp
          btBackColor   = BlendColor_(TGEx()\Color\Focus, $FFFFFF, 20)
          btBorderColor = TGEx()\Color\Focus
        ElseIf TGEx()\Button\State & #FocusUp
          btBackColor   = BlendColor_(TGEx()\Color\Focus, $FFFFFF, 10)
          btBorderColor = TGEx()\Color\Focus
        Else
          btBackColor   = TGEx()\Color\Button
          btBorderColor = TGEx()\Color\ButtonBorder
        EndIf
        
        DrawingMode(#PB_2DDrawing_Default)
        Box(TGEx()\Button\X, TGEx()\Button\Y1, dpiX(#ButtonWidth), TGEx()\Button\Height, btBackColor)
        Arrow_(TGEx()\Button\X, TGEx()\Button\Y1, dpiX(#ButtonWidth), TGEx()\Button\Height, #Up)
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(TGEx()\Button\X, TGEx()\Button\Y1, dpiX(#ButtonWidth), TGEx()\Button\Height, btBorderColor)
        
        TGEx()\Button\Y2 = dpiY(GadgetHeight(TGEx()\CanvasNum) - 2) - TGEx()\Button\Height
        
        If TGEx()\Button\State & #ClickDown
          btBackColor   = BlendColor_(TGEx()\Color\Focus, $FFFFFF, 20)
          btBorderColor = TGEx()\Color\Focus
        ElseIf TGEx()\Button\State & #FocusDown
          btBackColor   = BlendColor_(TGEx()\Color\Focus, $FFFFFF, 10)
          btBorderColor = TGEx()\Color\Focus
        Else
          btBackColor   = TGEx()\Color\Button
          btBorderColor = TGEx()\Color\ButtonBorder
        EndIf

        DrawingMode(#PB_2DDrawing_Default)
        Box(TGEx()\Button\X, TGEx()\Button\Y2, dpiX(#ButtonWidth), TGEx()\Button\Height, btBackColor)
        Arrow_(TGEx()\Button\X, TGEx()\Button\Y2, dpiX(#ButtonWidth), TGEx()\Button\Height, #Down)
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(TGEx()\Button\X, TGEx()\Button\Y2, dpiX(#ButtonWidth), TGEx()\Button\Height, btBorderColor)
        ;}
        
        ;{ _____ Text ____
        DrawingFont(TGEx()\FontID)
        
        X = dpiX(4)
        Y = (Height - TextHeight("X")) / 2
        
        Hour   = RSet(Str(TGEx()\Time\Hour),   2, "0")
        Minute = RSet(Str(TGEx()\Time\Minute), 2, "0")
        Second = RSet(Str(TGEx()\Time\Second), 2, "0")
        
        TGEx()\Selection\hX     = X
        TGEx()\Selection\hWidth = TextWidth(Hour)
        TGEx()\Selection\mX     = TGEx()\Selection\hX + TGEx()\Selection\hWidth + TextWidth(" : ")
        TGEx()\Selection\mWidth = TextWidth(Minute)
        If TGEx()\Flags & #NoSeconds
          TGEx()\Selection\sX     = 0
          TGEx()\Selection\sWidth = 0
        Else
          TGEx()\Selection\sX     = TGEx()\Selection\mX + TGEx()\Selection\mWidth + TextWidth(" : ")
          TGEx()\Selection\sWidth = TextWidth(Second)
        EndIf

        DrawingMode(#PB_2DDrawing_Transparent)
        If TGEx()\Flags & #Format12Hour
          TGEx()\Selection\uX     = TGEx()\Selection\sX + TGEx()\Selection\sWidth + TextWidth("  ")
          TGEx()\Selection\uWidth = TextWidth(TGEx()\Time\AmPm)
          If TGEx()\Flags & #NoSeconds
            DrawText(X, Y, Hour + " : " + Minute + "  " + TGEx()\Time\AmPm, TGEx()\Color\Front)
          Else
            DrawText(X, Y, Hour + " : " + Minute + " : " + Second + "  " + TGEx()\Time\AmPm, TGEx()\Color\Front)
          EndIf
        Else
          If TGEx()\Flags & #NoSeconds 
            DrawText(X, Y, Hour + " : " + Minute, TGEx()\Color\Front)
          Else
            DrawText(X, Y, Hour + " : " + Minute + " : " + Second, TGEx()\Color\Front)
          EndIf  
        EndIf
        
        DrawingMode(#PB_2DDrawing_Default)
        Select TGEx()\Time\State
          Case #Hour
            If TGEx()\State & #Input : Hour = RSet(TGEx()\Time\Input, 2, "0") : EndIf
            DrawText(TGEx()\Selection\hX, Y, Hour,   TGEx()\Color\HighlightText, TGEx()\Color\Highlight)
          Case #Minute
            If TGEx()\State & #Input : Minute = RSet(TGEx()\Time\Input, 2, "0") : EndIf
            DrawText(TGEx()\Selection\mX, Y, Minute, TGEx()\Color\HighlightText, TGEx()\Color\Highlight)
          Case #Second 
            If TGEx()\Flags & #NoSeconds = #False
              If TGEx()\State & #Input : Second = RSet(TGEx()\Time\Input, 2, "0") : EndIf
              DrawText(TGEx()\Selection\sX, Y, Second, TGEx()\Color\HighlightText, TGEx()\Color\Highlight)
            EndIf
          Case #AmPm
            DrawText(TGEx()\Selection\uX, Y, TGEx()\Time\AmPm, TGEx()\Color\HighlightText, TGEx()\Color\Highlight)
        EndSelect
        ;}
        
        ;{ _____ Border ____
        If TGEx()\Flags & #Borderless = #False
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0, 0, dpiX(GadgetWidth(TGEx()\CanvasNum)), dpiY(GadgetHeight(TGEx()\CanvasNum)), BorderColor)
        EndIf
        ;}
      
       StopDrawing()
     EndIf
     
    EndIf
    
  EndProcedure
  
  ;- __________ Events __________

  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      TGEx()\State | #Focus
      
      Draw_(GNum)
    EndIf
    
  EndProcedure  
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      TGEx()\State & ~#Focus
      TGEx()\Button\State & ~#FocusUp
      TGEx()\Button\State & ~#FocusDown
      
      SetInputTime_()
      
      TGEx()\Time\State = #False
      
      Draw_(GNum)
    EndIf
    
  EndProcedure      
  
  Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      TGEx()\Button\State & ~#FocusUp
      TGEx()\Button\State & ~#FocusDown
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure _MouseMoveHandler()
    Define.i X, Y
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If X > TGEx()\Button\X
        
        If Y > TGEx()\Button\Y1 And Y < TGEx()\Button\Y2 - dpiY(2)
          TGEx()\Button\State | #FocusUp
        Else
          TGEx()\Button\State & ~#FocusUp
        EndIf
        
        If Y > TGEx()\Button\Y2 And Y < TGEx()\Button\Y2 + TGEx()\Button\Height - dpiY(1)
          TGEx()\Button\State | #FocusDown
        Else
          TGEx()\Button\State & ~#FocusDown
        EndIf
        
      Else
        
        TGEx()\Button\State & ~#FocusUp
        TGEx()\Button\State & ~#FocusDown
        
      EndIf
   
      Draw_(GNum) 
    EndIf
    
  EndProcedure  
  
  Procedure _LeftButtonDownHandler()
    Define.i X, Y
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If X > TGEx()\Button\X
        
        If Y > TGEx()\Button\Y1 And Y < TGEx()\Button\Y2 - dpiY(2)
          TGEx()\Button\State | #ClickUp
        EndIf
        
        If Y > TGEx()\Button\Y2 And Y < TGEx()\Button\Y2 + TGEx()\Button\Height - dpiY(1)
          TGEx()\Button\State | #ClickDown
        EndIf

      EndIf 
      
      TGEx()\State | #Focus

      Draw_(GNum)
    EndIf
    
  EndProcedure 
  
  Procedure _LeftButtonUpHandler()
    Define.i X, Y
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      SetInputTime_()
      
      If X > TGEx()\Button\X
        
        If Y > TGEx()\Button\Y1 And Y < TGEx()\Button\Y2 - dpiY(2)
          Select TGEx()\Time\State
            Case #Hour
              TGEx()\Time\Hour   + 1
              If TGEx()\Flags & #Format12Hour
                If TGEx()\Time\Hour > 12 : TGEx()\Time\Hour = 1 : EndIf
              Else
                If TGEx()\Time\Hour > 24 : TGEx()\Time\Hour = 1 : EndIf
              EndIf
            Case #Minute
              TGEx()\Time\Minute + 1
              If TGEx()\Time\Minute > 59 : TGEx()\Time\Minute = 0 : EndIf
            Case #Second
              TGEx()\Time\Second + 1
              If TGEx()\Time\Second > 59 : TGEx()\Time\Second = 0 : EndIf
            Case #AmPm
              TGEx()\Time\AmPm = "PM"
          EndSelect
        EndIf
        
        If Y > TGEx()\Button\Y2 And Y < TGEx()\Button\Y2 + TGEx()\Button\Height - dpiY(1)
          Select TGEx()\Time\State
            Case #Hour
              TGEx()\Time\Hour   - 1
              If TGEx()\Flags & #Format12Hour
                If TGEx()\Time\Hour <= 0 : TGEx()\Time\Hour = 12 : EndIf
              Else
                If TGEx()\Time\Hour <= 0 : TGEx()\Time\Hour = 24 : EndIf
              EndIf
            Case #Minute
              TGEx()\Time\Minute - 1
              If TGEx()\Time\Minute < 0 : TGEx()\Time\Minute = 59 : EndIf
            Case #Second
              TGEx()\Time\Second - 1
              If TGEx()\Time\Second < 0 : TGEx()\Time\Second = 59 : EndIf
            Case #AmPm
              TGEx()\Time\AmPm = "AM"
          EndSelect
        EndIf

      Else
        
        If X > TGEx()\Selection\hX  And X < TGEx()\Selection\hX + TGEx()\Selection\hWidth
          TGEx()\Time\State = #Hour
        ElseIf X > TGEx()\Selection\mX And X < TGEx()\Selection\mX + TGEx()\Selection\mWidth
          TGEx()\Time\State = #Minute
        ElseIf X > TGEx()\Selection\sX And X < TGEx()\Selection\sX + TGEx()\Selection\sWidth
          TGEx()\Time\State = #Second
        ElseIf X > TGEx()\Selection\uX And X < TGEx()\Selection\uX + TGEx()\Selection\uWidth
          TGEx()\Time\State = #AmPm
        Else
          TGEx()\Time\State = #False
        EndIf 
        
      EndIf  
      
      TGEx()\Button\State & ~#ClickDown
      TGEx()\Button\State & ~#ClickUp
      
      Draw_(GNum)
    EndIf
    
  EndProcedure   
  
  Procedure _InputHandler()
    Define.s Num$
    Define.i Char
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
      If Char >= 48 And Char <= 57
        Num$ = Chr(Char)
        
        If Len(TGEx()\Time\Input) >= 2 : TGEx()\Time\Input = "" : EndIf
          
        Select TGEx()\Time\State
          Case #Hour
            If Val(TGEx()\Time\Input + Num$) <= 24
              TGEx()\Time\Input + Num$
            Else
              TGEx()\Time\Input = Num$
            EndIf 
            TGEx()\State | #Input
          Case #Minute
            If Val(TGEx()\Time\Input + Num$) <= 59
              TGEx()\Time\Input + Num$
            Else
              TGEx()\Time\Input = Num$
            EndIf
            TGEx()\State | #Input
          Case #Second
            If Val(TGEx()\Time\Input + Num$) <= 59
              TGEx()\Time\Input + Num$
            Else
              TGEx()\Time\Input = Num$
            EndIf
            TGEx()\State | #Input
        EndSelect
        
        Draw_(GNum)
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure _KeyDownHandler()
    Define.i Key, Modifier
    Define.i GNum = EventGadget()
    
    If FindMapElement(TGEx(), Str(GNum))
      
      Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
      
      Select Key
        Case #PB_Shortcut_Left      ;{ Cursor left
          Select TGEx()\Time\State
            Case #Minute
              TGEx()\Time\State = #Hour
            Case #Second
              TGEx()\Time\State = #Minute
            Case #AmPm
              If TGEx()\Flags & #NoSeconds
                TGEx()\Time\State = #Minute
              Else
                TGEx()\Time\State = #Second
              EndIf
          EndSelect ;}
        Case #PB_Shortcut_Right     ;{ Cursor right
          Select TGEx()\Time\State
            Case #Hour
              TGEx()\Time\State = #Minute
            Case #Minute
              If TGEx()\Flags & #NoSeconds
                If TGEx()\Flags & #Format12Hour
                  TGEx()\Time\State = #AmPm
                EndIf
              Else 
                TGEx()\Time\State = #Second
              EndIf
            Case #Second
              If TGEx()\Flags & #Format12Hour
                TGEx()\Time\State = #AmPm
              EndIf
          EndSelect ;}
        Case #PB_Shortcut_Up        ;{ Cursor right
          Select TGEx()\Time\State
            Case #Hour
              TGEx()\Time\Hour + 1
              If TGEx()\Flags & #Format12Hour
                If TGEx()\Time\Hour > 12 : TGEx()\Time\Hour = 1 : EndIf
              Else
                If TGEx()\Time\Hour > 24 : TGEx()\Time\Hour = 1 : EndIf
              EndIf
            Case #Minute
              TGEx()\Time\Minute + 1
              If TGEx()\Time\Minute > 59 : TGEx()\Time\Minute = 0 : EndIf
            Case #Second
              TGEx()\Time\Second + 1
              If TGEx()\Time\Second > 59 : TGEx()\Time\Second = 0 : EndIf
            Case #AmPm
              TGEx()\Time\AmPm = "PM"
          EndSelect
          ;}
        Case #PB_Shortcut_Down      ;{ Cursor down
          Select TGEx()\Time\State
            Case #Hour
              TGEx()\Time\Hour   - 1
              If TGEx()\Flags & #Format12Hour
                If TGEx()\Time\Hour <= 0 : TGEx()\Time\Hour = 12 : EndIf
              Else
                If TGEx()\Time\Hour <= 0 : TGEx()\Time\Hour = 24 : EndIf
              EndIf
            Case #Minute
              TGEx()\Time\Minute - 1
              If TGEx()\Time\Minute < 0 : TGEx()\Time\Minute = 59 : EndIf
            Case #Second
              TGEx()\Time\Second - 1
              If TGEx()\Time\Second < 0 : TGEx()\Time\Second = 59 : EndIf
            Case #AmPm
              TGEx()\Time\AmPm = "AM"
          EndSelect
          ;}
        Case #PB_Shortcut_Tab       ;{ Tabulator
          If Modifier & #PB_Canvas_Shift
            Select TGEx()\Time\State
              Case #Minute
                TGEx()\Time\State = #Hour
              Case #Second
                TGEx()\Time\State = #Minute
              Case #AmPm
                If TGEx()\Flags & #NoSeconds
                  TGEx()\Time\State = #Minute
                Else
                  TGEx()\Time\State = #Second
                EndIf
            EndSelect
          Else
            Select TGEx()\Time\State
              Case #Hour
                TGEx()\Time\State = #Minute
              Case #Minute
                If TGEx()\Flags & #NoSeconds
                  If TGEx()\Flags & #Format12Hour
                    TGEx()\Time\State = #AmPm
                  EndIf
                Else 
                  TGEx()\Time\State = #Second
                EndIf
              Case #Second
                If TGEx()\Flags & #Format12Hour
                  TGEx()\Time\State = #AmPm
                EndIf
            EndSelect 
          EndIf;}
      EndSelect
      
      Draw_(GNum)
      
    EndIf

  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================   
  
  Procedure.i GetColor(GNum.i, ColorType.i) 
    
    If FindMapElement(TGEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn TGEx()\Color\Front
        Case #BackColor
          ProcedureReturn TGEx()\Color\Back
        Case #BorderColor
          ProcedureReturn TGEx()\Color\Border
        Case #FocusColor
          ProcedureReturn TGEx()\Color\Focus
        Case #HighlightColor
          ProcedureReturn TGEx()\Color\Highlight
        Case #HighlightTextColor
          ProcedureReturn TGEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.i GetState(GNum.i) 
    Define.i Time
    
    If FindMapElement(TGEx(), Str(GNum))
      
      Time = TGEx()\Time\Hour * 60
      Time + TGEx()\Time\Minute
      
      If TGEx()\Flags & #Format12Hour
        Select UCase(TGEx()\Time\AmPm)
          Case "AM"
            ProcedureReturn Time * 60
          Case "PM"
            ProcedureReturn Time * 60 + 43200
        EndSelect    
      Else
        ProcedureReturn Time * 60
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure.s GetText(GNum.i, Seperator.s=":")
    Define.s Hour, Minute, Second
    
    If FindMapElement(TGEx(), Str(GNum))
      Hour   = RSet(Str(TGEx()\Time\Hour),   2, "0")
      Minute = RSet(Str(TGEx()\Time\Minute), 2, "0")
      Second = RSet(Str(TGEx()\Time\Second), 2, "0")
      
      If TGEx()\Flags & #Format12Hour
        ProcedureReturn Hour + Seperator + Minute + Seperator + Second + " " + TGEx()\Time\AmPm
      Else   
        ProcedureReturn Hour + Seperator + Minute + Seperator + Second
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Time.s, Flags.i=#False, WindowNum.i=#PB_Default) 
    Define Result.i, txtNum
    
    Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard)
    If Result
      If GNum = #PB_Any : GNum = Result : EndIf
      
      If AddMapElement(TGEx(), Str(GNum))
        
        TGEx()\CanvasNum = GNum
        
        TGEx()\Flags = Flags
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default
            TGEx()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            TGEx()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            TGEx()\Window\Num = GetActiveWindow()
          Else
            TGEx()\Window\Num = WindowNum
          EndIf
        CompilerEndIf   
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If ModuleEx::AddWindow(TGEx()\Window\Num, ModuleEx::#Tabulator)
            ModuleEx::AddGadget(GNum, TGEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf
        CompilerEndIf
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            TGEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              TGEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            TGEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        TGEx()\Color\Front         = $000000
        TGEx()\Color\Back          = $FFFFFF
        TGEx()\Color\Focus         = $D77800
        TGEx()\Color\Border        = $A0A0A0
        TGEx()\Color\Highlight     = $D77800
        TGEx()\Color\HighlightText = $FFFFFF
        TGEx()\Color\Button        = $E3E3E3    
        TGEx()\Color\ButtonBorder  = $A0A0A0
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            TGEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            TGEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            TGEx()\Color\Focus         = GetSysColor_(#COLOR_HIGHLIGHT)
            TGEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
            TGEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            TGEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
            TGEx()\Color\Button        = GetSysColor_(#COLOR_3DFACE) 
            TGEx()\Color\ButtonBorder  = GetSysColor_(#COLOR_3DSHADOW)
          CompilerCase #PB_OS_MacOS
            TGEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            TGEx()\Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            TGEx()\Color\Focus         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            TGEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            TGEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            TGEx()\Color\Button        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            TGEx()\Color\ButtonBorder  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}
        
        TGEx()\Time\Hour   = Val(Trim(StringField(Time, 1, ":")))
        TGEx()\Time\Minute = Val(Trim(StringField(Time, 2, ":")))
        TGEx()\Time\Second = Val(Trim(StringField(Time, 3, ":")))
        If Flags & #Format12Hour
          If StringField(Time, 2, " ") = ""
            TGEx()\Time\AmPm = "AM"
          Else
            TGEx()\Time\AmPm = UCase(StringField(Time, 2, " "))
          EndIf  
        EndIf
        
        BindGadgetEvent(GNum, @_FocusHandler(),          #PB_EventType_Focus)
        BindGadgetEvent(GNum, @_LostFocusHandler(),      #PB_EventType_LostFocus)
        BindGadgetEvent(GNum, @_MouseMoveHandler(),      #PB_EventType_MouseMove)
        BindGadgetEvent(GNum, @_MouseLeaveHandler(),     #PB_EventType_MouseLeave)
        BindGadgetEvent(GNum, @_LeftButtonDownHandler(), #PB_EventType_LeftButtonDown)
        BindGadgetEvent(GNum, @_LeftButtonUpHandler(),   #PB_EventType_LeftButtonUp)
        BindGadgetEvent(GNum, @_InputHandler(),          #PB_EventType_Input)
        BindGadgetEvent(GNum, @_KeyDownHandler(),        #PB_EventType_KeyDown)
        
      EndIf
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i) 
    
    If FindMapElement(TGEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          TGEx()\Color\Front = Color
        Case #BackColor
          TGEx()\Color\Back = Color
        Case #BorderColor
          TGEx()\Color\Border = Color
        Case #FocusColor
          TGEx()\Color\Focus = Color
        Case #HighlightColor
          TGEx()\Color\Highlight = Color
        Case #HighlightTextColor
          TGEx()\Color\HighlightText = Color
      EndSelect
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(TGEx(), Str(GNum))
      
      If IsFont(FontNum)
        TGEx()\FontID = FontID(FontNum)
      EndIf
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   SetState(GNum.i, Seconds.i) 
    Define.i Minute
    
    If FindMapElement(TGEx(), Str(GNum))

      TGEx()\Time\Second = Mod(Seconds, 60)
      Minute = Int(Seconds / 60)
      
      If TGEx()\Flags & #Format12Hour
        TGEx()\Time\Hour = Int(Minute / 60)
        If TGEx()\Time\Hour > 12
          TGEx()\Time\Hour - 12
          TGEx()\Time\AmPm = "PM"
        Else
          TGEx()\Time\AmPm = "AM"
        EndIf 
      Else
        TGEx()\Time\Hour   = Int(Minute / 60)
      EndIf
      
      TGEx()\Time\Minute = Mod(Minute, 60)
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   SetText(GNum.i, Time.s, Seperator.s=":")
    
    If FindMapElement(TGEx(), Str(GNum))
      
      TGEx()\Time\Hour   = Val(Trim(StringField(Time, 1, Seperator)))
      TGEx()\Time\Minute = Val(Trim(StringField(Time, 2, Seperator)))
      TGEx()\Time\Second = Val(Trim(StringField(Time, 3, Seperator)))
      
      If TGEx()\Flags & #Format12Hour
        If StringField(Time, 2, " ") = ""
          TGEx()\Time\AmPm = "AM"
        Else
          TGEx()\Time\AmPm = UCase(StringField(Time, 2, " "))
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure 
  
EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  
  Enumeration 1
    #Time
    #TimeUS
    #TimeNS
  EndEnumeration

  
  If OpenWindow(#Window, 0, 0, 305, 60, "TimeEx - Gadget", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    TimeEx::Gadget(#Time, 10, 15, 85, 25, "8:30", #False, #Window)
    ;TimeEx::SetState(#Time, 34245)
    
    TimeEx::Gadget(#TimeNS, 110, 15, 64, 25, "12:15", TimeEx::#NoSeconds, #Window)
    
    TimeEx::Gadget(#TimeUS, 189, 15, 106, 25, "9:45 pm", TimeEx::#Format12Hour, #Window)
    ;TimeEx::SetState(#TimeUS, 54900)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Time

          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
