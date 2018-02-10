;   Description: Extends the possibilities of PB's FormatDate() function
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=49633
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012, 2016 Little John
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

EnableExplicit

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  ; tested on German Windows 10
  
  Procedure.s LocalizedDayName (DayOfWeek.i, short.i=#False)
    ; in : DayOfWeek: Sunday=0, ..., Saturday=6
    ;                 (compliant with PureBasic's DayOfWeek() function)
    ;      short    : #True/#False
    ; out: short or full localized name of given weekday
    Protected fmt.i, buffer$, bufferSize.i=80
    
    If DayOfWeek = 0
      DayOfWeek = 7
    EndIf
    
    If short
      fmt = #LOCALE_SABBREVDAYNAME1
    Else
      fmt = #LOCALE_SDAYNAME1
    EndIf
    
    buffer$ = Space(bufferSize)
    GetLocaleInfo_(#LOCALE_USER_DEFAULT, fmt + DayOfWeek - 1, @buffer$, bufferSize)
    
    ProcedureReturn buffer$
  EndProcedure
  
  Procedure.s LocalizedMonthName (MonthOfYear.i, short.i=#False)
    ; in : MonthOfYear: January=1, ..., December=12
    ;                   (compliant with PureBasic's Month() function)
    ;      short      : #True/#False
    ; out: short or full localized name of given month
    Protected fmt.i, buffer$, bufferSize.i=80
    
    If short
      fmt = #LOCALE_SABBREVMONTHNAME1
    Else
      fmt = #LOCALE_SMONTHNAME1
    EndIf
    
    buffer$ = Space(bufferSize)
    GetLocaleInfo_(#LOCALE_USER_DEFAULT, fmt + MonthOfYear - 1, @buffer$, bufferSize)
    
    ProcedureReturn buffer$
  EndProcedure
  
CompilerElse
  ; tested on German Linux Mint 17.3
  
  Structure tm
    tm_sec.l
    tm_min.l
    tm_hour.l
    tm_mday.l
    tm_mon.l
    tm_year.l
    tm_wday.l
    tm_yday.l
    tm_isdst.l
  EndStructure
  
  Procedure.s LocalizedDayName (DayOfWeek.i, short.i=#False)
    ; in : DayOfWeek: Sunday=0, ..., Saturday=6
    ;                 (compliant with PureBasic's DayOfWeek() function)
    ;      short    : #True/#False
    ; out: short or full localized name of given weekday
    Protected tm.tm, fmt.i, numBytes.i, buffer$, bufferSize.i=80
    
    If short
      fmt = $6125      ; "%a"
    Else
      fmt = $4125      ; "%A"
    EndIf
    
    buffer$ = Space(bufferSize)
    tm\tm_wday = DayOfWeek
    numBytes = strftime_(@buffer$, bufferSize*SizeOf(Character), @fmt, @tm)
    
    ProcedureReturn PeekS(@buffer$, numBytes, #PB_UTF8|#PB_ByteLength)
  EndProcedure
  
  Procedure.s LocalizedMonthName (MonthOfYear.i, short.i=#False)
    ; in : MonthOfYear: January=1, ..., December=12
    ;                   (compliant with PureBasic's Month() function)
    ;      short      : #True/#False
    ; out: short or full localized name of given month
    Protected tm.tm, fmt.i, numBytes.i, buffer$, bufferSize.i=80
    
    If short
      fmt = $6225      ; "%b"
    Else
      fmt = $4225      ; "%B"
    EndIf
    
    buffer$ = Space(bufferSize)
    tm\tm_mon = MonthOfYear - 1
    numBytes = strftime_(@buffer$, bufferSize*SizeOf(Character), @fmt, @tm)
    
    ProcedureReturn PeekS(@buffer$, numBytes, #PB_UTF8|#PB_ByteLength)
  EndProcedure
CompilerEndIf


Procedure.s FormatDateEx (mask$, date.i=-1)
  ; in : mask$: can contain the same tokens as used with PB's FormatDate(),
  ;             plus the following additional ones:
  ;             - %ww    -->  full  localized name of given weekday
  ;             - %w     -->  short localized name of given weekday
  ;             - %mmmm  -->  full  localized name of given month
  ;             - %mmm   -->  short localized name of given month
  ;             - %d     -->  day   number without leading "0"
  ;             - %m     -->  month number without leading "0"
  ;      date : date value in PB's format; -1 for current system date and time
  ; out: mask string with all tokens replaced by the respective date values
  
  If date = -1
    date = Date()
  EndIf
  
  mask$ = ReplaceString(mask$, "%ww",   LocalizedDayName(DayOfWeek(date)))
  mask$ = ReplaceString(mask$, "%w",    LocalizedDayName(DayOfWeek(date), #True))
  mask$ = ReplaceString(mask$, "%mmmm", LocalizedMonthName(Month(date)))
  mask$ = ReplaceString(mask$, "%mmm",  LocalizedMonthName(Month(date), #True))
  mask$ = FormatDate(mask$, date)
  mask$ = ReplaceString(mask$, "%d", Str(Day(date)))
  mask$ = ReplaceString(mask$, "%m", Str(Month(date)))
  
  ProcedureReturn mask$
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  ; -- Demo
  Debug FormatDateEx("%ww, %d. %mmmm %yyyy", Date(2016,6,19, 0,0,0))
  Debug FormatDateEx("%w, %d. %mmm %yyyy")
  Debug FormatDateEx("%d.%m.%yyyy")
  Debug FormatDateEx("%dd.%mm.%yyyy")
CompilerEndIf
