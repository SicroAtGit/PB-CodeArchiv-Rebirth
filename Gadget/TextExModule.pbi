;   Description: Extented TextGadget (e.g. gradient background / multiline / automatic size adjustment) 
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72419
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31335
; -----------------------------------------------------------------------------

;/ ===========================
;/ =    TextEx-Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Extented TextGadget (e.g. gradient background / multiline / automatic size adjustment) 
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; Last Update: 12.6.2019

; - Added: Default font

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


;{ _____TextEx - Commands _____

; TextEx::Gadget()             - similar to 'TextGadget()'
; TextEx::GetColor()           - similar to 'GetGadgetColor()'
; TextEx::GetText()            - similar to 'GetGadgetText()'
; TextEx::SetColor()           - similar to 'SetGadgetColor()'
; TextEx::SetFont()            - similar to 'SetGadgetFont()'
; TextEx::SetText()            - similar to 'SetGadgetText()'
; TextEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]

;}



DeclareModule TextEx
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  #Left = 0
  
  EnumerationBinary
    #Center = #PB_Text_Center
    #Right  = #PB_Text_Right
    #Gradient
    #AutoResize
    #MultiLine
    #Border = #PB_Text_Border
  EndEnumeration
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration  
  
  Enumeration 1
    #FrontColor
    #BackColor
    #GradientColor
    #BorderColor
  EndEnumeration
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.s GetText(GNum.i)
  Declare   SetColor(GNum.i, ColorType.i, Value.i)
  Declare   SetFont(GNum.i, FontID.i)
  Declare   SetText(GNum.i, Text.s)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  
EndDeclareModule



Module TextEx
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants / Structures
  ;- ============================================================================  
  
  Structure TextEx_Window_Structure  ;{ TextEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure TextEx_Size_Structure  ;{ TextEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    winWidth.f
    winHeight.f
    Flags.i
  EndStructure ;} 
  
  Structure TextEx_Color_Structure ;{ TextEx()\Color\...
    Front.i
    Back.i
    Gradient.i
    Border.i
  EndStructure  ;}
  
  Structure TextEx_Structure       ;{ TextEx()\...
    WindowNum.i
    CanvasNum.i
    FontID.i
    
    Text.s
    Flags.i
    
    Color.TextEx_Color_Structure
    Size.TextEx_Size_Structure
    Window.TextEx_Window_Structure
    
  EndStructure ;}
  Global NewMap TextEx.TextEx_Structure()
  
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
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure.f GetOffsetX_(Text.s, OffsetX.f) 
    
    If TextEx()\Flags & #Center
      ProcedureReturn (TextEx()\Size\Width - TextWidth(Text)) / 2
    ElseIf TextEx()\Flags & #Right
      ProcedureReturn TextEx()\Size\Width - TextWidth(Text) - OffsetX
    Else
      ProcedureReturn OffsetX
    EndIf
 
  EndProcedure  
  
  Procedure Draw_()
    Define.f textY, textX, OffsetX
    Define.i TextHeight, Rows, r
    Define.s Text
    
    If StartDrawing(CanvasOutput(TextEx()\CanvasNum))
      
      ;{ _____ Background _____
      If TextEx()\Flags & #Gradient
        DrawingMode(#PB_2DDrawing_Gradient)
        FrontColor(TextEx()\Color\Back)
        BackColor(TextEx()\Color\Gradient)
        LinearGradient(0, 0, TextEx()\Size\Width, TextEx()\Size\Height)
        Box(0, 0, TextEx()\Size\Width, TextEx()\Size\Height)
        OffsetX = dpiX(5)
      Else
        DrawingMode(#PB_2DDrawing_Default)
        Box(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, TextEx()\Color\Back)
      EndIf ;}
      
      ;{ _____ Text _____
      If TextEx()\FontID : DrawingFont(TextEx()\FontID) : EndIf
      
      TextHeight = TextHeight(TextEx()\Text)
      
      DrawingMode(#PB_2DDrawing_Transparent)
      
      If TextEx()\Flags & #MultiLine
        
        Rows = CountString(TextEx()\Text, #LF$) + 1
        
        textY = (TextEx()\Size\Height - (TextHeight * Rows)) / 2
        
        For r = 1 To Rows
          Text  = StringField(TextEx()\Text, r, #LF$)
          textX = GetOffsetX_(Text, OffsetX)
          DrawText(textX, textY, Text, TextEx()\Color\Front)
          textY + TextHeight
        Next
        
      Else
        
        textY = (TextEx()\Size\Height - TextHeight) / 2
        textX = GetOffsetX_(TextEx()\Text, OffsetX) 
        
        DrawText(textX, textY, TextEx()\Text, TextEx()\Color\Front)
        
      EndIf ;}
      
      ;{ _____ Border ____
      If TextEx()\Flags & #Border
        DrawingMode(#PB_2DDrawing_Outlined)
        
        If TextEx()\Color\Border = #PB_Default
          If TextEx()\Flags & #Gradient
            Box(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, BlendColor_(TextEx()\Color\Back, TextEx()\Color\Gradient, 20))
          Else
            Box(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, BlendColor_(TextEx()\Color\Back, TextEx()\Color\Front))
          EndIf
        Else
          Box(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, TextEx()\Color\Border)
        EndIf
        
      EndIf ;}
      
      StopDrawing()
    EndIf  

  EndProcedure 
  
  ;- __________ Events __________
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(TextEx(), Str(GadgetID))
      
      TextEx()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      TextEx()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach TextEx()
      
      If IsGadget(TextEx()\CanvasNum)
        
        If TextEx()\Flags & #AutoResize
          
          If IsWindow(TextEx()\Window\Num)
            
            OffSetX = WindowWidth(TextEx()\Window\Num)  - TextEx()\Window\Width
            OffsetY = WindowHeight(TextEx()\Window\Num) - TextEx()\Window\Height

            TextEx()\Window\Width  = WindowWidth(TextEx()\Window\Num)
            TextEx()\Window\Height = WindowHeight(TextEx()\Window\Num)
            
            If TextEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If TextEx()\Size\Flags & #MoveX : X = GadgetX(TextEx()\CanvasNum) + OffSetX : EndIf
              If TextEx()\Size\Flags & #MoveY : Y = GadgetY(TextEx()\CanvasNum) + OffSetY : EndIf
              If TextEx()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(TextEx()\CanvasNum)  + OffSetX : EndIf
              If TextEx()\Size\Flags & #ResizeHeight : Height = GadgetHeight(TextEx()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(TextEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(TextEx()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(TextEx()\CanvasNum) + OffSetX, GadgetHeight(TextEx()\CanvasNum) + OffsetY)
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
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      TextEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          TextEx()\Color\Front    = Color
        Case #BackColor
          TextEx()\Color\Back     = Color
        Case #BorderColor
          TextEx()\Color\Border   = Color
        Case #GradientColor
          TextEx()\Color\Gradient = Color
      EndSelect
      
      Draw_()
    EndIf  

  EndProcedure
  
  Procedure.i GetColor(GNum.i, ColorType.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn TextEx()\Color\Front
        Case #BackColor
          ProcedureReturn TextEx()\Color\Back
        Case #BorderColor
          ProcedureReturn TextEx()\Color\Border
        Case #GradientColor
          ProcedureReturn TextEx()\Color\Gradient
      EndSelect
      
    EndIf  

  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      TextEx()\FontID = FontID
      
      Draw_()
    EndIf  
    
  EndProcedure
  
  Procedure   SetText(GNum.i, Text.s)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      TextEx()\Text = Text
      
      Draw_()
    EndIf  
    
  EndProcedure
  
  Procedure.s GetText(GNum.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      ProcedureReturn TextEx()\Text

    EndIf  
    
  EndProcedure
  
  Procedure   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum
    
    Result = CanvasGadget(GNum, X, Y, Width, Height)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(TextEx(), Str(GNum))
        
        TextEx()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default
            TextEx()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            TextEx()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            TextEx()\Window\Num = GetActiveWindow()
          Else
            TextEx()\Window\Num = WindowNum
          EndIf
        CompilerEndIf   
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If ModuleEx::AddWindow(TextEx()\Window\Num, ModuleEx::#Tabulator)
            ModuleEx::AddGadget(GNum, TextEx()\Window\Num, ModuleEx::#IgnoreTabulator)
          EndIf
        CompilerEndIf
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            TextEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              TextEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            TextEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        TextEx()\Size\X = X
        TextEx()\Size\Y = Y
        TextEx()\Size\Width  = Width
        TextEx()\Size\Height = Height
        
        TextEx()\Text = Text
        
        TextEx()\Color\Front    = $000000
        TextEx()\Color\Back     = $EDEDED
        TextEx()\Color\Gradient = $C0C0C0
        TextEx()\Color\Border   = #PB_Default
        
        CompilerSelect #PB_Compiler_OS ;{ window background color (if possible)
          CompilerCase #PB_OS_Windows
            TextEx()\Color\Front = GetSysColor_(#COLOR_WINDOWTEXT)
            TextEx()\Color\Back  = GetSysColor_(#COLOR_MENU)
          CompilerCase #PB_OS_MacOS
            TextEx()\Color\Front = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            TextEx()\Color\Back  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
          CompilerCase #PB_OS_Linux
            
        CompilerEndSelect ;}
        
        TextEx()\Flags  = Flags
        
        BindGadgetEvent(TextEx()\CanvasNum,  @_ResizeHandler(), #PB_EventType_Resize)
        
        If Flags & #AutoResize
          If IsWindow(WindowNum)
            TextEx()\Window\Width  = WindowWidth(WindowNum)
            TextEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf  
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure 
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window = 0
  #Text = 1
  #Font = 1
  
  LoadFont(#Font, "Arial", 11, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 180, 60, "Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
    
    TextEx::Gadget(#Text, 5, 5, 170, 50, "Gradient Background", TextEx::#Center|TextEx::#Border|TextEx::#Gradient|TextEx::#AutoResize|TextEx::#MultiLine, #Window)
    
    TextEx::SetColor(#Text, TextEx::#FrontColor,    $FFFFFF)
    TextEx::SetColor(#Text, TextEx::#BackColor,     $DEC4B0)
    TextEx::SetColor(#Text, TextEx::#GradientColor, $783C0A)
    
    TextEx::SetFont(#Text, FontID(#Font))
    ;TextEx::SetText(#Text, "Row 1" + #LF$ + "Row 2")
    
    ;TextEx::SetAutoResizeFlags(#Text, TextEx::#MoveY|TextEx::#ResizeWidth)
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  EndIf
CompilerEndIf
