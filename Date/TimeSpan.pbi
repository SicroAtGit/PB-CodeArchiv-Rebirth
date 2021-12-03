;   Description: Gets the date difference as a formatted string or as a data structure
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=78150
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; Author: Little John
; License: Feel free to do with this code what you want. Credits are welcome, but not required.
; Version 1.00, 2021-11-02
; tested with PB 5.73 LTS x64 on Windows (should be cross-platform)

EnableExplicit

Structure TimeSpan
  years.i
  months.i
  weeks.i
  days.i
  hours.i
  minutes.i
  seconds.i
EndStructure


#TS_en    = " year,s, month,s, week,s, day,s, hour,s, minute,s, second,s"
#TS_en_ab = " yr,, mo,, wk,, dy,, h,, m,, s,"     ; English, abbreviated (just an example)
#TS_de    = " Jahr,e, Monat,e, Woche,n, Tag,e, Stunde,n, Minute,n, Sekunde,n"     ; German

#SECONDS_PER_MINUTE = 60
#SECONDS_PER_HOUR   = 60 * #SECONDS_PER_MINUTE
#SECONDS_PER_DAY    = 24 * #SECONDS_PER_HOUR
#SECONDS_PER_WEEK   =  7 * #SECONDS_PER_DAY


Procedure.i TimeDiff (startTime.q, endTime.q, *diff.TimeSpan)
  ; in : startTime: point in time in PureBasic format
  ;      endTime  : point in time in PureBasic format
  ;      *diff    : set field values to -1 for units that shall be ignored
  ; out: *diff    : duration from startTime to endTime expressed in wanted units;
  ;                 The values are compatible with PB's built-in AddDate() function
  ;                 (see validation below).
  ;   return value: 1 on success, 0 on error
  Protected rest.i, tmp.q = startTime
  
  If startTime < 0 Or endTime < 0 Or startTime > endTime
    ProcedureReturn 0               ; error
  EndIf
  
  With *diff
    If \years < 0 And \months < 0 And \weeks < 0 And \days < 0 And
       \hours < 0 And \minutes < 0 And \seconds < 0
      ProcedureReturn 0            ; error
    EndIf
    
    If \years > -1
      \years = Year(endTime) - Year(startTime)
      If AddDate(tmp, #PB_Date_Year, \years) > endTime
        \years - 1
      EndIf
      tmp = AddDate(tmp, #PB_Date_Year, \years)
    Else
      \years = 0
    EndIf
    
    If \months > -1
      \months = (Month(endTime) - Month(startTime) + 12) % 12
      If AddDate(tmp, #PB_Date_Month, \months) > endTime
        \months - 1
      EndIf
      tmp = AddDate(tmp, #PB_Date_Month, \months)
    Else
      \months = 0
    EndIf
    
    rest = endTime - tmp
    
    If \weeks > -1
      \weeks = Int(rest / #SECONDS_PER_WEEK)
      rest % #SECONDS_PER_WEEK
    Else
      \weeks = 0
    EndIf
    
    If \days > -1
      \days = Int(rest / #SECONDS_PER_DAY)
      rest % #SECONDS_PER_DAY
    Else
      \days = 0
    EndIf
    
    If \hours > -1
      \hours = Int(rest / #SECONDS_PER_HOUR)
      rest % #SECONDS_PER_HOUR
    Else
      \hours = 0
    EndIf
    
    If \minutes > -1
      \minutes = Int(rest / #SECONDS_PER_MINUTE)
      rest % #SECONDS_PER_MINUTE
    Else
      \minutes = 0
    EndIf
    
    If \seconds > -1
      \seconds = rest
    Else
      \seconds = 0
    EndIf
  EndWith
  
  ProcedureReturn 1           ; success
EndProcedure


Procedure.s TimeStr (*diff.TimeSpan, units$=#TS_en)
  ; in : *diff : time span expressed in appropriate units
  ;      units$: seven time units in the language of your choice (default: English)
  ; out: return value: given time span expressed in given units as a string,
  ;                    or "" on error
  Protected ret$=""
  
  If *diff = #Null Or CountString(units$, ",") <> 13
    ProcedureReturn ""          ; error
  EndIf
  
  With *diff
    If \years < 0 Or \months < 0 Or \weeks < 0 Or \days < 0 Or
       \hours < 0 Or \minutes < 0 Or \seconds < 0
      ProcedureReturn ""       ; error
    EndIf
    
    If \years > 0
      ret$ + ", " + \years + StringField(units$, 1, ",")
      If \years > 1
        ret$ + StringField(units$, 2, ",")
      EndIf
    EndIf
    
    If \months > 0
      ret$ + ", " + \months + StringField(units$, 3, ",")
      If \months > 1
        ret$ + StringField(units$, 4, ",")
      EndIf
    EndIf
    
    If \weeks > 0
      ret$ + ", " + \weeks + StringField(units$, 5, ",")
      If \weeks > 1
        ret$ + StringField(units$, 6, ",")
      EndIf
    EndIf
    
    If \days > 0
      ret$ + ", " + \days + StringField(units$, 7, ",")
      If \days > 1
        ret$ + StringField(units$, 8, ",")
      EndIf
    EndIf
    
    If \hours > 0
      ret$ + ", " + \hours + StringField(units$, 9, ",")
      If \hours > 1
        ret$ + StringField(units$, 10, ",")
      EndIf
    EndIf
    
    If \minutes > 0
      ret$ + ", " + \minutes + StringField(units$, 11, ",")
      If \minutes > 1
        ret$ + StringField(units$, 12, ",")
      EndIf
    EndIf
    
    If \seconds > 0 Or Asc(ret$) = ''
      ret$ + ", " + \seconds + StringField(units$, 13, ",")
      If \seconds <> 1
        ret$ + StringField(units$, 14, ",")
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn Mid(ret$, 3)
EndProcedure


Macro TimeDiffS (_startTime_, _endTime_, _units_=#TS_en)
  If TimeDiff(_startTime_, _endTime_, diff)
    Debug TimeStr(diff, _units_)
  Else
    Debug "Error"
  EndIf
EndMacro


Macro DateX (_year_, _month_, _day_, _hour_=0, _min_=0, _sec_=0)
  ; This can be used instead of PB's Date() function for convenience,
  ; when hours, minutes and seconds are often not of interest.
  Date(_year_, _month_, _day_, _hour_, _min_, _sec_)
EndMacro


;-Example
CompilerIf #PB_Compiler_IsMainFile
  #Mask$ = "%yyyy-%mm-%dd %hh:%ii:%ss"
  
  Define startTime.q, endTime.q, endTime_c.q, i.i, n.i=100
  Define diff.TimeSpan
  
  ; -- Validation of TimeDiff()
  For i = 1 To n
    startTime = Date(Random(2037,1970), Random(12,1), Random(28,1), Random(23,0), Random(59,0), Random(59,0))
    endTime   = Date(Random(2037,1970), Random(12,1), Random(28,1), Random(23,0), Random(59,0), Random(59,0))
    
    If startTime > endTime
      Swap startTime, endTime
    EndIf
    
    ; randomly switch usage of individual units ON (0) or OFF (-1)
    ; (Seconds are always ON in this test so as not to lose precision.)
    With diff
      \years   = Random(1) - 1
      \months  = Random(1) - 1
      \weeks   = Random(1) - 1
      \days    = Random(1) - 1
      \hours   = Random(1) - 1
      \minutes = Random(1) - 1
    EndWith
    
    If TimeDiff(startTime, endTime, diff) = 0
      Debug "Fatal error: TimeDiff() = 0"
      End
    EndIf
    
    With diff
      endTime_c = AddDate(startTime, #PB_Date_Year,   \years)
      endTime_c = AddDate(endTime_c, #PB_Date_Month,  \months)
      endTime_c = AddDate(endTime_c, #PB_Date_Week,   \weeks)
      endTime_c = AddDate(endTime_c, #PB_Date_Day,    \days)
      endTime_c = AddDate(endTime_c, #PB_Date_Hour,   \hours)
      endTime_c = AddDate(endTime_c, #PB_Date_Minute, \minutes)
      endTime_c = AddDate(endTime_c, #PB_Date_Second, \seconds)
    EndWith
    
    If endTime <> endTime_c
      Debug "-- Error"
      Debug "startTime = " + FormatDate(#Mask$, startTime)
      Debug "endTime   = " + FormatDate(#Mask$, endTime)
      Debug "endTime_c = " + FormatDate(#Mask$, endTime_c)
      Debug "TimeStr() = " + TimeStr(diff)
      Debug ""
    EndIf
  Next
  
  
  ; -- Demo of TimeStr(), TimeDiffS(), and DateX()
  Debug TimeStr(diff)             ; default language: English
  Debug TimeStr(diff, #TS_en_ab)  ; use some abbreviations
  Debug TimeStr(diff, #TS_de)     ; German
  
  Debug "--------"
  
  ; You can control in which units the result will be expressed:
  startTime = DateX(2021, 4, 10)
  endTime   = DateX(2021, 4, 24)
  
  TimeDiffS(startTime, endTime)   ; => 2 weeks
  
  diff\weeks = -1                 ; Don't use weeks in the result:
  TimeDiffS(startTime, endTime)   ; => 14 days
  
  ; Note that now all negative fields in the 'diff' structure are automatically set to zero.
  ; There is no need for you to do that in your code.
  
  diff\weeks = -1                 ; Neither use weeks ...
  diff\days  = -1                 ; ... nor days in the result.
  TimeDiffS(startTime, endTime)   ; => 336 hours
  
  Debug ""
  
  ; Another example
  startTime = DateX(1975, 5, 29)
  endTime   = Date()
  
  ; If you want to get *precise* results you should do without years and months,
  ; because their lengths can vary ...
  diff\years  = -1
  diff\months = -1
  TimeDiffS(startTime, endTime)
  
  ; ... however, when I e.g. want to calculate the age of a person, I do want
  ; to know the number of years and months, but normally am not interested in
  ; hours, minutes and seconds.
  diff\hours   = -1
  diff\minutes = -1
  diff\seconds = -1
  TimeDiffS(startTime, endTime)
CompilerEndIf
