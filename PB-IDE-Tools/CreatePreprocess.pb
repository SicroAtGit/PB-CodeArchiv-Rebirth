;   Description: Create a preprocess file (all macros are expanded, false compilerif - compilerendif are removed)
;     Parameter: "%FILE"
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: www.purebasic.fr/german/viewtopic.php?f=8&t=29152
;-----------------------------------------------------------------------------+

; MIT License
; 
; Copyright (c) 2015 GPI
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

Procedure FindCommend(*pos.character)
  Protected *start=*pos
  Protected isDQuote
  Protected isQuote
  While *pos\c>0
    If isDQuote
      If *pos\c='"'
        isDQuote=#False
      EndIf
    ElseIf isQuote
      If *pos\c=39 ;'
        isQuote=#False
      EndIf
    Else
      Select *pos\c
        Case '"'
          isDQuote=#True
        Case 39;'
          isQuote=#True
        Case ';'
          Break
      EndSelect
    EndIf
    *pos+SizeOf(character)
  Wend
  ProcedureReturn (*pos-*start )/SizeOf(character)
EndProcedure


file$=ProgramParameter()
pb$=GetEnvironmentVariable("PB_TOOL_Compiler")
If file$ And FileSize(file$)>0
  dir$ = GetPathPart(file$)
  outfile$=file$+".pre.pb"
  DeleteFile(dir$+outfile$)
  OpenConsole()  
  ;Compiler = RunProgram(pb$, Chr(34)+file$+Chr(34)+" /COMMENTED /PREPROCESS "+Chr(34)+outfile$+Chr(34), dir$,#PB_Program_Wait)
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Compiler = RunProgram(pb$, Chr(34) + file$ + Chr(34) + " /COMMENTED /PREPROCESS " + Chr(34) + outfile$ + Chr(34), dir$, #PB_Program_Open)
    CompilerDefault
      Compiler = RunProgram(pb$, Chr(34) + file$ + Chr(34) + " -c -pp " + Chr(34) + outfile$ + Chr(34), dir$, #PB_Program_Open)
  CompilerEndSelect
  If compiler 
    WaitProgram(compiler)
    ExitCode=ProgramExitCode(compiler)
    PrintN("Errorcode:"+Str(ExitCode))
    
    CloseProgram(compiler)
  EndIf
  
  If compiler And ExitCode=0
    NewList file.s()
    
    Define in,str.s,lastcom.s
    Macro output(a)
      AddElement(file())
      file()=a
    EndMacro
    PrintN("")
    Print("Remove unnecassary comments...")
    
    Define empty
    
    in=ReadFile(#PB_Any,outfile$)
    If in
      While Not Eof(in)
        line+1
        str=ReadString(in)
        If Left(str,1)=";"
          If lastcom<>""
            If Trim(Left(lastcom,FindCommend(@lastcom)))=""
              output("  "+lastcom)
            Else
              output("; "+lastcom)
            EndIf
          EndIf      
          lastcom=Right(str,Len(str)-2)
        Else
          If Left(Trim(str),6)="Macro "
            isMacro=#True
            str=""
          ElseIf Left(Trim(str),8)="EndMacro"
            isMacro=#False
            str=""
          ElseIf isMacro
            str=""
          EndIf      
          If lastcom<>""
            If empty
              output(";;")
            EndIf
            empty=#False
            x=FindCommend(@lastcom)
            If str<>Left(lastcom,x)
              
              output( "; "+lastcom)
              If str<>""
                output( str)
              EndIf
              
            Else
              output(lastcom)
            EndIf
            lastcom=""
          ElseIf str<>""
            output(str)
            empty=#True
          EndIf
          
        EndIf
        
        
      Wend
      
      CloseFile(in)
    EndIf
    PrintN("done")
    PrintN("Removed lines:"+Str(line-ListSize(file())))
    Print("Write File ...")
    out=CreateFile(#PB_Any,outfile$)
    If out
      ForEach file()
        WriteStringN(out,file())
      Next
      CloseFile(out)
    EndIf
    PrintN("done")
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      PrintN("")  
      PrintN("Press [Return]")
      
      Input()      
    CompilerEndIf
    
    RunProgram(GetEnvironmentVariable("PB_TOOL_IDE"), #DQUOTE$ + outfile$ + #DQUOTE$, "")  
  Else
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      PrintN("")  
      PrintN("Press [Return]")
      
      Input()      
    CompilerEndIf
  EndIf
EndIf
