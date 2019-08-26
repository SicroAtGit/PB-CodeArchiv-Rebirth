;   Description: Support for enlarged date range (64 bit unix timestamp)
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=26001&start=50
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72722&start=15#p538578
;-----------------------------------------------------------------------------

;/ ============================
;/ =    Date64Module.pbi    =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS ]
;/
;/ Support for enlarged date range (64 bit unix timestamp)
;/
;/ based on 'Module Date64' by mk-soft / Sicro / ts-soft / wilbert
;/
;/ adapted from Thorsten Hoeppner (07/2019)
;/

;{ ===== MIT License =====
;
; Copyright (c) 2012 mk-soft
; Copyright (c) 2013-2017 Sicro
; Copyright (c) 2014 ts-soft
; Copyright (c) 2017 wilbert
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


; !!! >>> WARNING <<< !!!
; The Gregorian calendar was introduced in many regions at different times.
; This module uses the API date functions of the operating system and these have implemented a
; uniform introduction time, so that date calculations before the introduction of the Gregorian
; calendar usually lead to wrong results.


;{ _____ Date64 - Commands _____

; Date64::AddDate_()     - similar to AddDate()
; Date64::Date_()        - similar to Date()
; Date64::Day_()         - similar to Day()
; Date64::DayOfWeek_()   - similar to DayOfWeek() 
; Date64::DayOfYear_()   - similar to DayOfYear()
; Date64::DaysInMonth_() - number of days of this month
; Date64::FormatDate_()  - similar to FormatDate()
; Date64::Minute_()      - similar to Minute()
; Date64::Month_()       - similar to Month()
; Date64::Hour_()        - similar to Hour()
; Date64::IsLeapYear_()  - check whether it is a leap year
; Date64::ParseDate_()   - similar to ParseDate()
; Date64::Second_()      - similar to Second()
; Date64::Year_()        - similar to Year()

;}


DeclareModule Date64

	;- ===========================================================================
	;-   DeclareModule
	;- ===========================================================================
  
  Declare.q AddDate_(Date.q, Type.i, Value.i)
  Declare.q Date_(Year.i=#PB_Default, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
  Declare.i Day_(Date.q)
  Declare.i DayOfWeek_(Date.q)
  Declare.i DayOfYear_(Date.q)
  Declare.i DaysInMonth_(Year.i, Month.i)
  Declare.s FormatDate_(Mask.s, Date.q) 
  Declare.i Minute_(Date.q)
  Declare.i Month_(Date.q)
  Declare.i Hour_(Date.q)
  Declare.i IsLeapYear_(Year.i)
  Declare.q ParseDate_(Mask.s, Date.s)
  Declare.i Second_(Date.q)
  Declare.i Year_(Date.q)

EndDeclareModule

Module Date64

	EnableExplicit

	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	; Seconds
  #Seconds_Hour = 60 * 60                  ; Seconds in an hour
  #Seconds_Day  = #Seconds_Hour * 24       ; Seconds in a day
  
  ; Nanoseconds
  #Nano100_Second     = 10000000           ; hundred nanoseconds in a second.
  #Nano100_1601To1970 = 116444736000000000 ; hundred nanoseconds from 1. Jan. 1601 to 1. Jan. 1970

	;- ============================================================================
	;-   Module - Structures
	;- ============================================================================

  CompilerSelect #PB_Compiler_OS ;{ OS specific
    CompilerCase #PB_OS_Windows
      
      ; >> Minimum: 01.01.1601 00:00:00
      ; >> Maximum: 31.12.9999 23:59:59
      
    CompilerCase #PB_OS_Linux
      
      ; 32-Bit:
      ; >> Minimum: 01.01.1902 00:00:00
      ; >> Maximum: 18.01.2038 23:59:59
      ; 64-Bit:
      ; >> Minimum: 01.01.0000 00:00:00
      ; >> Maximum: 31.12.9999 23:59:59
      
      If Not Defined(tm, #PB_Structure)
        
        Structure tm Align #PB_Structure_AlignC
          tm_sec.l
          tm_min.l
          tm_hour.l
          tm_mday.l
          tm_mon.l
          tm_year.l
          tm_wday.l
          tm_yday.l
          tm_isdst.l
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
            tm_gmtoff.l
            *tm_zone
          CompilerElse
            tm_zone.l
            tm_gmtoff.l
            *tm_zone64
          CompilerEndIf
        EndStructure
        
      EndIf
      
    CompilerCase #PB_OS_MacOS
      
      ; >> Minimum: 31.12.1969 23:59:59
      ; >> Maximum: 31.12.9999 23:59:59
      
      ImportC ""
        CFCalendarAddComponents(calendar, *at, options, componentDesc.p-ascii, value)
        CFCalendarComposeAbsoluteTime(calendar, *at, componentDesc.p-ascii, year, month, day, hour, minute, second)
        CFCalendarCreateWithIdentifier(allocator, identifier)
        CFCalendarDecomposeAbsoluteTime(calendar, at.d, componentDesc.p-ascii, *component)
        CFCalendarSetTimeZone(calendar, tz)
        CFTimeZoneCopyDefault()
        CFTimeZoneCreateWithTimeIntervalFromGMT(allocator, ti.d)
        CFTimeZoneGetSecondsFromGMT.d(tz, at.d)
      EndImport
  
      Global.i GregorianGMT, TimeZone
  
      Procedure Date64Init(); Init global variables GregorianGMT and TimeZone
        Protected *kCFGregorianCalendar.Integer = dlsym_(#RTLD_DEFAULT, "kCFGregorianCalendar")
        TimeZone = CFTimeZoneCreateWithTimeIntervalFromGMT(0, 0)
        GregorianGMT = CFCalendarCreateWithIdentifier(0, *kCFGregorianCalendar\i)
        CFCalendarSetTimeZone(GregorianGMT, TimeZone)
        CFRelease_(TimeZone)
        TimeZone = CFTimeZoneCopyDefault()
      EndProcedure
  
      Date64Init()
      
  CompilerEndSelect ;}

	;- ============================================================================
	;-   Module - Internal
	;- ============================================================================

  Macro Windows_ReturnDatePart(Type)
    Define st.SYSTEMTIME

    Date = Date * #Nano100_Second + #Nano100_1601To1970
    FileTimeToSystemTime_(@Date, @st)

    ProcedureReturn st\Type
  EndMacro
  
  Macro Linux_ReturnDatePart(Type, ReturnCode)
    Define   *tm.tm
    Define.i Value

    *tm = gmtime_(@Date)
    If *tm
      Value = *tm\Type
    EndIf

    ProcedureReturn ReturnCode
  EndMacro
  
  Macro Mac_ReturnDatePart(Type)
    Define.i DatePart

    CFCalendarDecomposeAbsoluteTime(GregorianGMT, Date - 978307200, Type, @DatePart)

    CompilerIf Type = "E"
      ProcedureReturn DatePart - 1
    CompilerElse
      ProcedureReturn DatePart
    CompilerEndIf
  EndMacro
  
  Macro ReadMaskVariable(MaskVariable, ReturnVariable)
    If Mid(Mask, i, 3) = MaskVariable
      IsVariableFound = #True
      ReturnVariable = Val(Mid(Date$, DatePos, 2))
      DatePos + 2 ; Skip the 2 numbers of the number
      i + 2       ; Skip the 3 characters of the variable
      Continue
    EndIf
  EndMacro
  
  
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  Procedure.i IsLeapYear_(Year.i)
    If Year < 1600
      ProcedureReturn Bool(Year % 4 = 0)
    Else
      ProcedureReturn Bool((Year % 4 = 0 And Year % 100 <> 0) Or Year % 400 = 0)
    EndIf
  EndProcedure
  
  Procedure.i DaysInMonth_(Year.i, Month.i)
    
    While Month > 12 : Month - 12 : Wend
    
    While Month <  0 
      Year  - 1
      Month + 13
    Wend
    
    If Month = 0 : Month = 1 : EndIf

    Select Month
      Case 1, 3, 5, 7, 8, 10, 12
        ProcedureReturn 31
      Case 4, 6, 9, 11
        ProcedureReturn 30
      Case 2
        ProcedureReturn 28 + IsLeapYear_(Year)
    EndSelect
    
  EndProcedure
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      
      Procedure.q Date_(Year.i=-1, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
        Define   st.SYSTEMTIME
        Define   ft.FILETIME, ft2.FILETIME
        Define.i DaysInMonth

        If Year > -1 ; Valid date

          Minute + Second / 60
          Second % 60
          If Second < 0
            Minute - 1
            Second + 60
          EndIf

          Hour + Minute / 60
          Minute % 60
          If Minute < 0
            Hour   - 1
            Minute + 60
          EndIf

          Day + Hour / 24
          Hour % 24
          If Hour < 0
            Day  - 1
            Hour + 24
          EndIf

          While Month > 12
            Year  + 1
            Month - 12
          Wend

          DaysInMonth = DaysInMonth_(Year, Month)
          While Day > DaysInMonth
            Day - DaysInMonth
            Month + 1
            If Month > 12
              Year  + 1
              Month - 12
            EndIf
            DaysInMonth = DaysInMonth_(Year, Month)
          Wend

          If Day < 0
            Month - 1
            If Month = 0
              Year  - 1
              Month = 12
            EndIf
            Day + DaysInMonth_(Year, Month)
          EndIf
          
          ; Bugfixes for AddDate() with result 0
          If Day = 0
            Month - 1
            Day = DaysInMonth_(Year, Month)
          EndIf

          If Month = 0
            Year - 1
            Month = 12
          EndIf
          
          st\wYear   = Year
          st\wMonth  = Month
          st\wDay    = Day
          st\wHour   = Hour
          st\wMinute = Minute
          st\wSecond = Second

          SystemTimeToFileTime_(@st, @ft) ; Convert system time (UTC) to file time (UTC)

          ProcedureReturn (PeekQ(@ft) - #Nano100_1601To1970) / #Nano100_Second ; Convert UTC time to seconds
        Else
          
          GetLocalTime_(@st)              ; No valid date. Local system time is determined
          SystemTimeToFileTime_(@st, @ft) ; "st" is read as UTC and convert to file time

          ProcedureReturn (PeekQ(@ft) - #Nano100_1601To1970) / #Nano100_Second ; Convert UTC time to seconds
        EndIf
        
      EndProcedure
      
    CompilerCase #PB_OS_Linux

      Procedure.q Date_(Year.i=-1, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
        Define   tm.tm
        Define.q time
          
        If Year > -1 ; Valid date
          tm\tm_year  = Year - 1900 ; Years from 1900
          tm\tm_mon   = Month - 1   ; Months from January
          tm\tm_mday  = Day
          tm\tm_hour  = Hour
          tm\tm_min   = Minute
          tm\tm_sec   = Second

          time = timegm_(@tm) ; Convert structured UTC time to UTC time as seconds

          ProcedureReturn time ; UTC time in seconds
        Else
          
          time = time_(0)
          If localtime_r_(@time, @tm) <> 0
            time = timegm_(@tm)
          EndIf

          ProcedureReturn time ; UTC time in seconds
        EndIf
        
      EndProcedure
      
    CompilerCase #PB_OS_MacOS
      
      Procedure.q Date_(Year.i=-1, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
        Define.d at
        
        If Year > -1 ; Valid date
          CFCalendarComposeAbsoluteTime(GregorianGMT, @at, "yMdHms", Year, Month, Day, Hour, Minute, Second)
        Else 
          at = CFAbsoluteTimeGetCurrent_()
          at + CFTimeZoneGetSecondsFromGMT(TimeZone, at)
        EndIf
        
        ProcedureReturn at + 978307200
      EndProcedure
      
  CompilerEndSelect
  
  
  Procedure.i Year_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wYear)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_year, Value + 1900)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("y")
    CompilerEndSelect
  EndProcedure
  
  Procedure.i Month_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wMonth)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_mon, Value + 1)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("M")
    CompilerEndSelect
  EndProcedure
  
  Procedure.i Day_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wDay)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_mday, Value)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("d")
    CompilerEndSelect
  EndProcedure
  
  Procedure.i Hour_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wHour)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_hour, Value)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("H")
    CompilerEndSelect
  EndProcedure
 
  Procedure.i Minute_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wMinute)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_min, Value)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("m")
    CompilerEndSelect
  EndProcedure
 
  Procedure.i Second_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wSecond)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_sec, Value)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("s")
    CompilerEndSelect
  EndProcedure
  
  Procedure.i DayOfWeek_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Windows_ReturnDatePart(wDayOfWeek)
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_wday, Value)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("E")
    CompilerEndSelect
  EndProcedure
 
  Procedure.i DayOfYear_(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Define.q TempDate
        TempDate = Date_(Year_(Date))
        ProcedureReturn (Date - TempDate) / #Seconds_Day + 1
      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_yday, Value + 1)
      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("D")
    CompilerEndSelect
  EndProcedure
  
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    
    Procedure.q AddDate_Date.q, Type.i, Value.i)
      Define.d at
      
      at = Date - 978307200
      
      Select Type
        Case #PB_Date_Year
          CFCalendarAddComponents(GregorianGMT, @at, 0, "y", Value)
        Case #PB_Date_Month
          CFCalendarAddComponents(GregorianGMT, @at, 0, "M", Value)
        Case #PB_Date_Week
          CFCalendarAddComponents(GregorianGMT, @at, 0, "d", Value * 7)
        Case #PB_Date_Day
          CFCalendarAddComponents(GregorianGMT, @at, 0, "d", Value)
        Case #PB_Date_Hour
          CFCalendarAddComponents(GregorianGMT, @at, 0, "H", Value)
        Case #PB_Date_Minute
          CFCalendarAddComponents(GregorianGMT, @at, 0, "m", Value)
        Case #PB_Date_Second
          CFCalendarAddComponents(GregorianGMT, @at, 0, "s", Value)
      EndSelect

      ProcedureReturn at + 978307200 
    EndProcedure
    
  CompilerElse ; Windows or Linux
    
    Procedure.q AddDate_(Date.q, Type.i, Value.i)
      Define.i Day, Month, Year

      Select Type
        Case #PB_Date_Year
          
          ProcedureReturn Date_(Year_(Date) + Value, Month_(Date), Day_(Date), Hour_(Date), Minute_(Date), Second_(Date))
          
        Case #PB_Date_Month
          
          Day   = Day_(Date)
          Month = Month_(Date) + Value
          Year  = Year_(Date)

          If Day > DaysInMonth_(Year, Month)
            Day = DaysInMonth_(Year, Month) ; Set day to the maximum of the new month
          EndIf

          ProcedureReturn Date_(Year_(Date), Month, Day, Hour_(Date), Minute_(Date), Second_(Date))

        Case #PB_Date_Week
          
          ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date) + Value * 7, Hour_(Date), Minute_(Date), Second_(Date))
          
        Case #PB_Date_Day
          
          ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date) + Value, Hour_(Date), Minute_(Date), Second_(Date))
          
        Case #PB_Date_Hour
          
          ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date), Hour_(Date) + Value, Minute_(Date), Second_(Date))
          
        Case #PB_Date_Minute
          
          ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date), Hour_(Date), Minute_(Date) + Value, Second_(Date))
          
        Case #PB_Date_Second
          
          ProcedureReturn Date_(Year_(Date), Month_(Date), Day_(Date), Hour_(Date), Minute_(Date), Second_(Date) + Value)
          
      EndSelect
      
    EndProcedure  
 
  CompilerEndIf

  Procedure.s FormatDate_(Mask.s, Date.q)
    Define.s Result$

    Result$ = ReplaceString(Mask,   "%yyyy", RSet(Str(Year_(Date)),           4, "0"))
    Result$ = ReplaceString(Result$, "%yy",  RSet(Right(Str(Year_(Date)), 2), 2, "0"))
    Result$ = ReplaceString(Result$, "%mm",  RSet(Str(Month_(Date)),          2, "0"))
    Result$ = ReplaceString(Result$, "%dd",  RSet(Str(Day_(Date)),            2, "0"))
    Result$ = ReplaceString(Result$, "%hh",  RSet(Str(Hour_(Date)),           2, "0"))
    Result$ = ReplaceString(Result$, "%ii",  RSet(Str(Minute_(Date)),         2, "0"))
    Result$ = ReplaceString(Result$, "%ss",  RSet(Str(Second_(Date)),         2, "0"))

    ProcedureReturn Result$
  EndProcedure
 
  Procedure.q ParseDate_(Mask.s, Date$)
    Define.i i, DatePos, IsVariableFound, Year, Month, Day, Hour, Minute, Second
    Define.s MaskChar$, DateChar$
    
    DatePos = 1
    Month   = 1
    Day     = 1
    
    For i = 1 To Len(Mask)
      
      MaskChar$ = Mid(Mask, i, 1)
      DateChar$ = Mid(Date$, DatePos, 1)

      If MaskChar$ <> DateChar$
        
        If MaskChar$ = "%"

          If Mid(Mask, i, 5) = "%yyyy"
            IsVariableFound = #True
            Year = Val(Mid(Date$, DatePos, 4))
            DatePos + 4 ; Skip the 4 numbers of the year
            i + 4       ; Skip the 5 characters of the variable "%yyyy"
            Continue
          ElseIf Mid(Mask, i, 3) = "%yy"
            IsVariableFound = #True
            Year = Val(Mid(Date$, DatePos, 2))
            DatePos + 2 ; Skip the 2 numbers of the year
            i + 2       ; Skip the 3 characters of the variable "%yy"
            Continue
          EndIf

          ReadMaskVariable("%mm", Month)
          ReadMaskVariable("%dd", Day)
          ReadMaskVariable("%hh", Hour)
          ReadMaskVariable("%ii", Minute)
          ReadMaskVariable("%ss", Second)

          If Not IsVariableFound
            ProcedureReturn #False
          EndIf

        Else
          ProcedureReturn #False
        EndIf

      EndIf

      DatePos + 1
    Next

    ProcedureReturn Date_(Year, Month, Day, Hour, Minute, Second)
  EndProcedure
  
EndModule
  
;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Enable_SelfTest = #False  
  
  Define Event.i, Date.q
  
  Enumeration 
    #Window
    #Date
    #Button
    #Date64
    #Date32
    #Text
  EndEnumeration
  
  CompilerIf #Enable_SelfTest
    
    Procedure SelfTest(Minimum.s, Maximum.s)
      Define.s Result64$
      Define.q Date64
      
      Debug "---------------------"
      Debug "Self-Test"
      Debug "---------------------"
      Debug ""

      Date64    = Date64::ParseDate_("%dd.%mm.%yyyy %hh:%ii:%ss",  Minimum)
      Result64$ = Date64::FormatDate_("%dd.%mm.%yyyy %hh:%ii:%ss", Date64)
      
      If Minimum <> Result64$
        Debug "Minimum is wrong:"
        Debug "> Expected was: "    + Minimum
        Debug "> It was returned: " + Result64$
      Else
        Debug "Minimum:  " + Result64$
      EndIf
      
      Date64    = Date64::ParseDate_("%dd.%mm.%yyyy %hh:%ii:%ss",  Maximum)
      Result64$ = Date64::FormatDate_("%dd.%mm.%yyyy %hh:%ii:%ss", Date64)
      
      If Maximum <> Result64$
        Debug "Maximum is wrong:"
        Debug "> Expected was: "    + Maximum
        Debug "> It was returned: " + Result64$
      Else
        Debug "Maximum: " + Result64$
      EndIf
      
    EndProcedure
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        
        SelfTest("01.01.1601 00:00:00", "31.12.9999 23:59:59")
        
      CompilerCase #PB_OS_Linux
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
          
          SelfTest("01.01.1902 00:00:00", "18.01.2038 23:59:59")
          
        CompilerElse
          
          SelfTest("01.01.0000 00:00:00", "31.12.9999 23:59:59")
          
        CompilerEndIf
        
      CompilerCase #PB_OS_MacOS
        
        SelfTest("31.12.1969 23:59:59", "31.12.9999 23:59:59")
        
    CompilerEndSelect
    
  CompilerEndIf
  
  If OpenWindow(#Window, 0, 0, 220, 70, "Example", #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
    
    StringGadget(#Date64, 10, 10, 70, 20, "", #PB_String_ReadOnly)
    StringGadget(#Date32, 10, 40, 70, 20, "", #PB_String_ReadOnly)
    DateGadget(#Date, 85, 10, 80, 20, "%mm/%dd/%yyyy", Date())
    ButtonGadget(#Button, 170, 10, 30, 20, "OK")
    TextGadget(#Text, 85, 43, 100, 14, "( Date with 32-Bit )")
    
    Repeat
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button
              Date = Date64::ParseDate_("%mm/%dd/%yyyy", GetGadgetText(#Date))
              SetGadgetText(#Date64, Date64::FormatDate_("%mm/%dd/%yyyy", Date))
              Date = ParseDate("%mm/%dd/%yyyy", GetGadgetText(#Date))
              SetGadgetText(#Date32, FormatDate("%mm/%dd/%yyyy", Date))
          EndSelect
      EndSelect
    Until Event = #PB_Event_CloseWindow

    CloseWindow(#Window)
  EndIf 
  
CompilerEndIf
