;   Description: Translates strings to keyboard events and executes them
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=149551#p149551
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2007 Sicro
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

Procedure SendKeys(Keys.s)
  
  Protected i.l, KeyCode.w, VirtualKey.b, KeysState.b

  For i = 1 To Len(Keys)
    
    KeyCode = VkKeyScan_(Asc(Mid(Keys,i,1)))
    VirtualKey = KeyCode & $FF
    KeysState = (KeyCode >> 8) & $FF

    Select KeysState
      Case 1 ; Umschalt-Taste wird benoetigt
        keybd_event_(#VK_SHIFT,1,0,0)
      Case 6 ; "Alt Groß"-Taste wird benoetigt
        keybd_event_(#VK_RMENU,1,0,0)
    EndSelect

    keybd_event_(VirtualKey,1,0,0)
    keybd_event_(VirtualKey,1,#KEYEVENTF_KEYUP,0)

    Select KeysState
      Case 1 ; Umschalt-Taste wieder loslassen
        keybd_event_(#VK_SHIFT,1,#KEYEVENTF_KEYUP,0)
      Case 6 ; "Alt Groß"-Taste wieder loslassen
        keybd_event_(#VK_RMENU,1,#KEYEVENTF_KEYUP,0)
    EndSelect
    
  Next
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  SendKeys("Hello World")
  
CompilerEndIf
