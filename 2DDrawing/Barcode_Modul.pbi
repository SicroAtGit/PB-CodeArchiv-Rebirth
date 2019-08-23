;   Description: Generates EAN8, EAN13, Code128 bar codes
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=30623
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2018 Michael Suther
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

; BarcodeModul Version 1.3.0 - 14/04/2018

; All code comments have been translated from German into English by Sicro

DeclareModule Common
  EnableExplicit
  Structure Barcode_Parameter
    Type.s                        ; Example: "EAN8", "EAN13", "Code128"
    Text.s                        ; The code digits/letters. Example EAN8: "72395677"
    Font.s                        ; Example: "ocrB". The size will be adjusted automatically. If no font is specified, the code is printed WITHOUT digits.
    Sequence.s                    ; The previously created line sequence.
    Width.i                       ; The barcode width in mm
    Height.i                      ; The barcode height in mm
    PosX.i                        ; Position in mm
    PosY.i                        ; Position in mm
    Color0_RGB.s                  ; Color of the light code lines. Example: "255,255,255". Comma = delimiter
    Color1_RGB.s                  ; Color of the dark code lines. Example: "0,0,0". Comma = delimiter
    ColorDigits_RGB.s             ; Color of the code digits. Example: "0,0,0". Comma = delimiter
  EndStructure
  
  Structure Print_Parameter
    Page_width.d                  ; Paper width in mm
    Page_height.d                 ; Paper height in mm
    Left_edge.d                   ; Printing edge left in mm
    Right_edge.d                  ; Printing edge right in mm
    Top_edge.d                    ; Printing edge top in mm
    Bottom_edge.d                 ; Printing edge bottom in mm
    Pages.i                       ; Number of pages to be printed
    Print_Requester.b             ; #True = The printer requester will be opened. #False = The default printer will be used.
    Doc_Name.s                    ; This text is displayed in the printer queue.
  EndStructure
  
  Structure Text_Line
    Text.s                        ; The text to be printed
    Font.s                        ; Example: "Arial"
    Font_Size.i                   ; Example: 12
    TextColor_RGB.s               ; The color of the text line
    Text_Style.i                  ; Example: #PB_Font_Underline|#PB_Font_Italic
    Text_PosX.i                   ; Position of the text line in mm
    Text_PosY.i                   ; Position of the text line in mm
  EndStructure
  
  Structure SVG_Parameter
    Type.s                        ; Example: "EAN8", "EAN13", "Code128"
    Text.s                        ; The code digits/letters. Example EAN8: "72395677"
    Font.s                        ; Example: "ocrB". The size will be adjusted automatically. If no font is specified, the code is printed WITHOUT digits.
    Sequence.s                    ; The previously created line sequence.
    Width.d                       ; The barcode width in mm
    Height.d                      ; The barcode height in mm
    Color1.s                      ; Color of the dark code lines. Example: "0,0,0". Comma = delimiter
    Color0.s                      ; Color of the light code lines. Example: "255,255,255". Comma = delimiter
  EndStructure
  
  Structure Image_Parameter
    Type.s                        ; Example: Konstante #BCODE_Type_EAN13
    Text.s                        ; The code digits/letters. Example EAN8: "72395677"
    Font.s                        ; Example: "ocrB". The size will be adjusted automatically. If no font is specified, the code is printed WITHOUT digits.
    Sequence.s                    ; The previously created line sequence.
    Width.d                       ; The barcode width in mm
    Height.d                      ; The barcode height in mm
    Color1.s                      ; Color of the dark code lines. Example: "0,0,0". Comma = delimiter
    Color0.s                      ; Color of the light code lines. Example: "255,255,255". Comma = delimiter
    ColorDigits.s                 ; Color of the code digits. Example: "0,0,0". Comma = delimiter
    Image_Number.i                ; Return value of CreateImage()
  EndStructure
  
  
  ; Is used in Barcode_SVG_Export() to adjust the barcode text length.
  ; Default is 50%.
  ; This means: barcode text length = ca. 50% of the barcode length.
  ; Approximately because SVG viewers like Browser or LibreOffice use a larger letter-spacing than the
  ; PureBasic vector library. There is the possibility in SVG to correct this, but unfortunately this was
  ; ignored by LibreOffice.
  #Code128_SVG_Correction  = 50 ; %
  
  ; Constants of supported barcode types
  #BCODE_Type_Code128      = "Code128"
  #BCODE_Type_EAN13        = "EAN13"
  #BCODE_Type_EAN8         = "EAN8"
  
  ; Constants of the most commonly used Code128 control codes
  #BC128_StartA       = "<START A>"
  #BC128_StartB       = "<START B>"
  #BC128_StartC       = "<START C>"
  #BC128_CodeA        = ";<CODE A>"
  #BC128_CodeB        = ";<CODE B>"
  #BC128_CodeC        = ";<CODE C>"
  #BC128_Checksum     = ";<P>"
  #BC128_Stop         = ";<STOP>"
  #BC128_FNC1         = ";<FNC 1>"
  
  ; Constants of Code128 control codes - Code page A, B and C
  #BC128_US           = ";<US>"
  #BC128_FNC3         = ";<FNC 3>"
  #BC128_FNC2         = ";<FNC 2>"
  #BC128_Shift        = ";<SHIFT>"
  #BC128_FNC4         = ";<FNC 4>"
  #BC128_RS           = ";<RS>"
  #BC128_GS           = ";<GS>"
  #BC128_FS           = ";<FS>"
  #BC128_ESC          = ";<ESC>"
  #BC128_SUB          = ";<SUB>"
  #BC128_EM           = ";<EM>"
  #BC128_CAN          = ";<CAN>"
  #BC128_ETB          = ";<ETB>"
  #BC128_SYN          = ";<SYN>"
  #BC128_NAK          = ";<NAK>"
  #BC128_DC4          = ";<DC4>"
  #BC128_DC3          = ";<DC3>"
  #BC128_DC2          = ";<DC2>"
  #BC128_DC1          = ";<DC1>"
  #BC128_DLE          = ";<DLE>"
  #BC128_SI           = ";<SI>"
  #BC128_SO           = ";<SO>"
  #BC128_CR           = ";<CR>"
  #BC128_FF           = ";<FF>"
  #BC128_VT           = ";<VT>"
  #BC128_LF           = ";<LF>"
  #BC128_HT           = ";<HT>"
  #BC128_BS           = ";<BS>"
  #BC128_BEL          = ";<BEL>"
  #BC128_ACK          = ";<ACK>"
  #BC128_ENQ          = ";<ENQ>"
  #BC128_EOT          = ";<EOT>"
  #BC128_ETX          = ";<ETX>"
  #BC128_STX          = ";<STX>"
  #BC128_SOH          = ";<SOH>"
  #BC128_NUL          = ";<NUL>"
  #BC128_DEL          = ";<DEL>"
  
EndDeclareModule
Module Common
  ; Nothing
EndModule

DeclareModule Barcode
  EnableExplicit
  UseModule Common
  
  ; This function requires the 7 digits of the EAN8 code as a string.
  Declare Generate_EAN8_Checksum(digits.s)
  
  ; This function requires the 12 digits of the EAN13 code as a string.
  Declare Generate_EAN13_Checksum(digits.s)
  
  ; This function requires the complete EAN8 code incl. check digit as a string.
  Declare.s Generate_EAN8_Sequence(EAN8.s)
  
  ; This function requires the Code128 as a string.
  ; Example: "<START B>Hello PB-Community"
  Declare Generate_Code128_Checksum(Code128.s)
  
  ; This function requires the complete EAN13 code incl. check digit as a string.
  Declare.s Generate_EAN13_Sequence(EAN13.s)
  
  ; This function requires the complete Code128 incl. check digit and stop character.
  ; Example: "<START B>Hello PB-Community;<P>..;<STOP>"   ".." must be replaced by the check digit.
  Declare.s Generate_Code128_Sequence(Code128.s)
  
  ; See examples
  Declare Print_Barcode(List Barcode.Barcode_Parameter(), *Printer.Print_Parameter, List Text.Text_Line())
  
  ; Exports a barcode to SVG format
  Declare.s Barcode_SVG_Export(*SVG_Export.SVG_Parameter)
  
  ; Exports a barcode to a PureBasic Image/Bitmap
  Declare Barcode_Image_Export(*Image_Export.Image_Parameter)
  
EndDeclareModule

Module Barcode
  
  Procedure Generate_EAN8_Checksum(digits.s)
    Protected.s digit
    Protected i, Dim digit_num(6), a = 0, Odd, Even, checksum
    ; The string must contain 7 digits. If no, abort
    If Len(digits.s) <> 7
      ProcedureReturn 10
    EndIf
    
    ; Split the string digits.s into 7 numbers
    For i = 0 To 13 Step 2
      digit.s = PeekS(@digits.s + i, 1, #PB_Unicode)
      If UCase(digit.s) = LCase(digit.s) ; Check whether really numeric
        digit_num(a) = Val(digit.s)
        a = a + 1
      Else
        ProcedureReturn 11
      EndIf
    Next i
    ; Calculate Odd and Even
    Odd   = digit_num(6) + digit_num(4) + digit_num(2) + digit_num(0)
    Even  = digit_num(5) + digit_num(3) + digit_num(1)
    ; Calculate check digit
    checksum = (10 - (3 * Odd + Even) % 10) %10
    ProcedureReturn checksum
  EndProcedure
  
  Procedure Generate_Code128_Checksum(Code128.s)
    
    Protected.i Sum, ascii, lenght
    Protected.b a, b, c, d, e, f, weighting, value, checksum
    Protected.s Mode, ASCII_String, part, String, NewString
    Protected Dim CodepageA.s(106)
    Protected Dim CodepageB.s(106)
    Protected Dim CodepageC.s(106)
    Protected NewList Parts.s()
    
    ; Check for EAN128/UCC128 (old designation) GS1-128 (current designation)
    If FindString(Code128.s, "<START A>;<FNC 1>") Or FindString(Code128.s, "<START B>;<FNC 1>") Or FindString(Code128.s, "<START C>;<FNC 1>")
      ProcedureReturn 130
    EndIf
    
    ; Read the data section
    Restore CodeA
    For a = 0 To 106
      Read.s CodepageA(a)
    Next a
    Restore CodeB
    For a = 0 To 106
      Read.s CodepageB(a)
    Next a
    Restore CodeC
    For a = 0 To 106
      Read.s CodepageC(a)
    Next a
    
    ; Split the Code128
    a = 0
    Repeat
      a + 1
      part.s = StringField(Code128.s, a, ";")
      If part.s <> "" 
        AddElement(Parts())
        Parts() = part.s
      EndIf
      If FindString(Parts(), "<CODE C>")
        NewString.s = RemoveString(Parts(), "<CODE C>")
        lenght.i = StringByteLength(NewString.s, #PB_Unicode)
        If Len(NewString.s) % 2 > 0
          ProcedureReturn 129  ; Check whether number of digits is even
        EndIf
        Parts() = "<CODE C>"
        For e = 1 To lenght.i Step 4
          String.s = PeekS(@NewString + f, 2, #PB_Unicode)
          AddElement(Parts())
          Parts() = String.s
          f + 4
        Next e
      EndIf
    Until part.s = ""
    
    
    
    ; Determine start code page
    ForEach Parts()
      If FindString(Parts(), "<START A>")
        Mode.s = "A"
      ElseIf FindString(Parts(), "<START B>")
        Mode.s = "B"
      ElseIf FindString(Parts(), "<START C>")
        Mode.s = "C"
      ElseIf Mode = ""
        ProcedureReturn 126 ; No start code
      EndIf
      ; Check whether the code page changes
      If FindString(Parts(), "<CODE A>")
        Mode.s = "A"
        Parts() = ReplaceString(Parts(), "<CODE A>", Chr(133))
      ElseIf FindString(Parts(), "<CODE B>")
        Mode.s = "B"
        Parts() = ReplaceString(Parts(), "<CODE B>", Chr(132))
      ElseIf FindString(Parts(), "<CODE C>")
        Mode.s = "C"
        Parts() = ReplaceString(Parts(), "<CODE C>", Chr(131))
        ; Check whether number of digits is even
        If (Len(Parts()) - 1) % 2 > 0
          ProcedureReturn 29
        EndIf
      EndIf                                            
      ; Control codes to ASCII
      Select Mode.s
        Case "A"
          For a = 64 To 106
            Parts() = ReplaceString(Parts(), CodepageA(a), Chr(a + 32))   
          Next a
        Case "B"
          For a = 95 To 106
            Parts() = ReplaceString(Parts(), CodepageB(a), Chr(a + 32))
          Next a
        Case "C"
          For a = 0 To 106
            Parts() = ReplaceString(Parts(), CodepageC(a), Chr(a + 32))
          Next a        
      EndSelect
      ; Bulid ASCII string
      ASCII_String.s + Parts()
    Next
    ; Code length
    lenght.i = Len(ASCII_String)
    ; Start code
    If PeekS(@ASCII_String.s, 1, #PB_Unicode) = Chr(135)
      Sum.i + 103
    ElseIf PeekS(@ASCII_String.s, 1, #PB_Unicode) = Chr(136)
      Sum.i + 104
    ElseIf PeekS(@ASCII_String.s, 1, #PB_Unicode) = Chr(137)
      Sum.i + 105
    EndIf
    ; Calculate check digit
    For a = 2 To lenght.i * 2 - 2 Step 2
      weighting.b + 1
      ascii.i = Asc(PeekS(@ASCII_String + a, 1, #PB_Unicode))
      Sum.i + (ascii.i - 32) * weighting
    Next a
    checksum.b = Sum.i % 103
    ProcedureReturn checksum.b
    
    
    
    
    DataSection
      CodeA:
      Data.s Chr(32),Chr(33),Chr(34),Chr(35),Chr(36),Chr(37),Chr(38),Chr(39),Chr(40),Chr(41),Chr(42),Chr(43),Chr(44),Chr(45),Chr(46),Chr(47),Chr(48),Chr(49),Chr(50),Chr(51),
             Chr(52),Chr(53),Chr(54),Chr(55),Chr(56),Chr(57),Chr(58),Chr(59),Chr(60),Chr(61),Chr(62),Chr(63),Chr(64),Chr(65),Chr(66),Chr(67),Chr(68),Chr(69),Chr(70),Chr(71),
             Chr(72),Chr(73),Chr(74),Chr(75),Chr(76),Chr(77),Chr(78),Chr(79),Chr(80),Chr(81),Chr(82),Chr(83),Chr(84),Chr(85),Chr(86),Chr(87),Chr(88),Chr(89),Chr(90),Chr(91),
             Chr(92),Chr(93),Chr(94),Chr(95),"<NUL>","<SOH>","<STX>","<ETX>","<EOT>","<ENQ>","<ACK>","<BEL>","<BS>","<HT>","<LF>","<VT>","<FF>","<CR>","<SO>","<SI>","<DLE>",
             "<DC1>","<DC2>","<DC3>","<DC4>","<NAK>","<SYN>","<ETB>","<CAN>","<EM>","<SUB>","<ESC>","<FS>","<GS>","<RS>","<US>","<FNC 3>","<FNC 2>","<SHIFT>","<CODE C>",
             "<CODE B>","<FNC 4>","<FNC 1>","<START A>","<START B>","<START C>","<STOP>"
      CodeB:
      Data.s Chr(32),Chr(33),Chr(34),Chr(35),Chr(36),Chr(37),Chr(38),Chr(39),Chr(40),Chr(41),Chr(42),Chr(43),Chr(44),Chr(45),Chr(46),Chr(47),Chr(48),Chr(49),Chr(50),Chr(51),
             Chr(52),Chr(53),Chr(54),Chr(55),Chr(56),Chr(57),Chr(58),Chr(59),Chr(60),Chr(61),Chr(62),Chr(63),Chr(64),Chr(65),Chr(66),Chr(67),Chr(68),Chr(69),Chr(70),Chr(71),
             Chr(72),Chr(73),Chr(74),Chr(75),Chr(76),Chr(77),Chr(78),Chr(79),Chr(80),Chr(81),Chr(82),Chr(83),Chr(84),Chr(85),Chr(86),Chr(87),Chr(88),Chr(89),Chr(90),Chr(91),
             Chr(92),Chr(93),Chr(94),Chr(95),Chr(96),Chr(97),Chr(98),Chr(99),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),
             Chr(110),Chr(111),Chr(112),Chr(113),Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(119),Chr(120),Chr(121),Chr(122),Chr(123),Chr(124),Chr(125),Chr(126),
             "<DEL>","<FNC 3>","<FNC 2>","<SHIFT>","<CODE C>","<FNC 4>","<CODE A>","<FNC 1>","<START A>","<START B>","<START C>","<STOP>"
      
      CodeC:
      Data.s "00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21",
             "22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43",
             "44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65",
             "66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83",
             "84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","<CODE B>","<CODE A>","<FNC 1>","<START A>",
             "<START B>","<START C>","<STOP>"
      
    EndDataSection
    
  EndProcedure
  
  Procedure Generate_EAN13_Checksum(digits.s)
    Protected.s digit
    Protected i, Dim digit_num(11), a, Odd, Even, checksum
    
    ; The string must contain 12 digits. If no, abort
    If Len(digits.s) <> 12
      ProcedureReturn 10
    EndIf
    
    ; Split the string digits.s into 12 numbers
    For i = 0 To 23 Step 2
      digit.s = PeekS(@digits.s + i, 1, #PB_Unicode)
      If UCase(digit.s) = LCase(digit.s) ; Check whether really numeric
        digit_num(a) = Val(digit.s)
        a = a + 1
      Else
        ProcedureReturn 11
      EndIf
    Next i
    ; Calculate Odd and Even
    Odd   = digit_num(11) + digit_num(9) + digit_num(7) + digit_num(5) + digit_num(3) + digit_num(1)
    Even  = digit_num(10) + digit_num(8) + digit_num(6) + digit_num(4) + digit_num(2) + digit_num(0)
    ; Calculate check digit
    checksum = (10 - (3 * Odd + Even) % 10) %10
    ProcedureReturn checksum
  EndProcedure
  
  Procedure.s Generate_EAN8_Sequence(EAN8.s)  
    Protected.b i, a
    Protected.s part
    ; Will contain the entire EAN8 sequence
    Protected EAN8_Sequence.s  
    ; EAN8 start, center and stop sequences
    Protected EAN8_Start.s   = "101"
    Protected EAN8_Center.s  = "01010" 
    Protected EAN8_Stop.s    = "101"   
    ; EAN8 sequenzes part #1
    Protected Dim EAN8_Sequence_part1.s(9)
    EAN8_Sequence_part1(0) = "0001101"
    EAN8_Sequence_part1(1) = "0011001"
    EAN8_Sequence_part1(2) = "0010011"
    EAN8_Sequence_part1(3) = "0111101"
    EAN8_Sequence_part1(4) = "0100011"
    EAN8_Sequence_part1(5) = "0110001"
    EAN8_Sequence_part1(6) = "0101111"
    EAN8_Sequence_part1(7) = "0111011"
    EAN8_Sequence_part1(8) = "0110111"
    EAN8_Sequence_part1(9) = "0001011"
    ; EAN8 sequenzes part #2
    Protected Dim EAN8_Sequence_part2.s(9)
    EAN8_Sequence_part2(0) = "1110010"
    EAN8_Sequence_part2(1) = "1100110"
    EAN8_Sequence_part2(2) = "1101100"
    EAN8_Sequence_part2(3) = "1000010"
    EAN8_Sequence_part2(4) = "1011100"
    EAN8_Sequence_part2(5) = "1001110"
    EAN8_Sequence_part2(6) = "1010000"
    EAN8_Sequence_part2(7) = "1000100"
    EAN8_Sequence_part2(8) = "1001000"
    EAN8_Sequence_part2(9) = "1110100"
    
    ; The string must contain 8 digits. If no, abort
    If Len(EAN8.s) <> 8
      ProcedureReturn "12"
    EndIf
    ; Check whether really numeric
    If UCase(EAN8.s) <> LCase(EAN8.s)
      ProcedureReturn "13"
    EndIf
    
    ; Build sequence
    EAN8_Sequence.s + EAN8_Start.s                    ; Start sequence
    For i = 0 To 7 Step 2                             ; Part 1 sequence
      part.s = PeekS(@EAN8.s + i, 1, #PB_Unicode)
      For a = 0 To 9
        If part.s = Str(a)
          EAN8_Sequence.s + EAN8_Sequence_part1(a)
        EndIf
      Next a
    Next i
    EAN8_Sequence.s + EAN8_Center.s                   ; Center sequence
    For i = 0 To 7 Step 2                             ; Part 2 sequence
      part.s = PeekS(@EAN8.s + i + 8, 1, #PB_Unicode)
      For a = 0 To 9
        If part.s = Str(a)
          EAN8_Sequence.s + EAN8_Sequence_part2(a)
        EndIf
      Next a
    Next i
    EAN8_Sequence.s + EAN8_Stop.s                    ; Stop sequence
    
    ; Check whether 67 characters/lines were generated
    If Len(EAN8_Sequence.s) <> 67
      ProcedureReturn "14"
    EndIf
    ProcedureReturn EAN8_Sequence.s
  EndProcedure
  
  Procedure.s Generate_EAN13_Sequence(EAN13.s)
    Protected.b i, a, b
    Protected.s part, digit1, digit1_sequence
    Protected Row
    Protected Dim EAN13_digit1.s(9)
    EAN13_digit1(0) = "000000"
    EAN13_digit1(1) = "001011"
    EAN13_digit1(2) = "001101"
    EAN13_digit1(3) = "001110"
    EAN13_digit1(4) = "010011"
    EAN13_digit1(5) = "011001"
    EAN13_digit1(6) = "011100"
    EAN13_digit1(7) = "010101"
    EAN13_digit1(8) = "010110"
    EAN13_digit1(9) = "011010"
    digit1.s = Left(EAN13.s,1)
    digit1_sequence.s = EAN13_digit1(Val(digit1.s))
    ; Will contain the entire EAN13 sequence
    Protected EAN13_Sequence.s  
    ; EAN13 start, center and stop sequences
    Protected EAN13_Start.s   = "101"
    Protected EAN13_Center.s  = "01010" 
    Protected EAN13_Stop.s    = "101"   
    ; EAN13 sequenzes part #1
    Protected Dim EAN13_Sequence_part1.s(1,9)
    EAN13_Sequence_part1(0,0) = "0001101"
    EAN13_Sequence_part1(0,1) = "0011001"
    EAN13_Sequence_part1(0,2) = "0010011"
    EAN13_Sequence_part1(0,3) = "0111101"
    EAN13_Sequence_part1(0,4) = "0100011"
    EAN13_Sequence_part1(0,5) = "0110001"
    EAN13_Sequence_part1(0,6) = "0101111"
    EAN13_Sequence_part1(0,7) = "0111011"
    EAN13_Sequence_part1(0,8) = "0110111"
    EAN13_Sequence_part1(0,9) = "0001011"
    EAN13_Sequence_part1(1,0) = "0100111"
    EAN13_Sequence_part1(1,1) = "0110011"
    EAN13_Sequence_part1(1,2) = "0011011"
    EAN13_Sequence_part1(1,3) = "0100001"
    EAN13_Sequence_part1(1,4) = "0011101"
    EAN13_Sequence_part1(1,5) = "0111001"
    EAN13_Sequence_part1(1,6) = "0000101"
    EAN13_Sequence_part1(1,7) = "0010001"
    EAN13_Sequence_part1(1,8) = "0001001"
    EAN13_Sequence_part1(1,9) = "0010111"
    ; EAN13 sequenzes part #2
    Protected Dim EAN13_Sequence_part2.s(9)
    EAN13_Sequence_part2(0) = "1110010"
    EAN13_Sequence_part2(1) = "1100110"
    EAN13_Sequence_part2(2) = "1101100"
    EAN13_Sequence_part2(3) = "1000010"
    EAN13_Sequence_part2(4) = "1011100"
    EAN13_Sequence_part2(5) = "1001110"
    EAN13_Sequence_part2(6) = "1010000"
    EAN13_Sequence_part2(7) = "1000100"
    EAN13_Sequence_part2(8) = "1001000"
    EAN13_Sequence_part2(9) = "1110100"
    
    ; The string must contain 13 digits. If no, abort
    If Len(EAN13.s) <> 13
      ProcedureReturn "12"
    EndIf
    ; Check whether really numeric
    If UCase(EAN13.s) <> LCase(EAN13.s)
      ProcedureReturn "13"
    EndIf
    
    ; Build sequence
    EAN13_Sequence.s + EAN13_Start.s                   ; Start sequence
    For i = 2 To 13 Step 2                             ; Part 1 sequence
      part.s = PeekS(@EAN13.s + i, 1, #PB_Unicode)
      Row = Val(PeekS(@digit1_sequence.s + b, 1, #PB_Unicode))
      b = b +2
      For a = 0 To 9
        If part.s = Str(a)
          EAN13_Sequence.s + EAN13_Sequence_part1(Row,a)
        EndIf
      Next a
    Next i
    EAN13_Sequence.s + EAN13_Center.s                   ; Center sequence
    For i = 0 To 11 Step 2                              ; Part 2 sequence
      part.s = PeekS(@EAN13.s + i + 14, 1, #PB_Unicode)
      For a = 0 To 9
        If part.s = Str(a)
          EAN13_Sequence.s + EAN13_Sequence_part2(a)
        EndIf
      Next a
    Next i
    EAN13_Sequence.s + EAN13_Stop.s                    ; Stop sequence
    
    ; Check whether 95 characters/lines were generated
    If Len(EAN13_Sequence.s) <> 95
      ProcedureReturn "14"
    EndIf
    ProcedureReturn EAN13_Sequence.s
  EndProcedure
  
  Procedure.s Generate_Code128_Sequence(Code128.s)
    
    Protected.i lenght
    Protected.b a, b, c, d, e, f
    Protected.s Code128_Sequence, Mode, ASCII_String, part, String, NewString
    Protected Dim CodepageA.s(106)
    Protected Dim CodepageB.s(106)
    Protected Dim CodepageC.s(106)
    Protected Dim Pattern.s(106)
    Protected NewList Parts.s()
    
    ; Check for EAN128/UCC128 (old designation) GS1-128 (current designation)
    If FindString(Code128.s, "<START A>;<FNC 1>") Or FindString(Code128.s, "<START B>;<FNC 1>") Or FindString(Code128.s, "<START C>;<FNC 1>")
      ProcedureReturn "30"
    EndIf
    
    ; Read the data section
    Restore CodeA
    For a = 0 To 106
      Read.s CodepageA(a)
    Next a
    Restore CodeB
    For a = 0 To 106
      Read.s CodepageB(a)
    Next a
    Restore CodeC
    For a = 0 To 106
      Read.s CodepageC(a)
    Next a
    Restore Pattern
    For a = 0 To 106
      Read.s Pattern(a)
    Next a
    
    ; Split the Code128
    a = 0
    Repeat
      a + 1
      part.s = StringField(Code128.s, a, ";")
      If part.s <> "" 
        AddElement(Parts())
        Parts() = part.s
      EndIf
      If FindString(Parts(), "<CODE C>")
        NewString.s = RemoveString(Parts(), "<CODE C>")
        lenght.i = StringByteLength(NewString.s, #PB_Unicode)
        If Len(NewString.s) % 2 > 0
          ProcedureReturn "29"  ; Check whether the number of digits is even
        EndIf
        Parts() = "<CODE C>"
        For e = 1 To lenght.i Step 4
          String.s = PeekS(@NewString + f, 2, #PB_Unicode)
          AddElement(Parts())
          Parts() = String.s
          f + 4
        Next e
      EndIf
    Until part.s = ""
    
    ; Check for stop code
    If FindString(Code128.s, "<STOP>") = #False
      ProcedureReturn "27"
    EndIf
    ; Check for check digit
    If FindString(Code128.s, "<P>") = #False
      ProcedureReturn "28"
    EndIf
    ; Determine start code page
    ForEach Parts()
      If FindString(Parts(), "<START A>")
        Mode.s = "A"
      ElseIf FindString(Parts(), "<START B>")
        Mode.s = "B"
      ElseIf FindString(Parts(), "<START C>")
        Mode.s = "C"
      ElseIf Mode = ""
        ProcedureReturn "26" ; No start code
      EndIf
      ; Check whether code page changes
      If FindString(Parts(), "<CODE A>")
        Mode.s = "A"
        Parts() = ReplaceString(Parts(), "<CODE A>", Chr(133))
      ElseIf FindString(Parts(), "<CODE B>")
        Mode.s = "B"
        Parts() = ReplaceString(Parts(), "<CODE B>", Chr(132))
      ElseIf FindString(Parts(), "<CODE C>")
        Mode.s = "C"
        Parts() = ReplaceString(Parts(), "<CODE C>", Chr(131))
        
      ElseIf FindString(Parts(), "<P>")
        Mode.s = "C"
        Parts() = RemoveString(Parts(), "<P>")
      EndIf
      ; Control codes to ASCII
      Select Mode.s
        Case "A"
          For a = 64 To 106
            Parts() = ReplaceString(Parts(), CodepageA(a), Chr(a + 32))
          Next a
        Case "B"
          For a = 95 To 106
            Parts() = ReplaceString(Parts(), CodepageB(a), Chr(a + 32))
          Next a
        Case "C"
          For a = 0 To 106
            Parts() = ReplaceString(Parts(), CodepageC(a), Chr(a + 32))
          Next a
      EndSelect
      ; Build ASCII string
      ASCII_String.s + Parts()
    Next
    ; Build sequence
    For a = 0 To (Len(ASCII_String.s) -1) * 2 Step 2
      part.s = PeekS(@ASCII_String.s + a, 1, #PB_Unicode)
      c = Asc(part.s)-32
      If c = 106
        Code128_Sequence.s + "1100011101011"  ; Stop sequence
        ProcedureReturn Code128_Sequence.s
      EndIf
      For d = 1 To 6
        String.s = StringField(Pattern(c), d, " ")
        For b = 1 To Val(String.s)
          If d % 2 <> 0
            Code128_Sequence.s + "1"
          Else
            Code128_Sequence.s + "0"
          EndIf       
        Next b
      Next d          
    Next a
    
    
    ProcedureReturn
    
    DataSection
      
      CodeA:
      Data.s Chr(32),Chr(33),Chr(34),Chr(35),Chr(36),Chr(37),Chr(38),Chr(39),Chr(40),Chr(41),Chr(42),Chr(43),Chr(44),Chr(45),Chr(46),Chr(47),Chr(48),Chr(49),Chr(50),Chr(51),
             Chr(52),Chr(53),Chr(54),Chr(55),Chr(56),Chr(57),Chr(58),Chr(59),Chr(60),Chr(61),Chr(62),Chr(63),Chr(64),Chr(65),Chr(66),Chr(67),Chr(68),Chr(69),Chr(70),Chr(71),
             Chr(72),Chr(73),Chr(74),Chr(75),Chr(76),Chr(77),Chr(78),Chr(79),Chr(80),Chr(81),Chr(82),Chr(83),Chr(84),Chr(85),Chr(86),Chr(87),Chr(88),Chr(89),Chr(90),Chr(91),
             Chr(92),Chr(93),Chr(94),Chr(95),"<NUL>","<SOH>","<STX>","<ETX>","<EOT>","<ENQ>","<ACK>","<BEL>","<BS>","<HT>","<LF>","<VT>","<FF>","<CR>","<SO>","<SI>","<DLE>",
             "<DC1>","<DC2>","<DC3>","<DC4>","<NAK>","<SYN>","<ETB>","<CAN>","<EM>","<SUB>","<ESC>","<FS>","<GS>","<RS>","<US>","<FNC 3>","<FNC 2>","<SHIFT>","<CODE C>",
             "<CODE B>","<FNC 4>","<FNC 1>","<START A>","<START B>","<START C>","<STOP>"
      CodeB:
      Data.s Chr(32),Chr(33),Chr(34),Chr(35),Chr(36),Chr(37),Chr(38),Chr(39),Chr(40),Chr(41),Chr(42),Chr(43),Chr(44),Chr(45),Chr(46),Chr(47),Chr(48),Chr(49),Chr(50),Chr(51),
             Chr(52),Chr(53),Chr(54),Chr(55),Chr(56),Chr(57),Chr(58),Chr(59),Chr(60),Chr(61),Chr(62),Chr(63),Chr(64),Chr(65),Chr(66),Chr(67),Chr(68),Chr(69),Chr(70),Chr(71),
             Chr(72),Chr(73),Chr(74),Chr(75),Chr(76),Chr(77),Chr(78),Chr(79),Chr(80),Chr(81),Chr(82),Chr(83),Chr(84),Chr(85),Chr(86),Chr(87),Chr(88),Chr(89),Chr(90),Chr(91),
             Chr(92),Chr(93),Chr(94),Chr(95),Chr(96),Chr(97),Chr(98),Chr(99),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),
             Chr(110),Chr(111),Chr(112),Chr(113),Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(119),Chr(120),Chr(121),Chr(122),Chr(123),Chr(124),Chr(125),Chr(126),
             "<DEL>","<FNC 3>","<FNC 2>","<SHIFT>","<CODE C>","<FNC 4>","<CODE A>","<FNC 1>","<START A>","<START B>","<START C>","<STOP>"
      
      CodeC:
      Data.s "00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21",
             "22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43",
             "44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65",
             "66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83",
             "84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","<CODE B>","<CODE A>","<FNC 1>","<START A>",
             "<START B>","<START C>","<STOP>"
      
      Pattern:
      Data.s "2 1 2 2 2 2","2 2 2 1 2 2","2 2 2 2 2 1","1 2 1 2 2 3","1 2 1 3 2 2","1 3 1 2 2 2","1 2 2 2 1 3","1 2 2 3 1 2","1 3 2 2 1 2","2 2 1 2 1 3","2 2 1 3 1 2",
             "2 3 1 2 1 2","1 1 2 2 3 2","1 2 2 1 3 2","1 2 2 2 3 1","1 1 3 2 2 2","1 2 3 1 2 2","1 2 3 2 2 1","2 2 3 2 1 1","2 2 1 1 3 2","2 2 1 2 3 1","2 1 3 2 1 2",
             "2 2 3 1 1 2","3 1 2 1 3 1","3 1 1 2 2 2","3 2 1 1 2 2","3 2 1 2 2 1","3 1 2 2 1 2","3 2 2 1 1 2","3 2 2 2 1 1","2 1 2 1 2 3","2 1 2 3 2 1","2 3 2 1 2 1",
             "1 1 1 3 2 3","1 3 1 1 2 3","1 3 1 3 2 1","1 1 2 3 1 3","1 3 2 1 1 3","1 3 2 3 1 1","2 1 1 3 1 3","2 3 1 1 1 3","2 3 1 3 1 1","1 1 2 1 3 3","1 1 2 3 3 1",
             "1 3 2 1 3 1","1 1 3 1 2 3","1 1 3 3 2 1","1 3 3 1 2 1","3 1 3 1 2 1","2 1 1 3 3 1","2 3 1 1 3 1","2 1 3 1 1 3","2 1 3 3 1 1","2 1 3 1 3 1","3 1 1 1 2 3",
             "3 1 1 3 2 1","3 3 1 1 2 1","3 1 2 1 1 3","3 1 2 3 1 1","3 3 2 1 1 1","3 1 4 1 1 1","2 2 1 4 1 1","4 3 1 1 1 1","1 1 1 2 2 4","1 1 1 4 2 2","1 2 1 1 2 4",
             "1 2 1 4 2 1","1 4 1 1 2 2","1 4 1 2 2 1","1 1 2 2 1 4","1 1 2 4 1 2","1 2 2 1 1 4","1 2 2 4 1 1","1 4 2 1 1 2","1 4 2 2 1 1","2 4 1 2 1 1","2 2 1 1 1 4",
             "4 1 3 1 1 1","2 4 1 1 1 2","1 3 4 1 1 1","1 1 1 2 4 2","1 2 1 1 4 2","1 2 1 2 4 1","1 1 4 2 1 2","1 2 4 1 1 2","1 2 4 2 1 1","4 1 1 2 1 2","4 2 1 1 1 2",
             "4 2 1 2 1 1","2 1 2 1 4 1","2 1 4 1 2 1","4 1 2 1 2 1","1 1 1 1 4 3","1 1 1 3 4 1","1 3 1 1 4 1","1 1 4 1 1 3","1 1 4 3 1 1","4 1 1 1 1 3","4 1 1 3 1 1",
             "1 1 3 1 4 1","1 1 4 1 3 1","3 1 1 1 4 1","4 1 1 1 3 1","2 1 1 4 1 2","2 1 1 2 1 4","2 1 1 2 3 2","2 3 3 1 1 1 2"     
    EndDataSection
    
  EndProcedure
  
  Procedure.s Barcode_SVG_Export(*SVG_Export.SVG_Parameter)
    
    
    Protected.s SVG, SVG_Line, SVG_End, SVG_Comment, SVG_Text.s
    
    ; Basic data of the SVG XML
    SVG.s = ~"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + #CRLF$
    SVG.s + ~"<svg xmlns=\"http://www.w3.org/2000/svg\"" + #CRLF$
    SVG.s + ~"version=\"1.1\" baseProfile=\"full\"" + #CRLF$
    SVG.s + ~"width=\"<width>mm\" height=\"<height>mm\" >" + #CRLF$
    SVG_Comment.s = "<!-- <Type> <Text> -->" + #CRLF$
    SVG_Line.s = ~"<line x1=\"<x1>mm\" y1=\"<y1>mm\" x2=\"<x2>mm\" y2=\"<y2>mm\" stroke=\"rgb(<color>)\" stroke-width=\"<Line_Thickness>mm\"/>" + #CRLF$
    SVG_Text.s = ~"<text font-family=\"'OCR',ocrB\" font-size=\"<FontSize>mm\" x=\"<PosX>mm\" y=\"<PosY>mm\" text-anchor=\"middle\">BarcodeText</text>" + #CRLF$
    SVG_End.s = "</svg>"
    
    
    ; ********************************************************************** Export Code128 ******************************************************************
    
    If *SVG_Export\Type = #BCODE_Type_Code128
      Protected.s Code128_Sequence, String.s
      Protected.i Code128_Lines, Code128_max_FontSize, Code128_FontSize, Code128_FontID, Code128_Font, Code128_Image, Code128_VectorID, Lines, a
      Protected.d Code128_Line_Thickness, Code128_Text_width, Code128_Text_height, Offset
      
      ; Insert Code128 width into XML
      SVG.s = ReplaceString(SVG.s, "<width>", Str(*SVG_Export\Width))
      
      ; Insert Code128 height into XML
      SVG.s = ReplaceString(SVG.s, "<height>", Str(*SVG_Export\Height))
      
      ; Build and insert a comment into XML, which contains the type and text of the barcode
      SVG_Comment.s = ReplaceString(SVG_Comment.s, "<Type> <Text>", *SVG_Export\Type + " " + *SVG_Export\Text)
      SVG.s + SVG_Comment.s
      
      Code128_Sequence.s = *SVG_Export\Sequence
      ; Determine from the barcode the count/thickness of the lines...
      Code128_Lines.i = Len(*SVG_Export\Sequence)
      Code128_Line_Thickness.d = *SVG_Export\Width / Code128_Lines.i
      
      ; Finding a suitable font size and loading a font
      If *SVG_Export\Font <> ""
        If *SVG_Export\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
          ProcedureReturn "2"
        EndIf
        Code128_Image.i = CreateImage(#PB_Any, 100, 100)
        Code128_VectorID.i = ImageVectorOutput(Code128_Image, #PB_Unit_Millimeter)
        StartVectorDrawing(Code128_VectorID.i)
        Code128_max_FontSize.i = 60
        For Code128_FontSize.i = Code128_max_FontSize.i To 1 Step -1
          Code128_Font.i = LoadFont(#PB_Any, *SVG_Export\Font, Code128_FontSize.i)
          If Code128_Font.i = 0
            ProcedureReturn "3"
          EndIf
          Code128_FontID.i = FontID(Code128_Font.i)
          VectorFont(Code128_FontID.i)
          Code128_Text_width.d = VectorTextWidth(*SVG_Export\Text)
          Code128_Text_height.d = VectorTextHeight(*SVG_Export\Text)
          If Code128_Text_width.d <= (*SVG_Export\Width * #Code128_SVG_Correction ) /100
            If Code128_Text_height.d >= *SVG_Export\Height
              ProcedureReturn "1"   ; The barcode text is higher/larger than the barcode
            EndIf
            Break
          EndIf
          FreeFont(Code128_Font.i)
        Next
        FreeFont(Code128_Font.i)
        FreeImage(Code128_Image.i)
        StopVectorDrawing()
      EndIf
      Offset.d = Code128_Line_Thickness.d / 2
      ; "Draw" lines
      For a = 0 To Code128_Lines *2 Step 2
        If PeekS(@Code128_Sequence.s + a, 1, #PB_Unicode) = "1"
          String.s = SVG_Line.s
          String.s = ReplaceString(String.s, "<x1>", StrD(Offset.d))
          String.s = ReplaceString(String.s, "<y1>", "0")
          If *SVG_Export\Font <> ""
            String.s = ReplaceString(String.s, "<x2>", StrD(Offset.d))
            String.s = ReplaceString(String.s, "<y2>", StrD(*SVG_Export\Height - Code128_Text_height.d))
          Else
            String.s = ReplaceString(String.s, "<x2>", StrD(Offset.d))
            String.s = ReplaceString(String.s, "<y2>", StrD(*SVG_Export\Height))
          EndIf
          String.s = ReplaceString(String.s, "<color>", *SVG_Export\Color1)
          String.s = ReplaceString(String.s, "<Line_Thickness>", StrD(Code128_Line_Thickness.d))
          Offset.d + Code128_Line_Thickness.d
          SVG.s + String.s
        EndIf
        If PeekS(@Code128_Sequence.s + a, 1, #PB_Unicode) = "0"
          String.s = SVG_Line.s
          String.s = ReplaceString(String.s, "<x1>", StrD(Offset.d))
          String.s = ReplaceString(String.s, "<y1>", "0")
          If *SVG_Export\Font <> ""
            String.s = ReplaceString(String.s, "<x2>", StrD(Offset.d))
            String.s = ReplaceString(String.s, "<y2>", StrD(*SVG_Export\Height - Code128_Text_height.d))
          Else
            String.s = ReplaceString(String.s, "<x2>", StrD(Offset.d))
            String.s = ReplaceString(String.s, "<y2>", StrD(*SVG_Export\Height))
          EndIf            
          String.s = ReplaceString(String.s, "<color>", *SVG_Export\Color0)
          String.s = ReplaceString(String.s, "<Line_Thickness>", StrD(Code128_Line_Thickness.d))
          Offset.d + Code128_Line_Thickness.d
          SVG.s + String.s
        EndIf
      Next a
      ; "Draw" barcode text
      If *SVG_Export\Font <> ""
        SVG_Text.s = ReplaceString(SVG_Text.s, "<FontSize>", Str(Code128_Text_height))
        SVG_Text.s = ReplaceString(SVG_Text.s, "<PosX>", StrD(*SVG_Export\Width / 2))
        SVG_Text.s = ReplaceString(SVG_Text.s, "<PosY>", StrD(*SVG_Export\Height))
        SVG_Text.s = ReplaceString(SVG_Text.s, "BarcodeText", *SVG_Export\Text)
        SVG.s + SVG_Text.s
      EndIf  
      SVG.s + SVG_End.s
    EndIf
    ProcedureReturn SVG.s
    
    
  EndProcedure
  
  Procedure Print_Barcode(List Barcode.Barcode_Parameter(), *Printer.Print_Parameter, List Text.Text_Line())  
    
    ; Will be used for EAN8
    Protected.i EAN8_Lines, EAN8_Font.i, EAN8_FontID, EAN8_max_FontSize, EAN8_FontSize
    Protected.d EAN8_Line_Thickness, EAN8_part_width, EAN8_Text_width_p1, EAN8_Text_height, EAN8_Line_Adaptation
    Protected.s EAN8_Text, EAN8_Text_part1, EAN8_Text_part2, EAN8_Sequence.s
    ; Generally used
    Protected.d Offset
    Protected.i a, Init_Printer, VektorID, pages
    ; Will be used for freely definable texts
    Protected.i Text_Font.i, Text_FontID.i
    Protected.d Text_width.d, Text_height.d
    ; Will be used for EAN13
    Protected.i EAN13_Lines, EAN13_Font.i, EAN13_FontID, EAN13_max_FontSize, EAN13_FontSize
    Protected.d EAN13_Line_Thickness, EAN13_part_width, EAN13_Text_width_p1, EAN13_Text_height, EAN13_Line_Adaptation, EAN13_Text_width_p2
    Protected.s EAN13_Text, EAN13_Text_part1, EAN13_Text_part2, EAN13_Sequence.s
    ; Will be used for Code128
    Protected.s Code128_Sequence
    Protected.i Code128_Lines, Code128_max_FontSize, Code128_FontSize, Code128_Font, Code128_FontID
    Protected.d Code128_Line_Thickness, Code128_Text_width.d, Code128_Text_height.d
    
    ; Initialize printer and start printing
    If *Printer\Print_Requester = #False
      Init_Printer.i = DefaultPrinter()
    Else
      Init_Printer.i = PrintRequester()
    EndIf
    If Init_Printer = 0
      ProcedureReturn 15
    EndIf   
    Init_Printer.i = StartPrinting(*Printer\Doc_Name)
    If Init_Printer.i = 0
      ProcedureReturn 15
    EndIf
    VektorID = PrinterVectorOutput(#PB_Unit_Millimeter)
    StartVectorDrawing(VektorID)
    
    For pages.i = 1 To *Printer\Pages
      ForEach Barcode()
        ; ********************************************************************************************************************
        ; Draw barcode and barcode text                                                                                      *
        ; ********************************************************************************************************************
        
        ; Print Code128
        If Barcode()\Type = "Code128"
          Code128_Sequence.s = Barcode()\Sequence
          ; Determine from the barcode the count/thickness of the lines...
          Code128_Lines.i = Len(Barcode()\Sequence)
          Code128_Line_Thickness.d = Barcode()\Width / Code128_Lines.i
          
          ; Check whether Code128 is within the printing range
          If Barcode()\PosX < *Printer\Left_edge
            ProcedureReturn 38
          ElseIf Barcode()\PosX + Barcode()\Width > *Printer\Page_width - *Printer\Right_edge
            ProcedureReturn 39
          ElseIf Barcode()\PosY < *Printer\Top_edge
            ProcedureReturn 40
          ElseIf Barcode()\PosY + Barcode()\Height > *Printer\Page_height - *Printer\Bottom_edge
            ProcedureReturn 41
          EndIf
          
          ; Finding a suitable font size and loading a font
          If Barcode()\Font <> ""
            If Barcode()\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
              ProcedureReturn 35
            EndIf
            Code128_max_FontSize.i = 60
            For Code128_FontSize.i = Code128_max_FontSize.i To 1 Step -1
              Code128_Font.i = LoadFont(#PB_Any, Barcode()\Font, Code128_FontSize.i)
              If Code128_Font.i = 0
                ProcedureReturn 36
              EndIf
              Code128_FontID.i = FontID(Code128_Font.i)
              VectorFont(Code128_FontID)
              Code128_Text_width.d = VectorTextWidth(Barcode()\Text)
              Code128_Text_height.d = VectorTextHeight(Barcode()\Text)
              If Code128_Text_width.d <= (Barcode()\Width *70) /100
                If Code128_Text_height.d >= Barcode()\Height
                  ProcedureReturn 37   ; The barcode text is higher than the barcode (Barcode()\Height)
                EndIf
                Break
              EndIf
              FreeFont(Code128_Font.i)
            Next              
          EndIf
          Offset.d = 0
          ; Draw lines
          For a = 0 To Code128_Lines *2 Step 2
            If PeekS(@Code128_Sequence.s + a, 1, #PB_Unicode) = "1"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - Code128_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
              StrokePath(Code128_Line_Thickness.d)
              Offset.d + Code128_Line_Thickness.d
            EndIf
            If PeekS(@Code128_Sequence.s + a, 1, #PB_Unicode) = "0"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - Code128_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf            
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
              StrokePath(Code128_Line_Thickness.d)
              Offset.d + Code128_Line_Thickness.d
            EndIf
          Next a
          ; Draw barcode text
          If Barcode()\Font <> ""
            MovePathCursor((Barcode()\Width - Code128_Text_width.d) / 2 + Barcode()\PosX , Barcode()\PosY + Barcode()\Height - Code128_Text_height.d + 0.8)
            VectorSourceColor(RGBA(Val(StringField(Barcode()\ColorDigits_RGB, 1, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 2, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 3, ",")), 255))
            DrawVectorText(Barcode()\Text)
          EndIf
        EndIf
        
        
        ; Print EAN8
        If Barcode()\Type = "EAN8"
          EAN8_Text.s = Barcode()\Text
          ; Determine from the barcode the count/thickness of the lines
          EAN8_Lines.i = Len(Barcode()\Sequence)
          EAN8_Line_Thickness.d = Barcode()\Width / EAN8_Lines.i
          EAN8_part_width.d = 4 * 7 * EAN8_Line_Thickness ; 4 digits * 7 lines * line thickness
          
          ; EAN8 Part 1 / 2  Generate text
          For a = 0 To 7 Step 2
            EAN8_Text_part1.s + PeekS(@EAN8_Text + a, 1, #PB_Unicode)
          Next a
          For a = 8 To 15 Step 2
            EAN8_Text_part2.s + PeekS(@EAN8_Text + a, 1, #PB_Unicode)
          Next a
          
          ; Finding a suitable font size and loading a font
          If Barcode()\Font <> ""
            If Barcode()\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
              ProcedureReturn 26
            EndIf
            EAN8_max_FontSize.i = 60
            For EAN8_FontSize.i = EAN8_max_FontSize.i To 1 Step -1
              EAN8_Font.i = LoadFont(#PB_Any, Barcode()\Font, EAN8_FontSize.i)
              If EAN8_Font.i = 0
                ProcedureReturn 16
              EndIf
              EAN8_FontID.i = FontID(EAN8_Font.i)
              VectorFont(EAN8_FontID)
              EAN8_Text_width_p1.d = VectorTextWidth(EAN8_Text_part1.s)
              EAN8_Text_height.d = VectorTextHeight(EAN8_Text.s)
              If EAN8_Text_width_p1.d <= EAN8_part_width.d
                If EAN8_Text_height.d >= Barcode()\Height
                  ProcedureReturn 27   ; The barcode text is higher than the barcode (Barcode()\Height)
                EndIf
                Break
              EndIf
              FreeFont(EAN8_Font.i)
            Next              
          EndIf
          
          
          ; EAN8 Draw lines
          EAN8_Sequence.s = Barcode()\Sequence
          Offset.d = 0
          EAN8_Line_Adaptation.d = 0
          If Barcode()\Font <> ""
            EAN8_Line_Adaptation.d = EAN8_Text_height.d / 1.5
          EndIf
          ; Check whether the EAN8 is within the printing range
          If Barcode()\PosX < *Printer\Left_edge
            ProcedureReturn 22
          ElseIf Barcode()\PosX + Barcode()\Width > *Printer\Page_width - *Printer\Right_edge
            ProcedureReturn 23
          ElseIf Barcode()\PosY < *Printer\Top_edge
            ProcedureReturn 24
          ElseIf Barcode()\PosY + Barcode()\Height > *Printer\Page_height - *Printer\Bottom_edge
            ProcedureReturn 25
          EndIf
          ; Start sequence 3 lines 101
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          ; Digits Part 1
          For a = 6 To 61 Step 2
            If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "1"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
              StrokePath(EAN8_Line_Thickness.d)
              Offset.d + EAN8_Line_Thickness.d
            EndIf
            If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "0"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf            
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
              StrokePath(EAN8_Line_Thickness.d)
              Offset.d + EAN8_Line_Thickness.d
            EndIf
          Next a
          ; Center Sequence 01010
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          ; Digits Part 2
          For a = 72 To 127 Step 2
            If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "1"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
              StrokePath(EAN8_Line_Thickness.d)
              Offset.d + EAN8_Line_Thickness.d
            EndIf
            If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "0"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf            
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
              StrokePath(EAN8_Line_Thickness.d)
              Offset.d + EAN8_Line_Thickness.d
            EndIf
          Next a
          ; Stop Sequence 3 Lines 101
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN8_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d         
          ; Text Part 1 / 2 Draw
          If Barcode()\Font <> ""
            MovePathCursor(Barcode()\PosX + (3 * EAN8_Line_Thickness.d) + ((EAN8_part_width.d - EAN8_Text_width_p1)/2), Barcode()\PosY + Barcode()\Height - EAN8_Text_height.d + 0.8)
            VectorSourceColor(RGBA(Val(StringField(Barcode()\ColorDigits_RGB, 1, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 2, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 3, ",")), 255))
            DrawVectorText(EAN8_Text_part1.s)
            
            MovePathCursor(Barcode()\PosX + (36 * EAN8_Line_Thickness.d) + ((EAN8_part_width.d - EAN8_Text_width_p1)/2), Barcode()\PosY + Barcode()\Height - EAN8_Text_height.d + 0.8)
            VectorSourceColor(RGBA(Val(StringField(Barcode()\ColorDigits_RGB, 1, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 2, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 3, ",")), 255))
            DrawVectorText(EAN8_Text_part2.s)
          EndIf
          EAN8_Text.s =""
          EAN8_Text_width_p1.d = 0
          EAN8_Text_height.d = 0 
          EAN8_Text_part1.s = ""
          EAN8_Text_part2.s =""
          FreeFont(EAN8_Font.i)
          Offset.d = 0
        EndIf
        
        
        ; ********************************************************************* Print EAN13 ***************************************************************
        If Barcode()\Type = "EAN13"
          EAN13_Text.s = Barcode()\Text
          ; Determine from the barcode the count/thickness of the lines
          EAN13_Lines.i = Len(Barcode()\Sequence)
          EAN13_Line_Thickness.d = Barcode()\Width / EAN13_Lines.i
          EAN13_part_width.d = 6 * 7 * EAN13_Line_Thickness ; 7 digits * 7 lines * lines thickness
          
          ; EAN13 Part 1 / 2  Generate text
          For a = 0 To 13 Step 2
            EAN13_Text_part1.s + PeekS(@EAN13_Text + a, 1, #PB_Unicode)
          Next a
          For a = 14 To 25 Step 2
            EAN13_Text_part2.s + PeekS(@EAN13_Text + a, 1, #PB_Unicode)
          Next a
          ; Finding a suitable font size and loading a font
          If Barcode()\Font <> ""
            If Barcode()\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
              ProcedureReturn 28
            EndIf
            EAN13_max_FontSize.i = 60
            For EAN13_FontSize.i = EAN13_max_FontSize.i To 1 Step -1
              EAN13_Font.i = LoadFont(#PB_Any, Barcode()\Font, EAN13_FontSize.i)
              If EAN13_Font.i = 0
                ProcedureReturn 29
              EndIf
              EAN13_FontID.i = FontID(EAN13_Font.i)
              VectorFont(EAN13_FontID)
              EAN13_Text_width_p1.d = VectorTextWidth(EAN13_Text_part1.s)
              EAN13_Text_width_p2.d = VectorTextWidth(EAN13_Text_part2.s)
              EAN13_Text_height.d = VectorTextHeight(EAN13_Text.s)
              If EAN13_Text_width_p1.d <= EAN13_part_width.d
                If EAN13_Text_height.d >= Barcode()\Height
                  ProcedureReturn 30   ; The barcode text is higher than the barcode (Barcode()\Height)
                EndIf
                Break
              EndIf
              FreeFont(EAN13_Font.i)
            Next              
          EndIf
          
          ; EAN13 Draw lines
          EAN13_Sequence.s = Barcode()\Sequence
          Offset.d = 0
          EAN13_Line_Adaptation.d = 0
          If Barcode()\Font <> ""
            EAN13_Line_Adaptation.d = EAN13_Text_height.d / 1.5
          EndIf
          ; Check whether the EAN13 is within the printing range
          If Barcode()\PosX < *Printer\Left_edge
            ProcedureReturn 31
          ElseIf Barcode()\PosX + Barcode()\Width > *Printer\Page_width - *Printer\Right_edge
            ProcedureReturn 32
          ElseIf Barcode()\PosY < *Printer\Top_edge
            ProcedureReturn 33
          ElseIf Barcode()\PosY + Barcode()\Height > *Printer\Page_height - *Printer\Bottom_edge
            ProcedureReturn 34
          EndIf
          ; Start Sequence 3 Lines 101
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          
          ; Digits Part 1
          ; The first digit is handled separately and is not printed!
          For a = 6  To 89 Step 2
            If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "1"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
              StrokePath(EAN13_Line_Thickness.d)
              Offset.d + EAN13_Line_Thickness.d
            EndIf
            If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "0"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf            
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
              StrokePath(EAN13_Line_Thickness.d)
              Offset.d + EAN13_Line_Thickness.d
            EndIf
          Next a
          ; Center Sequenz 01010
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          ; Digits Part 2
          For a = 100 To 183 Step 2
            If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "1"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
              StrokePath(EAN13_Line_Thickness.d)
              Offset.d + EAN13_Line_Thickness.d
            EndIf
            If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "0"
              MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
              If Barcode()\Font <> ""
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Text_height.d)
              Else
                AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height)
              EndIf            
              VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
              StrokePath(EAN13_Line_Thickness.d)
              Offset.d + EAN13_Line_Thickness.d
            EndIf
          Next a
          ; Stop Sequence 3 Lines 101
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color0_RGB, 1, ",")), Val(StringField(Barcode()\Color0_RGB, 2, ",")), Val(StringField(Barcode()\Color0_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
          MovePathCursor(Barcode()\PosX + Offset, Barcode()\PosY)
          AddPathLine(Barcode()\PosX + Offset, Barcode()\PosY + Barcode()\Height - EAN13_Line_Adaptation.d)
          VectorSourceColor(RGBA(Val(StringField(Barcode()\Color1_RGB, 1, ",")), Val(StringField(Barcode()\Color1_RGB, 2, ",")), Val(StringField(Barcode()\Color1_RGB, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d         
          ; Text Part 1 / 2 Draw
          If Barcode()\Font <> ""
            MovePathCursor(Barcode()\PosX + (3 * EAN13_Line_Thickness.d) + ((EAN13_part_width.d - EAN13_Text_width_p1)/2), Barcode()\PosY + Barcode()\Height - EAN13_Text_height.d + 0.8)
            VectorSourceColor(RGBA(Val(StringField(Barcode()\ColorDigits_RGB, 1, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 2, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 3, ",")), 255))
            DrawVectorText(EAN13_Text_part1.s)
            
            MovePathCursor(Barcode()\PosX + (50 * EAN13_Line_Thickness.d) + ((EAN13_part_width.d - EAN13_Text_width_p2)/2), Barcode()\PosY + Barcode()\Height - EAN13_Text_height.d + 0.8)
            VectorSourceColor(RGBA(Val(StringField(Barcode()\ColorDigits_RGB, 1, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 2, ",")), Val(StringField(Barcode()\ColorDigits_RGB, 3, ",")), 255))
            DrawVectorText(EAN13_Text_part2.s)
          EndIf
          EAN13_Text.s =""
          EAN13_Text_width_p1.d = 0
          EAN13_Text_height.d = 0
          EAN13_Text_part1.s = ""
          EAN13_Text_part2.s = ""
          FreeFont(EAN13_Font.i)
        EndIf
      Next
      ; ********************************************************************************************************************
      ; End of barcode printing                                                                                            *
      ; ********************************************************************************************************************
      
      ; ********************************************************************************************************************
      ; Print texts                                                                                                        *
      ; ********************************************************************************************************************
      ForEach Text()
        ; Load character set for Text_Line and draw text
        If Text()\Font <> ""
          Text_Font.i = LoadFont(#PB_Any, Text()\Font, Text()\Font_Size, Text()\Text_Style)
          If Text_Font.i = 0
            ProcedureReturn 17
          EndIf
          Text_FontID.i = FontID(Text_Font.i)
        EndIf
        VectorFont(Text_FontID.i)
        Text_width.d = VectorTextWidth(Text()\Text)
        Text_height.d = VectorTextHeight(Text()\Text)     
        MovePathCursor(Text()\Text_PosX , Text()\Text_PosY) 
        VectorSourceColor(RGBA(Val(StringField(Text()\TextColor_RGB, 1, ",")), Val(StringField(Text()\TextColor_RGB, 2, ",")), Val(StringField(Text()\TextColor_RGB, 3, ",")), 255))
        DrawVectorText(Text()\Text)
        FreeFont(Text_Font.i)
        ; Check whether the text is within the printing range
        If Text()\Text_PosX < *Printer\Left_edge
          ProcedureReturn 18
        ElseIf Text()\Text_PosX + Text_width.d > *Printer\Page_width - *Printer\Right_edge
          ProcedureReturn 19
        ElseIf Text()\Text_PosY < *Printer\Top_edge
          ProcedureReturn 20
        ElseIf Text()\Text_PosY + Text_height.d > *Printer\Page_height - *Printer\Bottom_edge
          ProcedureReturn 21
        EndIf
      Next
      ; ********************************************************************************************************************
      ; End of text printing                                                                                               *
      ; ********************************************************************************************************************
      
      If pages.i < *Printer\Pages
        NewPrinterPage()
      EndIf      
    Next pages.i
    StopVectorDrawing()
    StopPrinting()
    ProcedureReturn #True
  EndProcedure
  
  Procedure Barcode_Image_Export(*Image_Export.Image_Parameter)
    ; Will be used for EAN8
    Protected.i EAN8_Lines, EAN8_Font.i, EAN8_FontID, EAN8_max_FontSize, EAN8_FontSize
    Protected.d EAN8_Line_Thickness, EAN8_part_width, EAN8_Text_width_p1, EAN8_Text_height, EAN8_Line_Adaptation
    Protected.s EAN8_Text, EAN8_Text_part1, EAN8_Text_part2, EAN8_Sequence.s
    ; Generally used
    Protected.d Offset
    Protected.i a, VektorID
    ; Will be used for EAN13
    Protected.i EAN13_Lines, EAN13_Font.i, EAN13_FontID, EAN13_max_FontSize, EAN13_FontSize
    Protected.d EAN13_Line_Thickness, EAN13_part_width, EAN13_Text_width_p1, EAN13_Text_height, EAN13_Line_Adaptation, EAN13_Text_width_p2
    Protected.s EAN13_Text, EAN13_Text_part1, EAN13_Text_part2, EAN13_Sequence.s
    ; Will be used for Code128
    Protected.s Code128_Sequence
    Protected.i Code128_Lines, Code128_max_FontSize, Code128_FontSize, Code128_Font, Code128_FontID
    Protected.d Code128_Line_Thickness, Code128_Text_width.d, Code128_Text_height.d
    
    
    VektorID = ImageVectorOutput(*Image_Export\Image_Number, #PB_Unit_Millimeter)
    If VektorID = 0
      ProcedureReturn 15
    EndIf
    StartVectorDrawing(VektorID)
    
    ; ********************************************************************************************************************
    ; Draw barcode and barcode text                                                                                      *
    ; ********************************************************************************************************************
    
    ; ****************************************************************** Draw Code128 ***********************************************************
    If *Image_Export\Type = "Code128"
      Code128_Sequence.s = *Image_Export\Sequence
      ; Determine from the barcode the count/thickness of the lines
      Code128_Lines.i = Len(*Image_Export\Sequence)
      Code128_Line_Thickness.d = *Image_Export\Width / Code128_Lines.i
      
      ; Finding a suitable font size and loading a font
      If *Image_Export\Font <> ""
        If *Image_Export\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
          ProcedureReturn 35
        EndIf
        Code128_max_FontSize.i = 60
        For Code128_FontSize.i = Code128_max_FontSize.i To 1 Step -1
          Code128_Font.i = LoadFont(#PB_Any, *Image_Export\Font, Code128_FontSize.i)
          If Code128_Font.i = 0
            ProcedureReturn 36
          EndIf
          Code128_FontID.i = FontID(Code128_Font.i)
          VectorFont(Code128_FontID)
          Code128_Text_width.d = VectorTextWidth(*Image_Export\Text)
          Code128_Text_height.d = VectorTextHeight(*Image_Export\Text)
          If Code128_Text_width.d <= (*Image_Export\Width *70) /100
            If Code128_Text_height.d >= *Image_Export\Height
              ProcedureReturn 37   ; The barcode text is higher than the barcode (Barcode()\Height)
            EndIf
            Break
          EndIf
          FreeFont(Code128_Font.i)
        Next              
      EndIf
      Offset.d = 0
      ; Draw lines
      For a = 0 To Code128_Lines *2 Step 2
        If PeekS(@Code128_Sequence.s + a, 1, #PB_Unicode) = "1"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - Code128_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
          StrokePath(Code128_Line_Thickness.d)
          Offset.d + Code128_Line_Thickness.d
        EndIf
        If PeekS(@Code128_Sequence.s + a, 1, #PB_Unicode) = "0"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - Code128_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf            
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
          StrokePath(Code128_Line_Thickness.d)
          Offset.d + Code128_Line_Thickness.d
        EndIf
      Next a
      ; Draw barcode text
      If *Image_Export\Font <> ""
        MovePathCursor((*Image_Export\Width - Code128_Text_width.d) / 2, 0 + *Image_Export\Height - Code128_Text_height.d + 0.8)
        VectorSourceColor(RGBA(Val(StringField(*Image_Export\ColorDigits, 1, ",")), Val(StringField(*Image_Export\ColorDigits, 2, ",")), Val(StringField(*Image_Export\ColorDigits, 3, ",")), 255))
        DrawVectorText(*Image_Export\Text)
      EndIf
    EndIf
    
    ; ********************************************************** Draw EAN8 *************************************************
    If *Image_Export\Type = "EAN8"
      EAN8_Text.s = *Image_Export\Text
      ; Determine from the barcode the count/thickness of the lines
      EAN8_Lines.i = Len(*Image_Export\Sequence)
      EAN8_Line_Thickness.d = *Image_Export\Width / EAN8_Lines.i
      EAN8_part_width.d = 4 * 7 * EAN8_Line_Thickness ; 4 digits * 7 lines * lines thickness
      
      ; EAN8 Part 1 / 2  Generate text
      For a = 0 To 7 Step 2
        EAN8_Text_part1.s + PeekS(@EAN8_Text + a, 1, #PB_Unicode)
      Next a
      For a = 8 To 15 Step 2
        EAN8_Text_part2.s + PeekS(@EAN8_Text + a, 1, #PB_Unicode)
      Next a
      
      ; Finding a suitable font size and loading a font
      If *Image_Export\Font <> ""
        If *Image_Export\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
          ProcedureReturn 26
        EndIf
        EAN8_max_FontSize.i = 60
        For EAN8_FontSize.i = EAN8_max_FontSize.i To 1 Step -1
          EAN8_Font.i = LoadFont(#PB_Any, *Image_Export\Font, EAN8_FontSize.i)
          If EAN8_Font.i = 0
            ProcedureReturn 16
          EndIf
          EAN8_FontID.i = FontID(EAN8_Font.i)
          VectorFont(EAN8_FontID)
          EAN8_Text_width_p1.d = VectorTextWidth(EAN8_Text_part1.s)
          EAN8_Text_height.d = VectorTextHeight(EAN8_Text.s)
          If EAN8_Text_width_p1.d <= EAN8_part_width.d
            If EAN8_Text_height.d >= *Image_Export\Height
              ProcedureReturn 27   ; The barcode text is higher than the barcode (*Image_Export\Height)
            EndIf
            Break
          EndIf
          FreeFont(EAN8_Font.i)
        Next              
      EndIf
      
      
      ; EAN8 Draw lines
      EAN8_Sequence.s = *Image_Export\Sequence
      Offset.d = 0
      EAN8_Line_Adaptation.d = 0
      If *Image_Export\Font <> ""
        EAN8_Line_Adaptation.d = EAN8_Text_height.d / 1.5
      EndIf
      
      ; Start Sequence 3 Lines 101
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      ; Digits Part 1
      For a = 6 To 61 Step 2
        If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "1"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN8_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
        EndIf
        If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "0"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN8_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf            
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
        EndIf
      Next a
      ; Center Sequenz 01010
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      ; Digits Part 2
      For a = 72 To 127 Step 2
        If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "1"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN8_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
        EndIf
        If PeekS(@EAN8_Sequence.s + a, 1, #PB_Unicode) = "0"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN8_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf            
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
          StrokePath(EAN8_Line_Thickness.d)
          Offset.d + EAN8_Line_Thickness.d
        EndIf
      Next a
      ; Stop Sequence 3 Lines 101
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN8_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN8_Line_Thickness.d)
      Offset.d + EAN8_Line_Thickness.d         
      ; Text Part 1 / 2 Draw
      If *Image_Export\Font <> ""
        MovePathCursor((3 * EAN8_Line_Thickness.d) + ((EAN8_part_width.d - EAN8_Text_width_p1)/2), *Image_Export\Height - EAN8_Text_height.d + 0.8)
        VectorSourceColor(RGBA(Val(StringField(*Image_Export\ColorDigits, 1, ",")), Val(StringField(*Image_Export\ColorDigits, 2, ",")), Val(StringField(*Image_Export\ColorDigits, 3, ",")), 255))
        DrawVectorText(EAN8_Text_part1.s)
        
        MovePathCursor((36 * EAN8_Line_Thickness.d) + ((EAN8_part_width.d - EAN8_Text_width_p1)/2), *Image_Export\Height - EAN8_Text_height.d + 0.8)
        VectorSourceColor(RGBA(Val(StringField(*Image_Export\ColorDigits, 1, ",")), Val(StringField(*Image_Export\ColorDigits, 2, ",")), Val(StringField(*Image_Export\ColorDigits, 3, ",")), 255))
        DrawVectorText(EAN8_Text_part2.s)
      EndIf
      FreeFont(EAN8_Font.i)
    EndIf
    
    
    
    ; ********************************************************** Draw EAN13 *************************************************
    
    If *Image_Export\Type = "EAN13"
      EAN13_Text.s = *Image_Export\Text
      ; Determine from the barcode the count/thickness of the lines
      EAN13_Lines.i = Len(*Image_Export\Sequence)
      EAN13_Line_Thickness.d = *Image_Export\Width / EAN13_Lines.i
      EAN13_part_width.d = 6 * 7 * EAN13_Line_Thickness ; 7 digits * 7 lines * lines thickness
      
      ; EAN13 Part 1 / 2  Generate text
      For a = 0 To 13 Step 2
        EAN13_Text_part1.s + PeekS(@EAN13_Text + a, 1, #PB_Unicode)
      Next a
      For a = 14 To 25 Step 2
        EAN13_Text_part2.s + PeekS(@EAN13_Text + a, 1, #PB_Unicode)
      Next a
      ; Finding a suitable font size and loading a font
      If *Image_Export\Font <> ""
        If *Image_Export\Font <> "ocrB" ; ********************************* The spelling may have to be changed! **************************************************
          ProcedureReturn 28
        EndIf
        EAN13_max_FontSize.i = 60
        For EAN13_FontSize.i = EAN13_max_FontSize.i To 1 Step -1
          EAN13_Font.i = LoadFont(#PB_Any, *Image_Export\Font, EAN13_FontSize.i)
          If EAN13_Font.i = 0
            ProcedureReturn 29
          EndIf
          EAN13_FontID.i = FontID(EAN13_Font.i)
          VectorFont(EAN13_FontID)
          EAN13_Text_width_p1.d = VectorTextWidth(EAN13_Text_part1.s)
          EAN13_Text_width_p2.d = VectorTextWidth(EAN13_Text_part2.s)
          EAN13_Text_height.d = VectorTextHeight(EAN13_Text.s)
          If EAN13_Text_width_p1.d <= EAN13_part_width.d
            If EAN13_Text_height.d >= *Image_Export\Height
              ProcedureReturn 30   ; The barcode text is higher than the barcode (*Image_Export\Height)
            EndIf
            Break
          EndIf
          FreeFont(EAN13_Font.i)
        Next              
      EndIf
      
      
      ; EAN13 Draw lines
      EAN13_Sequence.s = *Image_Export\Sequence
      Offset.d = 0
      EAN13_Line_Adaptation.d = 0
      If *Image_Export\Font <> ""
        EAN13_Line_Adaptation.d = EAN13_Text_height.d / 1.5
      EndIf
      
      ; Start Sequence 3 Lines 101
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      ; Digits Part 1
      For a = 6  To 89 Step 2
        If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "1"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN13_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
        EndIf
        If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "0"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN13_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf            
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
        EndIf
      Next a
      ; Center Sequenz 01010
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      ; Digits Part 2
      For a = 100 To 183 Step 2
        If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "1"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN13_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
        EndIf
        If PeekS(@EAN13_Sequence.s + a, 1, #PB_Unicode) = "0"
          MovePathCursor(Offset, 0)
          If *Image_Export\Font <> ""
            AddPathLine(Offset, *Image_Export\Height - EAN13_Text_height.d)
          Else
            AddPathLine(Offset, *Image_Export\Height)
          EndIf            
          VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
          StrokePath(EAN13_Line_Thickness.d)
          Offset.d + EAN13_Line_Thickness.d
        EndIf
      Next a
      ; Stop Sequence 3 Lines 101
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color0, 1, ",")), Val(StringField(*Image_Export\Color0, 2, ",")), Val(StringField(*Image_Export\Color0, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d
      MovePathCursor(Offset, 0)
      AddPathLine(Offset, *Image_Export\Height - EAN13_Line_Adaptation.d)
      VectorSourceColor(RGBA(Val(StringField(*Image_Export\Color1, 1, ",")), Val(StringField(*Image_Export\Color1, 2, ",")), Val(StringField(*Image_Export\Color1, 3, ",")), 255))
      StrokePath(EAN13_Line_Thickness.d)
      Offset.d + EAN13_Line_Thickness.d         
      ; Text Part 1 / 2 Draw
      If*Image_Export\Font <> ""
        MovePathCursor((3 * EAN13_Line_Thickness.d) + ((EAN13_part_width.d - EAN13_Text_width_p1)/2), *Image_Export\Height - EAN13_Text_height.d + 0.8)
        VectorSourceColor(RGBA(Val(StringField(*Image_Export\ColorDigits, 1, ",")), Val(StringField(*Image_Export\ColorDigits, 2, ",")), Val(StringField(*Image_Export\ColorDigits, 3, ",")), 255))
        DrawVectorText(EAN13_Text_part1.s)
        
        MovePathCursor((50 * EAN13_Line_Thickness.d) + ((EAN13_part_width.d - EAN13_Text_width_p2)/2), *Image_Export\Height - EAN13_Text_height.d + 0.8)
        VectorSourceColor(RGBA(Val(StringField(*Image_Export\ColorDigits, 1, ",")), Val(StringField(*Image_Export\ColorDigits, 2, ",")), Val(StringField(*Image_Export\ColorDigits, 3, ",")), 255))
        DrawVectorText(EAN13_Text_part2.s)
      EndIf
      FreeFont(EAN13_Font.i)
    EndIf
    StopVectorDrawing()
    ProcedureReturn 1
  EndProcedure
  
EndModule
