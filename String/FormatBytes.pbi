;   Description: Formats the bytes into KB, KiB, MB, MiB, etc.
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=70940
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; Routine to format bytes into kB, MB, etc. Based on information at
; https://en.wikipedia.org/wiki/Mebibyte (retrieved 27th June 2018)
;
; Programmed by Francis G. Loch
;
; This is free and unencumbered software released into the public domain.
;
; Anyone is free to copy, modify, publish, use, compile, sell, or
; distribute this software, either in source code form or as a compiled
; binary, for any purpose, commercial or non-commercial, and by any
; means.
;
; In jurisdictions that recognize copyright laws, the author or authors
; of this software dedicate any and all copyright interest in the
; software to the public domain. We make this dedication for the benefit
; of the public at large and to the detriment of our heirs and
; successors. We intend this dedication to be an overt act of
; relinquishment in perpetuity of all present and future rights to this
; software under copyright law.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
; IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
; OTHER DEALINGS IN THE SOFTWARE.
;
; For more information, please refer to <http://unlicense.org>

Enumeration
  #FormatBytes_OSDefault
  #FormatBytes_JEDEC
  #FormatBytes_IEC
  #FormatBytes_Metric
EndEnumeration

Procedure.s FormatBytes(NbBytes.d, NbDecimals = #PB_Default, Mode = #FormatBytes_OSDefault)
  
  Protected Base, Exponent, MaxExponent, Unit$
  
  If NbDecimals = #PB_Default
    NbDecimals = 2
  EndIf
  
  If Mode = #FormatBytes_OSDefault
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      Mode = #FormatBytes_JEDEC
    CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
      Mode = #FormatBytes_IEC
    CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
      Mode = #FormatBytes_Metric
    CompilerEndIf
  EndIf
  
  Select Mode
    Case #FormatBytes_IEC
      Base = 1024
      Unit$ = "KiB,MiB,GiB,TiB,PiB,EiB,ZiB,YiB"
    Case #FormatBytes_JEDEC
      Base = 1024
      Unit$ = "KB,MB,GB"
    Case #FormatBytes_Metric
      Base = 1000
      Unit$ = "kB,MB,GB,TB,PB,EB,ZB,YB"
    Default
      ProcedureReturn "[ERROR] FormatBytes(): Invalid mode passed"
  EndSelect
  
  Exponent = Int(Log(NbBytes) / Log(Base))
  MaxExponent = CountString(Unit$, ",") + 1
  If Exponent > MaxExponent
    Exponent = MaxExponent
  EndIf
  
  If Exponent
    ProcedureReturn FormatNumber(NbBytes / Pow(Base, Exponent), NbDecimals) + " " + StringField(Unit$, Exponent, ",")
  Else
    ProcedureReturn FormatNumber(NbBytes, 0) + " B"
  EndIf
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  n.d = Pow(1024, 4)
  
  Debug FormatNumber(n, 0) + " bytes" + Chr(10)
  Debug "JEDEC:" + Chr(9) + FormatBytes(n, #PB_Default, #FormatBytes_JEDEC)
  Debug "IEC:" + Chr(9) + FormatBytes(n, #PB_Default, #FormatBytes_IEC)
  Debug "Metric:" + Chr(9) + FormatBytes(n, #PB_Default, #FormatBytes_Metric)
  
CompilerEndIf
