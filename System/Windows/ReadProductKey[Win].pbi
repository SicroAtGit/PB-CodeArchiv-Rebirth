;   Description: Returns the product key from the running windows operating system
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=23505
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2010 ts-soft
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

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "Supported OS are only: Windows"
CompilerEndIf

; Original Code in XProfan by frank abbing
; http://www.paules-pc-forum.de/forum/dlls-includes-units-prozeduren/134802-windows-product-key-auslesen.html

; rewritten to work with purebasic by ts-soft

; Plattform: windows only
; Supports 32 and 64 bit OS
; Supports Ascii and Unicode
; Requires PureBasic 4.40 and higher

EnableExplicit

#KEY_WOW64_64KEY = $100

Procedure.s GetWindowsProductKey()
  Protected hKey, Res, size = 280
  Protected i, j, x, Result.s
  Protected *mem = AllocateMemory(size)
  Protected *newmem = AllocateMemory(size)
  Protected *digits = AllocateMemory(25)

  PokeS(*digits, "BCDFGHJKMPQRTVWXY2346789", -1, #PB_Ascii)
  If OSVersion() <= #PB_OS_Windows_2000
    Res = RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", 0, #KEY_READ, @hKey)
  Else
    Res = RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", 0, #KEY_READ | #KEY_WOW64_64KEY, @hKey)
  EndIf
  If Res = #ERROR_SUCCESS
    RegQueryValueEx_(hKey, "DigitalProductID", 0, 0, *mem, @size)
    RegCloseKey_(hKey)
    If size <> 280
      For i = 24 To 0 Step -1
        x = 0
        For j = 66 To 52 Step -1
          x = (x << 8) + PeekA(*mem + j)
          PokeA(*mem + j, x / 24)
          x % 24
        Next
        PokeA(*newmem + i, PeekA(*digits + x))
      Next
      For i = 0 To 15 Step 5
        Result + PeekS(*newmem + i, 5, #PB_Ascii) + "-"
      Next
      Result + PeekS(*newmem + 20, 5, #PB_Ascii)
    EndIf
  EndIf
  FreeMemory(*mem) : FreeMemory(*newmem) : FreeMemory(*digits)
  ProcedureReturn Result
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Debug GetWindowsProductKey()
  
CompilerEndIf
