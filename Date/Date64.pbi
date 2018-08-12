;   Description: Support for enlarged date range (64 bit unix timestamp)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=335727#p335727
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 mk-soft
; Copyright (c) 2013-2017 Sicro
; Copyright (c) 2014 ts-soft
; Copyright (c) 2017 wilbert
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

DeclareModule Date64
  Declare.i IsLeapYear64(Year.i)
  Declare.i DaysInMonth64(Year.i, Month.i)
  Declare.q Date64(Year.i=-1, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
  Declare.i Year64(Date.q)
  Declare.i Month64(Date.q)
  Declare.i Day64(Date.q)
  Declare.i Hour64(Date.q)
  Declare.i Minute64(Date.q)
  Declare.i Second64(Date.q)
  Declare.i DayOfWeek64(Date.q)
  Declare.i DayOfYear64(Date.q)
  Declare.q AddDate64(Date.q, Type.i, Value.i)
  Declare.s FormatDate64(Mask$, Date.q)
  Declare.q ParseDate64(Mask$, Date$)
EndDeclareModule

Module Date64
  EnableExplicit

  ; !!! >>> WARNING <<< !!!
  ; The Gregorian calendar was introduced in many regions at different times.
  ; This module uses the API date functions of the operating system and these have implemented a
  ; uniform introduction time, so that date calculations before the introduction of the Gregorian
  ; calendar usually lead to wrong results.

  ; == Windows ==
  ; >> Minimum: 01.01.1601 00:00:00
  ; >> Maximum: 31.12.9999 23:59:59

  ; == Linux ==
  ; 32-Bit:
  ; >> Minimum: 01.01.1902 00:00:00
  ; >> Maximum: 18.01.2038 23:59:59
  ; 64-Bit:
  ; >> Minimum: 01.01.0000 00:00:00
  ; >> Maximum: 31.12.9999 23:59:59

  ; == MacOS ==
  ; >> Minimum: 31.12.1969 23:59:59
  ; >> Maximum: 31.12.9999 23:59:59

  #SecondsInOneHour = 60 * 60
  #SecondsInOneDay  = #SecondsInOneHour * 24

  #HundredNanosecondsInOneSecond               = 10000000
  #HundredNanosecondsFrom_1Jan1601_To_1Jan1970 = 116444736000000000

  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
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
  CompilerEndIf

  ;{ Structure definition for "tm"
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    If Not Defined(tm, #PB_Structure)
      Structure tm Align #PB_Structure_AlignC
        tm_sec.l    ; 0 to 59 or up to 60 at leap second
        tm_min.l    ; 0 to 59
        tm_hour.l   ; 0 to 23
        tm_mday.l   ; Day of the month: 1 to 31
        tm_mon.l    ; Month: 0 to 11 (0 = January)
        tm_year.l   ; Number of years since the year 1900
        tm_wday.l   ; Weekday: 0 to 6, 0 = Sunday
        tm_yday.l   ; Days since the beginning of the year: 0 to 365 (365 is therefore 366 because after 1. January is counted)
        tm_isdst.l  ; Is summer time? tm_isdst > 0 = Yes
                    ;                             tm_isdst = 0 = No
                    ;                             tm_isdst < 0 = Unknown
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
          tm_gmtoff.l ; Offset of UTC in seconds
          *tm_zone    ; Abbreviation of the time zone
        CompilerElse
          tm_zone.l   ; Placeholder
          tm_gmtoff.l ; Offset of UTC in seconds
          *tm_zone64  ; Abbreviation of the time zone
        CompilerEndIf

      EndStructure
    EndIf
  CompilerEndIf
  ;}

  Procedure.i IsLeapYear64(Year.i)
    If Year < 1600
      ; Every year before 1600 are leap years if they are divisible by 4 with no remainder
      ProcedureReturn Bool(Year % 4 = 0)
    Else
      ; From the year 1600 are all year leap years that meet the following conditions:
      ; => Can be divided by 4 without remainder, but can not be divided by 100 without remainder
      ; => Divisible by 400 without remainder
      ProcedureReturn Bool((Year % 4 = 0 And Year % 100 <> 0) Or Year % 400 = 0)
    EndIf
  EndProcedure

  Procedure.i DaysInMonth64(Year.i, Month.i)
    While Month > 12
      Year  + 1
      Month - 12
    Wend
    While Month < 0
      Year  - 1
      Month + 13
    Wend
    If Month = 0
      Month = 1
    EndIf

    Select Month
      Case 1, 3, 5, 7, 8, 10, 12: ProcedureReturn 31
      Case 4, 6, 9, 11:           ProcedureReturn 30
      Case 2:                     ProcedureReturn 28 + IsLeapYear64(Year) ; February has one more day in the leap year
    EndSelect
  EndProcedure

  Procedure.q Date64(Year.i=-1, Month.i=1, Day.i=1, Hour.i=0, Minute.i=0, Second.i=0)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Protected.SYSTEMTIME st
        Protected.FILETIME   ft, ft2
        Protected.i          DaysInMonth

        If Year > -1 ; Valid date

          ; Correct the data, if necessary

          Minute + Second/60
          Second % 60
          If Second < 0
            Minute - 1
            Second + 60
          EndIf

          Hour + Minute/60
          Minute % 60
          If Minute < 0
            Hour   - 1
            Minute + 60
          EndIf

          Day + Hour/24
          Hour % 24
          If Hour < 0
            Day  - 1
            Hour + 24
          EndIf

          While Month > 12
            Year  + 1
            Month - 12
          Wend
          If Month = 0
            Month = 1
          EndIf

          DaysInMonth = DaysInMonth64(Year, Month)
          While Day > DaysInMonth
            Day - DaysInMonth
            Month + 1
            If Month > 12
              Year  + 1
              Month - 12
            EndIf
            DaysInMonth = DaysInMonth64(Year, Month)
          Wend

          If Day < 0
            Month - 1
            If Month = 0
              Year  - 1
              Month = 12
            EndIf
            Day + DaysInMonth64(Year, Month)
          EndIf

          st\wYear   = Year
          st\wMonth  = Month
          st\wDay    = Day
          st\wHour   = Hour
          st\wMinute = Minute
          st\wSecond = Second

          ; Convert system time (UTC) to file time (UTC)
          SystemTimeToFileTime_(@st, @ft)

          ; Convert UTC time to seconds
          ProcedureReturn (PeekQ(@ft) - #HundredNanosecondsFrom_1Jan1601_To_1Jan1970) / #HundredNanosecondsInOneSecond
        Else
          ; No valid date. Local system time is determined
          GetLocalTime_(@st)
          SystemTimeToFileTime_(@st, @ft) ; "st" is read as UTC and convert to file time

          ; Convert UTC time to seconds
          ProcedureReturn (PeekQ(@ft) - #HundredNanosecondsFrom_1Jan1601_To_1Jan1970) / #HundredNanosecondsInOneSecond
        EndIf

      CompilerCase #PB_OS_Linux
        Protected.tm tm
        Protected.q time
        
        If Year > -1 ; Valid date
          tm\tm_year  = Year - 1900 ; Years from 1900
          tm\tm_mon   = Month - 1   ; Months from January
          tm\tm_mday  = Day
          tm\tm_hour  = Hour
          tm\tm_min   = Minute
          tm\tm_sec   = Second

          ; mktime corrects the data itself and delivers seconds
          time = timegm_(@tm) ; Convert structured UTC time to UTC time as seconds

          ProcedureReturn time ; UTC time in seconds
        Else
          ; No valid date. Local system time is determined
          time = time_(0)
          If localtime_r_(@time, @tm) <> 0
            time = timegm_(@tm)
          EndIf

          ProcedureReturn time  ; UTC time in seconds
        EndIf

      CompilerCase #PB_OS_MacOS
        Protected at.d
        If Year > -1 ; Valid date
          CFCalendarComposeAbsoluteTime(GregorianGMT, @at, "yMdHms", Year, Month, Day, Hour, Minute, Second)
        Else ; No valid date. Local system time is determined
          at = CFAbsoluteTimeGetCurrent_()
          at + CFTimeZoneGetSecondsFromGMT(TimeZone, at)
        EndIf
        ProcedureReturn at + 978307200
    CompilerEndSelect
  EndProcedure

  Macro Windows_ReturnDatePart(Type)
    Protected.SYSTEMTIME st

    Date = Date * #HundredNanosecondsInOneSecond + #HundredNanosecondsFrom_1Jan1601_To_1Jan1970
    FileTimeToSystemTime_(@Date, @st)

    ProcedureReturn st\Type
  EndMacro

  Macro Linux_ReturnDatePart(Type, ReturnCode)
    Protected.tm *tm
    Protected.i  Value

    *tm = gmtime_(@Date)
    If *tm
      Value = *tm\Type
    EndIf

    ProcedureReturn ReturnCode
  EndMacro

  Macro Mac_ReturnDatePart(Type)
    Protected.i DatePart

    CFCalendarDecomposeAbsoluteTime(GregorianGMT, Date - 978307200, Type, @DatePart)

    CompilerIf Type = "E"
      ProcedureReturn DatePart - 1
    CompilerElse
      ProcedureReturn DatePart
    CompilerEndIf
  EndMacro

  Procedure.i Year64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wYear)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_year, Value + 1900)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("y")
    CompilerEndSelect
  EndProcedure

  Procedure.i Month64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wMonth)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_mon, Value + 1)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("M")
    CompilerEndSelect
  EndProcedure

  Procedure.i Day64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wDay)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_mday, Value)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("d")
    CompilerEndSelect
  EndProcedure

  Procedure.i Hour64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wHour)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_hour, Value)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("H")
    CompilerEndSelect
  EndProcedure

  Procedure.i Minute64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wMinute)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_min, Value)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("m")
    CompilerEndSelect
  EndProcedure

  Procedure.i Second64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wSecond)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_sec, Value)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("s")
    CompilerEndSelect
  EndProcedure

  Procedure.i DayOfWeek64(Date.q)
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : Windows_ReturnDatePart(wDayOfWeek)
      CompilerCase #PB_OS_Linux   : Linux_ReturnDatePart(tm_wday, Value)
      CompilerCase #PB_OS_MacOS   : Mac_ReturnDatePart("E")
    CompilerEndSelect
  EndProcedure

  Procedure.i DayOfYear64(Date.q)
    CompilerSelect #PB_Compiler_OS

      CompilerCase #PB_OS_Windows
        Protected.q TempDate
        TempDate = Date64(Year64(Date))
        ProcedureReturn (Date - TempDate) / #SecondsInOneDay + 1

      CompilerCase #PB_OS_Linux
        Linux_ReturnDatePart(tm_yday, Value + 1)

      CompilerCase #PB_OS_MacOS
        Mac_ReturnDatePart("D")

    CompilerEndSelect
  EndProcedure

  Procedure.q AddDate64(Date.q, Type.i, Value.i)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      Protected at.d = Date - 978307200

      Select Type
        Case #PB_Date_Year:   CFCalendarAddComponents(GregorianGMT, @at, 0, "y", Value)
        Case #PB_Date_Month:  CFCalendarAddComponents(GregorianGMT, @at, 0, "M", Value)
        Case #PB_Date_Week:   CFCalendarAddComponents(GregorianGMT, @at, 0, "d", Value * 7)
        Case #PB_Date_Day:    CFCalendarAddComponents(GregorianGMT, @at, 0, "d", Value)
        Case #PB_Date_Hour:   CFCalendarAddComponents(GregorianGMT, @at, 0, "H", Value)
        Case #PB_Date_Minute: CFCalendarAddComponents(GregorianGMT, @at, 0, "m", Value)
        Case #PB_Date_Second: CFCalendarAddComponents(GregorianGMT, @at, 0, "s", Value)
      EndSelect

      ProcedureReturn at + 978307200 
    CompilerElse ; Windows or Linux
      Protected.i Day, Month, Year

      Select Type
        Case #PB_Date_Year:   ProcedureReturn Date64(Year64(Date) + Value, Month64(Date), Day64(Date), Hour64(Date), Minute64(Date), Second64(Date))

        Case #PB_Date_Month
          Day   = Day64(Date)
          Month = Month64(Date) + Value
          Year  = Year64(Date)

          If Day > DaysInMonth64(Year, Month)
            ; Mktime corrects the date unlike PB-AddDate it does
            ; >> mktime:     31.03.2004 => 1 month later => 01.05.2004
            ; >> PB-AddDate: 31.03.2004 => 1 month later => 30.04.2004

            ; Set day to the maximum of the new month
            Day = DaysInMonth64(Year, Month)
          EndIf

          ProcedureReturn Date64(Year64(Date), Month, Day, Hour64(Date), Minute64(Date), Second64(Date))

        Case #PB_Date_Week:   ProcedureReturn Date64(Year64(Date), Month64(Date), Day64(Date) + Value * 7, Hour64(Date), Minute64(Date), Second64(Date))
        Case #PB_Date_Day:    ProcedureReturn Date64(Year64(Date), Month64(Date), Day64(Date) + Value, Hour64(Date), Minute64(Date), Second64(Date))
        Case #PB_Date_Hour:   ProcedureReturn Date64(Year64(Date), Month64(Date), Day64(Date), Hour64(Date) + Value, Minute64(Date), Second64(Date))
        Case #PB_Date_Minute: ProcedureReturn Date64(Year64(Date), Month64(Date), Day64(Date), Hour64(Date), Minute64(Date) + Value, Second64(Date))
        Case #PB_Date_Second: ProcedureReturn Date64(Year64(Date), Month64(Date), Day64(Date), Hour64(Date), Minute64(Date), Second64(Date) + Value)
      EndSelect
    CompilerEndIf

  EndProcedure

  Procedure.s FormatDate64(Mask$, Date.q)
    Protected Result$

    Result$ = ReplaceString(Mask$,   "%yyyy", RSet(Str(Year64(Date)),           4, "0"))
    Result$ = ReplaceString(Result$, "%yy",   RSet(Right(Str(Year64(Date)), 2), 2, "0"))
    Result$ = ReplaceString(Result$, "%mm",   RSet(Str(Month64(Date)),          2, "0"))
    Result$ = ReplaceString(Result$, "%dd",   RSet(Str(Day64(Date)),            2, "0"))
    Result$ = ReplaceString(Result$, "%hh",   RSet(Str(Hour64(Date)),           2, "0"))
    Result$ = ReplaceString(Result$, "%ii",   RSet(Str(Minute64(Date)),         2, "0"))
    Result$ = ReplaceString(Result$, "%ss",   RSet(Str(Second64(Date)),         2, "0"))

    ProcedureReturn Result$
  EndProcedure

  Macro ReadMaskVariable(MaskVariable, ReturnVariable)
    If Mid(Mask$, i, 3) = MaskVariable
      IsVariableFound = #True
      ReturnVariable = Val(Mid(Date$, DatePos, 2))
      DatePos + 2 ; Skip the 2 numbers of the number
      i + 2       ; Skip the 3 characters of the variable
      Continue
    EndIf
  EndMacro

  Procedure.q ParseDate64(Mask$, Date$)
    Protected.i i, DatePos = 1, IsVariableFound, Year, Month = 1, Day = 1, Hour, Minute, Second
    Protected MaskChar$, DateChar$

    For i = 1 To Len(Mask$)
      MaskChar$ = Mid(Mask$, i, 1)
      DateChar$ = Mid(Date$, DatePos, 1)

      If MaskChar$ <> DateChar$
        If MaskChar$ = "%" ; Maybe a variable?

          If Mid(Mask$, i, 5) = "%yyyy"
            IsVariableFound = #True
            Year = Val(Mid(Date$, DatePos, 4))
            DatePos + 4 ; Skip the 4 numbers of the year
            i + 4       ; Skip the 5 characters of the variable "%yyyy"
            Continue

          ElseIf Mid(Mask$, i, 3) = "%yy"
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
            ProcedureReturn 0
          EndIf

        Else
          ProcedureReturn 0
        EndIf

      EndIf

      DatePos + 1
    Next

    ProcedureReturn Date64(Year, Month, Day, Hour, Minute, Second)
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ;-Test
  
  UseModule Date64
  
  Define.i Year, Month, Day, Hour, Minute, Second, Result, Result64
  Define.q Date, Date64
  Define   Date$, Date64$, Result64$
  
  Debug "Small compatibility test - error:"

  For Year = 1970 To 2037
    For Month = 1 To 12
      For Day = 1 To 28
        For Hour = 0 To 23
          ;For Minute = 0 To 59
          ;For Second = 0 To 59

          Date = Date(Year, Month, Day, Hour, Minute, Second)
          Date64 = Date64(Year, Month, Day, Hour, Minute, Second)
          
          If Date <> Date64
            Debug "Date() <> Date64()"
            Debug Date
            Debug Date64
            Debug ""
          EndIf
          
          Date$ = FormatDate("%yyyy.%mm.%dd %hh:%ii:%ss", Date)
          Date64$ = FormatDate64("%yyyy.%mm.%dd %hh:%ii:%ss", Date64)
          If Date$ <> Date64$
            Debug "FormatDate() <> FormatDate64()"
            Debug Date$
            Debug Date64$
            Debug ""
          EndIf
          
          Result = ParseDate("%yyyy.%mm.%dd %hh:%ii:%ss", Date$)
          Result64 = ParseDate64("%yyyy.%mm.%dd %hh:%ii:%ss", Date64$)
          If Result <> Result64
            Debug "ParseDate() <> ParseDate64()"
            Debug Result
            Debug Result64
            Debug ""
          EndIf
          
          Result = DayOfWeek(Date)
          Result64 = DayOfWeek64(Date64)
          If Result <> Result64
            Debug "DayOfWeek() <> DayOfWeek64()"
            Debug Result
            Debug Result64
            Debug ""
          EndIf
          
          Result = DayOfYear(Date)
          Result64 = DayOfYear64(Date64)
          If Result <> Result64
            Debug "DayOfYear() <> DayOfYear64()"
            Debug Result
            Debug Result64
            Debug ""
          EndIf
          
          ;Next Second
          ;Next Minute
        Next Hour
      Next Day
    Next Month
  Next Year
  
  If Date() <> Date64()
    Debug "Date() <> Date64()"
  EndIf
  
  Macro AddDateTest(Type, TypeS)
    
    If AddDate(Date(), #PB_Date_#Type, 1) <> AddDate64(Date64(), #PB_Date_#Type, 1)
      Debug "AddDate(Date(), #PB_Date_" + TypeS + ", 1) <> AddDate64(Date64(), #PB_Date_" + TypeS + ", 1)"
    EndIf
    
    If AddDate(Date(), #PB_Date_#Type, -1) <> AddDate64(Date64(), #PB_Date_#Type, -1)
      Debug "AddDate(Date(), #PB_Date_" + TypeS + ", -1) <> AddDate64(Date64(), #PB_Date_" + TypeS + ", -1)"
    EndIf
    
  EndMacro
  
  AddDateTest(Year,   "Year")
  AddDateTest(Month,  "Month")
  AddDateTest(Day,    "Day")
  AddDateTest(Hour,   "Hour")
  AddDateTest(Minute, "Minute")
  AddDateTest(Second, "Second")
  AddDateTest(Week,   "Week")
  
  Macro TestDateLimits(Minimum, Maximum)
    
    Date64$ = Minimum
    Date64 = ParseDate64("%dd.%mm.%yyyy %hh:%ii:%ss", Date64$)
    Result64$ = FormatDate64("%dd.%mm.%yyyy %hh:%ii:%ss", Date64)
    If Date64$ <> Result64$
      Debug "Minimum is wrong:"
      Debug "> Expected was: " + Date64$
      Debug "> It was returned: " + Result64$
    EndIf
    
    Date64$ = Maximum
    Date64 = ParseDate64("%dd.%mm.%yyyy %hh:%ii:%ss", Date64$)
    Result64$ = FormatDate64("%dd.%mm.%yyyy %hh:%ii:%ss", Date64)
    If Date64$ <> Result64$
      Debug "Maximum is wrong:"
      Debug "> Expected was: " + Date64$
      Debug "> It was returned: " + Result64$
    EndIf
    
  EndMacro
  
  Debug "---------------------"
  Debug "Test of date limits - error:"
  
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows
      TestDateLimits("01.01.1601 00:00:00", "31.12.9999 23:59:59")
      
    CompilerCase #PB_OS_Linux
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        TestDateLimits("01.01.1902 00:00:00", "18.01.2038 23:59:59")
      CompilerElse
        TestDateLimits("01.01.0000 00:00:00", "31.12.9999 23:59:59")
      CompilerEndIf
      
    CompilerCase #PB_OS_MacOS
      TestDateLimits("31.12.1969 23:59:59", "31.12.9999 23:59:59")
      
  CompilerEndSelect
  
  Debug "---------------------"
  Debug "Test was carried out"
CompilerEndIf
