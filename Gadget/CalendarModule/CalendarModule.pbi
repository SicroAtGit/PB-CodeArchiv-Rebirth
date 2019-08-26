;   Description: Calendar Gadget (CanvasGadget)
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=73141
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31568
;-----------------------------------------------------------------------------

;/ ============================
;/ =    CalendarModule.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Calendar - Gadget 
;/
;/ © 2019 Thorsten1867 (07/2019)
;/

; Last Update: 20.07.2019
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


;{ _____ Calendar - Commands _____

; Calendar::AddEntry()           - add an entry to the calendar
; Calendar::AttachPopupMenu()    - attachs a popup menu to the chart
; Calendar::CountEntries()       - counts entries of the day of current month
; Calendar::GetDate()            - similar to Date()
; Calendar::DefaultCountry()     - set country code for default language [DE/AT/FR/ES/GB/US]
; Calendar::DisableReDraw()      - disable/enable redrawing
; Calendar::ExportDay()          - exports the events of this day as a file    (iCal)
; Calendar::ExportLabel()        - exports the event with this label as a file (iCal)
; Calendar::EventDate()          - returns date after event
; Calendar::EventDayOfMonth()    - returns the day of month
; Calendar::EventEntries()       - returns calendar entries after event as linked list (Calendar::Entries_Structure)
; Calendar::Gadget()             - create a new gadget
; Calendar::GetDay()             - returns day of selected date
; Calendar::GetEntries()         - all entries on this date as linked list (Calendar::Entries_Structure)
; Calendar::GetMonth()           - returns month of selected date
; Calendar::GetState()           - returns selected date
; Calendar::GetYear()            - returns year of selected date
; Calendar::ImportEvent()        - imports an event from a file (iCal)
; Calendar::MonthName()          - defines name of the month
; Calendar::RemoveEntry()        - removes an entry form the calendar
; Calendar::SetAttribute()       - similar to SetGadgetAttribute()
; Calendar::SetAutoResizeFlags() - [#MoveX|#MoveY|#ResizeWidth|#ResizeHeight]
; Calendar::SetDate()            - similar to SetGadgetState()
; Calendar::SetEntryColor(GNum.i, Label.s, ColorType.i, Value.i)
; Calendar::SetEntryMask(GNum.i, Label.s, String.s)
; Calendar::SetColor()           - similar to SetGadgetColor()
; Calendar::SetFlags()           - set flags [#Year/#Month/#Gadget]
; Calendar::SetFont()            - similar to SetGadgetFont()
; Calendar::SetMask()            - define mask for time or date
; Calendar::SetState()           - similar to SetGadgetState()
; Calendar::ToolTipText()        - define mask for tooltips
; Calendar::WeekDayName()        - defines name of the weekday
; Calendar::UpdatePopupText()    - update menu item text with this mask
;}


XIncludeFile "CanvasTooltipModule.pbi"
XIncludeFile "Date64Module.pbi"

DeclareModule Calendar
  
  #Enable_iCalFormat = #True
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  ;{ _____ Constants _____
  #Day$         = "{Day}"
  #Description$ = "{Description}"
  #Month$       = "{Month}"
  #Year$        = "{Year}"
  #Date$        = "{Date}"
  #Duration$    = "{Duration}"
  #EndDate$     = "{EndDate}"
  #EndTime$     = "{EndTime}"
  #Label$       = "{Label}"
  #Location$    = "{Location}"
  #StartDate$   = "{StartDate}"
  #Summary$     = "{Summary}"
  #StartTime$   = "{StartTime}"
  #WeekDay$     = "{Weekday}"
  
  EnumerationBinary ;{ calendar entry flags
    #FullDay
    #StartTime
    #Duration
  EndEnumeration  
  ;}  
  
  EnumerationBinary ;{ GadgetFlags
    #AutoResize    ; Automatic resizing of the gadget
    #Border        ; Draw a border  
    #FixDayOfMonth ; Don't change day of month
    #FixMonth      ; Don't change month
    #FixYear       ; Don't change year
    #GreyedDays    ; Show days of the previous month
    #PostEvent     ; Send PostEvents
    #ToolTips      ; Show tooltips
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #Spacing         ; Horizontal spacing for month name
    #Height_Month    ; Row height for month and year
    #Height_WeekDays ; Row height for weekdays
    #Maximum         ; Year (SpinGadget)
    #Minimum         ; Year (SpinGadget)
    #Date            ; Mask date
    #Time            ; Mask time 
    #ToolTipText     ; Mask for tooltip text
    #ToolTipTitle    ; Mask for tooltip title (requires 'CanvasTooltipModule.pbi')
  EndEnumeration ;}
  
  Enumeration 1     ;{ FontType
    #Font_Gadget
    #Font_Month
    #Font_WeekDays
    #Font_Entry
    #Font_ToolTip
  EndEnumeration ;}
  
  Enumeration 1     ;{ FlagType
    #Year
    #Month
    #Gadget
  EndEnumeration ;}
  
  EnumerationBinary ;{ AutoResize
    #MoveX
    #MoveY
    #ResizeWidth
    #ResizeHeight
  EndEnumeration ;} 
  
  Enumeration 1     ;{ Color
    #ArrowColor
    #BackColor
    #BorderColor
    #FocusColor
    #FrontColor
    #GreyTextColor
    #LineColor
    #Entry_FrontColor
    #Entry_BackColor
    #Month_FrontColor
    #Month_BackColor
    #Week_FrontColor
    #Week_BackColor
  EndEnumeration ;}
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    #Event_Gadget         = ModuleEx::#Event_Gadget
    #EventType_Day        = ModuleEx::#EventType_Day
    #EventType_Month      = ModuleEx::#EventType_Month
    #EventType_Year       = ModuleEx::#EventType_Year
    #EventType_RightClick = ModuleEx::#EventType_RightClick
  CompilerElse
    
    Enumeration #PB_Event_FirstCustomValue
      #Event_Gadget
    EndEnumeration
    
    Enumeration #PB_EventType_FirstCustomValue
      #EventType_Day
      #EventType_Month
      #EventType_Year
      #EventType_Focus
      #EventType_RightClick
    EndEnumeration
    
  CompilerEndIf
  ;}
  
  Structure Entries_Structure
    Label.s
    StartDate.q
    EndDate.q
    Summary.s
    Description.s
    Location.s
    Flags.i
  EndStructure

  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare.i AddEntry(GNum.i, Label.s, Summary.s, Description.s, Location.s, StartDate.q, EndDate.q=#PB_Default, Flag.i=#False)
  Declare   AttachPopupMenu(GNum.i, PopUpNum.i)
  Declare.i CountEntries(GNum.i, DayOfMonth.i)
  Declare.q GetDate(Day.i, Month.i, Year.i, Hour.i=0, Minute.i=0, Second.i=0)
  Declare   DefaultCountry(Code.s)
  Declare   DisableReDraw(GNum.i, State.i=#False)
  Declare.i EventDate(GNum.i)
  Declare.i EventDayOfMonth(GNum.i)
  Declare   EventEntries(GNum.i, List Entries.Entries_Structure())
  Declare.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetDay(GNum.i)
  Declare.i GetEntries(GNum.i, Date.q, List Entries.Entries_Structure())
  Declare.i GetMonth(GNum.i) 
  Declare.i GetState(GNum.i) 
  Declare.i GetYear(GNum.i)
  Declare   MonthName(Month.i, Name.s)
  Declare   RemoveEntry(GNum.i, Label.s)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  Declare   SetColor(GNum.i, ColorType.i, Value.i)
  Declare   SetDate(GNum.i, Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
  Declare   SetEntryColor(GNum.i, Label.s, ColorType.i, Value.i)
  Declare   SetEntryMask(GNum.i, Label.s, String.s)
  Declare   SetFlags(GNum.i, Type.i, Flags.i)
  Declare   SetFont(GNum.i, FontNum.i, FontType.i=#Font_Gadget)
  Declare   SetMask(GNum.i, Type.i, String.s)
  Declare   SetState(GNum.i, Date.q)
  Declare   ToolTipText(GNum.i, String.s) 
  Declare   WeekDayName(WeekDay.i, Name.s)
  Declare   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
  
  CompilerIf #Enable_iCalFormat
    Declare.i ExportDay(GNum.i, DayOfMonth.i, File.s)
    Declare.i ExportLabel(GNum.i, Label.s, File.s)
    Declare.i ImportEvent(GNum.i, Label.s, File.s)
  CompilerEndIf
  
EndDeclareModule

Module Calendar
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants
  ;- ============================================================================ 
  
  #NotValid = -1
  
  #MonthOfYear = 1
  #WeekDays    = 2
  
  #Previous = 1
  #Next     = 2
  #Change   = 1
  
  CompilerIf #Enable_iCalFormat
    #iCal_BeginCalendar = "BEGIN:VCALENDAR" ; Begin iCalendar file
    #iCal_Version       = "VERSION:2.0"     ; Version of the format
    #iCal_ProID         = "PRODID:"         ; Instance that created the document.
    #iCal_Publish       = "METHOD:PUBLISH"  ; Makes the entry appear immediately
    #iCal_Request       = "METHOD:REQUEST"  ; Packs the entry into a request to the user
    #iCal_BeginEvent    = "BEGIN:VEVENT"    ; Begin of the area in which the appointment data is contained.
    #iCal_UID           = "UID:"            ; Unique ID of an ICS file
    #iCal_Location      = "LOCATION:"       ; Event location
    #iCal_Summary       = "SUMMARY:"        ; Summary 
    #iCal_Description   = "DESCRIPTION:"    ; Description
    #iCal_Public        = "CLASS:PUBLIC"    ; Save appointment publicly 
    #iCal_Private       = "CLASS:PRIVATE"   ; Save appointment privately 
    #iCal_DateStart     = "DTSTART:"        ; Start of the calendar entry
    #iCal_DateEnd       = "DTEND:"          ; End of the calendar entry
    #iCal_DateStamp     = "DTSTAMP:"        ; Time at which the entry was created
    #iCal_EndEvent      = "END:VEVENT"      ; End of the area in which the appointment data is contained.
    #iCal_EndCalendar   = "END:VCALENDAR"   ; End iCalendar file
  CompilerEndIf
  
  ;- ============================================================================
  ;-   Module - Structures
  ;- ============================================================================
  
  Structure UUID_Structure               ;{ UID
    Byte.b[16]
  EndStructure ;}
  
  Structure Color_Structure              ;{ ...\Color\...
    Front.i
    Back.i
    Border.i
  EndStructure  ;}
  
  Structure Entry_Structure              ;{ ...\Entry\...
    StartDate.q
    EndDate.q
    Label.s
    Summary.s
    Description.s
    Location.s
    FrontColor.i
    BackColor.i
    ToolTipMask.s
    Flags.i
  EndStructure ;}
  
  Structure Button_Size_Structure        ;{ Calendar()\Button\...
    prevX.i
    nextX.i
    Y.i
    Width.i
    Height.i
  EndStructure  ;}
    
  Structure Event_Entries_Structure      ;{ Calendar()\Event\Entries\...
    Label.s
    StartDate.q
    EndDate.q
    Summary.s
    Description.s
    Location.s
    Flags.i
  EndStructure ;}
  
  Structure Calendar_Event_Structure     ;{ Calendar()\Event\
    Day.i
    Month.i
    Year.i
    List Entries.Event_Entries_Structure()
  EndStructure ;}
  
  Structure Calendar_PostEvent_Structure ;{ Calendar()\PostEvent\
    MonthX.i
    YearX.i
    Y.i
    MonthWidth.i
    YearWidth.i
    Height.i
  EndStructure ;}

  Structure Calendar_Day_Structure       ;{ Calendar()\Day\...
    X.i
    Y.i
    Width.i
    Height.i
    List Entry.Entry_Structure()
    ToolTip.s
    ToolTipTitle.s
  EndStructure ;}
  
  Structure Calendar_Entry_Structure     ;{ ...\Entry\...
    StartDate.q
    EndDate.q
    Summary.s
    Description.s
    Location.s
    FrontColor.i
    BackColor.i
    ToolTipMask.s
    Flags.i
  EndStructure ;}
  
  Structure Calendar_Month_Structure     ;{ Calendar()\Month\...
    Y.i
    Height.i
    defHeight.i
    Spacing.i
    Font.i
    Flags.i
    State.i
    Color.Color_Structure
    Map Name.s()
    List Entries.Entry_Structure()
  EndStructure ;}
  
  Structure Calendar_Year_Structure      ;{ Calendar()\Year\...
    Minimum.i
    Maximum.i
    State.i
    Flags.i
  EndStructure ;}
  
  Structure Calendar_Week_Structure      ;{ Calendar()\Week\...
    Y.i
    Height.i
    defHeight.i
    Font.i
    Color.Color_Structure
    Map Day.s()
  EndStructure ;}
  
  Structure Calendar_Current_Structure   ;{ Calendar()\Current\...
    Date.q
    Focus.i
    Month.i
    Year.i
  EndStructure ;}
  
  Structure Calendar_Margins_Structure   ;{ Calendar()\Margin\...
    Top.i
    Left.i
    Right.i
    Bottom.i
  EndStructure ;}
  
  Structure Calendar_Color_Structure     ;{ Calendar()\Color\...
    Arrow.i
    Back.i
    Border.i
    Focus.i
    Gadget.i
    Front.i
    Line.i
    GreyText.i
    EntryFront.i
    EntryBack.i
  EndStructure  ;}
  
  Structure Calendar_Window_Structure    ;{ Calendar()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure Calendar_Size_Structure      ;{ Calendar()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    Flags.i
  EndStructure ;} 
  
  Structure Calendar_Structure           ;{ Calendar()\...
    CanvasNum.i
    SpinNum.i
    ListNum.i
    PopupNum.i
    TooltipNum.i
    
    FontID.i
    EntryFontID.i

    ReDraw.i
    
    Flags.i
    
    DateMask.s
    TimeMask.s
    
    ToolTip.i
    ToolTipText.s
    ToolTipTitle.s
    
    Color.Calendar_Color_Structure
    Current.Calendar_Current_Structure
    
    Button.Button_Size_Structure
    Event.Calendar_Event_Structure
    Margin.Calendar_Margins_Structure
    Month.Calendar_Month_Structure
    PostEvent.Calendar_PostEvent_Structure
    Size.Calendar_Size_Structure
    Week.Calendar_Week_Structure
    Window.Calendar_Window_Structure
    Year.Calendar_Year_Structure
    
    Map Day.Calendar_Day_Structure()
    Map PopUpItem.s()
    
    Map Entries.Calendar_Entry_Structure()
    
  EndStructure ;}
  Global NewMap Calendar.Calendar_Structure()
  
  Global CountryCode.s
  Global NewMap NameOfMonth.s(), NewMap NameOfWeekDay.s()
  
  ;- ============================================================================
  ;-   Module - Date 32Bit / 64Bit
  ;- ============================================================================  
  
  CompilerIf Defined(Date64, #PB_Module)
    
    Procedure.q AddDate_(Date.q, Type.i, Value.i)
      ProcedureReturn Date64::AddDate_(Date, Type, Value)
    EndProcedure
    
    Procedure.q Date_(Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
      ProcedureReturn Date64::Date_(Year, Month, Day, Hour, Minute, Second)
    EndProcedure
    
    Procedure.i Day_(Date.q)
      ProcedureReturn Date64::Day_(Date)
    EndProcedure
    
    Procedure.i DayOfWeek_(Date.q)
      ProcedureReturn Date64::DayOfWeek_(Date)
    EndProcedure
    
    Procedure.s FormatDate_(Mask.s, Date.q)
      ProcedureReturn Date64::FormatDate_(Mask, Date)
    EndProcedure
    
    Procedure.i Month_(Date.q)
      ProcedureReturn Date64::Month_(Date)
    EndProcedure
    
    Procedure.i Year_(Date.q)
      ProcedureReturn Date64::Year_(Date)
    EndProcedure
    
  CompilerElse
    
    Procedure.q AddDate_(Date.q, Type.i, Value.i)
      ProcedureReturn AddDate(Date, Type, Value)
    EndProcedure
    
    Procedure.q Date_(Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
      ProcedureReturn Date(Year, Month, Day, Hour, Minute, Second)
    EndProcedure
    
    Procedure.i Day_(Date.q)
      ProcedureReturn Day(Date)
    EndProcedure
    
    Procedure.i DayOfWeek_(Date.q)
      ProcedureReturn DayOfWeek(Date)
    EndProcedure
    
    Procedure.s FormatDate_(Mask.s, Date.q)
      ProcedureReturn FormatDate(Mask, Date)
    EndProcedure
    
    Procedure.i Month_(Date.q)
      ProcedureReturn Month(Date)
    EndProcedure
    
    Procedure.i Year_(Date.q)
      ProcedureReturn Year(Date)
    EndProcedure
    
  CompilerEndIf
  
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
  
  Procedure.s GetPopUpText_(Text.s)
    Define.i Date
    
    If Text
      Date = Date_(Calendar()\Current\Year, Calendar()\Current\Month, Val(MapKey(Calendar()\Day())))
      Text = ReplaceString(Text, #Day$,     MapKey(Calendar()\Day()))
      Text = ReplaceString(Text, #Month$,   Str(Calendar()\Current\Month))
      Text = ReplaceString(Text, #Year$,    Str(Calendar()\Current\Year))
      Text = ReplaceString(Text, #WeekDay$, Calendar()\Week\Day(Str(DayOfWeek_(Date))))
      Text = ReplaceString(Text, #Date$,    FormatDate_(Calendar()\DateMask, Date))
    EndIf
    
    ProcedureReturn Text
  EndProcedure
  
  Procedure.s GetText_(Text.s)

    If Text
      Text = ReplaceString(Text, #Day$,         MapKey(Calendar()\Day()))
      Text = ReplaceString(Text, #WeekDay$,     Calendar()\Week\Day(Str(DayOfWeek_(Calendar()\Day()\Entry()\StartDate))))
      Text = ReplaceString(Text, #Summary$,     Calendar()\Day()\Entry()\Summary)
      Text = ReplaceString(Text, #Description$, Calendar()\Day()\Entry()\Summary)
      Text = ReplaceString(Text, #Location$,    Calendar()\Day()\Entry()\Summary)
      Text = ReplaceString(Text, #Label$,       Calendar()\Day()\Entry()\Label)
      Text = ReplaceString(Text, #StartDate$,   FormatDate_(Calendar()\DateMask, Calendar()\Day()\Entry()\StartDate))
      Text = ReplaceString(Text, #EndDate$,     FormatDate_(Calendar()\DateMask, Calendar()\Day()\Entry()\EndDate))
      Text = ReplaceString(Text, #StartTime$ ,  FormatDate_(Calendar()\TimeMask, Calendar()\Day()\Entry()\StartDate))
      Text = ReplaceString(Text, #EndTime$ ,    FormatDate_(Calendar()\TimeMask, Calendar()\Day()\Entry()\EndDate))
      Text = ReplaceString(Text, #Duration$,    FormatDate_(Calendar()\TimeMask, Calendar()\Day()\Entry()\StartDate) + " - " + FormatDate_(Calendar()\TimeMask, Calendar()\Day()\Entry()\EndDate))
    EndIf
    
    ProcedureReturn Text
  EndProcedure
  
  Procedure   MonthNames(Code.s="")
	  
    Select Code
      Case "AT"
	      Calendar()\Month\Name("1")  = "Jänner"
	      Calendar()\Month\Name("2")  = "Februar"
	      Calendar()\Month\Name("3")  = "März"
	      Calendar()\Month\Name("4")  = "April"
	      Calendar()\Month\Name("5")  = "Mai"
	      Calendar()\Month\Name("6")  = "Juni"
	      Calendar()\Month\Name("7")  = "Juli"
	      Calendar()\Month\Name("8")  = "August"
	      Calendar()\Month\Name("9")  = "September"
	      Calendar()\Month\Name("10") = "Oktober"
	      Calendar()\Month\Name("11") = "November"
	      Calendar()\Month\Name("12") = "Dezember"  
	    Case "DE"
	      Calendar()\Month\Name("1")  = "Januar"
	      Calendar()\Month\Name("2")  = "Februar"
	      Calendar()\Month\Name("3")  = "März"
	      Calendar()\Month\Name("4")  = "April"
	      Calendar()\Month\Name("5")  = "Mai"
	      Calendar()\Month\Name("6")  = "Juni"
	      Calendar()\Month\Name("7")  = "Juli"
	      Calendar()\Month\Name("8")  = "August"
	      Calendar()\Month\Name("9")  = "September"
	      Calendar()\Month\Name("10") = "Oktober"
	      Calendar()\Month\Name("11") = "November"
	      Calendar()\Month\Name("12") = "Dezember"
	    Case "ES"
	      Calendar()\Month\Name("1")  = "enero"
	      Calendar()\Month\Name("2")  = "febrero"
	      Calendar()\Month\Name("3")  = "marzo"
	      Calendar()\Month\Name("4")  = "abril"
	      Calendar()\Month\Name("5")  = "mayo"
	      Calendar()\Month\Name("6")  = "junio"
	      Calendar()\Month\Name("7")  = "julio"
	      Calendar()\Month\Name("8")  = "agosto"
	      Calendar()\Month\Name("9")  = "septiembre"
	      Calendar()\Month\Name("10") = "octubre"
	      Calendar()\Month\Name("11") = "noviembre"
	      Calendar()\Month\Name("12") = "diciembre"
	    Case "FR"
	      Calendar()\Month\Name("1")  = "Janvier"
	      Calendar()\Month\Name("2")  = "Février"
	      Calendar()\Month\Name("3")  = "Mars"
	      Calendar()\Month\Name("4")  = "Avril"
	      Calendar()\Month\Name("5")  = "Mai"
	      Calendar()\Month\Name("6")  = "Juin"
	      Calendar()\Month\Name("7")  = "Juillet"
	      Calendar()\Month\Name("8")  = "Août"
	      Calendar()\Month\Name("9")  = "Septembre"
	      Calendar()\Month\Name("10") = "Octobre"
	      Calendar()\Month\Name("11") = "Novembre"
	      Calendar()\Month\Name("12") = "Décembre"
	    Case "GB", "US"
        Calendar()\Month\Name("1")  = "January"
	      Calendar()\Month\Name("2")  = "February"
	      Calendar()\Month\Name("3")  = "March"
	      Calendar()\Month\Name("4")  = "April"
	      Calendar()\Month\Name("5")  = "May"
	      Calendar()\Month\Name("6")  = "June"
	      Calendar()\Month\Name("7")  = "July"
	      Calendar()\Month\Name("8")  = "August"
	      Calendar()\Month\Name("9")  = "September"
	      Calendar()\Month\Name("10") = "October"
	      Calendar()\Month\Name("11") = "November"
	      Calendar()\Month\Name("12") = "December"
	    Default
	      If MapSize(NameOfMonth())
	        Calendar()\Month\Name("1")  = NameOfMonth("1")
  	      Calendar()\Month\Name("2")  = NameOfMonth("2")
  	      Calendar()\Month\Name("3")  = NameOfMonth("3")
  	      Calendar()\Month\Name("4")  = NameOfMonth("4")
  	      Calendar()\Month\Name("5")  = NameOfMonth("5")
  	      Calendar()\Month\Name("6")  = NameOfMonth("6")
  	      Calendar()\Month\Name("7")  = NameOfMonth("7")
  	      Calendar()\Month\Name("8")  = NameOfMonth("8")
  	      Calendar()\Month\Name("9")  = NameOfMonth("9")
  	      Calendar()\Month\Name("10") = NameOfMonth("10")
  	      Calendar()\Month\Name("11") = NameOfMonth("11")
  	      Calendar()\Month\Name("12") = NameOfMonth("12")
	      Else
  	      Calendar()\Month\Name("1")  = "January"
  	      Calendar()\Month\Name("2")  = "February"
  	      Calendar()\Month\Name("3")  = "March"
  	      Calendar()\Month\Name("4")  = "April"
  	      Calendar()\Month\Name("5")  = "May"
  	      Calendar()\Month\Name("6")  = "June"
  	      Calendar()\Month\Name("7")  = "July"
  	      Calendar()\Month\Name("8")  = "August"
  	      Calendar()\Month\Name("9")  = "September"
  	      Calendar()\Month\Name("10") = "October"
  	      Calendar()\Month\Name("11") = "November"
  	      Calendar()\Month\Name("12") = "December"
	      EndIf
	  EndSelect
	  
	EndProcedure
  
  Procedure   WeekDayNames_(Code.s="")
	  
	  Select Code
	    Case "DE", "AT"
	      Calendar()\Week\Day("1") = "Mo."
	      Calendar()\Week\Day("2") = "Di."
	      Calendar()\Week\Day("3") = "Mi."
	      Calendar()\Week\Day("4") = "Do."
	      Calendar()\Week\Day("5") = "Fr."
	      Calendar()\Week\Day("6") = "Sa."
	      Calendar()\Week\Day("7") = "So."
	    Case "ES"
	      Calendar()\Week\Day("1") = "Lun."
	      Calendar()\Week\Day("2") = "Mar."
	      Calendar()\Week\Day("3") = "Mié."
	      Calendar()\Week\Day("4") = "Jue."
	      Calendar()\Week\Day("5") = "Vie."
	      Calendar()\Week\Day("6") = "Sáb."
	      Calendar()\Week\Day("7") = "Dom."
	    Case "FR"
	      Calendar()\Week\Day("1") = "Lu."
	      Calendar()\Week\Day("2") = "Ma."
	      Calendar()\Week\Day("3") = "Me."
	      Calendar()\Week\Day("4") = "Je."
	      Calendar()\Week\Day("5") = "Ve."
	      Calendar()\Week\Day("6") = "Sa."
	      Calendar()\Week\Day("7") = "Di."
	    Case "GB", "US"
        Calendar()\Week\Day("1") = "Mon."
	      Calendar()\Week\Day("2") = "Tue."
	      Calendar()\Week\Day("3") = "Wed."
	      Calendar()\Week\Day("4") = "Thu."
	      Calendar()\Week\Day("5") = "Fri."
	      Calendar()\Week\Day("6") = "Sat."
	      Calendar()\Week\Day("7") = "Sun."
	    Default
	      If MapSize(NameOfWeekDay())
	        Calendar()\Week\Day("1") = NameOfWeekDay("1")
  	      Calendar()\Week\Day("2") = NameOfWeekDay("2") 
  	      Calendar()\Week\Day("3") = NameOfWeekDay("3") 
  	      Calendar()\Week\Day("4") = NameOfWeekDay("4") 
  	      Calendar()\Week\Day("5") = NameOfWeekDay("5") 
  	      Calendar()\Week\Day("6") = NameOfWeekDay("6") 
  	      Calendar()\Week\Day("7") = NameOfWeekDay("7") 
	      Else
  	      Calendar()\Week\Day("1") = "Mon."
  	      Calendar()\Week\Day("2") = "Tue."
  	      Calendar()\Week\Day("3") = "Wed."
  	      Calendar()\Week\Day("4") = "Thu."
  	      Calendar()\Week\Day("5") = "Fri."
  	      Calendar()\Week\Day("6") = "Sat."
  	      Calendar()\Week\Day("7") = "Sun."
  	    EndIf
  	    
  	    Calendar()\Week\Day("0") = Calendar()\Week\Day("1")
  	    
	  EndSelect
	  
	EndProcedure
	
	Procedure.i GetColor_(Color.i, DefaultColor.i)
	  
	  If Color = #PB_Default
	    ProcedureReturn DefaultColor
	  Else
	    ProcedureReturn Color
	  EndIf
	  
	EndProcedure
	
	Procedure   SetFont_(FontNum.i)
	  
	  If IsFont(FontNum)
	     DrawingFont(FontID(FontNum))
	  Else
	     DrawingFont(Calendar()\FontID)
	  EndIf
	  
	EndProcedure
	
	Procedure.q FirstCalendarDay(Month.i, Year.i)
	  Define.i DayDiff
	  Define.q FirstDay, FirstCalendarDay
	  
	  FirstDay = Date_(Year, Month, 1, 0, 0, 0)
	  
	  DayDiff  = -DayOfWeek_(firstDay) + 1
	  If DayDiff > 0 : DayDiff - 7 : EndIf
	  
	  ProcedureReturn Day_(AddDate_(FirstDay, #PB_Date_Day, DayDiff))
  EndProcedure 
	
  Procedure.i LastDayOfMonth_(Month.i, Year.i)
    Define.q Date
    
    Date = Date_(Year, Month, 1, 0, 0, 0)

	  ProcedureReturn Day_(AddDate_(AddDate_(Date, #PB_Date_Month, 1), #PB_Date_Day, -1))
	EndProcedure
	
	Procedure.i FirstWeekDay_(Month.i, Year.i)
	  Define.i DayOfWeek
	  
	  DayOfWeek = DayOfWeek_(Date_(Year, Month, 1, 0, 0, 0))
	  If DayOfWeek = 0 : DayOfWeek = 7 : EndIf
	  
	  ProcedureReturn DayOfWeek
	EndProcedure
	
  Procedure   UpdatePopUpMenu_()
		Define.s Text$

		ForEach Calendar()\PopUpItem()
		  Text$ = GetPopUpText_(Calendar()\PopUpItem())
			SetMenuItemText(Calendar()\PopupNum, Val(MapKey(Calendar()\PopUpItem())), Text$)
		Next

	EndProcedure
	
	Procedure.s UpdateToolTipMask(Mask.s, Flags.i)
	  
	  If Flags & #FullDay
	    
	    Mask = RemoveString(Mask, #StartTime$)
	    Mask = RemoveString(Mask, #EndTime$)
	    Mask = RemoveString(Mask, #Duration$)
	    Mask = ReplaceString(Mask, "  ", " ")
	    
	  EndIf
	  
	  If Flags & #StartTime
	    Mask = ReplaceString(Mask, #Duration$, #StartTime$)
	  EndIf

	  ProcedureReturn Mask
	EndProcedure
	
	Procedure   UpdateCurrentEntries_()
	  Define.i d, StartDay, EndDay, LastDay
	  
	  If MapSize(Calendar()\Entries())
	    
  	  LastDay = LastDayOfMonth_(Calendar()\Current\Month, Calendar()\Current\Year)
  	  
  	  For d=1 To LastDay
        
	      StartDay = Date_(Calendar()\Current\Year, Calendar()\Current\Month, d, 0, 0, 0)
	      EndDay   = Date_(Calendar()\Current\Year, Calendar()\Current\Month, d, 23, 59, 59)

	      If AddMapElement(Calendar()\Day(), Str(d))
	        
	        ForEach Calendar()\Entries()

	          If (Calendar()\Entries()\StartDate >= StartDay And Calendar()\Entries()\EndDate <= EndDay) Or (StartDay >= Calendar()\Entries()\StartDate And EndDay <= Calendar()\Entries()\EndDate)

  	          If AddElement(Calendar()\Day(Str(d))\Entry())
  	            Calendar()\Day(Str(d))\Entry()\Label       = MapKey(Calendar()\Entries())
  	            Calendar()\Day(Str(d))\Entry()\StartDate   = Calendar()\Entries()\StartDate
  	            Calendar()\Day(Str(d))\Entry()\EndDate     = Calendar()\Entries()\EndDate
  	            Calendar()\Day(Str(d))\Entry()\Summary     = Calendar()\Entries()\Summary
  	            Calendar()\Day(Str(d))\Entry()\Description = Calendar()\Entries()\Description
  	            Calendar()\Day(Str(d))\Entry()\Location    = Calendar()\Entries()\Location
  	            Calendar()\Day(Str(d))\Entry()\FrontColor  = Calendar()\Entries()\FrontColor
  	            Calendar()\Day(Str(d))\Entry()\BackColor   = Calendar()\Entries()\BackColor
  	            Calendar()\Day(Str(d))\Entry()\ToolTipMask = Calendar()\Entries()\ToolTipMask
  	            Calendar()\Day(Str(d))\Entry()\Flags       = Calendar()\Entries()\Flags
  	          EndIf 
  	          
  	        EndIf
  	        
  	      Next
  	      
  	    EndIf
  	    
  	  Next
  	  
  	  SortStructuredList(Calendar()\Day()\Entry(), #PB_Sort_Ascending, OffsetOf(Entry_Structure\StartDate), TypeOf(Entry_Structure\StartDate))
  	  
  	EndIf  

	EndProcedure
	
	;- __________ Drawing __________
	
  Procedure.i BlendColor_(Color1.i, Color2.i, Factor.i=50)
    Define.i Red1, Green1, Blue1, Red2, Green2, Blue2
    Define.f Blend = Factor / 100
    
    Red1 = Red(Color1): Green1 = Green(Color1): Blue1 = Blue(Color1)
    Red2 = Red(Color2): Green2 = Green(Color2): Blue2 = Blue(Color2)
    
    ProcedureReturn RGB((Red1 * Blend) + (Red2 * (1 - Blend)), (Green1 * Blend) + (Green2 * (1 - Blend)), (Blue1 * Blend) + (Blue2 * (1 - Blend)))
  EndProcedure	
  
	Procedure.i Arrow_(X.i, Y.i, Width.i, Height.i, Direction.i)
	  Define.i Color
	  
	  If Calendar()\Month\Color\Back = Calendar()\Color\Back
	    Color = Calendar()\Color\Arrow
	  Else
	    Color = BlendColor_(Calendar()\Color\Arrow, Calendar()\Month\Color\Back, 70)
	  EndIf
	  
    Calendar()\Button\Width  = dpiX(5)
    Calendar()\Button\Height = dpiX(10)
    
    Calendar()\Button\Y = Y + (Height - Calendar()\Button\Height) / 2
    
    If Calendar()\Button\Width < Width And Calendar()\Button\Height < Height 
      
      Select Direction
        Case #Previous

          Calendar()\Button\prevX = X + Width - Calendar()\Button\Width - dpiX(21)

          DrawingMode(#PB_2DDrawing_Default)
          LineXY(Calendar()\Button\prevX, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Calendar()\Button\prevX + Calendar()\Button\Width, Calendar()\Button\Y, Color)
          LineXY(Calendar()\Button\prevX, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Calendar()\Button\prevX + Calendar()\Button\Width, Calendar()\Button\Y + Calendar()\Button\Height, Color)
          Line(Calendar()\Button\prevX + Calendar()\Button\Width, Calendar()\Button\Y, 1, Calendar()\Button\Height, Color)
          FillArea(Calendar()\Button\prevX + Calendar()\Button\Width - dpix(2), Calendar()\Button\Y + (Calendar()\Button\Height / 2), -1, Color)
          
        Case #Next

          Calendar()\Button\nextX = X + Width - Calendar()\Button\Width - dpiX(10)

          DrawingMode(#PB_2DDrawing_Default)
          Line(Calendar()\Button\nextX, Calendar()\Button\Y, 1, Calendar()\Button\Height, Color)
          LineXY(Calendar()\Button\nextX, Calendar()\Button\Y, Calendar()\Button\nextX + Calendar()\Button\Width, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Color)
          LineXY(Calendar()\Button\nextX, Calendar()\Button\Y + Calendar()\Button\Height, Calendar()\Button\nextX + Calendar()\Button\Width, Calendar()\Button\Y + (Calendar()\Button\Height / 2), Color)
          FillArea(Calendar()\Button\nextX + dpix(2), Calendar()\Button\Y + (Calendar()\Button\Height / 2), -1, Color)
          
      EndSelect

    EndIf
    
  EndProcedure
	
  Procedure   Draw_()
    Define.i X, Y, Width, Height, PosX, PosY, txtX, txtY, txtHeight
    Define.i c, r, Column, Row, ColumnWidth, RowHeight, Difference
    Define.i Date, Month, Year, Day, GreyDay, FirstWeekDay, LastDay, FocusDay, FocusX, FocusY
    Define.i FrontColor, BackColor, CurrentDate, Entries
    Define.s Text$, Month$, Year$, ToolTipMask$
    
    X = Calendar()\Margin\Left
    Y = Calendar()\Margin\Top
    
    Width  = Calendar()\Size\Width  - Calendar()\Margin\Left - Calendar()\Margin\Right
    Height = Calendar()\Size\Height - Calendar()\Margin\Top  - Calendar()\Margin\Bottom

    If StartDrawing(CanvasOutput(Calendar()\CanvasNum))
      
      ColumnWidth = Round(Width  / 7, #PB_Round_Down)  ; Days of week
      Width       = ColumnWidth *  7
      
      ;{ Calc Height
      If Calendar()\Month\defHeight = #PB_Default And Calendar()\Week\defHeight = #PB_Default
        
        RowHeight = Round(Height / 8, #PB_Round_Down) ; Month + Weekdays + Rows
        Calendar()\Month\Height = RowHeight
        Calendar()\Week\Height  = RowHeight

        Difference = Height - (RowHeight * 8)
        
      ElseIf Calendar()\Month\defHeight = #PB_Default
        
        RowHeight = Round((Height - Calendar()\Week\defHeight) / 7, #PB_Round_Down)
        Calendar()\Month\Height = RowHeight
        Calendar()\Week\Height  = Calendar()\Week\defHeight
        
        Difference = Height - (Calendar()\Week\Height + (RowHeight * 7))
        
      ElseIf Calendar()\Week\defHeight = #PB_Default 
        
        RowHeight = Round((Height - Calendar()\Month\defHeight) / 7, #PB_Round_Down)
        Calendar()\Month\Height = Calendar()\Month\defHeight
        Calendar()\Week\Height  = RowHeight
        
        Difference = Height - (Calendar()\Month\Height + (RowHeight * 7))
        
      Else
        
        RowHeight = Round((Height - Calendar()\Month\defHeight - Calendar()\Week\defHeight) / 6, #PB_Round_Down)
        Calendar()\Month\Height = Calendar()\Month\defHeight
        Calendar()\Week\Height  = Calendar()\Week\defHeight
        
        Difference = Height - (Calendar()\Month\Height + Calendar()\Week\Height + (RowHeight * 6))
        
      EndIf ;}
      
      Calendar()\Month\Height + Difference
      
      ;{ _____ Background _____
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, Calendar()\Size\Width, Calendar()\Size\Height, Calendar()\Color\Gadget)
      Box(0, 0, Width, Height, Calendar()\Color\Back) 
      ;}
      
      DrawingFont(Calendar()\FontID)
      
      Month = Calendar()\Current\Month
      Year  = Calendar()\Current\Year
      
      FirstWeekDay = FirstWeekDay_(Month, Year)
      LastDay      = LastDayOfMonth_(Month, Year)
      GreyDay      = FirstCalendarDay(Month.i, Year.i)
      FocusDay     = Day_(Calendar()\Current\Focus)
      
      FocusX = #NotValid
      FocusY = #NotValid
      
      PosY = Y
      Day  = 1
      
      PushMapPosition(Calendar()\Day())
      
      For r=1 To 8

        Select r
          Case #MonthOfYear ;{ Month & Year
            
            SetFont_(Calendar()\Month\Font)
            
            PosX = X  + Calendar()\Month\Spacing
            
            Month$ = Calendar()\Month\Name(Str(Calendar()\Current\Month))
            Year$  = Str(Calendar()\Current\Year)
            Text$  = Month$ + "  " + Year$
            
            txtHeight = TextHeight(Text$)
            txtY      = (Calendar()\Month\Height - txtHeight) / 2
           
            FrontColor = GetColor_(Calendar()\Month\Color\Front, Calendar()\Color\Front)
            
            If Calendar()\Month\Color\Back <> #PB_Default
              DrawingMode(#PB_2DDrawing_Default)
              Box(X, PosY, Width, Calendar()\Month\Height, Calendar()\Month\Color\Back)
            EndIf
            
            DrawingMode(#PB_2DDrawing_Transparent) 
            DrawText(PosX, PosY + txtY, Text$, FrontColor)
            
            Calendar()\Month\Y      = PosY + txtY
            Calendar()\Month\Height = Calendar()\Month\Height
            
            Calendar()\PostEvent\MonthX     = PosX
            Calendar()\PostEvent\MonthWidth = TextWidth(Month$)
            Calendar()\PostEvent\YearX      = PosX + Calendar()\PostEvent\MonthWidth + TextWidth("  ")
            Calendar()\PostEvent\YearWidth  = TextWidth(Year$)
            Calendar()\PostEvent\Y          = PosY + txtY
            Calendar()\PostEvent\Height     = txtHeight
            
            DrawingMode(#PB_2DDrawing_Outlined) 
            Box(X, PosY, Width, Calendar()\Month\Height + dpiY(1), Calendar()\Color\Line)
            
            PosY + Calendar()\Month\Height
            ;}
          Case #WeekDays    ;{ Weekdays
            
            SetFont_(Calendar()\Week\Font)

            PosX      = X
            txtHeight = TextHeight("Abc")
            txtY      = (Calendar()\Week\Height - txtHeight) / 2
            
            FrontColor = GetColor_(Calendar()\Week\Color\Front, Calendar()\Color\Front)
            
            If Calendar()\Month\Color\Back <> #PB_Default
              DrawingMode(#PB_2DDrawing_Default)
              Box(X, PosY, Width, Calendar()\Week\Height, Calendar()\Week\Color\Back)
            EndIf
            
            For c=1 To 7
              
              Text$ = Calendar()\Week\Day(Str(c))
              txtX = (ColumnWidth - TextWidth(Text$)) / 2
              
              DrawingMode(#PB_2DDrawing_Transparent) 
              DrawText(PosX + txtX, PosY + txtY, Text$, FrontColor)
              
              DrawingMode(#PB_2DDrawing_Outlined) 
              Box(PosX, PosY, ColumnWidth + dpiX(1), Calendar()\Week\Height + dpiY(1), Calendar()\Color\Line)
              
              PosX + ColumnWidth
            Next
            
            PosY + Calendar()\Week\Height
            ;}
          Default           ;{ Days

            PosX = X

            For c=1 To 7
              
              Entries = ListSize(Calendar()\Day(Str(Day))\Entry())
              If Entries
                DrawingFont(Calendar()\EntryFontID)
              Else
                DrawingFont(Calendar()\FontID)
              EndIf

              txtHeight = TextHeight("Abc")
              txtY      = (RowHeight - txtHeight) / 2
              
              If Day = 1 And c <> FirstWeekDay ;{ Skip weekdays < day 

                If Calendar()\Flags & #GreyedDays
                  Text$ = Str(GreyDay)
                  txtX  = (ColumnWidth - TextWidth("33")) / 2 + (TextWidth("33") - TextWidth(Text$))
                  DrawingMode(#PB_2DDrawing_Transparent) 
                  DrawText(PosX + txtX, PosY + txtY, Text$, Calendar()\Color\GreyText)
                  GreyDay + 1
                EndIf
                
                DrawingMode(#PB_2DDrawing_Outlined) 
                Box(PosX, PosY, ColumnWidth + dpiX(1), RowHeight + dpiY(1), Calendar()\Color\Line)
                
                PosX + ColumnWidth
                Continue 
              EndIf ;}

              If Day <= LastDay
                
                Text$ = Str(Day)
                txtX  = (ColumnWidth - TextWidth("33")) / 2 + (TextWidth("33") - TextWidth(Text$))
                
                FrontColor = Calendar()\Color\Front
                BackColor  = Calendar()\Color\Back
                
                If Entries        ;{ Draw entry background
                  
                  If FindMapElement(Calendar()\Day(), Str(Day))

                    Date = Date_(Year, Month, Day, 0, 0, 0)
                    If Calendar()\ToolTipTitle
                      Calendar()\Day()\ToolTipTitle = GetText_(Calendar()\ToolTipTitle)
                    Else
                      Calendar()\Day()\ToolTipTitle = Calendar()\Week\Day(Str(c)) + "  " + FormatDate_(Calendar()\DateMask, Date)
                    EndIf
                    
                    If Entries = 1 ;{ Single Entry

                      FrontColor = Calendar()\Color\EntryFront
                      BackColor  = Calendar()\Color\EntryBack
                      
                      If FirstElement(Calendar()\Day()\Entry())
                        
                        If Calendar()\Day()\Entry()\ToolTipMask
                          ToolTipMask$ = UpdateToolTipMask(Calendar()\Day()\Entry()\ToolTipMask, Calendar()\Day()\Entry()\Flags)
                          Calendar()\Day()\ToolTip = GetText_(ToolTipMask$)
                        ElseIf Calendar()\ToolTipText 
                          ToolTipMask$ = UpdateToolTipMask(Calendar()\ToolTipText, Calendar()\Day()\Entry()\Flags)
                          Calendar()\Day()\ToolTip = GetText_(ToolTipMask$)
                        Else
                          
                          If Calendar()\Day()\Entry()\Flags & #FullDay
                            Calendar()\Day()\ToolTip = Calendar()\Day()\Entry()\Summary
                          ElseIf Calendar()\Day()\Entry()\Flags & #Duration
                            Calendar()\Day()\ToolTip = GetText_(#Summary$ + " (" + #Duration$ + ")")
                          ElseIf Calendar()\Day()\Entry()\Flags & #StartTime
                            Calendar()\Day()\ToolTip = GetText_(#Summary$ + " (" + #StartTime$ + ")")
                          Else
                            Calendar()\Day()\ToolTip = Calendar()\Day()\Entry()\Summary
                          EndIf  
                          
                        EndIf
                        
                        If Calendar()\Day()\Entry()\FrontColor <> #PB_Default : FrontColor = Calendar()\Day()\Entry()\FrontColor : EndIf
                        If Calendar()\Day()\Entry()\BackColor  <> #PB_Default : BackColor  = Calendar()\Day()\Entry()\BackColor  : EndIf
                        
                      EndIf
                      
                      If BackColor <> Calendar()\Color\Back
                        DrawingMode(#PB_2DDrawing_Default)
                        BackColor = BlendColor_(BackColor, Calendar()\Day()\Entry()\BackColor, 30)
                        Box(PosX, PosY, ColumnWidth, RowHeight, BackColor)
                      EndIf
                      ;}
                    Else           ;{ Multiple Entires
                      
                      FrontColor = Calendar()\Color\EntryFront
                      BackColor  = Calendar()\Color\EntryBack
                      
                      CompilerIf Defined(ToolTip, #PB_Module)
                        
                        ForEach Calendar()\Day()\Entry()
                          If Calendar()\Day()\Entry()\ToolTipMask
                            Calendar()\Day()\ToolTip = GetText_(Calendar()\Day()\Entry()\ToolTipMask) + #LF$
                          ElseIf Calendar()\ToolTipText 
                            Calendar()\Day()\ToolTip + GetText_(Calendar()\ToolTipText) + #LF$
                          Else
                            
                            If Calendar()\Day()\Entry()\Flags & #FullDay
                              Calendar()\Day()\ToolTip = Calendar()\Day()\Entry()\Summary + #LF$
                            ElseIf Calendar()\Day()\Entry()\Flags & #Duration
                              Calendar()\Day()\ToolTip = GetText_(#Summary$ + " (" + #Duration$ + ")") + #LF$
                            ElseIf Calendar()\Day()\Entry()\Flags & #StartTime
                              Calendar()\Day()\ToolTip = GetText_(#Summary$ + " (" + #StartTime$ + ")") + #LF$
                            Else
                              Calendar()\Day()\ToolTip = Calendar()\Day()\Entry()\Summary + #LF$
                            EndIf  

                          EndIf
                        Next
                        
                        Calendar()\Day()\ToolTip = Trim(RTrim(Calendar()\Day()\ToolTip, #LF$))
                        
                      CompilerElse
                       
                        ForEach Calendar()\Day()\Entry()
                          If Calendar()\Day()\Entry()\ToolTipMask
                            Calendar()\Day()\ToolTip = GetText_(Calendar()\Day()\Entry()\ToolTipMask) + " /"
                          ElseIf Calendar()\ToolTipText 
                            Calendar()\Day()\ToolTip + " " + GetText_(Calendar()\ToolTipText) + " /"
                          Else
                            Calendar()\Day()\ToolTip + " " + Calendar()\Day()\Entry()\Summary + " /"
                          EndIf
                        Next
                        
                        Calendar()\Day()\ToolTip = Trim(RTrim(Calendar()\Day()\ToolTip, "/"))
                        
                      CompilerEndIf
                      
                      DrawingMode(#PB_2DDrawing_Default)
                      Box(PosX, PosY, ColumnWidth, RowHeight, BackColor)
                      
                    EndIf
                    ;}
                  EndIf
                  
                EndIf ;}
                
                If Day = FocusDay ;{ Draw focus
                  If Month = Month_(Calendar()\Current\Focus) And Year = Year_(Calendar()\Current\Focus)
                    DrawingMode(#PB_2DDrawing_Default)
                    Box(PosX, PosY, ColumnWidth, RowHeight, BlendColor_(Calendar()\Color\Focus, BackColor, 10))
                    FocusX = PosX : FocusY = PosY
                  EndIf
                EndIf ;}
                
                DrawingMode(#PB_2DDrawing_Transparent) 
                DrawText(PosX + txtX, PosY + txtY, Text$, FrontColor)
                
                If Calendar()\Flags & #GreyedDays = #False
                  DrawingMode(#PB_2DDrawing_Outlined) 
                  Box(PosX, PosY, ColumnWidth + dpiX(1), RowHeight + dpiY(1), Calendar()\Color\Line)
                EndIf
                
                Calendar()\Day(Str(Day))\X      = PosX
                Calendar()\Day(Str(Day))\Y      = PosY
                Calendar()\Day(Str(Day))\Width  = ColumnWidth
                Calendar()\Day(Str(Day))\Height = RowHeight
                
                If Day = LastDay : GreyDay = 1 : EndIf
                
                Day + 1
              Else
                
                Calendar()\Day(Str(Day))\X = #False
                Calendar()\Day(Str(Day))\Y = #False
                Calendar()\Day(Str(Day))\Width  = #False
                Calendar()\Day(Str(Day))\Height = #False
                
                If Calendar()\Flags & #GreyedDays
                  Text$ = Str(GreyDay)
                  txtX  = (ColumnWidth - TextWidth("33")) / 2 + (TextWidth("33") - TextWidth(Text$))
                  DrawingMode(#PB_2DDrawing_Transparent) 
                  DrawText(PosX + txtX, PosY + txtY, Text$, Calendar()\Color\GreyText)
                  GreyDay + 1
                EndIf
                
                Day + 1
              EndIf
              
              If Calendar()\Flags & #GreyedDays
                DrawingMode(#PB_2DDrawing_Outlined) 
                Box(PosX, PosY, ColumnWidth + dpiX(1), RowHeight + dpiY(1), Calendar()\Color\Line)
              EndIf
              
              PosX + ColumnWidth
            Next

            PosY + RowHeight
            ;}
        EndSelect

      Next
      
      PopMapPosition(Calendar()\Day())
      
      ;{ Draw Focus Border
      If FocusX <> #NotValid And FocusY <> #NotValid 
        DrawingMode(#PB_2DDrawing_Outlined) 
        Box(FocusX, FocusY, ColumnWidth + dpiX(1), RowHeight + dpiY(1), BlendColor_(Calendar()\Color\Focus, Calendar()\Color\Line, 60))
      EndIf
      ;}
      
      If Calendar()\Flags & #FixMonth = #False
        Arrow_(X, Y, Width, Calendar()\Month\Height, #Previous)
        Arrow_(X, Y, Width, Calendar()\Month\Height, #Next)
      EndIf
      
      ;{ _____ Border ____
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, Width, Height, Calendar()\Color\Line)
      If Calendar()\Flags & #Border
        Box(0, 0, Calendar()\Size\Width, Calendar()\Size\Height, Calendar()\Color\Border)
      EndIf ;}
      
      StopDrawing()
    EndIf 
    
  EndProcedure
  
  ;- __________ Events __________
  
  Procedure  UpdateEvent_()
    
    Calendar()\Event\Day   = Val(MapKey(Calendar()\Day()))
    Calendar()\Event\Month = Calendar()\Current\Month
    Calendar()\Event\Year  = Calendar()\Current\Year
    
    ClearList(Calendar()\Event\Entries())
    If ListSize(Calendar()\Day()\Entry())
      ForEach Calendar()\Day()\Entry()
        If AddElement(Calendar()\Event\Entries())
          Calendar()\Event\Entries()\Label       = Calendar()\Day()\Entry()\Label
          Calendar()\Event\Entries()\Summary     = Calendar()\Day()\Entry()\Summary
          Calendar()\Event\Entries()\Description = Calendar()\Day()\Entry()\Description
          Calendar()\Event\Entries()\Location    = Calendar()\Day()\Entry()\Location
          Calendar()\Event\Entries()\StartDate   = Calendar()\Day()\Entry()\StartDate
          Calendar()\Event\Entries()\EndDate     = Calendar()\Day()\Entry()\EndDate
          Calendar()\Event\Entries()\Flags       = Calendar()\Day()\Entry()\Flags
        EndIf
      Next
    EndIf 
    
  EndProcedure
  
  Procedure  ChangeYear_(State.i=#True)
    Define.i X, Y, Width, Height, Year, OffsetY
    Define.i FontID, spinHeight, spinWidth
    
    If IsGadget(Calendar()\SpinNum)
      
      If State
        
        X = DesktopUnscaledX(Calendar()\PostEvent\YearX)
        Y = DesktopUnscaledX(Calendar()\PostEvent\Y)
        Width  = DesktopUnscaledX(Calendar()\PostEvent\YearWidth)
        Height = DesktopUnscaledX(Calendar()\PostEvent\Height)
        
        If IsFont(Calendar()\Month\Font)
          SetGadgetFont(Calendar()\SpinNum, FontID(Calendar()\Month\Font))
        Else
          SetGadgetFont(Calendar()\SpinNum, Calendar()\FontID)
        EndIf
        
        SetGadgetState(Calendar()\SpinNum, Calendar()\Current\Year)
        
        spinWidth  = GadgetWidth(Calendar()\SpinNum,  #PB_Gadget_RequiredSize) + 10
        spinHeight = GadgetHeight(Calendar()\SpinNum, #PB_Gadget_RequiredSize)
        
        SetAttribute(Calendar()\SpinNum, #PB_Spin_Minimum, Calendar()\Year\Minimum)
        SetAttribute(Calendar()\SpinNum, #PB_Spin_Maximum, Calendar()\Year\Maximum)
        
        OffsetY = Round((Height - spinHeight) / 2, #PB_Round_Nearest)
        ResizeGadget(Calendar()\SpinNum, X, Y + OffsetY, spinWidth, spinHeight)
        
        HideGadget(Calendar()\SpinNum, #False)

        Calendar()\Year\State = #Change
      Else
        
        HideGadget(Calendar()\SpinNum, #True)
        
        Year = GetGadgetState(Calendar()\SpinNum)
        
        Calendar()\Current\Year  = Year
        Calendar()\Current\Date  = Date_(Year, Calendar()\Current\Month, 1, 0, 0, 0)
        
        UpdateCurrentEntries_()
        
        Draw_()
        
        Calendar()\Year\State = #False
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure  ChangeMonth_(State.i=#True)
    Define.i X, Y, Height
    
    If IsGadget(Calendar()\ListNum)
      
      If State
        X      = DesktopUnscaledX(Calendar()\PostEvent\MonthX)
        Y      = DesktopUnscaledX(Calendar()\PostEvent\Y + Calendar()\PostEvent\Height) + 1
        Height = DesktopUnscaledX(Calendar()\Size\Height - Calendar()\Month\Height) - 5
        
        SetGadgetState(Calendar()\ListNum, Calendar()\Current\Month - 1)
        
        ResizeGadget(Calendar()\ListNum, X, Y, 90, Height)
        
        Calendar()\Month\State = #Change
        HideGadget(Calendar()\ListNum, #False)
        
      Else
        
        Calendar()\Month\State = #False
        HideGadget(Calendar()\ListNum, #True)
        
      EndIf 
      
    EndIf 
    
  EndProcedure
  
  
  Procedure _ListGadgetHandler()
    Define.i GadgetNum, Selected, Month
    Define.i ListGadgetNum = EventGadget()
    
    GadgetNum = GetGadgetData(ListGadgetNum)
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      Selected = GetGadgetState(ListGadgetNum)
      If Selected <> -1
        
        HideGadget(ListGadgetNum, #True)
        Calendar()\Month\State = #False
        
        Month = Selected + 1
        If Month >= 1 And Month <= 12
          Calendar()\Current\Month = Month
          Calendar()\Current\Date  = Date_(Calendar()\Current\Year, Month, 1, 0, 0, 0)
          
          UpdateCurrentEntries_()
          
          Draw_()
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LeftDoubleClickHandler()
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseY)
      
      If Calendar()\Month\State = #Change : ChangeMonth_(#False) : EndIf
      If Calendar()\Year\State  = #Change : ChangeYear_(#False)  : EndIf
      
      If Y > Calendar()\Week\Y + Calendar()\Week\Height
        
        ForEach Calendar()\Day()
          
          If Y >= Calendar()\Day()\Y And Y <= Calendar()\Day()\Y + Calendar()\Day()\Height
            If X >= Calendar()\Day()\X And X <= Calendar()\Day()\X + Calendar()\Day()\Width
              
              CompilerIf Defined(ToolTip, #PB_Module)
                ToolTip::SetState(GadgetNum, #False)
              CompilerElse
                GadgetToolTip(GadgetNum, "")
              CompilerEndIf
              
              UpdateEvent_()
              
              PostEvent(#Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Day, Val(MapKey(Calendar()\Day())))
              PostEvent(#PB_Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Day, Val(MapKey(Calendar()\Day())))
              
              Break
            EndIf
          EndIf
          
        Next
          
      EndIf   
      
    EndIf
    
  EndProcedure
  
  Procedure _RightClickHandler()
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseY)
      
      If Calendar()\Month\State = #Change : ChangeMonth_(#False) : EndIf
      If Calendar()\Year\State  = #Change : ChangeYear_(#False)  : EndIf
      
      If Y > Calendar()\Week\Y + Calendar()\Week\Height
        
        ForEach Calendar()\Day()
          
          If Y >= Calendar()\Day()\Y And Y <= Calendar()\Day()\Y + Calendar()\Day()\Height
            If X >= Calendar()\Day()\X And X <= Calendar()\Day()\X + Calendar()\Day()\Width
              
              ToolTip::SetState(GadgetNum, #False)
              
              UpdateEvent_()
              
              If IsWindow(Calendar()\Window\Num) And IsMenu(Calendar()\PopUpNum)
                UpdatePopUpMenu_()
                DisplayPopupMenu(Calendar()\PopUpNum, WindowID(Calendar()\Window\Num))
              Else  
                PostEvent(#Event_Gadget,    Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_RightClick, Val(MapKey(Calendar()\Day())))
                PostEvent(#PB_Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_RightClick, Val(MapKey(Calendar()\Day())))
              EndIf
              
            EndIf
          EndIf
          
        Next
        
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure _LeftButtonDownHandler()
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseY) 
      
      If Calendar()\Month\State = #Change : ChangeMonth_(#False) : EndIf
      If Calendar()\Year\State  = #Change : ChangeYear_(#False)  : EndIf
      
    EndIf
    
  EndProcedure

  Procedure _LeftButtonUpHandler()  
    Define.i X, Y, Angle
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(Calendar()\CanvasNum, #PB_Canvas_MouseY)
      
      ;{ Buttons: Previous & Next
      If Calendar()\Flags & #FixMonth = #False
        If Y >= Calendar()\Button\Y And Y <= Calendar()\Button\Y + Calendar()\Button\Height
          If X >= Calendar()\Button\prevX And X <= Calendar()\Button\prevX + Calendar()\Button\Width
            Calendar()\Current\Date  = AddDate_(Calendar()\Current\Date, #PB_Date_Month, -1)
            Calendar()\Current\Month = Month_(Calendar()\Current\Date)
            Calendar()\Current\Year  = Year_(Calendar()\Current\Date)
            UpdateCurrentEntries_()
            Draw_()
            ProcedureReturn #True
          ElseIf X >= Calendar()\Button\nextX And X <= Calendar()\Button\nextX + Calendar()\Button\Width
            Calendar()\Current\Date  = AddDate_(Calendar()\Current\Date, #PB_Date_Month, 1)
            Calendar()\Current\Month = Month_(Calendar()\Current\Date)
            Calendar()\Current\Year  = Year_(Calendar()\Current\Date)
            UpdateCurrentEntries_()
            Draw_()
            ProcedureReturn #True
          EndIf
        EndIf  
      EndIf ;}
      
      ;{ Click: Month & Year
      If Y >= Calendar()\PostEvent\Y And Y <= Calendar()\PostEvent\Y + Calendar()\PostEvent\Height
        If X >= Calendar()\PostEvent\MonthX And X <= Calendar()\PostEvent\MonthX + Calendar()\PostEvent\MonthWidth
 
          If Calendar()\Month\Flags & #PostEvent
            PostEvent(#Event_Gadget,    Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Month)
            PostEvent(#PB_Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Month)
            ProcedureReturn #True
          Else
            ChangeMonth_()
            ProcedureReturn #True
          EndIf
          
        ElseIf X >= Calendar()\PostEvent\YearX And X <= Calendar()\PostEvent\YearX + Calendar()\PostEvent\YearWidth
          
          If Calendar()\Year\Flags & #PostEvent
            PostEvent(#Event_Gadget,    Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Year)
            PostEvent(#PB_Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Year)
            ProcedureReturn #True
          ElseIf Calendar()\Year\State = #False
            ChangeYear_(#True) 
            ProcedureReturn #True
          EndIf
          
        EndIf
      EndIf ;} 
      
      ;{ Click: Days of Month
      If Calendar()\Flags & #FixDayOfMonth = #False
        If Y > Calendar()\Week\Y + Calendar()\Week\Height
          ForEach Calendar()\Day()
            If Y >= Calendar()\Day()\Y And Y <= Calendar()\Day()\Y + Calendar()\Day()\Height
              If X >= Calendar()\Day()\X And X <= Calendar()\Day()\X + Calendar()\Day()\Width
                Calendar()\Current\Focus = Date_(Calendar()\Current\Year, Calendar()\Current\Month, Val(MapKey(Calendar()\Day())), 0, 0, 0)
                Draw_()
                UpdateEvent_()
                PostEvent(#Event_Gadget,    Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Focus, Val(MapKey(Calendar()\Day())))
                PostEvent(#PB_Event_Gadget, Calendar()\Window\Num, Calendar()\CanvasNum, #EventType_Focus, Val(MapKey(Calendar()\Day())))
                Break
              EndIf
            EndIf
          Next
        EndIf   
      EndIf ;}
      
    EndIf
    
  EndProcedure

  Procedure _MouseMoveHandler()
    Define.i X, Y
    Define.i GadgetNum = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetNum))
      
      X = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseX)
      Y = GetGadgetAttribute(GadgetNum, #PB_Canvas_MouseY)
      
      ;{ Buttons: Previous & Next
      If Y >= Calendar()\Button\Y And Y <= Calendar()\Button\Y + Calendar()\Button\Height
        If X >= Calendar()\Button\prevX And X <= Calendar()\Button\prevX + Calendar()\Button\Width
          SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          ProcedureReturn #True
        ElseIf X >= Calendar()\Button\nextX And X <= Calendar()\Button\nextX + Calendar()\Button\Width
          SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          ProcedureReturn #True
        EndIf
      EndIf ;}
      
      ;{ Month & Year
      If Y > Calendar()\PostEvent\Y And Y < Calendar()\PostEvent\Y + Calendar()\PostEvent\Height
        If X > Calendar()\PostEvent\MonthX And X < Calendar()\PostEvent\MonthX + Calendar()\PostEvent\MonthWidth
          If Calendar()\Month\Flags & #PostEvent Or Calendar()\Month\Flags & #FixMonth = #False
            SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          EndIf 
          ProcedureReturn #True
        ElseIf X > Calendar()\PostEvent\YearX And X < Calendar()\PostEvent\YearX + Calendar()\PostEvent\YearWidth 
          If Calendar()\Year\Flags & #PostEvent Or Calendar()\Month\Flags & #FixYear = #False
            SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
          EndIf
          ProcedureReturn #True
        EndIf
      EndIf ;}
      
      SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
      
      ;{ Days of Month
      If Y > Calendar()\Week\Y + Calendar()\Week\Height
        
        If Calendar()\Year\State = #Change : ChangeYear_(#False) : EndIf
        
        ForEach Calendar()\Day()
          
          If Y >= Calendar()\Day()\Y And Y <= Calendar()\Day()\Y + Calendar()\Day()\Height
            If X >= Calendar()\Day()\X And X <= Calendar()\Day()\X + Calendar()\Day()\Width
              
              If Calendar()\ToolTip <> Val(MapKey(Calendar()\Day()))
                
                If ListSize(Calendar()\Day()\Entry())
                
                  CompilerIf Defined(ToolTip, #PB_Module)
                    Debug "Calendar: " + Str(Calendar()\Day()\X) +" / "+ Str(Calendar()\Day()\Y) + " / "+Str(Calendar()\Day()\Width) + " / "+Str(Calendar()\Day()\Height)
                    ToolTip::SetContent(GadgetNum, Calendar()\Day()\ToolTip, Calendar()\Day()\ToolTipTitle, DesktopUnscaledX(Calendar()\Day()\X), DesktopUnscaledY(Calendar()\Day()\Y), DesktopUnscaledX(Calendar()\Day()\Width), DesktopUnscaledY(Calendar()\Day()\Height))
                  CompilerElse

                    GadgetToolTip(GadgetNum, Calendar()\Day()\ToolTip) 
                   
                  CompilerEndIf
                  
                EndIf
                
                Calendar()\ToolTip = Val(MapKey(Calendar()\Day()))
                
              EndIf

              If Calendar()\Flags & #FixDayOfMonth = #False
                SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Hand)
              EndIf
              
              ProcedureReturn #True
            EndIf
          EndIf
          
        Next
        
      EndIf ;}
      
      SetGadgetAttribute(GadgetNum, #PB_Canvas_Cursor, #PB_Cursor_Default)
      
      Calendar()\ToolTip = #False
      GadgetToolTip(GadgetNum, "")
     
    EndIf
    
  EndProcedure  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(Calendar(), Str(GadgetID))
      
      Calendar()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      Calendar()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach Calendar()
      
      If IsGadget(Calendar()\CanvasNum)
        
        If Calendar()\Flags & #AutoResize
          
          If IsWindow(Calendar()\Window\Num)
            
            OffSetX = WindowWidth(Calendar()\Window\Num)  - Calendar()\Window\Width
            OffsetY = WindowHeight(Calendar()\Window\Num) - Calendar()\Window\Height

            Calendar()\Window\Width  = WindowWidth(Calendar()\Window\Num)
            Calendar()\Window\Height = WindowHeight(Calendar()\Window\Num)
            
            If Calendar()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If Calendar()\Size\Flags & #MoveX : X = GadgetX(Calendar()\CanvasNum) + OffSetX : EndIf
              If Calendar()\Size\Flags & #MoveY : Y = GadgetY(Calendar()\CanvasNum) + OffSetY : EndIf
              If Calendar()\Size\Flags & #ResizeWidth  : Width  = GadgetWidth(Calendar()\CanvasNum)  + OffSetX : EndIf
              If Calendar()\Size\Flags & #ResizeHeight : Height = GadgetHeight(Calendar()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(Calendar()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(Calendar()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(Calendar()\CanvasNum) + OffSetX, GadgetHeight(Calendar()\CanvasNum) + OffsetY)
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
  
  CompilerIf #Enable_iCalFormat
    
    Procedure.s UniqueID(*UUID.UUID_Structure)
      Define i.i, UUID$
      
      If Not *UUID : ProcedureReturn "" : EndIf
      
      For i=0 To 15
        *UUID\Byte[i]=Random(255)
      Next
      
      *UUID\Byte[9] = 128 + Random(63)
      *UUID\Byte[7] =  64 + Random(15)
      
      For i=0 To 16-1
        UUID$ + RSet(Hex(*UUID\Byte[i]&$FF), 2, "0")
      Next
      
      ProcedureReturn UUID$
    EndProcedure
    
    Procedure.i ExportDay(GNum.i, DayOfMonth.i, File.s) 
      Define.i FileID, Result = #False
      Define   UUID.UUID_Structure
      
      If FindMapElement(Calendar(), Str(GNum))
        Debug "Day: "+Str(DayOfMonth)
        If FindMapElement(Calendar()\Day(), Str(DayOfMonth))
        
          FileID = CreateFile(#PB_Any, File, #PB_UTF8)
          If FileID
            
            WriteStringN(FileID, #iCal_BeginCalendar, #PB_UTF8)
            WriteStringN(FileID, #iCal_Version, #PB_UTF8)
            WriteStringN(FileID, #iCal_ProID + "PureBasic", #PB_UTF8)
            WriteStringN(FileID, #iCal_Publish, #PB_UTF8)
            
            ForEach Calendar()\Day()\Entry() ;{ Entries
              
              WriteStringN(FileID, #iCal_BeginEvent, #PB_UTF8)
              WriteStringN(FileID, #iCal_UID + UniqueID(@UUID), #PB_UTF8)
              WriteStringN(FileID, #iCal_Location    + Calendar()\Day()\Entry()\Location,    #PB_UTF8)
              WriteStringN(FileID, #iCal_Summary     + Calendar()\Day()\Entry()\Summary,     #PB_UTF8)
              WriteStringN(FileID, #iCal_Description + Calendar()\Day()\Entry()\Description, #PB_UTF8)
              WriteStringN(FileID, #iCal_Private, #PB_UTF8)
              WriteStringN(FileID, #iCal_DateStart   + FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Calendar()\Day()\Entry()\StartDate), #PB_UTF8)
              WriteStringN(FileID, #iCal_DateEnd     + FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Calendar()\Day()\Entry()\EndDate),   #PB_UTF8)
              WriteStringN(FileID, #iCal_DateStamp   + FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Date()), #PB_UTF8)
              WriteStringN(FileID, #iCal_EndEvent,  #PB_UTF8)
              ;}
            Next
            
            WriteStringN(FileID, #iCal_EndCalendar, #PB_UTF8)
            
            Result = #True
            CloseFile(FileID)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i ExportLabel(GNum.i, Label.s, File.s) 
      Define.i FileID, Result = #False
      Define   UUID.UUID_Structure
      
      If FindMapElement(Calendar(), Str(GNum))
        
        FileID = CreateFile(#PB_Any, File, #PB_UTF8)
        If FileID
          
          WriteStringN(FileID, #iCal_BeginCalendar, #PB_UTF8)
          WriteStringN(FileID, #iCal_Version, #PB_UTF8)
          WriteStringN(FileID, #iCal_ProID + "PureBasic", #PB_UTF8)
          WriteStringN(FileID, #iCal_Publish, #PB_UTF8)
          
          If FindMapElement(Calendar()\Entries(), Label) ;{ Entries
            
            WriteStringN(FileID, #iCal_BeginEvent, #PB_UTF8)
            WriteStringN(FileID, #iCal_UID + UniqueID(@UUID), #PB_UTF8)
            WriteStringN(FileID, #iCal_Location    + Calendar()\Entries()\Location,    #PB_UTF8)
            WriteStringN(FileID, #iCal_Summary     + Calendar()\Entries()\Summary,     #PB_UTF8)
            WriteStringN(FileID, #iCal_Description + Calendar()\Entries()\Description, #PB_UTF8)
            WriteStringN(FileID, #iCal_Private, #PB_UTF8)
            WriteStringN(FileID, #iCal_DateStart   + FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Calendar()\Entries()\StartDate), #PB_UTF8)
            WriteStringN(FileID, #iCal_DateEnd     + FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Calendar()\Entries()\EndDate),   #PB_UTF8)
            WriteStringN(FileID, #iCal_DateStamp   + FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", Date()), #PB_UTF8)
            WriteStringN(FileID, #iCal_EndEvent,  #PB_UTF8)
            ;}
          EndIf
          
          WriteStringN(FileID, #iCal_EndCalendar, #PB_UTF8)
          
          Result = #True
          CloseFile(FileID)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i ImportEvent(GNum.i, Label.s, File.s)
      Define.i FileID, Result = #False
      Define.s String, Param
      
      If FindMapElement(Calendar(), Str(GNum))
        
        If FindMapElement(Calendar()\Entries(), Label)
          Debug "Label already exists"
          ProcedureReturn #False
        EndIf 
        
        FileID = ReadFile(#PB_Any, File, #PB_UTF8)
        If FileID
  
          While Eof(FileID) = #False
            
            String = ReadString(FileID)
            
            Select StringField(String, 1, ":")
              Case "END"    ;{ END:VCALENDAR
                If StringField(String, 2, ":") = "VCALENDAR"
                  Result = #True
                  Break
                EndIf ;}  
              Case "BEGIN"  ;{ BEGIN:VEVENT
                
                If StringField(String, 2, ":") = "VEVENT" 
                  
                  If AddMapElement(Calendar()\Entries(), Label)
                    Repeat
                      String = ReadString(FileID)
                      Select StringField(String, 1, ":")
                        Case "LOCATION"
                          Calendar()\Entries()\Location    = StringField(String, 2, ":")
                        Case "SUMMARY"
                          Calendar()\Entries()\Summary     = StringField(String, 2, ":")
                        Case "DESCRIPTION"
                          Calendar()\Entries()\Description = StringField(String, 2, ":")
                        Case "DTSTART"
                          Calendar()\Entries()\StartDate   = ParseDate("%yyyy%mm%ddT%hh%ii%ssZ", StringField(String, 2, ":")) 
                        Case "DTEND"
                          Calendar()\Entries()\EndDate     = ParseDate("%yyyy%mm%ddT%hh%ii%ssZ", StringField(String, 2, ":")) 
                      EndSelect
                    Until String = "END:VEVENT" Or Eof(FileID)
                  EndIf
                  
                EndIf
                ;}
            EndSelect
  
          Wend
          
          CloseFile(FileID)
        EndIf

      EndIf 
      
      ProcedureReturn Result
    EndProcedure
    
  CompilerEndIf 
  
  
  Procedure.i AddEntry(GNum.i, Label.s, Summary.s, Description.s, Location.s, StartDate.q, EndDate.q=#PB_Default, Flag.i=#False)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If FindMapElement(Calendar()\Entries(), Label)
        Debug "Label already exists"
        ProcedureReturn #False
      EndIf 
      
      If AddMapElement(Calendar()\Entries(), Label)
        
        Calendar()\Entries()\Summary     = Summary
        Calendar()\Entries()\Description = Description
        Calendar()\Entries()\Location    = Location
        Calendar()\Entries()\StartDate   = StartDate
        
        If EndDate = #PB_Default
          Calendar()\Entries()\EndDate   = StartDate
        Else
          Calendar()\Entries()\EndDate   = EndDate
        EndIf
        
        Calendar()\Entries()\FrontColor  = #PB_Default
        Calendar()\Entries()\BackColor   = #PB_Default
        
        Calendar()\Entries()\Flags       = Flag
        
        UpdateCurrentEntries_()
        
        If Calendar()\ReDraw : Draw_() : EndIf
        
        ProcedureReturn #True
      EndIf

    EndIf
    
  EndProcedure
  
  Procedure   AttachPopupMenu(GNum.i, PopUpNum.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      Calendar()\PopupNum = PopUpNum
    EndIf
    
  EndProcedure  
  
  Procedure.i CountEntries(GNum.i, DayOfMonth.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      If FindMapElement(Calendar()\Day(), Str(DayOfMonth))
        ProcedureReturn ListSize(Calendar()\Day()\Entry())
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure 
  
  Procedure   DefaultCountry(Code.s)
    CountryCode = Code
  EndProcedure
  
  Procedure   DisableReDraw(GNum.i, State.i=#False)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If State
        Calendar()\ReDraw = #False
      Else
        Calendar()\ReDraw = #True
        Draw_()
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   EventEntries(GNum.i, List Entries.Entries_Structure())
    
    If FindMapElement(Calendar(), Str(GNum))
      CopyList(Calendar()\Event\Entries(), Entries())
      SortStructuredList(Entries(), #PB_Sort_Ascending, OffsetOf(Entries_Structure\StartDate), TypeOf(Entries_Structure\StartDate))
    EndIf
    
  EndProcedure
  
  Procedure.i EventDayOfMonth(GNum.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Calendar()\Event\Day
    EndIf
    
  EndProcedure
  
  Procedure.i EventDate(GNum.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Date_(Calendar()\Event\Year, Calendar()\Event\Month, Calendar()\Event\Day)
    EndIf
    
  EndProcedure
  
  Procedure.i Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Flags.i=#False, WindowNum.i=#PB_Default)
    Define d, m, DummyNum, Result.i
    
    Result = CanvasGadget(GNum, X, Y, Width, Height, #PB_Canvas_Container)
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(Calendar(), Str(GNum))
        
        Calendar()\CanvasNum = GNum
      
        CompilerIf Defined(ModuleEx, #PB_Module) ; WindowNum = #Default
          If WindowNum = #PB_Default
            Calendar()\Window\Num = ModuleEx::GetGadgetWindow()
          Else
            Calendar()\Window\Num = WindowNum
          EndIf
        CompilerElse
          If WindowNum = #PB_Default
            Calendar()\Window\Num = GetActiveWindow()
          Else
            Calendar()\Window\Num = WindowNum
          EndIf
        CompilerEndIf
        
        CompilerSelect #PB_Compiler_OS           ;{ Default Gadget Font
          CompilerCase #PB_OS_Windows
            Calendar()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            DummyNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If DummyNum
              Calendar()\FontID = GetGadgetFont(DummyNum)
              FreeGadget(DummyNum)
            EndIf
          CompilerCase #PB_OS_Linux
            Calendar()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        Calendar()\SpinNum = SpinGadget(#PB_Any, 0, 0, 0, 0, 1900, 2100, #PB_Spin_Numeric|#PB_Spin_ReadOnly)
        If Calendar()\SpinNum
          HideGadget(Calendar()\SpinNum, #True)
        EndIf
        
        MonthNames(CountryCode)
        WeekDayNames_(CountryCode)
        
        Calendar()\ListNum = ListViewGadget(#PB_Any, 0, 0, 0, 0)
        If Calendar()\ListNum
          SetGadgetData(Calendar()\ListNum, Calendar()\CanvasNum)
          HideGadget(Calendar()\ListNum, #True)
          For m=1 To 12
            AddGadgetItem(Calendar()\ListNum, -1, Calendar()\Month\Name(Str(m)))
          Next
        EndIf
        
        CloseGadgetList()
        
        Calendar()\EntryFontID = Calendar()\FontID
        
        Calendar()\Size\X = X
        Calendar()\Size\Y = Y
        Calendar()\Size\Width  = Width
        Calendar()\Size\Height = Height
        
        Calendar()\Margin\Left   = 0
        Calendar()\Margin\Right  = 0
        Calendar()\Margin\Top    = 0
        Calendar()\Margin\Bottom = 0
        
        Calendar()\Month\Spacing     = dpiY(5)
        Calendar()\Month\defHeight   = #PB_Default
        Calendar()\Month\Color\Front = #PB_Default
        Calendar()\Month\Color\Back  = #PB_Default
        
        Calendar()\Week\defHeight    = #PB_Default
        Calendar()\Week\Color\Front  = #PB_Default
        Calendar()\Week\Color\Back   = #PB_Default
        
        Calendar()\TimeMask = "%hh:%ii"
        Calendar()\DateMask = "%dd/%mm/%yyyy"
        
        Calendar()\Flags  = Flags
        
        If Calendar()\Flags & #PostEvent
          Calendar()\Month\Flags | #PostEvent
          Calendar()\Year\Flags  | #PostEvent
        EndIf
        
        Calendar()\ReDraw = #True
        
        Calendar()\Color\Arrow      = $C8C8C8
        Calendar()\Color\Back       = $FFFFFF
        Calendar()\Color\Border     = $A0A0A0
        Calendar()\Color\Gadget     = $EDEDED
        Calendar()\Color\GreyText   = $6D6D6D
        Calendar()\Color\Focus      = $D77800
        Calendar()\Color\Front      = $000000
        Calendar()\Color\Line       = $B4B4B4
        
        Calendar()\Color\EntryFront = $0000CC
        Calendar()\Color\EntryBack  = $FFFFFF
        
        CompilerSelect #PB_Compiler_OS ;{ Color
          CompilerCase #PB_OS_Windows
            Calendar()\Color\Back       = GetSysColor_(#COLOR_WINDOW)
            Calendar()\Color\Border     = GetSysColor_(#COLOR_WINDOWFRAME)
            Calendar()\Color\Focus      = GetSysColor_(#COLOR_MENUHILIGHT)
            Calendar()\Color\Front      = GetSysColor_(#COLOR_WINDOWTEXT)
            Calendar()\Color\Gadget     = GetSysColor_(#COLOR_MENU)
            Calendar()\Color\Line       = GetSysColor_(#COLOR_ACTIVEBORDER)
            Calendar()\Color\EntryBack  = Calendar()\Color\Back
          CompilerCase #PB_OS_MacOS
            Calendar()\Color\Back       = BlendColor_(OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textBackgroundColor")), $FFFFFF, 80)
            Calendar()\Color\Border     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            Calendar()\Color\Gadget     = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            Calendar()\Color\Focus      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor selectedControlColor"))
            Calendar()\Color\Front      = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            Calendar()\Color\Line       = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor grayColor"))
            Calendar()\Color\EntryBack  = Calendar()\Color\Back
          CompilerCase #PB_OS_Linux

        CompilerEndSelect ;} 
        
        BindGadgetEvent(Calendar()\CanvasNum,  @_ResizeHandler(),          #PB_EventType_Resize)
        BindGadgetEvent(Calendar()\CanvasNum,  @_RightClickHandler(),      #PB_EventType_RightClick)
        BindGadgetEvent(Calendar()\CanvasNum,  @_LeftDoubleClickHandler(), #PB_EventType_LeftDoubleClick)
        BindGadgetEvent(Calendar()\CanvasNum,  @_MouseMoveHandler(),       #PB_EventType_MouseMove)
        BindGadgetEvent(Calendar()\CanvasNum,  @_LeftButtonDownHandler(),  #PB_EventType_LeftButtonDown)
        BindGadgetEvent(Calendar()\CanvasNum,  @_LeftButtonUpHandler(),    #PB_EventType_LeftButtonUp)
        
        If IsGadget(Calendar()\ListNum)
          BindGadgetEvent(Calendar()\ListNum, @_ListGadgetHandler(), #PB_EventType_LeftClick)
        EndIf 
      
        If Flags & #AutoResize ;{ Enabel AutoResize
          If IsWindow(Calendar()\Window\Num)
            Calendar()\Window\Width  = WindowWidth(Calendar()\Window\Num)
            Calendar()\Window\Height = WindowHeight(Calendar()\Window\Num)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), Calendar()\Window\Num)
          EndIf  
        EndIf ;}
        
        CompilerIf Defined(ToolTip, #PB_Module)
          Calendar()\TooltipNum = ToolTip::Create(Calendar()\CanvasNum, Calendar()\Window\Num)
          If Calendar()\TooltipNum
            ToolTip::SetColor(Calendar()\CanvasNum, ToolTip::#BorderColor,      $800000)
            ToolTip::SetColor(Calendar()\CanvasNum, ToolTip::#BackColor,        $FFFFFA)
            ToolTip::SetColor(Calendar()\CanvasNum, ToolTip::#TitleBorderColor, $800000)
            ToolTip::SetColor(Calendar()\CanvasNum, ToolTip::#TitleBackColor,   $B48246)
            ToolTip::SetColor(Calendar()\CanvasNum, ToolTip::#TitleColor,       $FFFFFF)
          EndIf
        CompilerEndIf
        
        Draw_()
        
        ProcedureReturn Calendar()\CanvasNum
      EndIf
     
    EndIf
    
  EndProcedure    
  
  Procedure.q GetDate(Day.i, Month.i, Year.i, Hour.i=0, Minute.i=0, Second.i=0)
 
    ProcedureReturn Date_(Year, Month, Day, Hour, Minute, Second)

  EndProcedure
  
  Procedure.i GetDay(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Day_(Calendar()\Current\Focus)
    EndIf
    
  EndProcedure
  
  Procedure.i GetEntries(GNum.i, Date.q, List Entries.Entries_Structure()) 
    
    If FindMapElement(Calendar(), Str(GNum))
      
      ClearList(Entries())
      
      ForEach Calendar()\Entries()
        
        If Date >= Calendar()\Entries()\StartDate And Date <= Calendar()\Entries()\EndDate
          
          If AddElement(Entries())
            Entries()\Label       = MapKey(Calendar()\Entries())
            Entries()\StartDate   = Calendar()\Entries()\StartDate
            Entries()\EndDate     = Calendar()\Entries()\EndDate
            Entries()\Summary     = Calendar()\Entries()\Summary
            Entries()\Description = Calendar()\Entries()\Description
            Entries()\Location    = Calendar()\Entries()\Location
            Entries()\Flags       = Calendar()\Entries()\Flags
          EndIf  
          
        EndIf
        
      Next
      
      SortStructuredList(Entries(), #PB_Sort_Ascending, OffsetOf(Entries_Structure\StartDate), TypeOf(Entries_Structure\StartDate))

    EndIf
    
    ProcedureReturn ListSize(Entries())
  EndProcedure
  
  Procedure.i GetMonth(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Month_(Calendar()\Current\Focus)
    EndIf
    
  EndProcedure
  
  Procedure.i GetYear(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Year_(Calendar()\Current\Focus)
    EndIf
    
  EndProcedure
  
  Procedure.i GetState(GNum.i) 
    
    If FindMapElement(Calendar(), Str(GNum))
      ProcedureReturn Calendar()\Current\Focus
    EndIf
    
  EndProcedure  
  
  Procedure   RemoveEntry(GNum.i, Label.s)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If FindMapElement(Calendar()\Entries(), Label)
        DeleteMapElement(Calendar()\Entries())
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select Attribute
        Case #Spacing
          Calendar()\Month\Spacing   = dpiX(Value)
        Case #Height_Month
          Calendar()\Month\defHeight = dpiY(Value)
        Case #Height_WeekDays
          Calendar()\Week\defHeight  = dpiY(Value)
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf  
    
  EndProcedure 
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Calendar()\Size\Flags = Flags
      Calendar()\Flags | #AutoResize
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Value.i)
    
    If FindMapElement(Calendar(), Str(GNum))
    
      Select ColorType
        Case #ArrowColor
          Calendar()\Color\Arrow       = Value  
        Case #BackColor
          Calendar()\Color\Back        = Value
        Case #BorderColor
          Calendar()\Color\Border      = Value          
        Case #FrontColor
          Calendar()\Color\Front       = Value        
        Case #FocusColor
          Calendar()\Color\Focus       = Value
        Case #GreyTextColor
          Calendar()\Color\GreyText    = Value
        Case #LineColor
          Calendar()\Color\Line        = Value
        Case #Entry_FrontColor
          Calendar()\Color\EntryFront  = Value
        Case #Entry_BackColor
          Calendar()\Color\EntryBack   = Value
        Case #Month_FrontColor
          Calendar()\Month\Color\Front = Value
          ;If IsGadget(Calendar()\SpinNum) : SetGadgetColor(Calendar()\SpinNum, #PB_Gadget_FrontColor, Value) : EndIf
        Case #Month_BackColor
          Calendar()\Month\Color\Back  = Value
          ;If IsGadget(Calendar()\SpinNum) : SetGadgetColor(Calendar()\SpinNum, #PB_Gadget_BackColor, Value) : EndIf
        Case #Week_FrontColor
          Calendar()\Week\Color\Front  = Value
        Case #Week_BackColor  
          Calendar()\Week\Color\Back   = Value
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetDate(GNum.i, Year.i, Month.i, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)

    If FindMapElement(Calendar(), Str(GNum))
      
      Calendar()\Current\Date  = Date_(Year, Month, Day, Hour, Minute, Second)
      Calendar()\Current\Focus = Calendar()\Current\Date
      Calendar()\Current\Month = Month_(Calendar()\Current\Date)
      Calendar()\Current\Year  = Year_(Calendar()\Current\Date)
      
      UpdateCurrentEntries_()
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure
  
  Procedure   SetEntryColor(GNum.i, Label.s, ColorType.i, Value.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If FindMapElement(Calendar()\Entries(), Label)
        
        Select ColorType
          Case #Entry_FrontColor, #FrontColor
            Calendar()\Entries()\FrontColor = Value
          Case #Entry_BackColor, #BackColor
            Calendar()\Entries()\BackColor  = Value
        EndSelect
        
        UpdateCurrentEntries_()
        
        If Calendar()\ReDraw : Draw_() : EndIf
        
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetEntryMask(GNum.i, Label.s, String.s)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If FindMapElement(Calendar()\Entries(), Label)
        
        Calendar()\Entries()\ToolTipMask = String
        
        UpdateCurrentEntries_()
        
        If Calendar()\ReDraw : Draw_() : EndIf
        
      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   SetFlags(GNum.i, Type.i, Flags.i)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select Type
        Case #Month
          Calendar()\Month\Flags | Flags
        Case #Year
          Calendar()\Year\Flags  | Flags
        Case #Gadget
          Calendar()\Flags | Flags
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf 
    
  EndProcedure
  
  Procedure   SetFont(GNum.i, FontNum.i, FontType.i=#Font_Gadget) 
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select FontType
        Case #Font_Month
          Calendar()\Month\Font  = FontNum
        Case #Font_Weekdays
          Calendar()\Week\Font   = FontNum
        Case #Font_ToolTip
          CompilerIf Defined(ToolTip, #PB_Module)
            ToolTip::SetFont(Calendar()\CanvasNum, FontNum, ToolTip::#Title)
          CompilerEndIf  
        Case #Font_Entry
          Calendar()\EntryFontID = FontID(FontNum)
        Default
          Calendar()\FontID      = FontID(FontNum)
      EndSelect
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   SetMask(GNum.i, Type.i, String.s)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Select Type
        Case #Date
          Calendar()\DateMask     = String
        Case #Time
          Calendar()\TimeMask     = String
        Case #ToolTipText
          Calendar()\ToolTipText  = String
        Case #ToolTipTitle
          Calendar()\ToolTipTitle = String
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure   SetState(GNum.i, Date.q) 
    
    If FindMapElement(Calendar(), Str(GNum))
      
      Calendar()\Current\Date  = Date
      Calendar()\Current\Focus = Date
      Calendar()\Current\Month = Month_(Date)
      Calendar()\Current\Year  = Year_(Date)
      
      UpdateCurrentEntries_()
      
      If Calendar()\ReDraw : Draw_() : EndIf
    EndIf
    
  EndProcedure  
  
  Procedure   ToolTipText(GNum.i, String.s) 
    
    If FindMapElement(Calendar(), Str(GNum))
      Calendar()\ToolTipText = String
    EndIf  
    
  EndProcedure  

  Procedure   MonthName(Month.i, Name.s)
    If Month >= 1 And Month <= 12
      NameOfMonth(Str(Month)) = Name
    EndIf
  EndProcedure
  
  Procedure   UpdatePopupText(GNum.i, MenuItem.i, Text.s)
    
    If FindMapElement(Calendar(), Str(GNum))
      
      If AddMapElement(Calendar()\PopUpItem(), Str(MenuItem))
        Calendar()\PopUpItem() = Text
      EndIf 
      
    EndIf
    
  EndProcedure
  
  Procedure   WeekDayName(WeekDay.i, Name.s)
    If WeekDay >= 0 And WeekDay <= 7
      If WeekDay = 0
        NameOfWeekDay("7") = Name
      Else
        NameOfWeekDay(Str(WeekDay)) = Name
      EndIf
    EndIf
  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 0
  
  ; Example 1: Default 
  ; Example 2: #GreyedDays
  ; Example 3: Colors
  
  ;Calendar::DefaultCountry("DE")
  
  Enumeration 1
    #Window
    #Calendar
    #PopUpMenu
    #ExportEvent
    #ShowEntries
  EndEnumeration
  
  Enumeration 1
    #FontGadget
    #FontMonth
    #FontWeekDays
  EndEnumeration  
  
  LoadFont(#FontMonth,    "Arial", 11, #PB_Font_Bold)
  LoadFont(#FontWeekDays, "Arial",  9, #PB_Font_Bold)
  
  NewList Entries.Calendar::Entries_Structure()
  
  If OpenWindow(#Window, 0, 0, 300, 200, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    If CreatePopupMenu(#PopUpMenu)
      MenuItem(#ExportEvent, "Export calendar entries")
      MenuBar()
      MenuItem(#ShowEntries, "Show calendar entries")
    EndIf
    
    If Calendar::Gadget(#Calendar, 10, 10, 280, 180, #False, #Window) ; Calendar::#PostEvent|Calendar::#FixDayOfMonth|Calendar::#FixMonth|Calendar::#FixYear
      
      Calendar::AttachPopupMenu(#Calendar, #PopUpMenu)
      
      Calendar::SetFont(#Calendar, #FontMonth, Calendar::#Font_Month)
      Calendar::SetAttribute(#Calendar, Calendar::#Height_Month, 28)
      
      Calendar::SetFont(#Calendar, #FontWeekDays, Calendar::#Font_Weekdays)
      Calendar::SetAttribute(#Calendar, Calendar::#Height_WeekDays, 22)
      
      Calendar::UpdatePopupText(#Calendar, #ExportEvent, "Export calendar entries for '" + Calendar::#Date$ + "'.")
      Calendar::UpdatePopupText(#Calendar, #ShowEntries, "Show calendar entries for '"   + Calendar::#Date$ + "'.")
      
      Calendar::SetState(#Calendar, Date())
      
      CompilerSelect #Example
        CompilerCase 2
          Calendar::SetFlags(#Calendar, Calendar::#Gadget, Calendar::#GreyedDays)
        CompilerCase 3
          Calendar::SetColor(#Calendar, Calendar::#Month_FrontColor, $FFF8F0)
          Calendar::SetColor(#Calendar, Calendar::#Month_BackColor,  $701919)
          Calendar::SetColor(#Calendar, Calendar::#Week_FrontColor,  $701919)
          Calendar::SetColor(#Calendar, Calendar::#Week_BackColor,   $FFFAF6)
          Calendar::SetColor(#Calendar, Calendar::#FocusColor,       $00FC7C)
          ;Calendar::SetColor(#Calendar, Calendar::#Entry_BackColor, $9595FF)
          Calendar::SetFlags(#Calendar, Calendar::#Gadget, Calendar::#GreyedDays)
        CompilerDefault
          Calendar::SetColor(#Calendar, Calendar::#Month_FrontColor, $FFF8F0)
          Calendar::SetColor(#Calendar, Calendar::#Month_BackColor,  $701919)
          Calendar::SetColor(#Calendar, Calendar::#Week_FrontColor,  $701919)
          Calendar::SetColor(#Calendar, Calendar::#Week_BackColor,   $FFFAF6)
          
          Calendar::SetFont(#Calendar, #FontWeekDays, Calendar::#Font_Entry)
          Calendar::SetFlags(#Calendar, Calendar::#Gadget, Calendar::#GreyedDays)
          
          Calendar::SetMask(#Calendar, Calendar::#ToolTipText, Calendar::#Summary$ + ": " + Calendar::#Label$)
          Calendar::SetMask(#Calendar, Calendar::#Date, "%dd.%mm.%yyyy")
          
          Calendar::AddEntry(#Calendar, "Thorsten", "Birthday", "", "", Calendar::GetDate(18, 7, 2019))
          Calendar::AddEntry(#Calendar, "Entry 2",  "2nd appointment",  "", "", Calendar::GetDate(18, 7, 2019, 8), Calendar::GetDate(18, 7, 2019, 11, 15), Calendar::#Duration)
          Calendar::AddEntry(#Calendar, "Entry 3",  "3rd appointment",  "", "", Calendar::GetDate(18, 7, 2019, 15, 30), #PB_Default, Calendar::#StartTime)

          Calendar::AddEntry(#Calendar, "Holidy", "Holiday: Summer", "", "", Calendar::GetDate(27, 7, 2019), Calendar::GetDate(9, 8, 2019))
          Calendar::SetEntryColor(#Calendar, "Holidy", Calendar::#FrontColor, $008000)
          Calendar::SetEntryColor(#Calendar, "Holidy", Calendar::#BackColor,  $61FFC1)
          Calendar::SetEntryMask(#Calendar, "Holidy",  "Holiday: " + Calendar::#StartDate$ + " - " + Calendar::#EndDate$)
          
      CompilerEndSelect

    EndIf
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case Calendar::#Event_Gadget ;{ Module Events
          Select EventGadget()  
            Case #Calendar
              Select EventType()
                Case Calendar::#EventType_Month
                  ; 
                Case Calendar::#EventType_Year
                  
                Case Calendar::#EventType_Day
                  Debug "Day: " + Str(EventData())   
                Case Calendar::#EventType_Focus
                  Debug "Focus: " + Str(EventData()) 
            EndSelect
          EndSelect ;}
        Case #PB_Event_Menu          ;{ PopupMenu
          Select EventMenu()
            Case  #ExportEvent
              Debug "Export calendar entries: " + FormatDate("%dd/%mm/%yyyy",  Calendar::EventDate(#Calendar))
              DayOfMonth.i = Calendar::EventDayOfMonth(#Calendar)
              Calendar::ExportDay(#Calendar, DayOfMonth, "iCal_Export.ics")
            Case #ShowEntries  
              Debug "Show calendar entries: "
              Calendar::EventEntries(#Calendar, Entries())
              ForEach Entries()
                Debug "> " + FormatDate("%dd/%mm/%yyyy",  Entries()\StartDate) + ": " +  Entries()\Summary
              Next
          EndSelect ;}
        Case #PB_Event_Gadget  
          Select EventGadget()
            Case #Calendar           ;{ only in use with EventType()  
              Select EventType()
                Case Calendar::#EventType_Month
                  Debug "Select: Month"
                Case Calendar::#EventType_Year
                  Debug "Select: Year" 
              EndSelect ;}
          EndSelect  
      EndSelect        
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf
