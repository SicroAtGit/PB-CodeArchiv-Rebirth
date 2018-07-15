;   Description: Creates a CanvasGadget that scrolls a text (horizontally or vertically)
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=70658
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
;
; Copyright (c) 2018 Justin
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

DeclareModule guiMarquee
  #DefDelay = 10
  #DefScrollStep = 1
  
  ;- ENUM Flags
  EnumerationBinary
    #DirectionLeft
    #DirectionRight
    #DirectionUp
    #DirectionDown
    
    ;Align flags for multiline text
    #AlignLeft
    #AlignRight
    #AlignCenter
    #AlignBlock
  EndEnumeration
  
  ;- MARQUEE_TOOL_EXINFO
  Structure MARQUEE_TOOL_EXINFO
    PaddingLeft.d
    PaddingRight.d
    PaddingTop.d
    PaddingBottom.d
  EndStructure
  
  ;- MARQUEE_TOOL
  Structure MARQUEE_TOOL
    *Marquee.MARQUEE
    Canvas.i
    Text.s
    TextX.d
    TextY.d
    TextWidth.d
    TextHeight.d
    Scrolling.b
    ClrText.l
    ClrBack.l
    Flags.l
    FntID.i
    ExInfo.MARQUEE_TOOL_EXINFO
  EndStructure
  
  ;- MARQUEE
  Structure MARQUEE
    List Tools.MARQUEE_TOOL()
    TimerID.i
    TimerActive.b
    TimerMS.i
    ScrollStep.w
    ParentWindow.i
  EndStructure
  
  ;- DECLARES
  Declare Create(parentWindow.i, timerID.i, scrollStep.w = #DefScrollStep, delay.i = #DefDelay)
  Declare Free(*marquee.MARQUEE)
  Declare CreateTool(*marquee.MARQUEE, x.i, y.i, width.i, height.i, text.s, clrText.l, clrBack.l, fontid.i, flags.l = #DirectionLeft, *exInfo.MARQUEE_TOOL_EXINFO = #Null)
  Declare DestroyTool(*tool.MARQUEE_TOOL)
  Declare ResizeTool(*tool.MARQUEE_TOOL, x.i, y.i, width.i, height.i)
  Declare HideTool(*tool.MARQUEE_TOOL, hide.b)
  Declare SetToolText(*tool.MARQUEE_TOOL, text.s)
  Declare OnTimerTick(*marquee.MARQUEE)
  Declare SetDelay(*marquee.MARQUEE, ms.i)
EndDeclareModule

Module guiMarquee
  EnableExplicit
  
  ;Workaround to get TextParagraph height.
  #MAX_PAR_HEIGHT = 10000
  
  #DefPaddingLeft = 8
  #DefPaddingTop = 8
  #DefPaddingRight = 8
  #DefPaddingBottom = 8
  
  Declare DrawTool(*tool.MARQUEE_TOOL)
  
  Macro IsHorzScroll(flags)
    Bool(flags & #DirectionLeft = #DirectionLeft Or flags & #DirectionRight = #DirectionRight)
  EndMacro   
  
  Macro IsVertScroll(flags)
    Bool(flags & #DirectionUp = #DirectionUp Or flags & #DirectionDown = #DirectionDown)
  EndMacro   
  
  Procedure Create(parentWindow.i, timerID.i, scrollStep.w = #DefScrollStep, delay.i = #DefDelay)
    Define.MARQUEE *this
    
    *this = AllocateStructure(MARQUEE)
    *this\ParentWindow = parentWindow
    *this\TimerID = timerID
    *this\TimerMS = delay
    *this\ScrollStep = scrollStep
    
    ProcedureReturn *this
  EndProcedure
  
  Procedure Free(*this.MARQUEE)
    ForEach *this\Tools()
      If IsGadget(*this\Tools()\Canvas)
        FreeGadget(*this\Tools()\Canvas)
      EndIf
    Next
    FreeList(*this\Tools())
    FreeStructure(*this)
  EndProcedure
  
  Procedure OnToolResize()
    Define.MARQUEE_TOOL *tool
    
    *tool = GetGadgetData(EventGadget())
    If *tool : DrawTool(*tool) : EndIf
  EndProcedure
  
  Procedure CreateTool(*marquee.MARQUEE, x.i, y.i, width.i, height.i, text.s, clrTxt.l, clrBack.l, fid.i, flags.l = #DirectionLeft, *exInfo.MARQUEE_TOOL_EXINFO = #Null)
    AddElement(*marquee\Tools())
    *marquee\Tools()\Marquee = *marquee
    *marquee\Tools()\Text = text
    *marquee\Tools()\Canvas = CanvasGadget(#PB_Any, x, y, width, height)
    *marquee\Tools()\ClrText = clrTxt
    *marquee\Tools()\ClrBack = clrBack
    *marquee\Tools()\Flags = flags
    *marquee\Tools()\FntID = fid
    
    If *exInfo
      CopyMemory(*exInfo, *marquee\Tools()\ExInfo, SizeOf(MARQUEE_TOOL_EXINFO))
      
    Else
      *marquee\Tools()\ExInfo\PaddingLeft = #DefPaddingLeft
      *marquee\Tools()\ExInfo\PaddingTop = #DefPaddingTop
      *marquee\Tools()\ExInfo\PaddingRight = #DefPaddingRight
      *marquee\Tools()\ExInfo\PaddingBottom = #DefPaddingBottom
    EndIf
    
    *marquee\Tools()\TextX = *marquee\Tools()\ExInfo\PaddingLeft
    
    SetGadgetData(*marquee\Tools()\Canvas, @*marquee\Tools())
    BindGadgetEvent(*marquee\Tools()\Canvas, @OnToolResize(), #PB_EventType_Resize)
    DrawTool(@*marquee\Tools())
    
    ProcedureReturn @*marquee\Tools()
  EndProcedure
  
  Procedure DrawTool(*tool.MARQUEE_TOOL)
    Define.d availWidth, availHeight
    Define.l drawFlags
    
    If StartVectorDrawing(CanvasVectorOutput(*tool\Canvas))
      ;Font
      VectorFont(*tool\FntID)
      
      availWidth = GadgetWidth(*tool\Canvas) - *tool\ExInfo\PaddingLeft - *tool\ExInfo\PaddingRight
      availHeight = GadgetHeight(*tool\Canvas) - *tool\ExInfo\PaddingTop - *tool\ExInfo\PaddingBottom
      
      ;Text dimension is saved here to use it in OnTimerTick().
      *tool\TextWidth = VectorTextWidth(*tool\Text)
      *tool\TextHeight = VectorParagraphHeight(*tool\Text, availWidth, #MAX_PAR_HEIGHT) ;Workaround
      
      If IsHorzScroll(*tool\Flags)
        If *tool\TextWidth > availWidth
          *tool\Scrolling = #True
          
        Else
          *tool\Scrolling = #False
          *tool\TextX = *tool\ExInfo\PaddingLeft
        EndIf
        
        ;Center text vertically
        *tool\TextY = (GadgetHeight(*tool\Canvas) - VectorTextHeight(*tool\Text)) / 2
        If *tool\TextY < 0 : *tool\TextY = *tool\ExInfo\PaddingTop : EndIf
        
      ElseIf IsVertScroll(*tool\Flags)
        *tool\Scrolling = #True
      EndIf
      
      ;Activate timer if tool is scrolling.
      If *tool\Scrolling = #True
        If *tool\Marquee\TimerActive = #False
          AddWindowTimer(*tool\Marquee\ParentWindow, *tool\Marquee\TimerID, *tool\Marquee\TimerMS)
          *tool\Marquee\TimerActive = #True
        EndIf
      EndIf
      
      ;Background
      VectorSourceColor(*tool\ClrBack)
      FillVectorOutput()
      
      ;Set clip region
      If *tool\ExInfo\PaddingLeft <> 0 Or *tool\ExInfo\PaddingRight <> 0 Or *tool\ExInfo\PaddingTop <> 0 Or *tool\ExInfo\PaddingBottom <> 0
        AddPathBox(*tool\ExInfo\PaddingLeft, *tool\ExInfo\PaddingTop, availWidth, availHeight)
        ClipPath()
      EndIf
      
      ;Text
      VectorSourceColor(*tool\ClrText)
      MovePathCursor(*tool\TextX, *tool\TextY)
      If IsHorzScroll(*tool\Flags)
        DrawVectorText(*tool\Text)
        
      ElseIf IsVertScroll(*tool\Flags)
        If *tool\Flags & #AlignLeft = #AlignLeft
          drawFlags = #PB_VectorParagraph_Left
          
        ElseIf *tool\Flags & #AlignRight = #AlignRight
          drawFlags = #PB_VectorParagraph_Right
          
        ElseIf *tool\Flags & #AlignCenter = #AlignCenter
          drawFlags = #PB_VectorParagraph_Center
          
        ElseIf *tool\Flags & #AlignBlock = #AlignBlock
          drawFlags = #PB_VectorParagraph_Block
          
        Else
          drawFlags = #PB_VectorParagraph_Left
        EndIf
        
        DrawVectorParagraph(*tool\Text, availWidth, #MAX_PAR_HEIGHT, drawFlags)
      EndIf
      
      StopVectorDrawing()
    EndIf
  EndProcedure
  
  Procedure OnTimerTick(*marquee.MARQUEE)
    Define.i toolScrolling, canvasWidth, canvasHeight
    
    toolScrolling = #False
    
    ForEach *marquee\Tools()
      If *marquee\Tools()\Scrolling = #True
        toolScrolling = #True
        
        canvasWidth = GadgetWidth(*marquee\Tools()\Canvas)
        canvasHeight = GadgetHeight(*marquee\Tools()\Canvas)
        
        ;DirectionRight
        If *marquee\Tools()\Flags & #DirectionRight = #DirectionRight
          If *marquee\Tools()\TextX >=  canvasWidth - *marquee\Tools()\ExInfo\PaddingRight
            *marquee\Tools()\TextX = - *marquee\Tools()\TextWidth + *marquee\Tools()\ExInfo\PaddingLeft
            
          Else
            *marquee\Tools()\TextX + *marquee\Tools()\Marquee\ScrollStep
          EndIf
          
          ;Direction Up
        ElseIf *marquee\Tools()\Flags & #DirectionUp = #DirectionUp
          If *marquee\Tools()\TextY + *marquee\Tools()\TextHeight + *marquee\Tools()\ExInfo\PaddingTop <=  *marquee\Tools()\ExInfo\PaddingTop
            *marquee\Tools()\TextY = canvasHeight - *marquee\Tools()\ExInfo\PaddingBottom
            
          Else
            *marquee\Tools()\TextY - *marquee\Tools()\Marquee\ScrollStep
          EndIf
          
          ;Direction Down
        ElseIf *marquee\Tools()\Flags & #DirectionDown = #DirectionDown
          If *marquee\Tools()\TextY >= canvasHeight - *marquee\Tools()\ExInfo\PaddingBottom
            *marquee\Tools()\TextY = - *marquee\Tools()\TextHeight + *marquee\Tools()\ExInfo\PaddingTop
            
          Else
            *marquee\Tools()\TextY + *marquee\Tools()\Marquee\ScrollStep
          EndIf
          
          ;DirectionLeft
        ElseIf *marquee\Tools()\Flags & #DirectionLeft = #DirectionLeft
          If *marquee\Tools()\TextX + *marquee\Tools()\TextWidth + *marquee\Tools()\ExInfo\PaddingLeft <=  *marquee\Tools()\ExInfo\PaddingLeft
            *marquee\Tools()\TextX = canvasWidth - *marquee\Tools()\ExInfo\PaddingRight
            
          Else
            *marquee\Tools()\TextX - *marquee\Tools()\Marquee\ScrollStep
          EndIf
        EndIf
        
        DrawTool(*marquee\Tools())
      EndIf
    Next
    
    ;Remove timer if there are no tools scrolling
    If toolScrolling = #False
      RemoveWindowTimer(*marquee\ParentWindow, *marquee\TimerID)
      *marquee\TimerActive = #False
    EndIf
  EndProcedure
  
  Procedure SetDelay(*marquee.MARQUEE, ms.i)
    *marquee\TimerMS = ms
  EndProcedure
  
  Procedure ResizeTool(*tool.MARQUEE_TOOL, x.i, y.i, width.i, height.i)
    ResizeGadget(*tool\Canvas, x, y, width, height)
  EndProcedure
  
  Procedure SetToolText(*tool.MARQUEE_TOOL, text.s)
    *tool\Text = text
    DrawTool(*tool)
  EndProcedure
  
  Procedure DestroyTool(*tool.MARQUEE_TOOL)
    ForEach *tool\Marquee\Tools()
      If *tool = @*tool\Marquee\Tools()
        FreeGadget(*tool\Marquee\Tools()\Canvas)
        DeleteElement(*tool\Marquee\Tools())
        Break
      EndIf
    Next
  EndProcedure
  
  Procedure HideTool(*tool.MARQUEE_TOOL, hide.b)
    HideGadget(*tool\Canvas, hide)
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  Global.i g_win, g_marquee, g_mt1, g_mt2, g_mt3, g_mt4
  
  #MARQUEE_TIMER_ID = 1
  
  Procedure TimerEvent()
    If EventTimer() = #MARQUEE_TIMER_ID
      guiMarquee::OnTimerTick(g_marquee)
    EndIf
  EndProcedure
  
  Procedure SizeEvent()
    guiMarquee::ResizeTool(g_mt3, #PB_Ignore, #PB_Ignore, WindowWidth(g_win), #PB_Ignore)
    guiMarquee::ResizeTool(g_mt4, #PB_Ignore, #PB_Ignore, WindowWidth(g_win), #PB_Ignore)
  EndProcedure
  
  Define.guiMarquee::MARQUEE_TOOL_EXINFO exInfo
  Define.i fid
  
  fid = FontID(LoadFont(#PB_Any, "Verdana", 10))
  
  exInfo\PaddingLeft = 10
  exInfo\PaddingRight = 10
  exInfo\PaddingTop = 4
  exInfo\PaddingBottom = 4
  
  Define.s partext
  
  partext = "Every drawing output has a default unit of measurement. The default unit is pixels " +
            "for screen or raster image outputs and points for printer or vector image outputs. " +
            "It is however possible to select a different unit of measurement for the output when " +
            "creating it with the ImageVectorOutput(), PrinterVectorOutput() or similar function."
  
  g_win = OpenWindow(#PB_Any, 10, 10, 400, 350, "MarqueeEX", #PB_Window_SystemMenu | #PB_Window_SizeGadget)
  g_marquee = guiMarquee::Create(g_win, #MARQUEE_TIMER_ID)
  BindEvent(#PB_Event_Timer, @TimerEvent(), g_win)
  BindEvent(#PB_Event_SizeWindow, @SizeEvent(), g_win)
  
  g_mt1 = guiMarquee::CreateTool(g_marquee, 10, 10, 120, 30, "very long left scrolling text", RGBA(255, 255, 255, 255), RGBA(0, 0, 0, 255), fid, guiMarquee::#DirectionLeft, exInfo)
  g_mt2 = guiMarquee::CreateTool(g_marquee, 10, 50, 120, 30, "very long right scrolling text", RGBA(255, 0, 0, 255), RGBA(0, 255, 255, 255), fid, guiMarquee::#DirectionRight)
  
  g_mt3 = guiMarquee::CreateTool(g_marquee, 0, 100, WindowWidth(g_win), 100, partext, RGBA(255, 0, 0, 255), RGBA(0, 255, 255, 255), fid, guiMarquee::#DirectionDown)
  g_mt4 = guiMarquee::CreateTool(g_marquee, 0, 220, WindowWidth(g_win), 100, partext, RGBA(255, 0, 0, 255), RGBA(0, 255, 255, 255), fid, guiMarquee::#DirectionUp | guiMarquee::#AlignRight)
  
  Repeat
    
  Until WaitWindowEvent() = #PB_Event_CloseWindow
  
  guiMarquee::Free(g_marquee)
  
CompilerEndIf
