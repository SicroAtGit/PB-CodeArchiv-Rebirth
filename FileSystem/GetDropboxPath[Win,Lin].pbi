;   Description: Determines the path of the Dropbox directory
;            OS: Windows, Linux
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=49815
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012, 2016, 2017 Little John
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

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows And #PB_Compiler_OS <> #PB_OS_Linux
  CompilerError "Supported OS are only: Windows, Linux"
CompilerEndIf

; -- Get main Dropbox folder
; by Little John, 2017-03-06
; Original version after <http://stackoverflow.com/questions/12118162/how-can-i-get-the-dropbox-folder-location-programmatically-in-python>

; Previous versions of the code successfully tested in the course of time
; with various Dropbox and PB versions (ASCII mode and Unicode mode)
; on
; [v] Windows XP    (32 bit)
; [v] Windows 7     (64 bit)
; [v] Xubuntu 12.04 (32 bit)

; Current version of the code successfully tested with Dropbox 20.4.19
; and
; [v] PB 5.44 LTS (ASCII mode and Unicode mode)
; [v] PB 5.60     (only has Unicode mode)
; on
; [v] Windows 10      (64 bit)
; [v] Linux Mint 18.1 (64 bit)


DeclareModule Dropbox
  Declare.s Folder()
EndDeclareModule


Module Dropbox
  EnableExplicit
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #Slash$ = "\"
    CompilerDefault
      #Slash$ = "/"
  CompilerEndSelect
  
  
  Procedure.s _Base64ToStr (base64$, format.i=#PB_UTF8)
    ; -- decode a Base64 encoded string
    ; in : base64$: Base64 encoded string
    ;      format : format of the string in memory (#PB_Ascii, #PB_UTF8, or #PB_Unicode),
    ;               before it had been encoded to Base64
    ; out: return value: decoded string
    Protected *base64, base64Size.i = StringByteLength(base64$, #PB_Ascii)
    Protected *buffer, bufferSize.i = 0.8 * base64Size + 64
    Protected plainSize.i = 0, ret$ = ""
    
    If base64Size > 0
      *buffer = AllocateMemory(bufferSize)
      If *buffer
        CompilerIf #PB_Compiler_Version < 560
          *base64 = AllocateMemory(base64Size, #PB_Memory_NoClear)
          If *base64
            PokeS(*base64, base64$, -1, #PB_Ascii|#PB_String_NoZero)
            plainSize = Base64Decoder(*base64, base64Size, *buffer, bufferSize)
            FreeMemory(*base64)
          EndIf
        CompilerElse
          plainSize = Base64Decoder(base64$, *buffer, bufferSize)
        CompilerEndIf
        
        ret$ = PeekS(*buffer, plainSize, format)
        FreeMemory(*buffer)
      EndIf
    EndIf
    
    ProcedureReturn ret$
  EndProcedure
  
  
  Procedure.s _ReadLine (file$, lineNo.i)
    ; -- read one line from a file
    ; in : file$ : text file to read
    ;      lineNo: number of line to read (1 based)
    ; out: return value: n-th line of 'file$',
    ;                    or "" if the file doesn't contain so many lines
    Protected line$, fn.i, count.i=0
    
    fn = ReadFile(#PB_Any, file$)
    If fn
      While Eof(fn) = #False
        line$ = ReadString(fn)
        count + 1
        If count = lineNo
          CloseFile(fn)
          ProcedureReturn line$
        EndIf
      Wend
      CloseFile(fn)
    EndIf
    
    ProcedureReturn ""
  EndProcedure
  
  
  Macro _ExistFile (_name_)
    Bool(FileSize(_name_) > -1)
  EndMacro
  
  Macro _ExistDir (_name_)
    Bool(FileSize(_name_) = -2)
  EndMacro
  
  
  Procedure.s Folder()
    ; -- return main folder of an installed Dropbox, with trailing (back)slash,
    ;    or "" if not found
    Protected dbFile$, ret$
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      dbFile$ = GetEnvironmentVariable("appdata") + "\Dropbox\host.db"
      If _ExistFile(dbFile$) = #False
        dbFile$ = GetEnvironmentVariable("localappdata") + "\Dropbox\host.db"
      EndIf
    CompilerElse
      dbFile$ = GetHomeDirectory() + ".dropbox/host.db"
    CompilerEndIf
    
    ret$ = _Base64ToStr(_ReadLine(dbFile$, 2))
    
    If _ExistDir(ret$) = #False
      ; make an educated guess
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        ; This is after <https://www.dropbox.com/help/321>:
        ret$ = GetEnvironmentVariable("homedrive") + GetEnvironmentVariable("homepath") + "\Dropbox"
      CompilerElse
        ; This seems to be the standard e.g. on Xubuntu and Linux Mint:
        ret$ = GetHomeDirectory() + "Dropbox"
      CompilerEndIf
      If _ExistDir(ret$) = #False
        ret$ = ""
      EndIf
    EndIf
    
    If ret$ <> "" And Right(ret$, 1) <> #Slash$
      ret$ + #Slash$
    EndIf
    ProcedureReturn ret$
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Dropbox$ = Dropbox::Folder()
  
  Debug "Location of Dropbox folder:"
  If Dropbox$ <> ""
    Debug "'" + Dropbox$ + "'"
  Else
    Debug "not found"
  EndIf
  
CompilerEndIf
