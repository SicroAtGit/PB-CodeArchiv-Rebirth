;   Description: Create an DataSection.pbi from a binary file. Multi file select supported
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29361
; -----------------------------------------------------------------------------

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

; Tool Settings:
; - Event: Menu Or Shortcut
; For MacOS, the field "Commandline" must contain the full path to the executable
; file, e.g.: .../Program.app/Contents/MacOS/Program

EnableExplicit

Procedure.s Simple_Name(a$)
  Protected i
  Protected b$="Data_"
  Protected char
  
  For i=1 To Len(a$)
    char=Asc(Mid(a$,i,1))
    Select char
      Case 'a' To 'z','A' To 'Z', '0' To '9'
        b$+Chr(char)
      Default 
        b$+"_"
    EndSelect
    
    
  Next
  ProcedureReturn b$
EndProcedure
Procedure WriteMem(out,file.s,*mem,len)
  Protected a$,b$
  Protected i
  Protected limit=80
  file=simple_name(GetFilePart(file))
  
  WriteStringN(out,file+"_len:")
  WriteStringN(out,"data.i "+Str(len))
  WriteString(out,file+":")
  For i=0 To len-1 Step 8
    If limit>=80
      WriteStringN(out,"")
      WriteString(out, "Data.q ")
      limit=7
    Else
      WriteString(out,",")
      limit+1
    EndIf
    a$="$"+Hex(PeekQ(*mem+i)) 
    b$=Str(PeekQ(*mem+i))
    If Len(a$)<Len(b$)
      WriteString(out,a$)
      limit+Len(a$)
    Else
      WriteString(out,b$)
      limit+Len(b$)
    EndIf    
  Next
  WriteStringN(out,"")
EndProcedure

Define a$
Define file$
Define len
Define *mem
Define in
Define out

file$=GetCurrentDirectory()
Repeat
  file$=OpenFileRequester("Create Data pbi",file$,"*.*|*.*",1,#PB_Requester_MultiSelection)
  If file$="" 
    Break
  EndIf
  
  out=CreateFile(#PB_Any,file$+".pbi")      
  If out
    WriteStringN(out,"DataSection")
    Repeat
      len=FileSize(file$)
      If len>0
        *mem=AllocateMemory(len+8)
        If *mem
          in=ReadFile(#PB_Any,file$)
          If in
            ReadData(in,*mem,len)
            CloseFile(in)
          Else
            Debug "Error Read in"
          EndIf
          writemem(out,file$,*mem,len)
          WriteStringN(out,"")
          
          FreeMemory(*mem)
          *mem=0
        EndIf
      EndIf
      a$=NextSelectedFileName()
      If a$=""
        Break
      EndIf
      file$=a$
    ForEver
    
    WriteStringN(out,"EndDataSection")
    CloseFile(out)
  EndIf
  
  
ForEver
