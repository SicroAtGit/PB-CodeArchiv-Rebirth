;   Description: Editable and sortable ListGadget
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72402
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31330
; -----------------------------------------------------------------------------

;/ ===========================
;/ =    ListEx-Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ Editable and sortable ListGadget
;/
;/ © 2019 Thorsten1867 (03/2019)
;/
  

; Last Update: 12.06.2019

; - Restore focus after sorting
; - Bugfix: make row visible
;
; - SetState() moves now the row into the visible area
; - Key control (Up/Down, PageUp/PageDown, Home/End)
;
; - Added: #ProgressBar for AddColumn() => SetProgressBarAttribute() / SetProgressBarFlags()
;
; - Focus on the line in which a popup menu was opened with the right mouse button.
; - SetState(GNum.i, Row.i=#PB_Default)
; - BugFix: Right mouse click on Header 


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


;{ _____ ListEx - Commands _____

; ListEx::AddItem()                 - similar to 'AddGadgetItem()'
; ListEx::AddColumn()               - similar to 'AddGadgetColumn()'
; ListEx::AddComboBoxItems()        - add items to the comboboxes of the column (items seperated by #LF$)
; ListEx::CountItems()              - similar to 'CountGadgetItems()'
; ListEx::ChangeCountrySettings()   - change default settings
; ListEx::ClearComboBoxItems()      - clear items of the comboboxes of the column
; ListEx::ClearItems()              - similar to 'ClearGadgetItems()'
; ListEx::DisableEditing()          - disable editing for the complete list
; ListEx::DisableReDraw()           - disable redraw
; ListEx::EventColumn()             - column of event (Event: ListEx::#Event_Module)
; ListEx::EventRow()                - row of event    (Event: ListEx::#Event_Module)
; ListEx::EventState()              - returns state   (e.g. CheckBox / DateGadget)
; ListEx::EventValue()              - returns value   (string)
; ListEx::EventID()                 - returns row ID or header label 
; ListEx::Gadget()                  - [#GridLines|#NumberedColumn|#NoRowHeader]
; ListEx::GetAttribute()            - similar to 'GetGadgetAttribute()'
; ListEx::GetCellText()             - similar to 'GetGadgetItemText()' with labels
; ListEx::GetCellState()            - similar to 'GetGadgetItemState()' with labels
; ListEx::GetChangedState()         - check whether entries have been edited
; ListEx::GetColumnAttribute()      - similar to 'GetGadgetItemAttribute()'
; ListEx::GetColumnState()          - similar to 'GetGadgetItemState()' for a specific column
; ListEx::GetItemData()             - similar to 'GetGadgetItemData()'
; ListEx::GetItemID()               - similar to 'GetGadgetItemData()' but with string data
; ListEx::GetItemState()            - similar to 'GetGadgetItemState()'
; ListEx::GetItemText()             - similar to 'GetGadgetItemText()'
; ListEx::GetState(GNum.i)         - similar to 'GetGadgetState()'
; ListEx::Refresh()                 - redraw gadget
; ListEx::RemoveColumn()            - similar to 'RemoveGadgetColumn()'
; ListEx::RemoveItem()              - similar to 'RemoveGadgetItem()'
; ListEx::ResetChangedState()       - reset to not edited
; ListEx::SetAutoResizeColumn()     - column that is reduced when the vertical scrollbar is displayed.
; ListEx::SetAutoResizeFlags()      - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]
; ListEx::SetCellState()            - similar to 'SetGadgetItemState()' with labels
; ListEx::SetCellText()             - similar to 'SetGadgetItemText()' with labels
; ListEx::SetColor()                - similar to 'SetGadgetColor()'
; ListEx::SetColorTheme()           - change the color theme
; ListEx::SetColumnAttribute()      - [#Align/#Width/#Font]
; ListEx::SetColumnState()          - similar to 'SetGadgetItemState()' for a specific column
; ListEx::SetDateMask()             - similar to 'SetGadgetText()' and 'DateGadget()'
; ListEx::SetDateAttribute()        - similar to 'SetGadgetAttribute()' and 'DateGadget()'
; ListEx::SetFont()                 - similar to 'SetGadgetFont()'
; ListEx::SetHeaderAttribute()      - [#Align]
; ListEx::SetHeaderSort()           - enable sort by header column [#Sort_Ascending|#Sort_Descending|#Sort_NoCase|#Sort_SwitchDirection]
; ListEx::SetItemAttribute()        - similar to 'SetGadgetItemAttribute()'
; ListEx::SetItemColor()            - similar to 'SetGadgetItemColor()'
; ListEx::SetItemData()             - similar to 'SetGadgetItemData()'
; ListEx::SetItemFont()             - change font of row or header [#Header]
; ListEx::SetItemID()               - similar to 'SetGadgetItemData()' but with string data
; ListEx::SetItemImage( )           - add a image at row/column
; ListEx::SetItemState()            - similar to 'SetGadgetItemState()'
; ListEx::SetItemText()             - similar to 'SetGadgetItemText()'
; ListEx::SetProgressBarAttribute() - set minimum or maximum value for progress bars
; ListEx::SetProgressBarFlags()     - set flags for progressbar (#ShowPercent)
; ListEx::SetRowsHeight()           - change height of rows
; ListEx::SetTimeMask()             - change mask for time (sorting)
; ListEx::Sort()                    - sort rows by column [#SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch]

;} -----------------------------


DeclareModule ListEx
  
  #Enable_Validation  = #True
  #Enable_MarkContent = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #FirstItem = 0
  #LastItem  = -1
  
  #Header   = -1
  #NotValid = -2 
  
  #Ascending   = #PB_Sort_Ascending
  #Descending  = #PB_Sort_Descending
  #SortNoCase  = #PB_Sort_NoCase
  
  #ColumnCount = #PB_ListIcon_ColumnCount

  #Selected   = #PB_ListIcon_Selected
  #Checked    = #PB_ListIcon_Checked
  #Inbetween  = #PB_ListIcon_Inbetween
  
  #Minimum     = #PB_Date_Minimum
  #Maximum     = #PB_Date_Maximum
  
  #Progress$ = "{Percent}"
  
  EnumerationBinary ; ProgressBars
    #ShowPercent
  EndEnumeration
  
  EnumerationBinary ; Sort Header
    #Left   = 1
    #Right  = 1<<1
    #Center = 1<<2
    #Deutsch
    #Lexikon
    #Namen
    #SortString
    #SortNumber
    #SortDate
    #SortBirthday
    #SortTime
    #SortCash
    #SortFloat
    #HeaderSort
    #SortArrows
    #SwitchDirection
  EndEnumeration  
  
  Enumeration 
    #Align
    #Font
    #FontID
    #Width
    #Gadget
    #CellFont
  EndEnumeration
  
  EnumerationBinary Flags
    #Left    = 1
    #Right   = 1<<1
    #Center  = 1<<2
    #ChBFlag = 1<<3
    ; ---Gadget ---
    #GridLines
    #NoRowHeader
    #NumberedColumn
    #SingleClickEdit
    #AutoResize
    #UseExistingCanvas
    #ThreeState
    #MultiSelect
    ; --- Edit/Events ---
    #Image
    ; --- Color ---
    #ActiveLinkColor
    #BackColor
    #ButtonColor
    #ButtonBorderColor
    #ProgressBarColor
    #EditColor
    #FocusColor
    #FrontColor
    #GadgetBackColor
    #GridColor
    #LinkColor
    #HeaderFrontColor
    #HeaderBackColor
    #HeaderGridColor
    #AlternateRowColor
  EndEnumeration

  EnumerationBinary ColumnFlags
    #Left    = 1
    #Right   = 1<<1
    #Center  = 1<<2
    #CheckBoxes = #ChBFlag
    #ComboBoxes
    #Dates
    #Strings
    #Editable = #Strings
    #Buttons
    #Links
    #ProgressBar
    #MarkContent
    #Hide
    ; --------
    #Cash
    #Float
    #Grades
    #Integer
    #Number     ; unsigned Integer
    #Time
    #Text
  EndEnumeration  
  
  EnumerationBinary
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration 
  
  Enumeration 1
    #Currency
    #Clock
    #TimeSeperator
    #DateSeperator
    #DecimalSeperator
  EndEnumeration
  
  Enumeration Theme 1
    #Theme_Blue  
    #Theme_Green
  EndEnumeration
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    #Event_Gadget       = ModuleEx::#Event_Gadget
    
    #EventType_Button   = ModuleEx::#EventType_Button
    #EventType_String   = ModuleEx::#EventType_String
    #EventType_CheckBox = ModuleEx::#EventType_CheckBox
    #EventType_ComboBox = ModuleEx::#EventType_ComboBox
    #EventType_Date     = ModuleEx::#EventType_Date
    #EventType_Header   = ModuleEx::#EventType_Header
    #EventType_Link     = ModuleEx::#EventType_Link
    #EventType_Row      = ModuleEx::#EventType_Row
    
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Button
      #EventType_String
      #EventType_CheckBox
      #EventType_ComboBox
      #EventType_Date
      #EventType_Header
      #EventType_Link
      #EventType_Row
    EndEnumeration
    
  CompilerEndIf
  ;}
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddColumn(GNum.i, Column.i, Title.s, Width.f, Label.s="", Flags.i=#False)
  Declare.i AddComboBoxItems(GNum.i, Column.i, Text.s)
  Declare.i AddItem(GNum.i, Row.i=-1, Text.s="", RowID.s="", Flags.i=#False)
  Declare   AttachPopupMenu(GNum.i, Popup.i)
  Declare   ChangeCountrySettings(GNum.i, CountryCode.s, Currency.s="", Clock.s="", DecimalSeperator.s="", TimeSeperator.s="", DateSeperator.s="")
  Declare   ClearComboBoxItems(GNum.i, Column.i)
  Declare   ClearItems(GNum.i)
  Declare.i CountItems(GNum.i)
  Declare   DisableEditing(GNum.i, State.i=#True)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i EventColumn(GNum)
  Declare.s EventID(GNum.i)
  Declare.i EventRow(GNum.i)
  Declare.i EventState(GNum.i)
  Declare.s EventValue(GNum.i)
  Declare.i Gadget(GNum.i, X.f, Y.f, Width.f, Height.f, ColTitle.s, ColWidth.f, ColLabel.s="", Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetAttribute(GNum.i, Attribute.i)
  Declare.s GetCellText(GNum.i, Row.i, Label.s)
  Declare.i GetCellState(GNum.i, Row.i, Label.s) 
  Declare.i GetChangedState(GNum.i)
  Declare.i GetColumnState(GNum.i, Row.i, Column.i)
  Declare.i GetColumnAttribute(GNum.i, Column.i, Attribute.i)
  Declare.i GetItemData(GNum.i, Row.i)
  Declare.s GetItemID(GNum.i, Row.i)
  Declare.i GetItemState(GNum.i, Row.i, Column.i=#PB_Default)
  Declare.s GetItemText(GNum.i, Row.i, Column.i)
  Declare.i GetState(GNum.i)
  Declare   LoadColorTheme(GNum.i, File.s)
  Declare   Refresh(GNum.i)
  Declare   RemoveColumn(GNum.i, Column.i)
  Declare   RemoveItem(GNum.i, Row.i)
  Declare   ResetChangedState(GNum.i)
  Declare   SaveColorTheme(GNum.i, File.s)
  Declare   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetCellState(GNum.i, Row.i, Label.s, State.i)
  Declare   SetCellText(GNum.i, Row.i, Label.s, Text.s)
  Declare   SetColor(GNum.i, ColorTyp.i, Value.i)
  Declare   SetColorTheme(GNum.i, Theme.i=#PB_Default)
  Declare   SetColumnAttribute(GNum.i, Column.i, Attrib.i, Value.i)
  Declare   SetColumnState(GNum.i, Row.i, Column.i, State.i)
  Declare   SetFont(GNum.i, FontID.i)     
  Declare   SetDateAttribute(GNum.i, Column.i, Attrib.i, Value.i)
  Declare   SetDateMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
  Declare   SetHeaderAttribute(GNum.i, Attrib.i, Value.i)
  Declare   SetHeaderSort(GNum.i, Column.i, Direction.i=#PB_Sort_Ascending, Flag.i=#True)
  Declare   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
  Declare   SetItemData(GNum.i, Row.i, Value.i)
  Declare   SetItemFont(GNum.i, Row.i, FontID.i, Column.i=#PB_Ignore)
  Declare   SetItemID(GNum.i, Row.i, String.s)
  Declare   SetItemImage(GNum.i, Row.i, Column.i, Width.f, Height.f, ImageID.i, Align.i=#Left)
  Declare   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Default)
  Declare   SetItemText(GNum.i, Row.i, Text.s , Column.i)
  Declare   SetProgressBarAttribute(GNum.i, Attrib.i, Value.i)
  Declare   SetProgressBarFlags(GNum.i, Flags.i)
  Declare   SetRowsHeight(GNum.i, Height.f)
  Declare   SetState(GNum.i, Row.i=#PB_Default)
  Declare   SetTimeMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
  Declare   Sort(GNum.i, Column.i, Direction.i, Flags.i)
  
  CompilerIf #Enable_MarkContent
    Declare MarkContent(GNum.i, Column.i, Term.s, Color1.i=#PB_Default, Color2.i=#PB_Default, FontID.i=#PB_Default)
  CompilerEndIf

EndDeclareModule

Module ListEx

  EnableExplicit
  
  UsePNGImageDecoder()
  
  ;{ OS specific contants
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #ScrollBar_Width  = 18
    CompilerCase #PB_OS_MacOS
      #ScrollBar_Width  = 18
    CompilerCase #PB_OS_Linux
      #ScrollBar_Width  = 18
  CompilerEndSelect ;}
  
  ;- ===========================================================================
  ;-   Module - Constants
  ;- ===========================================================================  
  
  #DefaultCountry          = "DE"
  #DefaultDateMask         = "%dd.%mm.%yyyy"
  #DefaultTimeMask         = "%hh:%ii:%ss"
  #DefaultCurrency         = "€"
  #DefaultClock            = "Uhr"
  #DefaultTimeSeparator    = ":"
  #DefaultDateSeparator    = "."
  #DefaultDecimalSeperator = ","
  
  #RegEx = 1
  #JSON  = 1
  #NoFocus = -1
  #NotSelected = -1
  
  #Cursor_Default = #PB_Cursor_Default
  #Cursor_Edit    = #PB_Cursor_Hand
  #Cursor_Sort    = #PB_Cursor_Hand
  #Cursor_Click   = #PB_Cursor_Hand
  #Cursor_Button  = #PB_Cursor_Default
  
  Enumeration ColorFlag 1
    #Focus
    #Click
  EndEnumeration
  
  Enumeration Grades 1
    #Grades_Number
    #Grades_Character
    #Grades_Points
  EndEnumeration
  
  Enumeration 1
    #Key_Return
    #Key_Escape
    #Key_Tab
    #Key_ShiftTab
  EndEnumeration
  
  #Condition1 = 1
  #Condition2 = 2
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================  
  
  ; ===== Structures =====
  
  Structure ListEx_Mark_Structure       ;{ ListEx()\Mark()\...
    Term.s
    Color1.i
    Color2.i
    FontID.i
  EndStructure ;}
  
  Structure Country_Structure           ;{ ListEx()\Country\...
    Code.s
    Currency.s
    Clock.s
    TimeSeparator.s
    DateSeperator.s
    DecimalSeperator.s
    DateMask.s
    TimeMask.s
  EndStructure ;}
  
  Structure Grades_Structure            ;{ Grades()\...
    Best.i
    Worst.i
    Term.s
    Flag.i    ; #Number/#Character/#Points
    Map Notation.s()
  EndStructure ;}
  
  Structure Font_Structure              ;{ Font()\...
    ID.i
    Name.s
    Style.i
    Size.i
    Map DPI.i()
  EndStructure ;}
  
  Structure Color_Structure             ;{ ...\Color\...
    Front.i
    Back.i
    Grid.i
  EndStructure ;}
  
  Structure Image_Structure             ;{ ListEx()\Rows()\Column('label')\Image\...
    ID.i
    Width.f
    Height.f
    Flags.i
  EndStructure ;}
  
  Structure Cols_Header_Structure       ;{ ListEx()\Cols()\Header\...
    Titel.s
    Direction.i
    Sort.i
    Image.Image_Structure
    Flags.i
  EndStructure ;}
  
  Structure ComboBox_Item_Structure     ;{ ListEx()\ComboBox\Column('num')\...
    List Items.s()
  EndStructure ;}
  
  Structure Date_Structure              ;{ ListEx()\Date\Column('num')\...
    Min.i
    Max.i
    Mask.s
  EndStructure ;}
  
  Structure Event_Structure             ;{ ListEx()\Event\...
    Type.i
    Row.i
    Column.i
    Value.s
    State.i
    ID.s
  EndStructure  ;}
  

  Structure Rows_Column_Structure       ;{ ListEx()\Rows()\Column('label')\...
    Value.s
    FontID.i
    State.i ; e.g. CheckBoxes
    Flags.i
    Image.Image_Structure
    Color.Color_Structure
  EndStructure ;}
  
  Structure ListEx_Sort_Structure       ;{ ListEx()\Sort\...
    Column.i
    Label.s
    Direction.i
    Flags.i
  EndStructure ;}
  
  Structure ListEx_AutoResize_Structure ;{ ListEx()\AutoResize\...
    Column.i
    Width.f
    minWidth.f
    maxWidth.f
  EndStructure ;}
  
  Structure ListEx_Color_Structure      ;{ ListEx()\Color\...
    AlternateRow.i
    Front.i
    Back.i
    Grid.i
    HeaderFront.i
    HeaderBack.i
    HeaderGrid.i
    Canvas.i
    Focus.i
    Edit.i
    Button.i
    ButtonBorder.i
    ProgressBar.i
    Link.i
    ActiveLink.i
    ScrollBar.i
    WrongFront.i
    WrongBack.i
    Mark1.i
    Mark2.i
  EndStructure ;}
  
  Structure ListEx_Col_Structure        ;{ ListEx()\Col\...
    Current.i
    Number.i
    Width.f
    OffsetX.f
    CheckBoxes.i
  EndStructure ;}
  
  Structure ListEx_Cols_Structure       ;{ ListEx()\Cols()\...
    Type.i
    X.f
    Key.s
    Width.f
    Align.i
    FontID.i
    Mask.s
    Currency.s
    Flags.i
    Header.Cols_Header_Structure
  EndStructure ;}  
  
  Structure ListEx_ProgressBar          ;{ ListEx()\ProgressBar\...
    Minimum.i
    Maximum.i
    Flags.i
  EndStructure ;}
  
  Structure ListEx_String_Structure     ;{ ListEx()\String\...
    Row.i
    Col.i
    X.f
    Y.f
    Width.f
    Height.f
    Label.s
    Flag.i
    Wrong.i
  EndStructure ;}
  
  Structure ListEx_Button_Structure     ;{ ListEx()\Button\...
    Row.i
    Col.i
    RowID.s
    Value.s
    Label.s
    Pressed.i
    Focus.s
  EndStructure ;}
  
  Structure ListEx_Link_Structure       ;{ ListEx()\Link\...
    Row.i
    Col.i
    RowID.s
    Value.s
    Label.s
    Pressed.i
  EndStructure ;}
  
  Structure ListEx_ComboBox_Structure   ;{ ListEx()\ComboBox\...
    Row.i
    Col.i
    X.f
    Y.f
    Width.f
    Height.f
    Label.s
    Text.s
    State.i
    Flag.i
    Map Column.ComboBox_Item_Structure()
  EndStructure ;}
  
  Structure ListEx_CheckBox_Structure   ;{ ListEx()\CheckBox\...
    Row.i
    Col.i
    Label.s
    State.i
  EndStructure ;}
  
  Structure ListEx_Date_Structure       ;{ ListEx()\String\...
    Row.i
    Col.i
    X.f
    Y.f
    Width.f
    Height.f
    Mask.s
    Label.s
    Flag.i
    Map Column.Date_Structure()
  EndStructure ;}
  
  Structure ListEx_Header_Structure     ;{ ListEx()\Header\...
    Col.i
    Height.f
    Align.i
    FontID.i
  EndStructure ;}   
  
  Structure ListEx_Row_Structure        ;{ ListEx()\Row\...
    Current.i
    CurrentKey.i
    Number.i
    Height.f
    FontID.i
    Offset.i
    OffSetY.f
    Focus.i
    Color.Color_Structure ; Default colors
  EndStructure ;}  
  
  Structure ListEx_Rows_Structure       ;{ ListEx()\Rows()\...
    ID.s
    iData.i
    Y.f
    Height.f
    FontID.i
    Sort.s
    iSort.i
    fSort.f
    State.i
    Flags.i
    Color.Color_Structure
    Map Column.Rows_Column_Structure()
  EndStructure ;}  
  
  Structure ListEx_Scroll_Structure     ;{ ListEx()\VScroll\...
    MinPos.f
    MaxPos.f
    Position.f
    Hide.i
  EndStructure ;}
  
  Structure ListEx_Size_Structure       ;{ ListEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Rows.f
    Cols.f
    Flags.i
  EndStructure ;}
  
  Structure ListEx_Window_Structure     ;{ ListEx()\Window\...
    Num.i
    Width.f
    Height.i
  EndStructure ;}

  Structure ListEx_Structure            ;{ ListEx()\...
    
    Window.ListEx_Window_Structure
    
    CanvasNum.i
    StringNum.i
    ComboNum.i
    DateNum.i
    PopUpID.i
    HScrollNum.i
    VScrollNum.i
    ShortCutID.i

    Editable.i
    ReDraw.i
    
    Cursor.i
    Focus.i
    Strg.i
    Changed.i
    Flags.i
    
    Size.ListEx_Size_Structure
    
    VScroll.ListEx_Scroll_Structure
    HScroll.ListEx_Scroll_Structure
    AutoResize.ListEx_AutoResize_Structure
    
    Header.ListEx_Header_Structure
    Row.ListEx_Row_Structure
    Col.ListEx_Col_Structure
    
    Color.ListEx_Color_Structure
    
    Sort.ListEx_Sort_Structure

    Button.ListEx_Button_Structure
    CheckBox.ListEx_CheckBox_Structure
    ComboBox.ListEx_ComboBox_Structure
    ProgressBar.ListEx_ProgressBar
    Country.Country_Structure
    Date.ListEx_Date_Structure
    Event.Event_Structure
    Link.ListEx_Link_Structure
    String.ListEx_String_Structure
    
    Map Mark.ListEx_Mark_Structure()
    
    List Cols.ListEx_Cols_Structure()
    List Rows.ListEx_Rows_Structure()
    
  EndStructure ;}
  
  Global NewMap ListEx.ListEx_Structure()
  
  Global NewMap Font.Font_Structure()
  Global NewMap Grades.Grades_Structure() 
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  Declare AdjustScrollBars_(Force.i=#False)
  Declare BindShortcuts_(Flag.i=#True)
  Declare CloseString_(Escape.i=#False)
  Declare CloseComboBox_(Escape.i=#False)
  Declare CloseDate_(Escape.i=#False)
  
  
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
  
  
  Procedure   IsNumber_(String$)
    Define.i c
    
    String$ = Trim(String$)
    If String$ = "" : ProcedureReturn #False : EndIf
    
    For c=1 To Len(String$)
      Select Asc(Mid(String$, c, 1))
        Case 48 To 57
          Continue
        Case 44, 45, 46
          Continue
        Default
          ProcedureReturn #False
      EndSelect
    Next
  
    If CountString(String$, ".") > 1 Or CountString(String$, "-") > 1
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  
  Procedure   UpdateColumnX_()
    
    ListEx()\Size\Cols = 0
    
    ForEach ListEx()\Cols()
      If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
      ListEx()\Cols()\X  = ListEx()\Size\Cols
      ListEx()\Size\Cols + ListEx()\Cols()\Width
    Next  
      
  EndProcedure
  
  Procedure   UpdateRowY_()
    
    ListEx()\Size\Rows   = 0
    ListEx()\Row\OffSetY = 0
    
    ForEach ListEx()\Rows()
      
      If ListIndex(ListEx()\Rows()) < ListEx()\Row\Offset
        ListEx()\Row\OffSetY + ListEx()\Rows()\Height
      EndIf
      
      
      If ListEx()\Flags & #NoRowHeader
        ListEx()\Rows()\Y  = ListEx()\Size\Rows
      Else
        ListEx()\Rows()\Y  = ListEx()\Size\Rows + ListEx()\Header\Height
      EndIf
      
      ListEx()\Size\Rows + ListEx()\Rows()\Height
      
    Next
    
  EndProcedure
  
  Procedure.i GetPageRows_()    ; all visible Rows
    ProcedureReturn Int((ListEx()\Size\Height - ListEx()\Header\Height) / ListEx()\Row\Height)
  EndProcedure  
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  Procedure.i GetRow_(Y.f)

    If Y > ListEx()\Size\Y And Y < ListEx()\Size\Rows + ListEx()\Header\Height
      
      If Y < ListEx()\Header\Height
        ProcedureReturn #Header 
      Else
        
        ListEx()\Row\OffsetY = 0
        
        ForEach ListEx()\Rows()
          
          If ListIndex(ListEx()\Rows()) < ListEx()\Row\Offset
            ListEx()\Row\OffsetY + ListEx()\Rows()\Height
          Else
            If ListEx()\Rows()\Y > Y + ListEx()\Row\OffsetY
              ProcedureReturn ListIndex(ListEx()\Rows()) - 1
            EndIf
          EndIf
        Next
        
        ProcedureReturn ListIndex(ListEx()\Rows())
      EndIf
      
    Else
      ProcedureReturn #NotValid
    EndIf
    
  EndProcedure
  

  Procedure.i GetColumn_(X.i)
    
    If X > ListEx()\Size\X And X < ListEx()\Size\Cols
      
      ForEach ListEx()\Cols()
        If ListEx()\Cols()\X >= X + ListEx()\Col\OffsetX
          ProcedureReturn ListIndex(ListEx()\Cols()) - 1
        EndIf
      Next
      
      ProcedureReturn ListIndex(ListEx()\Cols())
    Else
      ProcedureReturn #NotValid
    EndIf
    
  EndProcedure
  
  ;- _____ Check Content _____
  
  CompilerIf #Enable_Validation
    
    Procedure   LoadGrades()
      
      If AddMapElement(Grades(), "DE")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 1
        Grades()\Worst  = 6
        Grades()\Term   = "Beyond{3|4}"
      EndIf
      
      If AddMapElement(Grades(), "AT")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 1
        Grades()\Worst  = 5
        Grades()\Term   = "Beyond{3|3}"
      EndIf
      
      If AddMapElement(Grades(), "IT")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 10
        Grades()\Worst  = 0
        Grades()\Term   = "Beyond{6|7}"
      EndIf
      
      If AddMapElement(Grades(), "ES")
        Grades()\Flag   = #Grades_Number
        Grades()\Best   = 10
        Grades()\Worst  = 0
        Grades()\Term   = "Beyond{5|6}"
      EndIf
      
      If AddMapElement(Grades(), "US")
        Grades()\Flag   = #Grades_Character
        Grades()\Best   = 1
        Grades()\Worst  = 5
        Grades()\Term   = "Beyond{3|4}"
        Grades()\Notation("1") = "A"
        Grades()\Notation("2") = "B"
        Grades()\Notation("3") = "C"
        Grades()\Notation("4") = "D"
        Grades()\Notation("5") = "F"
      EndIf
      
      If AddMapElement(Grades(), "GB")
        Grades()\Flag   = #Grades_Character
        Grades()\Best   = 1
        Grades()\Worst  = 6
        Grades()\Term   = "Beyond{3|5}"
        Grades()\Notation("1") = "A"
        Grades()\Notation("2") = "B"
        Grades()\Notation("3") = "C"
        Grades()\Notation("4") = "D"
        Grades()\Notation("5") = "E"
        Grades()\Notation("6") = "F"
      EndIf
      
      If AddMapElement(Grades(), "FR")
        Grades()\Flag   = #Grades_Points
        Grades()\Best   = 20
        Grades()\Worst  = 0
        Grades()\Term   = "Beyond{10|14}"
      EndIf
      
    EndProcedure
  
    Procedure.s ConvertUSTime_(Time.s, Seperator.s=":")
      Define apm$, Second$, Hour.i
      
      apm$  = LCase(RemoveString(StringField(Time, 2, " "), "."))
      Time = ReplaceString(StringField(Time, 1, " "), ".", " ")
      
      Hour = Val(StringField(Time, 1, Seperator))
      If CountString(apm$, "pm") = 1
        Hour + 12
      EndIf
      
      Second$ = StringField(Time, 3, Seperator)
      If Trim(Second$) = ""
        ProcedureReturn Str(Hour) + Seperator + StringField(Time, 2, Seperator)
      Else
        ProcedureReturn Str(Hour) + Seperator + StringField(Time, 2, Seperator) + Seperator + Second$
      EndIf
      
    EndProcedure

    Procedure.s GetTimeString_(Time.s, Mask.s, Seperator.s=":") 
      Define i.i, Hour$, Minute$, Second$, Parse$
      
      Parse$ = ListEx()\Cols()\Mask
      If Parse$ = "" : Parse$ = ListEx()\Country\TimeMask : EndIf
      
      Time  = ConvertUSTime_(Time)
      
      For i=1 To 3
        Select StringField(Parse$, i, Seperator)
          Case "%hh"
            Hour$   = RSet(StringField(Time, i, Seperator), 2, " ")
          Case "%ii"
            Minute$ = RSet(StringField(Time, i, Seperator), 2, "0")
          Case "%ss"
            Second$ = RSet(StringField(Time, i, Seperator), 2, "0")
        EndSelect
      Next
      
      Time = ReplaceString(Mask, "%0h", Hour$)
      Time = ReplaceString(Time, "%hh", Hour$)
      Time = ReplaceString(Time, "%ii", Minute$)
      Time = ReplaceString(Time, "%ss", Second$)
      
      ProcedureReturn Time
    EndProcedure    
  
    Procedure.i IsInteger(Value.s, UnSigned=#False)
      Define.i i
      
      For i=1 To Len(Value)
        Select Asc(Mid(Value, i, 1))
          Case 48 To 57
            Continue
          Case 43, 45
            If UnSigned
              ProcedureReturn #False
            EndIf
          Default
            ProcedureReturn #False
        EndSelect    
      Next
      
      ProcedureReturn #True
    EndProcedure
  
    Procedure.i IsFloat(Value.s)
      Define.i i
      
      Value = ReplaceString(Value, ",", ".") 
      
      If CountString(Value, ".") <> 1 : ProcedureReturn #False : EndIf
      
      For i=1 To Len(Value)
        Select Asc(Mid(Value, i, 1))
          Case 48 To 57 ; 0 - 9
            Continue
          Case 43, 45   ; + / -
            Continue
          Case 46
            Continue
          Default
            ProcedureReturn #False
        EndSelect    
      Next
      
      ProcedureReturn #True
    EndProcedure
  
    Procedure.i IsCash(Value.s)
      
      Value = Trim(RemoveString(Value, ListEx()\Cols()\Currency))
      Value = ReplaceString(Value, ",", ".")
      
      If IsFloat(Value)
        If Len(StringField(Value, 2, ".")) = 2
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure
  
    Procedure.i IsGrade(Value.s)
      
      If FindMapElement(Grades(), ListEx()\Country\Code)
        
        If Grades()\Flag & #Grades_Number Or Grades()\Flag & #Grades_Points ;{ Grades are numbers
          
          If IsInteger(Value, #True) = #False : ProcedureReturn #False : EndIf
          
          If Grades()\Best < Grades()\Worst  ; 1 - 6
            If Val(Value) >= Grades()\Best And Val(Value) <= Grades()\Worst
              ProcedureReturn #True
            EndIf 
          Else ; 12 - 0
            If Val(Value) >= Grades()\Worst And Val(Value) <= Grades()\Best
              ProcedureReturn #True
            EndIf
          EndIf
          ProcedureReturn #False
          ;}
        ElseIf Grades()\Flag & #Grades_Character ;{ Grades are characters
          If Grades()\Best < Grades()\Worst
            If Value >= Grades()\Notation(Str(Grades()\Best)) And Value  <= Grades()\Notation(Str(Grades()\Worst))
              ProcedureReturn #True
            EndIf 
          Else
            If Value >= Grades()\Notation(Str(Grades()\Worst)) And Value <= Grades()\Notation(Str(Grades()\Best))
              ProcedureReturn #True
            EndIf
          EndIf
          ProcedureReturn #False
          ;}
        EndIf
        
        ProcedureReturn #True
      Else
        ProcedureReturn #True
      EndIf
      
    EndProcedure
  
    Procedure IsTime(Value.s)
      Define Time$, Hour.s, Minute.s, Second.s
      
      Time$ = Trim(RemoveString(Value, ListEx()\Country\Clock))
      Time$ = GetTimeString_(Time$, "%hh|%ii|%ss")
      
      Hour   = StringField(Time$, 1, "|")
      Minute = StringField(Time$, 2, "|")
      Second = StringField(Time$, 3, "|")
      
      If IsInteger(Hour,   #True) = #False Or Val(Hour)   > 24 : ProcedureReturn #False : EndIf
      If IsInteger(Minute, #True) = #False Or Val(Minute) > 59 : ProcedureReturn #False : EndIf
      If IsInteger(Second, #True) = #False Or Val(Second) > 59 : ProcedureReturn #False : EndIf
      
      ProcedureReturn #True
    EndProcedure
  
    Procedure.i IsContentValid_(Value.s)
      
      If Value = "" : ProcedureReturn #True : EndIf
      
      If ListEx()\Cols()\Flags & #Number
        ProcedureReturn IsInteger(Value, #True) 
      ElseIf ListEx()\Cols()\Flags & #Integer
        ProcedureReturn IsInteger(Value) 
      ElseIf ListEx()\Cols()\Flags & #Float
        ProcedureReturn IsFloat(Value)
      ElseIf ListEx()\Cols()\Flags & #Grades
        ProcedureReturn IsGrade(Value)
      ElseIf ListEx()\Cols()\Flags & #Cash
        ProcedureReturn IsCash(Value)
      ElseIf ListEx()\Cols()\Flags & #Time
        ProcedureReturn IsTime(Value)
      EndIf  
      
      ProcedureReturn #True
    EndProcedure
  
  CompilerElse
    
    Procedure.i IsContentValid_(Value.s)
      ProcedureReturn #True
    EndProcedure
    
  CompilerEndIf
  
  ;- _____ Mark Content _____
  
  CompilerIf #Enable_MarkContent
    
    Procedure   MarkContent_(Term.s, Color1.i, Color2.i, FontID.i)
      
      If AddMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
       
        ListEx()\Mark()\Term   = Term
        
        If Color1 = #PB_Default
          ListEx()\Mark()\Color1 = ListEx()\Color\Mark1
        Else 
          ListEx()\Mark()\Color1 = Color1
        EndIf
        
        If Color2 = #PB_Default
          ListEx()\Mark()\Color2 = ListEx()\Color\Mark2
        Else 
          ListEx()\Mark()\Color2 = Color2
        EndIf
        
        ListEx()\Mark()\FontID = FontID

        ListEx()\Cols()\Flags | #MarkContent
        
      EndIf
  
    EndProcedure
    
    Procedure.s ExtractTag_(Text.s, Left.s, Right.s)
      Define.i idxL, idxR
    
      idxL = FindString(Text, Left,  1)
      idxR = FindString(Text, Right, idxL + 1)
      
      If idxL And idxR
        idxL + Len(Left)
        ProcedureReturn Mid(Text, idxL, idxR-idxL)
      EndIf
    
    EndProcedure
    
    Procedure.i CompareValues_(Value1.s, Compare.s, Value2.s, Flag.i)
      
      Select Flag
        Case #Number, #Integer, #Grades ;{
          Select Compare
            Case "="
              If Val(Value1) =  Val(Value2) : ProcedureReturn #True : EndIf
            Case "<"
              If Val(Value1) <  Val(Value2) : ProcedureReturn #True : EndIf
            Case ">"
              If Val(Value1) >  Val(Value2) : ProcedureReturn #True : EndIf
            Case ">="
              If Val(Value1) >= Val(Value2) : ProcedureReturn #True : EndIf
            Case "<="
              If Val(Value1) <= Val(Value2) : ProcedureReturn #True : EndIf
            Case "<>"
              If Val(Value1) <> Val(Value2) : ProcedureReturn #True : EndIf
          EndSelect ;}        
        Case #Float, #Cash              ;{
          Value1 = ReplaceString(Value1, ListEx()\Country\DecimalSeperator, ".")
          Value2 = ReplaceString(Value2, ListEx()\Country\DecimalSeperator, ".")
          Select Compare
            Case "="
              If ValF(Value1) =  ValF(Value2) : ProcedureReturn #True : EndIf
            Case "<"
              If ValF(Value1) <  ValF(Value2) : ProcedureReturn #True : EndIf
            Case ">"
              If ValF(Value1) >  ValF(Value2) : ProcedureReturn #True : EndIf
            Case ">="
              If ValF(Value1) >= ValF(Value2) : ProcedureReturn #True : EndIf
            Case "<="
              If ValF(Value1) <= ValF(Value2) : ProcedureReturn #True : EndIf
            Case "<>"
              If ValF(Value1) <> ValF(Value2) : ProcedureReturn #True : EndIf
          EndSelect ;}
        Default                         ;{
          Select Compare
            Case "="
              If Value1 =  Value2 : ProcedureReturn #True : EndIf
            Case "<"
              If Value1 <  Value2 : ProcedureReturn #True : EndIf
            Case ">"
              If Value1 >  Value2 : ProcedureReturn #True : EndIf
            Case ">="
              If Value1 >= Value2 : ProcedureReturn #True : EndIf
            Case "<="
              If Value1 <= Value2 : ProcedureReturn #True : EndIf
            Case "<>"
              If Value1 <> Value2 : ProcedureReturn #True : EndIf
          EndSelect ;}
      EndSelect
    
      ProcedureReturn #False
    EndProcedure  
    
    Procedure.i IsMarked_(Content.s, Term.s, Flag.i)
      ; Flag: #Number, #Integer, #Grades, #Float, #Cash
      Define.i Result1, Result2, Row, Column
      Define   Type$, Expr$, Compare$, Link$
      Type$ = StringField(Term, 1, "{")
      Expr$ = ExtractTag_(Term, "{", "}")
      Link$ = ExtractTag_(Term, "[", "]")
      
      If Link$ ;{ Link to another cell
        
        Row    = ListIndex(ListEx()\Rows())
        Column = ListIndex(ListEx()\Cols())
        
        Select Left(Link$, 1) 
          Case "R"
            Row    = Val(LTrim(Link$, "R"))
          Case "C"
            Column = Val(LTrim(Link$, "C"))
          Default
            Row    = Val(StringField(Link$, 1, ":"))
            Column = Val(StringField(Link$, 2, ":"))
        EndSelect
        
        PushListPosition(ListEx()\Rows())
        
        If SelectElement(ListEx()\Rows(), Row)
          PushListPosition(ListEx()\Cols())
          If SelectElement(ListEx()\Cols(), Column)
            Content = ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value
          EndIf
          PopListPosition(ListEx()\Cols())
        EndIf 
        
        PopListPosition(ListEx()\Rows())
        ;}
      EndIf
        
      Select UCase(Type$)
        Case "NEGATIVE", "NEGATIV"  ;{ NEGATIVE
          If CompareValues_(Content, "<", "0", Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "POSITIVE", "POSITIV"  ;{ POSITIVE
          If CompareValues_(Content, ">", "0", Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "EQUAL", "GLEICH"      ;{ EQUAL{3.95} / EQUAL{String}
          If CompareValues_(Content, "=", Expr$, Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "LIKE"                 ;{ LIKE{*end} / LIKE{start*} / LIKE{*part*}
          If Left(Expr$, 1) = "*" And Right(Expr$, 1) = "*"
            Expr$ = Trim(Expr$, "*")
            If CountString(Content, Expr$) : ProcedureReturn #Condition1 : EndIf
          ElseIf Left(Expr$, 1)  = "*"
            Expr$ = LTrim(Expr$, "*")
            If Right(Content, Len(Expr$)) = Expr$ : ProcedureReturn #Condition1 : EndIf
          ElseIf Right(Expr$, 1) = "*"
            Expr$ = RTrim(Expr$, "*")
            If Left(Content, Len(Expr$))  = Expr$ : ProcedureReturn #Condition1 : EndIf
          Else
            If Left(Content, Len(Expr$))  = Expr$ : ProcedureReturn #Condition1 : EndIf
          EndIf ;}
        Case "COMPARE", "VERGLEICH" ;{ COMPARE{<|12}  =>  [?] < 12
          If CompareValues_(Content, StringField(Expr$, 1, "|"), StringField(Expr$, 2, "|"), Flag)
            ProcedureReturn #Condition1
          EndIf ;}
        Case "BETWEEN", "ZWISCHEN"  ;{ BETWEEN{10|20}  =>  10 < [?] < 20
          Result1 = CompareValues_(Content, ">", StringField(Expr$, 1, "|"), Flag)
          Result2 = CompareValues_(Content, "<", StringField(Expr$, 2, "|"), Flag)
          If Result1 And Result2
            ProcedureReturn #Condition1
          EndIf ;}
        Case "BEYOND"               ;{ BEYOND{3|4}  =>  3 > [?] OR [?] > 4
          Result1 = CompareValues_(Content, "<", StringField(Expr$, 1, "|"), Flag)
          Result2 = CompareValues_(Content, ">", StringField(Expr$, 2, "|"), Flag)
          If Result1
            ProcedureReturn #Condition1
          ElseIf Result2
            ProcedureReturn #Condition2
          EndIf ;}
        Case "CHOICE", "AUSWAHL"    ;{ CHOICE{m|f}[C4]
          Result1 = CompareValues_(Content, "=", StringField(Expr$, 1, "|"), Flag)
          Result2 = CompareValues_(Content, "=", StringField(Expr$, 2, "|"), Flag)
          If Result1
            ProcedureReturn #Condition1
          ElseIf Result2
            ProcedureReturn #Condition2
          EndIf ;}
      EndSelect
      
      ProcedureReturn #False
    EndProcedure
    
  CompilerEndIf   
  

  ;- __________ Drawing __________
  
  Procedure.f GetAlignOffset_(Text.s, Width.f, Flags.i)
    Define.f Offset
    
    If Flags & #Right
      Offset = Width - TextWidth(Text) - dpiX(4)
    ElseIf Flags & #Center
      Offset = (Width - TextWidth(Text)) / 2
    Else
      Offset = dpiX(4)
    EndIf
    
    If Offset < 0 : Offset = 0 : EndIf
    
    ProcedureReturn Offset
  EndProcedure
  
  Procedure.i CurrentColumn_()
    ProcedureReturn ListIndex(ListEx()\Cols())
  EndProcedure  
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  
  Procedure.i Arrow_(X.i, Y.i, Width.i, Height.i, Direction.i, Color.i=#PB_Default)
    Define.i aX, aY, aWidth, aHeight
    
    If Color = #PB_Default : Color = BlendColor_($000000, ListEx()\Color\HeaderBack) : EndIf
    
    aWidth  = dpiX(8)
    aHeight = dpiX(4)
    
    aX = X + Width - aWidth - dpiX(5)
    aY = Y + (Height - aHeight) / 2
    
    If aWidth < Width And aHeight < Height 
    
      If Direction & #PB_Sort_Descending
        
        DrawingMode(#PB_2DDrawing_Default)
        Line(aX, aY, aWidth, 1, Color)
        LineXY(aX, aY, aX + (aWidth / 2), aY + aHeight, Color)
        LineXY(aX + (aWidth / 2), aY + aHeight, aX + aWidth, aY, Color)
        FillArea(aX + (aWidth / 2), aY + dpiY(2), -1, Color)

      Else

        DrawingMode(#PB_2DDrawing_Default)
        Line(aX, aY + aHeight, aWidth, 1, Color)
        LineXY(aX, aY + aHeight, aX + (aWidth / 2), aY, Color)
        LineXY(aX + (aWidth / 2), aY, aX + aWidth, aY + aHeight, Color)
        FillArea(aX + (aWidth / 2), aY + aHeight - dpiY(2), -1, Color)
        
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure.i Button_(X.f, Y.f, Width.f, Height.f, Text.s, ColorFlag.i=#False, TextColor.i=#PB_Default, FontID.i=#PB_Default)
    Define.f textX, textY
    Define.i BackColor, BorderColor
    
    If TextColor = #PB_Default : TextColor = ListEx()\Row\Color\Front : EndIf
    
    If ColorFlag & #Click
      BackColor   = BlendColor_(ListEx()\Color\Focus, $FFFFFF, 20)
      BorderColor = ListEx()\Color\Focus
    ElseIf ColorFlag & #Focus
      BackColor   = BlendColor_(ListEx()\Color\Focus, $FFFFFF, 10)
      BorderColor = ListEx()\Color\Focus
    Else  
      BackColor   = ListEx()\Color\Button
      BorderColor = ListEx()\Color\ButtonBorder
    EndIf
    
    If FontID = #PB_Default
      DrawingFont(ListEx()\Row\FontID)
    ElseIf FontID
      DrawingFont(FontID)
    EndIf
    
    X + dpiX(2)
    Y + dpiY(3)
    Width  - dpiX(5)
    Height - dpiY(5)
    
    DrawingMode(#PB_2DDrawing_Default)
    Box(X, Y, Width, Height, BackColor)
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(X, Y, Width, Height, BorderColor)
    
    DrawingMode(#PB_2DDrawing_Transparent)
    textX = GetAlignOffset_(Text, Width, #Center)
    textY = (Height - TextHeight("Abc")) / 2
    DrawText(X + textX, Y + textY, Text, ListEx()\Rows()\Color\Front)
    
  EndProcedure
  
  Procedure.i CheckBox_(X.i, Y.i, Width.i, Height.i, boxWidth.i, BackColor.i, State.i)
    Define.i X1, X2, Y1, Y2
    Define.i bColor
    
    If boxWidth <= Width And boxWidth <= Height
      
      X + ((Width  - boxWidth) / 2)
      Y + ((Height - boxWidth) / 2) + 1
      
      If State & #Checked

        bColor = BlendColor_($424242, $A09E9E)
        
        X1 = X + 1
        X2 = X + boxWidth - 2
        Y1 = Y + 1
        Y2 = Y + boxWidth - 2
        
        LineXY(X1 + 1, Y1, X2 + 1, Y2, bColor)
        LineXY(X1 - 1, Y1, X2 - 1, Y2, bColor)
        LineXY(X2 + 1, Y1, X1 + 1, Y2, bColor)
        LineXY(X2 - 1, Y1, X1 - 1, Y2, bColor)
        LineXY(X2, Y1, X1, Y2, $424242)
        LineXY(X1, Y1, X2, Y2, $424242)
        
      ElseIf State & #Inbetween
        
        Box(X, Y, boxWidth, boxWidth, BlendColor_($424242, BackColor, 50))
        
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X + 2, Y + 2, boxWidth - 4, boxWidth - 4, BlendColor_($424242, BackColor, 5))
      Box(X + 1, Y + 1, boxWidth - 2, boxWidth - 2, BlendColor_($424242, BackColor, 25))
      Box(X, Y, boxWidth, boxWidth, $424242)
      
    EndIf
    
  EndProcedure
  
  
  Procedure   DrawProgressBar_(X.f, Y.f, Width.f, Height.f, State.i, Text.s, TextColor.i, Align.i)
    Define.f Factor
    Define.i pbWidth, pbHeight, textX, textY, Progress, Percent
    
    If State < ListEx()\ProgressBar\Minimum : State = ListEx()\ProgressBar\Minimum : EndIf
    If State > ListEx()\ProgressBar\Maximum : State = ListEx()\ProgressBar\Maximum : EndIf
    
    pbWidth  = Width  - dpiX(4)
    pbHeight = Height - dpiY(4)
    
    If State > ListEx()\ProgressBar\Minimum
      
      If State = ListEx()\ProgressBar\Maximum
        Progress = pbWidth
      Else
        Factor   = pbWidth / (ListEx()\ProgressBar\Maximum - ListEx()\ProgressBar\Minimum)
        Progress = (State - ListEx()\ProgressBar\Minimum) * Factor
      EndIf
      
      DrawingMode(#PB_2DDrawing_Default)
      Box(X + dpiX(2), Y + dpiY(2), Progress, pbHeight, ListEx()\Color\ProgressBar)

    EndIf
    
    Percent = ((State - ListEx()\ProgressBar\Minimum) * 100) /  (ListEx()\ProgressBar\Maximum - ListEx()\ProgressBar\Minimum)
    
    If Text
      
      Text  = ReplaceString(Text, #Progress$, Str(Percent) + "%")
      textX = GetAlignOffset_(Text, pbWidth, Align)
      textY = (Height - TextHeight(Text)) / 2
      
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(X + textX, Y + textY, Text, TextColor)
      
    ElseIf ListEx()\ProgressBar\Flags & #ShowPercent
      
      Text  = Str(Percent) + "%"
      textX = Progress - TextWidth(Text)
      textY = (Height - TextHeight(Text)) / 2
      
      If textX < dpiX(5) : textX = dpiX(5) : EndIf
      
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(X + textX, Y + textY, Text, TextColor)
      
    EndIf
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(X + dpiX(2),  Y + dpiY(2), pbWidth, pbHeight, ListEx()\Color\ButtonBorder)
    
  EndProcedure
  
  Procedure   DrawButton_(X.f, Y.f, Width.f, Height.f, Text.s, ColorFlag.i, TextColor.i, FontID.i, *Image.Image_Structure)
    Define.f colX, rowY, imgX, imgY
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      If FontID > 0
        Button_(X, Y, Width, Height, Text, ColorFlag, TextColor, FontID)
      Else
        Button_(X, Y, Width, Height, Text, ColorFlag, TextColor)
      EndIf
      
      If *Image\ID ;{ Image 
        
        If *Image\Flags & #Center
          imgX = (Width - *Image\Width) / 2
        ElseIf *Image\Flags & #Right
          imgX = Width - *Image\Width - dpiX(4)
        Else 
          imgX = dpiX(4)
        EndIf
        
        imgY  = (Height - *Image\Height) / 2 + dpiY(1)
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(*Image\ID, X + imgX, Y + imgY, *Image\Width, *Image\Height) 
        ;}
      EndIf
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   DrawLink_(X.f, Y.f, Width.f, Height.f, Text.s, LinkColor.i, Align.i, FontID.i, *Image.Image_Structure)
    Define.f colX, rowY, textX, textY, imgX, imgY
    
    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      UpdateRowY_()

      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        ClipOutput(X, Y, Width, Height)
      CompilerEndIf

      DrawingMode(#PB_2DDrawing_Default)
      Box(X + dpiX(1), Y + dpiY(1), Width - dpiX(2), Height - dpiY(2), BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10))
      
      If *Image\ID ;{ Image 
        
        If *Image\Flags & #Center
          imgX = (Width - *Image\Width) / 2
        ElseIf *Image\Flags & #Right
          imgX = Width - *Image\Width - dpiX(4)
        Else 
          imgX = dpiX(4)
        EndIf
        
        imgY  = (Height - *Image\Height) / 2 + dpiY(1)
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(*Image\ID, X + imgX + dpiX(1), Y + imgY + dpiY(1), *Image\Width - dpiX(2), *Image\Height - dpiY(2)) 
        
        If Text <> ""
          
          If FontID > 0
            DrawingFont(FontID)
          Else
            DrawingFont(ListEx()\Row\FontID)
          EndIf
          
          If *Image\Flags & #Center
            textX = GetAlignOffset_(Text, Width, #Center)
          ElseIf *Image\Flags & #Right
            textX = GetAlignOffset_(Text, Width, #Left)
          Else 
            textX = *Image\Width + dpiX(8)
          EndIf
          
          textY = (Height - TextHeight("Abc")) / 2 + dpiY(1)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(X + textX, Y + textY, Text, LinkColor)
          
        EndIf
        ;}
      Else         ;{ Text
        
        If Text <> ""
          
          If FontID > 0
            DrawingFont(FontID)
          Else
            DrawingFont(ListEx()\Row\FontID)
          EndIf
          
          textX = GetAlignOffset_(Text, Width, Align)
          textY = (Height - TextHeight("Abc")) / 2 + dpiX(1)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          DrawText(X + textX, Y + textY, Text, LinkColor)
        EndIf
        ;}
      EndIf 
      
      CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
        UnclipOutput()
      CompilerEndIf  
      
      StopDrawing()
    EndIf
    
  EndProcedure
  
  Procedure   Draw_()
    Define.f colX, rowY, textY, textX, colW0, colWidth, rowHeight, imgY, imgX
    Define.i Flags, imgFlags, FrontColor, FocusColor, RowColor, Mark, Row
    Define.s Key$, Text$
    
    AdjustScrollBars_()

    If StartDrawing(CanvasOutput(ListEx()\CanvasNum))
      
      PushListPosition(ListEx()\Rows())
      PushListPosition(ListEx()\Cols())
      
      colX = 0
      rowY = 0
      colWidth  = 0
      rowHeight = 0
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(colX, rowY, dpiX(GadgetWidth(ListEx()\CanvasNum)), dpiY(GadgetHeight(ListEx()\CanvasNum)), ListEx()\Color\Canvas)
      ;}

      colX     = ListEx()\Size\X    - ListEx()\Col\OffsetX
      colWidth = ListEx()\Size\Cols - ListEx()\Col\OffsetX
      
      ;{ _____ Header _____
      If ListEx()\Flags & #NoRowHeader
        rowY = ListEx()\Size\Y
      Else
        
        DrawingFont(ListEx()\Header\FontID)
        
        textY = (ListEx()\Header\Height - TextHeight("Abc")) / 2 + 0.5
        
        DrawingMode(#PB_2DDrawing_Default)
        Box(colX, rowY, ListEx()\Size\Cols, ListEx()\Header\Height, ListEx()\Color\HeaderBack)
        
        ForEach ListEx()\Cols()
          
          If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
          
          If CurrentColumn_() = ListEx()\Sort\Column And ListEx()\Cols()\Header\Sort & #SortArrows
            Arrow_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Header\Height, ListEx()\Cols()\Header\Direction) 
          EndIf
          
          If ListEx()\Cols()\Header\Flags & #Image
            
            imgFlags = ListEx()\Cols()\Header\Image\Flags
            
            If imgFlags & #Center
              imgX  = (ListEx()\Cols()\Width - ListEx()\Cols()\Header\Image\Width) / 2
            ElseIf imgFlags & #Right
              imgX  =  ListEx()\Cols()\Width - ListEx()\Cols()\Header\Image\Width - dpiX(4)
            Else 
              imgX = dpiX(4)
            EndIf

            imgY  = (ListEx()\Header\Height - ListEx()\Cols()\Header\Image\Height) / 2 + dpiY(1)
          
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            DrawImage(ListEx()\Cols()\Header\Image\ID, colX + imgX, rowY + imgY, ListEx()\Cols()\Header\Image\Width, ListEx()\Cols()\Header\Image\Height) 

          EndIf
          
          If ListEx()\Cols()\Header\Titel
            textX = GetAlignOffset_(ListEx()\Cols()\Header\Titel, ListEx()\Cols()\Width, ListEx()\Header\Align)
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(colX + textX, rowY + textY, ListEx()\Cols()\Header\Titel, ListEx()\Color\HeaderFront)
          EndIf
          
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(colX - 1, rowY, ListEx()\Cols()\Width + 1, ListEx()\Header\Height + 1, ListEx()\Color\HeaderGrid)
          colX + ListEx()\Cols()\Width
          
        Next
      
        rowY = ListEx()\Size\Y + ListEx()\Header\Height
      EndIf ;}
      
      DrawingFont(ListEx()\Row\FontID)

      ;{ _____ Rows _____
      ListEx()\Row\OffSetY = 0

      ForEach ListEx()\Rows()

        If ListIndex(ListEx()\Rows()) < ListEx()\Row\Offset
          ListEx()\Row\OffSetY + ListEx()\Rows()\Height
          Continue
        EndIf
        
        If ListEx()\Rows()\FontID : DrawingFont(ListEx()\Rows()\FontID) : EndIf
        
        rowHeight + ListEx()\Rows()\Height
        
        colX = ListEx()\Size\X - ListEx()\Col\OffsetX
        
        DrawingMode(#PB_2DDrawing_Default)
        
        Row = ListIndex(ListEx()\Rows())

        ;{ Focus row
        FocusColor = BlendColor_(ListEx()\Color\Focus, ListEx()\Color\Back, 10)
        If ListEx()\Flags & #MultiSelect And ListEx()\Strg = #True
          If ListEx()\Rows()\State & #Selected
            Box(colX, rowY, ListEx()\Size\Cols, ListEx()\Rows()\Height, FocusColor)
          EndIf
        ElseIf ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
          Box(colX, rowY, ListEx()\Size\Cols, ListEx()\Rows()\Height, FocusColor)
        ElseIf ListEx()\Color\Back <> ListEx()\Color\AlternateRow
          If Mod(ListIndex(ListEx()\Rows()), 2)
            Box(colX, rowY, ListEx()\Size\Cols, ListEx()\Rows()\Height, ListEx()\Color\AlternateRow)
          Else
            Box(colX, rowY, ListEx()\Size\Cols, ListEx()\Rows()\Height, ListEx()\Color\Back)
          EndIf 
        Else
          Box(colX, rowY, ListEx()\Size\Cols, ListEx()\Rows()\Height, ListEx()\Color\Back)
        EndIf ;}
        
        ;{ Columns of current row
        ForEach ListEx()\Cols()
          
          If ListEx()\Cols()\Flags & #Hide : Continue : EndIf
          
          Key$ = ListEx()\Cols()\Key
          If Key$ = "" : Key$ = Str(ListIndex(ListEx()\Cols())) : EndIf
          
          If ListEx()\Cols()\FontID
            DrawingFont(ListEx()\Cols()\FontID)
          Else
            DrawingFont(ListEx()\Rows()\FontID)
          EndIf
          
          If CurrentColumn_() = 0 And ListEx()\Flags & #NumberedColumn ;{ Numbering column 0
            
            Text$    = Str(ListIndex(ListEx()\Rows()) + 1)
            textX    = GetAlignOffset_(Text$, ListEx()\Cols()\Width, #Right)
            textY    = (ListEx()\Rows()\Height - TextHeight("Abc")) / 2 + dpiY(1)
            colW0    = ListEx()\Cols()\Width
            
            DrawingMode(#PB_2DDrawing_Default)
            Box(colX, rowY, ListEx()\Cols()\Width, ListEx()\Row\Height, ListEx()\Color\HeaderBack)
            
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(colX + textX, rowY + textY, Text$, ListEx()\Color\HeaderFront, ListEx()\Color\HeaderBack)
            
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height + dpiY(1), ListEx()\Color\HeaderGrid)
            ;}
          Else  
            
            Flags = ListEx()\Rows()\Column(Key$)\Flags
            
            If Flags & #BackColor                       ;{ Colored cell background
              If ListIndex(ListEx()\Rows()) <> ListEx()\Row\Current
                DrawingMode(#PB_2DDrawing_Default)
                Box(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\Color\Back)  
              EndIf
            EndIf ;}
            
            If ListEx()\Cols()\Flags & #CheckBoxes      ;{ CheckBox
              
              If ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
                CheckBox_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, TextHeight("X") - dpiY(3), FocusColor, ListEx()\Rows()\Column(Key$)\State)
              Else
                CheckBox_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, TextHeight("X") - dpiY(3), ListEx()\Color\Back, ListEx()\Rows()\Column(Key$)\State)
              EndIf
            
            ElseIf ListEx()\Flags & #CheckBoxes And CurrentColumn_() = ListEx()\Col\CheckBoxes
              
              If ListEx()\Focus And ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
                CheckBox_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, TextHeight("X") - dpiY(3), FocusColor, ListEx()\Rows()\State)
              Else
                CheckBox_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, TextHeight("X") - dpiY(3), ListEx()\Color\Back,  ListEx()\Rows()\State)
              EndIf
              ;}
            ElseIf ListEx()\Cols()\Flags & #Buttons     ;{ Button
              
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                ClipOutput(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height)
              CompilerEndIf
              
              If ListEx()\Rows()\Column(Key$)\Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
              
              If ListEx()\Rows()\Column(Key$)\Flags & #FrontColor
                Button_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\Value, #False, ListEx()\Rows()\Column(Key$)\Color\Front)
              Else
                Button_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\Value, #False, ListEx()\Rows()\Color\Front)
              EndIf
              
              If Flags & #Image
                
                imgFlags = ListEx()\Rows()\Column(Key$)\Image\Flags
              
                If imgFlags & #Center
                  imgX  = (ListEx()\Cols()\Width - ListEx()\Rows()\Column(Key$)\Image\Width) / 2
                ElseIf imgFlags & #Right
                  imgX  = ListEx()\Cols()\Width - ListEx()\Rows()\Column(Key$)\Image\Width - dpiX(4)
                Else 
                  imgX = dpiX(4)
                EndIf

                imgY = (ListEx()\Rows()\Height - ListEx()\Rows()\Column(Key$)\Image\Height) / 2 + dpiY(1)
              
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                DrawImage(ListEx()\Rows()\Column(Key$)\Image\ID, colX + imgX, rowY + imgY, ListEx()\Rows()\Column(Key$)\Image\Width, ListEx()\Rows()\Column(Key$)\Image\Height) 
                
              EndIf
              
              If ListEx()\Rows()\Column(Key$)\Flags & #CellFont : DrawingFont(ListEx()\Row\FontID) : EndIf
              
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                UnclipOutput()
              CompilerEndIf  
              ;}
            ElseIf ListEx()\Cols()\Flags & #ProgressBar ;{ ProgressBar
              
              If ListEx()\Rows()\Column(Key$)\Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
              
              If ListEx()\Rows()\Column(Key$)\Flags & #FrontColor
                DrawProgressBar_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\State, ListEx()\Rows()\Column(Key$)\Value, ListEx()\Rows()\Column(Key$)\Color\Front, ListEx()\Cols()\Align)
              Else
                DrawProgressBar_(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height, ListEx()\Rows()\Column(Key$)\State, ListEx()\Rows()\Column(Key$)\Value, ListEx()\Rows()\Color\Front, ListEx()\Cols()\Align)
              EndIf
              ;}
            ElseIf Flags & #Image                       ;{ Image
              
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                ClipOutput(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height)
              CompilerEndIf
              
              imgFlags = ListEx()\Rows()\Column(Key$)\Image\Flags
              
              If imgFlags & #Center
                imgX  = (ListEx()\Cols()\Width - ListEx()\Rows()\Column(Key$)\Image\Width) / 2
              ElseIf imgFlags & #Right
                imgX  = ListEx()\Cols()\Width - ListEx()\Rows()\Column(Key$)\Image\Width - dpiX(4)
              Else 
                imgX = dpiX(4)
              EndIf

              imgY  = (ListEx()\Rows()\Height - ListEx()\Rows()\Column(Key$)\Image\Height) / 2 + dpiY(1)
              
              DrawingMode(#PB_2DDrawing_AlphaBlend)
              DrawImage(ListEx()\Rows()\Column(Key$)\Image\ID, colX + imgX, rowY + imgY, ListEx()\Rows()\Column(Key$)\Image\Width, ListEx()\Rows()\Column(Key$)\Image\Height) 
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              If Text$ <> ""
                
                If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
                
                textY = (ListEx()\Rows()\Height - TextHeight("Abc")) / 2 + dpiY(1)
                
                If imgFlags & #Center
                  textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, #Center)
                ElseIf imgFlags & #Right
                  textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, #Left)
                Else 
                  textX = ListEx()\Rows()\Column(Key$)\Image\Width + dpiX(8)
                EndIf
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                If ListEx()\Cols()\Flags & #Links
                  FrontColor = ListEx()\Color\Link
                ElseIf ListEx()\Rows()\Column(Key$)\Flags & #FrontColor
                  FrontColor = ListEx()\Rows()\Column(Key$)\Color\Front
                Else
                  FrontColor = ListEx()\Color\Front
                EndIf
                
                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          FrontColor = ListEx()\Mark()\Color1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          FrontColor = ListEx()\Mark()\Color2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                DrawText(colX + textX, rowY + textY, Text$, FrontColor)
                
                If Flags & #CellFont : DrawingFont(ListEx()\Row\FontID) : EndIf
                
              EndIf  
              CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                UnclipOutput()
              CompilerEndIf
              ;}
            Else                                        ;{ Text
              
              Text$ = ListEx()\Rows()\Column(Key$)\Value
              
              If Text$ <> ""
                
                CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                  ClipOutput(colX, rowY, ListEx()\Cols()\Width, ListEx()\Rows()\Height) 
                CompilerEndIf
                
                If Flags & #CellFont : DrawingFont(ListEx()\Rows()\Column(Key$)\FontID) : EndIf
                
                textY = (ListEx()\Rows()\Height - TextHeight("Abc")) / 2 + dpiY(1)
                
                DrawingMode(#PB_2DDrawing_Transparent)
                
                textX = GetAlignOffset_(Text$, ListEx()\Cols()\Width, ListEx()\Cols()\Align)
                
                If ListEx()\Cols()\Flags & #Links
                  FrontColor = ListEx()\Color\Link
                ElseIf ListEx()\Rows()\Column(Key$)\Flags & #FrontColor
                  FrontColor = ListEx()\Rows()\Column(Key$)\Color\Front
                Else
                  FrontColor = ListEx()\Color\Front
                EndIf
                
                CompilerIf #Enable_MarkContent
                  
                  If ListEx()\Cols()\Flags & #MarkContent
                    If FindMapElement(ListEx()\Mark(), ListEx()\Cols()\Key)
                      Select IsMarked_(Text$, ListEx()\Mark()\Term, ListEx()\Cols()\Flags)
                        Case #Condition1
                          FrontColor = ListEx()\Mark()\Color1
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                        Case #Condition2
                          FrontColor = ListEx()\Mark()\Color2
                          If ListEx()\Mark()\FontID <> #PB_Default : DrawingFont(ListEx()\Mark()\FontID) : EndIf
                      EndSelect
                    EndIf
                  EndIf
                  
                CompilerEndIf
                
                DrawText(colX + textX, rowY + textY, Text$, FrontColor)
                
                CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS
                  UnclipOutput()
                CompilerEndIf
                
              EndIf
              ;}  
            EndIf
          
            If ListEx()\Flags & #GridLines
              DrawingMode(#PB_2DDrawing_Outlined)
              Box(colX - dpiX(1), rowY, ListEx()\Cols()\Width + dpiX(1), ListEx()\Rows()\Height + dpiY(1), ListEx()\Color\Grid)
            EndIf
            
          EndIf
          
          colX + ListEx()\Cols()\Width
          
        Next ;}
        
        rowY + ListEx()\Row\Height
        
        If rowY > ListEx()\Size\Height : Break : EndIf
        
      Next ;}
      
      colX = ListEx()\Size\X - ListEx()\Col\OffsetX
      rowY = ListEx()\Size\Y
      
      DrawingMode(#PB_2DDrawing_Default)
      
      Line(0, ListEx()\Header\Height, colWidth, dpiY(1), ListEx()\Color\HeaderGrid) 
      
      ;{ _____ ScrollBars ______
      If ListEx()\VScroll\Hide = #False
        Box(dpiX(GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width), 0, dpiX(#ScrollBar_Width + 1), dpiY(GadgetHeight(ListEx()\CanvasNum)), ListEx()\Color\ScrollBar)
      EndIf
      
      If  ListEx()\HScroll\Hide = #False
        Box(0, dpiY(GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width), dpiX(GadgetWidth(ListEx()\CanvasNum)), dpiY(#ScrollBar_Width + 1), ListEx()\Color\ScrollBar)
      EndIf ;}
      
      ;{ _____ Border _____
      If ListEx()\Flags & #NumberedColumn
        Line(colX + colW0 - dpiY(1), ListEx()\Header\Height, dpiY(1), rowHeight + dpiY(1), ListEx()\Color\HeaderGrid)
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      
      Box(0, 0, dpiX(GadgetWidth(ListEx()\CanvasNum)), dpiY(GadgetHeight(ListEx()\CanvasNum)), ListEx()\Color\HeaderGrid)

      ;}
      
      PopListPosition(ListEx()\Cols())
      PopListPosition(ListEx()\Rows())

      StopDrawing()
    EndIf  
  
  EndProcedure
  
  
  ;- __________ ScrollBars _________
  
  Procedure   AdjustScrollBars_(Force.i=#False)
    Define.f WidthOffset
    Define.i PageRows

    If ListEx()\AutoResize\Column <> #PB_Ignore ;{ Resize column
      
      If ListEx()\Size\Cols > ListEx()\Size\Width
        
        If SelectElement(ListEx()\Cols(), ListEx()\AutoResize\Column)
          
          WidthOffset = ListEx()\Size\Cols - ListEx()\Size\Width
          If ListEx()\Cols()\Width - WidthOffset >= ListEx()\AutoResize\MinWidth
            ListEx()\Cols()\Width  - WidthOffset
            ListEx()\Size\Cols     - WidthOffset
            ListEx()\Size\Height   = dpiY(GadgetHeight(ListEx()\CanvasNum))
            ListEx()\HScroll\Hide  = #True
            UpdateColumnX_()
            HideGadget(ListEx()\HScrollNum, #True) 
            ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
          Else  
            WidthOffset = ListEx()\AutoResize\Width - ListEx()\Cols()\Width
            ListEx()\Cols()\Width = ListEx()\AutoResize\Width
            UpdateColumnX_()
          EndIf
          
        EndIf
        
      ElseIf ListEx()\Size\Cols < ListEx()\Size\Width
        
        If SelectElement(ListEx()\Cols(), ListEx()\AutoResize\Column)
          
          WidthOffset = ListEx()\Size\Width - ListEx()\Size\Cols
          
          If ListEx()\AutoResize\maxWidth > #PB_Default And ListEx()\Cols()\Width + WidthOffset > ListEx()\AutoResize\maxWidth
            ListEx()\Cols()\Width = ListEx()\AutoResize\maxWidth
          Else  
            ListEx()\Cols()\Width + WidthOffset
          EndIf
          
          UpdateColumnX_()
          
        EndIf
        
      EndIf
      ;}
    EndIf
    
    If IsGadget(ListEx()\HScrollNum) ;{ Horizontal Scrollbar
      
      If ListEx()\Size\Cols > ListEx()\Size\Width
        
        If ListEx()\HScroll\Hide
          ListEx()\Size\Height = dpiY(GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width)
          If ListEx()\VScroll\Hide
            ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
          Else
            ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
          EndIf
          HideGadget(ListEx()\HScrollNum, #False)
          ListEx()\HScroll\Hide = #False
        EndIf
        
        SetGadgetAttribute(ListEx()\HScrollNum, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(ListEx()\HScrollNum, #PB_ScrollBar_Maximum,    ListEx()\Size\Cols)
        SetGadgetAttribute(ListEx()\HScrollNum, #PB_ScrollBar_PageLength, ListEx()\Size\Width)
        
        ListEx()\HScroll\MinPos = 0
        ListEx()\HScroll\MaxPos = ListEx()\Size\Cols - ListEx()\Size\Width + 1
        
        If ListEx()\HScroll\Hide = #False
          If dpiX(GadgetWidth(ListEx()\HScrollNum)) < ListEx()\Size\Width - dpiX(2)
            If ListEx()\VScroll\Hide
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
            Else  
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
            EndIf  
          ElseIf dpiX(GadgetWidth(ListEx()\HScrollNum)) > ListEx()\Size\Width - dpiX(1)
            If ListEx()\VScroll\Hide
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
            Else  
              ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
            EndIf 
          EndIf
          
        EndIf
        
      ElseIf Not ListEx()\HScroll\Hide And ListEx()\Size\Cols < ListEx()\Size\Width
        
        ListEx()\Size\Height = dpiY(GadgetHeight(ListEx()\CanvasNum))
        ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
        HideGadget(ListEx()\HScrollNum, #True)
        ListEx()\HScroll\Hide = #True
        
      EndIf
      ;}
    EndIf
    
    If IsGadget(ListEx()\VScrollNum) ;{ Vertical ScrollBar
      
      If ListEx()\Size\Rows > (ListEx()\Size\Height - ListEx()\Header\Height)
      
        PageRows = GetPageRows_()
        
        If ListEx()\VScroll\Hide Or Force
          ListEx()\Size\Width = dpiX(GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width)
          If ListEx()\HScroll\Hide
            ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
          Else
            ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
          EndIf
          HideGadget(ListEx()\VScrollNum, #False)
          ListEx()\VScroll\Hide = #False
        EndIf
        
        SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_Minimum,    0)
        SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_Maximum,    ListEx()\Row\Number - 1)
        SetGadgetAttribute(ListEx()\VScrollNum, #PB_ScrollBar_PageLength, PageRows)
        
        ListEx()\VScroll\MinPos = 0
        ListEx()\VScroll\MaxPos = ListEx()\Row\Number - PageRows + 2
        
        If ListEx()\VScroll\Hide = #False
          If dpiY(GadgetHeight(ListEx()\VScrollNum)) < ListEx()\Size\Height - dpiY(2)
            
            If ListEx()\HScroll\Hide
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
            Else
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
            EndIf
            
          ElseIf dpiY(GadgetHeight(ListEx()\VScrollNum)) > ListEx()\Size\Height
            
            If ListEx()\HScroll\Hide
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
            Else
              ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
            EndIf
            
          EndIf
          
        EndIf
        
      ElseIf Not ListEx()\VScroll\Hide And ListEx()\Size\Rows < (ListEx()\Size\Height - ListEx()\Header\Height)
        
        ListEx()\Size\Width = dpiX(GadgetWidth(ListEx()\CanvasNum))
        ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 2)
        HideGadget(ListEx()\VScrollNum, #True)
        ListEx()\VScroll\Hide = #True
        
      EndIf
      ;}
    EndIf
    
  EndProcedure
  
  Procedure   SetHScrollPosition_()
    Define.f ScrollPos
    
    If IsGadget(ListEx()\HScrollNum)
      
      ScrollPos = ListEx()\Col\OffsetX
      If ScrollPos < ListEx()\HScroll\MinPos : ScrollPos = ListEx()\HScroll\MinPos : EndIf
      
      ListEx()\HScroll\Position = ScrollPos
      
      SetGadgetState(ListEx()\HScrollNum, ScrollPos)
      
    EndIf
    
  EndProcedure 
  
  Procedure   SetVScrollPosition_()
    Define.f ScrollPos
    
    If IsGadget(ListEx()\VScrollNum)
      
      ScrollPos = ListEx()\Row\Offset
      If ScrollPos > ListEx()\VScroll\MaxPos : ScrollPos = ListEx()\VScroll\MaxPos : EndIf
      
      ListEx()\VScroll\Position = ScrollPos
      
      SetGadgetState(ListEx()\VScrollNum, ScrollPos)
      
    EndIf
    
  EndProcedure  
  
  
  Procedure   SetVisible_(Row.i)
    Define.i PageRows

    PageRows = GetPageRows_() - 1

    If Row > ListEx()\Row\Offset + PageRows
      ListEx()\Row\Offset = Row - PageRows
      SetVScrollPosition_()
    ElseIf Row < ListEx()\Row\Offset
      ListEx()\Row\Offset = Row
      SetVScrollPosition_()
    EndIf
    
  EndProcedure
  
  Procedure   SetFocus_(Row.i, Column.i=#PB_Default)
    
    If Row > ListSize(ListEx()\Rows()) : Row = ListSize(ListEx()\Rows()) - 1 : EndIf
    If Row < 0 : Row = 0 : EndIf 
    
    If Column = #PB_Default
      
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Focus = #True
        ListEx()\Row\Current = Row
        ListEx()\Row\Focus   = ListEx()\Row\Current
        SetVisible_(ListEx()\Row\Focus)
      EndIf
      
    Else
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Focus = #True
          ListEx()\Row\Current = Row
          ListEx()\Row\Focus   = ListEx()\Row\Current
          SetVisible_(ListEx()\Row\Focus)
        EndIf 
      EndIf 
      
    EndIf
    
  EndProcedure  
  
  
  ;- _____ Sorting _____
  
  Procedure SetSortFocus_()
    If ListIndex(ListEx()\Rows()) = ListEx()\Row\Focus
      ListEx()\Rows()\Flags | #Focus
    Else
      ListEx()\Rows()\Flags & ~#Focus
    EndIf
  EndProcedure
  
  Procedure.f GetCashFloat_(String.s, Currency.s)

    String = ReplaceString(String, ",", ".")
    String = RemoveString(String, "")
    
    ProcedureReturn ValF(Trim(String)) 
  EndProcedure
  
  Procedure.s SortDEU_(Text.s, Flags.i=#Lexikon) ; german charakters (DIN 5007)
    
    If Flags & #Namen
      Text = ReplaceString(Text, "Ä", "Ae")
      Text = ReplaceString(Text, "Ö", "Oe")
      Text = ReplaceString(Text, "Ü", "Ue")
      Text = ReplaceString(Text, "ä", "ae")
      Text = ReplaceString(Text, "ö", "oe")
      Text = ReplaceString(Text, "ü", "ue")
      Text = ReplaceString(Text, "ß", "ss")
    ElseIf Flags & #Lexikon Or Flags & #Deutsch
      Text = ReplaceString(Text, "Ä", "A")
      Text = ReplaceString(Text, "Ö", "O")
      Text = ReplaceString(Text, "Ü", "U")
      Text = ReplaceString(Text, "ä", "a")
      Text = ReplaceString(Text, "ö", "o")
      Text = ReplaceString(Text, "ü", "u")
      Text = ReplaceString(Text, "ß", "ss")
    EndIf
    
    ProcedureReturn Text
  EndProcedure 
  
  Procedure   SortColumn_()
    Define.s String$
    
    If ListEx()\Sort\Flags & #SortNumber       ;{ Sort number (integer)
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\iSort = Val(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
        SetSortFocus_()
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\iSort), #PB_Integer)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortFloat    ;{ Sort number (float)
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\fSort = ValF(ReplaceString(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value, ",", "."))
        SetSortFocus_()
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\fSort), #PB_Float)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortDate     ;{ Sort date   (integer)

      If ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
        String$ = ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
      Else  
        String$ = ListEx()\Date\Mask
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\iSort = ParseDate(String$, ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
        SetSortFocus_()
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\iSort), #PB_Integer)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortBirthday ;{ Sort birthday   (string)

      If ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
        String$ = ListEx()\Date\Column(ListEx()\Sort\Label)\Mask
      Else  
        String$ = ListEx()\Date\Mask
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\Sort = FormatDate("%mm%dd", ParseDate(String$, ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value))
        SetSortFocus_()
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\Sort), #PB_String)
      ;}  
    ElseIf ListEx()\Sort\Flags & #SortCash     ;{ Sort cash   (float)

      String$ = ListEx()\Country\Currency
      If SelectElement(ListEx()\Cols(), ListEx()\Sort\Column)
        If ListEx()\Cols()\Currency : String$ = ListEx()\Cols()\Currency : EndIf
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\fSort = GetCashFloat_(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value, String$)
        SetSortFocus_()
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\fSort), #PB_Float)
      ;}
    ElseIf ListEx()\Sort\Flags & #SortTime     ;{ Sort time   (integer)
      
      String$ = ListEx()\Country\TimeMask
      If SelectElement(ListEx()\Cols(), ListEx()\Sort\Column)
        If ListEx()\Cols()\Mask : String$ = ListEx()\Cols()\Mask : EndIf
      EndIf
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\iSort = ParseDate(String$, ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
        SetSortFocus_()
      Next
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\iSort), #PB_Integer)
      ;}
    Else                                       ;{ Sort text   (string)
      
      ForEach ListEx()\Rows()
        If ListEx()\Sort\Flags & #Deutsch
          ListEx()\Rows()\Sort = SortDEU_(ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value)
        Else
          ListEx()\Rows()\Sort = ListEx()\Rows()\Column(ListEx()\Sort\Label)\Value
        EndIf
        SetSortFocus_()
      Next  
      
      SortStructuredList(ListEx()\Rows(), ListEx()\Sort\Direction, OffsetOf(ListEx_Rows_Structure\Sort), #PB_String)
      ;}
    EndIf
    
    ; Determine original focus line
    If ListEx()\Focus And ListEx()\Row\Focus <> #NotValid
      
      ForEach ListEx()\Rows()
        If ListEx()\Rows()\Flags & #Focus
          ListEx()\Row\Focus = ListIndex(ListEx()\Rows())
          SetVisible_(ListEx()\Row\Focus)
          ListEx()\Rows()\Flags & ~#Focus
          Break
        EndIf
      Next 
      
    EndIf 
    
  EndProcedure
  
  
  ;- __________ Events __________
  

  Procedure   UpdateEventData_(Type.i, Row.i=#NotValid, Column.i=#NotValid, Value.s="", State.i=#NotValid, ID.s="")
    
    ListEx()\Event\Type   = Type
    ListEx()\Event\Row    = Row
    ListEx()\Event\Column = Column
    ListEx()\Event\Value  = Value
    ListEx()\Event\State  = State
    ListEx()\Event\ID     = ID
    
  EndProcedure    
  
  Procedure   LoadComboItems_(Column.i)
    
    If IsGadget(ListEx()\ComboNum)
      
      ClearGadgetItems(ListEx()\ComboNum)
      
      If SelectElement(ListEx()\Cols(), Column)
        
        If FindMapElement(ListEx()\ComboBox\Column(), ListEx()\Cols()\Key)
          
          ForEach ListEx()\ComboBox\Column()\Items()
            AddGadgetItem(ListEx()\ComboNum, -1, ListEx()\ComboBox\Column()\Items())
          Next
          
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   ManageEditGadgets_(Row.i, Column.i)
    Define.f X, Y
    Define.i Date
    Define.s Value$, Key$, Mask$
    
    If ListEx()\String\Flag   = #True : ProcedureReturn #False : EndIf
    If ListEx()\ComboBox\Flag = #True : ProcedureReturn #False : EndIf
    If ListEx()\Date\Flag     = #True : ProcedureReturn #False : EndIf
    
    If SelectElement(ListEx()\Rows(), Row)
      If SelectElement(ListEx()\Cols(), Column)
        
        Y = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
        X = ListEx()\Cols()\X - ListEx()\Col\OffsetX
        
        Key$ = ListEx()\Cols()\Key
        
        If ListEx()\Cols()\Flags & #Strings        ;{ Editable Cells

          If IsGadget(ListEx()\StringNum)
            
            If ListEx()\Editable
              ResizeGadget(ListEx()\StringNum, DesktopUnscaledX(X), DesktopUnscaledY(Y) + 1, DesktopUnscaledX(ListEx()\Cols()\Width), DesktopUnscaledY(ListEx()\Rows()\Height) - 1)
              SetGadgetText(ListEx()\StringNum, ListEx()\Rows()\Column(Key$)\Value)
              If ListEx()\Cols()\FontID
                SetGadgetFont(ListEx()\StringNum, ListEx()\Cols()\FontID)
              Else
                SetGadgetFont(ListEx()\StringNum, ListEx()\Row\FontID)
              EndIf
              
              ListEx()\String\Row    = Row
              ListEx()\String\Col    = Column
              ListEx()\String\X      = ListEx()\Cols()\X
              ListEx()\String\Y      = ListEx()\Rows()\Y
              ListEx()\String\Width  = ListEx()\Cols()\Width
              ListEx()\String\Height = ListEx()\Rows()\Height
              ListEx()\String\Label  = ListEx()\Cols()\Key
              ListEx()\String\Flag   = #True

              BindShortcuts_(#True)
              HideGadget(ListEx()\StringNum, #False)
              
              SetActiveGadget(ListEx()\StringNum) 
            EndIf
            
          EndIf
          ;}
        ElseIf ListEx()\Cols()\Flags & #ComboBoxes ;{ ComboCoxes

          If IsGadget(ListEx()\ComboNum)
            
            If ListEx()\Editable
              
              ResizeGadget(ListEx()\ComboNum, DesktopUnscaledX(X), DesktopUnscaledY(Y) + 1, DesktopUnscaledX(ListEx()\Cols()\Width) - 1,  DesktopUnscaledY(ListEx()\Rows()\Height))
              LoadComboItems_(Column)
              SetGadgetText(ListEx()\ComboNum, ListEx()\Rows()\Column(Key$)\Value)
              ListEx()\ComboBox\Row    = Row
              ListEx()\ComboBox\Col    = Column
              ListEx()\ComboBox\X      = ListEx()\Cols()\X
              ListEx()\ComboBox\Y      = ListEx()\Rows()\Y
              ListEx()\ComboBox\Width  = ListEx()\Cols()\Width
              ListEx()\ComboBox\Height = ListEx()\Rows()\Height
              ListEx()\ComboBox\Label  = ListEx()\Cols()\Key
              ListEx()\ComboBox\Flag   = #True
              
              BindShortcuts_(#True)
              HideGadget(ListEx()\ComboNum, #False)
              
              SetActiveGadget(ListEx()\ComboNum)
              
            EndIf  
          
          EndIf
          ;}
        ElseIf ListEx()\Cols()\Flags & #Dates      ;{ DateGadget

          If IsGadget(ListEx()\DateNum)
            
            If ListEx()\Editable
              
              Mask$ = ListEx()\Date\Mask
              
              If FindMapElement(ListEx()\Date\Column(), Key$)
                If ListEx()\Date\Column()\Min  : SetGadgetAttribute(ListEx()\DateNum, #PB_Date_Minimum, ListEx()\Date\Column()\Min) : EndIf
                If ListEx()\Date\Column()\Max  : SetGadgetAttribute(ListEx()\DateNum, #PB_Date_Maximum, ListEx()\Date\Column()\Max) : EndIf
                If ListEx()\Date\Column()\Mask : Mask$ = ListEx()\Date\Column()\Mask : EndIf
              EndIf

              ResizeGadget(ListEx()\DateNum, DesktopUnscaledX(X), DesktopUnscaledX(Y), DesktopUnscaledX(ListEx()\Cols()\Width) - 1,  DesktopUnscaledY(ListEx()\Rows()\Height))
              SetGadgetText(ListEx()\DateNum, Mask$)

              Value$ = ListEx()\Rows()\Column(Key$)\Value
              If Value$
                Date = ParseDate(Mask$, Value$)
                If Date > 0 : SetGadgetState(ListEx()\DateNum, Date) : EndIf
              EndIf

              ListEx()\Date\Row    = Row
              ListEx()\Date\Col    = Column
              ListEx()\Date\X      = ListEx()\Cols()\X
              ListEx()\Date\Y      = ListEx()\Rows()\Y
              ListEx()\Date\Width  = ListEx()\Cols()\Width
              ListEx()\Date\Height = ListEx()\Rows()\Height
              ListEx()\Date\Label  = ListEx()\Cols()\Key
              ListEx()\Date\Flag   = #True
            
              BindShortcuts_(#True)
              HideGadget(ListEx()\DateNum, #False)
              
              SetActiveGadget(ListEx()\DateNum)
              
            EndIf  
         
          EndIf
          ;}
        EndIf  

      EndIf
    EndIf
    
  EndProcedure
  
  Procedure   ScrollEditGadgets_() 
    Define.f X, Y
    
    If ListEx()\String\Flag
      If IsGadget(ListEx()\StringNum)
        X = ListEx()\String\X - ListEx()\Col\OffsetX
        Y = ListEx()\String\Y - ListEx()\Row\OffSetY
        ResizeGadget(ListEx()\StringNum, DesktopUnscaledX(X), DesktopUnscaledY(Y) + 1, #PB_Ignore, #PB_Ignore)
        If X + ListEx()\String\Width > ListEx()\Size\Width Or Y + ListEx()\String\Height > ListEx()\Size\Height Or Y < ListEx()\Header\Height
          HideGadget(ListEx()\StringNum, #True) 
        Else  
          HideGadget(ListEx()\StringNum, #False)
        EndIf
      EndIf
    EndIf
    
    If ListEx()\ComboBox\Flag
      If IsGadget(ListEx()\ComboNum)
        X = ListEx()\ComboBox\X - ListEx()\Col\OffsetX
        Y = ListEx()\ComboBox\Y - ListEx()\Row\OffSetY
        ResizeGadget(ListEx()\ComboNum, DesktopUnscaledX(X), DesktopUnscaledY(Y) + 1, #PB_Ignore, #PB_Ignore)
        If X + ListEx()\ComboBox\Width > ListEx()\Size\Width Or Y + ListEx()\ComboBox\Height > ListEx()\Size\Height Or Y < ListEx()\Header\Height
          HideGadget(ListEx()\ComboNum, #True) 
        Else  
          HideGadget(ListEx()\ComboNum, #False)
        EndIf
      EndIf
    EndIf
    
    If ListEx()\Date\Flag
      If IsGadget(ListEx()\DateNum)
        X = ListEx()\Date\X - ListEx()\Col\OffsetX
        Y = ListEx()\Date\Y - ListEx()\Row\OffSetY
        ResizeGadget(ListEx()\DateNum, DesktopUnscaledX(X), DesktopUnscaledY(Y) + dpiY(1), #PB_Ignore, #PB_Ignore)
        If X + ListEx()\Date\Width > ListEx()\Size\Width Or Y + ListEx()\Date\Height > ListEx()\Size\Height Or Y < ListEx()\Header\Height
          HideGadget(ListEx()\DateNum, #True) 
        Else  
          HideGadget(ListEx()\DateNum, #False)
        EndIf
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i NextEditColumn_(Column.i)
    
    If SelectElement(ListEx()\Cols(), Column)
      
      While NextElement(ListEx()\Cols())
        
        If ListEx()\Cols()\Flags & #Strings
          ProcedureReturn ListIndex(ListEx()\Cols())
        ElseIf ListEx()\Cols()\Flags & #ComboBoxes
          ProcedureReturn ListIndex(ListEx()\Cols())
        ElseIf ListEx()\Cols()\Flags & #Dates
          ProcedureReturn ListIndex(ListEx()\Cols())
        EndIf
        
      Wend
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  Procedure.i PreviousEditColumn_(Column.i)
    
    If SelectElement(ListEx()\Cols(), Column)
      
      While PreviousElement(ListEx()\Cols())
        
        If ListEx()\Cols()\Flags & #Strings
          ProcedureReturn ListIndex(ListEx()\Cols())
        ElseIf ListEx()\Cols()\Flags & #ComboBoxes
          ProcedureReturn ListIndex(ListEx()\Cols())
        ElseIf ListEx()\Cols()\Flags & #Dates
          ProcedureReturn ListIndex(ListEx()\Cols())
        EndIf
        
      Wend
      
    EndIf
    
    ProcedureReturn #NotValid
  EndProcedure
  
  ;- ----------------------------

  Procedure _KeyShiftTabHandler()
    Define.i GNum, Column
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      
      If FindMapElement(ListEx(), Str(GNum))  

        Select ActiveID 
          Case ListEx()\StringNum
            CloseString_()
            Column = PreviousEditColumn_(ListEx()\String\Col)
            If Column <> #NotValid
              ManageEditGadgets_(ListEx()\String\Row, Column)
            EndIf
          Case ListEx()\ComboNum
            CloseComboBox_()
            Column = PreviousEditColumn_(ListEx()\ComboBox\Col)
            If Column <> #NotValid
              ManageEditGadgets_(ListEx()\ComboBox\Row, Column)
            EndIf
          Case ListEx()\DateNum
            CloseDate_()
            Column = PreviousEditColumn_(ListEx()\Date\Col)
            If Column <> #NotValid
              ManageEditGadgets_(ListEx()\Date\Row, Column)
            EndIf
        EndSelect
        
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure _KeyTabHandler()
    Define.i GNum, Column
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      
      If FindMapElement(ListEx(), Str(GNum))  

        Select ActiveID 
          Case ListEx()\StringNum

            CloseString_()
            
            Column = NextEditColumn_(ListEx()\String\Col)
            If Column <> #NotValid
              ManageEditGadgets_(ListEx()\String\Row, Column)
            EndIf
            
          Case ListEx()\ComboNum
            
            CloseComboBox_()
            
            Column = NextEditColumn_(ListEx()\ComboBox\Col)
            If Column <> #NotValid
              ManageEditGadgets_(ListEx()\ComboBox\Row, Column)
            EndIf
            
          Case ListEx()\DateNum
            
            CloseDate_()
            
            Column = NextEditColumn_(ListEx()\Date\Col)
            If Column <> #NotValid
              ManageEditGadgets_(ListEx()\Date\Row, Column)
            EndIf
            
        EndSelect
        
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure _KeyReturnHandler()
    Define.i GNum
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      If FindMapElement(ListEx(), Str(GNum))  
        
        Select ActiveID 
          Case ListEx()\StringNum
            
            CloseString_()
            
          Case ListEx()\ComboNum
            
            CloseComboBox_()
            
          Case ListEx()\DateNum
            
            CloseDate_()
            
        EndSelect
        
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure _KeyEscapeHandler()
    Define.i GNum
    Define.i ActiveID = GetActiveGadget()
    
    If IsGadget(ActiveID)
      
      GNum = GetGadgetData(ActiveID)
      If FindMapElement(ListEx(), Str(GNum))  
 
        Select ActiveID 
          Case ListEx()\StringNum
            
            CloseString_(#True)
            
          Case ListEx()\ComboNum
            
            CloseComboBox_(#True)
            
          Case ListEx()\DateNum
            
            CloseDate_(#True)

        EndSelect
        
      EndIf
      
    EndIf
  EndProcedure
  
  
  Procedure _KeyDownHandler()
    Define.i Key, Modifier, PageNum
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Key      = GetGadgetAttribute(GNum, #PB_Canvas_Key)
      Modifier = GetGadgetAttribute(GNum, #PB_Canvas_Modifiers)
      
      Select Key 
        Case #PB_Shortcut_Up       ;{ Up
          SetFocus_(ListEx()\Row\Focus - 1)
          ;}
        Case #PB_Shortcut_Down     ;{ Down
          SetFocus_(ListEx()\Row\Focus + 1)
          ;}
        Case #PB_Shortcut_PageUp   ;{ PageUp
          PageNum = GetPageRows_()
          SetFocus_(ListEx()\Row\Focus - PageNum)
          ;}
        Case #PB_Shortcut_PageDown ;{ PageDown
          PageNum = GetPageRows_()
          SetFocus_(ListEx()\Row\Focus + PageNum)
          ;}
        Case #PB_Shortcut_Home     ;{ Home/Pos1  
          SetFocus_(0)
          ;}
        Case #PB_Shortcut_End      ;{ End
          SetFocus_(ListSize(ListEx()\Rows())-1)
          ;}
      EndSelect
      
      Draw_()
      
    EndIf
    
  EndProcedure

  Procedure _RightClickHandler()
    Define.i X, Y
    Define.i GNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      X = GetGadgetAttribute(GNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GNum, #PB_Canvas_MouseY)
      
      If X < ListEx()\Size\Width And X < ListEx()\Size\Cols 
        If Y > ListEx()\Header\Height And Y < (ListEx()\Size\Rows + ListEx()\Header\Height)
          
          ListEx()\Row\Current = GetRow_(Y)
          
          If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
            ListEx()\Focus = #True
            ListEx()\Row\Focus = ListEx()\Row\Current
            Draw_() ; Draw Focus
          EndIf
          
          If IsWindow(ListEx()\Window\Num) And IsMenu(ListEx()\PopUpID)
            DisplayPopupMenu(ListEx()\PopUpID, WindowID(ListEx()\Window\Num))
          EndIf
          
        EndIf
      EndIf  
      
    EndIf  

  EndProcedure  

  Procedure _LeftButtonDownHandler()
    Define.f X, Y, Width, Height
    Define.i Flags, FontID
    Define.s Key$, Value$
    Define   Image.Image_Structure
    Define   GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_()
        Draw_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_()
        Draw_()
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_()
        Draw_()
      EndIf ;}
      
      ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      ListEx()\Col\Current = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))

      If ListEx()\Row\Current = #NotValid Or ListEx()\Col\Current = #NotValid : ProcedureReturn #False : EndIf
      
      If ListEx()\Row\Current = #Header ;{ Header clicked
        
        If SelectElement(ListEx()\Cols(), ListEx()\Col\Current)
          
          ListEx()\Header\Col = ListEx()\Col\Current
          
          If ListEx()\Cols()\Header\Sort & #HeaderSort
            
            ListEx()\Sort\Label     = ListEx()\Cols()\Key
            ListEx()\Sort\Column    = ListEx()\Col\Current
            ListEx()\Sort\Direction = ListEx()\Cols()\Header\Direction
            ListEx()\Sort\Flags     = ListEx()\Cols()\Header\Sort
            
            If ListEx()\Cols()\Header\Sort & #SwitchDirection
              ListEx()\Cols()\Header\Direction ! #PB_Sort_Descending ; Switch Bit 1
            EndIf
            
            SortColumn_()
            
            If ListEx()\Focus And ListEx()\Row\Focus <> #NotValid
              SetVisible_(ListEx()\Row\Focus)
              ;ListEx()\Focus = #False
              ;ListEx()\Row\Focus = 
            EndIf
            
            UpdateRowY_()
            
            Draw_()
            
            UpdateEventData_(#EventType_Header, #Header, ListEx()\Col\Current, "", ListEx()\Cols()\Header\Direction, ListEx()\Sort\Label)
            
          Else
            UpdateEventData_(#EventType_Header, #Header, ListEx()\Col\Current, "", #NotValid, ListEx()\Cols()\Key)
          EndIf

          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Header, ListEx()\Col\Current)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Header, ListEx()\Col\Current)
          EndIf
        EndIf 
        ;}
      Else                              ;{ Row clicked
        
        If ListEx()\Flags & #SingleClickEdit
          ManageEditGadgets_(ListEx()\Row\Current, ListEx()\Col\Current)
        EndIf
        
        If SelectElement(ListEx()\Rows(), ListEx()\Row\Current)
          If SelectElement(ListEx()\Cols(), ListEx()\Col\Current)
            
            Y = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
            X = ListEx()\Cols()\X - ListEx()\Col\OffsetX
            
            Key$  = ListEx()\Cols()\Key
            Flags = ListEx()\Rows()\Column(Key$)\Flags
            
            If ListEx()\Cols()\Flags & #CheckBoxes  ;{ CheckBox

              If ListEx()\Editable
                
                If ListEx()\Flags & #ThreeState
                  
                  If ListEx()\Rows()\Column(Key$)\State & #Checked
                    ListEx()\Rows()\Column(Key$)\State & ~#Checked
                    ListEx()\Rows()\Column(Key$)\State | #Inbetween
                  ElseIf ListEx()\Rows()\Column(Key$)\State & #Inbetween
                    ListEx()\Rows()\Column(Key$)\State & ~#Inbetween
                  Else
                    ListEx()\Rows()\Column(Key$)\State | #Checked
                  EndIf
                  
                Else
                  
                  If ListEx()\Rows()\Column(Key$)\State & #Checked
                    ListEx()\Rows()\Column(Key$)\State & ~#Checked
                  Else
                    ListEx()\Rows()\Column(Key$)\State | #Checked
                  EndIf
                  
                EndIf
                
                ListEx()\Changed = #True
                
                ListEx()\CheckBox\Row   = ListEx()\Row\Current
                ListEx()\CheckBox\Col   = ListEx()\Col\Current
                ListEx()\CheckBox\Label = Key$
                ListEx()\CheckBox\State = ListEx()\Rows()\Column(Key$)\State
                
                UpdateEventData_(#EventType_CheckBox, ListEx()\Row\Current, ListEx()\Col\Current, "", ListEx()\CheckBox\State, ListEx()\Rows()\ID)
                If IsWindow(ListEx()\Window\Num)
                  PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                  PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                EndIf
                
                Draw_()
              EndIf
              
            ElseIf ListEx()\Flags & #CheckBoxes And ListEx()\Col\CheckBoxes = ListEx()\Col\Current
              
              If ListEx()\Editable
                
                If ListEx()\Flags & #ThreeState
                  
                  If ListEx()\Rows()\State & #Checked
                    ListEx()\Rows()\State & ~#Checked
                    ListEx()\Rows()\State | #Inbetween
                  ElseIf ListEx()\Rows()\State & #Inbetween
                    ListEx()\Rows()\State & ~#Inbetween
                  Else
                    ListEx()\Rows()\State | #Checked
                  EndIf
                  
                Else
                  
                  If ListEx()\Rows()\State & #Checked
                    ListEx()\Rows()\State & ~#Checked
                  Else
                    ListEx()\Rows()\State | #Checked
                  EndIf
                  
                EndIf
                
                ListEx()\Changed = #True
                
                ListEx()\CheckBox\Row   = ListEx()\Row\Current
                ListEx()\CheckBox\Col   = ListEx()\Col\Current
                ListEx()\CheckBox\Label = Key$
                ListEx()\CheckBox\State = ListEx()\Rows()\Column(Key$)\State
                
                UpdateEventData_(#EventType_CheckBox, ListEx()\Row\Current, ListEx()\Col\Current, "", ListEx()\CheckBox\State, ListEx()\Rows()\ID)
                If IsWindow(ListEx()\Window\Num)
                  PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                  PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_CheckBox)
                EndIf
                
                Draw_()
              EndIf  
              ;}
            ElseIf ListEx()\Cols()\Flags & #Buttons ;{ Button
              
              Value$ = ListEx()\Rows()\Column(Key$)\Value
              
              If Flags & #Image
                Image\ID     = ListEx()\Rows()\Column(Key$)\Image\ID
                Image\Width  = ListEx()\Rows()\Column(Key$)\Image\Width
                Image\Height = ListEx()\Rows()\Column(Key$)\Image\Height
                Image\Flags  = ListEx()\Rows()\Column(Key$)\Image\Flags
              Else
                Image\ID = #False
              EndIf
              
              DrawButton_(X, Y, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, #Click, ListEx()\Rows()\Color\Front, ListEx()\Rows()\FontID, @Image)
              
              ListEx()\Button\Row   = ListEx()\Row\Current
              ListEx()\Button\Col   = ListEx()\Col\Current
              ListEx()\Button\Label = ListEx()\Cols()\Key
              ListEx()\Button\Value = Value$
              ListEx()\Button\RowID = ListEx()\Rows()\ID
              ListEx()\Button\Pressed = #True
              ;}
            ElseIf ListEx()\Cols()\Flags & #Links   ;{ Link
              
              ListEx()\Focus = #True
              ListEx()\Row\Focus = ListEx()\Row\Current
              
              Draw_()
              
              Value$ = ListEx()\Rows()\Column(Key$)\Value
              
              If ListEx()\Rows()\FontID : FontID = ListEx()\Rows()\FontID : EndIf
              If Flags & #CellFont : FontID = ListEx()\Rows()\Column(Key$)\FontID : EndIf
              
              ListEx()\Link\Row     = ListEx()\Row\Current
              ListEx()\Link\Col     = ListEx()\Col\Current
              ListEx()\Link\Label   = ListEx()\Cols()\Key
              ListEx()\Link\Value   = Value$
              ListEx()\Link\RowID   = ListEx()\Rows()\ID
              ListEx()\Link\Pressed = #True
              
              If Flags & #Image
                Image\ID     = ListEx()\Rows()\Column(Key$)\Image\ID
                Image\Width  = ListEx()\Rows()\Column(Key$)\Image\Width
                Image\Height = ListEx()\Rows()\Column(Key$)\Image\Height
                Image\Flags  = ListEx()\Rows()\Column(Key$)\Image\Flags
              Else
                Image\ID = #False
              EndIf
              
              DrawLink_(X, Y, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, ListEx()\Color\ActiveLink, ListEx()\Cols()\Align, FontID, @Image)
              ;}
            Else                                    ;{ Select row(s)
              ListEx()\Focus = #True
              ;{ Strg - Select
              If ListEx()\Flags & #MultiSelect And GetGadgetAttribute(GNum, #PB_Canvas_Modifiers) = #PB_Canvas_Control
                If ListEx()\Strg = #False
                  PushListPosition(ListEx()\Rows())
                  If SelectElement(ListEx()\Rows(), ListEx()\Row\Focus)
                    ListEx()\Rows()\State | #Selected
                  EndIf
                  PopListPosition(ListEx()\Rows())
                  ListEx()\Strg = #True
                EndIf
                ListEx()\Rows()\State ! #Selected
              ElseIf ListEx()\Strg = #True
                PushListPosition(ListEx()\Rows())
                ForEach ListEx()\Rows()
                  ListEx()\Rows()\State & ~#Selected
                Next
                PopListPosition(ListEx()\Rows())
                ListEx()\Strg = #False
              EndIf ;}
              ListEx()\Row\Focus = ListEx()\Row\Current
              Draw_() ; Draw Focus
             ;}
            EndIf
            
            If IsWindow(ListEx()\Window\Num)
              PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Row, ListEx()\Row\Current)
              PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Row, ListEx()\Row\Current)
            EndIf 
            
          EndIf
        EndIf 
        ;}        
      EndIf          
      
    EndIf  
      
  EndProcedure
  
  Procedure _LeftButtonUpHandler()
    Define GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      ListEx()\Col\Current = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If ListEx()\Row\Current = #NotValid Or ListEx()\Col\Current = #NotValid : ProcedureReturn #False : EndIf
      
      If ListEx()\Button\Pressed ;{ Button pressed
        
        If ListEx()\Button\Row = ListEx()\Row\Current And ListEx()\Button\Col = ListEx()\Col\Current
          UpdateEventData_(#EventType_Button, ListEx()\Button\Row, ListEx()\Button\Col, ListEx()\Button\Value, #NotValid, ListEx()\Button\RowID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Button)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Button)
          EndIf
        Else
          UpdateEventData_(#EventType_Button, #NotValid, #NotValid, "", #NotValid, "")
        EndIf  
        
        ListEx()\Button\Pressed = #False
        
        Draw_()
        ;}
      EndIf  
      
      If ListEx()\Link\Pressed   ;{ Link pressed
        
        If ListEx()\Link\Row = ListEx()\Row\Current And ListEx()\Link\Col = ListEx()\Col\Current
          UpdateEventData_(#EventType_Button, ListEx()\Link\Row, ListEx()\Link\Col, ListEx()\Link\Value, #NotValid, ListEx()\Link\RowID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Link)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Link)
          EndIf
        Else  
          UpdateEventData_(#EventType_Button, #NotValid, #NotValid, "", #NotValid, "")
        EndIf
        
        ListEx()\Link\Pressed = #False
        
        Draw_()
        ;}
      EndIf
      
    EndIf
    
    
  EndProcedure  
  
  Procedure _LeftDoubleClickHandler()
    Define GNum.i = EventGadget()
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If ListEx()\String\Flag   ;{ Close String
        CloseString_()
      EndIf ;}
      
      If ListEx()\ComboBox\Flag ;{ Close ComboBox
        CloseComboBox_()
      EndIf ;}
      
      If ListEx()\Date\Flag     ;{ Close DateGadget
        CloseDate_()
      EndIf ;}
      
      ListEx()\Row\Current = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      ListEx()\Col\Current = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      If ListEx()\Row\Current = #NotValid Or ListEx()\Col\Current = #NotValid : ProcedureReturn #False : EndIf
      
      If ListEx()\Row\Current = #Header
        
      Else
        
        ManageEditGadgets_(ListEx()\Row\Current, ListEx()\Col\Current)
 
      EndIf
      
      Draw_()
    EndIf
    
  EndProcedure
  
  
  Procedure _MouseMoveHandler()
    Define.i Row, Column, Flags
    Define.f X, Y
    Define.s Key$, Value$, Focus$
    Define   Image.Image_Structure
    Define.i GNum = EventGadget()
    
    
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Row    = GetRow_(GetGadgetAttribute(GNum, #PB_Canvas_MouseY))
      Column = GetColumn_(GetGadgetAttribute(GNum, #PB_Canvas_MouseX))
      
      Focus$ = Str(Row)+"|"+Str(Column)
      
      If ListEx()\Button\Focus And ListEx()\Button\Focus <> Focus$
        Draw_()
      EndIf
      
      If Row = #NotValid Or Column = #NotValid
        
        If ListEx()\Cursor <> #Cursor_Default
          ListEx()\Cursor = #Cursor_Default
          SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
        EndIf
        
      Else
        
        If Row = #Header ;{ Header
          
          If ListEx()\Cols()\Header\Sort & #HeaderSort
            
            If ListEx()\Cursor <> #Cursor_Sort
              ListEx()\Cursor = #Cursor_Sort
              SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
            EndIf
            
          Else
            
            If ListEx()\Cursor <> #Cursor_Default
              ListEx()\Cursor = #Cursor_Default
              SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
            EndIf
            
          EndIf
          
          ;}
        Else             ;{ Rows
          
          If Row < 0 Or Column < 0 : ProcedureReturn #False : EndIf
          
          If SelectElement(ListEx()\Rows(), Row)
            If SelectElement(ListEx()\Cols(), Column)
              
              Y = ListEx()\Rows()\Y - ListEx()\Row\OffsetY
              X = ListEx()\Cols()\X - ListEx()\Col\OffsetX
              
              
              Key$   = ListEx()\Cols()\Key
              Flags  = ListEx()\Rows()\Column(Key$)\Flags
              
              ; Change Cursor
              If ListEx()\Cols()\Flags & #Strings
                
                If ListEx()\Cursor <> #Cursor_Edit
                  ListEx()\Cursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #ComboBoxes
                
                If ListEx()\Cursor <> #Cursor_Edit
                  ListEx()\Cursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #CheckBoxes
                
                If ListEx()\Cursor <> #Cursor_Edit
                  ListEx()\Cursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Dates
                
                If ListEx()\Cursor <> #Cursor_Edit
                  ListEx()\Cursor = #Cursor_Edit
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Links
                
                If ListEx()\Cursor <> #Cursor_Click
                  ListEx()\Cursor = #Cursor_Click
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              ElseIf ListEx()\Cols()\Flags & #Buttons
                
                ListEx()\Button\Focus = Focus$
                
                Value$ = ListEx()\Rows()\Column(Key$)\Value
                
                If Flags & #Image
                  Image\ID     = ListEx()\Rows()\Column(Key$)\Image\ID
                  Image\Width  = ListEx()\Rows()\Column(Key$)\Image\Width
                  Image\Height = ListEx()\Rows()\Column(Key$)\Image\Height
                  Image\Flags  = ListEx()\Rows()\Column(Key$)\Image\Flags
                Else
                  Image\ID = #False
                EndIf
              
                DrawButton_(X, Y, ListEx()\Cols()\Width, ListEx()\Rows()\Height, Value$, #Focus, ListEx()\Rows()\Color\Front, ListEx()\Rows()\FontID, @Image)
                
                If ListEx()\Cursor <> #Cursor_Button
                  ListEx()\Cursor = #Cursor_Button
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              Else
                
                If ListEx()\Cursor <> #Cursor_Default
                  ListEx()\Cursor = #Cursor_Default
                  SetGadgetAttribute(GNum, #PB_Canvas_Cursor, ListEx()\Cursor)
                EndIf
                
              EndIf
              
            EndIf  
          EndIf
          ;}
        EndIf
        
      EndIf
    EndIf  
    
  EndProcedure
  
  Procedure _MouseLeaveHandler()
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure _MouseWheelHandler()
    Define.i GadgetNum = EventGadget()
    Define.i Delta
    Define.f ScrollPos
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      Delta = GetGadgetAttribute(GadgetNum, #PB_Canvas_WheelDelta)
      
      If IsGadget(ListEx()\VScrollNum)
        
        ScrollPos = GetGadgetState(ListEx()\VScrollNum) - Delta
        
        If ScrollPos > ListEx()\VScroll\MaxPos : ScrollPos = ListEx()\VScroll\MaxPos : EndIf
        If ScrollPos < ListEx()\VScroll\MinPos : ScrollPos = ListEx()\VScroll\MinPos : EndIf
        
        If ScrollPos <> ListEx()\VScroll\Position
          
          ListEx()\Row\Offset = ScrollPos
          SetVScrollPosition_()
          
          UpdateRowY_()
          
          ScrollEditGadgets_() 
          
          Draw_()
        EndIf

      EndIf

    EndIf
    
  EndProcedure
  

  Procedure _ResizeHandler()
    Define.i OffsetX, OffSetY
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(ListEx(), Str(GadgetNum))
    
      ListEx()\Size\Width  = dpiX(GadgetWidth(GadgetNum))
      ListEx()\Size\Height = dpiY(GadgetHeight(GadgetNum))
      
      If ListEx()\VScroll\Hide = #False : ListEx()\Size\Width  - dpiX(#ScrollBar_Width) : EndIf
      
      If ListEx()\HScroll\Hide = #False : ListEx()\Size\Height - dpiY(#ScrollBar_Width) : EndIf
      
      If ListEx()\VScroll\Hide = #False Or ListEx()\HScroll\Hide
        
        If ListEx()\VScroll\Hide
          ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - 1, #ScrollBar_Width - 1)
        Else
          ResizeGadget(ListEx()\HScrollNum, 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width - 1, #ScrollBar_Width - 1)
        EndIf
        
        If ListEx()\HScroll\Hide
          ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - 2)
        Else  
          ResizeGadget(ListEx()\VScrollNum, GadgetWidth(ListEx()\CanvasNum) - #ScrollBar_Width, 1, #ScrollBar_Width - 1, GadgetHeight(ListEx()\CanvasNum) - #ScrollBar_Width - 2)
        EndIf
        
      EndIf
      
      UpdateColumnX_()
      UpdateRowY_()
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.i  OffSetX, OffsetY

    ForEach ListEx()
      
      If IsGadget(ListEx()\CanvasNum)
        
        If ListEx()\Flags & #AutoResize
          
          If IsWindow(ListEx()\Window\Num)
            
            OffSetX = WindowWidth(ListEx()\Window\Num)  - ListEx()\Window\Width
            OffsetY = WindowHeight(ListEx()\Window\Num) - ListEx()\Window\Height
            
            ListEx()\Window\Width  = WindowWidth(ListEx()\Window\Num)
            ListEx()\Window\Height = WindowHeight(ListEx()\Window\Num)
            
            If ListEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width  = #PB_Ignore : Height = #PB_Ignore
              
              If ListEx()\Size\Flags & #MoveX : X = GadgetX(ListEx()\CanvasNum) + OffSetX : EndIf
              If ListEx()\Size\Flags & #MoveY : Y = GadgetY(ListEx()\CanvasNum) + OffSetY : EndIf
              If ListEx()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(ListEx()\CanvasNum)  + OffSetX : EndIf
              If ListEx()\Size\Flags & #ResizeHeight : Height = GadgetHeight(ListEx()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(ListEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              
              ResizeGadget(ListEx()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(ListEx()\CanvasNum) + OffSetX, GadgetHeight(ListEx()\CanvasNum) + OffsetY)
              
            EndIf
            
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  Procedure _StringGadgetHandler()
    Define.i GNum, StringNum = EventGadget()
    
    If IsGadget(StringNum)
      
      GNum = GetGadgetData(StringNum)
      If FindMapElement(ListEx(), Str(GNum))
        If ListEx()\String\Wrong
          SetGadgetColor(ListEx()\StringNum, #PB_Gadget_FrontColor, $000000)
          SetGadgetColor(ListEx()\StringNum, #PB_Gadget_BackColor,  $FFFFFF)
          ListEx()\String\Wrong = #False
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _SynchronizeScrollCols()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.f ScrollPos
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> ListEx()\HScroll\Position
        
        If ScrollPos < ListEx()\Col\OffsetX
          ListEx()\Col\OffsetX = ScrollPos - dpiX(20)
        ElseIf ScrollPos > ListEx()\Col\OffsetX
          ListEx()\Col\OffsetX = ScrollPos + dpiX(20)
        EndIf
        
        If ListEx()\Col\OffsetX < ListEx()\HScroll\MinPos : ListEx()\Col\OffsetX = ListEx()\HScroll\MinPos : EndIf
        If ListEx()\Col\OffsetX > ListEx()\HScroll\MaxPos : ListEx()\Col\OffsetX = ListEx()\HScroll\MaxPos : EndIf
        
        SetGadgetState(ScrollNum, ListEx()\Col\OffsetX)
        SetHScrollPosition_()
        
        UpdateRowY_()
        
        ScrollEditGadgets_() 
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _SynchronizeScrollRows()
    Define.i ScrollNum = EventGadget()
    Define.i GadgetNum = GetGadgetData(ScrollNum)
    Define.f X, Y, ScrollPos
    
    If FindMapElement(ListEx(), Str(GadgetNum))
      
      ScrollPos = GetGadgetState(ScrollNum)
      If ScrollPos <> ListEx()\VScroll\Position
        
        ListEx()\Row\Offset = ScrollPos

        SetVScrollPosition_()
        
        UpdateRowY_()
        
        ScrollEditGadgets_()
        
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure 
  
  
  ;- __________ Editing Cells __________
  
  Procedure  BindShortcuts_(Flag.i=#True)
    
    If IsWindow(ListEx()\Window\Num)
      If Flag
        BindMenuEvent(ListEx()\ShortCutID, #Key_Return,   @_KeyReturnHandler())
        BindMenuEvent(ListEx()\ShortCutID, #Key_Escape,   @_KeyEscapeHandler())
        BindMenuEvent(ListEx()\ShortCutID, #Key_Tab,      @_KeyTabHandler())
        BindMenuEvent(ListEx()\ShortCutID, #Key_ShiftTab, @_KeyShiftTabHandler())
      Else
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_Return,   @_KeyReturnHandler())
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_Escape,   @_KeyEscapeHandler())
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_Tab,      @_KeyTabHandler())
        UnbindMenuEvent(ListEx()\ShortCutID, #Key_ShiftTab, @_KeyShiftTabHandler())
      EndIf
    EndIf
    
  EndProcedure

  Procedure  CloseString_(Escape.i=#False)
    
    If IsGadget(ListEx()\StringNum)
      
      PushListPosition(ListEx()\Rows())
      
      If SelectElement(ListEx()\Rows(), ListEx()\String\Row)
        If SelectElement(ListEx()\Cols(), ListEx()\String\Col)
          
          If IsContentValid_(GetGadgetText(ListEx()\StringNum)) Or Escape
            
            If ListEx()\String\Wrong
              If IsGadget(ListEx()\StringNum)
                SetGadgetColor(ListEx()\StringNum, #PB_Gadget_FrontColor, $000000)
                SetGadgetColor(ListEx()\StringNum, #PB_Gadget_BackColor,  $FFFFFF)
              EndIf
              ListEx()\String\Wrong = #False
            EndIf
            
            If Escape
              UpdateEventData_(#EventType_String, #NotValid, #NotValid, "", #NotValid, "")
            Else
              ListEx()\Rows()\Column(ListEx()\String\Label)\Value = GetGadgetText(ListEx()\StringNum)
              ListEx()\Changed = #True
              SetGadgetText(ListEx()\StringNum, "")
              UpdateEventData_(#EventType_String, ListEx()\String\Row, ListEx()\String\Col, GetGadgetText(ListEx()\StringNum), #NotValid, ListEx()\Rows()\ID)
              If IsWindow(ListEx()\Window\Num)
                PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
                PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_String)
              EndIf 
            EndIf
            
            HideGadget(ListEx()\StringNum, #True)
            BindShortcuts_(#False)
            
            ListEx()\String\Label = ""
            ListEx()\String\Flag  = #False

          Else
            If IsGadget(ListEx()\StringNum)
              SetGadgetColor(ListEx()\StringNum, #PB_Gadget_FrontColor, ListEx()\Color\WrongFront)
              SetGadgetColor(ListEx()\StringNum, #PB_Gadget_BackColor,  ListEx()\Color\WrongBack)
            EndIf
            ListEx()\String\Wrong = #True
          EndIf
          
          
          
        EndIf
      EndIf

      PopListPosition(ListEx()\Rows())
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure  CloseDate_(Escape.i=#False)
    
    If IsGadget(ListEx()\DateNum)
      
      PushListPosition(ListEx()\Rows())
      
      If Escape
        UpdateEventData_(#EventType_Date, #NotValid, #NotValid, "", #NotValid, "")
      Else  
        If SelectElement(ListEx()\Rows(), ListEx()\Date\Row)
          ListEx()\Rows()\Column(ListEx()\Date\Label)\Value = GetGadgetText(ListEx()\DateNum)
          ListEx()\Changed = #True
          UpdateEventData_(#EventType_Date, ListEx()\Date\Row, ListEx()\Date\Col, GetGadgetText(ListEx()\DateNum), GetGadgetState(ListEx()\DateNum), ListEx()\Rows()\ID)
          If IsWindow(ListEx()\Window\Num)
            PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Date)
            PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_Date)
          EndIf    
        EndIf
      EndIf
      
      HideGadget(ListEx()\DateNum, #True)
      BindShortcuts_(#False)
      
      ListEx()\Date\Label = ""
      ListEx()\Date\Flag  = #False
      
      PopListPosition(ListEx()\Rows())
      
      Draw_()        
    EndIf
    
  EndProcedure
  
  Procedure  CloseComboBox_(Escape.i=#False)
    
    If IsGadget(ListEx()\ComboNum)
      
      PushListPosition(ListEx()\Rows())
      
      If Escape
        UpdateEventData_(#EventType_ComboBox, #NotValid, #NotValid, "", #NotValid, "")
      Else
        If SelectElement(ListEx()\Rows(), ListEx()\ComboBox\Row)
          If GetGadgetState(ListEx()\ComboNum) <> #NotSelected
            ListEx()\Rows()\Column(ListEx()\ComboBox\Label)\Value = GetGadgetText(ListEx()\ComboNum)
            ListEx()\Changed = #True
            UpdateEventData_(#EventType_ComboBox,ListEx()\ComboBox\Row, ListEx()\ComboBox\Col, GetGadgetText(ListEx()\ComboNum), GetGadgetState(ListEx()\ComboNum), ListEx()\Rows()\ID)
            If IsWindow(ListEx()\Window\Num)
              PostEvent(#PB_Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_ComboBox)
              PostEvent(#Event_Gadget, ListEx()\Window\Num, ListEx()\CanvasNum, #EventType_ComboBox)
            EndIf
          Else
            UpdateEventData_(#EventType_ComboBox, #NotValid, #NotValid, "", #NotValid, "")
          EndIf
        EndIf
      EndIf
      
      HideGadget(ListEx()\ComboNum, #True)
      BindShortcuts_(#False)
      
      ListEx()\ComboBox\Label = ""
      ListEx()\ComboBox\Flag  = #False
      
      PopListPosition(ListEx()\Rows())
      
      Draw_()        
    EndIf
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================  
  
  CompilerIf #Enable_MarkContent
 
    Procedure   MarkContent(GNum.i, Column.i, Term.s, Color1.i=#PB_Default, Color2.i=#PB_Default, FontID.i=#PB_Default)
      
      If FindMapElement(ListEx(), Str(GNum))
        
        If SelectElement(ListEx()\Cols(), Column)
          MarkContent_(Term, Color1, Color2, FontID)
          Draw_()
        EndIf
        
      EndIf  
   
    EndProcedure
    
  CompilerEndIf

  Procedure.i AddColumn(GNum.i, Column.i, Title.s, Width.f, Label.s="", Flags.i=#False)
    Define.s Term
    Define.i Result
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ;{ Add Column
      Select Column
        Case #FirstItem
          FirstElement(ListEx()\Cols())
          Result = InsertElement(ListEx()\Cols()) 
        Case #LastItem
          LastElement(ListEx()\Cols())
          Result = AddElement(ListEx()\Cols())
        Default
          If SelectElement(ListEx()\Cols(), Column)
            Result = InsertElement(ListEx()\Cols()) 
          Else
            LastElement(ListEx()\Cols())
            Result = AddElement(ListEx()\Cols())
          EndIf
      EndSelect ;}
      
      If Result
        
        If Flags & #Right
          ListEx()\Cols()\Align = #Right
          Flags & ~#Right
        ElseIf Flags & #Center
          ListEx()\Cols()\Align = #Center
          Flags & ~#Center
        ElseIf Flags & #Left
          ListEx()\Cols()\Align = #Left
          Flags & ~#Left
        EndIf
        
        ListEx()\Col\Number          = ListSize(ListEx()\Cols())
        ListEx()\Cols()\Header\Titel = Title
        ListEx()\Cols()\Width        = dpiX(Width)
        ListEx()\Cols()\Currency     = ListEx()\Country\Currency
        ListEx()\Cols()\Flags        = Flags
        If Label
          ListEx()\Cols()\Key = Label
        Else
          ListEx()\Cols()\Key = Str(ListEx()\Col\Number - 1)
        EndIf
        
        CompilerIf #Enable_Validation
          If ListEx()\Cols()\Flags & #Grades : LoadGrades() : EndIf 
        CompilerEndIf
        
        CompilerIf #Enable_MarkContent
          If ListEx()\Cols()\Flags & #Grades
            Term = Grades(ListEx()\Country\Code)\Term
            If Term : MarkContent_(Term, $008000, $0000FF, #PB_Default) : EndIf
          EndIf
        CompilerEndIf  
        
        If ListEx()\ReDraw
          UpdateColumnX_()
          AdjustScrollBars_()
          Draw_()
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn ListEx()\Col\Number
  EndProcedure
  
  Procedure.i AddComboBoxItems(GNum.i, Column.i, Text.s)
    Define.i i, Count
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Key$ = ListEx()\Cols()\Key
        
        Count = CountString(Text, #LF$) + 1
        For i = 1 To Count
          AddElement(ListEx()\ComboBox\Column(Key$)\Items())
          ListEx()\ComboBox\Column(Key$)\Items() = StringField(Text, i, #LF$)
        Next
        
      EndIf  
        
      ProcedureReturn ListSize(ListEx()\ComboBox\Column(Key$)\Items())      
    EndIf
    
  EndProcedure
  
  Procedure.i AddItem(GNum.i, Row.i=-1, Text.s="", RowID.s="", Flags.i=#False) 
    Define.i i, nc, Result
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ;{ Add item
      Select Row
        Case #FirstItem
          FirstElement(ListEx()\Rows())
          Result = InsertElement(ListEx()\Rows()) 
        Case #LastItem
          LastElement(ListEx()\Rows())
          Result = AddElement(ListEx()\Rows())
        Default
          If SelectElement(ListEx()\Rows(), Row)
            Result = InsertElement(ListEx()\Rows()) 
          Else
            LastElement(ListEx()\Rows())
            Result = AddElement(ListEx()\Rows())
          EndIf
      EndSelect ;}
      
      If Result
        
        ListEx()\Row\Number    = ListSize(ListEx()\Rows())
        ListEx()\Rows()\ID     = RowID
        ListEx()\Rows()\Height = ListEx()\Row\Height
        
        ListEx()\Rows()\FontID   = ListEx()\Row\FontID
        
        ListEx()\Rows()\Color\Front = ListEx()\Color\Front
        ListEx()\Rows()\Color\Back  = ListEx()\Color\Back
        ListEx()\Rows()\Color\Grid  = ListEx()\Color\Grid
        
        If Text <> ""
          If ListEx()\Flags & #NumberedColumn Or ListEx()\Flags & #CheckBoxes
            nc = 0
          Else
            nc = 1
          EndIf
          For i=1 To CountString(Text, #LF$) + 1
            If SelectElement(ListEx()\Cols(), i - nc)
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = StringField(Text, i, #LF$)
            EndIf
          Next
        EndIf
        
        If ListEx()\ReDraw
          UpdateRowY_()
          AdjustScrollBars_()
          Draw_()
        EndIf
        
      EndIf

    EndIf
    
    ProcedureReturn ListIndex(ListEx()\Rows())
  EndProcedure
  
  Procedure   AttachPopupMenu(GNum.i, Popup.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\PopUpID = Popup
      
    EndIf
    
  EndProcedure
  
  Procedure   ChangeCountrySettings(GNum.i, CountryCode.s, Currency.s="", Clock.s="", DecimalSeperator.s="", TimeSeperator.s="", DateSeperator.s="")
    
    If CountryCode : ListEx()\Country\Code     = CountryCode : EndIf
    If Currency    : ListEx()\Country\Currency = Currency    : EndIf
    If Clock       : ListEx()\Country\Clock    = Clock       : EndIf
    
    If TimeSeperator    : ListEx()\Country\TimeSeparator    = TimeSeperator    : EndIf
    If DateSeperator    : ListEx()\Country\DateSeperator    = DateSeperator    : EndIf
    If DecimalSeperator : ListEx()\Country\DecimalSeperator = DecimalSeperator : EndIf
   
  EndProcedure
  
  Procedure   ClearComboBoxItems(GNum.i, Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        If FindMapElement(ListEx()\ComboBox\Column(), ListEx()\Cols()\Key)
          ClearList(ListEx()\ComboBox\Column()\Items())
        EndIf  
      
      EndIf
      
    EndIf
    
  EndProcedure 
  
  Procedure   ClearItems(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ClearList(ListEx()\Rows())
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure    
  
  Procedure.i CountItems(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ProcedureReturn ListEx()\Row\Number
      
    EndIf  
 
  EndProcedure  
  
  Procedure   DisableEditing(GNum.i, State.i=#True)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If State = #True
        ListEx()\Editable = #False
      Else
        ListEx()\Editable = #True
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   DisableReDraw(GNum.i, State.i=#False)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If State
        ListEx()\ReDraw = #False
      Else
        ListEx()\ReDraw = #True
        UpdateRowY_()
        UpdateColumnX_()
        AdjustScrollBars_()
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.i EventRow(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ProcedureReturn ListEx()\Event\Row
    
    EndIf
    
  EndProcedure
  
  Procedure.i EventColumn(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\Column
    EndIf  
    
  EndProcedure
  
  Procedure.i EventState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\State
    EndIf  
    
  EndProcedure  
  
  Procedure.s EventValue(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\Value
    EndIf  
    
  EndProcedure
  
  Procedure.s EventID(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Event\ID
    EndIf  
    
  EndProcedure
  
  Procedure.i Gadget(GNum.i, X.f, Y.f, Width.f, Height.f, ColTitle.s, ColWidth.f, ColLabel.s="", Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result
    
    If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget (without guaranty!)
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Keyboard|#PB_Canvas_Container)
    EndIf
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X = dpiX(X)
      Y = dpiY(Y)
      Width    = dpiX(Width)
      Height   = dpiY(Height)
      ColWidth = dpiX(ColWidth)
      
      If ColLabel = "" : ColLabel = "0" : EndIf
      
      If AddMapElement(ListEx(), Str(GNum))
        
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If WindowNum = #PB_Default  
            ListEx()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            ListEx()\Window\Num = WindowNum
          EndIf  
        CompilerElse
          If WindowNum = #PB_Default 
            ListEx()\Window\Num = GetActiveWindow()
          Else
            ListEx()\Window\Num = WindowNum
          EndIf  
        CompilerEndIf
        
        ListEx()\CanvasNum = GNum
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If ModuleEx::AddWindow(ListEx()\Window\Num, ModuleEx::#Tabulator)
            ModuleEx::AddGadget(GNum, ListEx()\Window\Num, ModuleEx::#UseTabulator)
          EndIf
        CompilerEndIf
        
        ListEx()\Flags  = Flags
        ListEx()\ReDraw = #True
        
        ListEx()\Row\Height = dpiX(20) ; Default row height
        ListEx()\Col\Width  = dpiY(50) ; Default column width
        
        If Flags & #NumberedColumn : ListEx()\Col\CheckBoxes = 1 : EndIf
        
        ListEx()\Cursor   = #Cursor_Default
        ListEx()\Editable = #True
        
        ListEx()\ProgressBar\Minimum = 0
        ListEx()\ProgressBar\Maximum = 100
        
        ;{ Country defaults
        ListEx()\Country\Code     = #DefaultCountry
        ListEx()\Country\Currency = #DefaultCurrency
        ListEx()\Country\Clock    = #DefaultClock
        ListEx()\Country\TimeSeparator    = #DefaultTimeSeparator
        ListEx()\Country\DateSeperator    = #DefaultDateSeparator
        ListEx()\Country\DecimalSeperator = #DefaultDecimalSeperator
        ListEx()\Country\TimeMask         = #DefaultTimeMask
        ListEx()\Country\DateMask         = #DefaultDateMask
        ;}
        
        ;{ Event Data
        ListEx()\Event\Type   = #NotValid
        ListEx()\Event\Row    = #NotValid
        ListEx()\Event\Column = #NotValid
        ListEx()\Event\State  = #NotValid
        ;}
        
        ;{ Size
        ListEx()\Size\X = 0
        ListEx()\Size\Y = 0
        ListEx()\Size\Width  = Width
        ListEx()\Size\Height = Height
        If IsWindow(ListEx()\Window\Num)
          ListEx()\Window\Width  = WindowWidth(ListEx()\Window\Num)
          ListEx()\Window\Height = WindowHeight(ListEx()\Window\Num)
        EndIf
        ;}        

        ;{ Gadgets
        ListEx()\StringNum  = StringGadget(#PB_Any, 0, 0, 0, 0, "")
        If IsGadget(ListEx()\StringNum)
          SetGadgetData(ListEx()\StringNum, ListEx()\CanvasNum)
          BindGadgetEvent(ListEx()\StringNum, @_StringGadgetHandler(), #PB_EventType_Change)
          HideGadget(ListEx()\StringNum, #True)
        EndIf
        
        ListEx()\ComboNum = ComboBoxGadget(#PB_Any, 0, 0, 0, 0, #PB_ComboBox_Editable)
        If IsGadget(ListEx()\ComboNum)
          SetGadgetData(ListEx()\ComboNum, ListEx()\CanvasNum)
          HideGadget(ListEx()\ComboNum, #True)
        EndIf
        
        ListEx()\DateNum = DateGadget(#PB_Any, 0, 0, 0, 0, ListEx()\Country\DateMask)
        If IsGadget(ListEx()\DateNum)
          SetGadgetData(ListEx()\DateNum, ListEx()\CanvasNum)
          HideGadget(ListEx()\DateNum, #True)
        EndIf
        ListEx()\Date\Mask = ListEx()\Country\DateMask
        
        ListEx()\HScrollNum = ScrollBarGadget(#PB_Any, 0, 0, 0, 0, 0, 0, 0)
        If IsGadget(ListEx()\HScrollNum)
          SetGadgetData(ListEx()\HScrollNum, ListEx()\CanvasNum)
          ListEx()\HScroll\Hide = #True
          HideGadget(ListEx()\HScrollNum, #True)
        EndIf
        
        ListEx()\VScrollNum = ScrollBarGadget(#PB_Any, 0, 0, 0, 0, 0, 0, 0, #PB_ScrollBar_Vertical)
        If IsGadget(ListEx()\VScrollNum)
          SetGadgetData(ListEx()\VScrollNum, ListEx()\CanvasNum)
          ListEx()\VScroll\Hide = #True
          HideGadget(ListEx()\VScrollNum, #True)
        EndIf ;}
        
        ;{ Shortcuts
        If IsWindow(ListEx()\Window\Num)
          ListEx()\ShortCutID = CreateMenu(#PB_Any, WindowID(ListEx()\Window\Num))
          AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Return, #Key_Return)
          AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Escape, #Key_Escape)
          AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab,    #Key_Tab)
          AddKeyboardShortcut(ListEx()\Window\Num, #PB_Shortcut_Tab|#PB_Shortcut_Shift, #Key_ShiftTab)
          If Flags & #AutoResize
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), ListEx()\Window\Num)
          EndIf
        Else
          Debug "ERROR: No active Window"
        EndIf ;}
        
        ;{ Header
        If Flags & #NoRowHeader
          ListEx()\Header\Height = 0
        Else  
          ListEx()\Header\Height = dpiY(20)
        EndIf
        ListEx()\Header\FontID  = FontID(LoadFont(#PB_Any, "Arial", 9))  
        ListEx()\Header\Align = #False
        ;}
        
        ;{ Rows
        ListEx()\Row\Current = #NoFocus
        ListEx()\Row\FontID  = ListEx()\Header\FontID
        ListEx()\Size\Rows   = ListEx()\Row\Height ; Height of all rows
        ListEx()\Row\Focus   = #NotValid
        ;}
        
        ;{ Column
        If AddElement(ListEx()\Cols())
          ListEx()\Cols()\Header\Titel = ColTitle
          ListEx()\Cols()\Width = dpiX(ColWidth)
          ListEx()\Cols()\Key   = ColLabel
          ListEx()\Col\Number   = 1        ; Number of columns
        EndIf
        ListEx()\Size\Cols    = ListEx()\Cols()\Width ; Width of all columns
        ListEx()\Sort\Column  = #NotValid
        ListEx()\AutoResize\MinWidth = ListEx()\Col\Width
        ListEx()\AutoResize\Column = #PB_Ignore
        ;} 
        
        ;{ Default Colors
        ListEx()\Color\Front        = $000000
        ListEx()\Color\Back         = $FFFFFF
        ListEx()\Color\Canvas       = $FFFFFF
        ListEx()\Color\ScrollBar    = $F0F0F0
        ListEx()\Color\Focus        = $D77800
        ListEx()\Color\HeaderFront  = $000000
        ListEx()\Color\HeaderBack   = $FAFAFA
        ListEx()\Color\HeaderGrid   = $A0A0A0
        ListEx()\Color\Grid         = $E3E3E3
        ListEx()\Color\Button       = $E3E3E3
        ListEx()\Color\ButtonBorder = $A0A0A0
        ListEx()\Color\ProgressBar  = $32CD32
        ListEx()\Color\Edit         = $BE7D61
        ListEx()\Color\Link         = $8B0000
        ListEx()\Color\ActiveLink   = $FF0000
        ListEx()\Color\WrongFront   = $0000FF
        ListEx()\Color\WrongBack    = $FFFFFF
        ListEx()\Color\Mark1        = $008B45
        ListEx()\Color\Mark2        = $0000FF
        
        CompilerSelect  #PB_Compiler_OS
          CompilerCase #PB_OS_Windows
            ListEx()\Color\HeaderFront  = GetSysColor_(#COLOR_WINDOWTEXT)
            ;ListEx()\Color\HeaderBack   = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\HeaderGrid   = GetSysColor_(#COLOR_3DSHADOW)
            ListEx()\Color\Front        = GetSysColor_(#COLOR_WINDOWTEXT)
            ListEx()\Color\Back         = GetSysColor_(#COLOR_WINDOW)
            ListEx()\Color\Grid         = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\Canvas       = GetSysColor_(#COLOR_WINDOW)
            ListEx()\Color\ScrollBar    = GetSysColor_(#COLOR_MENU)
            ListEx()\Color\Focus        = GetSysColor_(#COLOR_MENUHILIGHT)
            ListEx()\Color\Button       = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\ButtonBorder = GetSysColor_(#COLOR_3DSHADOW) 
          CompilerCase #PB_OS_MacOS
            ListEx()\Color\HeaderFront  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ;ListEx()\Color\HeaderBack   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ListEx()\Color\HeaderGrid   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ListEx()\Color\Front        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ListEx()\Color\Back         = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ListEx()\Color\Canvas       = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ListEx()\Color\Grid         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ListEx()\Color\ScrollBar    = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            ListEx()\Color\Focus        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            ListEx()\Color\Button       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ListEx()\Color\ButtonBorder = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux
            
        CompilerEndSelect
        
        ListEx()\Color\AlternateRow = ListEx()\Color\Back
        ;}

        If IsGadget(ListEx()\StringNum) : SetGadgetFont(ListEx()\StringNum, ListEx()\Row\FontID) : EndIf
        
        BindGadgetEvent(ListEx()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(ListEx()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(ListEx()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        BindGadgetEvent(ListEx()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(ListEx()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(ListEx()\CanvasNum,  @_MouseWheelHandler(),      #PB_EventType_MouseWheel)
        BindGadgetEvent(ListEx()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
        BindGadgetEvent(ListEx()\CanvasNum,  @_MouseLeaveHandler(),      #PB_EventType_MouseLeave)
        BindGadgetEvent(ListEx()\CanvasNum,  @_KeyDownHandler(),         #PB_EventType_KeyDown)
        
        BindGadgetEvent(ListEx()\HScrollNum, @_SynchronizeScrollCols(),  #PB_All)
        BindGadgetEvent(ListEx()\VScrollNum, @_SynchronizeScrollRows(),  #PB_All) 
        
        Draw_()
        
      EndIf 
      
      CloseGadgetList()
    EndIf
    
    ProcedureReturn ListEx()\CanvasNum
  EndProcedure  
  
  
  Procedure.i GetAttribute(GNum.i, Attribute.i) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attribute
        Case #ColumnCount  
          ProcedureReturn ListSize(ListEx()\Cols())
        Case #Gadget  
          ProcedureReturn ListEx()\CanvasNum
      EndSelect
  
    EndIf
    
  EndProcedure  
  
  Procedure.s GetCellText(GNum.i, Row.i, Label.s)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\Column(Label)\Value
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetCellState(GNum.i, Row.i, Label.s) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\Column(Label)\State
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   GetChangedState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Changed
    EndIf
    
  EndProcedure
  
  Procedure.i GetColumnState(GNum.i, Row.i, Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
          ProcedureReturn ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State
        EndIf  
      EndIf
      
    EndIf   
 
  EndProcedure
  
  Procedure.i GetColumnAttribute(GNum.i, Column.i, Attribute.i)
    ; Attrib: #Align / #Width / #FontID
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Select Attribute
          Case #Align
            ProcedureReturn ListEx()\Cols()\Align  
          Case #Width
            ProcedureReturn ListEx()\Cols()\Width
          Case #FontID
            ProcedureReturn ListEx()\Cols()\FontID
        EndSelect
      
      EndIf
      
    EndIf
    
  EndProcedure

  Procedure.i GetItemData(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\iData
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.s GetItemID(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ProcedureReturn ListEx()\Rows()\ID
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.i GetItemState(GNum.i, Row.i, Column.i=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        If Column = #PB_Default
          ProcedureReturn ListEx()\Rows()\State
        Else
          If SelectElement(ListEx()\Cols(), Column)
            ProcedureReturn ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State
          EndIf 
        EndIf
      EndIf
      
    EndIf  
    
  EndProcedure   
  
  Procedure.s GetItemText(GNum.i, Row.i, Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        If SelectElement(ListEx()\Cols(), Column)
          ProcedureReturn ListEx()\Cols()\Header\Titel
        EndIf
      Else  
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            ProcedureReturn ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.i GetState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ProcedureReturn ListEx()\Row\Focus
    EndIf
    
  EndProcedure

  Procedure   LoadColorTheme(GNum.i, File.s)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If LoadJSON(#JSON, File)
        ExtractJSONStructure(JSONValue(#JSON), @ListEx()\Color, ListEx_Color_Structure)
        FreeJSON(#JSON)
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   Refresh(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\ReDraw = #True
      UpdateRowY_()
      UpdateColumnX_()
      AdjustScrollBars_()
      Draw_()
      
    EndIf  
   
  EndProcedure
  
  Procedure   RemoveColumn(GNum.i, Column.i)
    Define.s Key$, Col$ 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Col$ = Str(Column)
        Key$ = ListEx()\Cols()\Key
        
        ForEach ListEx()\Rows()
          DeleteMapElement(ListEx()\Rows()\Column(), Key$)
        Next
        
        DeleteMapElement(ListEx()\ComboBox\Column(), Key$)
        DeleteMapElement(ListEx()\Date\Column(), Key$)
        
        DeleteElement(ListEx()\Cols())
        
        ListEx()\Col\Number = ListSize(ListEx()\Cols())
        
        UpdateColumnX_()
        
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
  
  EndProcedure
  
  Procedure   RemoveItem(GNum.i, Row.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        DeleteElement(ListEx()\Rows())
        UpdateRowY_()
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf  
   
  EndProcedure  

  Procedure   ResetChangedState(GNum.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ListEx()\Changed = #False
    EndIf
    
  EndProcedure  
  
  Procedure   SaveColorTheme(GNum.i, File.s)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If CreateJSON(#JSON)
        InsertJSONStructure(JSONValue(#JSON), @ListEx()\Color, ListEx_Color_Structure)
        SaveJSON(#JSON, File)
        FreeJSON(#JSON)
      EndIf
     
    EndIf  
    
  EndProcedure  
  
  
  Procedure   SetAutoResizeColumn(GNum.i, Column.i, minWidth.f=#PB_Default, maxWidth.f=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If minWidth = #PB_Default : minWidth = ListEx()\Col\Width : EndIf
      
      ListEx()\AutoResize\Column   = Column
      ListEx()\AutoResize\minWidth = dpiX(minWidth)
      ListEx()\AutoResize\maxWidth = dpiX(maxWidth)
      If SelectElement(ListEx()\Cols(), Column) : ListEx()\AutoResize\Width = ListEx()\Cols()\Width : EndIf
      
    EndIf  
 
  EndProcedure  
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetCellText(GNum.i, Row.i, Label.s, Text.s)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\Column(Label)\Value = Text
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetCellState(GNum.i, Row.i, Label.s, State.i) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\Column(Label)\State = State
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorTyp.i, Value.i)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      Select ColorTyp
        Case #ButtonBorderColor
          ListEx()\Color\ButtonBorder = Value
        Case #ActiveLinkColor  
          ListEx()\Color\ActiveLink = Value
        Case #FrontColor
          ListEx()\Color\Front = Value
        Case #BackColor
          ListEx()\Color\Back = Value
        Case #ButtonColor  
          ListEx()\Color\Button = Value
        Case #ProgressBarColor
          ListEx()\Color\ProgressBar = Value
        Case #GridColor
          ListEx()\Color\Grid = Value
        Case #FocusColor
          ListEx()\Color\Focus = Value
        Case #EditColor
          ListEx()\Color\Edit = Value
        Case #LinkColor
          ListEx()\Color\Link = Value
        Case #HeaderFrontColor
          ListEx()\Color\HeaderFront = Value
        Case #HeaderBackColor
          ListEx()\Color\HeaderBack = Value
        Case #HeaderGridColor
          ListEx()\Color\HeaderGrid = Value
        Case #GadgetBackColor
          ListEx()\Color\Canvas = Value
        Case #AlternateRowColor
          ListEx()\Color\AlternateRow = Value
      EndSelect
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetColorTheme(GNum.i, Theme.i=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Theme
        Case #Theme_Blue
          
          ListEx()\Color\Front        = 0
          ListEx()\Color\Back         = 16645114
          ListEx()\Color\Grid         = 13092807
          ListEx()\Color\ProgressBar  = 11829830
          ListEx()\Color\HeaderFront  = 4270875
          ListEx()\Color\HeaderBack   = 14599344
          ListEx()\Color\HeaderGrid   = 8750469
          ListEx()\Color\AlternateRow = ListEx()\Color\Back
          
        Case #Theme_Green
          
          ListEx()\Color\Front        = 0
          ListEx()\Color\Back         = 16383222
          ListEx()\Color\Grid         = 13092807
          ListEx()\Color\ProgressBar  = 7451452
          ListEx()\Color\HeaderFront  = 2374163
          ListEx()\Color\HeaderBack   = 9423456
          ListEx()\Color\HeaderGrid   = 8750469
          ListEx()\Color\AlternateRow = ListEx()\Color\Back
          
        Default
          
          ListEx()\Color\Front        = $000000
          ListEx()\Color\Back         = $FFFFFF
          ListEx()\Color\Grid         = $E3E3E3
          ListEx()\Color\ProgressBar  = $32CD32
          ListEx()\Color\HeaderFront  = $000000
          ListEx()\Color\HeaderBack   = $FAFAFA
          ListEx()\Color\HeaderGrid   = $A0A0A0
          ListEx()\Color\AlternateRow = ListEx()\Color\Back
          
          CompilerSelect  #PB_Compiler_OS
            CompilerCase #PB_OS_Windows
            ListEx()\Color\HeaderFront  = GetSysColor_(#COLOR_WINDOWTEXT)
            ;ListEx()\Color\HeaderBack   = GetSysColor_(#COLOR_3DLIGHT)
            ListEx()\Color\HeaderGrid   = GetSysColor_(#COLOR_3DSHADOW)
            ListEx()\Color\Front        = GetSysColor_(#COLOR_WINDOWTEXT)
            ListEx()\Color\Back         = GetSysColor_(#COLOR_WINDOW)
            ListEx()\Color\Grid         = GetSysColor_(#COLOR_3DLIGHT)
          CompilerCase #PB_OS_MacOS
            ListEx()\Color\HeaderFront  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ;ListEx()\Color\HeaderBack   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor controlBackgroundColor"))
            ListEx()\Color\HeaderGrid   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            ListEx()\Color\Front        = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            ListEx()\Color\Back         = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            ListEx()\Color\Grid         = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
          CompilerCase #PB_OS_Linux
            
        CompilerEndSelect
    EndSelect
    
      Draw_()
    EndIf  
    
  EndProcedure  
  
  Procedure   SetColumnAttribute(GNum.i, Column.i, Attrib.i, Value.i)
    ; Attrib: #Align (#Left/#Right/#Center) / #Width / #Font
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Select Attrib
          Case #Align
            ListEx()\Cols()\Align = Value
          Case #Width
            ListEx()\Cols()\Width = dpiX(Value)
            UpdateColumnX_()
          Case #FontID
            ListEx()\Cols()\FontID  = Value
          Case #Font  
            ListEx()\Cols()\FontID  = FontID(Value)
        EndSelect
        
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf 
      
    EndIf
    
  EndProcedure 

  Procedure   SetColumnState(GNum.i, Row.i, Column.i, State.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State = State
          If ListEx()\ReDraw : Draw_() : EndIf
        EndIf  
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetCurrency(GNum.i, String.s, Column.i=#PB_Ignore)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      If Column = #PB_Ignore 
        ListEx()\Country\Currency = String
      Else
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Currency = String
        EndIf
      EndIf
      
    EndIf
    
  EndProcedure  

  Procedure   SetDateAttribute(GNum.i, Column.i, Attrib.i, Value.i)
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        Key$ = ListEx()\Cols()\Key
        
        Select Attrib
          Case #Minimum
            ListEx()\Date\Column(Key$)\Min = Value
          Case #Maximum
            ListEx()\Date\Column(Key$)\Max = Value
        EndSelect
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetDateMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      If Column = #PB_Ignore 
        ListEx()\Date\Mask = Mask
      Else
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Date\Column(ListEx()\Cols()\Key)\Mask = Mask
        EndIf
      EndIf
      
    EndIf
   
  EndProcedure

  Procedure   SetFont(GNum.i, FontID.i) 
    
    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Row\FontID    = FontID
      ListEx()\Header\FontID = FontID
      If IsGadget(ListEx()\StringNum) : SetGadgetFont(ListEx()\StringNum, ListEx()\Row\FontID) : EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetHeaderAttribute(GNum.i, Attrib.i, Value.i)
    ; Attrib: #Align / #Width / #FontID / #Font
    ; Value:  #Left / #Right / #Center
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attrib
        Case #Align
          ListEx()\Header\Align = Value 
        Case #Width
          ListEx()\Cols()\Width = dpiX(Value)
          UpdateColumnX_()
        Case #FontID
          ListEx()\Header\FontID  = Value
        Case #Font
          ListEx()\Header\FontID  = FontID(Value)
      EndSelect
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
  EndProcedure
  
  Procedure   SetHeaderSort(GNum.i, Column.i, Direction.i=#PB_Sort_Ascending, Flags.i=#True)
    ; Direction: #Sort_Ascending|#Sort_Descending|#Sort_NoCase
    ; Flags:     #SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch / #Lexikon|#Namen
    ; Flags:     #True    (#HeaderSort|SwitchDirection|#SortArrows)
    ; Flags:     #Deutsch (#HeaderSort|SwitchDirection|#SortArrows|#Deutsch)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        ListEx()\Cols()\Header\Direction = Direction
        
        If Flags = #True
          ListEx()\Cols()\Header\Sort = #HeaderSort|#SortArrows|#SwitchDirection
        ElseIf Flags = #Deutsch
          ListEx()\Cols()\Header\Sort = #HeaderSort|#SortArrows|#SwitchDirection|#Deutsch
        Else
          ListEx()\Cols()\Header\Sort = Flags
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemColor(GNum.i, Row.i, ColorTyp.i, Value.i, Column.i=#PB_Ignore)
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
    
      Select ColorTyp
        Case #FrontColor ;{ FrontColor
          If Row = #Header
            ListEx()\Color\HeaderFront = Value
          Else
            If SelectElement(ListEx()\Rows(), Row)
              If Column = #PB_Ignore
                ListEx()\Rows()\Color\Front = Value
              Else
                If SelectElement(ListEx()\Cols(), Column)
                  Key$ = ListEx()\Cols()\Key
                  ListEx()\Rows()\Column(Key$)\Color\Front = Value
                  ListEx()\Rows()\Column(Key$)\Flags | #FrontColor
                EndIf
              EndIf
            EndIf
          EndIf ;}
        Case #BackColor  ;{ BackColor
          If Row = #Header
            ListEx()\Color\HeaderBack = Value
          Else
            If SelectElement(ListEx()\Rows(), Row)
              If Column = #PB_Ignore
                ListEx()\Rows()\Color\Back = Value
              Else
                If SelectElement(ListEx()\Cols(), Column)
                  Key$ = ListEx()\Cols()\Key
                  ListEx()\Rows()\Column(Key$)\Color\Back = Value
                  ListEx()\Rows()\Column(Key$)\Flags | #BackColor
                EndIf  
              EndIf 
            EndIf
          EndIf ;}
        Case #GridColor  ;{ GridColor
          If Row = #Header
            ListEx()\Color\HeaderGrid = Value
          Else
            If SelectElement(ListEx()\Rows(), Row)
              If Column = #PB_Ignore
                ListEx()\Rows()\Color\Grid = Value
              Else
                If SelectElement(ListEx()\Cols(), Column)
                  Key$ = ListEx()\Cols()\Key
                  ListEx()\Rows()\Column(Key$)\Color\Grid = Value
                  ListEx()\Rows()\Column(Key$)\Flags | #GridColor
                EndIf  
              EndIf
            EndIf
          EndIf ;}
        Case #HeaderFrontColor
          ListEx()\Color\HeaderFront = Value
        Case #HeaderBackColor
          ListEx()\Color\HeaderBack = Value
        Case #HeaderGridColor
          ListEx()\Color\HeaderGrid = Value  
      EndSelect
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i SetItemData(GNum.i, Row.i, Value.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\iData = Value
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemFont(GNum.i, Row.i, FontID.i, Column.i=#PB_Ignore)
    Define.s Key$
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        ListEx()\Header\FontID = FontID
      Else
        If SelectElement(ListEx()\Rows(), Row)
          If Column = #PB_Ignore
            ListEx()\Rows()\FontID = FontID
          Else
            If SelectElement(ListEx()\Cols(), Column)
              Key$ = ListEx()\Cols()\Key
              ListEx()\Rows()\Column(Key$)\FontID = FontID
              ListEx()\Rows()\Column(Key$)\Flags | #CellFont
            EndIf
          EndIf
        EndIf
      EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemID(GNum.i, Row.i, String.s)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      If SelectElement(ListEx()\Rows(), Row)
        ListEx()\Rows()\ID = String
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetItemImage(GNum.i, Row.i, Column.i, Width.f, Height.f, ImageID.i, Align.i=#Left)
    
    If FindMapElement(ListEx(), Str(GNum))                    
      
      If Row = #Header
        
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Header\Image\ID     = ImageID
          ListEx()\Cols()\Header\Image\Width  = dpiX(Width)
          ListEx()\Cols()\Header\Image\Height = dpiY(Height)
          ListEx()\Cols()\Header\Image\Flags  = Align
          ListEx()\Cols()\Header\Flags | #Image
          If ListEx()\ReDraw : Draw_() : EndIf
        EndIf
        
      Else
        
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\ID     = ImageID
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Width  = dpiX(Width)
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Height = dpiY(Height)
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Image\Flags  = Align
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Flags | #Image
            If ListEx()\ReDraw : Draw_() : EndIf
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetItemState(GNum.i, Row.i, State.i, Column.i=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))

      If Row > #NotValid
        
        If SelectElement(ListEx()\Rows(), Row)
          If Column = #PB_Default
            ListEx()\Rows()\State = State
            If ListEx()\ReDraw : Draw_() : EndIf
          Else
            If SelectElement(ListEx()\Cols(), Column)
              ListEx()\Rows()\Column(ListEx()\Cols()\Key)\State = State
              If ListEx()\ReDraw : Draw_() : EndIf
            EndIf  
          EndIf
        EndIf
        
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetItemText(GNum.i, Row.i, Text.s , Column.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #Header
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Header\Titel = Text
        EndIf
      Else  
        If SelectElement(ListEx()\Rows(), Row)
          If SelectElement(ListEx()\Cols(), Column)
            ListEx()\Rows()\Column(ListEx()\Cols()\Key)\Value = Text
          EndIf
        EndIf
      EndIf
      
      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetProgressBarAttribute(GNum.i, Attrib.i, Value.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      Select Attrib
        Case #Minimum
          ListEx()\ProgressBar\Minimum  = Value
        Case #Maximum
          ListEx()\ProgressBar\Maximum = Value
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure   SetProgressBarFlags(GNum.i, Flags.i)
    
    If FindMapElement(ListEx(), Str(GNum))
      ListEx()\ProgressBar\Flags = Flags
    EndIf
    
  EndProcedure
  
  Procedure   SetRowsHeight(GNum.i, Height.f)

    If FindMapElement(ListEx(), Str(GNum))
      
      ListEx()\Row\Height = dpiY(Height)
      
      ForEach ListEx()\Rows()
        ListEx()\Rows()\Height = ListEx()\Row\Height
      Next
      
      UpdateRowY_()

      If ListEx()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetState(GNum.i, Row.i=#PB_Default)
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If Row = #PB_Default
        
        ListEx()\Focus = #False
        
        If ListEx()\Strg = #True
          PushListPosition(ListEx()\Rows())
          ForEach ListEx()\Rows()
            ListEx()\Rows()\State & ~#Selected
          Next
          PopListPosition(ListEx()\Rows())
          ListEx()\Strg = #False
        EndIf
        
        ListEx()\Row\Focus = #NotValid
        
      Else 

        SetFocus_(Row)
        
      EndIf
      
      Draw_()
      
    EndIf
    
  EndProcedure
  
  Procedure   SetTimeMask(GNum.i, Mask.s, Column.i=#PB_Ignore)
    
    If FindMapElement(ListEx(), Str(GNum))
    
      If Column = #PB_Ignore 
        ListEx()\Country\TimeMask = Mask
      Else
        If SelectElement(ListEx()\Cols(), Column)
          ListEx()\Cols()\Mask = Mask
        EndIf
      EndIf
      
    EndIf
   
  EndProcedure
  
  
  Procedure   Sort(GNum.i, Column.i, Direction.i, Flags.i)
    ; Direction: #Sort_Ascending|#Sort_Descending|#Sort_NoCase
    ; Flags: #SortString|#SortNumber|#SortFloat|#SortDate|#SortBirthday|#SortTime|#SortCash / #Deutsch / #Lexikon|#Namen
    
    If FindMapElement(ListEx(), Str(GNum))
      
      If SelectElement(ListEx()\Cols(), Column)
        
        ListEx()\Sort\Column    = Column
        ListEx()\Sort\Direction = Direction
        
        If Flags = #True
          ListEx()\Sort\Flags = #HeaderSort|#SortArrows|#SwitchDirection
        ElseIf Flags = #Deutsch
          ListEx()\Sort\Flags = #HeaderSort|#SortArrows|#SwitchDirection|#Deutsch
        Else
          ListEx()\Sort\Flags = Flags
        EndIf
        
        SortColumn_()
        
        If ListEx()\Focus And ListEx()\Row\Focus <> #NotValid
          SetVisible_(ListEx()\Row\Focus)
          ;ListEx()\Focus = #False
          ;ListEx()\Row\Focus = 
        EndIf
      
        If ListEx()\ReDraw : Draw_() : EndIf
      EndIf
      
    EndIf
    
  EndProcedure
  

EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  #Window  = 0
  Enumeration 1
    #List
    #Button
    #PopupMenu
    #MenuItem1
    #MenuItem2
    #MenuItem3
    #MenuItem4
    #B_Green
    #B_Grey
    #B_Blue
  EndEnumeration

  #Image = 0
  #Font_Arial9  = 1
  #Font_Arial9B = 2
  #Font_Arial9U = 3
  
  LoadFont(#Font_Arial9,  "Arial", 9)
  LoadFont(#Font_Arial9B, "Arial", 9, #PB_Font_Bold)
  LoadFont(#Font_Arial9U, "Arial", 9, #PB_Font_Underline)
  
  If OpenWindow(#Window, 0, 0, 500, 250, "Window", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopupMenu)
      MenuItem(#MenuItem1, "Theme 'Blue'")
      MenuItem(#MenuItem2, "Theme 'Green'")
      MenuItem(#MenuItem3, "Theme 'Grey'")
      MenuBar()
      MenuItem(#MenuItem4, "Reset gadget size")
    EndIf
    
    ButtonGadget(#Button,  420,  10, 70, 20, "Resize")
    ButtonGadget(#B_Grey,  420,  50, 70, 20, "Grey")
    ButtonGadget(#B_Green, 420,  80, 70, 20, "Green")
    ButtonGadget(#B_Blue,  420, 110, 70, 20, "Blue")
    
    ;ListEx::Gadget(#List, 10, 10, 400, 230, "", 25, "", ListEx::#GridLines|ListEx::#CheckBoxes|ListEx::#AutoResize|ListEx::#ThreeState) ; ListEx::#NoRowHeader|ListEx::#MultiSelect|ListEx::#NumberedColumn|ListEx::#CheckBoxes|ListEx::#SingleClickEdit|ListEx::#AutoResize 
    ListEx::Gadget(#List, 10, 10, 400, 230, "", 25, "", ListEx::#GridLines|ListEx::#NumberedColumn|ListEx::#AutoResize|ListEx::#ThreeState) ; ListEx::#NoRowHeader|ListEx::#MultiSelect|ListEx::#NumberedColumn|ListEx::#n|ListEx::#SingleClickEdit|ListEx::#AutoResize 
    ListEx::DisableReDraw(#List, #True) 
    
    ListEx::AddColumn(#List, 1, "Link",    75, "link",   ListEx::#Links)
    ListEx::AddColumn(#List, 2, "Edit",    85, "edit",   ListEx::#Editable) ; |ListEx::#Time
    ListEx::AddColumn(#List, ListEx::#LastItem, "Combo",   78, "combo",  ListEx::#ComboBoxes)
    ListEx::AddColumn(#List, ListEx::#LastItem, "Date",    76, "date",   ListEx::#Dates)
    ListEx::AddColumn(#List, ListEx::#LastItem, "Buttons", 60, "button", ListEx::#Buttons) ; ListEx::#Hide
    
    ; --- Test ProgressBar ---
    ;ListEx::AddColumn(#List, ListEx::#LastItem, "Progress", 60, "progress", ListEx::#ProgressBar)
    ;ListEx::SetProgressBarFlags(#List, ListEx::#ShowPercent)
    
    ListEx::SetHeaderAttribute(#List, ListEx::#Align, ListEx::#Center)

    ListEx::SetFont(#List, FontID(#Font_Arial9))
    
    ListEx::AddItem(#List, ListEx::#LastItem, "Image"    + #LF$ + "no Image" + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Thorsten" + #LF$ + "Hoeppner" + #LF$ + "male" + #LF$ + "18.07.1967" + #LF$ + "", "PureBasic")
    ListEx::AddItem(#List, ListEx::#LastItem, "Amelia"   + #LF$ + "Smith"    + #LF$ + "female"+ #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Jack"     + #LF$ + "Jones"    + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Isla"     + #LF$ + "Williams" + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Harry"    + #LF$ + "Brown"    + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Emily"    + #LF$ + "Taylor"   + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Jacob"    + #LF$ + "Wilson"   + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Ava"      + #LF$ + "Evans"    + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Thomas"   + #LF$ + "Roberts"  + #LF$ + #LF$ + #LF$ + "Push")
    ListEx::AddItem(#List, ListEx::#LastItem, "Harriet"  + #LF$ + "Smith"    + #LF$ + #LF$ + #LF$ + "Push")
    
    ListEx::SetItemState(#List, 3, ListEx::#Inbetween)
    
    ListEx::DisableReDraw(#List, #False) 
    
    ListEx::SetRowsHeight(#List, 22)
    
    ListEx::AttachPopupMenu(#List, #PopupMenu)
    
    ListEx::AddComboBoxItems(#List, 3, "male" + #LF$ + "female")
    
;     If LoadImage(#Image, "Test.png")
;       ListEx::SetItemImage(#List, 0, 1, 16, 16, ImageID(#Image))
;       ListEx::SetItemImage(#List, 1, 5, 14, 14, ImageID(#Image), ListEx::#Center)
;       ListEx::SetItemImage(#List, ListEx::#Header, 2, 14, 14, ImageID(#Image), ListEx::#Right)
;     EndIf
    
    ListEx::SetAutoResizeColumn(#List, 2, 50)
    
    ListEx::SetColumnAttribute(#List, 1, ListEx::#FontID, FontID(#Font_Arial9U))
    ListEx::SetColumnAttribute(#List, 5, ListEx::#Align, ListEx::#Center)
    
    ListEx::SetHeaderSort(#List, 2, ListEx::#Ascending, ListEx::#Deutsch)
    
    ListEx::SetItemColor(#List,  3, ListEx::#FrontColor, $228B22, 2)
    ListEx::SetItemFont(#List, 0, FontID(#Font_Arial9B), 2)
    
    ListEx::SetAutoResizeFlags(#List, ListEx::#ResizeHeight)
    
    ListEx::MarkContent(#List, 1, "CHOICE{male|female}[C3]", $D30094, $9314FF, FontID(#Font_Arial9B))
    
    ListEx::SetColorTheme(#List, ListEx::#Theme_Blue)
    
    ListEx::SetColor(#List, ListEx::#AlternateRowColor, $FBF7F5)
    
    ; --- Test ProgressBar ---
    ;ListEx::SetCellState(#List, 1, "progress", 75) ; or SetItemState(#List, 1, 75, 5)
    ;ListEx::SetCellState(#List, 2, "progress", 50) ; or SetItemState(#List, 2, 50, 5)
    ;ListEx::SetCellState(#List, 3, "progress", 25) ; or SetItemState(#List, 3, 25, 5)
    
    ; ListEx::SetState(#List, 9)
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case ListEx::#Event_Gadget ; works with or without EventType()
          If EventType() = ListEx::#EventType_Row
            Debug ">>> Row: " + Str(EventData())
          EndIf
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #List      ;{ only in use with EventType()
              Select EventType()
                Case ListEx::#EventType_Header
                  Debug ">>> Header Click: " + Str(EventData()) ; Str(ListEx::EventColumn(#List))  
                Case ListEx::#EventType_Button
                  Debug ">>> Button pressed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + ")"
                Case ListEx::#EventType_Link
                  Debug ">>> Link pressed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)
                  If ListEx::EventID(#List) = "PureBasic" : RunProgram("http://www.purebasic.com") :  EndIf
                Case ListEx::#EventType_String
                  Debug ">>> Cell edited (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)
                Case ListEx::#EventType_Date
                  Debug ">>> Date changed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)  
                Case ListEx::#EventType_CheckBox
                  Debug ">>> CheckBox state changed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "):" + Str(ListEx::EventState(#List)) 
                Case ListEx::#EventType_ComboBox
                  Debug ">>> ComboBox state changed (" + Str(ListEx::EventRow(#List))+"/"+Str(ListEx::EventColumn(#List)) + "): " +  ListEx::EventValue(#List)
              EndSelect ;}
            Case #Button    ;{ Buttons
              HideGadget(#Button,  #True)
              HideGadget(#B_Green, #True)
              HideGadget(#B_Grey,  #True)
              HideGadget(#B_Blue,  #True)
              ResizeGadget(#List, #PB_Ignore, #PB_Ignore, 480, #PB_Ignore)
            Case #B_Green
              ListEx::SetColorTheme(#List, ListEx::#Theme_Green)
              ;ListEx::LoadColorTheme(#List, "Theme_Green.json")
            Case #B_Grey
              ListEx::SetColorTheme(#List, #PB_Default)
              ;ListEx::LoadColorTheme(#List, "Theme_Grey.json")  
            Case #B_Blue
              ListEx::SetColorTheme(#List, ListEx::#Theme_Blue)
              ;ListEx::LoadColorTheme(#List, "Theme_Blue.json")
              ;}
          EndSelect
        Case #PB_Event_Menu ;{ PopupMenu
          Select EventMenu()
            Case #MenuItem1
              ListEx::LoadColorTheme(#List, "Theme_Blue.json")
            Case #MenuItem2
              ListEx::LoadColorTheme(#List, "Theme_Green.json")
            Case #MenuItem3  
              ListEx::LoadColorTheme(#List, "Theme_Grey.json")
            Case #MenuItem4
              HideGadget(#Button,  #False)
              HideGadget(#B_Green, #False)
              HideGadget(#B_Grey,  #False)
              HideGadget(#B_Blue,  #False)
              ResizeGadget(#List, #PB_Ignore, #PB_Ignore, 400, #PB_Ignore)
          EndSelect ;}
      EndSelect
    Until Event = #PB_Event_CloseWindow
    
    ;ListEx::SaveColorTheme(#List, "Theme_Test.json")
    
  EndIf
  
CompilerEndIf
