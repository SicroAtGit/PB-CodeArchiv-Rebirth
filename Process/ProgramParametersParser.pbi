;   Description: Parses the program parameters
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29646
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 Sicro
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

; Version: 1.0.1
; Werte bei kombinierten Parametern können nun nur gesetzt werden, wenn dies ausdrücklich erlaubt wird (AllowMultiSetValue=#True).
; Bei [-mt "Test"] und AllowMultiSetValue=#False wird nur dem Parameter "m" der Wert zugewiesen.

DeclareModule ProgramParameterParser
  Declare.i IsSet(LongName$, ShortName$="")
  Declare.s GetValue(LongName$, ShortName$="", DefaultValue$="", AllowMultiSetValue=#False)
EndDeclareModule

Module ProgramParameterParser
  
  Procedure.i IsSet(LongName$, ShortName$="")
    Protected i, x, Parameter$, Length
    
    For i = CountProgramParameters() - 1 To 0 Step -1
      Parameter$ = ProgramParameter(i)
      
      ; Prüfe nach langem Parameter
      If Left(Parameter$, 2) = "--"
        
        If Mid(Parameter$, 3, Len(LongName$)) = LongName$
          ProcedureReturn #True
        EndIf
        
        ; Prüfe nach kurzem Parameter
      ElseIf Left(Parameter$, 1) = "-" And ShortName$ <> ""
        
        Length = Len(Parameter$)
        For x = 2 To Length
          If Mid(Parameter$, x, 1) = ShortName$
            ProcedureReturn #True
          EndIf
        Next
        
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.s GetValue(LongName$, ShortName$="", DefaultValue$="", AllowMultiSetValue=#False)
    Protected i, x, Parameter$, Length
    
    For i = CountProgramParameters() - 1 To 0 Step -1
      Parameter$ = ProgramParameter(i)
      
      ; Prüfe nach langem Parameter
      If Left(Parameter$, 2) = "--"
        
        If Mid(Parameter$, 3, Len(LongName$)) = LongName$
          Parameter$ = ProgramParameter(i + 1)
          Break
        EndIf
        
        ; Prüfe nach kurzem Parameter
      ElseIf Left(Parameter$, 1) = "-" And ShortName$ <> ""
        
        Length = Len(Parameter$)
        For x = 2 To Length
          If Mid(Parameter$, x, 1) = ShortName$
            If x > 2 And Not AllowMultiSetValue
              Break
            EndIf
            Parameter$ = ProgramParameter(i + 1)
            Break 2
          EndIf
        Next
        
      EndIf
    Next
    
    If Left(Parameter$, 1) = "-" Or Left(Parameter$, 2) = "--"
      Parameter$ = ""
    EndIf
    
    If Parameter$ = ""
      Parameter$ = DefaultValue$
    EndIf
    
    ProcedureReturn Parameter$
  EndProcedure
  
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  ; ===============
  ; >> Beispiele <<
  ; ===============
  
  ; Programm.exe --version "1.0" --open "D:\InputFile" --save "D:\OutputFile" -oc
  ; Programm.exe --optimize --compress --version "1.0" --open "D:\InputFile" --save "D:\OutputFile"
  ; Programm.exe -o -c -v "1.0" --open "D:\InputFile" --save "D:\OutputFile"
  
  ; Parameter überschreiben:
  
  ; Programm.exe --open "D:\InputFile" --open "X:\Test\InputFile"
  
  ; Parameter kombinieren und allen einen Wert gleichzeitig übergeben:
  
  ; Programm.exe -mt "Test"
  
  Debug ProgramParameterParser::GetValue("version", "v", "UnknownVersion")
  Debug ProgramParameterParser::GetValue("open", "")
  Debug ProgramParameterParser::GetValue("save", "")
  Debug ProgramParameterParser::GetValue("message", "m")
  Debug ProgramParameterParser::GetValue("", "t", "", 0)
  If ProgramParameterParser::IsSet("optimize", "o")
    Debug "Optimierung ist aktiviert"
  EndIf
  If ProgramParameterParser::IsSet("compress", "c")
    Debug "Komprimierung ist aktiviert"
  EndIf
CompilerEndIf
