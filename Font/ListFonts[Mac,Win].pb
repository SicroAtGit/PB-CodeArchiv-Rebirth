;   Description: List all available fonts
;            OS: Mac, Windos
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=410574#p410574
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 wilbert -- MacOS code
; Copyright (c) 2015 GPI -- Windows code
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

CompilerIf #PB_Compiler_OS=#PB_OS_Linux
  CompilerError "MacOs&Win only!"
CompilerEndIf


CompilerIf #PB_Compiler_OS=#PB_OS_MacOS
  FontManager = CocoaMessage(0, 0, "NSFontManager sharedFontManager")
  AvailableFontFamilies = CocoaMessage(0, FontManager, "availableFontFamilies")
  FontCount = CocoaMessage(0, AvailableFontFamilies, "count")
  
  i = 0
  While i < FontCount
    FontName.s = PeekS(CocoaMessage(0, CocoaMessage(0, AvailableFontFamilies, "objectAtIndex:", i), "UTF8String"), -1, #PB_UTF8)
    Debug FontName
    i + 1
  Wend
  
CompilerElseIf #PB_Compiler_OS=#PB_OS_Windows
  
  Procedure EnumFontFamProc(*lpelf.ENUMLOGFONT, *lpntm.NEWTEXTMETRIC, FontType, lParam) ; GetFonts and trans. to List
                                                                                        ;Debug PeekS(@*lpelf\elfLogFont\lfFaceName[0])
    Debug PeekS(@*lpelf\elfLogFont\lfFaceName[0],-1)
    ProcedureReturn 1
  EndProcedure
  hWnd = GetDesktopWindow_()
  hDC = GetDC_(hWnd)
  EnumFontFamilies_(hDC, 0, @EnumFontFamProc(), 0)
  ReleaseDC_ (hWnd, hDC)
  
CompilerEndIf

  
  
