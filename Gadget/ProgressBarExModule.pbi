;   Description: Extended ProgressBarGadget
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72984
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31522
; -----------------------------------------------------------------------------

;/ ===========================
;/ =    ProgressBarEx-Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Extented ProgressBar 
;/
;/ © 2019 Thorsten1867 (06/2019)
;/

; Last Update: 24.8.2019

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


;{ _____ ProgressBarEx - Commands _____

; ProgressEx::Gadget()             - similar to ProgressBarGadget()
; ProgressEx::GetAttribute()       - similar to GetGadgetAttribute()
; ProgressEx::GetState()           - similar to GetGadgetState()
; ProgressEx::SetAutoResizeFlags() - defines the behavior of AutoResize
; ProgressEx::SetAttribute()       - similar to SetGadgetAttribute()
; ProgressEx::SetColor()           - similar to SetGadgetColor()
; ProgressEx::SetFont()            - similar to SetGadgetFont()
; ProgressEx::SetState()           - similar to SetGadgetState()
; ProgressEx::SetText()            - similar to SetGadgetText()
;}

DeclareModule ProgressEx
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  #Progress$ = "{Percent}"
  
  #Left = 0
  
  EnumerationBinary
    #Center = #PB_Text_Center
    #Right  = #PB_Text_Right
    #Border
    #Vertical
    #ShowPercent
    #AutoResize
  EndEnumeration
  
  Enumeration 1
    #Minimum = #PB_ProgressBar_Minimum
    #Maximum = #PB_ProgressBar_Maximum
    #Percent 
  EndEnumeration
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration  
  
  Enumeration 1
    #FrontColor
    #BackColor
    #ProgressBarColor
    #GradientColor
    #BorderColor
  EndEnumeration
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Minimum.i=0, Maximum.i=100, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.i GetState(GNum.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetFont(GNum.i, FontNum.i)
  Declare   SetState(GNum.i, Value.i)
  Declare   SetText(GNum.i, Text.s, Align.i=#Left)
  
EndDeclareModule


Module ProgressEx
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants / Structures
  ;- ============================================================================  
   
  Structure PBarEx_Size_Structure  ;{ PBarEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    winWidth.f
    winHeight.f
    Flags.i
  EndStructure ;}
  
  Structure PBarEx_Color_Structure ;{ PBarEx()\Color\...
    Front.i
    Back.i
    ProgressBar.i
    Gradient.i
    Border.i
  EndStructure ;}
  
  Structure PBarEx_Structure       ;{ PBarEx()\...
    WindowNum.i
    CanvasNum.i
    
    FontID.i
    
    Text.s
    Align.i
    
    State.i
    Percent.i
    Minimum.i
    Maximum.i
    
    Flags.i
    
    Size.PBarEx_Size_Structure
    Color.PBarEx_Color_Structure
    
  EndStructure ;}
  Global NewMap PBarEx.PBarEx_Structure()
 
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
  
  ;- __________ Drawing __________
  
  Procedure Draw_() 
    Define.f Factor
    Define.i Width, Progress, txtWidth, txtHeight, txtX, txtY
    Define.s Percent$, Text$
    
    If StartDrawing(CanvasOutput(PBarEx()\CanvasNum))
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, dpiX(GadgetWidth(PBarEx()\CanvasNum)), dpiY(GadgetHeight(PBarEx()\CanvasNum)), PBarEx()\Color\Back)
      ;}
      
      ;{ _____ ProgressBar _____
      If PBarEx()\State < PBarEx()\Minimum : PBarEx()\State = PBarEx()\Minimum : EndIf
      If PBarEx()\State > PBarEx()\Maximum : PBarEx()\State = PBarEx()\Maximum : EndIf
      
      If PBarEx()\Flags & #Vertical
        Width = PBarEx()\Size\Height
      Else
        Width = PBarEx()\Size\Width
      EndIf
      
      If PBarEx()\State >= PBarEx()\Minimum
        
        ;{ Draw Progressbar 
        If PBarEx()\State = PBarEx()\Maximum
          Progress = Width
        Else
          Factor = Width / (PBarEx()\Maximum - PBarEx()\Minimum)
          Progress = (PBarEx()\State - PBarEx()\Minimum) * Factor
        EndIf
        
        If PBarEx()\Color\Gradient = #PB_Default
          
          DrawingMode(#PB_2DDrawing_Default)
          
          If PBarEx()\Flags & #Vertical
            Box(0, PBarEx()\Size\Height - Progress, PBarEx()\Size\Width, Progress,  PBarEx()\Color\ProgressBar)
          Else
            Box(0, 0, Progress, PBarEx()\Size\Height, PBarEx()\Color\ProgressBar)
          EndIf
          
        Else
         
          DrawingMode(#PB_2DDrawing_Gradient)
          FrontColor(PBarEx()\Color\Gradient)
          BackColor(PBarEx()\Color\ProgressBar)
          
          If PBarEx()\Flags & #Vertical
            LinearGradient(0, PBarEx()\Size\Height - Progress, PBarEx()\Size\Width, Progress)
            Box(0, PBarEx()\Size\Height - Progress, PBarEx()\Size\Width, Progress)
          Else
            LinearGradient(0, 0, Progress, PBarEx()\Size\Height)
            Box(0, 0, Progress, PBarEx()\Size\Height)
          EndIf
        
        EndIf ;}
        
        PBarEx()\Percent = ((PBarEx()\State - PBarEx()\Minimum) * 100) /  (PBarEx()\Maximum - PBarEx()\Minimum)
        Percent$ = Str(PBarEx()\Percent) + "%"
        
        If PBarEx()\Text                     ;{ Show text
          
          DrawingFont(PBarEx()\FontID)
          
          Text$ = ReplaceString(PBarEx()\Text, #Progress$, Percent$)
          
          txtWidth  = TextWidth(Text$)
          txtHeight = TextHeight(Text$)
          
          If PBarEx()\Flags & #Vertical
            
            txtX = (PBarEx()\Size\Width - txtHeight) / 2

            If PBarEx()\Align = #Center
              txtY = PBarEx()\Size\Height - ((PBarEx()\Size\Height - txtWidth) / 2)
            ElseIf PBarEx()\Align = #Right
              txtY = txtWidth + (txtHeight / 2) + dpiY(2)
            Else
              txtY = PBarEx()\Size\Height - dpiY(5)
            EndIf
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawRotatedText(txtX, txtY, Text$, 90, PBarEx()\Color\Front)

          Else
            
            txtY = (PBarEx()\Size\Height - txtHeight) / 2

            If PBarEx()\Align = #Center
              txtX = (PBarEx()\Size\Width - txtWidth) / 2
            ElseIf PBarEx()\Align = #Right
              txtX = PBarEx()\Size\Width - txtWidth - dpiX(5)
            Else
              txtX = dpiX(5)
            EndIf
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(txtX, txtY, Text$, PBarEx()\Color\Front)
            
          EndIf
          
          ;}
        ElseIf PBarEx()\Flags & #ShowPercent ;{ Show percentage
          
          DrawingFont(PBarEx()\FontID)

          txtWidth  = TextWidth(Percent$)
          txtHeight = TextHeight(Percent$)
          
          If PBarEx()\Flags & #Vertical
            
            txtX = (PBarEx()\Size\Width - txtWidth) / 2
            txtY = PBarEx()\Size\Height - Progress + dpiX(3)
 
            If txtY + txtHeight + dpiX(3) > PBarEx()\Size\Height : txtY = PBarEx()\Size\Height - txtHeight - dpiX(3) : EndIf 
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(txtX, txtY, Percent$, PBarEx()\Color\Front)
            
          Else
            
            txtY = (PBarEx()\Size\Height - txtHeight) / 2
            txtX = Progress - txtWidth - dpiX(5)
            
            If txtX < dpiX(5) : txtX = dpiX(5) : EndIf
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(txtX, txtY, Percent$, PBarEx()\Color\Front)

          EndIf  
          ;}
        EndIf
        
      EndIf ;}
    
      ;{ _____ Border _____
      If PBarEx()\Flags & #Border
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0, 0, dpiX(GadgetWidth(PBarEx()\CanvasNum)), dpiY(GadgetHeight(PBarEx()\CanvasNum)), PBarEx()\Color\Border)
      EndIf ;}
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  ;- __________ Events __________
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(PBarEx(), Str(GadgetID))
      
      PBarEx()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      PBarEx()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach PBarEx()
      
      If IsGadget(PBarEx()\CanvasNum)
        
        If PBarEx()\Flags & #AutoResize
          
          If IsWindow(PBarEx()\WindowNum)
            
            OffSetX = WindowWidth(PBarEx()\WindowNum)  - PBarEx()\Size\winWidth
            OffsetY = WindowHeight(PBarEx()\WindowNum) - PBarEx()\Size\winHeight

            PBarEx()\Size\winWidth  = WindowWidth(PBarEx()\WindowNum)
            PBarEx()\Size\winHeight = WindowHeight(PBarEx()\WindowNum)
            
            If PBarEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If PBarEx()\Size\Flags & #MoveX : X = GadgetX(PBarEx()\CanvasNum) + OffSetX : EndIf
              If PBarEx()\Size\Flags & #MoveY : Y = GadgetY(PBarEx()\CanvasNum) + OffSetY : EndIf
              If PBarEx()\Size\Flags & #Width  : Width  = GadgetWidth(PBarEx()\CanvasNum)  + OffSetX : EndIf
              If PBarEx()\Size\Flags & #Height : Height = GadgetHeight(PBarEx()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(PBarEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(PBarEx()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(PBarEx()\CanvasNum) + OffSetX, GadgetHeight(PBarEx()\CanvasNum) + OffsetY)
            EndIf
          
            Draw_()
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================  
  

  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Minimum.i=0, Maximum.i=100, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i txtNum, Result
    
    Result = CanvasGadget(GNum, X, Y, Width, Height)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(PBarEx(), Str(GNum))
        
        PBarEx()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default
            PBarEx()\WindowNum = ModuleEx::GetGadgetWindow()
          Else
            PBarEx()\WindowNum = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            PBarEx()\WindowNum = GetActiveWindow()
          Else
            PBarEx()\WindowNum = WindowNum
          EndIf
        CompilerEndIf   
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If ModuleEx::AddWindow(PBarEx()\WindowNum, ModuleEx::#Tabulator)
            ModuleEx::AddGadget(GNum, PBarEx()\WindowNum, ModuleEx::#IgnoreTabulator)
          EndIf
        CompilerEndIf
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            PBarEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              PBarEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            PBarEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        PBarEx()\Size\X = X
        PBarEx()\Size\Y = Y
        PBarEx()\Size\Width  = Width
        PBarEx()\Size\Height = Height
        
        PBarEx()\Color\Front       = $000000
        PBarEx()\Color\Back        = $E3E3E3
        PBarEx()\Color\ProgressBar = $32CD32
        PBarEx()\Color\Gradient    = $00FC7C
        PBarEx()\Color\Border      = $A0A0A0
        
        CompilerSelect #PB_Compiler_OS ;{ window background color (if possible)
          CompilerCase #PB_OS_Windows
            PBarEx()\Color\Back      = GetSysColor_(#COLOR_3DLIGHT)
            PBarEx()\Color\Border    = GetSysColor_(#COLOR_3DSHADOW)
          CompilerCase #PB_OS_MacOS
            PBarEx()\Color\Back      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            PBarEx()\Color\Border    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux
  
        CompilerEndSelect ;}
        
        PBarEx()\Minimum = Minimum
        PBarEx()\Maximum = Maximum
        PBarEx()\Flags   = Flags
        
        BindGadgetEvent(PBarEx()\CanvasNum,  @_ResizeHandler(), #PB_EventType_Resize)
        
        If Flags & #AutoResize
          If IsWindow(WindowNum)
            PBarEx()\Size\winWidth  = WindowWidth(WindowNum)
            PBarEx()\Size\winHeight = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf  
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      
      Select Attribute
        Case #Minimum
          ProcedureReturn PBarEx()\Minimum
        Case #Maximum
          ProcedureReturn PBarEx()\Maximum 
        Case #Percent
          ProcedureReturn PBarEx()\Percent
      EndSelect
      
    EndIf  
    
  EndProcedure
  
  Procedure.i GetState(GNum.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      ProcedureReturn PBarEx()\State
    EndIf  
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      
      PBarEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      
      Select Attribute
        Case #Minimum
          PBarEx()\Minimum = Value
        Case #Maximum
          PBarEx()\Maximum = Value 
      EndSelect
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          PBarEx()\Color\Front       = Color
        Case #BackColor
          PBarEx()\Color\Back        = Color
        Case #ProgressBarColor
          PBarEx()\Color\ProgressBar = Color
        Case #GradientColor
          PBarEx()\Color\Gradient    = Color
        Case #BorderColor
          PBarEx()\Color\Border      = Color
      EndSelect
      
      Draw_()
      
    EndIf 
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontNum.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      
      If IsFont(FontNum)
        PBarEx()\FontID = FontID(FontNum)
        Draw_()
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetState(GNum.i, Value.i)
    
    If FindMapElement(PBarEx(), Str(GNum))
      PBarEx()\State = Value
      Draw_()
    EndIf  
    
  EndProcedure
  
  Procedure   SetText(GNum.i, Text.s, Align.i=#Left)
    
    If FindMapElement(PBarEx(), Str(GNum))
      
      PBarEx()\Text  = Text
      PBarEx()\Align = Align
      
      Draw_()
    EndIf  
    
  EndProcedure
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window = 0
  #PBar = 1
  #SG   = 2
  #BT   = 3
  
  If OpenWindow(#Window, 0, 0, 180, 75, "Example", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    ProgressEx::Gadget(#PBar, 10, 10, 160, 25, 0, 100, ProgressEx::#Border|ProgressEx::#ShowPercent|ProgressEx::#AutoResize, #Window)
    ProgressEx::SetAutoResizeFlags(#PBar, ProgressEx::#Width)
    ;ProgressEx::Gadget(#PBar, 100, 10, 30, 60, 0, 100, ProgressEx::#Border|ProgressEx::#Vertical|ProgressEx::#ShowPercent)
    ;ProgressEx::SetAutoResizeFlags(#PBar, ProgressEx::#Height)
    
    ProgressEx::SetState(#PBar, 60)

    ProgressEx::SetColor(#PBar, ProgressEx::#FrontColor, $FFFFFF)
    ProgressEx::SetColor(#PBar, ProgressEx::#ProgressBarColor, $8B0000)
    ProgressEx::SetColor(#PBar, ProgressEx::#GradientColor,    $E16941)
    ;ProgressEx::SetColor(#PBar, ProgressEx::#GradientColor, #PB_Default) ; Disable gradient color
    
    ;ProgressEx::SetText(#PBar, "ProgressBarEx.pbi (" + ProgressEx::#Progress$ + ")")
    
    StringGadget(#SG, 10, 45, 30, 20, "", #PB_String_Numeric)
    ButtonGadget(#BT, 45, 44, 30, 22, "Set")
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #BT
              State = Val(GetGadgetText(#SG))
              ProgressEx::SetState(#PBar, State)
          EndSelect
      EndSelect
    Until Event = #PB_Event_CloseWindow
    
  EndIf
  
CompilerEndIf  
