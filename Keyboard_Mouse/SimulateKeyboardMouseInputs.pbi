;   Description: Simulates keyboard and mouse inputs
;            OS: Windows, Linux
; English-Forum:
;  French-Forum:
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31246
; -----------------------------------------------------------------------------

; MIT License
;
; Copyright (c) 2019 ccode_new
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

DeclareModule Simulate
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ;- Linux-Keys
    #XBackSpace = $FF08
    #XTab = $FF09
    #XLineFeed = $FF0A
    #XClear = $FF0B
    #XReturn = $FF0D
    #XPause = $FF13
    #XScroll_Lock = $FF14
    #XSys_Req = $FF15
    #XEscape = $FF1B
    #XDelete = $FFFF
    #XMulti_key = $FF20
    #XCodeinput = $FF37
    #XSingleCandidate = $FF3C
    #XMultipleCandidate = $FF3D
    #XPreviousCandidate = $FF3E
    #XHome = $FF50
    #XLeft = $FF51
    #XUp = $FF52
    #XRight = $FF53
    #XDown = $FF54
    #XPage_Up = $FF55
    #XPage_Down = $FF56
    #XEnd = $FF57
    #XBegin = $FF58
    #XSelect = $FF60
    #XPrint = $FF61
    #XExecute = $FF62
    #XInsert = $FF63
    #XUndo = $FF65
    #XRedo = $FF66
    #XMenu = $FF67
    #XFind = $FF68
    #XCancel = $FF69
    #XHelp = $FF6A
    #XBreak = $FF6B
    #XNum_Lock = $FF7F
    Enumeration F
      #XF1 = $FFBE
      #XF2
      #XF3
      #XF4
      #XF5
      #XF6
      #XF7
      #XF8
      #XF9
      #XF10
      #XF11
      #XF12
    EndEnumeration
    #XShift_L = $FFE1
    #XShift_R = $FFE2
    #XControl_L = $FFE3
    #XControl_R = $FFE4
    #XCaps_Lock = $FFE5
    #XShift_Lock = $FFE6
    #XMeta_L = $FFE7
    #XMeta_R = $FFE8
    #XAlt_L = $FFE9
    #XAlt_R = $FFEA
    #XSuper_L = $FFEB
    #XSuper_R = $FFEC
    #XHyper_L = $FFED
    #XHyper_R = $FFEE
  CompilerEndIf
 
  Declare ComputerKey(key.i, is_press.b = 1, option.b = 0, char_mode.b = 0)
  Declare ComputerMouse(posx.i, posy.i, key.w = 0, is_press.b = 1, option.b = 0) ;key = 0 (Left) / key = 1 (Right) / key = 2 (Middle)
  Declare Ghost(write.s, delay.i)
 
EndDeclareModule

Module Simulate
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ImportC "-lX11"
      XOpenDisplay(*display)
      XCloseDisplay(*display)
      XDefaultScreen(*display)
      XStringToKeysym(string.p-utf8)
      XKeysymToString(keysym)
      XKeysymToKeycode(*display, keysym)
      XFlush(display)
    EndImport
   
    ImportC "-lXtst"
      XTestFakeKeyEvent(display, keycode, is_press, delay)
      XTestFakeButtonEvent(display, button, is_press, delay)
      XTestFakeMotionEvent(display, screen_number, x, y, delay)
    EndImport
  CompilerEndIf
 
  Procedure ComputerKey(key.i, is_press.b = 1, option.b = 0, char_mode.b = 0)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If option = 0
        Protected TipTap.INPUT
        TipTap\Type = #INPUT_KEYBOARD
        If is_press = 1
          If char_mode = 1
            TipTap\ki\wScan = key
            TipTap\ki\dwFlags = 4
          Else
            TipTap\ki\wVk = key
            TipTap\ki\dwFlags = 0
          EndIf
        ElseIf is_press = 0
          If char_mode = 1
            TipTap\ki\wScan = key
            TipTap\ki\dwFlags = 4 | #KEYEVENTF_KEYUP
          Else
            TipTap\ki\wVk = key
            TipTap\ki\dwFlags = #KEYEVENTF_KEYUP
          EndIf
        EndIf
        SendInput_(1, @TipTap, SizeOf(INPUT))
      ElseIf option = 1
        If is_press = 1
          If char_mode = 1
            keybd_event_(0, key,  4, 0)
          Else
            keybd_event_(key, 0, 0, 0)
          EndIf
        Else
          If char_mode = 1
            keybd_event_(0, key, 4 | #KEYEVENTF_KEYUP, 0)
          Else
            keybd_event_(key, 0, #KEYEVENTF_KEYUP, 0)
          EndIf
        EndIf
      EndIf
    CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
      Protected *display = XOpenDisplay(0)
     
      ;       If XKeySymToString(key) <> 0
      ;         Debug PeekS(XKeySymToString(key), -1, #PB_UTF8)
      ;       EndIf
      ;       symbol = XStringToKeysym(PeekS(XKeySymToString(key), -1, #PB_UTF8))
     
      code = XkeysymTokeycode(*display, key)
      XTestFakekeyEvent(*display, code, is_press, 0)
      XFlush(*display)
      XCloseDisplay(*display)
    CompilerEndIf
  EndProcedure
 
  Procedure ComputerMouse(posx.i, posy.i, key.w = 0, is_pressss.b = 1, option.b = 0) ;key = 0 (Left) / key = 1 (Right) / key = 2 (Middle)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If option = 0
        Protected Miau.INPUT
        Miau\Type=#INPUT_MOUSE
        If is_press = 1
          If key = 0
            Miau\mi\dwFlags  = #MOUSEEVENTF_LEFTDOWN
          ElseIf key = 1
            Miau\mi\dwFlags  = #MOUSEEVENTF_RIGHTDOWN
          ElseIf key = 2
            Miau\mi\dwFlags  = #MOUSEEVENTF_MIDDLEDOWN
          EndIf
        Else
          If key = 0
            Miau\mi\dwFlags  = #MOUSEEVENTF_LEFTUP
          ElseIf key = 1
            Miau\mi\dwFlags  = #MOUSEEVENTF_RIGHTUP
          ElseIf key = 2
            Miau\mi\dwFlags  = #MOUSEEVENTF_MIDDLEUP
          EndIf
        EndIf
        SetCursorPos_(posx, posy)
        SendInput_(1, @Miau, SizeOf(INPUT))
      Else
        Protected MouseAreaWidth.i  = GetSystemMetrics_( #SM_CXSCREEN )-1
        Protected MouseAreaHeight.i  = GetSystemMetrics_( #SM_CYSCREEN )-1
        Protected mx.i = posx * (65535 / MouseAreaWidth)
        Protected my.i = posy * (65535 / MouseAreaHeight)
        If is_press = 1
          If key = 0
            mouse_event_(#MOUSEEVENTF_LEFTDOWN | #MOUSEEVENTF_MOVE | #MOUSEEVENTF_ABSOLUTE, mx, my, 0, 0)
          ElseIf key = 1
            mouse_event_(#MOUSEEVENTF_RIGHTDOWN | #MOUSEEVENTF_MOVE | #MOUSEEVENTF_ABSOLUTE, mx, my, 0, 0)
          ElseIf key = 2
            mouse_event_(#MOUSEEVENTF_MIDDLEDOWN | #MOUSEEVENTF_MOVE | #MOUSEEVENTF_ABSOLUTE, mx, my, 0, 0)
          EndIf
        Else
          If key = 0
            mouse_event_(#MOUSEEVENTF_LEFTUP | #MOUSEEVENTF_MOVE | #MOUSEEVENTF_ABSOLUTE, mx, my, 0, 0)
          ElseIf key = 1
            mouse_event_(#MOUSEEVENTF_RIGHTUP | #MOUSEEVENTF_MOVE  | #MOUSEEVENTF_ABSOLUTE, mx, my, 0, 0)
          ElseIf key = 2
            mouse_event_(#MOUSEEVENTF_MIDDLEUP | #MOUSEEVENTF_MOVE | #MOUSEEVENTF_ABSOLUTE, mx, my, 0, 0)
          EndIf
        EndIf
      EndIf
    CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
      Protected *display = XOpenDisplay(0)
      XTestFakeMotionEvent(*display, XDefaultScreen(*display), posx, posy, 0)
      If key = 0
        XTestFakeButtonEvent(*display, 1, is_press, 0)
      ElseIf key = 1
        XTestFakeButtonEvent(*display, 3, is_press, 0)
      ElseIf key = 2
        XTestFakeButtonEvent(*display, 2, is_press, 0)
      EndIf
      XFlush(*display)
      XCloseDisplay(*display)
    CompilerEndIf
  EndProcedure
 
  Procedure Ghost(write.s, delay.i)
    Protected g
    ;Windows-Char-Mode (Only letters and numbers)
    For g = 1 To Len(write)
      ComputerKey(Asc(Mid(write,g,1)), 1, 0, 1)
      ComputerKey(Asc(Mid(write,g,1)), 0, 0, 1)
      Delay(delay)
    Next g
  EndProcedure
 
EndModule

;-Main
CompilerIf #PB_Compiler_IsMainFile
  UseModule Simulate
 
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
   
    RunProgram("xed", "", "")
    Delay(3000)
   
    ;   ComputerMouse(100, 50, 0)
    ;   ComputerMouse(100, 50, 0, 0)
   
    ComputerKey(#XShift_L, #True)
    ComputerKey('H', #True)
    ComputerKey('H', #False)
    ComputerKey(#XShift_L, #False)
   
    ComputerKey(#PB_Key_A, #True)
    ComputerKey(#PB_Key_A, #False)
   
    ComputerKey('L', #True)
    ComputerKey('L', #False)
   
    ComputerKey(#PB_Key_L)
    ComputerKey(#PB_Key_L, #False)
   
    ComputerKey('O')
    ComputerKey('O', #False)
   
    ComputerKey(#PB_Key_Space, #True)
    ComputerKey(#PB_Key_Space, #False)
   
    ComputerKey(#XShift_L)
    ComputerKey('L', #True)
    ComputerKey('L', #False)
    ComputerKey(#XShift_L, 0)
   
    ComputerKey(#PB_Key_I)
    ComputerKey(#PB_Key_I, 0)
   
    ComputerKey('n', 1)
    ComputerKey('n', 0)
   
    ComputerKey(#PB_Key_U, 1)
    ComputerKey(#PB_Key_U, 0)
   
    ComputerKey(120, 1)
    ComputerKey(120, 0)
   
    ComputerKey(#XShift_L)
    ComputerKey('!', 1)
    ComputerKey('!', 0)
    ComputerKey(#XShift_L, 0)
   
    Ghost(" Its snowing", 20)
   
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
   
    RunProgram("notepad.exe")
    Delay(3000)
   
    ;ComputerMouse(100, 100, 0)
    ;ComputerMouse(100, 100, 0, 0)
   
    ComputerKey(#VK_LSHIFT, #True)
    ComputerKey('H', #True)
    ComputerKey('H', #False)
    ComputerKey(#VK_LSHIFT, #False)
   
    ComputerKey(#VK_A, #True)
    ComputerKey(#VK_A, #False)
   
    ComputerKey('L', #True)
    ComputerKey('L', #False)
   
    ComputerKey(#VK_L)
    ComputerKey(#VK_L, #False)
   
    ComputerKey('O')
    ComputerKey('O', #False)
   
    ComputerKey(#VK_SPACE, #True)
    ComputerKey(#VK_SPACE, #False)
   
    ComputerKey(#VK_LSHIFT)
    ComputerKey('W', #True)
    ComputerKey('W', #False)
    ComputerKey(#VK_LSHIFT, 0)
   
    ComputerKey(#VK_I)
    ComputerKey(#VK_I, 0)
   
    ComputerKey('N', 1)
    ComputerKey('N', 0)
   
    ComputerKey(#VK_D, 1)
    ComputerKey(#VK_D, 0)
   
    ComputerKey(#VK_O, 1)
    ComputerKey(#VK_O, 0)
   
    ComputerKey('W', 1)
    ComputerKey('W', 0)
   
    ComputerKey(#VK_S)
    ComputerKey(#VK_S, #False)
   
    ComputerKey(#VK_LSHIFT)
    ComputerKey('1', 1)
    ComputerKey('1', 0)
    ComputerKey(#VK_LSHIFT, 0)
   
    Ghost(" Its snowing", 20)
   
  CompilerEndIf
 
  UnuseModule Simulate
CompilerEndIf
