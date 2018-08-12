;   Description: Gets the date difference as a formatted string
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
;
; Copyright (c) 2018 Sicro
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

XIncludeFile "DaysInMonth.pbi"

Procedure$ GetDateDiff(Date1, Date2, ResultMask$ = "%y years, %m months, %d days, %h hours, %i minutes, %s seconds")
  
  Protected DiffSeconds, DiffMinutes, DiffHours, DiffDays, DiffMonths, DiffYears, Carry
  Protected Result$ = ResultMask$
  
  If Date1 > Date2
    Swap Date1, Date2
  EndIf
  
  DiffSeconds = Second(Date2) - Second(Date1)
  If DiffSeconds < 0
    DiffSeconds + 60
    Carry = 1
  EndIf
  
  DiffMinutes = Minute(Date2) - Minute(Date1) - Carry
  If DiffMinutes < 0
    DiffMinutes + 60
    Carry = 1
  Else
    Carry = 0
  EndIf
  
  DiffHours = Hour(Date2) - Hour(Date1) - Carry
  If DiffHours < 0
    DiffHours + 24
    Carry = 1
  Else
    Carry = 0
  EndIf
  
  DiffDays = Day(Date2) - Day(Date1) - Carry
  If DiffDays < 0
    DiffDays + DaysInMonth(Month(Date1), Year(Date1))
    Carry = 1
  Else
    Carry = 0
  EndIf
  
  DiffMonths = Month(Date2) - Month(Date1) - Carry
  If DiffMonths < 0
    DiffMonths + 12
    Carry = 1
  Else
    Carry = 0
  EndIf
  
  DiffYears = Year(Date2) - Year(Date1) - Carry
  
  Result$ = ReplaceString(Result$, "%y", Str(DiffYears))
  Result$ = ReplaceString(Result$, "%m", Str(DiffMonths))
  Result$ = ReplaceString(Result$, "%d", Str(DiffDays))
  Result$ = ReplaceString(Result$, "%h", Str(DiffHours))
  Result$ = ReplaceString(Result$, "%i", Str(DiffMinutes))
  Result$ = ReplaceString(Result$, "%s", Str(DiffSeconds))
  
  Result$ = ReplaceString(Result$, "%M", Str((Date2 - Date1) / (60 * 60 * 24 * 30)))
  Result$ = ReplaceString(Result$, "%D", Str((Date2 - Date1) / (60 * 60 * 24)))
  Result$ = ReplaceString(Result$, "%H", Str((Date2 - Date1) / (60 * 60)))
  Result$ = ReplaceString(Result$, "%I", Str((Date2 - Date1) / 60))
  Result$ = ReplaceString(Result$, "%S", Str((Date2 - Date1)))
  
  ProcedureReturn Result$
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Define Result$ = "Years: %y" + #CRLF$ +
                   "Months: %m (Months in total: %M)" + #CRLF$ +
                   "Days: %d (Days in total: %D)" + #CRLF$ +
                   "Hours: %h (Hours in total: %H)" + #CRLF$ +
                   "Minutes: %i (Minutes in total: %I)" + #CRLF$ +
                   "Seconds: %s (Seconds in total: %S)"
  
  MessageRequester("GetDateDiff", GetDateDiff(Date(2003, 3, 1, 0, 0, 0), Date(2004, 3, 1, 0, 0, 0), result$))
CompilerEndIf
