;   Description: Module for controlling keyboard LCDs: Logitech (Monochrom/RGB) (G15, G13, G19, etc.)
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29427
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 Imhotheb
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

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Thread-Safe is needed!"
CompilerEndIf

DeclareModule Logitech_Common

  Declare CreatePxArray(Image, Width, Heigth, Mono, Alpha)
  Macro FreePxArray(_Ptr_)                                            ; free memory of pixes-array
    FreeMemory(_Ptr_)
  EndMacro

  Declare.s GetLCorePath()          ; try to find the location of "LCore.exe", logitech's keyb/mouse software

  Declare Dummy()                   ; reserved

EndDeclareModule
Module Logitech_Common

  Procedure.s GetLCorePath()
    Protected Ret.s

    ; i know ... a little clueless
    Ret = GetEnvironmentVariable("ProgramFiles")
    Ret + "\Logitech Gaming Software"

    ProcedureReturn Ret
  EndProcedure

  Procedure CreatePxArray(Image, Width, Heigth, Mono, Alpha)
    Protected *Ret, Img, x, y, Size, Color, *Ptr.Ascii

    ; calculate memory needed for mone or color lcd
    If Mono = #False
      Size = Width * Heigth * 4
    Else
      Size = Width * Heigth ; * 1
    EndIf

    ; some checks if image exists and is big enougth
    If IsImage(Image)
      If ImageHeight(Image) >= Heigth And ImageWidth(Image) >= Width
        Img = GrabImage(Image, #PB_Any, 0, 0, Width, Heigth)        ; i think it's saver to copy the image, but dont know
        If Img

          ; override alpha if there is no alpha-channel
          If ImageDepth(Img) < 32
            Alpha = 255
          EndIf

          *Ret = AllocateMemory(Size)
          If *Ret

            StartDrawing(ImageOutput(Img))
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            For y = 0 To Heigth - 1
              For x = 0 To Width - 1
                Color = Point(x, y)                   ; take color of pb-image
                If Mono = #False                      ; color-lcd
                  ;write 4 Byte (BGRA)
                  *Ptr = *Ret + (y * Width + x) * 4   ; calc location in memory
                  PokeA(*Ptr, Blue(Color))            ; maybe its faster to use "*Ptr\a = " ?
                  PokeA(*Ptr + 1, Green(Color))
                  PokeA(*Ptr + 2, Red(Color))
                  If Alpha < 0
                    PokeA(*Ptr + 3, Alpha(Color))
                  Else
                    PokeA(*Ptr + 3, Alpha)
                  EndIf
                Else                                  ; mono-lcd
                  *Ptr = *Ret + (y * Width + x)
                  If Color
                    PokeA(*Ret, 255)
                  Else
                    PokeA(*Ret, 0)
                  EndIf
                EndIf

              Next x
            Next y
            StopDrawing()
          EndIf

        EndIf
      EndIf
    EndIf

    ProcedureReturn *Ret
  EndProcedure

  Procedure Dummy()
    ProcedureReturn #False
  EndProcedure

EndModule

DeclareModule LCD

  #TYPE_Mono             = %1                    ;= &00000001
  #TYPE_Color            = %10                   ;= &00000002

  #BUTTON_Mono_0         = %1                    ;= &00000001
  #BUTTON_Mono_1         = %10                   ;= &00000002
  #BUTTON_Mono_2         = %100                  ;= &00000004
  #BUTTON_Mono_3         = %1000                 ;= &00000008

  #BUTTON_Color_Left     = %100000000            ;= &00000100
  #BUTTON_Color_Right    = %1000000000           ;= &00000200
  #BUTTON_Color_Ok       = %10000000000          ;= &00000400
  #BUTTON_Color_Cancel   = %100000000000         ;= &00000800
  #BUTTON_Color_Up       = %1000000000000        ;= &00001000
  #BUTTON_Color_Down     = %10000000000000       ;= &00002000
  #BUTTON_Color_Menu     = %100000000000000      ;= &00004000

  #WIDTH_Mono            = 160;
  #HEIGTH_Mono           = 43 ;
  #MAXLINE_Mono          = 3

  #WIDTH_Color           = 320;
  #HEIGTH_Color          = 240;
  #MAXLINE_Color         = 7

  Declare Init(AppName$ = "", DLL$ = "LogitechLcd.dll", Type = LCD::#TYPE_Color | LCD::#TYPE_Mono)
  ; AppName = name of your app ... who could have guessed that?
  ; DLL$ = Path to LogitechLcd.dll ... most located at "C:\Program Files\Logitech Gaming Software\SDK\LCD\<youre arch>\LogitechLcd.dll"
  ;         you can try LCD:GetLCD_DLL_Path()
  ; Type = one or both type of lcd ... doesn't matter if it is connected


  Declare Free()
  ; clean up, free resources, close dll, etc.

  Declare.s GetLCD_DLL_Path()
  ; this function isnt very tricky

  PrototypeC LogiLcdColorSetBackground(*Color_Bitmap)
  ; use CreatePxArray() to create *Color_Bitmap

  PrototypeC LogiLcdColorSetText(LineNbr, Text.p-Unicode, Red = 255, Green = 255, Blue = 255)
  ;                LineNbr can be 0 to 7
  ;                Text ... if its too long, it will be truncated
  ;                Red / Green / Blue ... Values from 0 to 255

  PrototypeC LogiLcdColorSetTitle(Text.p-unicode, Red, Green, Blue)
  ;                Same as SetText() ... but its the first Line in bigger letters

  PrototypeC LogiLcdIsButtonPressed(Button)
  ;                discover any pressed buttons on mono or color lcd

  PrototypeC LogiLcdIsConnected(Type)
  ;                use #TYPE_Mono, #TYPE_Color or both with "|"
  ;                #true if available

  PrototypeC LogiLcdMonoSetBackground(*Mono_Bitmap)
  ;                same as the one for color lcd ... but different pixmap
  ;                ... use mono = #True in CreatePxArray()


  PrototypeC LogiLcdMonoSetText(Line, Text.p-unicode)
  ;                LineNbr can be 0 to 3
  ;                Text ... if its too long, it will be truncated

  PrototypeC LogiLcdUpdate()
  ;       you have to use this in your main-loop to update the lcd(s)



  ; Description see above ... Disabled before Init() successed
  Global Color_SetBackground.LogiLcdColorSetBackground        = Logitech_Common::@Dummy()
  Global Color_SetText.LogiLcdColorSetText                    = Logitech_Common::@Dummy()
  Global Color_SetTitle.LogiLcdColorSetTitle                  = Logitech_Common::@Dummy()
  Global IsButtonPressed.LogiLcdIsButtonPressed               = Logitech_Common::@Dummy()
  Global IsConnected.LogiLcdIsConnected                       = Logitech_Common::@Dummy()
  Global Mono_SetBackground.LogiLcdMonoSetBackground          = Logitech_Common::@Dummy()
  Global Mono_SetText.LogiLcdMonoSetText                      = Logitech_Common::@Dummy()
  Global Update.LogiLcdUpdate                                 = Logitech_Common::@Dummy()

  Macro CreatePxArray(_Image_, _Width_ = LCD::#WIDTH_Color, _Heigth_ = LCD::#HEIGTH_Color, _Mono_ = #False, _Alpha_ = -1)
    Logitech_Common::CreatePxArray(_Image_, _Width_, _Heigth_, _Mono_, _Alpha_)
  EndMacro
            ; create logitech combatible pixel-array
            ; Image = pb's "#Image"
            ; if mono = #true, create mono  combatibel pixmap
            ; set Alpha to override Alpha


  Macro FreePxArray(_Ptr_)        ; free resurces reserved for pixmap
    Logitech_Common::FreePxArray(_Ptr_)
  EndMacro
  Macro Color_IsConnected()       ; true if color-lcd  is connected
    LCD::IsConnected(LCD::#TYPE_Color)
  EndMacro
  Macro Mono_IsConnected()        ; true if mono-lcd is connected
    LCD::IsConnected(LCD::#TYPE_Mono)
  EndMacro

EndDeclareModule

Module LCD
  EnableExplicit

  PrototypeC LogiLcdInit(AppName$, Type)
  PrototypeC LogiLcdShutdown()

  Global LcdInit.LogiLcdInit                = Logitech_Common::@Dummy()
  Global LcdShutdown.LogiLcdShutdown        = Logitech_Common::@Dummy()
  Global hDLL

  Procedure.s GetLCD_DLL_Path()
    Protected Ret.s, Arch.s

    ; not very smart, i know ...

    If #PB_Compiler_Processor = #PB_Processor_x86
      Arch = "x86"
    Else
      Arch = "x64"
    EndIf

    Ret = Logitech_Common::GetLCorePath()
    Ret + "\SDK\LCD\" + Arch + "\LogitechLCD.dll"

    ProcedureReturn Ret
  EndProcedure

  Procedure Init(AppName$ = "", DLL$ = "LogitechLcd.dll", Type = LCD::#TYPE_Color | LCD::#TYPE_Mono)

    hDLL = OpenLibrary(#PB_Any, DLL$)
    If hDLL

      Color_SetBackground = GetFunction(hDLL, "LogiLcdColorSetBackground")
      Color_SetText = GetFunction(hDLL, "LogiLcdColorSetText")
      Color_SetTitle = GetFunction(hDLL, "LogiLcdColorSetTitle")
      IsButtonPressed = GetFunction(hDLL, "LogiLcdIsButtonPressed")
      IsConnected = GetFunction(hDLL, "LogiLcdIsConnected")
      Mono_SetBackground = GetFunction(hDLL, "LogiLcdMonoSetBackground")
      Mono_SetText = GetFunction(hDLL, "LogiLcdMonoSetText")
      Update = GetFunction(hDLL, "LogiLcdUpdate")
      LcdInit = GetFunction(hDLL, "LogiLcdInit")
      LcdShutdown = GetFunction(hDLL, "LogiLcdShutdown")

      ProcedureReturn LcdInit(AppName$, Type)
    EndIf

    ProcedureReturn #False
  EndProcedure
  Procedure Free()

    ; shut down lcd
    If LcdShutdown
      LcdShutdown()
    EndIf

    ; close library
    If hDLL
      If IsLibrary(hDLL)
        CloseLibrary(hDLL)
      EndIf
    EndIf

    ; disable functions
    Color_SetBackground           = Logitech_Common::@Dummy()
    Color_SetText                 = Logitech_Common::@Dummy()
    Color_SetTitle                = Logitech_Common::@Dummy()
    IsButtonPressed               = Logitech_Common::@Dummy()
    IsConnected                   = Logitech_Common::@Dummy()
    Mono_SetBackground            = Logitech_Common::@Dummy()
    Mono_SetText                  = Logitech_Common::@Dummy()
    Update                        = Logitech_Common::@Dummy()
    LcdInit                       = Logitech_Common::@Dummy()
    LcdShutdown                   = Logitech_Common::@Dummy()

  EndProcedure

EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
    UsePNGImageDecoder()
  
    Enumeration Images
      #Color_BG
      #PB_Logo
      #Mono_BG
    EndEnumeration
    #LogoW = 48
    #LogoH = 48
  
    Declare ColorBG(Img, Speed = 1)       ; do some animations
    #AppName = "Logitech LCD Test"
  
    Define *ColorPxArray, *MonoPxArray, *MonoPxArray2, Button.s, DLL_Path.s
    Define i, y, x, c
  
    ; create a backgroundimage and load icon
    CreateImage(#Color_BG, LCD::#WIDTH_Color, LCD::#WIDTH_Color, 24, #Black)
    CatchImage(#PB_Logo, ?PB_Logo)
  
    ; create two backgrounds for mono lcd ... we can LCD::CreatePxArray()
    *MonoPxArray = AllocateMemory(LCD::#HEIGTH_Mono * LCD::#WIDTH_Mono)
    *MonoPxArray2 = AllocateMemory(LCD::#HEIGTH_Mono * LCD::#WIDTH_Mono)
    For y = 0 To LCD::#HEIGTH_Mono - 1
      For x = 0 To LCD::#WIDTH_Mono - 1
        If x % 2 = 0 And Not y % 2
          c = 255
         Else
          c = 0
        EndIf
        PokeA(*MonoPxArray + y * LCD::#WIDTH_Mono + x, c)
        If x % 4 = 0 And y % 4 = 0
          c = 255
         Else
          c = 0
        EndIf
        PokeA(*MonoPxArray2 + y * LCD::#WIDTH_Mono + x, c)
      Next x
    Next y
  
    ; try to get location of dll and initialize it
    Logitech_Common::GetLCorePath()
    DLL_Path = LCD::GetLCD_DLL_Path()
    LCD::Init(#AppName, DLL_Path)
  
  
    ; now we can put some text on lcd
    LCD::Color_SetTitle(#AppName, 255, 0, 0)
    LCD::Color_SetText(0, "Line 1 ... Blue", 0, 0, 255)
    LCD::Color_SetText(1, "Line 2 ... Green", 0, 255, 0)
    LCD::Color_SetText(2, "Line 3 ... Yellow", 255, 255, 0)
    LCD::Color_SetText(LCD::#MAXLINE_Color, "Press <Back> to Quit", 0, 0, 0)
  
    If LCD::Color_IsConnected()
      LCD::Color_SetText(3, "Found Color LCD", 255, 128, 64)
      LCD::Mono_SetText(0, "Found Color LCD")
    EndIf
    If LCD::Mono_IsConnected()
      LCD::Color_SetText(4, "Found Mono LCD", 128, 128, 128)
      LCD::Mono_SetText(1, "Found Mono LCD")
    EndIf
  
    LCD::Mono_SetText(LCD::#MAXLINE_Mono, "  BTN0     BTN1     BTN2      Quit")
  
  
    Repeat
      If i < 1
        i = 1
      ElseIf i > 16
        i = 16
      EndIf
  
      ; little dynamic on lcd
      LCD::Color_SetText(5, "Speed: " + Str(i) + " " + RSet("", i, Chr(187)), i * 16 - 1, 255 - i * 16, 0)
      ; create new background for color lcd
      ColorBG(#Color_BG, i)
      ; convert it to pixmap
      *ColorPxArray = LCD::CreatePxArray(#Color_BG)
      ; set new background
      LCD::Color_SetBackground(*ColorPxArray)
      ; free pixmap
      LCD::FreePxArray(*ColorPxArray)
  
  
  
      ; do somthing with buttons (mono)
      Button = ""
      If LCD::IsButtonPressed(LCD::#BUTTON_Mono_0)
        Button + "0 "
        LCD::Mono_SetBackground(*MonoPxArray)
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Mono_1)
        Button + "1 "
        LCD::Mono_SetBackground(*MonoPxArray2)
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Mono_2)
        Button + "2 "
        LCD::Mono_SetBackground(0)
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Mono_3)
        Break
      EndIf
      If Button = ""
        Button = "Buttons: NONE"
      Else
        Button = "Buttons: " + Button
      EndIf
      LCD::Mono_SetText(2, Button)
  
  
  
      ; do somthing with buttons (color)
      Button = ""
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Ok)
        Button + "OK "
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Up)
        i + 1
        Button + "UP "
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Down)
        i - 1
        Button + "DOWN "
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Left)
        Button + "LEFT "
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Right)
        Button + "RIGHT "
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Menu)
        i = 1
        Button + "MENU "
      EndIf
      If LCD::IsButtonPressed(LCD::#BUTTON_Color_Cancel)
        Break
      EndIf
      If Button = ""
        Button = "Buttons: NONE"
      Else
        Button = "Buttons: " + Button
      EndIf
      LCD::Color_SetText(6, Button)
  
      ; update lcd ... same as FlipBuffers() ... i think ^^
      LCD::Update()
    ForEver
  
    ; free resources and quit
    LCD::Free()
    LCD::FreePxArray(*MonoPxArray)
    LCD::FreePxArray(*MonoPxArray2)
  
    Procedure ColorBG(Img, Speed = 1)
      Protected XMid, Y3rd
      Static LogoX, LogoY, DirX = 1, DirY = 1
      Static C
  
      ; mix colors
      If c < $FF
        c + 1
      ElseIf c < $FF00
        c + $100
        c - 1
      ElseIf c < $FF0000
        c + $10000
        c - $100
      ElseIf c > $FE0000
        c = 0
      EndIf
  
      ; calc direction
      If DirX > 0
        If LogoX >= LCD::#WIDTH_Color - #LogoW - Speed
          DirX = -1
        EndIf
      ElseIf DirX < 0
        If LogoX < 0
          DirX = 1
        EndIf
      EndIf
      If DirY > 0
        If LogoY >= LCD::#HEIGTH_Color - #LogoH - Speed
          DirY = -1
        EndIf
      ElseIf DirY < 0
        If LogoY < 0
          DirY = 1
        EndIf
      EndIf
  
      LogoX + DirX * Speed
      LogoY + DirY * Speed
  
  
      ; draw box with gradient and pb-logo
      If IsImage(Img)
        If StartDrawing(ImageOutput(Img))
          XMid = LCD::#WIDTH_Color / 2 - 1
          Y3rd = LCD::#HEIGTH_Color / 1.5 - 1
          DrawingMode(#PB_2DDrawing_Gradient)
          FrontColor(0)
          BackColor(c)
          LinearGradient(XMid, LCD::#HEIGTH_Color - 1, XMid, Y3rd)
          Box(0, 0, LCD::#WIDTH_Color, LCD::#HEIGTH_Color)
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          DrawImage(ImageID(#PB_Logo), LogoX, LogoY)
          StopDrawing()
          ProcedureReturn #True
        EndIf
      EndIf
  
      ProcedureReturn #False
    EndProcedure
  
    DataSection
    PB_Logo:
      Data.b $89,$50,$4E,$47,$0D,$0A,$1A,$0A,$00,$00,$00,$0D,$49,$48,$44,$52
      Data.b $00,$00,$00,$30,$00,$00,$00,$30,$08,$06,$00,$00,$00,$57,$02,$F9
      Data.b $87,$00,$00,$00,$09,$70,$48,$59,$73,$00,$00,$1C,$20,$00,$00,$1C
      Data.b $20,$01,$CD,$0F,$9B,$9E,$00,$00,$00,$07,$74,$49,$4D,$45,$07,$D6
      Data.b $0C,$1C,$15,$17,$0D,$B6,$53,$C9,$04,$00,$00,$0C,$9C,$49,$44,$41
      Data.b $54,$68,$DE,$D5,$99,$79,$8C,$5D,$D7,$5D,$C7,$3F,$E7,$9C,$7B,$EF
      Data.b $5B,$E6,$BD,$D9,$17,$CF,$E2,$78,$A9,$27,$09,$B6,$A2,$26,$71,$90
      Data.b $93,$8A,$2C,$60,$D2,$02,$6D,$54,$94,$96,$48,$24,$6D,$11,$55,$55
      Data.b $05,$A5,$40,$25,$4A,$04,$52,$A1,$82,$06,$A9,$8A,$10,$02,$A1,$A6
      Data.b $34,$40,$45,$CB,$2A,$0A,$51,$A0,$B4,$84,$2C,$4E,$52,$E3,$6C,$B6
      Data.b $C7,$F6,$64,$C6,$19,$7B,$16,$8F,$67,$5F,$DF,$BE,$DF,$77,$CF,$E1
      Data.b $8F,$7B,$66,$3C,$36,$89,$ED,$B1,$C7,$48,$1C,$E9,$E8,$5E,$DD,$27
      Data.b $BD,$FB,$FB,$9E,$DF,$F6,$FD,$FE,$AE,$62,$8B,$56,$4B,$3C,$2A,$9E
      Data.b $79,$F4,$A1,$96,$87,$F6,$DF,$D6,$11,$53,$2A,$32,$B6,$94,$52,$81
      Data.b $D6,$0E,$A0,$00,$B9,$61,$0B,$BB,$B9,$E4,$FE,$9A,$96,$D8,$22,$FB
      Data.b $C5,$F4,$23,$0F,$7E,$B9,$51,$D7,$FF,$D8,$F1,$5C,$29,$1C,$15,$18
      Data.b $29,$2B,$06,$72,$46,$90,$D1,$82,$4C,$A0,$C9,$D4,$B5,$49,$D7,$11
      Data.b $E9,$BA,$54,$99,$9A,$A3,$D2,$15,$A9,$D2,$45,$44,$2A,$A7,$4D,$7A
      Data.b $36,$5F,$4A,$1D,$3E,$37,$93,$7E,$73,$72,$B6,$70,$66,$25,$E5,$07
      Data.b $DA,$68,$60,$6D,$07,$F6,$7A,$63,$00,$9C,$79,$E2,$D1,$9B,$55,$A6
      Data.b $30,$50,$74,$DD,$06,$E3,$07,$18,$BF,$8E,$30,$06,$61,$C0,$51,$02
      Data.b $E5,$39,$38,$9E,$83,$F2,$5C,$1C,$C7,$C5,$95,$02,$19,$F8,$50,$2E
      Data.b $41,$AD,$82,$10,$E0,$7A,$11,$94,$E7,$82,$52,$B5,$74,$AE,$58,$D0
      Data.b $F9,$6A,$26,$55,$F5,$8F,$DC,$F9,$C3,$D7,$9E,$06,$E6,$81,$8C,$05
      Data.b $72,$D1,$72,$AE,$D7,$F8,$87,$6F,$DE,$A1,$A2,$E9,$FC,$B7,$A7,$CF
      Data.b $4F,$37,$68,$40,$1B,$83,$36,$60,$08,$37,$F6,$AA,$0D,$04,$1A,$02
      Data.b $6D,$D0,$08,$94,$1B,$C5,$69,$6A,$C2,$69,$6C,$42,$7A,$1E,$A2,$0A
      Data.b $C2,$57,$4C,$8D,$0C,$7A,$1D,$41,$AD,$75,$5F,$57,$57,$FC,$E1,$D7
      Data.b $DE,$01,$B8,$17,$78,$1D,$28,$DC,$10,$00,$7F,$76,$FF,$81,$2F,$2E
      Data.b $9C,$9D,$78,$C0,$6C,$74,$AB,$00,$63,$42,$F7,$5E,$78,$6E,$C2,$80
      Data.b $17,$20,$8D,$41,$FB,$15,$AA,$2B,$15,$CA,$2B,$4B,$61,$6C,$08,$45
      Data.b $C1,$D4,$89,$F9,$25,$F6,$DF,$B4,$DD,$FC,$C2,$91,$E3,$E9,$C9,$62
      Data.b $69,$9B,$B5,$B1,$F6,$7E,$C6,$63,$93,$EA,$9A,$D7,$D0,$AF,$3D,$BA
      Data.b $33,$37,$B3,$F0,$8D,$AA,$EF,$83,$31,$18,$13,$9A,$6B,$36,$A2,$31
      Data.b $1B,$1E,$08,$90,$02,$A4,$B4,$5B,$80,$14,$06,$25,$C0,$77,$14,$54
      Data.b $0A,$3C,$B0,$BD,$8F,$2F,$9D,$1A,$C9,$1F,$4B,$65,$97,$80,$53,$C0
      Data.b $00,$B0,$B8,$E5,$00,$6E,$EF,$68,$91,$D1,$E5,$D4,$B7,$B2,$D9,$6C
      Data.b $23,$18,$CC,$DA,$59,$6F,$30,$DE,$98,$0D,$BF,$58,$8F,$20,$D6,$C2
      Data.b $CB,$80,$08,$EF,$44,$43,$92,$62,$6E,$85,$7B,$BB,$B7,$F1,$17,$E7
      Data.b $E7,$4A,$FF,$3C,$35,$37,$0F,$BC,$03,$BC,$0C,$BC,$07,$14,$2F,$FE
      Data.b $E7,$2D,$00,$F0,$DC,$CF,$3F,$F0,$B9,$D4,$C2,$E2,$CF,$69,$63,$42
      Data.b $43,$0D,$18,$63,$CD,$5D,$F7,$C6,$C5,$EF,$34,$EF,$03,$D0,$4D,$B6
      Data.b $B0,$9C,$5A,$E4,$F6,$D6,$56,$4E,$94,$AB,$B5,$AF,$0D,$9D,$59,$02
      Data.b $4E,$00,$2F,$59,$0F,$64,$3F,$A8,$02,$61,$6B,$F4,$A6,$D7,$C0,$AF
      Data.b $7E,$AA,$A7,$3E,$33,$FF,$7C,$B1,$52,$89,$E9,$75,$E3,$2F,$24,$EE
      Data.b $7A,$F2,$1A,$61,$3D,$20,$2C,$B0,$8B,$81,$44,$92,$CD,$2C,$66,$D3
      Data.b $EC,$F0,$1C,$62,$8D,$8D,$C1,$27,$0F,$1F,$5D,$AE,$69,$3D,$08,$FC
      Data.b $27,$F0,$DF,$36,$74,$EA,$97,$B3,$65,$D3,$49,$BC,$2D,$1E,$95,$0D
      Data.b $CB,$A9,$3F,$9F,$CF,$64,$5B,$EB,$DA,$86,$87,$14,$08,$21,$C2,$E4
      Data.b $15,$62,$3D,$65,$8D,$08,$BD,$83,$30,$17,$9D,$BC,$30,$E0,$C5,$13
      Data.b $A4,$2A,$55,$9A,$B4,$4F,$7F,$4F,$AF,$B9,$FF,$D5,$37,$53,$85,$7A
      Data.b $7D,$14,$38,$04,$1C,$B1,$A5,$D3,$BF,$92,$3D,$9B,$06,$F0,$BD,$BB
      Data.b $6F,$DB,$51,$2A,$64,$9B,$DC,$98,$BB,$D4,$28,$44,$9B,$13,$68,$55
      Data.b $01,$7C,$24,$01,$10,$04,$9A,$7A,$50,$47,$23,$C2,$92,$23,$42,$4F
      Data.b $5C,$F4,$52,$2F,$42,$59,$45,$08,$52,$33,$7C,$64,$D7,$4E,$1E,$79
      Data.b $EB,$64,$F6,$5C,$A1,$34,$09,$FC,$D8,$EE,$F3,$B6,$F2,$DC,$90,$4E
      Data.b $DC,$00,$7C,$18,$F8,$B8,$14,$E2,$CE,$CE,$88,$D7,$D6,$1F,$75,$93
      Data.b $3B,$A3,$5E,$BC,$37,$EA,$C5,$BA,$63,$D1,$C8,$81,$F6,$D6,$86,$42
      Data.b $D5,$57,$75,$AD,$C1,$7A,$06,$04,$CA,$F5,$30,$DA,$40,$73,$27,$33
      Data.b $D3,$A3,$1C,$DC,$BE,$9D,$A7,$46,$27,$0B,$CF,$8E,$4D,$4E,$02,$AF
      Data.b $00,$CF,$DB,$F8,$CF,$7D,$50,$D2,$6E,$05,$00,$0F,$E8,$06,$3E,$64
      Data.b $AF,$4D,$76,$37,$02,$4D,$F7,$75,$B4,$DC,$FC,$F5,$5D,$7D,$3F,$5D
      Data.b $F1,$7D,$A9,$A5,$40,$08,$89,$10,$82,$68,$A2,$89,$B2,$72,$E9,$2E
      Data.b $67,$19,$CE,$64,$D8,$D7,$DE,$C1,$6B,$C5,$4A,$F9,$37,$8F,$0D,$CE
      Data.b $D8,$90,$79,$0E,$78,$13,$48,$5D,$2E,$69,$B7,$A2,$91,$F9,$C0,$1C
      Data.b $B0,$02,$44,$2C,$A0,$28,$10,$FB,$E8,$AE,$BE,$9D,$7F,$78,$53,$CF
      Data.b $F7,$D2,$B9,$9C,$34,$80,$D1,$06,$21,$34,$5E,$34,$46,$25,$92,$20
      Data.b $7D,$EE,$34,$BB,$3E,$B4,$C7,$FC,$D5,$E8,$54,$7E,$78,$7C,$2E,$B7
      Data.b $58,$A9,$AE,$00,$EF,$02,$2F,$DA,$7A,$9F,$DE,$8C,$F1,$D7,$0A,$C0
      Data.b $58,$10,$BE,$AD,$CF,$02,$E0,$B7,$EE,$DC,$1B,$FB,$62,$6F,$F7,$B3
      Data.b $53,$B3,$B3,$ED,$D2,$5A,$61,$0C,$08,$29,$50,$AD,$3D,$4C,$9F,$3D
      Data.b $C9,$DD,$BB,$76,$F3,$C4,$C0,$70,$EE,$D0,$D2,$EA,$14,$30,$04,$0C
      Data.b $5B,$00,$A7,$80,$A5,$0F,$6A,$56,$5B,$0A,$E0,$C4,$E7,$7F,$B1,$AF
      Data.b $AB,$BD,$E5,$EE,$B9,$7C,$31,$FF,$97,$C7,$4E,$9F,$FD,$F6,$D1,$A1
      Data.b $55,$A0,$FE,$1B,$7B,$76,$FE,$C9,$FC,$EC,$DC,$4F,$79,$9E,$8B,$D6
      Data.b $10,$18,$83,$36,$86,$78,$F7,$2E,$46,$CE,$BE,$CB,$BE,$BE,$3E,$7E
      Data.b $F7,$BD,$F1,$FC,$CB,$0B,$4B,$D3,$B6,$44,$FE,$97,$6D,$52,$CB,$96
      Data.b $E7,$F8,$D7,$52,$D2,$37,$95,$03,$23,$8F,$7C,$7C,$77,$9B,$E7,$9F
      Data.b $90,$E5,$5A,$A3,$17,$8B,$E2,$C6,$63,$A6,$8C,$9C,$AF,$69,$31,$5D
      Data.b $5C,$4E,$1D,$F0,$A5,$C0,$AF,$07,$54,$FD,$80,$7A,$60,$50,$89,$36
      Data.b $06,$C7,$DE,$A3,$29,$1E,$E5,$B9,$D5,$5C,$F1,$EF,$C7,$26,$D7,$8C
      Data.b $FF,$37,$DB,$69,$53,$F6,$D4,$CD,$B5,$36,$D4,$AB,$F6,$C0,$67,$77
      Data.b $F7,$39,$CD,$75,$FF,$AF,$4B,$42,$37,$CA,$B6,$26,$F2,$42,$11,$18
      Data.b $21,$02,$4D,$4F,$63,$26,$D7,$D3,$D8,$D5,$46,$60,$04,$D5,$9A,$4F
      Data.b $B9,$E2,$83,$8C,$71,$6C,$6C,$94,$93,$B3,$73,$2C,$B5,$75,$54,$FE
      Data.b $69,$6C,$72,$19,$38,$69,$3B,$EC,$80,$35,$BE,$7E,$BD,$64,$F2,$6A
      Data.b $01,$88,$A7,$EF,$D8,$F7,$EB,$C2,$D1,$0F,$44,$3D,$17,$53,$AD,$13
      Data.b $51,$06,$A9,$1C,$8C,$00,$A7,$B3,$05,$E5,$44,$08,$0C,$18,$E9,$10
      Data.b $C8,$18,$D3,$B9,$22,$AB,$E9,$15,$5A,$1C,$C5,$1D,$1E,$D1,$5F,$BE
      Data.b $7F,$7F,$B7,$1B,$8D,$DC,$E1,$41,$09,$6D,$92,$43,$99,$DC,$C9,$3F
      Data.b $38,$75,$76,$32,$5D,$F3,$2B,$36,$7C,$D6,$44,$8B,$D9,$F2,$10,$1A
      Data.b $FD,$D4,$47,$F7,$36,$4B,$73,$54,$C4,$9C,$B8,$11,$21,$9D,$14,$CA
      Data.b $41,$48,$85,$54,$0A,$A9,$1C,$84,$0A,$63,$BF,$EA,$07,$94,$CB,$3E
      Data.b $E5,$9A,$8F,$89,$46,$A9,$6B,$4D,$10,$F8,$54,$4A,$45,$74,$21,$4F
      Data.b $BC,$52,$A0,$39,$E2,$12,$73,$5C,$DC,$48,$24,$8F,$1B,$19,$79,$FC
      Data.b $E8,$D0,$D7,$BE,$3F,$39,$3B,$68,$2B,$5B,$75,$4B,$3D,$F0,$D4,$87
      Data.b $6F,$F6,$9A,$D1,$DF,$51,$31,$27,$AE,$37,$E2,$5E,$A3,$CE,$6B,$47
      Data.b $A6,$0D,$C6,$08,$04,$02,$29,$15,$AE,$32,$D4,$7D,$8D,$A7,$5C,$DC
      Data.b $68,$03,$AD,$8D,$9D,$18,$2F,$8A,$69,$68,$24,$9D,$5A,$62,$F0,$D8
      Data.b $6B,$EC,$4D,$36,$25,$FF,$71,$75,$31,$FA,$FD,$C9,$D9,$7B,$AC,$E1
      Data.b $45,$DB,$81,$AF,$DA,$0B,$57,$62,$A3,$E2,$0B,$3B,$7B,$9F,$54,$51
      Data.b $79,$E0,$82,$02,$17,$17,$5F,$4D,$C8,$8F,$D7,$08,$1D,$58,$5E,$24
      Data.b $25,$42,$48,$A4,$08,$29,$85,$90,$0A,$57,$3A,$88,$62,$85,$F1,$63
      Data.b $6F,$B0,$23,$12,$E7,$07,$D9,$42,$E9,$F7,$4F,$BD,$07,$D0,$62,$8D
      Data.b $DE,$DA,$32,$3A,$F1,$B1,$03,$B7,$47,$A4,$F9,$AA,$72,$54,$28,$0B
      Data.b $85,$C4,$08,$19,$1A,$27,$25,$88,$D0,$48,$83,$E4,$02,$7B,$5E,$23
      Data.b $76,$12,$69,$F9,$90,$10,$E1,$30,$A2,$5E,$0F,$38,$79,$FC,$75,$7A
      Data.b $84,$66,$C4,$50,$FB,$CA,$C0,$F0,$32,$70,$06,$78,$1B,$18,$03,$CA
      Data.b $9B,$CD,$81,$CB,$D2,$E9,$A9,$72,$35,$98,$C9,$E5,$53,$A3,$4B,$E9
      Data.b $F6,$7A,$D5,$4F,$B6,$2B,$E5,$4A,$C7,$11,$D2,$71,$2D,$08,$15,$4A
      Data.b $AB,$90,$86,$A2,$8D,$08,$35,$B1,$D6,$68,$0D,$46,$48,$A4,$08,$F3
      Data.b $04,$E9,$70,$7A,$78,$80,$58,$3E,$4D,$D0,$D8,$58,$7F,$E4,$C8,$F1
      Data.b $45,$5F,$9B,$41,$E0,$47,$96,$C0,$CD,$5F,$4B,$2F,$B8,$2C,$80,$91
      Data.b $7C,$49,$1D,$5A,$CD,$55,$7F,$B8,$94,$CE,$7F,$F7,$FC,$C2,$6A,$A6
      Data.b $5C,$F3,$1E,$EC,$ED,$EC,$10,$9E,$7B,$E1,$F4,$CD,$05,$FA,$AC,$4D
      Data.b $28,$EA,$03,$1D,$0A,$FB,$50,$43,$4A,$A4,$72,$18,$9B,$38,$4B,$7D
      Data.b $69,$86,$8E,$CE,$8E,$E0,$13,$87,$8F,$AD,$14,$EA,$C1,$69,$CB,$FB
      Data.b $5F,$05,$A6,$AE,$96,$7D,$6E,$56,$D0,$68,$9B,$58,$B3,$BF,$D4,$DB
      Data.b $59,$FD,$C6,$5D,$7B,$3F,$EB,$25,$E3,$6E,$28,$50,$04,$06,$C9,$F8
      Data.b $CC,$2A,$A5,$89,$31,$DC,$6A,$99,$A0,$1E,$A0,$09,$E3,$5D,$5B,$50
      Data.b $42,$2A,$66,$16,$E6,$C9,$4C,$8D,$D2,$DF,$DB,$AD,$1F,$3A,$32,$90
      Data.b $5A,$A8,$54,$CF,$5A,$FE,$F3,$12,$30,$B1,$D9,$CA,$B3,$99,$2A,$54
      Data.b $07,$52,$5F,$BD,$75,$47,$ED,$4B,$BB,$B7,$FF,$43,$A4,$B1,$21,$A6
      Data.b $B5,$59,$D7,$B3,$73,$A9,$02,$93,$13,$A3,$F4,$75,$B5,$E9,$4F,$1E
      Data.b $3E,$91,$E9,$95,$54,$EE,$6B,$49,$AA,$FD,$AD,$4D,$89,$BD,$6D,$6D
      Data.b $71,$95,$68,$12,$2B,$5A,$B1,$30,$31,$CC,$1D,$7D,$3D,$E6,$D3,$EF
      Data.b $0C,$66,$CE,$17,$CB,$13,$F6,$D4,$5F,$B1,$C6,$57,$AE,$A7,$13,$5F
      Data.b $B1,$0F,$C4,$1D,$47,$4C,$FC,$CC,$FE,$67,$22,$ED,$6D,$8F,$6B,$A5
      Data.b $C2,$E1,$88,$10,$64,$2A,$9A,$A3,$43,$C3,$F4,$B4,$35,$99,$C7,$4F
      Data.b $9D,$4D,$BD,$97,$2B,$4E,$02,$A7,$ED,$00,$AA,$B9,$41,$A9,$AE,$FB
      Data.b $1A,$63,$DD,$B7,$34,$44,$DB,$13,$5E,$34,$FA,$1F,$A9,$5C,$F9,$64
      Data.b $26,$37,$03,$BC,$06,$FC,$00,$18,$04,$F2,$D7,$63,$FC,$55,$01,$98
      Data.b $3E,$B8,$FF,$B1,$44,$6B,$EB,$DF,$E2,$45,$84,$16,$60,$90,$54,$EA
      Data.b $F0,$C6,$F0,$08,$6E,$D4,$31,$5F,$1F,$9F,$CD,$0C,$A4,$B2,$E7,$AC
      Data.b $14,$3C,$64,$75,$6C,$12,$E8,$B2,$7A,$A1,$07,$E8,$B4,$EF,$1A,$03
      Data.b $0E,$5B,$E3,$B3,$9B,$A5,$CE,$9B,$0E,$A1,$33,$0F,$DC,$FE,$13,$89
      Data.b $64,$F2,$5B,$78,$AE,$08,$45,$79,$58,$65,$06,$C6,$26,$79,$7D,$7A
      Data.b $86,$F9,$D6,$B6,$CA,$C9,$74,$6E,$09,$38,$6A,$E3,$F9,$B8,$55,$53
      Data.b $CA,$6A,$84,$04,$D0,$6C,$05,$8F,$B4,$9D,$76,$CE,$9E,$FC,$75,$1B
      Data.b $7F,$D9,$24,$FE,$D7,$7B,$F6,$C5,$F7,$35,$35,$FE,$48,$26,$13,$3B
      Data.b $40,$AC,$CF,$73,$16,$6B,$01,$E7,$4B,$45,$2A,$F9,$02,$F7,$B4,$35
      Data.b $B9,$BF,$F7,$B3,$F7,$24,$1F,$DE,$DD,$A7,$3E,$D6,$D7,$99,$2E,$F9
      Data.b $C1,$F4,$78,$AE,$50,$B5,$B9,$53,$B1,$86,$AE,$02,$0B,$C0,$AC,$05
      Data.b $50,$B9,$DE,$B0,$B9,$62,$08,$25,$5C,$47,$4C,$1E,$BC,$EB,$59,$AF
      Data.b $B9,$E9,$0B,$5A,$CA,$0B,$E3,$12,$11,$56,$1F,$5F,$2A,$2A,$91,$08
      Data.b $99,$5C,$91,$F4,$EA,$2A,$D1,$5A,$95,$AE,$64,$03,$1D,$AD,$CD,$7E
      Data.b $C5,$98,$E3,$73,$85,$D2,$AB,$87,$E6,$96,$5F,$FC,$CA,$B1,$D3,$43
      Data.b $DA,$98,$D2,$86,$D1,$E0,$96,$19,$7E,$59,$00,$0B,$0F,$FE,$E4,$AF
      Data.b $24,$9B,$9B,$FE,$C6,$B8,$EE,$FA,$7C,$DB,$AC,$F9,$5C,$4A,$90,$2A
      Data.b $6C,$62,$42,$51,$AD,$6B,$2A,$8E,$4B,$BE,$54,$A2,$98,$CF,$E2,$94
      Data.b $8B,$B4,$7A,$2E,$2D,$89,$38,$28,$35,$BD,$5A,$2E,$BF,$7E,$26,$5B
      Data.b $78,$F9,$A9,$E1,$89,$1F,$BF,$B5,$9A,$5B,$B5,$1E,$A8,$6F,$55,$08
      Data.b $FD,$2F,$00,$E3,$07,$F7,$DF,$B6,$AD,$31,$F9,$86,$88,$46,$13,$21
      Data.b $CD,$11,$04,$98,$90,$2A,$0B,$81,$11,$21,$85,$40,$28,$8C,$0C,$AF
      Data.b $DA,$F6,$84,$5A,$3D,$C0,$F7,$5C,$8A,$7E,$8D,$4A,$B9,$08,$99,$14
      Data.b $4D,$D4,$69,$F2,$3C,$12,$B1,$48,$39,$5B,$AD,$BD,$3D,$57,$AA,$1C
      Data.b $7A,$7E,$6E,$E5,$C5,$3F,$1A,$99,$1A,$03,$D6,$BC,$A3,$AF,$D5,$3B
      Data.b $17,$01,$F8,$E6,$81,$7D,$D1,$CF,$B5,$37,$1D,$93,$89,$86,$7D,$C8
      Data.b $90,$BF,$84,$5F,$17,$2C,$00,$42,$00,$6B,$7B,$1D,$C8,$DA,$33,$04
      Data.b $DA,$EE,$40,$1B,$EA,$91,$18,$65,$61,$A8,$96,$F3,$04,$E9,$25,$12
      Data.b $A5,$3C,$CD,$8E,$43,$5B,$3C,$66,$AA,$5A,$8F,$2F,$55,$FD,$57,$07
      Data.b $73,$C5,$97,$7F,$67,$68,$FC,$8D,$B1,$42,$39,$6B,$BD,$13,$6C,$C6
      Data.b $3B,$97,$7A,$C0,$FB,$F2,$EE,$EE,$83,$77,$B5,$34,$3E,$79,$4F,$47
      Data.b $CB,$81,$6D,$89,$86,$98,$56,$2A,$F4,$F7,$06,$00,$7A,$23,$00,$29
      Data.b $31,$22,$FC,$8A,$A4,$C5,$5A,$87,$16,$68,$2C,$C9,$13,$12,$23,$25
      Data.b $81,$EB,$51,$F3,$5C,$CA,$A5,$0C,$F5,$EC,$32,$B1,$CC,$0A,$ED,$AE
      Data.b $43,$B3,$EB,$A1,$94,$93,$5B,$AD,$D5,$DF,$38,$5F,$AE,$BE,$F2,$77
      Data.b $53,$F3,$2F,$3D,$33,$3E,$7D,$DE,$32,$80,$FA,$95,$3C,$73,$69,$15
      Data.b $92,$6F,$A5,$0B,$FA,$B9,$F9,$D5,$EC,$37,$C7,$67,$B3,$43,$A9,$B4
      Data.b $1F,$0D,$02,$AF,$2F,$E2,$C5,$94,$72,$C2,$09,$95,$10,$F6,$1F,$C5
      Data.b $DA,$C4,$7F,$C3,$1B,$C4,$C6,$2F,$01,$17,$EE,$85,$44,$21,$88,$18
      Data.b $49,$C2,$4D,$10,$4D,$76,$22,$FA,$F6,$90,$8E,$27,$59,$74,$24,$2B
      Data.b $D9,$74,$24,$22,$D8,$B3,$3B,$16,$79,$70,$B4,$54,$6E,$7F,$69,$31
      Data.b $35,$67,$85,$7E,$79,$B3,$00,$B0,$BC,$64,$D9,$C0,$F9,$91,$42,$E5
      Data.b $DC,$BF,$CC,$AD,$4C,$7F,$67,$72,$6E,$39,$5D,$28,$D0,$2A,$45,$B4
      Data.b $D3,$73,$23,$46,$3A,$E1,$0C,$D4,$88,$F5,$CA,$64,$6C,$9D,$DD,$08
      Data.b $CE,$58,$70,$42,$08,$1B,$6E,$E1,$90,$4B,$4A,$85,$AB,$05,$0D,$5E
      Data.b $12,$65,$A2,$2C,$A4,$57,$91,$F9,$A2,$F9,$ED,$33,$13,$0B,$7F,$3A
      Data.b $3A,$BD,$68,$BB,$F9,$F4,$D5,$34,$3B,$F5,$3E,$33,$9F,$9A,$6D,$46
      Data.b $8B,$76,$46,$39,$5E,$0E,$F4,$B9,$B7,$33,$85,$73,$DF,$9D,$5A,$98
      Data.b $79,$61,$6E,$29,$67,$AA,$65,$D5,$E7,$AA,$78,$C2,$71,$94,$91,$CE
      Data.b $45,$A7,$7D,$61,$42,$BD,$E6,$A1,$B5,$9F,$2D,$ED,$DE,$00,$AC,$5A
      Data.b $2C,$30,$F9,$EE,$11,$3A,$74,$D5,$3C,$39,$36,$95,$FB,$F7,$B9,$95
      Data.b $05,$3B,$2B,$3A,$6A,$79,$52,$E9,$4A,$1E,$10,$57,$91,$23,$8E,$ED
      Data.b $AA,$2D,$96,$1A,$EC,$04,$FA,$A5,$10,$FD,$0F,$75,$35,$DF,$FA,$E9
      Data.b $9E,$AE,$5D,$F7,$76,$77,$B5,$39,$B1,$A4,$34,$8E,$67,$3D,$22,$D1
      Data.b $A8,$F5,$9C,$40,$2A,$BB,$43,$1D,$2D,$94,$43,$B9,$54,$60,$E6,$CC
      Data.b $00,$ED,$51,$C7,$3C,$71,$7A,$3C,$F3,$56,$2A,$37,$65,$47,$2E,$2F
      Data.b $00,$C7,$6C,$D3,$AB,$5F,$37,$17,$BA,$44,$7E,$BA,$76,$B8,$DB,$06
      Data.b $F4,$01,$BB,$81,$9B,$5B,$3D,$A7,$FF,$B1,$9E,$F6,$5B,$1E,$EA,$ED
      Data.b $DE,$BE,$B7,$BD,$3D,$59,$8F,$24,$D1,$D2,$59,$4F,$FA,$30,$D9,$D5
      Data.b $FA,$2E,$15,$73,$2C,$4C,$0C,$D3,$1C,$73,$F5,$E7,$07,$47,$D3,$43
      Data.b $21,$11,$3C,$6C,$F5,$C1,$89,$0D,$F3,$A2,$1B,$32,$DC,$15,$16,$4C
      Data.b $C4,$92,$B6,$4E,$E0,$26,$A0,$1F,$E8,$BF,$AD,$31,$7E,$CB,$67,$7A
      Data.b $3B,$F6,$3C,$D8,$DB,$D3,$DD,$92,$68,$F1,$EA,$91,$44,$28,$29,$A5
      Data.b $83,$91,$92,$42,$3E,$C3,$EA,$F4,$28,$B1,$58,$24,$F8,$CC,$C9,$91
      Data.b $D4,$B9,$62,$65,$C2,$7E,$85,$7C,$C1,$92,$BC,$CC,$66,$B4,$B1,$D8
      Data.b $82,$46,$B8,$31,$C4,$B6,$01,$BB,$80,$7E,$25,$44,$FF,$27,$BA,$9A
      Data.b $6F,$7D,$B8,$BB,$63,$D7,$47,$B6,$F5,$B4,$89,$78,$8B,$CC,$96,$4B
      Data.b $64,$17,$A6,$20,$E2,$06,$8F,$9E,$18,$59,$59,$A8,$D4,$C6,$AC,$36
      Data.b $78,$D1,$CE,$4A,$37,$CD,$50,$C5,$16,$D2,$92,$0F,$0C,$B1,$36,$CF
      Data.b $E9,$7F,$AC,$B7,$FD,$D6,$7D,$D1,$58,$EF,$8A,$31,$3C,$3D,$3E,$93
      Data.b $CD,$FA,$F5,$35,$E3,$5F,$B2,$33,$D2,$6B,$62,$A8,$82,$1B,$B3,$D4
      Data.b $25,$21,$B6,$03,$D8,$63,$C3,$AC,$CB,$36,$A9,$E3,$36,$69,$47,$6D
      Data.b $CD,$37,$5B,$C2,$85,$6E,$00,$59,$74,$80,$98,$D5,$05,$DB,$AC,$77
      Data.b $2A,$56,$C8,$CF,$5F,$CB,$28,$E5,$FF,$12,$C0,$A5,$21,$E6,$D8,$30
      Data.b $33,$37,$92,$62,$FF,$BF,$5A,$FF,$03,$14,$40,$F3,$DA,$D8,$5F,$19
      Data.b $B7,$00,$00,$00,$00,$49,$45,$4E,$44,$AE,$42,$60,$82
  EndDataSection
CompilerEndIf
