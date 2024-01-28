﻿;   Description: Adds a ChartGadget (Columns, bars, pie charts, curve charts and charts with data series)
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=73000
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31524
; -----------------------------------------------------------------------------

;/ ============================
;/ =    Chart - Module.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Chart - Gadget 
;/
;/ © 2019 Thorsten1867 (06/2019)
;/


; Last Update: 28.07.19
;
; Added: #Time flag for axis / AddAxisLabel()
; Added: 
;
; Added: Scatter plot chart
;
; BugFixes
;

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


;{ _____ Chart - Commands _____

; Chart::AddItem()             - similar to AddGadgetItem()
; Chart::AttachPopupMenu()     - attachs a popup menu to the chart
; Chart::DisableReDraw()       - disable/enable redrawing
; Chart::EventColor()          - returns the color after the event
; Chart::EventIndex()          - returns the item index after the event
; Chart::EventLabel()          - returns the item label after the event
; Chart::EventValue()          - returns the item value after the event
; Chart::Gadget()              - create a new gadget
; Chart::GetErrorMessage()     - get error message [DE/FR/ES/UK]
; Chart::GetItemColor()        - returns the color of the item
; Chart::GetItemLabel()        - get the label of the item
; Chart::GetItemState()        - similar to GetGadgetItemState()
; Chart::GetItemText()         - similar to GetGadgetItemText()
; Chart::GetLabelState()       - similar to GetGadgetItemState(), but 'label' instead of 'position'
; Chart::GetLabelColor()       - returns the color of the item
; Chart::RemoveItem()          - similar to RemoveGadgetItem()
; Chart::RemoveLabel()         - similar to RemoveGadgetItem(), but 'label' instead of 'position'
; Chart::SetAttribute()        - similar to SetGadgetAttribute()
; Chart::SetAutoResizeFlags()  - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]
; Chart::SetColor()            - similar to SetGadgetColor()
; Chart::SetFlags()            - set flags for chart customization
; Chart::SetFont()             - similar to SetGadgetFont()
; Chart::SetItemState()        - similar to SetGadgetItemState()
; Chart::SetItemText()         - similar to SetGadgetItemText()
; Chart::SetLabelState()       - similar to SetGadgetItemState(), but 'label' instead of 'position'
; Chart::SetMargins()          - define top, left, right and bottom margin
; Chart::SetMask()             - define mask for FormatDate()
; Chart::ToolTipText()         - defines the text for tooltips (#Percent$ / #Value$ / #Label$ / #Serie$)
; Chart::UpdatePopupText()     - updates the menu item text before the popup menu is displayed

; --- Data Series ---

; Chart::AddDataSeries()       - add a new data series
; Chart::AddSeriesItem()       - add a new item to the data series
; Chart::DisplayDataSeries()   - displays the data series
; Chart::EventDataSeries()     - returns the value of the item by index
; Chart::GetSeriesColor()      - returns the color of the data series
; Chart::GetSeriesItemState()  - returns the value of the item by index
; Chart::GetSeriesLabelState() - returns the value of the item by label
; Chart::RemoveSeriesItem()    - removes the item by index
; Chart::RemoveSeriesLabel()   - removes the item by label
; Chart::RemoveDataSeries()    - removes the data series
; Chart::SetSeriesItemState()  - sets the value of the item by index
; Chart::SetSeriesLabelState() 

; --- Scatter Plot ---

; Chart::AddAxisLabel()         - defines a axis label for a specific value
; Chart::AddScatterPlot()       - add a new scatter plot
; Chart::AddScatterItem()       - add a new item to the scatter plot
; Chart::DisplayScatterPlot()   - displays the scatter plot
; Chart::EventScatterPlot()     - returns the label of the scatter plot after the event
; Chart::EventDataX()           - returns dataX after the event 
; Chart::EventDataY()           - returns dataY after the event 
; Chart::GetScatterColor()      - returns the color of the scatter plot
; Chart::GetScatterItem()       - returns the value of the item by index [#DataX/#DataY]
; Chart::GetScatterLabelData()  - returns the value of the item by label [#DataX/#DataY]
; Chart::RemoveScatterPlot()    - removes the item by index
; Chart::RemoveScatterItem()    - removes the item by label
; Chart::RemoveScatterLabel()   - removes the data series
; Chart::SetScatterItem()       - sets the values of the item by index
; Chart::SetScatterLabelData()  - sets the values of the item by label

;}

DeclareModule Chart
  
  #Enable_PieChart       = #True
  #Enable_DataSeries     = #True
  #Enable_Horizontal     = #True
  #Enable_LineChart      = #True
  #Enable_ScatterPlot    = #True
  #Enable_ModifyByCursor = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #Percent$ = "{Percent}"
  #Value$   = "{Value}"
  #Label$   = "{Label}"
  #Serie$   = "{Series}"
  #Scatter$ = "{Scatter}"
  #DataX$   = "{DataX}"
  #DataY$   = "{DataY}"
  #Time$    = "{Time}"
  #TimeX$   = "{Time}"
  #TimeY$   = "{TimeY}"
  
  EnumerationBinary
    #BarChart        ; bar chart             (german: "Säulendiagramm")
    #PieChart        ; pie chart             (german: "Tortendiagramm")
    #DataSeries      ; chart for data series (german: "Diagramm für Datenreihen")
    #Horizontal      ; horizontal bars       (german: "Balkendiagramm")
    #LineChart       ; line chart            (german: "Kurvendiagramm")
    #ScatterPlot     ; scatter plot          (german: "Streudiagramm")
    #Legend          ; legend for pie chart / chart for data series
    #PopUpMenu       ; opens the attached popup menu with a rightclick [#BarChart/#PieChart/#Legend]
    #AutoResize      ; Automatic resizing of the gadget
    #Border          ; Gadget border
    #NoBorder        ; Display no bar or pie borders                   [#BarChart/#PieChart]
    #AllDataSeries   ; Show all data series in legend                  [#Legend]
    #ShowLines       ; Show horziontal lines (Y-Axis) 
    #ShowPercent     ; Show percentage value                           [Gadget & #PieChart]
    #ShowValue       ; Show values                                     [Gadget & #PieChart]
    #PostEvents      ; Send post events for legend                     [#Legend]
    #Colored         ; Colored text                                    [#BarChart/#PieChart/#Legend]
    #NoAutoAdjust    ; Don't adjust the max./min. value, if necessary. 
    #Diagonal        ; Gradiant flag for vector drawing
    #Vertical        ; Gradiant flag for vector drawing
    #Descending      ; Descending numbering of the y-axis              [#LineChart]
    #Hide            ; hide legend                                     [#Legend]
    #BezierCurve     ;                                                 [#LineChart]
    #ToolTips        ; show tooltips
    #ChangeCursor    ; change the cursor for clickable areas
    #OutOfRange      ; shows value which are out of ranges
    #ModifyByCursor  ; move data points up and down to change the value [#LineChart]
    #AxisX
    #AxisY
  EndEnumeration
  
  #AllScatterPlots = #AllDataSeries
  
  EnumerationBinary  
    #Time
    #Labels
  EndEnumeration
  
  Enumeration 1    ; [Attribute]
    #Minimum       ; Minimum value
    #Maximum       ; Maximum value
    #MinimumX      ; Minimum value Y
    #MaximumX      ; Maximum value X
    #Width         ; Width of the bars / circle diameter for data points (LineChart)
    #Spacing       ; Spacing between the bars / between chart and legend (PieChart) / between data points (LineChart)
    #Padding       ; Padding between data series bars (DataSeries) / between y-axis and first data (LineChart)
    #ScaleLines    ; Number of scale lines for Y-axis
    #ScaleLinesX   ; Number of scale lines for X-axis
    #ScaleSpacing  ; Spacing of scale lines for Y-axis [#Single/#Double]
    #ScaleSpacingX ; Spacing of scale lines for X-axis [#Single/#Double]
    #LineColor     ; (LineChart)
    #FontSize      ; Value/Percent in Chart (LineChart/PieChart)
    #Decimals      ; decimal places for scatter plot data
  EndEnumeration

  #ScaleLinesY   = #ScaleLines
  #ScaleSpacingY = #ScaleSpacing
  #MinimumY      = #Minimum
  #MaximumY      = #Maximum
    
  #DataX = 1
  #DataY = 2
  
  #Single = 1
  #Double = 2
  
  EnumerationBinary 
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration  
  
  Enumeration 1
    #FrontColor
    #BackColor
    #BorderColor
    #AxisColor
    #BarColor
    #BarBorderColor
    #GradientColor
  EndEnumeration
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget = ModuleEx::#Event_Gadget
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration

  CompilerEndIf
  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================  
  
  CompilerIf #Enable_DataSeries
    
    Declare.i AddDataSeries(GNum.i, Label.s, Color.i=#PB_Default, GradientColor.i=#PB_Default, BorderColor.i=#PB_Default)
    Declare.i AddSeriesItem(GNum.i, Series.s, Label.s, Value.i)
    Declare.i DisplayDataSeries(GNum.i, Series.s, State.i=#True)
    Declare.s EventDataSeries(GNum.i)
    Declare.i GetSeriesColor(GNum.i, Series.s)
    Declare.i GetSeriesItemState(GNum.i, Series.s, Position.i)
    Declare.i GetSeriesLabelState(GNum.i, Series.s, Label.s)
    Declare.i RemoveSeriesItem(GNum.i, Series.s, Position.i)
    Declare.i RemoveSeriesLabel(GNum.i, Series.s, Label.s)
    Declare.i RemoveDataSeries(GNum.i, Series.s) 
    Declare   SetSeriesItemState(GNum.i, Series.s, Position.i, Value.i)
    Declare   SetSeriesLabelState(GNum.i, Series.s, Label.s, Value.i)
    
  CompilerEndIf
  
  CompilerIf #Enable_ScatterPlot

    Declare.i AddScatterPlot(GNum.i, Label.s, Color.i=#PB_Default, GradientColor.i=#PB_Default, BorderColor.i=#PB_Default)
    Declare.i AddScatterItem(GNum.i, Scatter.s, Label.s, DataX.q, DataY.q)
    Declare.i DisplayScatterPlot(GNum.i, Scatter.s, State.i=#True)
    Declare.s EventScatterPlot(GNum.i) 
    Declare.f EventDataX(GNum.i) 
    Declare.f EventDataY(GNum.i) 
    Declare.i GetScatterColor(GNum.i, Scatter.s)
    Declare.i GetScatterItem(GNum.i, Scatter.s, Position.i, Type.i)
    Declare.i GetScatterLabelData(GNum.i, Scatter.s, Label.s, Type.i)
    Declare.i RemoveScatterPlot(GNum.i, Scatter.s)
    Declare.i RemoveScatterItem(GNum.i, Scatter.s, Position.i)
    Declare.i RemoveScatterLabel(GNum.i, Scatter.s, Label.s)
    Declare   SetScatterItem(GNum.i, Scatter.s, Position.i, DataX.q, DataY.q)
    Declare   SetScatterLabelData(GNum.i, Scatter.s, Label.s, DataX.q, DataY.q)
    
  CompilerEndIf  
  
  Declare.i AddAxisLabel(GNum.i, Label.s, Value.f, Type.i=#AxisX)
  Declare.i AddItem(GNum.i, Label.s, Value.i, BarColor.i=#PB_Default, GradientColor.i=#PB_Default, BorderColor.i=#PB_Default)
  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i EventColor(GNum.i) 
  Declare.i EventIndex(GNum.i) 
  Declare.s EventLabel(GNum.i)
  Declare.i EventValue(GNum.i)
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.s GetErrorMessage(GNum.i, Language.s="")
  Declare.i GetItemColor(GNum.i, Position.i)
  Declare.s GetItemLabel(GNum.i, Position.i)
  Declare.i GetItemState(GNum.i, Position.i)
  Declare.s GetItemText(GNum.i, Position.i)
  Declare.i GetLabelColor(GNum.i, Label.s)
  Declare.i GetLabelState(GNum.i, Label.s)
  Declare.i RemoveItem(GNum.i, Position.i)
  Declare   RemoveLabel(GNum.i, Label.s)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Color.i)
  Declare   SetFlags(GNum.i, Type.i, Flags.i)
  Declare   SetFont(GNum.i, FontID.i, Flags.i=#False) 
  Declare.i SetItemState(GNum.i, Position.i, State.i)
  Declare.i SetItemText(GNum.i, Position.i, Text.s)
  Declare.i SetLabelState(GNum.i, Label.s, State.i)
  Declare   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
  Declare   SetMask(GNum.i, Type.i, String.s)
  Declare   ToolTipText(GNum.i, Text.s)
  Declare   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
  
EndDeclareModule

Module Chart
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================  
  
  #NotValid = -1
  #Error    = -2
  
  Enumeration MouseMove
    #Mouse_Released 
    #Mouse_Pressed
  EndEnumeration
  
  Enumeration 1
    #Error_LabelExists
    #Error_LabelUnknown
    #Error_IndexNotValid
    #Error_Minimum
    #Error_Maximum
  EndEnumeration
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure Axis_Label_Structure
    Text.s
    Value.q
  EndStructure
  
  Structure Chart_Axis_Structure
    DateMask.s
    Flags.i
    List Label.Axis_Label_Structure()
  EndStructure
  
  Structure Chart_EventSize_Structure ;{
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure ;}
  
  Structure Chart_Legend_Structure     ;{ Chart()\Legend\...
    FontID.i
    Minimum.i
    Range.i
    Sum.i
    Flags.i
  EndStructure ;}
  
  Structure Chart_Pie_Structure        ;{ Chart()\Pie\...
    X.i
    Y.i
    Radius.i
    Sum.i
    Spacing.i
    FontID.i
    FontSize.i
    Flags.i
  EndStructure ;}
  
  Structure Chart_Line_Structure       ;{ Chart()\Line\...
    Width.i
    Range.i
    Spacing.i
    Padding.i
    ScaleLines.i
    ScaleSpacing.i
    FontSize.i
    FontID.i
    Color.i
    Flags.i
  EndStructure ;}
  
  Structure Chart_Bar_Structure        ;{ Chart()\Bar\...
    Width.i
    Range.i
    Spacing.i
    Padding.i
    ScaleLines.i
    ScaleSpacing.i
    FontID.i
    Flags.i
  EndStructure ;}
  
  Structure Chart_Scatter_Structure    ;{ Chart()\Scatter\...
    MinimumX.i
    MinimumY.i
    MaximumX.i
    MaximumY.i
    ScaleLinesX.i
    ScaleLinesY.i
    ScaleSpacingX.i
    ScaleSpacingY.i
    RangeX.i
    RangeY.i
    Width.i
    ;Spacing.i
    ;Padding.i
    FontSize.i
    FontID.i
    Color.i
    Flags.i
  EndStructure ;}
  
  Structure Chart_Item_Structure       ;{ Chart()\Item()\...
    Label.s
    X.i
    Y.i
    Width.i
    Height.i
    sAngle.f
    eAngle.f
    DataX.q
    DataY.q
    Value.i
    Text.s
    Color.i
    Gradient.i
    Border.i
    Legend.Chart_EventSize_Structure
  EndStructure ;}
  
  Structure Chart_Series_Structure     ;{ Chart()\Series('label')\...
    Label.s
    Visible.i   ; current visible data series
    Color.i
    Gradient.i
    Border.i
    Legend.Chart_EventSize_Structure 
    List Item.Chart_Item_Structure()
    Map  Index.i()
  EndStructure ;}
  
  Structure Chart_Margins_Structure    ;{ Chart()\Margin\...
    Top.i
    Left.i
    Right.i
    Bottom.i
  EndStructure ;}
  
  Structure Chart_Event_Structure      ;{ Chart()\Event\...
    Series.s ; series label
    Label.s  ; item label
    Index.i  ; item index
    Color.i  ; data series color or item color
    Value.i
    DataX.f
    DataY.f
  EndStructure ;}
  
  Structure Chart_Window_Structure     ;{ Chart()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure Chart_Size_Structure       ;{ Chart()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Flags.i
  EndStructure ;} 
  
  Structure Chart_Color_Structure      ;{ Chart()\Color\...
    Front.i
    Back.i
    Axis.i
    Bar.i
    BarBorder.i
    Gradient.i
    Border.i
  EndStructure  ;}
  
  Structure Chart_Mouse_Structure      ;{ Chart()\Cursor\...
    downY.i
    Current.i
    State.i
  EndStructure ;}
  
  Structure Chart_Currrent_Structure   ;{ Chart()\Currrent\...
    pFactorY.f
    nFactorY.f
    pFactorX.f
    nFactorX.f
    MinimumY.i
    MaximumY.i
    MinimumX.i
    MaximumX.i
    Offset.i
  EndStructure ;}
  
  Structure Chart_Structure            ;{ Chart()\...
    CanvasNum.i
    PopupNum.i
    
    FontID.i
    
    Minimum.i
    Maximum.i
    Decimals.i
    
    AxisX.Chart_Axis_Structure
    AxisY.Chart_Axis_Structure
    Bar.Chart_Bar_Structure
    Current.Chart_Currrent_Structure
    Pie.Chart_Pie_Structure
    Line.Chart_Line_Structure
    Legend.Chart_Legend_Structure
    
    Color.Chart_Color_Structure
    Mouse.Chart_Mouse_Structure
    Event.Chart_Event_Structure
    Margin.Chart_Margins_Structure
    Window.Chart_Window_Structure
    Scatter.Chart_Scatter_Structure
    Size.Chart_Size_Structure
    EventSize.Chart_EventSize_Structure
    
    Flags.i
    
    List VisibleData.i()                 ; visible data series (labels)
    List Series.Chart_Series_Structure() ; data series
    List Item.Chart_Item_Structure()
    
    Map  Index.i()                       ; labels with list index
    Map  VisibleIndex.i()                ; labels with list index (VisibleData)
    Map  PopUpItem.s()
    
    ToolTipText.s
    
    ReDraw.i
    Error.i
    ToolTip.i
  EndStructure ;}
  Global NewMap Chart.Chart_Structure()
  
  
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
  
  
  Procedure.s GetText_(Text.s)
    Define.f Percent
    Define.s Text$ = ""
    
    If Chart()\Flags & #DataSeries
      
      If Text
        
        If Chart()\Flags & #LineChart
          Percent = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * 100
          If Percent <> 0
            Percent = (Percent / Chart()\Line\Range)
          Else
            Percent = 0
          EndIf
        Else
          Percent = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * 100
          If Percent <> 0
            Percent = (Percent / Chart()\Bar\Range)
          Else
            Percent = 0
          EndIf
        EndIf
        Text$ = ReplaceString(Text,  #Percent$, Str(Percent) + "%")
        Text$ = ReplaceString(Text$, #Value$, Str(Chart()\Series()\Item()\Value))
        Text$ = ReplaceString(Text$, #Label$, Chart()\Series()\Item()\Label)
        Text$ = ReplaceString(Text$, #Serie$, Chart()\Series()\Label)
      EndIf
      
    ElseIf Chart()\Flags & #PieChart

      If Text
        If Chart()\Pie\Sum <> 0
          Percent = Chart()\Item()\Value / Chart()\Pie\Sum
        Else  
          Percent = 0
        EndIf
        Text$ = ReplaceString(Text,  #Percent$, Str(Percent * 100) + "%")
        Text$ = ReplaceString(Text$, #Value$, Str(Chart()\Series()\Item()\Value))
        Text$ = ReplaceString(Text$, #Label$, Chart()\Series()\Item()\Label)
        Text$ = ReplaceString(Text$, #Serie$, Chart()\Series()\Label)
      EndIf
      
    ElseIf Chart()\Flags & #ScatterPlot
      
      If Text
        Text$ = ReplaceString(Text,  #Value$,   Str(Chart()\Series()\Item()\DataX) + "/" + Str(Chart()\Series()\Item()\DataY))
        Text$ = ReplaceString(Text$, #Label$,   Chart()\Series()\Item()\Label)
        Text$ = ReplaceString(Text$, #Serie$,   Chart()\Series()\Label)
        Text$ = ReplaceString(Text$, #Scatter$, Chart()\Series()\Label)
        Text$ = ReplaceString(Text$, #DataX$,   StrF(Chart()\Series()\Item()\DataX), Chart()\Decimals)
        Text$ = ReplaceString(Text$, #DataY$,   StrF(Chart()\Series()\Item()\DataY), Chart()\Decimals)
        Text$ = ReplaceString(Text$, #TimeX$,   FormatDate(Chart()\AxisX\DateMask, Int(Chart()\Series()\Item()\DataX)))
        Text$ = ReplaceString(Text$, #TimeY$,   FormatDate(Chart()\AxisY\DateMask, Int(Chart()\Series()\Item()\DataY)))
      EndIf
      
    ElseIf Chart()\Flags & #LineChart 
      
      Percent = (Chart()\Item()\Value - Chart()\Current\MinimumY) * 100
      If Percent <> 0
        Percent = (Percent / Chart()\Line\Range)
      Else
        Percent = 0
      EndIf
      If Text
        Text$ = ReplaceString(Text,  #Percent$, Str(Percent) + "%")
        Text$ = ReplaceString(Text$, #Value$, Str(Chart()\Item()\Value))
        Text$ = ReplaceString(Text$, #Label$, Chart()\Item()\Label)
      EndIf
      
    Else
      
      Percent = (Chart()\Item()\Value - Chart()\Current\MinimumY) * 100
      If Percent <> 0
        Percent = (Percent / Chart()\Bar\Range)
      Else
        Percent = 0
      EndIf
      If Text
        Text$ = ReplaceString(Text,  #Percent$, Str(Percent) + "%")
        Text$ = ReplaceString(Text$, #Value$, Str(Chart()\Item()\Value))
        Text$ = ReplaceString(Text$, #Label$, Chart()\Item()\Label)
      EndIf
      
    EndIf
    
    ProcedureReturn Text$
  EndProcedure
  
  Procedure.s FormatValue_(Value.f, Type.i=#False) 
   
    Select Type
      Case #AxisX
        If Chart()\AxisX\Flags & #Time
          ProcedureReturn FormatDate(Chart()\AxisX\DateMask, Int(Value))
        Else
          ProcedureReturn StrF(Value, Chart()\Decimals)
        EndIf 
      Case #AxisY
        If Chart()\AxisY\Flags & #Time
          ProcedureReturn FormatDate(Chart()\AxisY\DateMask, Int(Value))
        Else
          ProcedureReturn StrF(Value, Chart()\Decimals)
        EndIf 
      Default
        ProcedureReturn StrF(Value, Chart()\Decimals)
    EndSelect
    
  EndProcedure
  
  Procedure   UpdatePopUpMenu_()
    Define.s Text$
    
    ForEach Chart()\PopUpItem()
      Text$ = GetText_(Chart()\PopUpItem())
      SetMenuItemText(Chart()\PopupNum, Val(MapKey(Chart()\PopUpItem())), Text$)
    Next
    
  EndProcedure
    
  Procedure.i MaxLabelWidth_()
    Define.i MaxWidth
    
    ForEach Chart()\Item()
      If TextWidth(Chart()\Item()\Label) > MaxWidth
        MaxWidth = TextWidth(Chart()\Item()\Label)
      EndIf
    Next
    
    ProcedureReturn MaxWidth
  EndProcedure

  Procedure.i MaximumValue_(X.i=#False)
    Define.i MaxValue
    
    If Chart()\Flags & #DataSeries      ;{ DataSeries
      
      MaxValue = Chart()\Maximum
      
      ForEach Chart()\VisibleData()
        If SelectElement(Chart()\Series(), Chart()\VisibleData())
          ForEach Chart()\Series()\Item()
            If Chart()\Series()\Item()\Value > MaxValue
              MaxValue = Chart()\Series()\Item()\Value
            EndIf
          Next
        EndIf    
      Next
      ;}
    ElseIf Chart()\Flags & #ScatterPlot ;{ ScatterPlot
      
      If X
        
        MaxValue = Chart()\Scatter\MaximumX
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              If Chart()\Series()\Item()\DataX > MaxValue
                MaxValue = Chart()\Series()\Item()\DataX
              EndIf
            Next
          EndIf    
        Next
        
      Else
        
        MaxValue = Chart()\Scatter\MaximumY
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              If Chart()\Series()\Item()\DataY > MaxValue
                MaxValue = Chart()\Series()\Item()\DataY
              EndIf
            Next
          EndIf    
        Next        
        
      EndIf
      ;}
    Else                                ;{ other Charts
      
      MaxValue = Chart()\Maximum
      
      ForEach Chart()\Item()
        If Chart()\Item()\Value > MaxValue
          MaxValue = Chart()\Item()\Value
        EndIf
      Next
      ;}
    EndIf
  
    ProcedureReturn MaxValue
  EndProcedure
  
  Procedure.i MinimumValue_(X.i=#False)
    Define.i MinValue

    If Chart()\Flags & #DataSeries      ;{ DataSeries
      
      MinValue = Chart()\Minimum
      
      ForEach Chart()\VisibleData()
        If SelectElement(Chart()\Series(), Chart()\VisibleData())
          ForEach Chart()\Series()\Item()
            If Chart()\Series()\Item()\Value < MinValue
              MinValue = Chart()\Series()\Item()\Value
            EndIf
          Next
        EndIf   
      Next
      ;}
    ElseIf Chart()\Flags & #ScatterPlot ;{ ScatterPlot
      
      If X
        
        MinValue = Chart()\Scatter\MinimumX
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              If Chart()\Series()\Item()\DataX < MinValue
                MinValue = Chart()\Series()\Item()\DataX
              EndIf
            Next
          EndIf   
        Next        
        
      Else
        
        MinValue = Chart()\Scatter\MinimumY
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              If Chart()\Series()\Item()\DataY < MinValue
                MinValue = Chart()\Series()\Item()\DataY
              EndIf
            Next
          EndIf   
        Next 
        
      EndIf
      ;}
    Else                                ;{ other Charts
      
      MinValue = Chart()\Minimum
      
      ForEach Chart()\Item()
        If Chart()\Item()\Value < MinValue
          MinValue = Chart()\Item()\Value
        EndIf
      Next
      ;}
    EndIf
    
    ProcedureReturn MinValue
  EndProcedure

  Procedure.i MaximumItems_()
    Define.i Number
    
    ForEach Chart()\VisibleData()
      If SelectElement(Chart()\Series(), Chart()\VisibleData())
        If Number < ListSize(Chart()\Series()\Item())
          Number = ListSize(Chart()\Series()\Item())
        EndIf
      EndIf  
    Next
    
    ProcedureReturn Number
  EndProcedure
  
  
  Procedure.i CalcScaleLines_(ScaleLines.i, Range.i) 
    Define.i n
    
    If Range >= 10 And Mod(Range, 10) = 0 And Range / 10 <= ScaleLines
      
      ScaleLines = Range / 10
      
    ElseIf Range >= 5 And Mod(Range, 5) = 0 And Range / 5 <= ScaleLines
      
      ScaleLines = Range / 5
      
    Else

      If Range >= ScaleLines
        For n = ScaleLines To Int(ScaleLines / 2) Step -1
          If Mod(Range, n) = 0
            ScaleLines = n
            Break
          EndIf
        Next
      Else
        ScaleLines = Range
      EndIf 
    EndIf 
    
    ProcedureReturn ScaleLines
  EndProcedure
  
  Procedure.f GetAngleDegree_(X.i, Y.i, cX.i=0, cY.i=0)
    Define.i aX, aY
    Define.f Angle
    
    aX = X - cX
    aY = Y - cY
  
    Angle = ATan2(aX, aY)
    
    If Angle >= 0
      ProcedureReturn Degree(Angle)
    Else
      ProcedureReturn 360 + Degree(Angle)
    EndIf
  
  EndProcedure

  Procedure.i SumValue_()
    Define.i Sum = 0
    
    ForEach Chart()\Item()
      If Chart()\Item()\Value > 0 : Sum + Chart()\Item()\Value : EndIf 
    Next
    
    ProcedureReturn Sum
  EndProcedure

  ;- _______ Vector Drawing _______
  
  Procedure Box_(X.i, Y.i, Width.i, Height.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default, Flags.i=#False)
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
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
    StrokePath(1)
    
  EndProcedure
  
  Procedure Circle_(X.i, Y.i, Radius.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default)

    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    AddPathCircle(X, Y, Radius)
    
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
    StrokePath(1)
  
  EndProcedure
  
  Procedure CircleSector_(X.i, Y.i, Radius.i, startAngle.i, endAngle.i, Color.q, FillColor.q=#PB_Default, GradientColor.q=#PB_Default)

    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf

    MovePathCursor(X, Y)
    AddPathCircle(X, Y, Radius, startAngle, endAngle, #PB_Path_Connected)
    ClosePath()
    
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
    StrokePath(1)
    
  EndProcedure
  
  Procedure LineXY_(X1.f, Y1.f, X2.f, Y2.f, Color.q)
    
    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    MovePathCursor(X1, Y1)
    AddPathLine(X2, Y2)
    VectorSourceColor(Color)
    StrokePath(1)
    
  EndProcedure
  
  Procedure Text_(X.i, Y.i, Text$, Color.q, Angle.i=0)

    If Alpha(Color) = #False : Color = RGBA(Red(Color), Green(Color), Blue(Color), 255) : EndIf
    
    If Angle : RotateCoordinates(X, Y, Angle) : EndIf
    
    MovePathCursor(X, Y)
    VectorSourceColor(Color)
    DrawVectorText(Text$)

    If Angle : RotateCoordinates(X, Y, -Angle) : EndIf
    
  EndProcedure
  
  ;- __________ Drawing __________
  
  Procedure.q AlphaColor_(Color.i, Alpha.i)
    ProcedureReturn RGBA(Red(Color), Green(Color), Blue(Color), Alpha)
  EndProcedure 
  
  Procedure.q Alpha_(Color.i)
    ProcedureReturn RGBA(Red(Color), Green(Color), Blue(Color), 255)
  EndProcedure
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure.i Value_(Y.i) 
    Define.i Value
    
    Y - Chart()\Margin\Top - Chart()\Current\Offset
    
    If Chart()\Current\MinimumY < 0
      
      If Y < 0
        Value = Round(Chart()\Current\MinimumY - (Y / Chart()\Current\nFactorY), #PB_Round_Nearest)
      Else
        Value = Round(Chart()\Current\MaximumY - (Y / Chart()\Current\pFactorY), #PB_Round_Nearest)
      EndIf
      
    Else

      If Chart()\Line\Flags & #Descending
        Value = Round((Y / Chart()\Current\pFactorY) + Chart()\Current\MinimumY, #PB_Round_Nearest)
      Else
        Value = Round(Chart()\Current\MaximumY - (Y / Chart()\Current\pFactorY), #PB_Round_Nearest)
      EndIf

    EndIf 
    
    If Value < Chart()\Current\MinimumY : Value = Chart()\Current\MinimumY : EndIf 
    If Value > Chart()\Current\MaximumY : Value = Chart()\Current\MaximumY : EndIf 
    
    ProcedureReturn Value
  EndProcedure

  CompilerIf #Enable_LineChart
    
    Procedure   DrawLineChart_(X.i, Y.i, Width.i, Height.i)
      Define.i PosX, PosY, sWidth, cWidth, cHeight, nHeight, pHeight, lastX, lastY, xW3
      Define.i txtX, txtY, txtWidth, txtHeight, axisY, Radius
      Define.i n, Items, Spaces, ScaleLines, AlphaColor, Color, Gradient, maxValue, minValue
      Define.f SpaceY, Factor, Calc
      Define.s Text$, Percent$
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
        
        DrawingFont(Chart()\FontID)

        Chart()\Current\MaximumY = Chart()\Maximum ;{ Maximum
        maxValue = MaximumValue_()
        If Chart()\Current\MaximumY = #PB_Default
          Chart()\Current\MaximumY = maxValue
        ElseIf Chart()\Line\Flags & #NoAutoAdjust = #False
          Chart()\Current\MaximumY = Chart()\Maximum
          If maxValue > Chart()\Current\MaximumY : Chart()\Current\MaximumY = maxValue : EndIf
        EndIf ;}
        
        Chart()\Current\MinimumY = Chart()\Minimum ;{ Minimum
        minValue = MinimumValue_()
        If Chart()\Current\MinimumY = #PB_Default
          Chart()\Current\MinimumY = minValue
        ElseIf Chart()\Line\Flags & #NoAutoAdjust = #False
          If minValue < Chart()\Current\MinimumY : Chart()\Current\MinimumY = minValue : EndIf
        EndIf ;}
       
        txtHeight = TextHeight("Abc")
        txtWidth  = TextWidth(Str(Chart()\Current\MaximumY))
        
        X  + txtWidth + dpiX(2)
        Y  + (txtHeight / 2)

        Width  - txtWidth - dpiX(2)
        Height - (txtHeight * 1.5) - dpiY(3)
        
        Chart()\Current\Offset = txtHeight / 2
        
        Chart()\EventSize\X = X
        Chart()\EventSize\Y = Y
        Chart()\EventSize\Width  = Width
        Chart()\EventSize\Height = Height
        
        Chart()\Line\Range = Chart()\Current\MaximumY - Chart()\Current\MinimumY
        
        ;{ --- Calc Height for positive and negative Values ---
        If Chart()\Current\MinimumY < 0
          Factor = Height / Chart()\Line\Range
          pHeight  = Factor * Chart()\Current\MaximumY ; positiv
          nHeight  = Factor * Chart()\Current\MinimumY ; negativ 
        Else
          pHeight = Height ; positiv
          nHeight = 0      ; negativ
        EndIf ;}
      
        ;{ --- Calc Spacing Width ---
        Items  = ListSize(Chart()\Item())
        Spaces = Items - 1
        
        If Chart()\Line\Width = #PB_Default And Chart()\Line\Spacing = #PB_Default
          cWidth = dpiX(6)
          If Items > 0 : sWidth = Round((Width - (cWidth * Items) - (Chart()\Line\Padding * 2)) / Spaces, #PB_Round_Nearest) : EndIf
        ElseIf Chart()\Line\Width = #PB_Default
          cWidth = dpiX(6)
          sWidth = Chart()\Line\Spacing
        ElseIf Chart()\Line\Spacing = #PB_Default
          cWidth = Chart()\Line\Width
          sWidth = Round((Width - (cWidth * Items) - (Chart()\Line\Padding * 2)) / Spaces, #PB_Round_Nearest)
        Else  
          cWidth = Chart()\Line\Width
          sWidth = Chart()\Line\Spacing
        EndIf ;}
    
        ;{ --- Draw Coordinate Axes ---
        DrawingMode(#PB_2DDrawing_Transparent)
        
        Line(X, Y, 1, Height, Chart()\Color\Axis)
        
        If Chart()\Line\ScaleLines = #PB_Default
          If Chart()\Line\ScaleSpacing = 0 : Chart()\Line\ScaleSpacing = 1 : EndIf
          ScaleLines = Height / (txtHeight * Chart()\Line\ScaleSpacing)
          ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Line\Range)
        Else
          ScaleLines = Chart()\Line\ScaleLines
        EndIf
  
        If ScaleLines
          
          Factor = Chart()\Line\Range  / ScaleLines
          SpaceY = Height / ScaleLines
  
          For n = 0 To ScaleLines
            PosY = Y + Round(n * SpaceY, #PB_Round_Nearest)
            If Chart()\Flags & #ShowLines
              Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
            EndIf 
            Line(X - dpiX(2), PosY, dpiX(5), 1, Chart()\Color\Axis)
            If Chart()\Line\Flags & #Descending
              Text$ = Str((Factor * n) + Chart()\Current\MinimumY)
            Else
              Text$ = Str(Chart()\Current\MaximumY - (Factor * n))
            EndIf
            txtX = X - TextWidth(Text$) - dpix(4)
            txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
            DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          Next
          
          Line(X, Y + pHeight, Width, 1, Chart()\Color\Axis)
          
        EndIf ;} 
        
        StopDrawing()
      EndIf 
    
      If StartVectorDrawing(CanvasVectorOutput(Chart()\CanvasNum))

        Radius = cWidth / 2
        
        ;{ --- Draw Lines ---
        PosX = X + Chart()\Line\Padding
        
        AlphaColor = RGBA(Red(Chart()\Line\Color), Green(Chart()\Line\Color), Blue(Chart()\Line\Color), 140)
        
        xW3 = Round((cWidth + sWidth) / 3, #PB_Round_Nearest)
        
        If Chart()\Line\Flags & #OutOfRange
          SaveVectorState()
          AddPathBox(X, Y, Width, Height)
          ClipPath()
        EndIf
        
        ForEach Chart()\Item()
          
          If (Chart()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Item()\Value <= Chart()\Current\MaximumY) Or Chart()\Line\Flags & #OutOfRange
            
            ;{ --- Calc Position & Height ---
            If Chart()\Current\MinimumY < 0
              
              If Chart()\Item()\Value < 0
                PosY = Y + pHeight + dpiY(1)
                Factor = nHeight / Chart()\Current\MinimumY
                cHeight = Chart()\Item()\Value * Factor
                If Chart()\Item()\Value < Chart()\Current\MinimumY : cHeight = - SpaceY : EndIf
              Else
                PosY = Y + pHeight
                Factor = pHeight / Chart()\Current\MaximumY
                cHeight = Chart()\Item()\Value * Factor
                If Chart()\Item()\Value < Chart()\Current\MinimumY
                  cHeight = - SpaceY   
                ElseIf Chart()\Item()\Value > Chart()\Current\MaximumY
                  cHeight = (Chart()\Current\MaximumY -  Chart()\Current\MinimumY) * Factor + SpaceY
                EndIf 
              EndIf

            Else
              
              PosY = Y + pHeight
              Factor = Height / Chart()\Line\Range
              If Chart()\Line\Flags & #Descending
                cHeight = (Chart()\Current\MaximumY - (Chart()\Item()\Value)) * Factor
                If Chart()\Item()\Value < Chart()\Current\MinimumY
                  cHeight = (Chart()\Current\MaximumY -  Chart()\Current\MinimumY) * Factor + SpaceY
                ElseIf Chart()\Item()\Value > Chart()\Current\MaximumY
                  cHeight = - SpaceY   
                EndIf 
              Else
                cHeight = (Chart()\Item()\Value - Chart()\Current\MinimumY) * Factor
                If Chart()\Item()\Value < Chart()\Current\MinimumY
                  cHeight = - SpaceY   
                ElseIf Chart()\Item()\Value > Chart()\Current\MaximumY
                  cHeight = (Chart()\Current\MaximumY -  Chart()\Current\MinimumY) * Factor + SpaceY
                EndIf 
              EndIf
              
            EndIf ;} 
            
            If ListIndex(Chart()\Item()) = 0
              MovePathCursor(PosX + Radius, PosY - cHeight)
            Else
              If Chart()\Line\Flags & #BezierCurve
                AddPathCurve(lastX + xW3, LastY, PosX + Radius - xW3, PosY - cHeight, PosX + Radius, PosY - cHeight)
              Else
                AddPathLine(PosX + Radius, PosY - cHeight)
              EndIf  
            EndIf

            LastX = PosX + Radius : LastY = PosY - cHeight
          EndIf
          
          PosX + cWidth + sWidth
        Next 
        
        VectorSourceColor(AlphaColor)
        StrokePath(2, #PB_Path_RoundCorner)
        
        If Chart()\Line\Flags & #OutOfRange : RestoreVectorState() : EndIf
        ;}
      
        PosX = X + Chart()\Line\Padding
        
        ForEach Chart()\Item()
          
          ;{ --- Calc Position & Height ---
          If Chart()\Current\MinimumY < 0
            If Chart()\Item()\Value < 0
              PosY = Y + pHeight + dpiY(1)
              Factor = nHeight / Chart()\Current\MinimumY
              Chart()\Current\nFactorY= Factor
            Else
              PosY = Y + pHeight
              Factor = pHeight / Chart()\Current\MaximumY
              Chart()\Current\pFactorY= Factor
            EndIf
            cHeight = Chart()\Item()\Value * Factor
          Else
            PosY = Y + pHeight
            Factor = Height / Chart()\Line\Range
            If Chart()\Line\Flags & #Descending
              cHeight = (Chart()\Current\MaximumY - (Chart()\Item()\Value)) * Factor
            Else
              cHeight = (Chart()\Item()\Value - Chart()\Current\MinimumY) * Factor
            EndIf
            Chart()\Current\pFactorY= Factor
          EndIf ;}
          
          Chart()\Current\MaximumY = Chart()\Current\MaximumY
          
          ;{ --- Set text for #ShowValue or #ShowPercent ---
          Calc = (Chart()\Item()\Value - Chart()\Current\MinimumY) * 100
          If Calc <> 0
            Percent$ = Str((Calc / Chart()\Line\Range)) + "%"
          Else
            Percent$ = "0%"
          EndIf
          
          If Chart()\Flags & #ShowValue
            Text$ = Str(Chart()\Item()\Value)
          ElseIf Chart()\Flags & #ShowPercent  
            Text$ = Percent$
          Else
            Text$ = GetText_(Chart()\Item()\Text)
          EndIf ;}
          
          ;{ --- Draw Circles ---
          Color = Chart()\Item()\Color
          If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
          
          If Chart()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Item()\Value <= Chart()\Current\MaximumY

            Circle_(PosX + Radius, PosY - cHeight, Radius, BlendColor_(Color, Chart()\Color\Border, 50), Color)
            
            ;{ --- Set data ----
            Chart()\Item()\X      = PosX
            Chart()\Item()\Y      = PosY - cHeight - Radius
            Chart()\Item()\Width  = cWidth
            Chart()\Item()\Height = cWidth
            ;}
            
          Else
            Chart()\Item()\X      = 0
            Chart()\Item()\Y      = 0
            Chart()\Item()\Width  = 0
            Chart()\Item()\Height = 0
            cHeight = 0
            Chart()\Item()\Height = cHeight
            Color = #Error
          EndIf ;}

          ;{ --- Draw Text ---
          If Text$ 
            
            If Chart()\Line\FontSize = #PB_Default
              VectorFont(Chart()\Line\FontID)
            Else
              VectorFont(Chart()\Line\FontID, dpiY(Chart()\Line\FontSize))
            EndIf
            
            txtX = PosX + ((cWidth - VectorTextWidth(Text$)) / 2)
            
            If Chart()\Item()\Value < 0
              txtY = PosY - VectorTextHeight(Text$) - dpiY(2)
            Else
              txtY = PosY - cHeight - VectorTextHeight(Text$) - dpiY(2)
            EndIf

            If Color = #Error
              Text_(txtX, Y + Height - VectorTextHeight(Text$) - dpiY(2), Text$, $0000FF)
            Else
              Text_(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 40))
            EndIf  
            
          EndIf ;}
  
          PosX + cWidth + sWidth
        Next
        
        StopVectorDrawing()
      EndIf
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
        
        DrawingFont(Chart()\FontID)
        
        PosX = X + Chart()\Line\Padding
        
        ForEach Chart()\Item()
          
          ;{ --- Draw Labels ---
          Text$ = Chart()\Item()\Label
          txtX  = PosX + ((Radius - TextWidth(Text$)) / 2)
          txtY  = Y + Height + dpiY(3)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          Color = Chart()\Item()\Color
          If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
          
          If Chart()\Line\Flags & #Colored
            DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 30))
          Else
            DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          EndIf ;}
          
          PosX + cWidth + sWidth
        Next
        
        StopDrawing()
      EndIf
      
    EndProcedure
    
  CompilerEndIf 

  CompilerIf #Enable_PieChart

    Procedure   DrawPieChart(X.i, Y.i, Width.i, Height.i)
      Define.i Radius, Number, Color, maxWidth, Spacing
      Define.i lX, lY, pX, pY, lHeight, lWidth, txtX, txtWidth, txtHeight, PosX, PosY
      Define.f Factor, Angle, startAngle, endAngle
      Define.s Text$, Percent$

      Radius = Height / 2
  
      X + Radius
      Y + Radius
      
      Chart()\Pie\X = X
      Chart()\Pie\Y = Y
      Chart()\Pie\Radius = Radius
      
      Chart()\EventSize\X = X
      Chart()\EventSize\Y = Y
      Chart()\EventSize\Width  = Radius * 2
      Chart()\EventSize\Height = Radius * 2
      
      If StartVectorDrawing(CanvasVectorOutput(Chart()\CanvasNum))
        
        Chart()\Pie\Sum = SumValue_()
        If Chart()\Pie\Sum > 0
          
          ;{ --- Draw Pie Chart ---
          startAngle = 0
          endAngle   = 0
          
          maxWidth = 0

          ForEach Chart()\Item()
            
            If Chart()\Item()\Value <= 0 : Continue : EndIf
            
            If Chart()\Pie\Flags & #NoBorder = #False
              Color = BlendColor_(Chart()\Item()\Color, Chart()\Color\Axis, 50)
            Else
              Color = Chart()\Item()\Color
            EndIf
            
            If Chart()\Pie\Sum
              Factor  = Chart()\Item()\Value / Chart()\Pie\Sum
              Percent$ = Str(Factor * 100) + "%"
            Else
              Percent$ = "0%"
            EndIf 
            
            startAngle = endAngle
            endAngle   = startAngle + (Factor * 360)
            
            CircleSector_(X, Y, Radius, startAngle, endAngle, Color, Chart()\Item()\Color, BlendColor_(Chart()\Item()\Color, Chart()\Color\Back, 60))
            
            Chart()\Item()\sAngle = startAngle
            Chart()\Item()\eAngle = endAngle
            
            If Chart()\Pie\Flags & #ShowPercent Or Chart()\Pie\Flags & #ShowValue ;{ Draw Text
              
              If Chart()\Pie\FontSize = #PB_Default
                VectorFont(Chart()\Pie\FontID)
              Else
                VectorFont(Chart()\Pie\FontID, dpiY(Chart()\Pie\FontSize))
              EndIf

              If Chart()\Pie\Flags & #ShowPercent
                Text$ = Percent$
              Else
                Text$ = Str(Chart()\Item()\Value)
              EndIf
              
              txtWidth  = VectorTextWidth(Text$)
              txtHeight = VectorTextHeight(Text$)
              
              Angle = Radian(startAngle + ((endAngle - startAngle) / 2))
              pX = (Radius - txtWidth) * Cos(Angle) - (txtHeight / 2)
              pY = (Radius - txtWidth) * Sin(Angle) - (txtHeight / 2)
              
              Text_(X + pX, Y + pY, Text$, BlendColor_(Chart()\Item()\Color, Chart()\Color\Front, 50))
              ;}
            EndIf

          Next
          ;}
          
        EndIf
        
        StopVectorDrawing()
      EndIf
      
      If Chart()\Legend\Flags & #Hide = #False
        
        If StartDrawing(CanvasOutput(Chart()\CanvasNum))  
          
          DrawingFont(Chart()\FontID)
          
          If Chart()\Pie\Sum > 0
            
            ;{ --- Calc max. legend  text width ---
            ForEach Chart()\Item()
              
              If Chart()\Flags & #ShowPercent
                Factor   = Chart()\Item()\Value / Chart()\Pie\Sum
                Percent$ = Str(Factor * 100) + "%"
                Text$ = ":  " + Percent$
              ElseIf Chart()\Flags & #ShowValue
                Text$ = ":  " + Str(Chart()\Item()\Value)
              Else
                Text$ = GetText_(Chart()\Item()\Text)
              EndIf
              
              Text$ = Chart()\Item()\Label + Text$
              If maxWidth < TextWidth(Text$) : maxWidth = TextWidth(Text$) : EndIf
              
            Next ;}
            
            ;{ --- Draw Legend ---
            DrawingFont(Chart()\Legend\FontID)
            txtHeight = TextHeight("Abc")
            
            Number = ListSize(Chart()\Item())
  
            Spacing = Chart()\Pie\Spacing
            If Spacing = #PB_Default : Spacing = Chart()\Margin\Left : EndIf
      
            lX = X + Radius + Spacing
            
            lHeight = (txtHeight * 1.5) * (Number + 1)
            lWidth  = maxWidth + (txtHeight * 3) + dpiX(5)
            
            lY = (Chart()\Size\Height - lHeight) / 2
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(lX, lY, lWidth, lHeight, $FFFFFF)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(lX, lY, lWidth, lHeight, Chart()\Color\Border)
      
            PosX = lX + txtHeight
            PosY = lY + txtHeight
            
            ForEach Chart()\Item()
              
              If Chart()\Item()\Value <= 0 : Continue : EndIf
      
              DrawingMode(#PB_2DDrawing_Default)
              Box(PosX, PosY, txtHeight, txtHeight, Chart()\Item()\Color)
              
              DrawingMode(#PB_2DDrawing_Outlined)
              Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Item()\Color, Chart()\Color\Border, 40))
              
              Chart()\Item()\Legend\X      = PosX
              Chart()\Item()\Legend\Y      = PosY
              Chart()\Item()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Item()\Label)
              Chart()\Item()\Legend\Height = txtHeight
              
              DrawingMode(#PB_2DDrawing_Transparent)
              
              If Chart()\Pie\Sum
                Factor   = Chart()\Item()\Value / Chart()\Pie\Sum
                Percent$ = Str(Factor * 100) + "%"
              Else
                Percent$ = "0%"
              EndIf
              
              If Chart()\Legend\Flags & #Colored
                Color = BlendColor_(Chart()\Item()\Color, Chart()\Color\Front, 80)
              Else
                Color = Chart()\Color\Front
              EndIf
              
              If Chart()\Flags & #ShowPercent
                txtX = lWidth - txtHeight - TextWidth(Str(Factor * 100) + "%")
                DrawText(PosX + txtHeight + dpiX(5), PosY, Chart()\Item()\Label + ":  ", Chart()\Color\Front)
                DrawText(lX + txtX, PosY, Percent$,  Color)
              ElseIf Chart()\Flags & #ShowValue
                txtX = lWidth - txtHeight - TextWidth(Str(Chart()\Item()\Value))
                DrawText(PosX + txtHeight + dpiX(5), PosY, Chart()\Item()\Label + ":  ", Chart()\Color\Front)
                DrawText(lX + txtX, PosY, Str(Chart()\Item()\Value), Color)
              Else
                Text$ = GetText_(Chart()\Item()\Text)
                txtX = TextWidth(Chart()\Item()\Label)
                DrawText(PosX + txtHeight + dpiX(5), PosY, Chart()\Item()\Label, Chart()\Color\Front)
                DrawText(lX + txtX, PosY, Text$, Color)
              EndIf 
      
              PosY + (txtHeight * 1.5)
              
            Next
            ;}
            
          EndIf
          
          StopDrawing()
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_ScatterPlot
    
    Procedure    DrawScatterPlot(X.i, Y.i, Width.i, Height.i)
      Define.i axisY, seriesX, xW3, lastX, lastY, lX, lY
      Define.i txtX, txtY, txtWidth, txtWidthX, txtHeight, lHeight, lWidth, lTextWidth
      Define.i n, Items, Spaces, ScaleLines, Color, Gradient, maxValue, minValue, Series
      Define.q AlphaColor
      Define.d Factor, Value, Calc
      Define.f PosX, PosY, SpaceX, SpaceY, cWidth, nWidth, nHeight, pWidth, pHeight, Radius
      Define.s Text$, Percent$
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
        
        DrawingFont(Chart()\FontID)
        
        Chart()\Current\MaximumX = Chart()\Scatter\MaximumX ;{ MaximumX
        maxValue = MaximumValue_(#True)
        If Chart()\Current\MaximumX = #PB_Default
          Chart()\Current\MaximumX = maxValue
        ElseIf Chart()\Scatter\Flags & #NoAutoAdjust = #False
          Chart()\Current\MaximumX = Chart()\Scatter\MaximumX
          If maxValue > Chart()\Current\MaximumX : Chart()\Current\MaximumX = maxValue : EndIf
        EndIf ;}
        
        Chart()\Current\MaximumY = Chart()\Scatter\MaximumY ;{ MaximumY
        maxValue = MaximumValue_()
        If Chart()\Current\MaximumY = #PB_Default
          Chart()\Current\MaximumY = maxValue
        ElseIf Chart()\Scatter\Flags & #NoAutoAdjust = #False
          Chart()\Current\MaximumY = Chart()\Scatter\MaximumY
          If maxValue > Chart()\Current\MaximumY : Chart()\Current\MaximumY = maxValue : EndIf
        EndIf ;}
        
        Chart()\Current\MinimumX = Chart()\Scatter\MinimumX ;{ MinimumX
        minValue = MinimumValue_(#True)
        If Chart()\Current\MinimumX = #PB_Default
          Chart()\Current\MinimumX = minValue
        ElseIf Chart()\Scatter\Flags & #NoAutoAdjust = #False
          If minValue < Chart()\Current\MinimumX : Chart()\Current\MinimumX = minValue : EndIf
        EndIf ;}
        
        Chart()\Current\MinimumY = Chart()\Scatter\MinimumY ;{ MinimumY
        minValue = MinimumValue_()
        If Chart()\Current\MinimumY = #PB_Default
          Chart()\Current\MinimumY = minValue
        ElseIf Chart()\Scatter\Flags & #NoAutoAdjust = #False
          If minValue < Chart()\Current\MinimumY : Chart()\Current\MinimumY = minValue : EndIf
        EndIf ;}

        txtHeight = TextHeight("Abc")
        txtWidth  = TextWidth(FormatValue_(Chart()\Current\MaximumY, #AxisY))
        txtWidthX = TextWidth(FormatValue_(Chart()\Current\MaximumY, #AxisX))
        
        If txtWidthX / 2 > txtWidth : txtWidth = txtWidthX / 2 : EndIf  
        
        X  + txtWidth + dpiX(2)
        Y  + (txtHeight / 2)
        
        If Chart()\Legend\Flags & #Hide
          lHeight = -dpiY(5)
        Else
          lHeight = txtHeight + dpiY(10)
        EndIf 
        
        Width  - txtWidthX  - dpiX(2)
        Height - txtHeight - lHeight - dpiY(13) ; Labels + Legend

        Chart()\Current\Offset = txtHeight / 2
        
        Chart()\EventSize\X = X
        Chart()\EventSize\Y = Y
        Chart()\EventSize\Width  = Width
        Chart()\EventSize\Height = Height
        
        Chart()\Scatter\RangeX = Chart()\Current\MaximumX - Chart()\Current\MinimumX
        Chart()\Scatter\RangeY = Chart()\Current\MaximumY - Chart()\Current\MinimumY
        
        ;{ --- Calc Height for positive and negative Values ---
        If Chart()\Current\MinimumY < 0
          Factor  = Height / Chart()\Scatter\RangeY
          pHeight = Factor * Chart()\Current\MaximumY ; positiv
          nHeight = Factor * Chart()\Current\MinimumY ; negativ
          Factor  = Width / Chart()\Scatter\RangeX
          pWidth  = Factor * Chart()\Current\MaximumX ; positiv
          nWidth  = Factor * Chart()\Current\MinimumX ; negativ
        Else
          pHeight = Height ; positiv
          pWidth  = Width  
          nHeight = 0      ; negativ
          nWidth  = 0
        EndIf ;}        
        
        ;{ --- Diameter ---
        Series = ListSize(Chart()\VisibleData())
        Items  = MaximumItems_()
        
        If Chart()\Scatter\Width = #PB_Default
          cWidth = dpiX(6)
        Else  
          cWidth = Chart()\Scatter\Width
        EndIf ;}
        
        ; ----- Draw Y - Axis -----
        If Chart()\AxisY\Flags & #Labels ;{ defined labels
          
          Factor = Height / Chart()\Scatter\RangeY
          
          DrawingMode(#PB_2DDrawing_Transparent)

          ForEach Chart()\AxisY\Label()
            PosY = Y + Round((Chart()\AxisY\Label()\Value - Chart()\Scatter\MinimumY) * Factor, #PB_Round_Nearest)
            If Chart()\Flags & #ShowLines
              Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
            EndIf 
            Line(X - dpiX(2), PosY, dpiX(5), 1, Chart()\Color\Axis)
            txtX = X - TextWidth(Chart()\AxisY\Label()\Text) - dpix(4)
            txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
            DrawText(txtX, txtY, Chart()\AxisY\Label()\Text, Chart()\Color\Front)
          Next
          ;}
        Else                             ;{ calculated scalelines & labels
          
          If Chart()\Scatter\ScaleLinesY = #PB_Default
            If Chart()\Scatter\ScaleSpacingY = 0 : Chart()\Scatter\ScaleSpacingY = 1 : EndIf
            ScaleLines = Height / (txtHeight * Chart()\Scatter\ScaleSpacingY)
            ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Scatter\RangeY)
          Else
            ScaleLines = Chart()\Scatter\ScaleLinesY
          EndIf
          
          If ScaleLines
          
            Factor = Chart()\Scatter\RangeY / ScaleLines
            SpaceY = Height / ScaleLines
            
            DrawingMode(#PB_2DDrawing_Transparent)
            
            For n = 0 To ScaleLines - 1
              PosY = Y + Round(n * SpaceY, #PB_Round_Nearest)
              If Chart()\Flags & #ShowLines
                Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
              EndIf 
              Line(X - dpiX(2), PosY, dpiX(5), 1, Chart()\Color\Axis)
              If Chart()\Scatter\Flags & #Descending
                Value = (Factor * n) + Chart()\Current\MinimumY
                If Value
                  Text$ = FormatValue_(Value, #AxisY)
                Else
                  Text$ = "0"
                EndIf  
              Else
                Value = Chart()\Current\MaximumY - (Factor * n)
                If Value
                  Text$ = StrF(Value, Chart()\Decimals)
                Else
                  Text$ = "0"
                EndIf  
              EndIf
              txtX = X - TextWidth(Text$) - dpix(4)
              txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
              DrawText(txtX, txtY, Text$, Chart()\Color\Front)
            Next
            
          EndIf
          ;}
        EndIf
        
        ; ----- Draw X - Axis -----
        If Chart()\AxisX\Flags & #Labels ;{ defined labels
          
          Factor = Width / Chart()\Scatter\RangeX
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          ForEach Chart()\AxisX\Label()
            PosX = X + Round((Chart()\AxisX\Label()\Value - Chart()\Scatter\MinimumX) * Factor, #PB_Round_Nearest)
            If PosX > X + Width : PosX = X + Width : EndIf 
            If Chart()\Flags & #ShowLines
              Line(PosX, Y, 1, Height, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
            EndIf
            Line(PosX, Y + pHeight - dpiX(2), 1, dpiX(5), Chart()\Color\Axis)
            txtX = PosX - Round(TextWidth(Chart()\AxisX\Label()\Text) / 2, #PB_Round_Nearest)
            txtY = Y + pHeight + dpix(4)
            DrawText(txtX, txtY, Chart()\AxisX\Label()\Text, Chart()\Color\Front)
          Next
          ;}
        Else                             ;{ calculated scalelines & labels
          
          If Chart()\Scatter\ScaleLinesX = #PB_Default
            If Chart()\Scatter\ScaleSpacingX = 0 : Chart()\Scatter\ScaleSpacingX = 1 : EndIf
            If Chart()\Scatter\ScaleSpacingX = 1
              ScaleLines = Width / ((txtWidthX + dpiX(6)) * Chart()\Scatter\ScaleSpacingX)
            Else  
              ScaleLines = Width / (txtWidthX * Chart()\Scatter\ScaleSpacingX)
            EndIf
            ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Scatter\RangeX)
          Else
            ScaleLines = Chart()\Scatter\ScaleLinesX - 1
          EndIf
        
          If ScaleLines                
        
            Factor = Chart()\Scatter\RangeX / ScaleLines
            SpaceX = Width / ScaleLines
            
            DrawingMode(#PB_2DDrawing_Transparent)
            
            For n = 0 To ScaleLines
              PosX = X + Round(n * SpaceX, #PB_Round_Nearest)
              If Chart()\Flags & #ShowLines
                Line(PosX, Y, 1, Height, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
              EndIf 
              Line(PosX, Y + pHeight - dpiX(2), 1, dpiX(5), Chart()\Color\Axis)
              If Chart()\Scatter\Flags & #Descending
                Value = Chart()\Current\MaximumX - (Factor * n)
                If Value
                  Text$ = FormatValue_(Value, #AxisX)
                Else
                  Text$ = "0"
                EndIf
              Else
                Value = (Factor * n) + Chart()\Current\MinimumX
                If Value
                  Text$ = FormatValue_(Value, #AxisX)
                Else
                  Text$ = "0"
                EndIf  
              EndIf
              txtX = PosX - Round(TextWidth(Text$) / 2, #PB_Round_Nearest)
              txtY = Y + pHeight + dpix(4)
              DrawText(txtX, txtY, Text$, Chart()\Color\Front)
            Next
          EndIf
          ;}
        EndIf
        
        Line(X, Y, 1, Height, Chart()\Color\Axis) 
        Line(X, Y + pHeight, Width, 1, Chart()\Color\Axis)
        
        StopDrawing()
      EndIf 

      If StartVectorDrawing(CanvasVectorOutput(Chart()\CanvasNum))
        
        Radius = cWidth / 2
        
        ForEach Chart()\VisibleData()
          
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            
            ForEach Chart()\Series()\Item()
              
              ;{ --- Calc Position X/Y ---
              If Chart()\Current\MinimumY < 0
                If Chart()\Series()\Item()\DataY < 0
                  PosY = Y + pHeight + dpiY(1)
                  Factor = nHeight / Chart()\Current\MinimumY
                  Chart()\Current\nFactorY = Factor
                Else
                  PosY = Y + pHeight
                  Factor = pHeight / Chart()\Current\MaximumY
                  Chart()\Current\pFactorY = Factor
                EndIf
                PosY + Chart()\Series()\Item()\DataY * Factor
              Else
                PosY = Y + pHeight
                Factor = Height / Chart()\Scatter\RangeY
                If Chart()\Scatter\Flags & #Descending
                  PosY - (Chart()\Current\MaximumY - (Chart()\Series()\Item()\DataY)) * Factor
                Else
                  PosY - (Chart()\Series()\Item()\DataY - Chart()\Current\MinimumY) * Factor
                EndIf
                Chart()\Current\pFactorY = Factor
              EndIf
              
              If Chart()\Current\MinimumX < 0
                If Chart()\Series()\Item()\DataX < 0
                  PosX = X
                  Factor = nWidth / Chart()\Current\MinimumX
                  Chart()\Current\nFactorX = Factor
                Else
                  PosX = X + nWidth + dpiX(1)
                  Factor = pWidth / Chart()\Current\MaximumX
                  Chart()\Current\pFactorX = Factor
                EndIf
                PosX + Chart()\Series()\Item()\DataX * Factor
              Else
                PosX = X
                Factor = Width / Chart()\Scatter\RangeX
                If Chart()\Scatter\Flags & #Descending
                  PosX + (Chart()\Current\MaximumX - (Chart()\Series()\Item()\DataX)) * Factor
                Else
                  PosX + (Chart()\Series()\Item()\DataX - Chart()\Current\MinimumX) * Factor
                EndIf
                Chart()\Current\pFactorX = Factor
              EndIf
              ;}
             
              ;{ --- Set text for #ShowValue or #ShowPercent ---        
              If Chart()\Flags & #ShowValue
                Text$ = "(" + StrF(Chart()\Series()\Item()\DataX, Chart()\Decimals) + "/" +StrF(Chart()\Series()\Item()\DataX, Chart()\Decimals)+ ")"
              Else
                Text$ = GetText_(Chart()\Series()\Item()\Text)
              EndIf ;}
              
              If Chart()\Series()\Item()\DataY >= Chart()\Current\MinimumY And Chart()\Series()\Item()\DataY <= Chart()\Current\MaximumY And Chart()\Series()\Item()\DataX >= Chart()\Current\MinimumX And Chart()\Series()\Item()\DataX <= Chart()\Current\MaximumX
                
                Color = Chart()\Series()\Color
                If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf

                Circle_(Round(PosX, #PB_Round_Nearest), Round(PosY, #PB_Round_Nearest), Radius, BlendColor_(Color, Chart()\Color\Border, 50), Color)
              
                ;{ --- Set Data ----
                If Chart()\Series()\Item()\Value < 0
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY
                  Chart()\Series()\Item()\Width  = cWidth
                  Chart()\Series()\Item()\Height = cWidth
                Else
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY
                  Chart()\Series()\Item()\Width  = cWidth
                  Chart()\Series()\Item()\Height = cWidth
                EndIf ;}
              
              Else
                Chart()\Series()\Item()\X      = 0
                Chart()\Series()\Item()\Y      = 0
                Chart()\Series()\Item()\Width  = 0
                Chart()\Series()\Item()\Height = 0
                Color = #Error
              EndIf
              
              ;{ --- Draw Text ---
              If Text$ 
                
                If Chart()\Scatter\FontSize = #PB_Default
                  VectorFont(Chart()\Scatter\FontID)
                Else
                  VectorFont(Chart()\Scatter\FontID, dpiY(Chart()\Scatter\FontSize))
                EndIf
                
                txtHeight = VectorTextHeight(Text$)
                
                txtX = PosX - Radius + ((cWidth - VectorTextWidth(Text$)) / 2)
                
                If Chart()\Series()\Item()\Value < 0
                  txtY = PosY - VectorTextHeight(Text$) - dpiY(2)
                Else
                  txtY = PosY - VectorTextHeight(Text$) - dpiY(2)
                EndIf

                If Color = #Error
                  Text_(txtX, Y + Height - txtHeight - dpiY(2), Text$, $0000FF)
                Else
                  Text_(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 60))
                EndIf  
                
              EndIf ;}
              
            Next  
            
          EndIf
          
        Next
        
        StopVectorDrawing()
      EndIf
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
    
        DrawingFont(Chart()\FontID)
        
        If Items
          
          If Chart()\Legend\Flags & #Hide = #False
            
            ;{ --- Draw Legend ---
            DrawingFont(Chart()\Legend\FontID)
            txtHeight = TextHeight("Abc")
            
            lTextWidth = 0
            
            If Chart()\Legend\Flags & #AllDataSeries
              Series = ListSize(Chart()\Series())
              ForEach Chart()\Series()
                lTextWidth + TextWidth(Chart()\Series()\Label)
              Next
            Else
              ForEach Chart()\VisibleData()
                If SelectElement(Chart()\Series(), Chart()\VisibleData())  
                  lTextWidth + TextWidth(Chart()\Series()\Label)
                EndIf  
              Next
            EndIf
            
            lWidth  = lTextWidth + ((txtHeight + dpiX(5)) * Series) + (dpiX(10) * (Series - 1)) + dpiX(10)
            
            lX = (Width - lWidth) / 2 + X
            lY = Y + Height + txtHeight + dpiY(8)
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(lX, lY, lWidth, lHeight, $FFFFFF)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(lX, lY, lWidth, lHeight, Chart()\Color\Border)
            
            PosX = lX + dpiX(5)
            PosY = lY + dpiX(5)
           
            If Chart()\Legend\Flags & #AllDataSeries
              
              ForEach Chart()\Series()
                
                DrawingMode(#PB_2DDrawing_Default)
                Box(PosX, PosY, txtHeight, txtHeight, Chart()\Series()\Color)
               
                DrawingMode(#PB_2DDrawing_Outlined)
                Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Series()\Color, Chart()\Color\Border, 40))
                
                Chart()\Series()\Legend\X      = PosX
                Chart()\Series()\Legend\Y      = PosY
                Chart()\Series()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Series()\Label)
                Chart()\Series()\Legend\Height = txtHeight
                
                PosX + txtHeight + dpiX(5)
      
                DrawingMode(#PB_2DDrawing_Transparent)
                DrawText(PosX, PosY, Chart()\Series()\Label, Chart()\Color\Front)
                
                PosX + TextWidth(Chart()\Series()\Label) + dpiX(10)
              Next  
              
            Else
              
              ForEach Chart()\VisibleData()
              
                If SelectElement(Chart()\Series(), Chart()\VisibleData())
                  
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(PosX, PosY, txtHeight, txtHeight, Chart()\Series()\Color)
                 
                  DrawingMode(#PB_2DDrawing_Outlined)
                  Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Series()\Color, Chart()\Color\Border, 40))
                  
                  Chart()\Series()\Legend\X      = PosX
                  Chart()\Series()\Legend\Y      = PosY
                  Chart()\Series()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Series()\Label)
                  Chart()\Series()\Legend\Height = txtHeight
                  
                  PosX + txtHeight + dpiX(5)
        
                  DrawingMode(#PB_2DDrawing_Transparent)
                  DrawText(PosX, PosY, Chart()\Series()\Label, Chart()\Color\Front)
                  
                  PosX + TextWidth(Chart()\Series()\Label) + dpiX(10)
        
                EndIf 
                
              Next
              
            EndIf ;}
            
          EndIf  
          
        EndIf
        
        StopDrawing()
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_DataSeries

    Procedure   DrawBarSeries_(X.i, Y.i, Width.i, Height.i)
      Define.i PosX, PosY, sWidth, bWidth, bHeight, nHeight, pHeight
      Define.i txtX, txtY, txtWidth, txtHeight, lX, lY, lHeight, lWidth, lTextWidth, axisY, padWidth, seriesX
      Define.i n, Items, Spaces, ScaleLines, Color, Gradient, maxValue, minValue, Series
      Define.f SpaceY, Quotient, Calc
      Define.s Text$, Percent$
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
        
        DrawingFont(Chart()\FontID)
        
        Chart()\Current\MaximumY  = Chart()\Maximum ;{ Maximum
        maxValue = MaximumValue_()
        If Chart()\Current\MaximumY = #PB_Default
          Chart()\Current\MaximumY = maxValue
        ElseIf Chart()\Bar\Flags & #NoAutoAdjust = #False
          Chart()\Current\MaximumY = Chart()\Maximum
          If maxValue > Chart()\Current\MaximumY : Chart()\Current\MaximumY = maxValue : EndIf
        EndIf ;}
        
        Chart()\Current\MinimumY  = Chart()\Minimum ;{ Minimum
        minValue = MinimumValue_()
        If Chart()\Current\MinimumY = #PB_Default
          Chart()\Current\MinimumY = minValue
        ElseIf Chart()\Bar\Flags & #NoAutoAdjust = #False
          If minValue < Chart()\Current\MinimumY : Chart()\Current\MinimumY = minValue : EndIf
        EndIf ;}
        
        txtHeight = TextHeight("Abc")
        txtWidth  = TextWidth(Str(Chart()\Current\MaximumY))
       
        X  + txtWidth + dpiX(2)
        Y  + (txtHeight / 2)
        
        If Chart()\Legend\Flags & #Hide
          lHeight = -dpiY(5)
        Else
          lHeight = txtHeight + dpiY(10)
        EndIf 

        Width  - txtWidth - dpiX(2)
        Height - txtHeight - lHeight - dpiY(13) ; Labels + Legend
        
        Chart()\Current\Offset = txtHeight / 2
        
        Chart()\EventSize\X = X
        Chart()\EventSize\Y = Y
        Chart()\EventSize\Width  = Width
        Chart()\EventSize\Height = Height
        
        Chart()\Bar\Range = Chart()\Current\MaximumY - Chart()\Current\MinimumY
        
        ;{ --- Calc Height for positive and negative Values ---
        If Chart()\Current\MinimumY < 0
          Quotient = Height / Chart()\Bar\Range
          pHeight  = Quotient * Chart()\Current\MaximumY ; positiv
          nHeight  = Quotient * Chart()\Current\MinimumY ; negativ 
        Else
          pHeight = Height ; positiv
          nHeight = 0      ; negativ
        EndIf ;}
        
        ;{ --- Calc Bar & Spacing Width ---
        Series = ListSize(Chart()\VisibleData())
        Items  = MaximumItems_()
        Spaces = Items + 1
        padWidth = Chart()\Bar\Padding * (Items * (Series - 1)) ; Spacing between series bars
        If Chart()\Bar\Width = #PB_Default And Chart()\Bar\Spacing = #PB_Default
          bWidth = (Width - padWidth) / ((Items * Series) + Spaces)
          sWidth = bWidth
        ElseIf Chart()\Bar\Width = #PB_Default
          sWidth = Chart()\Bar\Spacing
          If Items
            bWidth   = (Width - padWidth - (sWidth * Spaces )) / (Items * Series)
          EndIf
        ElseIf Chart()\Bar\Spacing = #PB_Default
          bWidth = Chart()\Bar\Width
          sWidth = (Width - padWidth - (bWidth * (Items * Series))) / Spaces
        Else  
          bWidth = Chart()\Bar\Width
          sWidth = Chart()\Bar\Spacing
        EndIf ;}
        
        ;{ --- Draw Coordinate Axes ---
        Line(X, Y, 1, Height, Chart()\Color\Axis)

        If Chart()\Bar\ScaleLines = #PB_Default
          ScaleLines = Height / (txtHeight * Chart()\Bar\ScaleSpacing)
          If Chart()\Bar\ScaleSpacing = 0 : Chart()\Bar\ScaleSpacing = 1 : EndIf
          ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Bar\Range)
        Else
          ScaleLines = Chart()\Bar\ScaleLines
        EndIf
        
        If ScaleLines
         
          Quotient = Chart()\Bar\Range  / ScaleLines
          SpaceY   = Height / ScaleLines
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          For n = 0 To ScaleLines
            PosY = Y + Round(n * SpaceY, #PB_Round_Nearest)
            If Chart()\Flags & #ShowLines
              Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
            EndIf 
            Line(X - dpiX(2), PosY, dpiX(5), 1, Chart()\Color\Axis)
            Text$ = Str(Chart()\Current\MaximumY - (Quotient * n))
            txtX = X - TextWidth(Text$) - dpix(4)
            txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
            DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          Next
    
          ;If Chart()\Current\MinimumY
          ;  PosY = Y + Height
          ;  If Chart()\Flags & #ShowLines
          ;    Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
          ;  EndIf
          ;  Line(X - dpiX(2), PosY, dpiX(6), 1, Chart()\Color\Axis)
          ;  Text$ = Str(Chart()\Current\MinimumY)
          ;  txtX = X - TextWidth(Text$) - dpix(4)
          ;  txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
          ;  DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          ;EndIf

        EndIf
        
        Line(X, Y + Height, Width, 1, Chart()\Color\Axis)
        ;} 
        
        If Items : Dim Label.s(Items - 1) : EndIf
  
        seriesX = X + sWidth
        
        DrawingFont(Chart()\Bar\FontID)
        txtHeight = TextHeight("Abc")
        
        ForEach Chart()\VisibleData()
          
          PosX = seriesX
          
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            
            lTextWidth + TextWidth(Chart()\Series()\Label)

            ForEach Chart()\Series()\Item()
              
              If (Chart()\Series()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Series()\Item()\Value <= Chart()\Current\MaximumY) Or Chart()\Bar\Flags & #OutOfRange
                
                If Chart()\Bar\Flags & #OutOfRange : ClipOutput(X, Y, Width, Height) : EndIf 
                
                ;{ --- Calc Position & Height---
                If Chart()\Current\MinimumY < 0
                  If Chart()\Series()\Item()\Value < 0
                    PosY = Y + pHeight + dpiY(1)
                    Quotient = nHeight / Chart()\Current\MinimumY
                  Else
                    PosY = Y + pHeight
                    Quotient = pHeight / Chart()\Current\MaximumY
                  EndIf
                  bHeight = Chart()\Series()\Item()\Value * Quotient
                Else
                  PosY = Y + pHeight
                  Quotient = Height / Chart()\Bar\Range
                  bHeight = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * Quotient
                EndIf ;}
                
                ;{ --- Set text for #ShowValue or #ShowPercent ---
                Calc = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * 100
                If Calc <> 0
                  Percent$ = Str((Calc / Chart()\Bar\Range)) + "%"
                Else
                  Percent$ = "0%"
                EndIf
          
                If Chart()\Flags & #ShowValue
                  Text$ = Str(Chart()\Series()\Item()\Value)
                ElseIf Chart()\Flags & #ShowPercent  
                  Text$ = Percent$
                Else
                  Text$ = GetText_(Chart()\Series()\Item()\Text)
                EndIf ;}
          
                ;{ --- Draw Bars ---
                Color = Chart()\Series()\Color
                If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
                
                Gradient = Chart()\Series()\Gradient
                If Gradient = #PB_Default : Gradient = BlendColor_(Color, Chart()\Color\Back, 60) : EndIf
                
                If (Chart()\Series()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Series()\Item()\Value <= Chart()\Current\MaximumY) Or Chart()\Bar\Flags & #OutOfRange
                
                  If Color <> Gradient ;{ Gradient color
          
                    DrawingMode(#PB_2DDrawing_Gradient)
                    FrontColor(Color)
                    BackColor(Gradient)
                    LinearGradient(PosX, PosY - bHeight, PosX, PosY)
                    Box(PosX, PosY - bHeight, bWidth, bHeight)
                    ;}
                  Else                 ;{ Solid color
                    
                    DrawingMode(#PB_2DDrawing_Default)
                    Box(PosX, PosY - bHeight, bWidth, bHeight, Color)
                    ;}
                  EndIf
                
                  ;{ --- Draw Bar Border ---
                  If Chart()\Bar\Flags & #NoBorder = #False
                    DrawingMode(#PB_2DDrawing_Outlined)
                    If Chart()\Series()\Border = #PB_Default
                      Box(PosX, PosY, bWidth, -bHeight, BlendColor_(Color, Chart()\Color\Border, 60))
                    Else
                      Box(PosX, PosY, bWidth, -bHeight, Chart()\Series()\Item()\Border)
                    EndIf
                  EndIf ;}
                  
                Else
                  bHeight = 0
                  Chart()\Series()\Item()\Height = bHeight
                  Color = #Error
                EndIf ;}
                
                If Chart()\Bar\Flags & #OutOfRange ;{
                  If Chart()\Series()\Item()\Value < Chart()\Current\MinimumY Or Chart()\Series()\Item()\Value > Chart()\Current\MaximumY
                    Color = #Error
                  EndIf
                  UnclipOutput()
                  ;}
                EndIf 
                
                ;{ --- Set Data ----
                If Chart()\Series()\Item()\Value < 0
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY
                  Chart()\Series()\Item()\Width  = bWidth
                  Chart()\Series()\Item()\Height = Abs(bHeight)
                Else
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY - bHeight
                  Chart()\Series()\Item()\Width  = bWidth
                  Chart()\Series()\Item()\Height = bHeight
                EndIf ;}
                
                ;{ --- Draw Text ---
                If Text$ 

                  DrawingMode(#PB_2DDrawing_Transparent)
                  
                  txtX = PosX + ((bWidth - TextWidth(Text$)) / 2)
                  
                  If Abs(bHeight) < txtHeight + dpiY(4) Or Abs(bWidth) < TextWidth(Text$) + dpiY(4)
                    If Chart()\Series()\Item()\Value < 0
                      txtY = PosY - txtHeight - dpiY(1)
                    Else
                      txtY = PosY - bHeight - txtHeight - dpiY(1)
                    EndIf
                  Else
                    If Chart()\Series()\Item()\Value < 0
                      txtY = PosY - bHeight - txtHeight - dpiY(2)
                    Else
                      txtY = PosY - bHeight + dpiY(2)
                    EndIf 
                  EndIf
                  
                  If Color = #Error
                    
                    If Chart()\Bar\Flags & #OutOfRange
                      If Chart()\Series()\Item()\Value < 0
                        txtY = Y + Height - txtHeight - dpiY(1)
                      Else
                        txtY = Y + dpiY(5)
                      EndIf
                      If Chart()\Series()\Item()\Color = #PB_Default
                        DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Color\Back, 60))
                      Else
                        DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Series()\Color, 60))
                      EndIf
                    Else
                      If Chart()\Series()\Item()\Value < 0
                        DrawText(txtX, txtY - txtHeight - dpiY(2), Text$, $0000FF)
                      Else
                        DrawText(txtX, txtY - dpiY(2), Text$, $0000FF)
                      EndIf
                    EndIf
                    
                  Else
                    DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 60))
                  EndIf  
                  
                EndIf;}
                
                ;{ --- Remember all Labels ---
                Text$ = Chart()\Series()\Item()\Label
                If Text$
                  Label(ListIndex(Chart()\Series()\Item())) = Text$
                EndIf
                ;}
                
                PosX + (bWidth * Series) + (Chart()\Bar\Padding * (Series - 1)) + sWidth
                
              EndIf
              
            Next
  
            seriesX + bWidth + Chart()\Bar\Padding
  
          EndIf
        
        Next
        
        If Items

          ;{ --- Draw Labels ---
          DrawingFont(Chart()\FontID)
          txtHeight = TextHeight("Abc")
          
          PosX   = X + sWidth
          bWidth = (bWidth * Series) + (Chart()\Bar\Padding * (Series - 1)) 
          
          For n=0 To Items - 1
            
            Text$ = Label(n)
            
            txtX  = PosX + ((bWidth - TextWidth(Text$)) / 2)
            txtY  = Y + Height + dpiY(3)
            
            DrawingMode(#PB_2DDrawing_Transparent)
            If Color = #Error
              If Chart()\Bar\Flags & #OutOfRange
                If Chart()\Bar\Flags & #Colored
                  If Chart()\Item()\Color = #PB_Default
                    DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Color\Back, 30))
                  Else
                    DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Item()\Color, 30))
                  EndIf
                Else
                  DrawText(txtX, txtY, Text$, Chart()\Color\Front)
                EndIf 
              Else
                DrawText(txtX, txtY, Text$, $808080)
              EndIf 
            ElseIf Chart()\Bar\Flags & #Colored
              DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 40))
            Else
              DrawText(txtX, txtY, Text$, Chart()\Color\Front)
            EndIf
            
            PosX + bWidth + sWidth
          Next
          ;}
          
          If Chart()\Legend\Flags & #Hide = #False
            
            ;{ --- Draw Legend ---
            DrawingFont(Chart()\Legend\FontID)
            txtHeight = TextHeight("Abc")
            
            If Chart()\Legend\Flags & #AllDataSeries
              Series     = ListSize(Chart()\Series())
              lTextWidth = 0
              ForEach Chart()\Series()
                lTextWidth + TextWidth(Chart()\Series()\Label)
              Next  
            EndIf
            
            lWidth  = lTextWidth + ((txtHeight + dpiX(5)) * Series) + (dpiX(10) * (Series - 1)) + dpiX(10)
            
            lX = (Width - lWidth) / 2 + X
            lY = Y + Height + txtHeight + dpiY(8)
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(lX, lY, lWidth, lHeight, $FFFFFF)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(lX, lY, lWidth, lHeight, Chart()\Color\Border)
            
            PosX = lX + dpiX(5)
            PosY = lY + dpiX(5)
           
            If Chart()\Legend\Flags & #AllDataSeries
              
              ForEach Chart()\Series()
                
                DrawingMode(#PB_2DDrawing_Default)
                Box(PosX, PosY, txtHeight, txtHeight, Chart()\Series()\Color)
               
                DrawingMode(#PB_2DDrawing_Outlined)
                Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Series()\Color, Chart()\Color\Border, 40))
                
                Chart()\Series()\Legend\X      = PosX
                Chart()\Series()\Legend\Y      = PosY
                Chart()\Series()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Series()\Label)
                Chart()\Series()\Legend\Height = txtHeight
                
                PosX + txtHeight + dpiX(5)
      
                DrawingMode(#PB_2DDrawing_Transparent)
                DrawText(PosX, PosY, Chart()\Series()\Label, Chart()\Color\Front)
                
                PosX + TextWidth(Chart()\Series()\Label) + dpiX(10)
              Next  
              
            Else
              
              ForEach Chart()\VisibleData()
              
                If SelectElement(Chart()\Series(), Chart()\VisibleData())
                  
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(PosX, PosY, txtHeight, txtHeight, Chart()\Series()\Color)
                 
                  DrawingMode(#PB_2DDrawing_Outlined)
                  Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Series()\Color, Chart()\Color\Border, 40))
                  
                  Chart()\Series()\Legend\X      = PosX
                  Chart()\Series()\Legend\Y      = PosY
                  Chart()\Series()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Series()\Label)
                  Chart()\Series()\Legend\Height = txtHeight
                  
                  PosX + txtHeight + dpiX(5)
        
                  DrawingMode(#PB_2DDrawing_Transparent)
                  DrawText(PosX, PosY, Chart()\Series()\Label, Chart()\Color\Front)
                  
                  PosX + TextWidth(Chart()\Series()\Label) + dpiX(10)
        
                EndIf 
                
              Next
              
            EndIf ;}
            
          EndIf
          
        EndIf
        
        StopDrawing()
      EndIf
    
    EndProcedure
    
    Procedure   DrawLineSeries_(X.i, Y.i, Width.i, Height.i)
      Define.i PosX, PosY, sWidth, cWidth, cHeight, nHeight, pHeight, axisY, seriesX
      Define.i txtX, txtY, txtWidth, txtHeight, lX, lY, lHeight, lWidth, lTextWidth, Radius, xW3, lastX, lastY
      Define.i n, Items, Spaces, ScaleLines, Color, Gradient, maxValue, minValue, Series
      Define.q AlphaColor
      Define.f SpaceY, Factor, Calc
      Define.s Text$, Percent$
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
      
        DrawingFont(Chart()\FontID)
        
        Chart()\Current\MaximumY = Chart()\Maximum ;{ Maximum
        maxValue = MaximumValue_()
        If Chart()\Current\MaximumY = #PB_Default
          Chart()\Current\MaximumY = maxValue
        ElseIf Chart()\Line\Flags & #NoAutoAdjust = #False
          Chart()\Current\MaximumY = Chart()\Maximum
          If maxValue > Chart()\Current\MaximumY : Chart()\Current\MaximumY = maxValue : EndIf
        EndIf ;}
        
        Chart()\Current\MinimumY = Chart()\Minimum ;{ Minimum
        minValue = MinimumValue_()
        If Chart()\Current\MinimumY = #PB_Default
          Chart()\Current\MinimumY = minValue
        ElseIf Chart()\Line\Flags & #NoAutoAdjust = #False
          If minValue < Chart()\Current\MinimumY : Chart()\Current\MinimumY = minValue : EndIf
        EndIf ;}
        
        txtHeight = TextHeight("Abc")
        txtWidth  = TextWidth(Str(Chart()\Current\MaximumY))
       
        X  + txtWidth + dpiX(2)
        Y  + (txtHeight / 2)
        
        If Chart()\Legend\Flags & #Hide
          lHeight = -dpiY(5)
        Else
          lHeight = txtHeight + dpiY(10)
        EndIf 
        
        Width  - txtWidth - dpiX(2)
        Height - txtHeight - lHeight - dpiY(13) ; Labels + Legend

        Chart()\Current\Offset = txtHeight / 2
        
        Chart()\EventSize\X = X
        Chart()\EventSize\Y = Y
        Chart()\EventSize\Width  = Width
        Chart()\EventSize\Height = Height
        
        Chart()\Line\Range = Chart()\Current\MaximumY - Chart()\Current\MinimumY
        
        ;{ --- Calc Height for positive and negative Values ---
        If Chart()\Current\MinimumY < 0
          Factor = Height / Chart()\Line\Range
          pHeight  = Factor * Chart()\Current\MaximumY ; positiv
          nHeight  = Factor * Chart()\Current\MinimumY ; negativ 
        Else
          pHeight = Height ; positiv
          nHeight = 0      ; negativ
        EndIf ;}
        
        ;{ --- Calc Bar & Spacing Width ---
        Series = ListSize(Chart()\VisibleData())
        Items  = MaximumItems_()
        Spaces = Items - 1
        
        If Chart()\Line\Width = #PB_Default And Chart()\Line\Spacing = #PB_Default
          cWidth = dpiX(6)
          If Items > 0 : sWidth = Round((Width - (cWidth * Items) - (Chart()\Line\Padding * 2)) / Spaces, #PB_Round_Nearest) : EndIf
        ElseIf Chart()\Line\Width = #PB_Default
          cWidth = dpiX(6)
          sWidth = Chart()\Line\Spacing
        ElseIf Chart()\Line\Spacing = #PB_Default
          cWidth = Chart()\Line\Width
          sWidth = Round((Width - (cWidth * Items) - (Chart()\Line\Padding * 2)) / Spaces, #PB_Round_Nearest)
        Else  
          cWidth = Chart()\Line\Width
          sWidth = Chart()\Line\Spacing
        EndIf ;}
      
        ;{ --- Draw Coordinate Axes ---
        Line(X, Y, 1, Height, Chart()\Color\Axis)
        
        If Chart()\Line\ScaleLines = #PB_Default
          ScaleLines = Height / (txtHeight * Chart()\Line\ScaleSpacing)
          If Chart()\Line\ScaleSpacing = 0 : Chart()\Line\ScaleSpacing = 1 : EndIf
          ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Line\Range)
        Else
          ScaleLines = Chart()\Line\ScaleLines
        EndIf
        
        If ScaleLines
          
          Factor = Chart()\Line\Range  / ScaleLines
          SpaceY = Height / ScaleLines
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          For n = 0 To ScaleLines
            PosY = Y + Round(n * SpaceY, #PB_Round_Nearest)
            If Chart()\Flags & #ShowLines
              Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
            EndIf 
            Line(X - dpiX(2), PosY, dpiX(5), 1, Chart()\Color\Axis)
            If Chart()\Line\Flags & #Descending
              Text$ = Str((Factor * n) + Chart()\Current\MinimumY)
            Else
              Text$ = Str(Chart()\Current\MaximumY - (Factor * n))
            EndIf
            txtX = X - TextWidth(Text$) - dpix(4)
            txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
            DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          Next
    
          Line(X, Y + pHeight, Width, 1, Chart()\Color\Axis)
          
        EndIf ;} 
        
        StopDrawing()
      EndIf 
    
      If StartVectorDrawing(CanvasVectorOutput(Chart()\CanvasNum))
 
        If Items : Dim Label.s(Items - 1) : EndIf
  
        Radius = cWidth / 2
        
        ;{ --- Draw Lines ---
        xW3 = Round((cWidth + sWidth) / 3, #PB_Round_Nearest)
        
        If Chart()\Line\Flags & #OutOfRange
          SaveVectorState()
          AddPathBox(X, Y, Width, Height)
          ClipPath()
        EndIf
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            
            AlphaColor = RGBA(Red(Chart()\Series()\Color), Green(Chart()\Series()\Color), Blue(Chart()\Series()\Color), 200)
            
            PosX  = X + Chart()\Line\Padding
            LastX = 0 : LastY = 0
            
            ForEach Chart()\Series()\Item()
              
              If (Chart()\Series()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Series()\Item()\Value <= Chart()\Current\MaximumY) Or Chart()\Line\Flags & #OutOfRange
                
                ;{ --- Calc Position & Height---
                If Chart()\Current\MinimumY < 0
                  
                  If Chart()\Series()\Item()\Value < 0
                    PosY    = Y + pHeight + dpiY(1)
                    Factor  = nHeight / Chart()\Current\MinimumY
                    cHeight = Chart()\Series()\Item()\Value * Factor
                    If Chart()\Series()\Item()\Value < Chart()\Current\MinimumY : cHeight = - SpaceY : EndIf
                  Else
                    PosY    = Y + pHeight
                    Factor  = pHeight / Chart()\Current\MaximumY
                    cHeight = Chart()\Series()\Item()\Value * Factor
                    If Chart()\Series()\Item()\Value < Chart()\Current\MinimumY
                      cHeight = - SpaceY   
                    ElseIf Chart()\Series()\Item()\Value > Chart()\Current\MaximumY
                      cHeight = (Chart()\Current\MaximumY -  Chart()\Current\MinimumY) * Factor + SpaceY
                    EndIf 
                  EndIf

                Else
                  
                  PosY = Y + pHeight
                  Factor = Height / Chart()\Line\Range
                  If Chart()\Line\Flags & #Descending
                    cHeight = (Chart()\Current\MaximumY - (Chart()\Series()\Item()\Value)) * Factor
                    If Chart()\Series()\Item()\Value < Chart()\Current\MinimumY
                      cHeight = (Chart()\Current\MaximumY -  Chart()\Current\MinimumY) * Factor + SpaceY
                    ElseIf Chart()\Series()\Item()\Value > Chart()\Current\MaximumY
                      cHeight = - SpaceY   
                    EndIf 
                  Else
                    cHeight = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * Factor
                    If Chart()\Series()\Item()\Value < Chart()\Current\MinimumY
                      cHeight = - SpaceY   
                    ElseIf Chart()\Series()\Item()\Value > Chart()\Current\MaximumY
                      cHeight = (Chart()\Current\MaximumY -  Chart()\Current\MinimumY) * Factor + SpaceY
                    EndIf 
                  EndIf

                EndIf ;}
                If ListIndex(Chart()\Series()\Item()) = 0
                  MovePathCursor(PosX + Radius, PosY - cHeight)
                Else
                  
                  If Chart()\Line\Flags & #BezierCurve
                    AddPathCurve(lastX + xW3, LastY, PosX + Radius - xW3, PosY - cHeight, PosX + Radius, PosY - cHeight)
                  Else
                    AddPathLine(PosX + Radius, PosY - cHeight)
                  EndIf  
                  
                EndIf
                
                LastX = PosX + Radius : LastY = PosY - cHeight
              EndIf
              
              PosX + cWidth + sWidth
            Next
            
            VectorSourceColor(AlphaColor)
            StrokePath(2, #PB_Path_RoundCorner)

          EndIf
        Next
        If Chart()\Line\Flags & #OutOfRange : RestoreVectorState() : EndIf
        
        ;}
        
        ForEach Chart()\VisibleData()
          
          PosX = X + Chart()\Line\Padding
          
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            
            ForEach Chart()\Series()\Item()

              ;{ --- Calc Position & Height---
              If Chart()\Current\MinimumY < 0
                If Chart()\Series()\Item()\Value < 0
                  PosY = Y + pHeight + dpiY(1)
                  Factor = nHeight / Chart()\Current\MinimumY
                  Chart()\Current\nFactorY = Factor
                Else
                  PosY = Y + pHeight
                  Factor = pHeight / Chart()\Current\MaximumY
                  Chart()\Current\pFactorY = Factor
                EndIf
                cHeight = Chart()\Series()\Item()\Value * Factor
              Else
                PosY = Y + pHeight
                Factor = Height / Chart()\Line\Range
                If Chart()\Line\Flags & #Descending
                  cHeight = (Chart()\Current\MaximumY - (Chart()\Series()\Item()\Value)) * Factor
                Else
                  cHeight = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * Factor
                EndIf
                Chart()\Current\pFactorY = Factor
              EndIf ;}
              
              ;Chart()\Current\MaximumY = Chart()\Current\MaximumY
              
              ;{ --- Set text for #ShowValue or #ShowPercent ---
              Calc = (Chart()\Series()\Item()\Value - Chart()\Current\MinimumY) * 100
              If Calc <> 0
                Percent$ = Str((Calc / Chart()\Line\Range)) + "%"
              Else
                Percent$ = "0%"
              EndIf
        
              If Chart()\Flags & #ShowValue
                Text$ = Str(Chart()\Series()\Item()\Value)
              ElseIf Chart()\Flags & #ShowPercent  
                Text$ = Percent$
              Else
                Text$ = GetText_(Chart()\Series()\Item()\Text)
              EndIf ;}
              
              If Chart()\Series()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Series()\Item()\Value <= Chart()\Current\MaximumY
  
                ;{ --- Draw Circles ---
                Color = Chart()\Series()\Color
                If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
                
                ;Gradient = Chart()\Series()\Gradient
                ;If Gradient = #PB_Default : Gradient = BlendColor_(Color, Chart()\Color\Back, 60) : EndIf
                
                Circle_(PosX + Radius, PosY - cHeight, Radius, BlendColor_(Color, Chart()\Color\Border, 50), Color)
              
                ;{ --- Set Data ----
                If Chart()\Series()\Item()\Value < 0
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY - cHeight + Radius
                  Chart()\Series()\Item()\Width  = cWidth
                  Chart()\Series()\Item()\Height = cWidth
                Else
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY - cHeight - Radius
                  Chart()\Series()\Item()\Width  = cWidth
                  Chart()\Series()\Item()\Height = cWidth
                EndIf ;}
                If Chart()\Series()\Item()\Value < 0
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY + Radius
                  Chart()\Series()\Item()\Width  = cWidth
                  Chart()\Series()\Item()\Height = cWidth
                Else
                  Chart()\Series()\Item()\X      = PosX
                  Chart()\Series()\Item()\Y      = PosY - Radius
                  Chart()\Series()\Item()\Width  = cWidth
                  Chart()\Series()\Item()\Height = cWidth
                EndIf  
                ;}
                
              Else
                Chart()\Series()\Item()\X      = 0
                Chart()\Series()\Item()\Y      = 0
                Chart()\Series()\Item()\Width  = 0
                cHeight = 0
                Chart()\Series()\Item()\Height = cHeight
                Color = #Error
              EndIf
              
              ;{ --- Draw Text ---
              If Text$ 
                
                If Chart()\Line\FontSize = #PB_Default
                  VectorFont(Chart()\Line\FontID)
                Else
                  VectorFont(Chart()\Line\FontID, dpiY(Chart()\Line\FontSize))
                EndIf
                
                txtHeight = VectorTextHeight(Text$)
                
                txtX = PosX + ((cWidth - VectorTextWidth(Text$)) / 2)
                
                If Chart()\Series()\Item()\Value < 0
                  txtY = PosY - VectorTextHeight(Text$) - dpiY(2)
                Else
                  txtY = PosY - cHeight - VectorTextHeight(Text$) - dpiY(2)
                EndIf

                If Color = #Error
                  Text_(txtX, Y + Height - txtHeight - dpiY(2), Text$, $0000FF)
                Else
                  Text_(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 60))
                EndIf  
                
              EndIf ;}
              
              ;{ --- Remember all Labels ---
              Text$ = Chart()\Series()\Item()\Label
              If Text$
                Label(ListIndex(Chart()\Series()\Item())) = Text$
              EndIf
              ;}

              PosX + cWidth + sWidth
            Next

          EndIf
        
        Next

        StopVectorDrawing()
      EndIf
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
    
        DrawingFont(Chart()\FontID)
        
        If Items
          
          ;{ --- Draw Labels ---
          PosX = X + Chart()\Line\Padding
          
          For n=0 To Items - 1
            
            Text$ = Label(n)
            
            txtX  = PosX + ((cWidth - TextWidth(Text$)) / 2)
            txtY  = Y + Height + dpiY(3)
            
            DrawingMode(#PB_2DDrawing_Transparent)
            If Color = #Error
              DrawText(txtX, txtY, Text$, $808080)
            ElseIf Chart()\Line\Flags & #Colored
              DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 40))
            Else
              DrawText(txtX, txtY, Text$, Chart()\Color\Front)
            EndIf
            
            PosX + cWidth + sWidth
          Next
          ;}
        
          If Chart()\Legend\Flags & #Hide = #False
            
            ;{ --- Draw Legend ---
            DrawingFont(Chart()\Legend\FontID)
            txtHeight = TextHeight("Abc")
            
            lTextWidth = 0
            
            If Chart()\Legend\Flags & #AllDataSeries
              Series = ListSize(Chart()\Series())
              ForEach Chart()\Series()
                lTextWidth + TextWidth(Chart()\Series()\Label)
              Next
            Else
              ForEach Chart()\VisibleData()
                If SelectElement(Chart()\Series(), Chart()\VisibleData())  
                  lTextWidth + TextWidth(Chart()\Series()\Label)
                EndIf  
              Next
            EndIf
            
            lWidth  = lTextWidth + ((txtHeight + dpiX(5)) * Series) + (dpiX(10) * (Series - 1)) + dpiX(10)
            
            lX = (Width - lWidth) / 2 + X
            lY = Y + Height + txtHeight + dpiY(8)
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(lX, lY, lWidth, lHeight, $FFFFFF)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(lX, lY, lWidth, lHeight, Chart()\Color\Border)
            
            PosX = lX + dpiX(5)
            PosY = lY + dpiX(5)
           
            If Chart()\Legend\Flags & #AllDataSeries
              
              ForEach Chart()\Series()
                
                DrawingMode(#PB_2DDrawing_Default)
                Box(PosX, PosY, txtHeight, txtHeight, Chart()\Series()\Color)
               
                DrawingMode(#PB_2DDrawing_Outlined)
                Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Series()\Color, Chart()\Color\Border, 40))
                
                Chart()\Series()\Legend\X      = PosX
                Chart()\Series()\Legend\Y      = PosY
                Chart()\Series()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Series()\Label)
                Chart()\Series()\Legend\Height = txtHeight
                
                PosX + txtHeight + dpiX(5)
      
                DrawingMode(#PB_2DDrawing_Transparent)
                DrawText(PosX, PosY, Chart()\Series()\Label, Chart()\Color\Front)
                
                PosX + TextWidth(Chart()\Series()\Label) + dpiX(10)
              Next  
              
            Else
              
              ForEach Chart()\VisibleData()
              
                If SelectElement(Chart()\Series(), Chart()\VisibleData())
                  
                  DrawingMode(#PB_2DDrawing_Default)
                  Box(PosX, PosY, txtHeight, txtHeight, Chart()\Series()\Color)
                 
                  DrawingMode(#PB_2DDrawing_Outlined)
                  Box(PosX, PosY, txtHeight, txtHeight, BlendColor_(Chart()\Series()\Color, Chart()\Color\Border, 40))
                  
                  Chart()\Series()\Legend\X      = PosX
                  Chart()\Series()\Legend\Y      = PosY
                  Chart()\Series()\Legend\Width  = txtHeight + dpiX(5) + TextWidth(Chart()\Series()\Label)
                  Chart()\Series()\Legend\Height = txtHeight
                  
                  PosX + txtHeight + dpiX(5)
        
                  DrawingMode(#PB_2DDrawing_Transparent)
                  DrawText(PosX, PosY, Chart()\Series()\Label, Chart()\Color\Front)
                  
                  PosX + TextWidth(Chart()\Series()\Label) + dpiX(10)
        
                EndIf 
                
              Next
              
            EndIf ;}
            
          EndIf  
          
        EndIf
        
        StopDrawing()
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_Horizontal
    
    Procedure   DrawHorizontalChart_(X.i, Y.i, Width.i, Height.i)
      Define.i PosX, PosY, sHeight, bWidth, bHeight, maxLabelWidth
      Define.i txtX, txtY, txtWidth, txtHeight, axisY
      Define.i n, Items, Spaces, ScaleLines, Color, Gradient, maxValue, minValue
      Define.f SpaceX, Quotient, Calc
      Define.s Text$, Percent$
      
      If StartDrawing(CanvasOutput(Chart()\CanvasNum))
      
        DrawingFont(Chart()\FontID)
        
        Chart()\Current\MaximumY  = Chart()\Maximum ;{ Maximum
        maxValue = MaximumValue_()
        If Chart()\Current\MaximumY = #PB_Default
          Chart()\Current\MaximumY = maxValue
        ElseIf Chart()\Bar\Flags & #NoAutoAdjust = #False
          Chart()\Current\MaximumY = Chart()\Maximum
          If maxValue > Chart()\Current\MaximumY : Chart()\Current\MaximumY = maxValue : EndIf
        EndIf ;}
  
        Chart()\Current\MinimumY  = Chart()\Minimum ; Minimum
        If Chart()\Bar\Flags & #NoAutoAdjust = #False
          Chart()\Current\MinimumY = Chart()\Minimum
          If minValue < Chart()\Current\MinimumY : Chart()\Current\MinimumY = minValue : EndIf
        EndIf
        
        If Chart()\Current\MinimumY < 0 : Chart()\Current\MinimumY = 0 : EndIf
        
        maxLabelWidth = MaxLabelWidth_()
        
        txtHeight = TextHeight("Abc")
        txtWidth  = maxLabelWidth
       
        X  + maxLabelWidth + dpiX(2)
        
        Width  - maxLabelWidth - dpiX(5)
        Height - txtHeight - dpiY(4)
        
        Chart()\EventSize\X = X
        Chart()\EventSize\Y = Y
        Chart()\EventSize\Width  = Width
        Chart()\EventSize\Height = Height
        
        Chart()\Bar\Range = Abs(Chart()\Current\MaximumY - Chart()\Current\MinimumY)
        
        ;{ --- Calc Bar & Spacing Width ---
        Items  = ListSize(Chart()\Item())
        Spaces = Items + 1
        
        If Chart()\Bar\Width = #PB_Default And Chart()\Bar\Spacing = #PB_Default
          bHeight = Round(Height / (Items + Spaces), #PB_Round_Nearest)
          sHeight = bHeight
        ElseIf Chart()\Bar\Width = #PB_Default
          sHeight = Chart()\Bar\Spacing
          If Items : bHeight = Round((Height - (sHeight * Spaces)) / Items, #PB_Round_Nearest) : EndIf
        ElseIf Chart()\Bar\Spacing = #PB_Default
          bHeight = Chart()\Bar\Width
          sHeight = Round((Height - (bHeight * Items)) / Spaces, #PB_Round_Nearest)
        Else  
          bHeight = Chart()\Bar\Width
          sHeight = Chart()\Bar\Spacing
        EndIf ;}
      
        ;{ --- Draw Coordinate Axes ---
        Line(X, Y + Height, Width, 1, Chart()\Color\Axis)
        
        If Chart()\Bar\ScaleLines = #PB_Default
          If Chart()\Bar\ScaleSpacing = 0 : Chart()\Bar\ScaleSpacing = 1 : EndIf
          ScaleLines = Width / ((TextWidth(Str(Chart()\Current\MaximumY)) + dpiX(4)) * Chart()\Bar\ScaleSpacing) ; Labels width
          ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Bar\Range)
        Else
          ScaleLines = Chart()\Bar\ScaleLines
        EndIf
    
        If ScaleLines
          
          Quotient = Chart()\Bar\Range  / ScaleLines
          SpaceX   = Width / ScaleLines
          
          PosY = Y + Height
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          For n = 0 To ScaleLines
            
            PosX = X + Round(n * SpaceX, #PB_Round_Nearest)
            
            If Chart()\Flags & #ShowLines
              Line(PosX, Y, 1, Height, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
            EndIf
            
            Line(PosX, PosY - dpiX(2), 1, dpiX(5), Chart()\Color\Axis)
            Text$ = Str(Quotient * n)
            txtY = PosY + dpix(4)
            txtX = PosX - Round(TextWidth(Text$) / 2, #PB_Round_Nearest)
            DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          Next
    
          ;If Chart()\Current\MinimumY
          ;  PosY = Y + Height
          ;  If Chart()\Flags & #ShowLines
          ;    Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
          ;  EndIf
          ;  Line(X - dpiX(2), PosY, dpiX(6), 1, Chart()\Color\Axis)
          ;  Text$ = Str(Chart()\Current\MinimumY)
          ;  txtX = X - TextWidth(Text$) - dpix(4)
          ;  txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
          ;  DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          ;EndIf
          
          Line(X, Y, 1, Height, Chart()\Color\Axis)
          
        EndIf ;} 
        
        PosX = X + dpiX(1)
        PosY = Y + sHeight
        
        ForEach Chart()\Item()
          
          Quotient = Width / Chart()\Bar\Range
          bWidth   = (Chart()\Item()\Value - Chart()\Current\MinimumY) * Quotient
          
          ;{ --- Set text for #ShowValue or #ShowPercent ---
          Calc = (Chart()\Item()\Value - Chart()\Current\MinimumY) * 100
          If Calc <> 0
            Percent$ = Str((Calc / Chart()\Bar\Range)) + "%"
          Else
            Percent$ = "0%"
          EndIf
          
          If Chart()\Flags & #ShowValue
            Text$ = Str(Chart()\Item()\Value)
          ElseIf Chart()\Flags & #ShowPercent  
            Text$ = Percent$
          Else
            Text$ = GetText_(Chart()\Item()\Text)
          EndIf ;}
          
          ;{ --- Draw Bars ---
          Color = Chart()\Item()\Color
          If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
          
          Gradient = Chart()\Item()\Gradient
          If Gradient = #PB_Default : Gradient = BlendColor_(Color, Chart()\Color\Back, 60) : EndIf
          
          If (Chart()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Item()\Value <= Chart()\Current\MaximumY)  Or Chart()\Bar\Flags & #OutOfRange
            
            If Chart()\Bar\Flags & #OutOfRange : ClipOutput(X + dpiX(1), Y, Width, Height) : EndIf 
            
            If Color <> Gradient ;{ Gradient color
    
              DrawingMode(#PB_2DDrawing_Gradient)
              FrontColor(Gradient)
              BackColor(Color)
              LinearGradient(PosX, PosY, PosX + bWidth, PosY)
              Box(PosX, PosY, bWidth, bHeight)
              ;}
            Else                 ;{ Solid color
              
              DrawingMode(#PB_2DDrawing_Default)
              Box(PosX, PosY, bWidth, bHeight, Color)
              ;}
            EndIf
          
            ;{ --- Draw Bar Border ---
            If Chart()\Bar\Flags & #NoBorder = #False
              DrawingMode(#PB_2DDrawing_Outlined)
              If Chart()\Item()\Border = #PB_Default
                Box(PosX, PosY, bWidth, bHeight, BlendColor_(Color, Chart()\Color\Border, 60))
              Else
                Box(PosX, PosY, bWidth, bHeight, Chart()\Item()\Border)
              EndIf
            EndIf ;}
            
            If Chart()\Bar\Flags & #OutOfRange ;{
              If Chart()\Item()\Value < Chart()\Current\MinimumY Or Chart()\Item()\Value > Chart()\Current\MaximumY
                Color = #Error
              EndIf
              UnclipOutput()
              ;}
            EndIf 
            
          Else
            bWidth = 0
            Chart()\Item()\Width = bWidth
            Color = #Error
          EndIf ;}
          
          ;{ --- Set Data ----
          Chart()\Item()\X      = PosX
          Chart()\Item()\Y      = PosY
          Chart()\Item()\Width  = bWidth
          Chart()\Item()\Height = bHeight
          ;}
          
          ;{ --- Draw Text ---
          If Text$ 
            
            DrawingFont(Chart()\Bar\FontID)
            txtHeight = TextHeight("Abc")

            DrawingMode(#PB_2DDrawing_Transparent)
  
            txtY = PosY + Round((bHeight - txtHeight) / 2, #PB_Round_Nearest)
  
            If bWidth < TextWidth(Text$) + dpiY(8) Or bHeight < txtHeight + dpiY(2)
              txtX = PosX + bWidth + dpiY(3)
            Else
              txtX = PosX + bWidth - TextWidth(Text$) - dpiX(4)
            EndIf
            
            If Color = #Error
              
              If Chart()\Bar\Flags & #OutOfRange
                If Chart()\Item()\Value < 0
                  txtX = X + dpiY(5)
                Else
                  txtX = X + Width - TextWidth(Text$) - dpiY(5)
                EndIf
                If Chart()\Item()\Color = #PB_Default
                  DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Color\Back, 60))
                Else  
                  DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Item()\Color, 60))
                EndIf
              Else
                DrawText(PosX + bWidth + dpiY(3), txtY, Text$, $0000FF)
              EndIf
              
            Else
              DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 60))
            EndIf  
            
          EndIf;}
          
          ;{ --- Draw Labels ---
          DrawingFont(Chart()\Bar\FontID)
          txtHeight = TextHeight("Abc")
          
          Text$ = Chart()\Item()\Label
          txtX  = PosX - TextWidth(Text$) - dpiX(5)
          txtY  = PosY + ((bHeight - txtHeight) / 2)

          DrawingMode(#PB_2DDrawing_Transparent)
          If Color = #Error
            
            If Chart()\Bar\Flags & #OutOfRange
              If Chart()\Bar\Flags & #Colored
                If Chart()\Item()\Color = #PB_Default
                  DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Color\Back, 30))
                Else
                  DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Item()\Color, 30))
                EndIf
              Else
                DrawText(txtX, txtY, Text$, Chart()\Color\Front)
              EndIf 
            Else
              DrawText(txtX, txtY, Text$, $808080)
            EndIf
            
          ElseIf Chart()\Bar\Flags & #Colored
            DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 30))
          Else
            DrawText(txtX, txtY, Text$, Chart()\Color\Front)
          EndIf ;}
          
          PosY + bHeight + sHeight
        Next
        
        StopDrawing()
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  Procedure   DrawBarChart_(X.i, Y.i, Width.i, Height.i)
    Define.i PosX, PosY, sWidth, bWidth, bHeight, nHeight, pHeight
    Define.i txtX, txtY, txtWidth, txtHeight, axisY
    Define.i n, Items, Spaces, ScaleLines, Color, Gradient, maxValue, minValue
    Define.f SpaceY, Quotient, Calc
    Define.s Text$, Percent$
    
    If StartDrawing(CanvasOutput(Chart()\CanvasNum))
      
      DrawingFont(Chart()\FontID)
    
      Chart()\Current\MaximumY  = Chart()\Maximum ;{ Maximum
      maxValue = MaximumValue_()
      If Chart()\Current\MaximumY = #PB_Default
        Chart()\Current\MaximumY = maxValue
      ElseIf Chart()\Bar\Flags & #NoAutoAdjust = #False
        Chart()\Current\MaximumY = Chart()\Maximum
        If maxValue > Chart()\Current\MaximumY : Chart()\Current\MaximumY = maxValue : EndIf
      EndIf ;}
      
      Chart()\Current\MinimumY  = Chart()\Minimum ;{ Minimum
      minValue = MinimumValue_()
      If Chart()\Current\MinimumY = #PB_Default
        Chart()\Current\MinimumY = minValue
      ElseIf Chart()\Bar\Flags & #NoAutoAdjust = #False
        If minValue < Chart()\Current\MinimumY : Chart()\Current\MinimumY = minValue : EndIf
      EndIf ;}

      txtHeight = TextHeight("Abc")
      txtWidth  = TextWidth(Str(Chart()\Current\MaximumY))
     
      X  + txtWidth + dpiX(2)
      Y  + (txtHeight / 2)
      
      Width  - txtWidth - dpiX(2)
      Height - (txtHeight * 1.5) - dpiY(3)
      
      Chart()\Current\Offset = txtHeight / 2
      
      Chart()\EventSize\X = X
      Chart()\EventSize\Y = Y
      Chart()\EventSize\Width  = Width
      Chart()\EventSize\Height = Height
      
      Chart()\Bar\Range = Chart()\Current\MaximumY - Chart()\Current\MinimumY
      
      ;{ --- Calc Height for positive and negative Values ---
      If Chart()\Current\MinimumY < 0
        Quotient = Height / Chart()\Bar\Range
        pHeight  = Quotient * Chart()\Current\MaximumY ; positiv
        nHeight  = Quotient * Chart()\Current\MinimumY ; negativ 
      Else
        pHeight = Height ; positiv
        nHeight = 0      ; negativ
      EndIf ;}
      
      ;{ --- Calc Bar & Spacing Width ---
      Items  = ListSize(Chart()\Item())
      Spaces = Items + 1
      
      If Chart()\Bar\Width = #PB_Default And Chart()\Bar\Spacing = #PB_Default
        bWidth = Round(Width / (Items + Spaces), #PB_Round_Nearest)
        sWidth = bWidth
      ElseIf Chart()\Bar\Width = #PB_Default
        sWidth = Chart()\Bar\Spacing
        If Items : bWidth = Round((Width - (sWidth * Spaces)) / Items, #PB_Round_Nearest) : EndIf
      ElseIf Chart()\Bar\Spacing = #PB_Default
        bWidth = Chart()\Bar\Width
        sWidth = Round((Width - (bWidth * Items)) / Spaces, #PB_Round_Nearest)
      Else  
        bWidth = Chart()\Bar\Width
        sWidth = Chart()\Bar\Spacing
      EndIf ;}
    
      ;{ --- Draw Coordinate Axes ---
      Line(X, Y, 1, Height, Chart()\Color\Axis)

      If Chart()\Bar\ScaleLines = #PB_Default
        If Chart()\Bar\ScaleSpacing = 0 : Chart()\Bar\ScaleSpacing = 1 : EndIf
        ScaleLines = Height / (txtHeight * Chart()\Bar\ScaleSpacing)
        ScaleLines = CalcScaleLines_(ScaleLines, Chart()\Bar\Range)
      Else
        ScaleLines = Chart()\Bar\ScaleLines
      EndIf
  
      If ScaleLines
        
        Quotient = Chart()\Bar\Range  / ScaleLines
        SpaceY   = Height / ScaleLines
        
        DrawingMode(#PB_2DDrawing_Transparent)
        
        For n = 0 To ScaleLines
          PosY = Y + Round(n * SpaceY, #PB_Round_Nearest)
          If Chart()\Flags & #ShowLines
            Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
          EndIf 
          Line(X - dpiX(2), PosY, dpiX(5), 1, Chart()\Color\Axis)
          Text$ = Str(Chart()\Current\MaximumY - (Quotient * n))
          txtX = X - TextWidth(Text$) - dpix(4)
          txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
          DrawText(txtX, txtY, Text$, Chart()\Color\Front)
        Next
  
        ;If Chart()\Current\MinimumY
        ;  PosY = Y + Height
        ;  If Chart()\Flags & #ShowLines
        ;    Line(X, PosY, Width, 1, BlendColor_(Chart()\Color\Axis, Chart()\Color\Back, 10))
        ;  EndIf
        ;  Line(X - dpiX(2), PosY, dpiX(6), 1, Chart()\Color\Axis)
        ;  Text$ = Str(Chart()\Current\MinimumY)
        ;  txtX = X - TextWidth(Text$) - dpix(4)
        ;  txtY = PosY - Round(txtHeight / 2, #PB_Round_Nearest)
        ;  DrawText(txtX, txtY, Text$, Chart()\Color\Front)
        ;EndIf
        
        Line(X, Y + pHeight, Width, 1, Chart()\Color\Axis)
        
      EndIf ;} 
      
      PosX = X + sWidth
  
      ForEach Chart()\Item()
        
        ;{ --- Calc Position & Height---
        If Chart()\Current\MinimumY < 0
          If Chart()\Item()\Value < 0
            PosY = Y + pHeight + dpiY(1)
            Quotient = nHeight / Chart()\Current\MinimumY
          Else
            PosY = Y + pHeight
            Quotient = pHeight / Chart()\Current\MaximumY
          EndIf
          bHeight = Chart()\Item()\Value * Quotient
        Else
          PosY = Y + pHeight
          Quotient = Height / Chart()\Bar\Range
          bHeight = (Chart()\Item()\Value - Chart()\Current\MinimumY) * Quotient
        EndIf ;}
        
        ;{ --- Set text for #ShowValue or #ShowPercent ---
        Calc = (Chart()\Item()\Value - Chart()\Current\MinimumY) * 100
        If Calc <> 0
          Percent$ = Str((Calc / Chart()\Bar\Range)) + "%"
        Else
          Percent$ = "0%"
        EndIf
        
        If Chart()\Flags & #ShowValue
          Text$ = Str(Chart()\Item()\Value)
        ElseIf Chart()\Flags & #ShowPercent  
          Text$ = Percent$
        Else
          Text$ = GetText_(Chart()\Item()\Text)
        EndIf ;}
  
        ;{ --- Draw Bars ---
        Color = Chart()\Item()\Color
        If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
        
        Gradient = Chart()\Item()\Gradient
        If Gradient = #PB_Default : Gradient = BlendColor_(Color, Chart()\Color\Back, 60) : EndIf
        
        If (Chart()\Item()\Value >= Chart()\Current\MinimumY And Chart()\Item()\Value <= Chart()\Current\MaximumY) Or Chart()\Bar\Flags & #OutOfRange
          
          If Chart()\Bar\Flags & #OutOfRange : ClipOutput(X, Y, Width, Height) : EndIf 
          
          If Color <> Gradient ;{ Gradient color
  
            DrawingMode(#PB_2DDrawing_Gradient)
            FrontColor(Color)
            BackColor(Gradient)
            LinearGradient(PosX, PosY - bHeight, PosX, PosY)
            Box(PosX, PosY - bHeight, bWidth, bHeight)
            ;}
          Else                 ;{ Solid color
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(PosX, PosY - bHeight, bWidth, bHeight, Color)
            ;}
          EndIf
        
          ;{ --- Draw Bar Border ---
          If Chart()\Bar\Flags & #NoBorder = #False
            DrawingMode(#PB_2DDrawing_Outlined)
            If Chart()\Item()\Border = #PB_Default
              Box(PosX, PosY, bWidth, -bHeight, BlendColor_(Color, Chart()\Color\Border, 60))
            Else
              Box(PosX, PosY, bWidth, -bHeight, Chart()\Item()\Border)
            EndIf
          EndIf ;}
          
          If Chart()\Bar\Flags & #OutOfRange ;{
            If Chart()\Item()\Value < Chart()\Current\MinimumY Or Chart()\Item()\Value > Chart()\Current\MaximumY
              Color = #Error
            EndIf
            UnclipOutput()
            ;}
          EndIf 
          
        Else
          bHeight = 0
          Chart()\Item()\Height = bHeight
          Color = #Error
        EndIf ;}
        
        ;{ --- Set data ----
        If Chart()\Item()\Value < 0
          Chart()\Item()\X      = PosX
          Chart()\Item()\Y      = PosY
          Chart()\Item()\Width  = bWidth
          Chart()\Item()\Height = Abs(bHeight)
        Else
          Chart()\Item()\X      = PosX
          Chart()\Item()\Y      = PosY - bHeight
          Chart()\Item()\Width  = bWidth
          Chart()\Item()\Height = bHeight
        EndIf ;}
        
        ;{ --- Draw Text ---
        If Text$ 
          
          DrawingFont(Chart()\Bar\FontID)
          txtHeight = TextHeight("Abc")
          
          DrawingMode(#PB_2DDrawing_Transparent)
          
          txtX = PosX + ((bWidth - TextWidth(Text$)) / 2)
          
          If Abs(bHeight) < txtHeight + dpiY(4) Or Abs(bWidth) < TextWidth(Text$) + dpiY(4)
            If Chart()\Item()\Value < 0
              txtY = PosY - txtHeight - dpiY(1)
            Else
              txtY = PosY - bHeight - txtHeight - dpiY(1)
            EndIf
          Else
            If Chart()\Item()\Value < 0
              txtY = PosY - bHeight - txtHeight - dpiY(2)
            Else
              txtY = PosY - bHeight + dpiY(2)
            EndIf 
          EndIf
          
          If Color = #Error
            
            If Chart()\Bar\Flags & #OutOfRange
              If Chart()\Item()\Value < 0
                txtY = Y + Height - txtHeight - dpiY(1)
              Else
                txtY = Y + dpiY(5)
              EndIf
              If Chart()\Item()\Color = #PB_Default
                DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Color\Back, 60))
              Else  
                DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Item()\Color, 60))
              EndIf
            Else
              If Chart()\Item()\Value < 0
                DrawText(txtX, txtY - txtHeight - dpiY(2), Text$, $0000FF)
              Else
                DrawText(txtX, txtY - dpiY(2), Text$, $0000FF)
              EndIf
            EndIf
          Else
            DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 60))
          EndIf  
          
        EndIf;}
        
        ;{ --- Draw Labels ---
        DrawingFont(Chart()\FontID)
        txtHeight = TextHeight("Abc")
        
        Text$ = Chart()\Item()\Label
        txtX  = PosX + ((bWidth - TextWidth(Text$)) / 2)
        txtY  = Y + Height + dpiY(3)
        
        DrawingMode(#PB_2DDrawing_Transparent)
        If Color = #Error
          
          If Chart()\Bar\Flags & #OutOfRange
            If Chart()\Bar\Flags & #Colored
              If Chart()\Item()\Color = #PB_Default
                DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Color\Back, 30))
              Else
                DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Chart()\Item()\Color, 30))
              EndIf
            Else
              DrawText(txtX, txtY, Text$, Chart()\Color\Front)
            EndIf 
          Else
            DrawText(txtX, txtY, Text$, $808080)
          EndIf
          
        ElseIf Chart()\Bar\Flags & #Colored
          DrawText(txtX, txtY, Text$, BlendColor_(Chart()\Color\Front, Color, 30))
        Else
          DrawText(txtX, txtY, Text$, Chart()\Color\Front)
        EndIf ;}
        
        PosX + bWidth + sWidth
      Next
      
      StopDrawing()
    EndIf 
    
  EndProcedure
  
  Procedure   Draw_()
    Define.i X, Y, Width, Height
    
    X = Chart()\Margin\Left
    Y = Chart()\Margin\Top
    
    Width  = Chart()\Size\Width  - Chart()\Margin\Left - Chart()\Margin\Right
    Height = Chart()\Size\Height - Chart()\Margin\Top  - Chart()\Margin\Bottom

    If StartDrawing(CanvasOutput(Chart()\CanvasNum))

      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, Chart()\Size\Width, Chart()\Size\Height, Chart()\Color\Back)
      ;}

      StopDrawing()
    EndIf   
      
    If Chart()\Flags & #LineChart And Chart()\Flags & #DataSeries
      
      CompilerIf #Enable_DataSeries
        CompilerIf #Enable_LineChart
          DrawLineSeries_(X, Y, Width, Height)
        CompilerEndIf
      CompilerEndIf
      
    ElseIf Chart()\Flags & #PieChart
      
      CompilerIf #Enable_PieChart
        DrawPieChart(X, Y, Width, Height)
      CompilerEndIf
      
    ElseIf Chart()\Flags & #DataSeries
      
      CompilerIf #Enable_DataSeries
        DrawBarSeries_(X, Y, Width, Height)
      CompilerEndIf
      
    ElseIf Chart()\Flags & #Horizontal
      
      CompilerIf #Enable_Horizontal
        DrawHorizontalChart_(X, Y, Width, Height)
      CompilerEndIf
      
    ElseIf Chart()\Flags & #LineChart
      
      CompilerIf #Enable_LineChart
        DrawLineChart_(X, Y, Width, Height)
      CompilerEndIf
      
    ElseIf Chart()\Flags & #ScatterPlot  
      
      CompilerIf #Enable_ScatterPlot
        DrawScatterPlot(X, Y, Width, Height)
      CompilerEndIf  
      
    Else
      
      DrawBarChart_(X, Y, Width, Height)
    
    EndIf
    
    If StartDrawing(CanvasOutput(Chart()\CanvasNum))
      
      ;{ _____ Border ____
      If Chart()\Flags & #Border
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0, 0, Chart()\Size\Width, Chart()\Size\Height, Chart()\Color\Border)
      EndIf ;}
      
      StopDrawing()
    EndIf    
   
  EndProcedure
  
  ;- __________ Events __________
  
  Procedure.i GetRadius_(X1.i, Y1.i, X2.i, Y2.i)
    Define.f X, Y
    X = X1 - X2
    Y = Y1 - Y2
    ProcedureReturn Sqr((X * X) + (Y * Y))
  EndProcedure
  
  Procedure   UpdateEventData_(Index.i, Label.s, Value.i=0, Color.i=#PB_Default, Series.s="", DataX.f=0, DataY.f=0)
    
    Chart()\Event\Index  = Index
    Chart()\Event\Value  = Value
    Chart()\Event\DataX  = DataX
    Chart()\Event\DataY  = DataY
    Chart()\Event\Label  = Label
    Chart()\Event\Series = Series
    Chart()\Event\Color  = Color

  EndProcedure
  
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Y, Angle, Radius
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Chart(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseY)
      
      If Chart()\Flags & #PieChart            ;{ Pie Chart
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          ForEach Chart()\Item()
            
            If X > Chart()\Item()\Legend\X And X < Chart()\Item()\Legend\X + Chart()\Item()\Legend\Width
              If Y > Chart()\Item()\Legend\Y And Y < Chart()\Item()\Legend\Y + Chart()\Item()\Legend\Height
                
                UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
                PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick)
                
                ProcedureReturn #True
              EndIf
            EndIf 
            
          Next
          ;}
        EndIf
        
        Radius = GetRadius_(Chart()\Pie\X, Chart()\Pie\Y, X, Y)
        If Radius < Chart()\Pie\Radius ; within the circle
          
          ForEach Chart()\Item()
            Angle = GetAngleDegree_(X, Y, Chart()\Pie\X, Chart()\Pie\Y)
            If Angle > Chart()\Item()\sAngle And Angle < Chart()\Item()\eAngle
              
              UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
              PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick, ListIndex(Chart()\Item()))
              
              ProcedureReturn #True
            EndIf
          Next 
          
        EndIf
        ;}
      ElseIf Chart()\Flags & #DataSeries      ;{ Data Series Chart 
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          If Chart()\Legend\Flags & #AllDataSeries
            
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                  
                  UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick)
                  
                  ProcedureReturn #True
                EndIf
              EndIf 
            Next
            
          Else
            
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                  If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                    
                    UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick)
                    
                  EndIf
                EndIf
              EndIf
            Next
            
          EndIf 
          ;}
        EndIf
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              If X > Chart()\Series()\Item()\X And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                If Y > Chart()\Series()\Item()\Y And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height

                  UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, Chart()\Series()\Item()\Value, Chart()\Series()\Color, Chart()\Series()\Label)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick, ListIndex(Chart()\Series()\Item()))
                  
                  ProcedureReturn #True
                EndIf
              EndIf
            Next
          EndIf
        Next
        ;}
      ElseIf Chart()\Flags & #ScatterPlot     ;{ Scatter Plot Chart 
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          If Chart()\Legend\Flags & #AllScatterPlots
            
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                  
                  UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick)
                  
                  ProcedureReturn #True
                EndIf
              EndIf 
            Next

          EndIf 
          ;}
        EndIf
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              If X > Chart()\Series()\Item()\X And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                If Y > Chart()\Series()\Item()\Y And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height

                  UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, 0, Chart()\Series()\Color, Chart()\Series()\Label, Chart()\Series()\Item()\DataX, Chart()\Series()\Item()\DataY)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick, ListIndex(Chart()\Series()\Item()))
                  
                  ProcedureReturn #True
                EndIf
              EndIf
            Next
          EndIf
        Next
        ;}  
        
      Else                                    ;{ Bar / Line Chart
        
        ForEach Chart()\Item()
          If X > Chart()\Item()\X And X < Chart()\Item()\X + Chart()\Item()\Width
            If Y > Chart()\Item()\Y And Y < Chart()\Item()\Y + Chart()\Item()\Height
              
              UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
              PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftDoubleClick, ListIndex(Chart()\Item()))
              
              ProcedureReturn #True
            EndIf 
          EndIf
        Next  
        ;}
      EndIf 
      
    EndIf
    
  EndProcedure
  
  Procedure _RightClickHandler()
    Define.i X, Y, Angle, Radius
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Chart(), Str(GadgetNum))

      X = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseY)
      
      If Chart()\Flags & #PieChart            ;{ Pie Chart
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          ForEach Chart()\Item()
            
            If X > Chart()\Item()\Legend\X And X < Chart()\Item()\Legend\X + Chart()\Item()\Legend\Width
              If Y > Chart()\Item()\Legend\Y And Y < Chart()\Item()\Legend\Y + Chart()\Item()\Legend\Height
                
                UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
                
                If Chart()\Legend\Flags & #PopUpMenu
                  If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                    UpdatePopUpMenu_()
                    DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                  EndIf
                Else  
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick)
                EndIf
                
                ProcedureReturn #True
              EndIf
            EndIf 
            
          Next
          ;}
        EndIf

        Radius = GetRadius_(Chart()\Pie\X, Chart()\Pie\Y, X, Y)
        If Radius < Chart()\Pie\Radius ; within the circle
          
          ForEach Chart()\Item()
            
            Angle = GetAngleDegree_(X, Y, Chart()\Pie\X, Chart()\Pie\Y)
            If Angle > Chart()\Item()\sAngle And Angle < Chart()\Item()\eAngle
              
              UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
              
              If Chart()\Pie\Flags & #PopUpMenu
                If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                  UpdatePopUpMenu_()
                  DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                EndIf
              Else  
                PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick, ListIndex(Chart()\Item()))
              EndIf
              
              ProcedureReturn #True
            EndIf
            
          Next 
          
        EndIf
        ;}
      ElseIf Chart()\Flags & #DataSeries      ;{ Data Series Chart
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          If Chart()\Legend\Flags & #AllDataSeries
            
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                  
                  UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                  
                  If Chart()\Legend\Flags & #PopUpMenu
                    If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                      UpdatePopUpMenu_()
                      DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                    EndIf
                  Else  
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick)
                  EndIf
                  
                  ProcedureReturn #True
                EndIf
              EndIf 
            Next
            
          Else
            
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                  If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                    
                    UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                    
                    If Chart()\Legend\Flags & #PopUpMenu
                      If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                        UpdatePopUpMenu_()
                        DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                      EndIf
                    Else  
                      PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick)
                    EndIf
                    
                    ProcedureReturn #True
                  EndIf
                EndIf
              EndIf
            Next
            
          EndIf 
          ;}
        EndIf
        
        ForEach Chart()\VisibleData()         ;{ Bars / Circles
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              
              If X > Chart()\Series()\Item()\X And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                If Y > Chart()\Series()\Item()\Y And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                  
                  UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, Chart()\Series()\Item()\Value, Chart()\Series()\Color, Chart()\Series()\Label)
                  
                  If Chart()\Bar\Flags & #PopUpMenu
                    If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                      UpdatePopUpMenu_()
                      DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                    EndIf
                  Else  
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick, ListIndex(Chart()\Series()\Item()))
                  EndIf

                  ProcedureReturn #True
                EndIf
              EndIf
              
            Next
          EndIf
        Next ;}
        
        ;}
      ElseIf Chart()\Flags & #ScatterPlot     ;{ ScatterPlot
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          If Chart()\Legend\Flags & #AllScatterPlots
            
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                  
                  UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                  
                  If Chart()\Legend\Flags & #PopUpMenu
                    If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                      UpdatePopUpMenu_()
                      DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                    EndIf
                  Else  
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick)
                  EndIf
                  
                  ProcedureReturn #True
                EndIf
              EndIf 
            Next
            
          Else
            
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                  If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                    
                    UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                    
                    If Chart()\Legend\Flags & #PopUpMenu
                      If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                        UpdatePopUpMenu_()
                        DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                      EndIf
                    Else  
                      PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick)
                    EndIf
                    
                    ProcedureReturn #True
                  EndIf
                EndIf
              EndIf
            Next
            
          EndIf 
          ;}
        EndIf
        
        ForEach Chart()\VisibleData()         ;{ Circles
          If SelectElement(Chart()\Series(), Chart()\VisibleData())
            ForEach Chart()\Series()\Item()
              
              If X > Chart()\Series()\Item()\X And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                If Y > Chart()\Series()\Item()\Y And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                  
                  UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, 0, Chart()\Series()\Color, Chart()\Series()\Label, Chart()\Series()\Item()\DataX, Chart()\Series()\Item()\DataY)
                  
                  If Chart()\Scatter\Flags & #PopUpMenu
                    If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                      UpdatePopUpMenu_()
                      DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                    EndIf
                  Else  
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick, ListIndex(Chart()\Series()\Item()))
                  EndIf

                  ProcedureReturn #True
                EndIf
              EndIf
              
            Next
          EndIf
        Next ;}
     
        ;}
      Else                                    ;{ Bar / Line Chart
        
        ForEach Chart()\Item()
          
          If X > Chart()\Item()\X And X < Chart()\Item()\X + Chart()\Item()\Width
            If Y > Chart()\Item()\Y And Y < Chart()\Item()\Y + Chart()\Item()\Height
              
              UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)

              If Chart()\Bar\Flags & #PopUpMenu
                If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
                  UpdatePopUpMenu_()
                  DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
                EndIf
              Else
                PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_RightClick, ListIndex(Chart()\Item()))
              EndIf
              
              ProcedureReturn #True 
            EndIf 
          EndIf
          
        Next
        
        ;}
      EndIf
      
      If Chart()\Flags & #PopUpMenu
        If X > = Chart()\EventSize\X And X <= Chart()\EventSize\X + Chart()\EventSize\Width
          If Y >= Chart()\EventSize\Y And Y <= Chart()\EventSize\Y + Chart()\EventSize\Height
            If IsWindow(Chart()\Window\Num) And IsMenu(Chart()\PopUpNum)
              UpdatePopUpMenu_()
              DisplayPopupMenu(Chart()\PopUpNum, WindowID(Chart()\Window\Num))
            EndIf
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonDownHandler()
    Define.i X, Y, Radius, Value
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Chart(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseY) 
      
      CompilerIf #Enable_ModifyByCursor
        
        If Chart()\Line\Flags & #ModifyByCursor

          If Chart()\Flags & #LineChart
            If Chart()\Flags & #DataSeries ;{ DataSeries
              
              Radius = Chart()\Series()\Item()\Width / 2
              
              ForEach Chart()\VisibleData()
                If SelectElement(Chart()\Series(), Chart()\VisibleData())
                  
                  ForEach Chart()\Series()\Item()

                    If X > Chart()\Series()\Item()\X - Radius And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                      If Y > Chart()\Series()\Item()\Y - Radius  And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                        If Chart()\Mouse\State = #Mouse_Released
                          Chart()\Mouse\downY   = Y
                          Chart()\Mouse\Current = ListIndex(Chart()\Series()\Item())
                          Chart()\Mouse\State   = #Mouse_Pressed
                          ProcedureReturn #True
                        EndIf
                      EndIf
                    EndIf
                    
                  Next
                  
                EndIf
              Next
              ;}  
            Else                           ;{ Single 
              
              ForEach Chart()\Item()
                
                Radius = Chart()\Item()\Width / 2
                
                If X > Chart()\Item()\X - Radius And X < Chart()\Item()\X + Chart()\Item()\Width
                  If Y > Chart()\Item()\Y - Radius And Y < Chart()\Item()\Y + Chart()\Item()\Height
                    If Chart()\Mouse\State = #Mouse_Released
                      Chart()\Mouse\downY   = Y
                      Chart()\Mouse\Current = ListIndex(Chart()\Item())
                      Chart()\Mouse\State   = #Mouse_Pressed
                      ProcedureReturn #True
                    EndIf
                  EndIf 
                EndIf
              Next  
              ;}
            EndIf
          EndIf
          
        EndIf
        
      CompilerEndIf
      
    EndIf
    
  EndProcedure

  Procedure _LeftButtonUpHandler()  
    Define.i X, Y, Angle, Radius, Value
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Chart(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Chart()\CanvasNum, #PB_Canvas_MouseY)
      
      CompilerIf #Enable_ModifyByCursor
        
        If Chart()\Line\Flags & #ModifyByCursor
          
          If Chart()\Mouse\State = #Mouse_Pressed
            Chart()\Mouse\Current = -1
            Chart()\Mouse\State   = #Mouse_Released
          EndIf
          
        EndIf
        
      CompilerEndIf
      
      If Chart()\Flags & #PieChart            ;{ Pie Chart
        
        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          ForEach Chart()\Item()
            
            If X > Chart()\Item()\Legend\X And X < Chart()\Item()\Legend\X + Chart()\Item()\Legend\Width
              If Y > Chart()\Item()\Legend\Y And Y < Chart()\Item()\Legend\Y + Chart()\Item()\Legend\Height
                
                UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
                PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick)
                
                ProcedureReturn #True
              EndIf
            EndIf 
            
          Next
          ;}
        EndIf
       
        Radius = GetRadius_(Chart()\Pie\X, Chart()\Pie\Y, X, Y)
        If Radius < Chart()\Pie\Radius ; within the circle
          
          ForEach Chart()\Item()
            Angle = GetAngleDegree_(X, Y, Chart()\Pie\X, Chart()\Pie\Y)
            If Angle > Chart()\Item()\sAngle And Angle < Chart()\Item()\eAngle
              
              UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
              PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Chart()\Item()))
              
              ProcedureReturn #True
            EndIf
          Next 
          
        EndIf  
        ;}
      ElseIf Chart()\Flags & #DataSeries      ;{ Data Series Chart

        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          If Chart()\Legend\Flags & #AllDataSeries
            
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                  
                  UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick)
                  
                  ProcedureReturn #True
                EndIf
              EndIf 
            Next
            
          Else
            
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                  If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                    
                    UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick)
                    
                  EndIf
                EndIf
              EndIf
            Next
            
          EndIf 
          ;}
        EndIf
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())

            ForEach Chart()\Series()\Item()
             
              If Chart()\Flags & #LineChart
              
                Radius = Chart()\Series()\Item()\Width / 2
                
                If X > Chart()\Series()\Item()\X - Radius And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                  If Y > Chart()\Series()\Item()\Y - Radius  And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                    
                    UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, Chart()\Series()\Item()\Value, Chart()\Series()\Color, Chart()\Series()\Label)
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Chart()\Series()\Item()))
                    
                    ProcedureReturn #True
                  EndIf
                EndIf
                
              Else
                
                If X > Chart()\Series()\Item()\X  And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                  If Y > Chart()\Series()\Item()\Y  And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                    
                    UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, Chart()\Series()\Item()\Value, Chart()\Series()\Color, Chart()\Series()\Label)
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Chart()\Series()\Item()))
                    
                    ProcedureReturn #True
                  EndIf
                EndIf
                
              EndIf
                
            Next
            
          EndIf
        Next
        ;}
      ElseIf Chart()\Flags & #ScatterPlot     ;{ Scatter Plot Chart

        If Chart()\Legend\Flags & #PostEvents ;{ Legend
          
          If Chart()\Legend\Flags & #AllDataSeries
            
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                  
                  UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick)
                  
                  ProcedureReturn #True
                EndIf
              EndIf 
            Next
            
          Else
            
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                  If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                    
                    UpdateEventData_(#NotValid, "", 0, Chart()\Series()\Color, Chart()\Series()\Label)
                    PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick)
                    
                  EndIf
                EndIf
              EndIf
            Next
            
          EndIf 
          ;}
        EndIf
        
        ForEach Chart()\VisibleData()
          If SelectElement(Chart()\Series(), Chart()\VisibleData())

            ForEach Chart()\Series()\Item()
             
              Radius = Chart()\Series()\Item()\Width / 2
              
              If X > Chart()\Series()\Item()\X - Radius And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                If Y > Chart()\Series()\Item()\Y - Radius  And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                  
                  UpdateEventData_(ListIndex(Chart()\Series()\Item()), Chart()\Series()\Item()\Label, 0, Chart()\Series()\Color, Chart()\Series()\Label, Chart()\Series()\Item()\DataX, Chart()\Series()\Item()\DataY)
                  PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Chart()\Series()\Item()))
                  
                  ProcedureReturn #True
                EndIf
              EndIf
             
            Next
            
          EndIf
        Next
        ;}  
      Else                                    ;{ Bar / Line Chart
        
        ForEach Chart()\Item()
        
          If Chart()\Flags & #LineChart
            
            Radius = Chart()\Item()\Width / 2
            
            If X > Chart()\Item()\X - Radius And X < Chart()\Item()\X + Chart()\Item()\Width
              If Y > Chart()\Item()\Y - Radius And Y < Chart()\Item()\Y + Chart()\Item()\Height
                
                UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
                PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Chart()\Item()))
                
                ProcedureReturn #True
              EndIf 
            EndIf
            
          Else
            
            If X > Chart()\Item()\X And X < Chart()\Item()\X + Chart()\Item()\Width
              If Y > Chart()\Item()\Y And Y < Chart()\Item()\Y + Chart()\Item()\Height
                
                UpdateEventData_(ListIndex(Chart()\Item()), Chart()\Item()\Label, Chart()\Item()\Value, Chart()\Item()\Color)
                PostEvent(#Event_Gadget, Chart()\Window\Num, Chart()\CanvasNum, #PB_EventType_LeftClick, ListIndex(Chart()\Item()))
                
                ProcedureReturn #True
              EndIf 
            EndIf
            
          EndIf
          
        Next 
        ;}
      EndIf 
      
    EndIf
    
  EndProcedure

  Procedure _MouseMoveHandler()
    Define.i X, Y, Radius, Angle, Value
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Chart(), Str(GadgetNum))
      
      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)

      If Chart()\Legend\Flags & #PostEvents ;{ Legend
        
        If Chart()\Flags & #PieChart        ;{ Pie Chart
          ForEach Chart()\Item()
            If X > Chart()\Item()\Legend\X And X < Chart()\Item()\Legend\X + Chart()\Item()\Legend\Width
              If Y > Chart()\Item()\Legend\Y And Y < Chart()\Item()\Legend\Y + Chart()\Item()\Legend\Height
                
                If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf
                
                ProcedureReturn #True
              EndIf
            EndIf 
          Next
          ;}
        ElseIf Chart()\Flags & #DataSeries  ;{ Data Series Chart

          If Chart()\Legend\Flags & #AllDataSeries
            ForEach Chart()\Series()
              If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height

                  If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf

                  ProcedureReturn #True
                EndIf
              EndIf 
            Next
          Else
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                If X > Chart()\Series()\Legend\X And X < Chart()\Series()\Legend\X + Chart()\Series()\Legend\Width
                  If Y > Chart()\Series()\Legend\Y And Y < Chart()\Series()\Legend\Y + Chart()\Series()\Legend\Height
                    
                    If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf
                    
                    ProcedureReturn #True
                  EndIf
                EndIf
              EndIf
            Next
          EndIf 
          ;}
        EndIf
        ;}
      EndIf  
      
      If X >= Chart()\EventSize\X And X <= Chart()\EventSize\X + Chart()\EventSize\Width
        If Y >= Chart()\EventSize\Y And Y <= Chart()\EventSize\Y + Chart()\EventSize\Height

          If Chart()\Flags & #PieChart        ;{ Pie Chart

            Radius = GetRadius_(Chart()\Pie\X, Chart()\Pie\Y, X, Y)
            If Radius < Chart()\Pie\Radius ; within the circle
              
              ForEach Chart()\Item()
                
                Angle = GetAngleDegree_(X, Y, Chart()\Pie\X, Chart()\Pie\Y)
                If Angle > Chart()\Item()\sAngle And Angle < Chart()\Item()\eAngle
                  
                  If Chart()\Flags & #ToolTips And Chart()\ToolTip = #False
                    GadgetToolTip(GadgetNum, GetText_(Chart()\ToolTipText))
                    Chart()\ToolTip = #True
                  EndIf
                  
                  If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf
                  
                  ProcedureReturn #True
                EndIf
                
              Next 
              
            EndIf
            ;}
          ElseIf Chart()\Flags & #DataSeries  ;{ Data Series Chart

            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                
                ForEach Chart()\Series()\Item()
                  
                  CompilerIf #Enable_ModifyByCursor
                    
                    If Chart()\Line\Flags & #ModifyByCursor
                      
                      If Chart()\Mouse\State = #Mouse_Pressed And Chart()\Mouse\Current = ListIndex(Chart()\Series()\Item())
                        
                        If X < Chart()\Series()\Item()\X - Chart()\Series()\Item()\Width Or X > Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                          Chart()\Mouse\Current = -1
                          Chart()\Mouse\State   = #Mouse_Released
                          If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default) : EndIf
                          ProcedureReturn #False
                        EndIf 
                        
                        ;{ Change value while the button is pressed
                        If Chart()\Mouse\downY <> Y
                          Value = Value_(Y)
                          If Value <> Chart()\Series()\Item()\Value
                            Chart()\Series()\Item()\Value = Value
                            Draw_()
                          EndIf
                        EndIf ;}
                        
                        ProcedureReturn #True
                      EndIf
                      
                    EndIf
                    
                  CompilerEndIf
                  
                  If Chart()\Flags & #LineChart
                    
                    Radius = (Chart()\Series()\Item()\Width / 2)
                    
                    If X > Chart()\Series()\Item()\X - Radius And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                      If Y > Chart()\Series()\Item()\Y - Radius And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                       
                        If Chart()\Flags & #ToolTips And Chart()\ToolTip = #False
                          GadgetToolTip(GadgetNum, GetText_(Chart()\ToolTipText))
                          Chart()\ToolTip = #True
                        EndIf

                        If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf

                        ProcedureReturn #True
                      EndIf
                    EndIf
                    
                  Else
                    
                    If X > Chart()\Series()\Item()\X And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                      If Y > Chart()\Series()\Item()\Y And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                       
                        If Chart()\Flags & #ToolTips And Chart()\ToolTip = #False
                          GadgetToolTip(GadgetNum, GetText_(Chart()\ToolTipText))
                          Chart()\ToolTip = #True
                        EndIf

                        If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf

                        ProcedureReturn #True
                      EndIf
                    EndIf
                    
                  EndIf 
                  
                Next
                
              EndIf
            Next
            ;}
          ElseIf Chart()\Flags & #ScatterPlot ;{ Scatter plot chart
            
            ForEach Chart()\VisibleData()
              If SelectElement(Chart()\Series(), Chart()\VisibleData())
                
                ForEach Chart()\Series()\Item()

                  Radius = (Chart()\Series()\Item()\Width / 2)
                  
                  If X > Chart()\Series()\Item()\X - Radius And X < Chart()\Series()\Item()\X + Chart()\Series()\Item()\Width
                    If Y > Chart()\Series()\Item()\Y - Radius And Y < Chart()\Series()\Item()\Y + Chart()\Series()\Item()\Height
                      
                      If Chart()\Flags & #ToolTips And Chart()\ToolTip = #False
                        GadgetToolTip(GadgetNum, GetText_(Chart()\ToolTipText))
                        Chart()\ToolTip = #True
                      EndIf

                      If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf

                      ProcedureReturn #True
                    EndIf
                  EndIf
 
                Next
                
              EndIf
            Next
            ;}
          Else                                ;{ Bar / Line Chart
            
            ForEach Chart()\Item()
              
              CompilerIf #Enable_ModifyByCursor
                
                If Chart()\Line\Flags & #ModifyByCursor
                  
                  If Chart()\Mouse\State = #Mouse_Pressed And Chart()\Mouse\Current = ListIndex(Chart()\Item())
                    
                    If X < Chart()\Item()\X - Chart()\Item()\Width Or X > Chart()\Item()\X + Chart()\Item()\Width
                      Chart()\Mouse\Current = -1
                      Chart()\Mouse\State   = #Mouse_Released
                      If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default) : EndIf
                    EndIf
                    
                    ;{ Change value While the button is pressed
                    If Chart()\Mouse\downY <> Y
                      Value = Value_(Y)
                      If Value <> Chart()\Item()\Value
                        Chart()\Item()\Value = Value
                        Draw_()
                      EndIf 
                    EndIf ;}
                    
                    ProcedureReturn #True
                  EndIf
                  
                EndIf
                
              CompilerEndIf
              
              If Chart()\Flags & #LineChart ;{ LineChart
                
                Radius = (Chart()\Item()\Width / 2)
                
                If X >= Chart()\Item()\X - Radius And X <= Chart()\Item()\X + Chart()\Item()\Width
                  If Y >= Chart()\Item()\Y - Radius And Y <= Chart()\Item()\Y + Chart()\Item()\Height
                    
                    If Chart()\Flags & #ToolTips And Chart()\ToolTip = #False
                      GadgetToolTip(GadgetNum, GetText_(Chart()\ToolTipText))
                      Chart()\ToolTip = #True
                    EndIf
                    
                    If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf
                    
                    ProcedureReturn #True
                  EndIf 
                EndIf
                ;}
              Else                           ;{ BarChart
                
                If X >= Chart()\Item()\X And X <= Chart()\Item()\X + Chart()\Item()\Width
                  If Y >= Chart()\Item()\Y And Y <= Chart()\Item()\Y + Chart()\Item()\Height
                    
                    If Chart()\Flags & #ToolTips And Chart()\ToolTip = #False
                      GadgetToolTip(GadgetNum, GetText_(Chart()\ToolTipText))
                      Chart()\ToolTip = #True
                    EndIf
                    
                    If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand) : EndIf
                    
                    ProcedureReturn #True
                  EndIf 
                EndIf
                ;}
              EndIf
              
            Next  
            ;}
          EndIf

        EndIf

      EndIf
        
      
      Chart()\ToolTip = #False
      GadgetToolTip(GadgetNum, "")
      
      If Chart()\Flags & #ChangeCursor : SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default) : EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(Chart(), Str(GadgetID))
      
      Chart()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      Chart()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach Chart()
      
      If IsGadget(Chart()\CanvasNum)
        
        If Chart()\Flags & #AutoResize
          
          If IsWindow(Chart()\Window\Num)
            
            OffSetX = WindowWidth(Chart()\Window\Num)  - Chart()\Window\Width
            OffsetY = WindowHeight(Chart()\Window\Num) - Chart()\Window\Height

            Chart()\Window\Width  = WindowWidth(Chart()\Window\Num)
            Chart()\Window\Height = WindowHeight(Chart()\Window\Num)
            
            If Chart()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If Chart()\Size\Flags & #MoveX : X = GadgetX(Chart()\CanvasNum) + OffSetX : EndIf
              If Chart()\Size\Flags & #MoveY : Y = GadgetY(Chart()\CanvasNum) + OffSetY : EndIf
              If Chart()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(Chart()\CanvasNum)  + OffSetX : EndIf
              If Chart()\Size\Flags & #ResizeHeight : Height = GadgetHeight(Chart()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(Chart()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(Chart()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(Chart()\CanvasNum) + OffSetX, GadgetHeight(Chart()\CanvasNum) + OffsetY)
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
  
  CompilerIf #Enable_ScatterPlot
    
    Procedure   AddScatterPlot(GNum.i, Label.s, Color.i=#PB_Default, GradientColor.i=#PB_Default, BorderColor.i=#PB_Default)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
        
        If FindMapElement(Chart()\Index(), Label) ;{ Error: Label already exists
          Chart()\Error = #Error_LabelExists
          ProcedureReturn #False
          ;}
        EndIf

        If AddElement(Chart()\Series())
          
          Chart()\Series()\Label    = Label
          Chart()\Series()\Color    = Color
          Chart()\Series()\Gradient = GradientColor
          Chart()\Series()\Border   = BorderColor
         
          If AddMapElement(Chart()\Index(), Label)
            Chart()\Index() = ListIndex(Chart()\Series())
          EndIf
          
          ProcedureReturn #True
        EndIf  
        
      EndIf 
      
    EndProcedure
    
    Procedure.i AddScatterItem(GNum.i, Scatter.s, Label.s, DataX.q, DataY.q) 
      
      If FindMapElement(Chart(), Str(GNum))
      
        If DataX < Chart()\Minimum Or DataY < Chart()\Minimum ;{ Error: Minimum
          Chart()\Error = #Error_Minimum
          ;}
        EndIf  
      
        If Chart()\Maximum <> #PB_Default And (DataX > Chart()\Maximum Or DataY > Chart()\Maximum) ;{ Error: Maximum
          Chart()\Error = #Error_Maximum
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Scatter)            ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index())  ; Data Series Element
            
            If FindMapElement(Chart()\Series()\Index(), Label) ;{ Error: Label already exists
              Chart()\Error = #Error_LabelExists
              ProcedureReturn #False
              ;}
            EndIf
            
            If AddElement(Chart()\Series()\Item())
          
              Chart()\Series()\Item()\Label = Label
              Chart()\Series()\Item()\DataX = DataX
              Chart()\Series()\Item()\DataY = DataY

              If AddMapElement(Chart()\Series()\Index(), Label)
                Chart()\Series()\Index() = ListIndex(Chart()\Series()\Item())
              EndIf
              
              If Chart()\ReDraw : Draw_() : EndIf
              
              ProcedureReturn #True
            EndIf  
            
          EndIf
        EndIf  

      EndIf
    
    EndProcedure
    
    Procedure.i DisplayScatterPlot(GNum.i, Scatter.s, State.i=#True)

      If FindMapElement(Chart(), Str(GNum))
        
        If FindMapElement(Chart()\Index(), Scatter)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If State
              
              If AddElement(Chart()\VisibleData())
                
                Chart()\VisibleData() = ListIndex(Chart()\Series())
                
                If AddMapElement(Chart()\VisibleIndex(), Scatter)
                  
                  Chart()\VisibleIndex() = ListIndex(Chart()\Series())
                  
                  If Chart()\ReDraw : Draw_() : EndIf
                  
                  ProcedureReturn #True
                EndIf 
              EndIf
              
            Else
              
              If FindMapElement(Chart()\VisibleIndex(), Scatter)
              
                ForEach Chart()\VisibleData()
                  If Chart()\VisibleData() = Chart()\VisibleIndex()
                    DeleteElement(Chart()\VisibleData())
                  EndIf 
                Next
                
                DeleteMapElement(Chart()\VisibleIndex())
                
                If Chart()\ReDraw : Draw_() : EndIf
                
                ProcedureReturn #True
              EndIf
              
            EndIf
            
          EndIf
        EndIf

      EndIf
      
    EndProcedure
    
    Procedure.s EventScatterPlot(GNum.i) 
      
      If FindMapElement(Chart(), Str(GNum))
        ProcedureReturn Chart()\Event\Series
      EndIf
      
    EndProcedure
    
    Procedure.f EventDataX(GNum.i) 
      
      If FindMapElement(Chart(), Str(GNum))
        ProcedureReturn Chart()\Event\DataX
      EndIf
      
    EndProcedure 
    
    Procedure.f EventDataY(GNum.i) 
      
      If FindMapElement(Chart(), Str(GNum))
        ProcedureReturn Chart()\Event\DataY
      EndIf
      
    EndProcedure 
    
    Procedure.i GetScatterColor(GNum.i, Scatter.s)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If FindMapElement(Chart()\Index(), Scatter)
          If SelectElement(Chart()\Series(), Chart()\Index())
            ProcedureReturn Chart()\Series()\Color
          EndIf
        Else
          Chart()\Error = #Error_LabelUnknown
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure.i GetScatterItem(GNum.i, Scatter.s, Position.i, Type.i)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If Position < 0 ;{ Error: List Index
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #NotValid
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Scatter)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If SelectElement(Chart()\Series()\Item(), Position)
              
              Select Type
                Case #DataX
                  ProcedureReturn Chart()\Series()\Item()\DataX
                Case #DataY
                  ProcedureReturn Chart()\Series()\Item()\DataY
              EndSelect
              
            Else
              Chart()\Error = #Error_IndexNotValid
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure.i GetScatterLabelData(GNum.i, Scatter.s, Label.s, Type.i)
     
      If FindMapElement(Chart(), Str(GNum))
       
        If FindMapElement(Chart()\Index(), Scatter)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If FindMapElement(Chart()\Series()\Index(), Label)
              If SelectElement(Chart()\Series()\Item(), Chart()\Series()\Index())
                
                Select Type
                  Case #DataX
                    ProcedureReturn Chart()\Series()\Item()\DataX
                  Case #DataY
                    ProcedureReturn Chart()\Series()\Item()\DataY
                EndSelect
                
              Else
                Chart()\Error = #Error_IndexNotValid
              EndIf
            Else
              Chart()\Error = #Error_LabelUnknown
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    
    Procedure.i RemoveScatterPlot(GNum.i, Scatter.s)
      
      If FindMapElement(Chart(), Str(GNum))

        If FindMapElement(Chart()\Index(), Scatter)           ; ScatterPlot Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; ScatterPlot Element

            DeleteMapElement(Chart()\Index())
            DeleteElement(Chart()\Series())
            
            ForEach Chart()\VisibleData()
              If Chart()\VisibleData() = ListIndex(Chart()\Series())
                DeleteElement(Chart()\VisibleData())
              EndIf 
            Next
            
            DeleteMapElement(Chart()\VisibleIndex(), Scatter)
            
            If Chart()\ReDraw : Draw_() : EndIf
            
            ProcedureReturn #True
          EndIf
        EndIf
  
      EndIf
      
    EndProcedure
    
    Procedure.i RemoveScatterItem(GNum.i, Scatter.s, Position.i)
      
      If FindMapElement(Chart(), Str(GNum))
      
        If Position < 0 ;{ Error: List Index
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #False
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Scatter)           ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; Data Series Element
            
            If SelectElement(Chart()\Series()\Item(), Position)
          
              DeleteMapElement(Chart()\Series()\Index(), Chart()\Series()\Item()\Label)
              DeleteElement(Chart()\Series()\Item())
              
              If Chart()\ReDraw : Draw_() : EndIf
              
              ProcedureReturn #True
            Else
              Chart()\Error = #Error_IndexNotValid
              ProcedureReturn #False
            EndIf

          EndIf
        EndIf
  
      EndIf
      
    EndProcedure
    
    Procedure.i RemoveScatterLabel(GNum.i, Scatter.s, Label.s)
      
      If FindMapElement(Chart(), Str(GNum))

        If FindMapElement(Chart()\Index(), Scatter)            ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; Data Series Element
            
            If FindMapElement(Chart()\Series()\Index(), Label)
              If SelectElement(Chart()\Series()\Item(), Chart()\Series()\Index())
            
                DeleteMapElement(Chart()\Series()\Index())
                DeleteElement(Chart()\Series()\Item())
                
                If Chart()\ReDraw : Draw_() : EndIf
                
                ProcedureReturn #True
              EndIf
            Else
              Chart()\Error = #Error_LabelUnknown
            EndIf
            
          EndIf
        EndIf
  
      EndIf
      
    EndProcedure
    
    
    Procedure   SetScatterItem(GNum.i, Scatter.s, Position.i, DataX.q, DataY.q)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If Position < 0 ;{ Error: List Index
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #NotValid
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Scatter)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If SelectElement(Chart()\Series()\Item(), Position)
              
              Chart()\Series()\Item()\DataX = DataX
              Chart()\Series()\Item()\DataY = DataY
              
              If Chart()\ReDraw : Draw_() : EndIf
              
            Else
              Chart()\Error = #Error_IndexNotValid
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure   SetScatterLabelData(GNum.i, Scatter.s, Label.s, DataX.q, DataY.q)
     
      If FindMapElement(Chart(), Str(GNum))
       
        If FindMapElement(Chart()\Index(), Scatter)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If FindMapElement(Chart()\Series()\Index(), Label)
              If SelectElement(Chart()\Series()\Item(), Chart()\Series()\Index())
                
                Chart()\Series()\Item()\DataX = DataX
                Chart()\Series()\Item()\DataY = DataY
                
                If Chart()\ReDraw : Draw_() : EndIf
                
              Else
                Chart()\Error = #Error_IndexNotValid
              EndIf
            Else
              Chart()\Error = #Error_LabelUnknown
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf  
   
  CompilerIf #Enable_DataSeries
    
    Procedure.i AddDataSeries(GNum.i, Label.s, Color.i=#PB_Default, GradientColor.i=#PB_Default, BorderColor.i=#PB_Default)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
        
        If FindMapElement(Chart()\Index(), Label) ;{ Error: Label already exists
          Chart()\Error = #Error_LabelExists
          ProcedureReturn #False
          ;}
        EndIf
        
        If AddElement(Chart()\Series())
          
          Chart()\Series()\Label    = Label
          Chart()\Series()\Color    = Color
          Chart()\Series()\Gradient = GradientColor
          Chart()\Series()\Border   = BorderColor
         
          If AddMapElement(Chart()\Index(), Label)
            Chart()\Index() = ListIndex(Chart()\Series())
          EndIf
          
          ProcedureReturn #True
        EndIf  
        
      EndIf
      
    EndProcedure
    
    Procedure.i AddSeriesItem(GNum.i, Series.s, Label.s, Value.i) 
      
      If FindMapElement(Chart(), Str(GNum))
      
        If Value < Chart()\Minimum ;{ Error: Minimum
          Chart()\Error = #Error_Minimum
          ;}
        EndIf  
      
        If Chart()\Maximum <> #PB_Default And Value > Chart()\Maximum ;{ Error: Maximum
          Chart()\Error = #Error_Maximum
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Series)            ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; Data Series Element
            
            If FindMapElement(Chart()\Series()\Index(), Label) ;{ Error: Label already exists
              Chart()\Error = #Error_LabelExists
              ProcedureReturn #False
              ;}
            EndIf
            
            If AddElement(Chart()\Series()\Item())
          
              Chart()\Series()\Item()\Label    = Label
              Chart()\Series()\Item()\Value    = Value
    
              If AddMapElement(Chart()\Series()\Index(), Label)
                Chart()\Series()\Index() = ListIndex(Chart()\Series()\Item())
              EndIf
              
              If Chart()\ReDraw : Draw_() : EndIf
              
              ProcedureReturn #True
            EndIf  
            
          EndIf
        EndIf  

      EndIf
    
    EndProcedure
    
    Procedure.i DisplayDataSeries(GNum.i, Series.s, State.i=#True)

      If FindMapElement(Chart(), Str(GNum))
        
        If FindMapElement(Chart()\Index(), Series)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If State
              
              If AddElement(Chart()\VisibleData())
                
                Chart()\VisibleData() = ListIndex(Chart()\Series())
                
                If AddMapElement(Chart()\VisibleIndex(), Series)
                  
                  Chart()\VisibleIndex() = ListIndex(Chart()\Series())
                  
                  If Chart()\ReDraw : Draw_() : EndIf
                  
                  ProcedureReturn #True
                EndIf 
              EndIf
              
            Else
              
              If FindMapElement(Chart()\VisibleIndex(), Series)
              
                ForEach Chart()\VisibleData()
                  If Chart()\VisibleData() = Chart()\VisibleIndex()
                    DeleteElement(Chart()\VisibleData())
                  EndIf 
                Next
                
                DeleteMapElement(Chart()\VisibleIndex())
                
                If Chart()\ReDraw : Draw_() : EndIf
                
                ProcedureReturn #True
              EndIf
              
            EndIf
            
          EndIf
        EndIf

      EndIf
      
    EndProcedure
    
    Procedure.s EventDataSeries(GNum.i) 
      
      If FindMapElement(Chart(), Str(GNum))
        ProcedureReturn Chart()\Event\Series
      EndIf
      
    EndProcedure  
    
    Procedure.i GetSeriesColor(GNum.i, Series.s)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If FindMapElement(Chart()\Index(), Series)
          If SelectElement(Chart()\Series(), Chart()\Index())
            ProcedureReturn Chart()\Series()\Color
          EndIf
        Else
          Chart()\Error = #Error_LabelUnknown
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure.i GetSeriesItemState(GNum.i, Series.s, Position.i)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If Position < 0 ;{ Error: List Index
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #NotValid
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Series)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If SelectElement(Chart()\Series()\Item(), Position)
              ProcedureReturn Chart()\Series()\Item()\Value
            Else
              Chart()\Error = #Error_IndexNotValid
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure.i GetSeriesLabelState(GNum.i, Series.s, Label.s)
     
      If FindMapElement(Chart(), Str(GNum))
       
        If FindMapElement(Chart()\Index(), Series)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If FindMapElement(Chart()\Series()\Index(), Label)
              If SelectElement(Chart()\Series()\Item(), Chart()\Series()\Index())
                ProcedureReturn Chart()\Series()\Item()\Value
              Else
                Chart()\Error = #Error_IndexNotValid
              EndIf
            Else
              Chart()\Error = #Error_LabelUnknown
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    
    Procedure.i RemoveDataSeries(GNum.i, Series.s)
      
      If FindMapElement(Chart(), Str(GNum))

        If FindMapElement(Chart()\Index(), Series)            ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; Data Series Element

            DeleteMapElement(Chart()\Index())
            DeleteElement(Chart()\Series())
            
            ForEach Chart()\VisibleData()
              If Chart()\VisibleData() = ListIndex(Chart()\Series())
                DeleteElement(Chart()\VisibleData())
              EndIf 
            Next
            
            DeleteMapElement(Chart()\VisibleIndex(), Series)
            
            If Chart()\ReDraw : Draw_() : EndIf
            
            ProcedureReturn #True
          EndIf
        EndIf
  
      EndIf
      
    EndProcedure
    
    Procedure.i RemoveSeriesItem(GNum.i, Series.s, Position.i)
      
      If FindMapElement(Chart(), Str(GNum))
      
        If Position < 0 ;{ Error: List Index
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #False
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Series)            ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; Data Series Element
            
            If SelectElement(Chart()\Series()\Item(), Position)
          
              DeleteMapElement(Chart()\Series()\Index(), Chart()\Series()\Item()\Label)
              DeleteElement(Chart()\Series()\Item())
              
              If Chart()\ReDraw : Draw_() : EndIf
              
              ProcedureReturn #True
            Else
              Chart()\Error = #Error_IndexNotValid
              ProcedureReturn #False
            EndIf

          EndIf
        EndIf
  
      EndIf
      
    EndProcedure
    
    Procedure.i RemoveSeriesLabel(GNum.i, Series.s, Label.s)
      
      If FindMapElement(Chart(), Str(GNum))

        If FindMapElement(Chart()\Index(), Series)            ; Data Series Label
          If SelectElement(Chart()\Series(), Chart()\Index()) ; Data Series Element
            
            If FindMapElement(Chart()\Series()\Index(), Label)
              If SelectElement(Chart()\Series()\Item(), Chart()\Series()\Index())
            
                DeleteMapElement(Chart()\Series()\Index())
                DeleteElement(Chart()\Series()\Item())
                
                If Chart()\ReDraw : Draw_() : EndIf
                
                ProcedureReturn #True
              EndIf
            Else
              Chart()\Error = #Error_LabelUnknown
            EndIf
            
          EndIf
        EndIf
  
      EndIf
      
    EndProcedure
    
    
    Procedure   SetSeriesItemState(GNum.i, Series.s, Position.i, Value.i)
      
      If FindMapElement(Chart(), Str(GNum))
        
        If Position < 0 ;{ Error: List Index
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #NotValid
          ;}
        EndIf
        
        If FindMapElement(Chart()\Index(), Series)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If SelectElement(Chart()\Series()\Item(), Position)
              
              Chart()\Series()\Item()\Value = Value
              
              If Chart()\ReDraw : Draw_() : EndIf
              
            Else
              Chart()\Error = #Error_IndexNotValid
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
    Procedure   SetSeriesLabelState(GNum.i, Series.s, Label.s, Value.i)
     
      If FindMapElement(Chart(), Str(GNum))
       
        If FindMapElement(Chart()\Index(), Series)
          If SelectElement(Chart()\Series(), Chart()\Index())
            
            If FindMapElement(Chart()\Series()\Index(), Label)
              If SelectElement(Chart()\Series()\Item(), Chart()\Series()\Index())
                
                Chart()\Series()\Item()\Value = Value
                
                If Chart()\ReDraw : Draw_() : EndIf
                
              Else
                Chart()\Error = #Error_IndexNotValid
              EndIf
            Else
              Chart()\Error = #Error_LabelUnknown
            EndIf
            
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  
  Procedure.i AddAxisLabel(GNum.i, Label.s, Value.f, Type.i=#AxisX) ; enable with flag '#Label'
    Define.i i, Count
    
    If FindMapElement(Chart(), Str(GNum))

      Select Type
        Case #AxisX
          
          If AddElement(Chart()\AxisX\Label())
            Chart()\AxisX\Label()\Text  = Label
            Chart()\AxisX\Label()\Value = Value
            ProcedureReturn ListSize(Chart()\AxisX\Label())
          EndIf
          
        Case #AxisY

          If AddElement(Chart()\AxisY\Label())
            Chart()\AxisY\Label()\Text  = Label
            Chart()\AxisY\Label()\Value = Value
            ProcedureReturn ListSize(Chart()\AxisY\Label())
          EndIf
          
      EndSelect
      
    EndIf  
    
  EndProcedure 
  
  Procedure.i AddItem(GNum.i, Label.s, Value.i, Color.i=#PB_Default, GradientColor.i=#PB_Default, BorderColor.i=#PB_Default)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Color = #PB_Default : Color = Chart()\Color\Bar : EndIf
      
      If Value < Chart()\Minimum ;{ Error: Minimum
        Chart()\Error = #Error_Minimum
        ;}
      EndIf  
      
      If Chart()\Maximum <> #PB_Default And Value > Chart()\Maximum ;{ Error: Maximum
        Chart()\Error = #Error_Maximum
        ;}
      EndIf
      
      If FindMapElement(Chart()\Index(), Label) ;{ Error: Label already exists
        Chart()\Error = #Error_LabelExists
        ProcedureReturn #False
        ;}
      EndIf
      
      If AddElement(Chart()\Item())
        
        Chart()\Item()\Label    = Label
        Chart()\Item()\Value    = Value
        Chart()\Item()\Color    = Color
        Chart()\Item()\Gradient = GradientColor
        Chart()\Item()\Border   = BorderColor
        
        If AddMapElement(Chart()\Index(), Label)
          Chart()\Index() = ListIndex(Chart()\Item())
        EndIf
        
        If Chart()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      EndIf  
     
    EndIf
    
  EndProcedure
  
  
  Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)
    
    If FindMapElement(Chart(), Str(GNum))
      Chart()\PopupNum = PopUpNum
    EndIf
    
  EndProcedure
  
  Procedure   DisableReDraw(GNum.i, State.i=#False)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If State
        Chart()\ReDraw = #False
      Else
        Chart()\ReDraw = #True
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  
  Procedure.i EventColor(GNum.i)
    
    If FindMapElement(Chart(), Str(GNum))
      ProcedureReturn Chart()\Event\Color
    EndIf 
    
  EndProcedure
  
  Procedure.i EventIndex(GNum.i)
    
    If FindMapElement(Chart(), Str(GNum))
      ProcedureReturn Chart()\Event\Index
    EndIf 
    
  EndProcedure
  
  Procedure.s EventLabel(GNum.i)
    
    If FindMapElement(Chart(), Str(GNum))
      ProcedureReturn Chart()\Event\Label
    EndIf
    
  EndProcedure
  
  Procedure.i EventValue(GNum.i)
    
    If FindMapElement(Chart(), Str(GNum))
      ProcedureReturn Chart()\Event\Value
    EndIf 
    
  EndProcedure
  
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define txtNum, Result.i
    
    Result = CanvasGadget(GNum, X, Y, Width, Height)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(Chart(), Str(GNum))
        
        Chart()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default
            Chart()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            Chart()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            Chart()\Window\Num = GetActiveWindow()
          Else
            Chart()\Window\Num = WindowNum
          EndIf
        CompilerEndIf   
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            Chart()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              Chart()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            Chart()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        Chart()\Legend\FontID  = Chart()\FontID 
        Chart()\Pie\FontID     = Chart()\FontID
        Chart()\Bar\FontID     = Chart()\FontID
        Chart()\Line\FontID    = Chart()\FontID
        Chart()\Scatter\FontID = Chart()\FontID
        
        Chart()\Size\X = X
        Chart()\Size\Y = Y
        Chart()\Size\Width  = Width
        Chart()\Size\Height = Height
        
        Chart()\Margin\Left   = 10
        Chart()\Margin\Right  = 10
        Chart()\Margin\Top    = 10
        Chart()\Margin\Bottom = 10
        
        Chart()\Minimum  = 0
        Chart()\Maximum  = #PB_Default
        Chart()\Decimals = 0
        
        Chart()\Bar\ScaleSpacing  = #Single
        Chart()\Bar\ScaleLines    = #PB_Default
        Chart()\Bar\Width         = #PB_Default
        Chart()\Bar\Padding       = 5
        Chart()\Bar\Spacing       = #PB_Default
        
        Chart()\Pie\Spacing       = #PB_Default
        Chart()\Pie\FontSize      = #PB_Default
 
        Chart()\Line\ScaleSpacing = #Single
        Chart()\Line\ScaleLines   = #PB_Default
        Chart()\Line\Width        = #PB_Default
        Chart()\Line\Spacing      = #PB_Default
        Chart()\Line\Padding      = 20
        Chart()\Line\Color        = $9F723E
        Chart()\Line\FontSize     = #PB_Default
        
        Chart()\Scatter\ScaleSpacingX = #Single
        Chart()\Scatter\ScaleSpacingY = #Single
        Chart()\Scatter\ScaleLinesX   = #PB_Default
        Chart()\Scatter\ScaleLinesY   = #PB_Default
        Chart()\Scatter\Width         = #PB_Default
        Chart()\Scatter\Color         = $9F723E
        Chart()\Scatter\FontSize      = #PB_Default
        Chart()\Scatter\MaximumX      = #PB_Default
        Chart()\Scatter\MaximumY      = #PB_Default
        
        Chart()\AxisX\DateMask = "%hh:%ii"
        Chart()\AxisY\DateMask = "%hh:%ii"
        
        Chart()\ToolTipText = #Value$
        Chart()\Flags       = Flags

        Chart()\ReDraw = #True
        
        Chart()\Color\Front     = $000000
        Chart()\Color\Back      = $EDEDED
        Chart()\Color\Border    = $A0A0A0
        Chart()\Color\Axis      = $000000
        Chart()\Color\Bar       = $B48246
        Chart()\Color\BarBorder = $856033
        Chart()\Color\Gradient  = $C29764
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            Chart()\Color\Front         = GetSysColor_(#COLOR_WINDOWTEXT)
            Chart()\Color\Back          = GetSysColor_(#COLOR_MENU)
            Chart()\Color\Border        = GetSysColor_(#COLOR_WINDOWFRAME)
          CompilerCase #PB_OS_MacOS
            Chart()\Color\Front         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            Chart()\Color\Back          = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            Chart()\Color\Border        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;}        

        BindGadgetEvent(Chart()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
        BindGadgetEvent(Chart()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
        ;BindGadgetEvent(Chart()\CanvasNum,  @_LeftClickHandler(),       #PB_EventType_LeftClick)
        BindGadgetEvent(Chart()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(Chart()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        
        CompilerIf #Enable_ModifyByCursor
          BindGadgetEvent(Chart()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
          BindGadgetEvent(Chart()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        CompilerEndIf
        
        If Flags & #AutoResize
          If IsWindow(Chart()\Window\Num)
            Chart()\Window\Width  = WindowWidth(Chart()\Window\Num)
            Chart()\Window\Height = WindowHeight(Chart()\Window\Num)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Chart()\Window\Num)
          EndIf  
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure
  
  
  Procedure.s GetErrorMessage(GNum.i, Language.s="")
    
    If FindMapElement(Chart(), Str(GNum))
      
      Select Left(UCase(Language), 2)
        Case "DE" ;{ German
          Select Chart()\Error
            Case #Error_LabelExists
              ProcedureReturn "Label existiert bereits."
            Case #Error_Minimum
              ProcedureReturn "Wert kleiner als Minimum."
            Case #Error_Maximum
              ProcedureReturn "Wert größer als Maximum."  
            Case #Error_LabelUnknown
              ProcedureReturn "Label unbekannt." 
            Case #Error_IndexNotValid
              ProcedureReturn "Index ungültig." 
          EndSelect
          ;}
        Case "FR" ;{ France
          Select Chart()\Error
            Case #Error_LabelExists
              ProcedureReturn "L'étiquette existe déjà."
            Case #Error_Minimum
              ProcedureReturn "Valeur inférieure à la valeur minimale"
            Case #Error_Maximum
              ProcedureReturn "Valeur supérieure au maximum." 
            Case #Error_LabelUnknown
              ProcedureReturn "." 
            Case #Error_IndexNotValid
              ProcedureReturn "."   
          EndSelect
          ;}
        Case "ES" ;{ Spanish
          Select Chart()\Error
            Case #Error_LabelExists
              ProcedureReturn "La etiqueta ya existe."
            Case #Error_Minimum
              ProcedureReturn "Valor inferior al mínimo."
            Case #Error_Maximum
              ProcedureReturn "Valor superior al máximo" 
            Case #Error_LabelUnknown
              ProcedureReturn "." 
            Case #Error_IndexNotValid
              ProcedureReturn "."   
          EndSelect ;} 
        Default   ;{ English
          Select Chart()\Error
            Case #Error_LabelExists
              ProcedureReturn "Label already exists."
            Case #Error_Minimum
              ProcedureReturn "Value less than minimum"
            Case #Error_Maximum
              ProcedureReturn "Value greater than maximum"
            Case #Error_LabelUnknown
              ProcedureReturn "." 
            Case #Error_IndexNotValid
              ProcedureReturn "."   
          EndSelect
          ;}
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetItemColor(GNum.i, Position.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #NotValid
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        ProcedureReturn Chart()\Item()\Color
      Else
        Chart()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.s GetItemLabel(GNum.i, Position.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn ""
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        ProcedureReturn Chart()\Item()\Label
      Else
        Chart()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf

  EndProcedure
  
  Procedure.i GetItemState(GNum.i, Position.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #NotValid
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        ProcedureReturn Chart()\Item()\Value
      Else
        Chart()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.s GetItemText(GNum.i, Position.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn ""
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        ProcedureReturn Chart()\Item()\Text
      Else
        Chart()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf

  EndProcedure
  
  Procedure.i GetLabelColor(GNum.i, Label.s)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If FindMapElement(Chart()\Index(), Label)
        If SelectElement(Chart()\Item(), Chart()\Index())
          ProcedureReturn Chart()\Item()\Color
        Else
          Chart()\Error = #Error_IndexNotValid
        EndIf
      Else
        Chart()\Error = #Error_LabelUnknown
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.i GetLabelState(GNum.i, Label.s)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If FindMapElement(Chart()\Index(), Label)
        If SelectElement(Chart()\Item(), Chart()\Index())
          ProcedureReturn Chart()\Item()\Value
        Else
          Chart()\Error = #Error_IndexNotValid
        EndIf
      Else
        Chart()\Error = #Error_LabelUnknown
      EndIf
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  
  Procedure.i RemoveItem(GNum.i, Position.i)
    
    If FindMapElement(Chart(), Str(GNum))

      If Position < 0            ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #False
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        
        DeleteMapElement(Chart()\Index(), Chart()\Item()\Label)
        DeleteElement(Chart()\Item())
        
        If Chart()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      Else
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #False
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure   RemoveLabel(GNum.i, Label.s)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If FindMapElement(Chart()\Index(), Label)
        
        If SelectElement(Chart()\Item(), Chart()\Index())
          DeleteElement(Chart()\Item())
          DeleteMapElement(Chart()\Index())
        EndIf
        
      Else
        Chart()\Error = #Error_LabelUnknown  
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      Select Attribute
        Case #Minimum        ;{ minimum value (Y-axis)
          If Chart()\Flags & #ScatterPlot
            Chart()\Scatter\MinimumY = Value
          Else
            Chart()\Minimum = Value
          EndIf 
          ;}
        Case #Maximum        ;{ maximum value (Y-axis)
          If Chart()\Flags & #ScatterPlot
            Chart()\Scatter\MaximumY = Value
          Else
            Chart()\Maximum = Value 
          EndIf
          ;}
        Case #MinimumX       ;{ minimum value (X-axis)
          If Chart()\Flags & #ScatterPlot
            Chart()\Scatter\MinimumX = Value
          Else
            Chart()\Minimum = Value
          EndIf
          ;}
        Case #MaximumX       ;{ maximum value (X-axis)
          If Chart()\Flags & #ScatterPlot
            Chart()\Scatter\MaximumX = Value
          Else
            Chart()\Maximum = Value 
          EndIf ;}
        Case #Width          ;{ width of bars (X-axis)
          If Chart()\Flags & #LineChart
            Chart()\Line\Width  = dpiX(Value)
          Else
            Chart()\Bar\Width = dpiX(Value)
          EndIf
          ;}
        Case #Spacing        ;{ width of spacing (X-axis)
          If Chart()\Flags & #PieChart
            Chart()\Pie\Spacing  = dpiX(Value)
          ElseIf Chart()\Flags & #LineChart
            Chart()\Line\Spacing = dpiX(Value)
          Else
            Chart()\Bar\Spacing  = dpiX(Value)
          EndIf 
          ;}
        Case #LineColor      ;{ Color for line chart
          Chart()\Line\Color = Value
          ;}
        Case #Padding        ;{ padding between data series bars
          If Chart()\Flags & #LineChart
            Chart()\Line\Padding = Value
          Else
            Chart()\Bar\Padding = Value
          EndIf
          ;}
        Case #ScaleLines     ;{ Number of scale lines (Y-axis)
          If Chart()\Flags & #LineChart
            Chart()\Line\ScaleLines = Value
          ElseIf Chart()\Flags & #ScatterPlot
            Chart()\Scatter\ScaleLinesY = Value
          Else
            Chart()\Bar\ScaleLines = Value
          EndIf
          ;}
        Case #ScaleLinesX    ;{ Number of scale lines (X-axis)
          Chart()\Scatter\ScaleLinesX = Value
          ;}
        Case #ScaleSpacing   ;{ Spacing of scale lines [#Single/#Double]
          If Chart()\Flags & #LineChart
            If Value > 0 : Chart()\Line\ScaleSpacing = Value : EndIf
          ElseIf Chart()\Flags & #ScatterPlot
            If Value > 0 : Chart()\Scatter\ScaleSpacingY = Value : EndIf
          Else
            If Value > 0 : Chart()\Bar\ScaleSpacing  = Value : EndIf
          EndIf
          ;}
        Case #ScaleSpacingX  ;{ Spacing of scale lines [#Single/#Double]
          If Value > 0 : Chart()\Scatter\ScaleSpacingX = Value : EndIf
          ;}
        Case #FontSize       ;{ Font size for vector text
          If Chart()\Flags & #LineChart
            Chart()\Line\FontSize = Value
          ElseIf  Chart()\Flags & #PieChart
            Chart()\Pie\FontSize = Value
          EndIf 
          ;}
        Case #Decimals       ;{ Decimal places for scatter plot data
          Chart()\Decimals = Value
          ;}
      EndSelect
      
      If Chart()\ReDraw : Draw_() : EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      Chart()\Size\Flags = Flags
      Chart()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          Chart()\Color\Front     = Color
        Case #BackColor
          Chart()\Color\Back      = Color
        Case #AxisColor
          Chart()\Color\Axis      = Color   
        Case #BarColor
          Chart()\Color\Bar       = Color
        Case #BarBorderColor
          Chart()\Color\BarBorder = Color
        Case #GradientColor
          Chart()\Color\Gradient  = Color
        Case #BorderColor
          Chart()\Color\Border    = Color
      EndSelect
      
      If Chart()\ReDraw : Draw_() : EndIf
      
    EndIf 
    
  EndProcedure
  
  Procedure   SetFlags(GNum.i, Type.i, Flags.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      Select Type
        Case #BarChart
          Chart()\Bar\Flags | Flags
        Case #PieChart
          Chart()\Pie\Flags | Flags
        Case #LineChart
          Chart()\Line\Flags | Flags
        Case #ScatterPlot
          Chart()\Scatter\Flags | Flags
        Case #Legend
          Chart()\Legend\Flags | Flags
        Case #AxisX
          Chart()\AxisX\Flags | Flags
        Case #AxisY
          Chart()\AxisY\Flags | Flags
      EndSelect
      
      If Chart()\ReDraw : Draw_() : EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontID.i, Flags.i=#False) 
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Flags & #Legend          ;{ Text in the legend
        Chart()\Legend\FontID = FontID
        ;}
      ElseIf Flags & #PieChart    ;{ Text in circle sectors
        Chart()\Pie\FontID = FontID
        ;}
      ElseIf Flags & #BarChart    ;{ Text in bars
        Chart()\Bar\FontID = FontID
        ;}
      ElseIf Flags & #LineChart   ;{ Text over data points
        Chart()\Line\FontID = FontID
        ;}
      ElseIf Flags & #ScatterPlot ;{ Text over data points
        Chart()\Scatter\FontID = FontID
        ;}
      Else
        Chart()\FontID = FontID
      EndIf
      
      If Chart()\ReDraw : Draw_() : EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure.i SetItemState(GNum.i, Position.i, State.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If State < Chart()\Minimum ;{ Error: Minimum
        Chart()\Error = #Error_Minimum
        ;}
      EndIf  
      
      If Chart()\Maximum <> #PB_Default And State > Chart()\Maximum ;{ Error: Maximum
        Chart()\Error = #Error_Maximum
        ;}
      EndIf
      
      If Position < 0            ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #False
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        
        Chart()\Item()\Value = State
        If Chart()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      Else
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #False
      EndIf

    EndIf  
    
  EndProcedure  
  
  Procedure.i SetItemText(GNum.i, Position.i, Text.s)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If Position < 0 ;{ Error: List Index
        Chart()\Error = #Error_IndexNotValid
        ProcedureReturn #False
        ;}
      EndIf
      
      If SelectElement(Chart()\Item(), Position)
        
        Chart()\Item()\Text = Text
        
        If Chart()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      Else
        Chart()\Error = #Error_IndexNotValid
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetLabelState(GNum.i, Label.s, State.i)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If State < Chart()\Minimum ;{ Error: Minimum
        Chart()\Error = #Error_Minimum
        ;}
      EndIf  
      
      If Chart()\Maximum <> #PB_Default And State > Chart()\Maximum ;{ Error: Maximum
        Chart()\Error = #Error_Maximum
        ;}
      EndIf
      
      If FindMapElement(Chart()\Index(), Label)
        If SelectElement(Chart()\Item(), Chart()\Index())
          
          Chart()\Item()\Value = State
          
          If Chart()\ReDraw : Draw_() : EndIf
          
          ProcedureReturn #True
        Else
          Chart()\Error = #Error_IndexNotValid
          ProcedureReturn #False
        EndIf
      Else
        Chart()\Error = #Error_LabelUnknown
        ProcedureReturn #False
      EndIf
 
    EndIf  
    
  EndProcedure  
  
  Procedure   SetMargins(GNum.i, Top.i, Left.i, Right.i=#PB_Default, Bottom.i=#PB_Default)
    
    If FindMapElement(Chart(), Str(GNum))
      
      Chart()\Margin\Top    = dpiY(Top)
      Chart()\Margin\Left   = dpiX(Left)
      If Right = #PB_Default
        Chart()\Margin\Right = Chart()\Margin\Left
      Else  
        Chart()\Margin\Right = dpiX(Right)
      EndIf  
      If Bottom = #PB_Default
        Chart()\Margin\Bottom = Chart()\Margin\Top
      Else
        Chart()\Margin\Bottom = dpiY(Bottom)
      EndIf
      
    EndIf 
    
  EndProcedure
  
  Procedure   SetMask(GNum.i, Type.i, String.s)
    
    If FindMapElement(Chart(), Str(GNum))
      
      Select Type
        Case #AxisX
          Chart()\AxisX\DateMask = String
        Case #AxisY
          Chart()\AxisY\DateMask = String
      EndSelect
      
    EndIf
    
  EndProcedure
  
  
  Procedure   ToolTipText(GNum.i, Text.s) ; #Value$ / Percent$ / #Label$ / #Series$
    
    If FindMapElement(Chart(), Str(GNum))
      
      Chart()\ToolTipText = Text
      
    EndIf  
    
  EndProcedure  
    
  Procedure   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
    
    If FindMapElement(Chart(), Str(GNum))
      
      If AddMapElement(Chart()\PopUpItem(), Str(MenuItem))
        Chart()\PopUpItem() = Text
      EndIf 
      
    EndIf
    
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  ; ----- Select Example -----
  
  #Example = 17
  
  ; --- Bar Chart ---
  ;  1: automatically adjust maximum value (#PB_Default)
  ;  2: display horizontal lines
  ;  3: use colored labels
  ;  4: minimum value = 20
  ;  5: show value in bars
  ;  6: show percentage value in bars
  ;  7: negative minimum
  ; --- Pie Chart ---
  ;  8: colored values in legend / no borders
  ;  9: show percent
  ; --- Data Series ---
  ; 10: chart with data series
  ; --- Horizontal Bars ---
  ; 11: chart with horizontal bars
  ; --- Line Charts ---
  ; 12: positive values
  ; 13: bezier curves
  ; 14: negative & positive values
  ; 15: data series
  ; 16: 
  ; --- Scatter Plot ---
  ; 17: popup menu
  ; 18: time axis
  ; --------------------------
  
  Enumeration 
    #Window
    #Chart
    #Label
    #Value
    #Button
    #PopUp
    #Menu_Hide
    #Menu_Display
    #Font
    #FontB
  EndEnumeration
  
  LoadFont(#Font,  "Arial", 8)
  LoadFont(#FontB, "Arial", 10, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 315, 230, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopUp)
      MenuItem(#Menu_Display, "Display data series")
      MenuBar()
      MenuItem(#Menu_Hide, "Hide data series")
    EndIf 
    
    CompilerSelect #Example
      CompilerCase 1  ; automatically adjust maximum value (#PB_Default)
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#AutoResize, #Window)
      CompilerCase 2 ; display horizontal lines
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#ShowLines|Chart::#AutoResize, #Window)
        Chart::SetAttribute(#Chart, Chart::#ScaleLines, 5)
        Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
      CompilerCase 3 ; use colored labels
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#Colored)
        Chart::SetAttribute(#Chart, Chart::#ScaleLines, 5)
        Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
      CompilerCase 4 ; minimum value = 20
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#NoAutoAdjust) ; Don't adjust maximum/minimum value!
        Chart::SetAttribute(#Chart, Chart::#Minimum, 20)
        Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
      CompilerCase 5 ; show value in bar
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#ShowValue|Chart::#AutoResize, #Window)
        Chart::SetAttribute(#Chart, Chart::#ScaleLines, 5)
        Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
      CompilerCase 6 ; show percentage value in bar
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#ShowPercent|Chart::#AutoResize, #Window)
        Chart::SetAttribute(#Chart, Chart::#ScaleLines, 5)
        Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
      CompilerCase 7 ; negative minimum
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#ShowLines|Chart::#ShowValue|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#Colored)
        Chart::SetAttribute(#Chart, Chart::#ScaleSpacing, Chart::#Double) ; Chart::#Single / Chart::#Double
        Chart::SetAttribute(#Chart, Chart::#Minimum, -100)
        Chart::SetAttribute(#Chart, Chart::#Maximum,  100)
      CompilerCase 8 ; Pie Chart: colored values in legend / no borders
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#PieChart|Chart::#Border|Chart::#ShowPercent|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#PieChart, Chart::#NoBorder|Chart::#ShowValue)
        Chart::SetFlags(#Chart, Chart::#Legend, Chart::#Colored|Chart::#PostEvents) ; |Chart::#Hide
        Chart::SetAttribute(#Chart, Chart::#Spacing, 12)                            ; Spacing between chart and legend
        Chart::SetFont(#Chart, FontID(#FontB), Chart::#PieChart)
        ;Chart::SetAttribute(#Chart, Chart::#FontSize, 16)
      CompilerCase 9 ; Pie Chart: show percent
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#PieChart|Chart::#Border|Chart::#ShowValue|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#PieChart, Chart::#ShowPercent)
        Chart::SetFlags(#Chart, Chart::#Legend, Chart::#Colored|Chart::#PostEvents) ; |Chart::#Hide
        Chart::SetAttribute(#Chart, Chart::#Spacing, 15)                            ; Spacing between chart and legend
        Chart::SetAttribute(#Chart, Chart::#FontSize, 14)
        ;Chart::SetMargins(#Chart, 15, 15)
      CompilerCase 10 ; Chart with data series
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#DataSeries|Chart::#Border|Chart::#ShowValue|Chart::#ShowLines|Chart::#AutoResize, #Window)
        ;Chart::SetAttribute(#Chart, Chart::#ScaleSpacing, Chart::#Double) ; Chart::#Single / Chart::#Double
        Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
        Chart::SetFlags(#Chart, Chart::#Legend, Chart::#AllDataSeries|Chart::#PostEvents|Chart::#PopUpMenu) ; |Chart::#Hide
        Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#PopUpMenu)
        Chart::SetFont(#Chart, FontID(#Font), Chart::#BarChart)
        Chart::SetFont(#Chart, FontID(#Font), Chart::#Legend)
        ;Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
        ;Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#NoAutoAdjust|Chart::#OutOfRange)
        ; Popup Menu
        Chart::AttachPopupMenu(#Chart, #PopUp)
        Chart::UpdatePopupText(#Chart, #Menu_Display, "Display '"+Chart::#Serie$+"'")
        Chart::UpdatePopupText(#Chart, #Menu_Hide,    "Hide '"+Chart::#Serie$+"'")
      CompilerCase 11 ; Chart with horizontal bars
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Horizontal|Chart::#Border|Chart::#ShowValue|Chart::#ShowLines|Chart::#AutoResize, #Window)
        Chart::SetAttribute(#Chart, Chart::#Width, 22)
        Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#Colored)
        ;Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
        ;Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#NoAutoAdjust|Chart::#OutOfRange)
      CompilerCase 12 ; Line Chart
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#LineChart|Chart::#Border|Chart::#ShowLines|Chart::#ShowValue|Chart::#ChangeCursor|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#Colored) ; |Chart::#Descending
        ;Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#NoAutoAdjust)
        ;Chart::SetAttribute(#Chart, Chart::#LineColor, $AACD66)
        Chart::SetAttribute(#Chart, Chart::#FontSize, 9)
        Chart::SetFont(#Chart, FontID(#Font), Chart::#LineChart)
        Chart::SetMargins(#Chart, 15, 15)
      CompilerCase 13 ; Line Chart (#BezierCurve)
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#LineChart|Chart::#Border|Chart::#ShowLines|Chart::#ShowValue|Chart::#ChangeCursor|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#Colored|Chart::#BezierCurve) ; |Chart::#Descending|Chart::#NoAutoAdjust
        Chart::SetAttribute(#Chart, Chart::#Maximum,  80)
        Chart::SetAttribute(#Chart, Chart::#FontSize, 10)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#NoAutoAdjust|Chart::#OutOfRange)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#ModifyByCursor)
      CompilerCase 14 ; Line Chart (negative values)
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#LineChart|Chart::#Border|Chart::#ShowLines|Chart::#ChangeCursor|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#Colored|Chart::#BezierCurve)
        Chart::SetAttribute(#Chart, Chart::#Minimum, -50)
        Chart::SetAttribute(#Chart, Chart::#Maximum, 50)
      CompilerCase 15 ; Line Chart (data series)
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#LineChart|Chart::#DataSeries|Chart::#ShowLines|Chart::#Border|Chart::#ChangeCursor|Chart::#ToolTips|Chart::#AutoResize, #Window) ; |Chart::#ShowValue
        Chart::SetFlags(#Chart, Chart::#Legend, Chart::#AllDataSeries|Chart::#PostEvents|Chart::#PopUpMenu)  ; |Chart::#Hide
        Chart::SetFont(#Chart, FontID(#Font), Chart::#Legend)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#BezierCurve) ; |Chart::#Descending|Chart::#NoAutoAdjust
        Chart::SetAttribute(#Chart, Chart::#Maximum, 70)
        Chart::SetAttribute(#Chart, Chart::#FontSize, 9)
        Chart::SetFlags(#Chart, Chart::#LineChart, Chart::#NoAutoAdjust|Chart::#OutOfRange)
        ; --- Tooltips ---
        Chart::ToolTipText(#Chart, "Value: " + Chart::#Value$)
        ; Popup Menu
        Chart::AttachPopupMenu(#Chart, #PopUp)
        Chart::UpdatePopupText(#Chart, #Menu_Display, "Display '" + Chart::#Serie$ + "'")
        Chart::UpdatePopupText(#Chart, #Menu_Hide,    "Hide '"    + Chart::#Serie$ + "'")
      CompilerCase 17  
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#ScatterPlot|Chart::#Border|Chart::#ToolTips|Chart::#AutoResize, #Window) ; |Chart::#ShowLines|Chart::#ShowValue
        Chart::SetFlags(#Chart, Chart::#Legend, Chart::#PostEvents|Chart::#PopUpMenu)
        Chart::SetAttribute(#Chart, Chart::#MaximumY, 80)
        Chart::SetAttribute(#Chart, Chart::#MaximumX, 80)
        ;Chart::SetAttribute(#Chart, Chart::#Decimals, 1)
        Chart::ToolTipText(#Chart, Chart::#Scatter$ + ": " + Chart::#Value$)
        ; Popup Menu
        Chart::AttachPopupMenu(#Chart, #PopUp)
        Chart::UpdatePopupText(#Chart, #Menu_Display, "Display '" + Chart::#Serie$ + "'")
        Chart::UpdatePopupText(#Chart, #Menu_Hide,    "Hide '"    + Chart::#Serie$ + "'")
        ;Chart::SetFont(#Chart, FontID(#Font), Chart::#ScatterPlot)
      CompilerCase 18  
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#ScatterPlot|Chart::#Border|Chart::#ShowLines|Chart::#ToolTips|Chart::#AutoResize, #Window) ; |Chart::#ShowLines|Chart::#ShowValue
        Chart::SetFlags(#Chart, Chart::#Legend, Chart::#PostEvents|Chart::#PopUpMenu)
        Chart::SetAttribute(#Chart, Chart::#MaximumY, 80)
        Chart::SetAttribute(#Chart, Chart::#MinimumX, Date(2019, 1, 1, 8, 0, 0))
        Chart::SetAttribute(#Chart, Chart::#MaximumX, Date(2019, 1, 1, 13, 0, 0))
       
        Chart::AddAxisLabel(#Chart,  "8:00", Date(2019, 1, 1,  8, 0, 0))
        Chart::AddAxisLabel(#Chart,  "9:00", Date(2019, 1, 1,  9, 0, 0))
        Chart::AddAxisLabel(#Chart, "10:00", Date(2019, 1, 1, 10, 0, 0))
        Chart::AddAxisLabel(#Chart, "11:00", Date(2019, 1, 1, 11, 0, 0))
        Chart::AddAxisLabel(#Chart, "12:00", Date(2019, 1, 1, 12, 0, 0))
        Chart::AddAxisLabel(#Chart, "13:00", Date(2019, 1, 1, 13, 0, 0))
        Chart::SetFlags(#Chart, Chart::#AxisX, Chart::#Time|Chart::#Labels)
        
        Chart::ToolTipText(#Chart, Chart::#Scatter$ + ": " + Chart::#Time$ + " - " + Chart::#DataY$) 
      CompilerDefault
        Chart::Gadget(#Chart, 10, 10, 295, 180, Chart::#Border|Chart::#ShowLines|Chart::#ShowValue|Chart::#ChangeCursor|Chart::#AutoResize, #Window)
        Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#Colored)
        Chart::SetAttribute(#Chart, Chart::#ScaleSpacing, Chart::#Double) ; Chart::#Single / Chart::#Double
        ;Chart::SetAttribute(#Chart, Chart::#Maximum, 100)
        ;Chart::SetFlags(#Chart, Chart::#BarChart, Chart::#NoAutoAdjust|Chart::#OutOfRange)
        ; --- Tooltips ---
        Chart::ToolTipText(#Chart, "Percent: " + Chart::#Percent$)
    CompilerEndSelect    
    
    Chart::SetAutoResizeFlags(#Chart, Chart::#ResizeWidth)
    
    CompilerSelect #Example
      CompilerCase 7   
        Chart::AddItem(#Chart, "Data 1", -35, $FF901E)
        Chart::AddItem(#Chart, "Data 2", 50, $0000FF)
        Chart::AddItem(#Chart, "Data 3", -10, $32CD32)
        Chart::AddItem(#Chart, "Data 4", 80, $00D7FF)
      CompilerCase 14
        Chart::AddItem(#Chart, "Data 1", -30, $FF901E)
        Chart::AddItem(#Chart, "Data 2", 20,  $0000FF)
        Chart::AddItem(#Chart, "Data 3", -20, $32CD32)
        Chart::AddItem(#Chart, "Data 4", 45,  $00D7FF)
      CompilerCase 10
        
        CompilerIf Chart::#Enable_DataSeries
          
          If Chart::AddDataSeries(#Chart, "Series 1", $FF901E)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 1", 35)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 2", 70)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 3", 50)
          EndIf
          
          Chart::DisplayDataSeries(#Chart, "Series 1")
          
          If Chart::AddDataSeries(#Chart, "Series 2", $0000FF)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 1", 60)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 2", 45)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 3", 80)
          EndIf
          
          Chart::DisplayDataSeries(#Chart, "Series 2")
          
          If Chart::AddDataSeries(#Chart, "Series 3", $00D7FF)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 1", 10)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 2", 25)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 3", 40)
          EndIf
          
          Chart::DisplayDataSeries(#Chart, "Series 3")
          
        CompilerEndIf
        
      CompilerCase 15
        
        CompilerIf Chart::#Enable_DataSeries
          
          If Chart::AddDataSeries(#Chart, "Series 1", $FF901E)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 1", 35)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 2", 70)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 3", 30)
            Chart::AddSeriesItem(#Chart, "Series 1", "Data 4", 50)
          EndIf
          
          Chart::DisplayDataSeries(#Chart, "Series 1")
          
          If Chart::AddDataSeries(#Chart, "Series 2", $0000FF)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 1", 60)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 2", 45)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 3", 70)
            Chart::AddSeriesItem(#Chart, "Series 2", "Data 4", 60)
          EndIf
          
          Chart::DisplayDataSeries(#Chart, "Series 2")
          
          If Chart::AddDataSeries(#Chart, "Series 3", $00D7FF)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 1", 15)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 2", 35)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 3", 10)
            Chart::AddSeriesItem(#Chart, "Series 3", "Data 4", 40)
          EndIf
          
          Chart::DisplayDataSeries(#Chart, "Series 3")
          
        CompilerEndIf
        
      CompilerCase 16
     
        If Chart::AddScatterPlot(#Chart, "Scatter 1", $FF901E)
          Chart::AddScatterItem(#Chart, "Scatter 1", "Data 1", 20, 45)
          Chart::AddScatterItem(#Chart, "Scatter 1", "Data 2", 30, 50)
          Chart::AddScatterItem(#Chart, "Scatter 1", "Data 3", 55, 60)
        EndIf
        Chart::DisplayScatterPlot(#Chart, "Scatter 1", #True)
        
        If Chart::AddScatterPlot(#Chart, "Scatter 2", $0000FF)
          Chart::AddScatterItem(#Chart, "Scatter 2", "Data 1", 60, 50)
          Chart::AddScatterItem(#Chart, "Scatter 2", "Data 2", 45, 35)
          Chart::AddScatterItem(#Chart, "Scatter 2", "Data 3", 25, 30)
        EndIf
        Chart::DisplayScatterPlot(#Chart, "Scatter 2", #True)
        
        If Chart::AddScatterPlot(#Chart, "Scatter 3", $00D7FF)
          Chart::AddScatterItem(#Chart, "Scatter 3", "Data 1", 25, 60)
          Chart::AddScatterItem(#Chart, "Scatter 3", "Data 2", 35, 45)
          Chart::AddScatterItem(#Chart, "Scatter 3", "Data 3", 55, 30)
        EndIf
        Chart::DisplayScatterPlot(#Chart, "Scatter 3", #True)
        
      CompilerCase 17
        
        If Chart::AddScatterPlot(#Chart, "Scatter 1", $FF901E)
          Chart::AddScatterItem(#Chart, "Scatter 1", "08:30",  Date(2019, 1, 1,  8, 30, 0), 45)
          Chart::AddScatterItem(#Chart, "Scatter 1", "10:30",  Date(2019, 1, 1,  10, 30, 0), 50)
          Chart::AddScatterItem(#Chart, "Scatter 1", "12::30", Date(2019, 1, 1,  12, 30, 0), 60)
        EndIf
        Chart::DisplayScatterPlot(#Chart, "Scatter 1", #True)
        
        If Chart::AddScatterPlot(#Chart, "Scatter 2", $0000FF)
          Chart::AddScatterItem(#Chart, "Scatter 2", "09:00", Date(2019, 1, 1,   9, 0, 0), 50)
          Chart::AddScatterItem(#Chart, "Scatter 2", "11:00", Date(2019, 1, 1,  11, 0, 0), 35)
          Chart::AddScatterItem(#Chart, "Scatter 2", "13:00", Date(2019, 1, 1,  13, 0, 0), 30)
        EndIf
        Chart::DisplayScatterPlot(#Chart, "Scatter 2", #True)
        
        If Chart::AddScatterPlot(#Chart, "Scatter 3", $00D7FF)
          Chart::AddScatterItem(#Chart, "Scatter 3", "10:00", Date(2019, 1, 1, 10, 0, 0), 60)
          Chart::AddScatterItem(#Chart, "Scatter 3", "11:00", Date(2019, 1, 1, 11, 0, 0), 45)
          Chart::AddScatterItem(#Chart, "Scatter 3", "12:00", Date(2019, 1, 1, 12, 0, 0), 30)
        EndIf
        Chart::DisplayScatterPlot(#Chart, "Scatter 3", #True)
        
      CompilerDefault 
        
        Chart::AddItem(#Chart, "Data 1", 35, $FF901E)
        Chart::AddItem(#Chart, "Data 2", 50, $0000FF)
        Chart::AddItem(#Chart, "Data 3", 10, $32CD32)
        Chart::AddItem(#Chart, "Data 4", 80, $00D7FF)

        ;Chart::SetItemText(#Chart, 0, "A")
        ;Chart::SetItemText(#Chart, 1, "B")
        ;Chart::SetItemText(#Chart, 2, "C")
        ;Chart::SetItemText(#Chart, 3, "D")
        
    CompilerEndSelect

    StringGadget(#Label, 10, 200, 80, 20, "(Click Data)", #PB_String_ReadOnly)
    StringGadget(#Value, 95, 200, 30, 20, "")
    ButtonGadget(#Button, 130, 200, 40, 20, "Apply")

    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case Chart::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #Chart
              Select EventType()
                Case #PB_EventType_LeftClick       ;{ Left mouse click
                  CompilerIf #Example = 10
                    CompilerIf Chart::#Enable_DataSeries
                      DataSeries$ = Chart::EventDataSeries(#Chart) 
                      Debug "Left Click: "+Str(EventData()) + " (" + DataSeries$ + ")"
                      If DataSeries$
                        SetGadgetText(#Label, Chart::EventLabel(#Chart))
                        SetGadgetText(#Value, Str(Chart::EventValue(#Chart)))
                        SetGadgetColor(#Label, #PB_Gadget_BackColor, Chart::EventColor(#Chart))
                      EndIf
                    CompilerEndIf  
                  CompilerElseIf #Example = 15
                    CompilerIf Chart::#Enable_DataSeries
                      DataSeries$ = Chart::EventDataSeries(#Chart) 
                      Debug "Left Click: "+Str(EventData()) + " (" + DataSeries$ + ")"
                      If DataSeries$
                        SetGadgetText(#Label, Chart::EventLabel(#Chart))
                        SetGadgetText(#Value, Str(Chart::EventValue(#Chart)))
                        SetGadgetColor(#Label, #PB_Gadget_BackColor, Chart::EventColor(#Chart))
                      EndIf
                    CompilerEndIf
                  CompilerElse
                    Debug "Left Click: "+Str(EventData())
                    Index = EventData()
                    If Index > -1
                      SetGadgetText(#Label, Chart::GetItemLabel(#Chart, Index))
                      SetGadgetText(#Value, Str(Chart::GetItemState(#Chart, Index)))
                      SetGadgetColor(#Value, #PB_Gadget_FrontColor, Chart::EventColor(#Chart))
                    EndIf
                  CompilerEndIf
                  ;}
                Case #PB_EventType_LeftDoubleClick ;{ LeftDoubleClick
                  Debug "Left DoubleClick"
                  ;}
                Case #PB_EventType_RightClick      ;{ Right mouse click
                  Debug "Right Click: "+Str(EventData())
                  ;}
              EndSelect
          EndSelect ;}
        Case #PB_Event_Menu
          Select EventMenu()
            Case #Menu_Display 
              CompilerIf Chart::#Enable_DataSeries
                CompilerIf #Example = 10
                  Chart::DisplayDataSeries(#Chart, Chart::EventDataSeries(#Chart))
                CompilerElseIf #Example = 15
                  Chart::DisplayDataSeries(#Chart, Chart::EventDataSeries(#Chart))
                CompilerElseIf #Example = 16
                  Chart::DisplayScatterPlot(#Chart, Chart::EventDataSeries(#Chart))  
                CompilerEndIf
              CompilerEndIf
            Case #Menu_Hide
              CompilerIf Chart::#Enable_DataSeries
                CompilerIf #Example = 10
                  Chart::DisplayDataSeries(#Chart, Chart::EventDataSeries(#Chart), #False)
                CompilerElseIf #Example = 15
                  Chart::DisplayDataSeries(#Chart, Chart::EventDataSeries(#Chart), #False)
                CompilerElseIf #Example = 16
                  Chart::DisplayScatterPlot(#Chart, Chart::EventDataSeries(#Chart), #False)  
                CompilerEndIf
              CompilerEndIf  
          EndSelect
        Case #PB_Event_Gadget
          Select EventGadget()  
            Case #Button
              CompilerIf #Example = 10
                CompilerIf Chart::#Enable_DataSeries
                  Chart::SetSeriesLabelState(#Chart, DataSeries$, GetGadgetText(#Label), Val(GetGadgetText(#Value)))
                CompilerEndIf  
              CompilerElseIf #Example = 15 
                CompilerIf Chart::#Enable_DataSeries
                  Chart::SetSeriesLabelState(#Chart, DataSeries$, GetGadgetText(#Label), Val(GetGadgetText(#Value)))
                CompilerEndIf  
              CompilerElse
                Chart::SetLabelState(#Chart, GetGadgetText(#Label), Val(GetGadgetText(#Value)))
              CompilerEndIf
          EndSelect
      EndSelect        
    Until Event = #PB_Event_CloseWindow
    
    CloseWindow(#Window)
  EndIf
  
CompilerEndIf  
