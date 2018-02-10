;   Description: Simple Requester to show error messages
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=311985#p311985
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 Bisonte
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

; -----------------------------------------------------------------------------
; --- File     : ErrorRequester.pbi
; --- Author   : George Bisonte
; --- Version  : 1.0
; --- Compiler : PureBasic 5.11 (Windows - x86)
; --- created  : 03.05.2013 - 15:39
; -----------------------------------------------------------------------------
; --- Simple Requester to show Errormessages
; -----------------------------------------------------------------------------
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
CompilerEndIf
;
DataSection ; Icons for WindowTitleBar
  CompilerIf Not Defined(Icon_FatalError_Start, #PB_Label) ; Datas : Size = 1152 Bytes
    Icon_FatalError_Start: ;{ Datas : Size = 1152 Bytes
    ; Soure : http://www.fatcow.com/free-icons --> 16x16 cancel.png
    Data.q $1010000100010000,$0468002000010000,$0028000000160000,$0020000000100000,$0000002000010000
    Data.q $0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000120000000000
    Data.q $0000330000003300,$0000330000003300,$0000330000003300,$0000120000003300,$0000000000000000
    Data.q $0000000000000000,$0000000000000000,$3C2C7C8E2D221200,$3A2BFFBE3B2BFFC0,$3A2BFFBE3A2BFFBE
    Data.q $3C2CFFBE3B2BFFBE,$00007C8E2D22FFC0,$0000000000001200,$0000000000000000,$2D21120000000000
    Data.q $715FFFC33E2F798D,$7C69FFFF7D69FFF9,$7C69FFFF7C69FFFF,$715FFFFF7D69FFFF,$2D21FFC33E2FFFF9
    Data.q $000012000000798D,$0000000000000000,$3E2F798D2D211200,$745FFFF66B58FFC2,$725EFFFE725DFFFF
    Data.q $725EFFFD735EFFFD,$745FFFFE725DFFFD,$3E2FFFF66B58FFFF,$0000798D2D21FFC2,$2D22000000001200
    Data.q $6855FFC23F307C8E,$644EFFFC6C58FFF3,$6854FFF8634DFFF9,$6854FFF96B57FFF9,$644EFFF8634DFFF9
    Data.q $6855FFFC6C58FFF9,$2D22FFC23F30FFF3,$3D2D000000007C8E,$6B55FFF26753FFC0,$FFFFFFF76049FFFA
    Data.q $563EFFFFFFFFFFFF,$563EFFF65E47FFF6,$FFFFFFFFFFFFFFF6,$6B55FFF76049FFFF,$3D2DFFF26651FFFA
    Data.q $3B2B00000000FFC0,$644DFFFC7662FFBF,$FFFFFFF45942FFF6,$FFFFFFFFFFFFFFFF,$FFFFFFF3462CFFFF
    Data.q $FFFFFFFFFFFFFFFF,$644EFFF45942FFFF,$3B2CFFFC755FFFF6,$3A2A00000000FFBF,$5F49FFFA8673FFBF
    Data.q $806EFFF35A43FFF3,$FFFFFFFFFFFFFFF6,$FFFFFFFFFFFFFFFF,$806EFFFFFFFFFFFF,$5F49FFF35A43FFF6
    Data.q $3A2BFFFA816EFFF3,$392900000000FFBF,$5A42FFFB9686FFBF,$4E35FFF15942FFF1,$FFFFFFF2705BFFF0
    Data.q $FFFFFFFFFFFFFFFF,$4E35FFF2705BFFFF,$5B43FFF15942FFF0,$392AFFF9907DFFF1,$372700000000FFBF
    Data.q $553AFFFBA89AFFBF,$4428FFEE5339FFEF,$FFFFFFFFFFFFFFED,$FFFFFFFFFFFFFFFF,$4428FFFFFFFFFFFF
    Data.q $553BFFEE5339FFED,$3828FFFA9D8EFFEF,$372600000000FFBF,$4C31FFF1AB9FFFBF,$FFFFFFEB472BFFED
    Data.q $FFFFFFFFFFFFFFFF,$FFFFFFEF6953FFFF,$FFFFFFFFFFFFFFFF,$4C31FFEB472CFFFF,$3727FFF1AB9FFFED
    Data.q $382800000000FFBF,$9180FFF1AB9FFFC1,$FFFFFFE83E21FFF4,$725DFFFFFFFFFFFF,$725DFFE84023FFEE
    Data.q $FFFFFFFFFFFFFFEE,$9180FFE83E21FFFF,$3828FFF1AB9FFFF4,$3D2D00000000FFC1,$A597FFC33E2E5BC2
    Data.q $715BFFF28A77FFEF,$4326FFEE7460FFEE,$4326FFE7482CFFE6,$715BFFEE7460FFE6,$A597FFF28A77FFEE
    Data.q $3D2DFFC33E2EFFEF,$0000000000005BC2,$3E2E58C23C2C0000,$8876FFEEA295FFC2,$4023FFE43B1EFFF0
    Data.q $4023FFE54125FFE5,$8876FFE43B1EFFE5,$3E2EFFEEA295FFF0,$000058C23C2CFFC2,$0000000000000000
    Data.q $3C2C000000000000,$A094FFC33D2F58C2,$B8ADFFF8B9ADFFEF,$B8ADFFF7B9ADFFF7,$A094FFF8B9ADFFF7
    Data.q $3C2CFFC33D2FFFEF,$00000000000058C2,$0000000000000000,$0000000000000000,$3F305BC23C2C0000
    Data.q $5444FFCE5545FFC4,$5444FFCD5443FFCD,$3F30FFCE5545FFCD,$00005BC23C2CFFC4,$0000000000000000
    Data.q $0FE0000000000000,$038041AC07C041AC,$010041AC010041AC,$010041AC010041AC,$010041AC010041AC
    Data.q $010041AC010041AC,$010041AC010041AC,$07C041AC038041AC,$000041AC0FE041AC
    Icon_FatalError_End: ;}
  CompilerEndIf
  CompilerIf Not Defined(Icon_WarnError_Start, #PB_Label) ; Datas : Size = 1152 Bytes
    Icon_WarnError_Start: ;{ Datas : Size = 1152 Bytes
    ; Soure : http://www.fatcow.com/free-icons --> 16x16 error.png
    Data.q $1010000100010000,$0468002000010000,$0028000000160000,$0020000000100000,$0000002000010000
    Data.q $0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000
    Data.q $0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000
    Data.q $0000000000000000,$0000330000003300,$0000330000003300,$0000330000003300,$0000330000003300
    Data.q $0000330000003300,$0000330000003300,$0000330000003300,$823A330000003300,$7D38FFC87F39FFCA
    Data.q $7C39FFC77C38FFC7,$7D38FFC77C39FFC7,$7E38FFC97E38FFC7,$7C39FFC77D38FFC9,$7C38FFC77C39FFC7
    Data.q $7F39FFC77D38FFC7,$863BFFCA823AFFC8,$E355FFFFE355FFCD,$E156FFFFE156FFFF,$E556FFFFE256FFFF
    Data.q $E955FFFFE955FFFF,$E256FFFFE556FFFF,$E156FFFFE156FFFF,$E355FFFFE355FFFF,$8038FFCD863BFFFF
    Data.q $DB52FFE4B87A94C9,$D54DFFFFD54BFFFF,$DC4BFFFFD64DFFFF,$4967FF3F4967FFFF,$D64DFFFFDC4BFF3F
    Data.q $D54BFFFFD54DFFFF,$B87AFFFFDB52FFFF,$000094C98038FFE4,$E0A3FFC9823F0000,$CE44FFFFCF40FFFA
    Data.q $D644FFFFCF46FFFF,$5C77FF505C77FFFF,$CF46FFFFD644FF50,$CF40FFFFCE44FFFF,$823FFFFAE0A3FFFF
    Data.q $000000000000FFC9,$975B44C980360000,$C738FFFFE89EFFD4,$CF3DFFFFC83DFFFF,$BC4BFFE9BC4BFFFF
    Data.q $C83DFFFFCF3DFFE9,$E89EFFFFC738FFFF,$8036FFD4975BFFFF,$00000000000044C9,$7E33000000000000
    Data.q $D76FFFE6BF90BBC8,$CB34FFFFC332FFFF,$4B64FF3F4B64FFFF,$C332FFFFCB34FF3F,$BF90FFFFD76FFFFF
    Data.q $0000BBC87E33FFE6,$0000000000000000,$0000000000000000,$E8C1FFC9823C0000,$C527FFFFCC50FFFD
    Data.q $5569FF4C5569FFFF,$CC50FFFFC527FF4C,$823CFFFDE8C1FFFF,$000000000000FFC9,$0000000000000000
    Data.q $0000000000000000,$975758C980350000,$CA3AFFFFF3C6FFD5,$5B6CFF545B6CFFFF,$F3C6FFFFCA3AFF54
    Data.q $8035FFD59757FFFF,$00000000000058C9,$0000000000000000,$0000000000000000,$7E33000000000000
    Data.q $ECA4FFEABE86CFC8,$5D6CFF535D6CFFFF,$BE86FFFFECA4FF53,$0000CFC87E33FFEA,$0000000000000000
    Data.q $0000000000000000,$0000000000000000,$8238000000000000,$E5B2FFCB833A0ACA,$C89EFFDEC89EFFFF
    Data.q $833AFFFFE5B2FFDE,$00000ACA8238FFCB,$0000000000000000,$0000000000000000,$0000000000000000
    Data.q $0000000000000000,$98536DCA80350000,$F0C1FFFFF0C1FFD7,$8035FFD79853FFFF,$0000000000006DCA
    Data.q $0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$7E33000000000000
    Data.q $C384FFF1C384CFC7,$0000CFC77E33FFF1,$0000000000000000,$0000000000000000,$0000000000000000
    Data.q $0000000000000000,$0000000000000000,$8339000000000000,$8433FFCD843321CA,$000021CA8339FFCD
    Data.q $0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000
    Data.q $0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000
    Data.q $FFFF000000000000,$000041AC000041AC,$000041AC000041AC,$018041AC018041AC,$07E041AC03C041AC
    Data.q $0FF041AC07E041AC,$1FF841AC0FF041AC,$3FFC41AC3FFC41AC,$000041ACFFFF41AC
    Icon_WarnError_End: ;}
  CompilerEndIf
EndDataSection
;
#PB_ERRORREQUESTER_FAIL = 1 ; Automatic End of Program
#PB_ERRORREQUESTER_WARN = 2 ; User can continue program
;
Procedure ErrorRequester(ErrType, Image, ErrName.s, Text1.s = "", Text2.s = "", pID = -1)

  Protected Win, Event, Quit
  Protected Icon, FontB, FontN, FontBtn, ww
  Protected WinTitle.s, WinSize = 85, y = 10, x1
  Protected IG, TName, TText1, TText2, ButtonContinue, ButtonQuit

  FontB = LoadFont(#PB_Any, "Verdana", 12, #PB_Font_Bold)
  FontN = LoadFont(#PB_Any, "Verdana", 8)
  FontBtn = LoadFont(#PB_Any, "Verdana", 9, #PB_Font_Bold)

  If ErrType = #PB_ERRORREQUESTER_WARN
    Icon = CatchImage(#PB_Any, ?Icon_WarnError_Start)
    WinTitle = "Warning"
  Else
    Icon = CatchImage(#PB_Any, ?Icon_FatalError_Start)
    WinTitle = "Fatal Error"
  EndIf

  If IsImage(Image) : WinSize + ImageHeight(Image) + 5 : EndIf
  If Text1 <> "" : WinSize + 18 : EndIf
  If Text2 <> "" : WinSize + 18 : EndIf

  If pID = -1
    Win = OpenWindow(#PB_Any, 0, 0, 300, WinSize, WinTitle, #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  Else
    Win = OpenWindow(#PB_Any, 0, 0, 300, WinSize, WinTitle, #PB_Window_SystemMenu|#PB_Window_WindowCentered, WindowID(pID))
    DisableWindow(pID, #True)
  EndIf
  If IsImage(Icon) : SendMessage_(WindowID(Win), #WM_SETICON, #False, ImageID(Icon)) : EndIf

  ww = WindowWidth(Win)
  If IsImage(Image)
    IG = ImageGadget(#PB_Any, ((ww/2) - (ImageWidth(Image)/2)), y, ImageWidth(Image), ImageHeight(Image), ImageID(Image))
    y + GadgetHeight(IG) + 5
  EndIf
  TName = TextGadget(#PB_Any, 0, y, ww, 25, ErrName, #PB_Text_Center|#SS_CENTERIMAGE) : y + 30
  SetGadgetFont(TName, FontID(FontB))

  If Text1 <> ""
    TText1 = TextGadget(#PB_Any, 0, y, ww, 18, Text1, #PB_Text_Center|#SS_CENTERIMAGE) : y + GadgetHeight(TText1)
    SetGadgetFont(TText1, FontID(FontN))
  EndIf
  If Text2 <> ""
    TText2 = TextGadget(#PB_Any, 0, y, ww, 18, Text2, #PB_Text_Center|#SS_CENTERIMAGE) : y + GadgetHeight(TText2)
    SetGadgetFont(TText2, FontID(FontN))
  EndIf

  y + 10

  If ErrType = #PB_ERRORREQUESTER_WARN
    ButtonQuit = ButtonGadget(#PB_Any, 10, y, 130, 25, "Quit")
    ButtonContinue = ButtonGadget(#PB_Any, ww - 10 - 130, y, 130, 25, "Continue") : y + GadgetHeight(ButtonContinue)
    SetGadgetFont(ButtonContinue, FontID(FontBtn))
  Else
    ButtonQuit = ButtonGadget(#PB_Any, ((ww/2) - (150/2)), y, 150, 25, "Quit") : y + GadgetHeight(ButtonQuit)
  EndIf
  SetGadgetFont(ButtonQuit, FontID(FontBtn))
  If pID = -1
    StickyWindow(Win, #True)
  EndIf

  Repeat
    Event = WaitWindowEvent()

    If Event = #PB_Event_CloseWindow
      Quit = 1
    EndIf
    If Event = #PB_Event_Gadget
      If EventGadget() = ButtonContinue
        Quit = 2
      Else
        Quit = 1
      EndIf
    EndIf

  Until Quit > 0
  If pID <> -1
    DisableWindow(pID, #False)
  EndIf
  CloseWindow(Win)

  If IsFont(FontB) : FreeFont(FontB) : EndIf
  If IsFont(FontN) : FreeFont(FontN) : EndIf
  If IsFont(FontBtn) : FreeFont(FontBtn) : EndIf
  If IsImage(Icon) : FreeImage(Icon) : EndIf

  If Quit = 2
    ProcedureReturn #True
  Else
    End
  EndIf

EndProcedure
;
; -----------------------------------------------------------------------------
; --- Example / Demo
; -----------------------------------------------------------------------------
CompilerIf #PB_Compiler_IsMainFile
  OpenWindow(0, #PB_Ignore, #PB_Ignore, 640, 480, "Hallo")
  UsePNGImageDecoder()
  Define Im
  Im = LoadImage(#PB_Any, "D:\FCI\ethernet-card-Vista-icon128x128.png") ; <-- use your own Image
  ErrorRequester(#PB_ERRORREQUESTER_WARN, im, "Network Error", "No TCP/IP stack found !", "Click on Continue", 0)
  ErrorRequester(#PB_ERRORREQUESTER_FAIL, im, "Network Error", "No TCP/IP stack found !", "any network adapter installed ?")
CompilerEndIf
