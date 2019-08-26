;   Description: Extented String Gadget (CanvasGadget)
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72534
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31372
; -----------------------------------------------------------------------------

;/ ============================
;/ =    StringExModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2019 Thorsten1867 (03/2019)
;/

; Last Update: 18.08.2019
;
; - Bugfixes: Cursor


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


;{ _____ StringEx - Commands _____


; StringEx::AddButton()          - adds a button to the gadget
; StringEx::AddWords()           - add words to the autocomplete list
; StringEx::AttachPopupMenu()    - attach a popup menu to the gadget
; StringEx::Clear()              - clear gadget
; StringEx::Copy()               - copy selection to clipboard
; StringEx::Cut()                - cut selection to clipboard
; StringEx::Delete()             - delete selection
; StringEx::Free()               - similar To 'FreeGadget()'
; StringEx::GetAttribute()       - similar to 'GetGadgetAttribute()'
; StringEx::GetColor()           - similar to 'GetGadgetColor()'
; StringEx::GetText()            - similar to 'GetGadgetText()'
; StringEx::Gadget()             - similar to 'StringGadget()'
; StringEx::Paste()              - paste clipboard
; StringEx::RemoveFlag()         - removes a flag
; StringEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; StringEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]
; StringEx::SetColor()           - similar to 'SetGadgetColor()'
; StringEx::SetFlags()           - sets one or more flags
; StringEx::SetText()            - similar to 'SetGadgetText()'
; StringEx::Undo()               - undo last input

;}


;XIncludeFile "ModuleEx.pbi"

DeclareModule StringEx
  
  #Enable_AutoComplete = #True
  #Enable_ShowPasswordButton = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  EnumerationBinary Flags
    #UpperCase     = #PB_String_UpperCase
    #LowerCase     = #PB_String_LowerCase
    #Password      = #PB_String_Password
    #NotEditable   = #PB_String_ReadOnly
    #Numeric       = #PB_String_Numeric
    #Borderless    = #PB_String_BorderLess
    #AutoComplete
    #AutoResize
    #ShowButton
    #EventButton
    #Left
    #Right
    #Center
  EndEnumeration
  
  Enumeration Attribute 1
    #MaximumLength = #PB_String_MaximumLength
    #Padding
  EndEnumeration
  
  Enumeration Color 1 
    #FrontColor  = #PB_Gadget_FrontColor
    #BackColor   = #PB_Gadget_BackColor
    #BorderColor = #PB_Gadget_LineColor
    #FocusColor
    #CursorColor
    #HighlightColor
    #HighlightTextColor
  EndEnumeration
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration  
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Cursor       = ModuleEx::#Event_Cursor
    #Event_Gadget       = ModuleEx::#Event_Gadget
    #EventType_Button   = ModuleEx::#EventType_Button
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Cursor
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Button
    EndEnumeration
    
  CompilerEndIf

  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  CompilerIf #Enable_AutoComplete
    
    Declare   AddWords(GNum.i, String.s, NoCase.i=#False, Seperator.s=" ")
    Declare   ClearWords(GNum.i)
    
  CompilerEndIf
  
  Declare   AddButton(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Event.i=#PB_Default)
  Declare   AttachPopupMenu(GNum.i, MenuNum.i)
  Declare   Clear(GNum.i)
  Declare   Copy(GNum.i)
  Declare   Cut(GNum.i)
  Declare   Delete(GNum.i)
  Declare   Free(GNum.i)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.s GetText(GNum.i) 
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare   Paste(GNum.i)
  Declare   RemoveFlag(GNum.i, Flag.i)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i) 
  Declare   SetFlags(GNum.i, Flags.i)
  Declare   SetText(GNum.i, Text.s) 
  Declare   Undo(GNum.i)
  
EndDeclareModule

Module StringEx
  
  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================
  
  #CursorFrequency = 600
  #ButtonWidth = 22
  
  EnumerationBinary State
    #Focus
    #Edit
    #Click
  EndEnumeration
  
  Enumeration Mouse
    #Mouse_Move
    #Mouse_Select
  EndEnumeration 
  
  Enumeration Selection
    #NoSelection
    #Selected
  EndEnumeration
  
  #Cursor = 1
  
  CompilerIf #PB_Compiler_Unicode
    #PWChar = Chr($25CF)
  CompilerElse
    #PWChar = "*"
  CompilerEndIf
  
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure Cursor_Thread_Structure  ;{
    Num.i
    Active.i
    Exit.i
  EndStructure ;}
  
  Structure StrgEx_Words_Structure   ;{ StrgEx()\AutoComplete\...
    Word.s
    NoCase.i
  EndStructure ;}
  
  Structure Selection_Structure      ;{ StrgEx()\Selection\
    Pos1.i
    Pos2.i
    Flag.i
  EndStructure ;}
  
  Structure StrgEx_Button_Structure  ;{ StrgEx()\Button\...
    X.f
    State.i
    ImgNum.i
    Width.f
    Height.f
    Event.i
  EndStructure ;}  
  
  Structure StrgEx_Cursor_Structure  ;{ StrgEx()\Cursor\...
    Pos.i ; 0: "|abc" / 1: "a|bc" / 2: "ab|c"  / 3: "abc|"
    X.i
    Y.i
    Height.i
    State.i
    Frequency.i
    Elapsed.i
    Thread.i
    Pause.i
  EndStructure ;}
  
  Structure StrgEx_Color_Structure   ;{ StrgEx()\Color\...
    Front.i
    Back.i
    Focus.i
    Border.i
    Cursor.i
    Highlight.i
    HighlightText.i
    Button.i
    WordColor.i
  EndStructure ;}
  
  Structure StrgEx_Size_Structure    ;{ StrgEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Flags.i
  EndStructure ;} 
  
  Structure StrgEx_Window_Structure  ;{ StrgEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure StrgEx_Structure         ;{ StrgEx()\...
    CanvasNum.i
    PopupNum.i
    
    Thread.i
    ;Signal.i
    
    FontID.i
    State.i
    Flags.i
    Text.s
    Undo.s
    CanvasCursor.i
    Mouse.i
    MaxLength.i
    Padding.i
    
    Button.StrgEx_Button_Structure
    Color.StrgEx_Color_Structure
    Cursor.StrgEx_Cursor_Structure
    Selection.Selection_Structure
    Size.StrgEx_Size_Structure
    Window.StrgEx_Window_Structure
    
    List AutoComplete.StrgEx_Words_Structure()
  EndStructure ;}
  Global NewMap StrgEx.StrgEx_Structure()

  Global Thread.Cursor_Thread_Structure
  
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
  
  
  CompilerIf #Enable_AutoComplete
    
    Procedure.i SelectAutoCompleteWord_()
      Define.s WordPart$
      
      ForEach StrgEx()\AutoComplete()
        
        WordPart$ = Left(StrgEx()\AutoComplete()\Word, Len(StrgEx()\Text))
        
        If StrgEx()\AutoComplete()\NoCase
  
          If LCase(WordPart$) = LCase(StrgEx()\Text)
            ProcedureReturn #True
          EndIf
          
        Else
          
          If WordPart$ = StrgEx()\Text
            ProcedureReturn #True
          EndIf
          
        EndIf
        
      Next
     
      ResetList(StrgEx()\AutoComplete())
      
    EndProcedure
    
  CompilerEndIf  
  
  
  Procedure.i IsNumber(Char.i)
    Select Char
      Case 48 To 57
        ProcedureReturn #True
      Case 43, 45
        ProcedureReturn #True
    EndSelect
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s DeleteStringPart_(String.s, Position.i, Length.i=1) ; Delete string part at Position (with Length)
    
    If Position <= 0 : Position = 1 : EndIf
    If Position > Len(String) : Position = Len(String) : EndIf
    
    ProcedureReturn Left(String, Position - 1) + Mid(String, Position + Length)
  EndProcedure
  
  Procedure.s StringSegment_(String.s, Pos1.i, Pos2.i=#PB_Ignore) ; Return String from Pos1 to Pos2 
    Define.i Length = Pos2 - Pos1
    If Pos2 = #PB_Ignore
      ProcedureReturn Mid(String, Pos1, Len(String) - Pos1 + 1)
    Else
      ProcedureReturn Mid(String, Pos1, Pos2 - Pos1 + 1)
    EndIf
  EndProcedure 
  
  
  Procedure   RemoveSelection_()                                  ; Remove & Reset selection 
    StrgEx()\Selection\Pos1 = #False
    StrgEx()\Selection\Pos2 = #False
    StrgEx()\Selection\Flag = #NoSelection
  EndProcedure
  
  Procedure   DeleteSelection_() 
    
    If StrgEx()\Selection\Flag = #Selected
      
      StrgEx()\Undo = StrgEx()\Text
      
      If StrgEx()\Selection\Pos1 > StrgEx()\Selection\Pos2
        StrgEx()\Text = Left(StrgEx()\Text, StrgEx()\Selection\Pos2) + Mid(StrgEx()\Text, StrgEx()\Selection\Pos1 + 1)
        StrgEx()\Cursor\Pos = StrgEx()\Selection\Pos2
      Else
        StrgEx()\Text = Left(StrgEx()\Text, StrgEx()\Selection\Pos1) + Mid(StrgEx()\Text, StrgEx()\Selection\Pos2 + 1)
        StrgEx()\Cursor\Pos = StrgEx()\Selection\Pos1
      EndIf  
      
      RemoveSelection_() 
    EndIf
    
  EndProcedure
  
  
  Procedure   Copy_()
    Define.s Text
    
    StrgEx()\Undo = StrgEx()\Text
    
    If StrgEx()\Selection\Pos1 > StrgEx()\Selection\Pos2
      Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos2 + 1, StrgEx()\Selection\Pos1)
    Else
      Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos1 + 1, StrgEx()\Selection\Pos2)
    EndIf
    
    SetClipboardText(Text)
    RemoveSelection_()
    
  EndProcedure
  
  Procedure   Cut_()
    Define.s Text
    
    If Not StrgEx()\Flags & #NotEditable
      
      StrgEx()\Undo = StrgEx()\Text
      
      If StrgEx()\Selection\Pos1 > StrgEx()\Selection\Pos2
        Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos2 + 1, StrgEx()\Selection\Pos1)
      Else
        Text = StringSegment_(StrgEx()\Text, StrgEx()\Selection\Pos1 + 1, StrgEx()\Selection\Pos2)
      EndIf
        
      SetClipboardText(Text)
      DeleteSelection_()
      RemoveSelection_()
      
    EndIf

  EndProcedure
  
  Procedure   Paste_()
    Define.i c
    Define.s Text, Num, Char
    
    If Not StrgEx()\Flags & #NotEditable
      
      StrgEx()\Undo = StrgEx()\Text
      
      Text = GetClipboardText()
      
      If StrgEx()\Flags & #Numeric ;{ Numbers
        For c=1 To Len(Text)
          Char = Mid(Text, c, 1)
          If IsNumber(Asc(Char)) : Num + Char : EndIf
        Next
        Text = Num ;}
      EndIf
      
      If StrgEx()\Flags & #UpperCase : Text = UCase(Text) : EndIf
      If StrgEx()\Flags & #LowerCase : Text = LCase(Text) : EndIf
      
      If StrgEx()\Selection\Flag = #Selected
        DeleteSelection_()
        RemoveSelection_()
      EndIf
      
      StrgEx()\Text = InsertString(StrgEx()\Text, Text, StrgEx()\Cursor\Pos + 1)
      StrgEx()\Cursor\Pos + Len(Text)
      
      CompilerIf #Enable_AutoComplete
        
        If StrgEx()\Flags & #AutoComplete
          SelectAutoCompleteWord_()
        EndIf
        
      CompilerEndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   Undo_()
    Define.s Text
    
    Text = StrgEx()\Text
    StrgEx()\Text = StrgEx()\Undo
    StrgEx()\Undo = Text
    
  EndProcedure
  
  
  Procedure.i CursorPos_(CursorX.i)
    Define.s Text
    Define.i p, Pos.i
    
    If CursorX > dpiX(4)
      
      Text = StrgEx()\Text
      If StrgEx()\Flags & #Password And StrgEx()\Button\State & #Click = #False
        Text = LSet("", Len(StrgEx()\Text), #PWChar)
      Else
        Text = StrgEx()\Text
      EndIf
      
      If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
        DrawingFont(StrgEx()\FontID)
        For p=1 To Len(Text)
          If TextWidth(Left(Text, p)) >= CursorX
            Break
          EndIf
          Pos = p
        Next
        StopDrawing()
      EndIf
      
      ProcedureReturn Pos
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure.f CursorX_(CursorPos.i) ; [ Needs StartDrawing() ]
    ; Pos 0: '|abc' / Pos1: 'a|bc'
    Define.s Text
    
    Text = StrgEx()\Text
    If StrgEx()\Flags & #Password And StrgEx()\Button\State & #Click = #False
      Text = LSet("", Len(StrgEx()\Text), #PWChar)
    Else
      Text = StrgEx()\Text
    EndIf
    
    If CursorPos > 0
      ProcedureReturn TextWidth(Left(Text, CursorPos)) + dpiX(4)
    Else
      ProcedureReturn dpiX(4)
    EndIf
    
  EndProcedure
  
  
  Procedure.i GetWordStart_(Pos.i) 
    Define.i p
    
    For p = Pos To 0 Step -1
      If Mid(StrgEx()\Text, p, 1) = " "
        ProcedureReturn p
      EndIf
    Next
    
    ProcedureReturn 0
  EndProcedure  
  
  Procedure.i GetWordEnd_(Pos.i) 
    Define.i p
    
    For p = Pos To Len(StrgEx()\Text)
      If Mid(StrgEx()\Text, p, 1) = " "
        ProcedureReturn p - 1
      EndIf
    Next
    
    ProcedureReturn Len(StrgEx()\Text)
  EndProcedure
 
  ;- __________ Drawing __________
  
  Procedure.f GetOffsetX_(Text.s, Width.i, OffsetX.i) 
    
    If StrgEx()\Flags & #Center
      ProcedureReturn (Width - TextWidth(Text)) / 2
    ElseIf StrgEx()\Flags & #Right
      ProcedureReturn Width - TextWidth(Text) - OffsetX
    Else
      ProcedureReturn OffsetX
    EndIf
 
  EndProcedure
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure   Button_(BorderColor.i)
    Define.f X, Y
    
    StrgEx()\Button\X = dpiX(GadgetWidth(StrgEx()\CanvasNum) - #ButtonWidth)
    
    If StrgEx()\Button\State & #Click
      DrawingMode(#PB_2DDrawing_Default)
      Box(StrgEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(StrgEx()\CanvasNum)), BlendColor_(StrgEx()\Color\Focus, $FFFFFF, 20))
    ElseIf StrgEx()\Button\State & #Focus
      DrawingMode(#PB_2DDrawing_Default)
      Box(StrgEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(StrgEx()\CanvasNum)), BlendColor_(StrgEx()\Color\Focus, $FFFFFF, 10))
    Else
      DrawingMode(#PB_2DDrawing_Default)
      Box(StrgEx()\Button\X, 0, dpiX(#ButtonWidth), dpiY(GadgetHeight(StrgEx()\CanvasNum)), StrgEx()\Color\Button)
    EndIf 
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(StrgEx()\Button\X, 0, dpiX(#ButtonWidth + 1), dpiY(GadgetHeight(StrgEx()\CanvasNum)), BorderColor)
    
    If IsImage(StrgEx()\Button\ImgNum)
      X = StrgEx()\Button\X + ((dpiX(#ButtonWidth) - StrgEx()\Button\Width)  / 2)
      Y = (dpiY(GadgetHeight(StrgEx()\CanvasNum))  - StrgEx()\Button\Height) / 2
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      If IsImage(StrgEx()\Button\ImgNum)
        DrawImage(ImageID(StrgEx()\Button\ImgNum), X, Y, StrgEx()\Button\Width, StrgEx()\Button\Height)
      EndIf  
    EndIf
    
  EndProcedure

  Procedure   Draw_(GNum.i)
    Define.f X, Y, Height, Width, startX
    Define.s Text, Word, strgPart
    Define.i TextColor, BackColor, BorderColor
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If StrgEx()\MaxLength <> #PB_Default
        If Len(StrgEx()\Text) > StrgEx()\MaxLength
          StrgEx()\Text = Left(StrgEx()\Text, StrgEx()\MaxLength)
        EndIf
      EndIf
      
      If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
        
        BackColor   = StrgEx()\Color\Back
        BorderColor = StrgEx()\Color\Border
        TextColor   = StrgEx()\Color\Front
        
        If StrgEx()\State & #Focus
          BorderColor = StrgEx()\Color\Focus
        EndIf
        
        Height = dpiY(GadgetHeight(StrgEx()\CanvasNum))
        Width  = dpiX(GadgetWidth(StrgEx()\CanvasNum))

        ;{ _____ Background _____
        DrawingMode(#PB_2DDrawing_Default)
        Box(0, 0, Width, Height, BackColor)
        ;}
        
        If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton
          Width - dpiX(#ButtonWidth - 1)
        EndIf
        
        DrawingFont(StrgEx()\FontID)

        ;{ _____ Text _____
        If StrgEx()\Text
          Text = StrgEx()\Text
          If StrgEx()\Flags & #Password And StrgEx()\Button\State & #Click = #False
            Text = LSet("", Len(StrgEx()\Text), #PWChar)
          Else
            Text = StrgEx()\Text
          EndIf
          
          X = GetOffsetX_(Text, Width, StrgEx()\Padding)
          Y = (Height - TextHeight(Text)) / 2
          
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(X, Y, Text, StrgEx()\Color\Front)
          
          CompilerIf #Enable_AutoComplete
            
            If StrgEx()\Flags & #AutoComplete And StrgEx()\Flags & #Password = #False
              If ListIndex(StrgEx()\AutoComplete()) <> -1
                Word = Mid(StrgEx()\AutoComplete()\Word, Len(Text) + 1)
                DrawingMode(#PB_2DDrawing_Default)
                DrawText(X + TextWidth(Text) + dpiX(1), Y, Word, StrgEx()\Color\WordColor, BlendColor_(StrgEx()\Color\Highlight, $FFFFFF, 3))
              EndIf
            EndIf
            
          CompilerEndIf
          
        Else
          
          X = StrgEx()\Padding
          Y = (Height - TextHeight("X")) / 2  
          
        EndIf
        ;}
        
        ;{ _____ Selection ______
        If StrgEx()\Selection\Flag = #Selected
          
          If StrgEx()\Selection\Pos1 >  StrgEx()\Selection\Pos2
            startX   = CursorX_(StrgEx()\Selection\Pos2)
            strgPart = StringSegment_(Text, StrgEx()\Selection\Pos2 + 1, StrgEx()\Selection\Pos1)
          Else
            startX   = CursorX_(StrgEx()\Selection\Pos1)
            strgPart = StringSegment_(Text, StrgEx()\Selection\Pos1 + 1, StrgEx()\Selection\Pos2)
          EndIf
          
          StrgEx()\Cursor\Pos = StrgEx()\Selection\Pos2
          
          DrawingMode(#PB_2DDrawing_Default)
          DrawText(startX, Y, strgPart, StrgEx()\Color\HighlightText, StrgEx()\Color\Highlight)
  
        EndIf 
        ;}
        
        ;{ _____ Cursor _____
        If StrgEx()\Cursor\Pos
          X + TextWidth(Left(Text, StrgEx()\Cursor\Pos))
        EndIf
        StrgEx()\Cursor\Height = TextHeight("X")
        StrgEx()\Cursor\X = X
        StrgEx()\Cursor\Y = Y
        ;}
        
        CompilerIf #Enable_ShowPasswordButton
          If StrgEx()\Flags & #ShowButton
            Button_(BorderColor)
          EndIf
        CompilerEndIf
        
        If StrgEx()\Flags & #EventButton
          Button_(BorderColor)
        EndIf
        
        ;{ _____ Border ____
        If StrgEx()\Flags & #Borderless = #False
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0, 0, dpiX(GadgetWidth(StrgEx()\CanvasNum)), Height, BorderColor)
        EndIf
        ;}
        
        StopDrawing()
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  ;- __________ Events __________
  
  Procedure _CursorDrawing() ; Trigger from Thread (PostEvent Change)
    Define.i WindowNum = EventWindow()
    
    ForEach StrgEx()
      
      If StrgEx()\Cursor\Pause = #False

        StrgEx()\Cursor\State ! #True
      
        If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          If StrgEx()\Cursor\State
            Line(StrgEx()\Cursor\X - 1, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, StrgEx()\Color\Cursor)
          Else
            Line(StrgEx()\Cursor\X - 1, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, StrgEx()\Color\Back)
          EndIf
          StopDrawing()
        EndIf
        
      ElseIf StrgEx()\Cursor\State
        
        If StartDrawing(CanvasOutput(StrgEx()\CanvasNum))
          DrawingMode(#PB_2DDrawing_Default)
          Line(StrgEx()\Cursor\X - 1, StrgEx()\Cursor\Y, 1, StrgEx()\Cursor\Height, StrgEx()\Color\Back)
          StopDrawing()
        EndIf
      
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _CursorThread(Frequency.i)
    Define.i ElapsedTime
    
    Repeat
      
      If ElapsedTime >= Frequency
        PostEvent(#Event_Cursor)
        ElapsedTime = 0
      EndIf
      
      Delay(100)
      
      ElapsedTime + 100
      
    Until Thread\Exit
    
  EndProcedure
  
  Procedure _FocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))

      StrgEx()\State | #Focus
      Draw_(GNum)
      
      StrgEx()\Cursor\State = #False
      StrgEx()\Cursor\Pause = #False
      
    EndIf
    
  EndProcedure  
  
  Procedure _LostFocusHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Cursor\Pause = #True
      
      StrgEx()\State & ~#Focus
      StrgEx()\Button\State & ~#Focus
      ResetList(StrgEx()\AutoComplete())
      Draw_(GNum)
  
    EndIf
    
  EndProcedure    
  
  
  Procedure _InputHandler()
    Define.s Char$
    Define.i Char
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))

      If StrgEx()\State & #Focus And Not StrgEx()\Flags & #NotEditable
        
        If Len(StrgEx()\Text) < StrgEx()\MaxLength Or StrgEx()\MaxLength = #PB_Default
          
          Char = GetGadgetAttribute(GNum, #PB_Canvas_Input)
          
          If StrgEx()\Flags & #Numeric And IsNumber(Char) = #False
            ProcedureReturn #False
          EndIf
          
          If Char >= 32
            
            If StrgEx()\Selection\Flag = #Selected
              DeleteSelection_()
            EndIf
            
            Char$ =  Chr(Char)
            If StrgEx()\Flags & #UpperCase : Char$ = UCase(Char$) : EndIf
            If StrgEx()\Flags & #LowerCase : Char$ = LCase(Char$) : EndIf
            
            StrgEx()\Cursor\Pos + 1
            StrgEx()\Text = InsertString(StrgEx()\Text, Char$, StrgEx()\Cursor\Pos)
            
            
            CompilerIf #Enable_AutoComplete
              
              If StrgEx()\Flags & #AutoComplete
                SelectAutoCompleteWord_()
              EndIf
              
            CompilerEndIf
            
          EndIf
          
          Draw_(GNum)
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure _KeyDownHandler()
    Define.i Key, Modifier
    Define.s Text
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If StrgEx()\State & #Focus
        
        Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
        Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
        
        Select Key
          Case #PB_Shortcut_Left      ;{ Cursor left
            If Modifier & #PB_Canvas_Shift
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = StrgEx()\Cursor\Pos
                StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos - 1
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 - 1
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
              If StrgEx()\Cursor\Pos > 0
                StrgEx()\Cursor\Pos - 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = GetWordEnd_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Pos2 = GetWordStart_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 = GetWordStart_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If StrgEx()\Cursor\Pos > 0
                StrgEx()\Cursor\Pos - 1
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_Right     ;{ Cursor right
            If Modifier & #PB_Canvas_Shift
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = StrgEx()\Cursor\Pos
                StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos + 1
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 + 1
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
              If StrgEx()\Cursor\Pos < Len(StrgEx()\Text)
                StrgEx()\Cursor\Pos + 1
              EndIf
              
            ElseIf Modifier & #PB_Canvas_Control
              
              If StrgEx()\Selection\Flag = #NoSelection
                StrgEx()\Selection\Pos1 = GetWordStart_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Pos2 = GetWordEnd_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              Else
                StrgEx()\Selection\Pos2 = GetWordEnd_(StrgEx()\Cursor\Pos)
                StrgEx()\Selection\Flag = #Selected
              EndIf
              
            Else
              
              If StrgEx()\Flags & #AutoComplete And ListIndex(StrgEx()\AutoComplete()) <> -1
                StrgEx()\Text = StrgEx()\AutoComplete()\Word
                StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
                ResetList(StrgEx()\AutoComplete())
              Else
                If StrgEx()\Cursor\Pos < Len(StrgEx()\Text)
                  StrgEx()\Cursor\Pos + 1
                EndIf
              EndIf
              
              RemoveSelection_()
              
            EndIf ;}
          Case #PB_Shortcut_End       ;{ Cursor end of chars
            StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Home      ;{ Cursor position 0
            StrgEx()\Cursor\Pos = 0
            RemoveSelection_()
            ;}
          Case #PB_Shortcut_Back      ;{ Delete Back
            If Not StrgEx()\Flags & #NotEditable
              If StrgEx()\Selection\Flag = #Selected
                DeleteSelection_()
                RemoveSelection_()
              Else
                If StrgEx()\Cursor\Pos > 0
                  StrgEx()\Text = DeleteStringPart_(StrgEx()\Text, StrgEx()\Cursor\Pos)
                  StrgEx()\Cursor\Pos - 1
                EndIf
                RemoveSelection_()
              EndIf  
            EndIf ;}
          Case #PB_Shortcut_Delete    ;{ Delete / Cut (Shift)
            If Modifier & #PB_Canvas_Shift ;{ Cut selected text
              Cut_()
              ;}
            Else                           ;{ Delete text
              If Not StrgEx()\Flags & #NotEditable
                If StrgEx()\Selection\Flag = #Selected
                  DeleteSelection_()
                  RemoveSelection_()
                Else
                  If StrgEx()\Cursor\Pos < Len(StrgEx()\Text)
                    StrgEx()\Text = DeleteStringPart_(StrgEx()\Text, StrgEx()\Cursor\Pos + 1)
                    RemoveSelection_()
                  EndIf
                EndIf
              EndIf ;}
            EndIf ;} 
          Case #PB_Shortcut_Insert    ;{ Copy (Ctrl) / Paste (Shift)
            If Modifier & #PB_Canvas_Shift
              Paste_()
            ElseIf Modifier & #PB_Canvas_Control
              Copy_()
            EndIf ;}  
          Case #PB_Shortcut_A         ;{ Ctrl-A (Select all)
            If Modifier & #PB_Canvas_Control
              StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
              StrgEx()\Selection\Pos1 = 0
              StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos
              StrgEx()\Selection\Flag = #Selected
            EndIf ;}
          Case #PB_Shortcut_C         ;{ Copy   (Ctrl)  
            Copy_()
            ;}
          Case #PB_Shortcut_X         ;{ Cut    (Ctrl) 
            Cut_()
            ;}
          Case #PB_Shortcut_D         ;{ Ctrl-D (Delete selection)
            If Not StrgEx()\Flags & #NotEditable
              If Modifier & #PB_Canvas_Control
                DeleteSelection_()
              EndIf 
            EndIf ;} 
          Case #PB_Shortcut_V         ;{ Paste  (Ctrl) 
            If Not StrgEx()\Flags & #NotEditable
              Paste_()
            EndIf ;} 
          Case #PB_Shortcut_Z         ;{ Crtl-Z (Undo)  
            If Not StrgEx()\Flags & #NotEditable
              Undo_()
            EndIf
            ;}
          Case #PB_Shortcut_Return    ;{ Return
            If StrgEx()\Flags & #AutoComplete And ListIndex(StrgEx()\AutoComplete()) <> -1
              StrgEx()\Text = StrgEx()\AutoComplete()\Word
              StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
              ResetList(StrgEx()\AutoComplete())
            EndIf  
            ;}
          Case #PB_Shortcut_Tab       ;{ Tabulator
            If StrgEx()\Flags & #AutoComplete And ListIndex(StrgEx()\AutoComplete()) <> -1
              StrgEx()\Text = StrgEx()\AutoComplete()\Word
              StrgEx()\Cursor\Pos = Len(StrgEx()\Text)
              ResetList(StrgEx()\AutoComplete())
            EndIf  
            ;}
        EndSelect
        
       Draw_(GNum)
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure _LeftButtonDownHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)

      If StrgEx()\Mouse = #Mouse_Move
        StrgEx()\Cursor\Pos = CursorPos_(X)
      EndIf
      
      StrgEx()\State | #Focus
      
      If StrgEx()\Button\State & #Focus
        If StrgEx()\Flags & #ShowButton
          StrgEx()\Button\State | #Click
        ElseIf StrgEx()\Flags & #EventButton
          StrgEx()\Button\State | #Click
          If IsWindow(StrgEx()\Window\Num)
            If StrgEx()\Button\Event = #PB_Default
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Button)
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\CanvasNum, #EventType_Button)
            Else
              PostEvent(#PB_Event_Gadget, StrgEx()\Window\Num, StrgEx()\Button\Event)
              PostEvent(#Event_Gadget, StrgEx()\Window\Num, StrgEx()\Button\Event)
            EndIf
          EndIf
        EndIf
      EndIf
      
      If StrgEx()\Selection\Flag = #Selected
        RemoveSelection_()
      EndIf
      
      Draw_(GNum)
    EndIf
    
  EndProcedure 
  
  Procedure _LeftButtonUpHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If StrgEx()\Flags & #ShowButton
        StrgEx()\Button\State & ~#Click
      ElseIf StrgEx()\Flags & #EventButton
        StrgEx()\Button\State & ~#Click
      EndIf
      
      If StrgEx()\Mouse = #Mouse_Select
        StrgEx()\Cursor\Pos     = CursorPos_(X)
        StrgEx()\Selection\Pos2 = StrgEx()\Cursor\Pos
        StrgEx()\Mouse = #Mouse_Move
      EndIf
      
      Draw_(GNum)
    EndIf
    
  EndProcedure 
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Pos
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton 
        If X > StrgEx()\Button\X
          ProcedureReturn #False
        EndIf
      EndIf
      
      Pos = CursorPos_(X)
      StrgEx()\Selection\Pos1 = GetWordStart_(Pos)
      StrgEx()\Selection\Pos2 = GetWordEnd_(Pos)
      StrgEx()\Selection\Flag = #Selected
      StrgEx()\Cursor\Pos     = StrgEx()\Selection\Pos2

      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Button\State & ~#Focus
      ResetList(StrgEx()\AutoComplete())
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure _MouseMoveHandler()
    Define.i X
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      
      If GetGadgetAttribute(GNum, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton ;{ Left mouse button pressed
        
        Select StrgEx()\Mouse
          Case #Mouse_Move   ;{ Start selection
            If StrgEx()\Selection\Flag = #NoSelection
              StrgEx()\Selection\Pos1 = StrgEx()\Cursor\Pos
              StrgEx()\Selection\Pos2 = CursorPos_(X)
              StrgEx()\Selection\Flag = #Selected
              StrgEx()\Mouse = #Mouse_Select
              Draw_(GNum)
            EndIf ;}
          Case #Mouse_Select ;{ Continue selection
            StrgEx()\Selection\Pos2 = CursorPos_(X)
            StrgEx()\Cursor\Pos     = StrgEx()\Selection\Pos2
            Draw_(GNum) ;}
        EndSelect
        ;}
      Else
        
        If StrgEx()\Flags & #ShowButton Or StrgEx()\Flags & #EventButton
          
          If X > StrgEx()\Button\X
            StrgEx()\Button\State | #Focus
            If StrgEx()\CanvasCursor <> #PB_Cursor_Default
              SetGadgetAttribute(StrgEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
              StrgEx()\CanvasCursor = #PB_Cursor_Default
            EndIf
          Else
            StrgEx()\Button\State & ~#Focus
            If StrgEx()\CanvasCursor <> #PB_Cursor_IBeam
              SetGadgetAttribute(StrgEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
              StrgEx()\CanvasCursor = #PB_Cursor_IBeam
            EndIf
          EndIf
        
          Draw_(GNum)
        Else
          If StrgEx()\CanvasCursor <> #PB_Cursor_IBeam
            SetGadgetAttribute(StrgEx()\CanvasNum, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
            StrgEx()\CanvasCursor = #PB_Cursor_IBeam
          EndIf
        EndIf
        
        StrgEx()\Mouse = #Mouse_Move
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _RightClickHandler()
    Define.i GNum = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GNum))
      If IsWindow(StrgEx()\Window\Num)
        DisplayPopupMenu(StrgEx()\PopupNum, WindowID(StrgEx()\Window\Num))
      EndIf
    EndIf
    
  EndProcedure
  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(StrgEx(), Str(GadgetID))
      
      StrgEx()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      StrgEx()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_(StrgEx()\CanvasNum)
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach StrgEx()
      
      If IsGadget(StrgEx()\CanvasNum)
        
        If StrgEx()\Flags & #AutoResize
          
          If IsWindow(StrgEx()\Window\Num)
            
            OffSetX = WindowWidth(StrgEx()\Window\Num)  - StrgEx()\Window\Width
            OffsetY = WindowHeight(StrgEx()\Window\Num) - StrgEx()\Window\Height

            StrgEx()\Window\Width  = WindowWidth(StrgEx()\Window\Num)
            StrgEx()\Window\Height = WindowHeight(StrgEx()\Window\Num)
            
            If StrgEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If StrgEx()\Size\Flags & #MoveX : X = GadgetX(StrgEx()\CanvasNum) + OffSetX : EndIf
              If StrgEx()\Size\Flags & #MoveY : Y = GadgetY(StrgEx()\CanvasNum) + OffSetY : EndIf
              If StrgEx()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(StrgEx()\CanvasNum)  + OffSetX : EndIf
              If StrgEx()\Size\Flags & #ResizeHeight : Height = GadgetHeight(StrgEx()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(StrgEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(StrgEx()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(StrgEx()\CanvasNum) + OffSetX, GadgetHeight(StrgEx()\CanvasNum) + OffsetY)
            EndIf
          
            Draw_(StrgEx()\CanvasNum)
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure  
  
  Procedure _CloseWindowHandler()
    Define.i Window = EventWindow()
    
    ForEach StrgEx()
    
      If StrgEx()\Window\Num = Window
        
        CompilerIf Defined(ModuleEx, #PB_Module) = #False
          If MapSize(StrgEx()) = 1
            Thread\Exit = #True
            Delay(100)
            If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
            Thread\Active = #False
          EndIf
        CompilerEndIf
        
        DeleteMapElement(StrgEx())
        
      EndIf
      
    Next
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  CompilerIf #Enable_AutoComplete
  
    Procedure   AddWords(GNum.i, String.s, NoCase.i=#False, Seperator.s=" ")
      Define.i Count, w
      
      If FindMapElement(StrgEx(), Str(GNum))
        
        Count = CountString(String, Seperator) + 1
        For w=1 To Count
          If AddElement(StrgEx()\AutoComplete())
            StrgEx()\AutoComplete()\Word   = StringField(String, w, Seperator)
            StrgEx()\AutoComplete()\NoCase = NoCase
          EndIf
        Next
        
        SortStructuredList(StrgEx()\AutoComplete(), #PB_Sort_Ascending, OffsetOf(StrgEx_Words_Structure\Word), TypeOf(StrgEx_Words_Structure\Word))
        ResetList(StrgEx()\AutoComplete())
        
      EndIf
      
    EndProcedure
    
    Procedure   ClearWords(GNum.i)
    
      If FindMapElement(StrgEx(), Str(GNum))
        ClearList(StrgEx()\AutoComplete())
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure   AttachPopupMenu(GNum.i, MenuNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsMenu(MenuNum)
        StrgEx()\PopupNum = MenuNum
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   AddButton(GNum.i, ImageNum.i, Width.i=#PB_Default, Height.i=#PB_Default, Event.i=#PB_Default)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsImage(ImageNum)
        StrgEx()\Flags | #EventButton
        StrgEx()\Button\ImgNum  = ImageNum
        If Width = #PB_Default
          StrgEx()\Button\Width = ImageWidth(ImageNum)
        Else
          StrgEx()\Button\Width = dpiX(Width)
        EndIf
        If Height = #PB_Default
          StrgEx()\Button\Height = ImageHeight(ImageNum)
        Else
          StrgEx()\Button\Height = dpiY(Height)
        EndIf
        StrgEx()\Button\Event = Event
        Draw_(GNum)
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   Clear(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Text = ""
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   Copy(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Copy_()
    EndIf
    
  EndProcedure
  
  Procedure   Cut(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Cut_()
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   Paste(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Paste_()
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   Delete(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      DeleteSelection_()
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure   Free(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      CompilerIf Defined(ModuleEx, #PB_Module) = #False
        If MapSize(StrgEx()) = 1
          Thread\Exit = #True
          Delay(100)
          If IsThread(Thread\Num) : KillThread(Thread\Num) : EndIf
          Thread\Active = #False
        EndIf
      CompilerEndIf
      
      DeleteMapElement(StrgEx())
      
    EndIf 
    
  EndProcedure
  
  
  Procedure Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Content.s="", Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum
    
    Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(StrgEx(), Str(GNum))
        
        StrgEx()\CanvasNum = GNum
        StrgEx()\Text      = Content
        StrgEx()\MaxLength = #PB_Default
        StrgEx()\Undo      = Content
        StrgEx()\Flags     = Flags
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default
            StrgEx()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            StrgEx()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            StrgEx()\Window\Num = GetActiveWindow()
          Else
            StrgEx()\Window\Num = WindowNum
          EndIf
        CompilerEndIf   
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          
          If ModuleEx::AddWindow(StrgEx()\Window\Num, ModuleEx::#Tabulator|ModuleEx::#CursorEvent)
            ModuleEx::AddGadget(GNum, StrgEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf

        CompilerElse  
          
          If IsWindow(StrgEx()\Window\Num)
            RemoveKeyboardShortcut(StrgEx()\Window\Num, #PB_Shortcut_Tab)
          Else
            Debug "ERROR: Invalid window number"
            ProcedureReturn #False
          EndIf
          
          If Thread\Active = #False
            
            Thread\Exit   = #False
            Thread\Num    = CreateThread(@_CursorThread(), #CursorFrequency)
            Thread\Active = #True
            
          EndIf

        CompilerEndIf
        
        CompilerIf #Enable_ShowPasswordButton 
          StrgEx()\Button\ImgNum = CatchImage(#PB_Any, ?ImgShow, 591)
          StrgEx()\Button\Width  = dpiX(16)
          StrgEx()\Button\Height = dpiY(10)
        CompilerEndIf
      
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            StrgEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              StrgEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            StrgEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        StrgEx()\Padding = dpiX(4)
        
        StrgEx()\Size\X = X
        StrgEx()\Size\Y = Y
        StrgEx()\Size\Width  = Width
        StrgEx()\Size\Height = Height
        
        StrgEx()\CanvasCursor = #PB_Cursor_Default
        StrgEx()\Cursor\Pause = #True
        StrgEx()\Cursor\State = #True
        
        StrgEx()\Color\Front         = $000000
        StrgEx()\Color\Back          = $FFFFFF
        StrgEx()\Color\Focus         = $D77800
        StrgEx()\Color\Border        = $A0A0A0
        StrgEx()\Color\Cursor        = $800000
        StrgEx()\Color\Button        = $E3E3E3
        StrgEx()\Color\Highlight     = $D77800
        StrgEx()\Color\HighlightText = $FFFFFF
        StrgEx()\Color\WordColor     = $CC6600
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            StrgEx()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            StrgEx()\Color\Back          = GetSysColor_(#COLOR_WINDOW)
            StrgEx()\Color\Focus         = GetSysColor_(#COLOR_HIGHLIGHT)
            StrgEx()\Color\Button        = GetSysColor_(#COLOR_3DLIGHT)
            StrgEx()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
            StrgEx()\Color\WordColor     = GetSysColor_(#COLOR_HOTLIGHT)
            StrgEx()\Color\Highlight     = GetSysColor_(#COLOR_HIGHLIGHT)
            StrgEx()\Color\HighlightText = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
          CompilerCase #PB_OS_MacOS
            StrgEx()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            StrgEx()\Color\Back          = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            StrgEx()\Color\Focus         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor keyboardFocusIndicatorColor"))
            StrgEx()\Color\Button        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            StrgEx()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            StrgEx()\Color\Highlight     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextBackgroundColor"))
            StrgEx()\Color\HighlightText = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedTextColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}        
        
        BindGadgetEvent(GNum, @_FocusHandler(),           #PB_EventType_Focus)
        BindGadgetEvent(GNum, @_LostFocusHandler(),       #PB_EventType_LostFocus)
        BindGadgetEvent(GNum, @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(GNum, @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(GNum, @_InputHandler(),           #PB_EventType_Input)
        BindGadgetEvent(GNum, @_KeyDownHandler(),         #PB_EventType_KeyDown)
        BindGadgetEvent(GNum, @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(GNum, @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
        BindGadgetEvent(GNum, @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(GNum, @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(GNum, @_CursorDrawing(),          #PB_EventType_Change)
        BindGadgetEvent(GNum, @_ResizeHandler(),          #PB_EventType_Resize)
        
        If Flags & #AutoResize
          If IsWindow(WindowNum)
            StrgEx()\Window\Width  = WindowWidth(WindowNum)
            StrgEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf  
        EndIf
        
        BindEvent(#Event_Cursor,         @_CursorDrawing())
        BindEvent(#PB_Event_CloseWindow, @_CloseWindowHandler(), StrgEx()\Window\Num)
        
        Draw_(GNum)
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select Attribute
        Case #MaximumLength
          ProcedureReturn StrgEx()\MaxLength  
        Case #Padding
          ProcedureReturn StrgEx()\Padding
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetColor(GNum.i, ColorType.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn StrgEx()\Color\Front
        Case #BackColor
          ProcedureReturn StrgEx()\Color\Back
        Case #BorderColor
          ProcedureReturn StrgEx()\Color\Border
        Case #FocusColor
          ProcedureReturn StrgEx()\Color\Focus
        Case #CursorColor
          ProcedureReturn StrgEx()\Color\Cursor
        Case #HighlightColor
          ProcedureReturn StrgEx()\Color\Highlight
        Case #HighlightTextColor
          ProcedureReturn StrgEx()\Color\HighlightText
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure.s GetText(GNum.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      ProcedureReturn StrgEx()\Text
    EndIf
    
  EndProcedure
  
  
  Procedure SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      StrgEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select Attribute
        Case #MaximumLength
          StrgEx()\MaxLength = Value
          Draw_(GNum)
        Case #Padding
          If Value < 2 : Value = 2 : EndIf 
          StrgEx()\Padding = dpiX(Value)
      EndSelect
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure SetColor(GNum.i, ColorType.i, Color.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          StrgEx()\Color\Front = Color
        Case #BackColor
          StrgEx()\Color\Back = Color
        Case #BorderColor
          StrgEx()\Color\Border = Color
        Case #FocusColor
          StrgEx()\Color\Focus = Color
        Case #CursorColor
          StrgEx()\Color\Cursor = Color
        Case #HighlightColor
          StrgEx()\Color\Highlight = Color
        Case #HighlightTextColor
          StrgEx()\Color\HighlightText = Color
      EndSelect
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure SetFlags(GNum.i, Flags.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Flags | Flags
    EndIf
    
  EndProcedure
  
  Procedure RemoveFlag(GNum.i, Flag.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Flags & ~Flag
    EndIf
    
  EndProcedure
  
  Procedure SetFont(GNum.i, FontNum.i) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      
      If IsFont(FontNum)
        StrgEx()\FontID = FontID(FontNum)
      EndIf
      
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  Procedure SetText(GNum.i, Text.s) 
    
    If FindMapElement(StrgEx(), Str(GNum))
      StrgEx()\Text = Text
      Draw_(GNum)
    EndIf
    
  EndProcedure
  
  
  Procedure Undo(GNum.i)
    
    If FindMapElement(StrgEx(), Str(GNum))
      Undo_()
      Draw_(GNum)
    EndIf
    
  EndProcedure  
  
  CompilerIf #Enable_ShowPasswordButton  
    DataSection
      ImgShow:
      Data.q $0A1A0A0D474E5089,$524448490D000000,$0A00000010000000,$DEBEBD0000000608,$414449160200009C,$6600406463DA7854,
             $FFF328C8C8CBFE20,$67E99313133B7FFF,$E20563140DF99CCE,$DEEF77AC06FAFADF,$FE406997CBE5FE99,$508C7FE202662023,
             $C9909090BFFA20CD,$31F4F4F74EEF77BB,$31745454326BEBE8,$9EF57ABC33AA6A68,$8E5C5C419AD03021,$34444441923A3A21,
             $611A617347E3F1E5,$17F3F99AF1007BB6,$48888FFEB27272B0,$2713FFFDFB7DB961,$D2FFEFF77BBE33F6,$A7FF448C8D19D3A5,
             $6660313133FFE4A4,$3F67F3F9FA2F6767,$393C9E4C56179223,$3EBABAA7E727273C,$58343419678DC6FB,$6EF6F64B025E8018,
             $BEA0D02179BCD860,$6E6E6FFEBC9E4F7F,$9A05960B6C281AF6,$8177E80FAD340916,$3356C6C7B09F2F97,$3384141631E5A5A4,
             $308646443274F4F4,$33EACAC830E44444,$F69F1F1FFBFF6B68,$3085D6A077F06807,$F7BBDD84F102A817,$763631FD38B8B87A,
             $F22A286429898B61,$F1C32E6EAEAF3B81,$93FCE5F5F7FE87E3,$720BC7C7CFF8D797,$C67881D217B20381,$9E7ABD5C7F271389,
             $E11E1EACEDFCFE79,$A3C3C8CF3F3F9FFF,$32328C1B9DCEFFF0,$9391FD375756FE7F,$7FC2D7EBF5FF6593,$0F0F02C4A1D5FEFF,
             $793C9EA69A30164F,$AF56FF1BC3E1E18A,$EE70C360E0E0C23E,$AC86067979066DDC,$A0065535352602AC,$3B3AF3858585399A,
             $580E9C00BB221F3B,$1DE3F9FCFFFD5959,$B812E974BA9D1515,$B6C70BD008707064,$DF1F1F056CF67B3F,$3F0A047D3E9F4FF9,
             $000B10086E003641,$A0A0B72B13131EB1,$FD7FFF3F1F8FC320,$CE8E8EADF6A411FA,$41EFD880AE572BED,$8D20D82EA10006AE,
             $4900000000C587C8
      Data.b $45,$4E,$44,$AE,$42,$60,$82
      ImgShowEnd:
    EndDataSection
  CompilerEndIf

EndModule  

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  
  Enumeration 1
    #String
    #StringEx
    #StringPW
    #StringDel
    #Font
    #Popup
    #Image
    #Menu_Item1
    #Menu_Item2
    #Menu_Item3
    #Menu_Item4
    #Menu_Item5
  EndEnumeration
  
  LoadImage(#Image, "Delete.png")
  
  If OpenWindow(#Window, 0, 0, 460, 60, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#Popup)
      MenuItem(#Menu_Item1, "Undo")
      MenuBar()
      MenuItem(#Menu_Item2, "Copy")
      MenuItem(#Menu_Item3, "Cut")
      MenuItem(#Menu_Item4, "Paste")
      MenuBar()
      MenuItem(#Menu_Item5, "Delete")
    EndIf
    
    StringGadget(#String, 15, 19, 90, 20, "")
    ;SetGadgetAttribute(#String, #PB_String_MaximumLength, 5)
    
    StringEx::Gadget(#StringEx, 120, 19, 90, 20, "AutoComplete", StringEx::#AutoComplete, #Window) ; StringEx::#ShowButton / StringEx::#Numeric / StringEx::#LowerCase / StringEx::#UpperCase / StringEx::#NotEditable / StringEx::#BorderLess
    StringEx::AttachPopupMenu(#StringEx, #Popup)
    ;StringEx::SetAttribute(#StringEx, StringEx::#MaximumLength, 5)
    StringEx::AddWords(#StringEx, "Default Define Declare Degree Debug AutoComplete")
    
    StringEx::Gadget(#StringPW, 225, 19, 100, 20, "Password", StringEx::#Password|StringEx::#ShowButton, #Window)
    ;StringEx::SetAttribute(#StringPW, StringEx::#Padding, 6)
    ;StringEx::SetAttribute(#StringPW, StringEx::#MaximumLength, 10)
    
    StringEx::Gadget(#StringDel, 340, 19, 100, 20, "Delete this", StringEx::#Center|StringEx::#AutoResize, #Window)
    StringEx::AddButton(#StringDel, #Image)
    StringEx::SetAutoResizeFlags(#StringDel, StringEx::#ResizeWidth)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #StringDel
              If EventType() = StringEx::#EventType_Button
                StringEx::Clear(#StringDel)
              EndIf
          EndSelect
        Case #PB_Event_Menu
          Select EventMenu()
            Case #Menu_Item1
              StringEx::Undo(#StringEx)
            Case #Menu_Item2
              StringEx::Copy(#StringEx)
            Case #Menu_Item3
              StringEx::Cut(#StringEx)
            Case #Menu_Item4
              StringEx::Paste(#StringEx)
            Case #Menu_Item5
              StringEx::Delete(#StringEx)
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
