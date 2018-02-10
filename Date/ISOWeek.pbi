;   Description: Adds a function to get the week number (ISO 8601)
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=420707#p420707
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 TI-994A
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

Procedure.i ISOWeek(date)
  
  Protected year, firstDay, ISOday, ISOwk
  
  year = Year(date)
  firstDay = DayOfWeek(Date(year, 1, 1, 0, 0, 0))
  If firstDay = 0
    firstDay = 7
  EndIf
  If firstDay <= 4
    ISOday = DayOfYear(date) + (firstDay - 1)
  Else
    ISOday = DayOfYear(date) - (8 - firstDay)
  EndIf
  ISOwk = Round(ISOday / 7, #PB_Round_Up)
  If Not ISOwk
    ISOwk = ISOWeek(Date(year - 1, 12, 31, 0, 0, 0))
  EndIf
  ;------
  If ISOwk = 53 And Month(date) = 12 And
     DayOfWeek(Date(year + 1, 1, 1, 0, 0, 0)) <= 4
    ISOwk = 1
  EndIf 
  ;------
  ProcedureReturn ISOWk
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Debug ISOWeek(Date())
  Debug ISOWeek(Date(1997, 12, 29, 0, 0, 0)) ;week #1
  Debug ISOWeek(Date(2012, 12, 31, 0, 0, 0)) ;week #1
  Debug ISOWeek(Date(2012, 1, 1, 0, 0, 0))   ;week #52
  Debug ISOWeek(Date(2016, 1, 1, 0, 0, 0))   ;week #53
  
CompilerEndIf
