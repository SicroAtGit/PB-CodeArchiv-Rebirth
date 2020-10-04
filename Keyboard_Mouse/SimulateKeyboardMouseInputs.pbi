;   Description: Simulates keyboard and mouse inputs
;            OS: Windows, Linux, Mac
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
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
    #VK_A                    = $00
    #VK_S                    = $01
    #VK_D                    = $02
    #VK_F                    = $03
    #VK_H                    = $04
    #VK_G                    = $05
    #VK_Z                    = $06
    #VK_X                    = $07
    #VK_C                    = $08
    #VK_V                    = $09
    #VK_B                    = $0B
    #VK_Q                    = $0C
    #VK_W                    = $0D
    #VK_E                    = $0E
    #VK_R                    = $0F
    #VK_Y                    = $10
    #VK_T                    = $11
    #VK_1                    = $12
    #VK_2                    = $13
    #VK_3                    = $14
    #VK_4                    = $15
    #VK_6                    = $16
    #VK_5                    = $17
    #VK_Equal                = $18
    #VK_9                    = $19
    #VK_7                    = $1A
    #VK_Minus                = $1B
    #VK_8                    = $1C
    #VK_0                    = $1D
    #VK_RightBracket         = $1E
    #VK_O                    = $1F
    #VK_U                    = $20
    #VK_LeftBracket          = $21
    #VK_I                    = $22
    #VK_P                    = $23
    #VK_L                    = $25
    #VK_J                    = $26
    #VK_Quote                = $27
    #VK_K                    = $28
    #VK_Semicolon            = $29
    #VK_Backslash            = $2A
    #VK_Comma                = $2B
    #VK_Slash                = $2C
    #VK_N                    = $2D
    #VK_M                    = $2E
    #VK_Period               = $2F
    #VK_Grave                = $32
    #VK_KeypadDecimal        = $41
    #VK_KeypadMultiply       = $43
    #VK_KeypadPlus           = $45
    #VK_KeypadClear          = $47
    #VK_KeypadDivide         = $4B
    #VK_KeypadEnter          = $4C
    #VK_KeypadMinus          = $4E
    #VK_KeypadEquals         = $51
    #VK_Keypad0              = $52
    #VK_Keypad1              = $53
    #VK_Keypad2              = $54
    #VK_Keypad3              = $55
    #VK_Keypad4              = $56
    #VK_Keypad5              = $57
    #VK_Keypad6              = $58
    #VK_Keypad7              = $59
    #VK_Keypad8              = $5B
    #VK_Keypad9              = $5C
   
    #VK_Return                    = $24
    #VK_Tab                       = $30
    #VK_Space                     = $31
    #VK_Delete                    = $33
    #VK_Escape                    = $35
    #VK_Command                   = $37
    #VK_Shift                     = $38
    #VK_CapsLock                  = $39
    #VK_Option                    = $3A
    #VK_Control                   = $3B
    #VK_RightShift                = $3C
    #VK_RightOption               = $3D
    #VK_RightControl              = $3E
    #VK_Function                  = $3F
    #VK_F17                       = $40
    #VK_VolumeUp                  = $48
    #VK_VolumeDown                = $49
    #VK_Mute                      = $4A
    #VK_F18                       = $4F
    #VK_F19                       = $50
    #VK_F20                       = $5A
    #VK_F5                        = $60
    #VK_F6                        = $61
    #VK_F7                        = $62
    #VK_F3                        = $63
    #VK_F8                        = $64
    #VK_F9                        = $65
    #VK_F11                       = $67
    #VK_F13                       = $69
    #VK_F16                       = $6A
    #VK_F14                       = $6B
    #VK_F10                       = $6D
    #VK_F12                       = $6F
    #VK_F15                       = $71
    #VK_Help                      = $72
    #VK_Home                      = $73
    #VK_PageUp                    = $74
    #VK_ForwardDelete             = $75
    #VK_F4                        = $76
    #VK_End                       = $77
    #VK_F2                        = $78
    #VK_PageDown                  = $79
    #VK_F1                        = $7A
    #VK_LeftArrow                 = $7B
    #VK_RightArrow                = $7C
    #VK_DownArrow                 = $7D
    #VK_UpArrow                   = $7E
   
  CompilerEndIf
 
  Declare ComputerKey(key.i, is_press.b = 1, option.b = 0, char_mode.b = 0)
  Declare ComputerMouse(posx.d, posy.d, key.w = 0, is_press.b = 1, option.b = 0) ;key = 0 (Left) / key = 1 (Right) / key = 2 (Middle)
                                                                                 ;Declare Ghost(write.s, delay.i)
 
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
   
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
   
    #kCGEventFlagMaskShift     = $020000 ; = NX_SHIFTMASK
    #kCGEventFlagMaskControl   = $040000 ; = NX_CONTROLMASK
    #kCGEventFlagMaskAlternate = $080000 ; = NX_ALTERNATEMASK
    #kCGEventFlagMaskCommand   = $100000 ; = NX_COMMANDMASK
   
    ImportC ""
      CFRelease(CFTypeRef.i)
      CGEventCreate(CGEventSourceRef.i)
      CGEventCreateKeyboardEvent(CGEventSourceRef.i, CGVirtualKeyCode.u, KeyDown.l)
      CGEventCreateMouseEvent(CGEventSourceRef.i, MouseEventType.i, x.d, y.d, MouseButton.i)
      CGEventPost(CGEventTapLocation.l, CGEventRef.i)
      CGEventSetFlags(CGEventRef.i, CGEventFlags.l)
      CGEventGetLocation(CGEventRef.i)
      CGEventSetIntegerValueField(CGEventRef.i, CGEventField.i, value.q)
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
      code = XkeysymTokeycode(*display, key)
      XTestFakekeyEvent(*display, code, is_press, 0)
      XFlush(*display)
      XCloseDisplay(*display)
    CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
      Protected TipTap.i
      If is_press = 1
        TipTap = CGEventCreateKeyboardEvent(0, key, #True)
      Else
        TipTap = CGEventCreateKeyboardEvent(0, key, #False)
      EndIf
      If TipTap
        If option = 1
          CGEventSetFlags(TipTap, #kCGEventFlagMaskShift)
        ElseIf option = 2
          CGEventSetFlags(TipTap, #kCGEventFlagMaskControl)
        ElseIf option = 3
          CGEventSetFlags(TipTap, #kCGEventFlagMaskCommand)
        ElseIf option = 4
          CGEventSetFlags(TipTap, #kCGEventFlagMaskAlternate)
        Else
          CGEventSetFlags(TipTap, 0)
        EndIf
        CGEventPost(0, TipTap)
        CFRelease(TipTap)
      EndIf
    CompilerEndIf
  EndProcedure
 
  Procedure ComputerMouse(posx.d, posy.d, key.w = 0, is_press.b = 1, option.b = 0) ;key = 0 (Left) / key = 1 (Right) / key = 2 (Middle)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If option = 0
        Protected Miau.INPUT
        Miau\Type=#INPUT_MOUSE
        If is_press = 1
          If key = 0
            Miau\mi\dwFlags = #MOUSEEVENTF_LEFTDOWN
          ElseIf key = 1
            Miau\mi\dwFlags = #MOUSEEVENTF_RIGHTDOWN
          ElseIf key = 2
            Miau\mi\dwFlags = #MOUSEEVENTF_MIDDLEDOWN
          EndIf
        Else
          If key = 0
            Miau\mi\dwFlags = #MOUSEEVENTF_LEFTUP
          ElseIf key = 1
            Miau\mi\dwFlags = #MOUSEEVENTF_RIGHTUP
          ElseIf key = 2
            Miau\mi\dwFlags = #MOUSEEVENTF_MIDDLEUP
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
    CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
      Protected Miau.i
      If key = 0
        If is_press = 1
          Miau = CGEventCreateMouseEvent(0, 1, posx, posy, 0)
        Else
          Miau = CGEventCreateMouseEvent(0, 2, posx, posy, 0)
        EndIf
      ElseIf key = 1
        If is_press = 1
          Miau = CGEventCreateMouseEvent(0, 3, posx, posy, 1)
        Else
          Miau = CGEventCreateMouseEvent(0, 4, posx, posy, 1)
        EndIf
      ElseIf key = 2
        ;?
      EndIf
      If Miau
        CGEventPost(0, Miau)
        CFRelease(Miau)
      EndIf
    CompilerEndIf
  EndProcedure
 
  ;   Procedure Ghost(write.s, delay.i)
  ;     Protected g
  ;     ;Windows-Char-Mode (Only letters and numbers)
  ;     For g = 1 To Len(write)
  ;       ComputerKey(Asc(Mid(write,g,1)), 1, 0, 1)
  ;       ComputerKey(Asc(Mid(write,g,1)), 0, 0, 1)
  ;       Delay(delay)
  ;     Next g
  ;   EndProcedure
 
EndModule

;-Main
CompilerIf #PB_Compiler_IsMainFile
  UseModule Simulate
 
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
   
    RunProgram("gedit", "", "")
    Delay(3000)
   
    ;ComputerMouse(100, 100, 0)
    ;ComputerMouse(100, 100, 0, 0)
   
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
   
  CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
   
    ProgramID = RunProgram("Open", "/Applications/TextEdit.app", "")
    Delay(3000)
   
    ComputerMouse(100, 100, 2, 1)
    ComputerMouse(100, 100, 2, 0)
   
    ComputerKey(#VK_Shift, #True)
    ComputerKey(#VK_H, #True, #True)
    ComputerKey(#VK_A, #True)
    ComputerKey(#VK_L, #True)
    ComputerKey(#VK_L, #True)
    ComputerKey(#VK_O, #True)
    ComputerKey(#VK_Space, #True)
    ComputerKey(#VK_M, #True, #True)
    ComputerKey(#VK_A, #True)
    ComputerKey(#VK_C, #True)
    ComputerKey(#VK_Slash, #True) ;no German-Keyboardlayout
    ComputerKey(#VK_O, #True, #True)
    ComputerKey(#VK_S, #True, #True)
   
  CompilerEndIf
 
  UnuseModule Simulate
CompilerEndIf
