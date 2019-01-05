;   Description: Returns the target path of a shell link file
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?p=295302#p295302
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2011 Sicro
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

Procedure$ GetShellLinkTargetPath(shellLinkFilePath$)
  
  Protected result$ = Space(#MAX_PATH + 1)
  Protected linkFile.IPersistFile
 
  CompilerSelect #PB_Compiler_Unicode
    CompilerCase #True:  Protected shellLink.IShellLinkW
    CompilerCase #False: Protected shellLink.IShellLinkA
  CompilerEndSelect
 
  CoInitialize_(0)
 
  If CoCreateInstance_(?CLSID_ShellLink, 0, 1, ?IID_IShellLink, @shellLink) = #S_OK
    If shellLink\QueryInterface(?IID_IPersistFile, @linkFile) = #S_OK
      If linkFile\Load(shellLinkFilePath$, 0) = #S_OK
        If shellLink\Resolve(0, 1) = #S_OK
          CompilerSelect #PB_Compiler_Unicode
            CompilerCase #True:  shellLink\GetPath(@result$, #MAX_PATH, 0, 0)
            CompilerCase #False: shellLink\GetPath(result$,  #MAX_PATH, 0, 0)
          CompilerEndSelect
        EndIf
      EndIf
      LinkFile\Release()
    EndIf
    shellLink\Release()
  EndIf
   
  CoUninitialize_()
 
  ProcedureReturn result$

  DataSection
    CLSID_ShellLink:
    ; 00021401-0000-0000-C000-000000000046
    Data.l $00021401
    Data.w $0000,$0000
    Data.b $C0,$00,$00,$00,$00,$00,$00,$46
   
    IID_IShellLink:
    CompilerIf #PB_Compiler_Unicode
      ; IID_IShellLinkW
      ; {000214F9-0000-0000-C000-000000000046}
      Data.l $000214F9
      Data.w $0000,$0000
      Data.b $C0,$00,$00,$00,$00,$00,$00,$46
    CompilerElse
      ; 000214EE-0000-0000-C000-000000000046
      Data.l $000214EE
      Data.w $0000,$0000
      Data.b $C0,$00,$00,$00,$00,$00,$00,$46
    CompilerEndIf
       
    IID_IPersistFile:
    ; 0000010b-0000-0000-C000-000000000046
    Data.l $0000010b
    Data.w $0000,$0000
    Data.b $C0,$00,$00,$00,$00,$00,$00,$46
  EndDataSection
  
EndProcedure
