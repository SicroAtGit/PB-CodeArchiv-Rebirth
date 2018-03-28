;   Description: Allows to quickly expand strings
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 Sicro
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

DeclareModule QuicklyExpandStrings
  Declare.i CreateString()
  Declare.i AddToString(*String, String$)
  Declare$  GetString(*String)
  Declare   FreeString(*String)
EndDeclareModule

Module QuicklyExpandStrings
  #Size_Megabyte = 1024 * 1024
  
  Structure StringStruc
    DataLength.i
    *Memory
  EndStructure
  
  Procedure.i CreateString()
    Protected *String.StringStruc
    
    *String = AllocateMemory(SizeOf(StringStruc))
    If *String = 0
      ProcedureReturn #False
    EndIf
    
    *String\Memory = AllocateMemory(#Size_Megabyte, #PB_Memory_NoClear)
    If *String\Memory = 0
      FreeMemory(*String)
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn *String
  EndProcedure
  
  Procedure.i AddToString(*String.StringStruc, String$)
    Protected StringLength = StringByteLength(String$)
    Protected *NewMemory
  
    If *String = 0
      ProcedureReturn #False
    EndIf
    
    If MemorySize(*String\Memory) <= (*String\DataLength + StringLength)
      *NewMemory = ReAllocateMemory(*String\Memory, *String\DataLength + StringLength + #Size_Megabyte, #PB_Memory_NoClear)
      If *NewMemory = 0
        ProcedureReturn #False
      EndIf
      *String\Memory = *NewMemory
    EndIf
    PokeS(*String\Memory + *String\DataLength, String$)
    *String\DataLength + StringLength
  
    ProcedureReturn #True
  EndProcedure
  
  Procedure$ GetString(*String.StringStruc)
    ProcedureReturn PeekS(*String\Memory, *String\DataLength / SizeOf(Character))
  EndProcedure
  
  Procedure FreeString(*String.StringStruc)
    FreeMemory(*String\Memory)
    FreeMemory(*String)
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  *String = QuicklyExpandStrings::CreateString()
  If *String = 0 : End : EndIf
    
  If Not QuicklyExpandStrings::AddToString(*String, "Hello! ")
    Debug "Error: AddString"
  EndIf
  
  If Not QuicklyExpandStrings::AddToString(*String, "This is a example text.")
    Debug "Error: AddString"
  EndIf
  
  Debug QuicklyExpandStrings::GetString(*String)
  
  QuicklyExpandStrings::FreeString(*String) ; This is done automatically when the program ends.
CompilerEndIf
