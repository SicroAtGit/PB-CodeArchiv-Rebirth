;   Description: Adds support for upper and lower case-mapping for unicode
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=68536
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 mk-soft
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

;-Top

; Unicode LCaseW and UCaseW function by mk-soft
; From 27.05.2017, Update 03.06.2017
; Version v1.05

DeclareModule CaseUnicode
 
  Declare.s UCaseW(String.s)
  Declare.s LCaseW(String.s)
  Declare.s ULCaseW(String.s)
  Declare FindStringW(String.s, StringToFind.s, StartPosition=1, Mode=#PB_String_NoCase)
 
EndDeclareModule

Module CaseUnicode
 
  EnableExplicit
 
  Global Dim ArrayLCase.c($FFFF)
  Global Dim ArrayUCase.c($FFFF)
 
  Structure udtArrayChar
    c.c[0]
  EndStructure
 
  ; ---------------------------------------------------------------------------
 
  Procedure Init()
    Protected index, uchar.c, lchar.c
   
    For index = 0 To $FFFF
      ArrayLCase(index) = index
      ArrayUCase(index) = index
    Next
   
    Restore CaseFolding
    Repeat
      Read.c uchar
      Read.c lchar
      If Not uchar
        Break
      EndIf
      ArrayLCase(uchar) = lchar
      ArrayUCase(lchar) = uchar
    ForEver
  EndProcedure : Init()
 
  ; ---------------------------------------------------------------------------
 
  Procedure.s UCaseW(String.s)
    Protected result.s, len, index, cnt, *source.udtArrayChar, *dest.udtArrayChar
    len = Len(String)
    result = Space(len)
    *source = @String
    *dest = @result
    cnt = len - 1
    For index = 0 To cnt
      *dest\c[index] = ArrayUCase(*source\c[index])
    Next
    ProcedureReturn result
  EndProcedure
   
  ; ---------------------------------------------------------------------------
 
  Procedure.s LCaseW(String.s)
    Protected result.s, len, index, cnt, *source.udtArrayChar, *dest.udtArrayChar
    len = Len(String)
    result = Space(len)
    *source = @String
    *dest = @result
    cnt = len - 1
    For index = 0 To cnt
      *dest\c[index] = ArrayLCase(*source\c[index])
    Next
    ProcedureReturn result
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  Procedure.s ULCaseW(String.s)
    Protected result.s, len, index, cnt, up, *source.udtArrayChar, *dest.udtArrayChar
    len = Len(String)
    result = Space(len)
    up = #True
    *source = @String
    *dest = @result
    cnt = len - 1
    For index = 0 To cnt
      Select *source\c[index]
        Case ' ', '.', #CR, #LF, #TAB, '!', '?', ',', ';'
          up = #True
          *dest\c[index] = *source\c[index]
        Default
          If up
            *dest\c[index] = ArrayUCase(*source\c[index])
            up = #False
          Else
            *dest\c[index] = ArrayLCase(*source\c[index])
          EndIf
      EndSelect           
    Next
    ProcedureReturn result
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  Procedure FindStringW(String.s, StringToFind.s, StartPosition=1, Mode=#PB_String_NoCase)
    Protected r1, StringW.s, StringToFindW.s
    If Mode = #PB_String_NoCase
      StringW = LCaseW(String)
      StringToFindW = LCaseW(StringToFind)
      r1 = FindString(StringW, StringToFindW, StartPosition, #PB_String_CaseSensitive)
    Else
      r1 = FindString(String, StringToFind, StartPosition, #PB_String_CaseSensitive)
    EndIf 
    ProcedureReturn r1
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  DataSection
    CaseFolding:
    Data.c $0041, $0061
    Data.c $0042, $0062
    Data.c $0043, $0063
    Data.c $0044, $0064
    Data.c $0045, $0065
    Data.c $0046, $0066
    Data.c $0047, $0067
    Data.c $0048, $0068
    Data.c $0049, $0069
    Data.c $004A, $006A
    Data.c $004B, $006B
    Data.c $004C, $006C
    Data.c $004D, $006D
    Data.c $004E, $006E
    Data.c $004F, $006F
    Data.c $0050, $0070
    Data.c $0051, $0071
    Data.c $0052, $0072
    Data.c $0053, $0073
    Data.c $0054, $0074
    Data.c $0055, $0075
    Data.c $0056, $0076
    Data.c $0057, $0077
    Data.c $0058, $0078
    Data.c $0059, $0079
    Data.c $005A, $007A
    Data.c $00B5, $03BC
    Data.c $00C0, $00E0
    Data.c $00C1, $00E1
    Data.c $00C2, $00E2
    Data.c $00C3, $00E3
    Data.c $00C4, $00E4
    Data.c $00C5, $00E5
    Data.c $00C6, $00E6
    Data.c $00C7, $00E7
    Data.c $00C8, $00E8
    Data.c $00C9, $00E9
    Data.c $00CA, $00EA
    Data.c $00CB, $00EB
    Data.c $00CC, $00EC
    Data.c $00CD, $00ED
    Data.c $00CE, $00EE
    Data.c $00CF, $00EF
    Data.c $00D0, $00F0
    Data.c $00D1, $00F1
    Data.c $00D2, $00F2
    Data.c $00D3, $00F3
    Data.c $00D4, $00F4
    Data.c $00D5, $00F5
    Data.c $00D6, $00F6
    Data.c $00D8, $00F8
    Data.c $00D9, $00F9
    Data.c $00DA, $00FA
    Data.c $00DB, $00FB
    Data.c $00DC, $00FC
    Data.c $00DD, $00FD
    Data.c $00DE, $00FE
    Data.c $0100, $0101
    Data.c $0102, $0103
    Data.c $0104, $0105
    Data.c $0106, $0107
    Data.c $0108, $0109
    Data.c $010A, $010B
    Data.c $010C, $010D
    Data.c $010E, $010F
    Data.c $0110, $0111
    Data.c $0112, $0113
    Data.c $0114, $0115
    Data.c $0116, $0117
    Data.c $0118, $0119
    Data.c $011A, $011B
    Data.c $011C, $011D
    Data.c $011E, $011F
    Data.c $0120, $0121
    Data.c $0122, $0123
    Data.c $0124, $0125
    Data.c $0126, $0127
    Data.c $0128, $0129
    Data.c $012A, $012B
    Data.c $012C, $012D
    Data.c $012E, $012F
    Data.c $0132, $0133
    Data.c $0134, $0135
    Data.c $0136, $0137
    Data.c $0139, $013A
    Data.c $013B, $013C
    Data.c $013D, $013E
    Data.c $013F, $0140
    Data.c $0141, $0142
    Data.c $0143, $0144
    Data.c $0145, $0146
    Data.c $0147, $0148
    Data.c $014A, $014B
    Data.c $014C, $014D
    Data.c $014E, $014F
    Data.c $0150, $0151
    Data.c $0152, $0153
    Data.c $0154, $0155
    Data.c $0156, $0157
    Data.c $0158, $0159
    Data.c $015A, $015B
    Data.c $015C, $015D
    Data.c $015E, $015F
    Data.c $0160, $0161
    Data.c $0162, $0163
    Data.c $0164, $0165
    Data.c $0166, $0167
    Data.c $0168, $0169
    Data.c $016A, $016B
    Data.c $016C, $016D
    Data.c $016E, $016F
    Data.c $0170, $0171
    Data.c $0172, $0173
    Data.c $0174, $0175
    Data.c $0176, $0177
    Data.c $0178, $00FF
    Data.c $0179, $017A
    Data.c $017B, $017C
    Data.c $017D, $017E
    Data.c $017F, $0073
    Data.c $0181, $0253
    Data.c $0182, $0183
    Data.c $0184, $0185
    Data.c $0186, $0254
    Data.c $0187, $0188
    Data.c $0189, $0256
    Data.c $018A, $0257
    Data.c $018B, $018C
    Data.c $018E, $01DD
    Data.c $018F, $0259
    Data.c $0190, $025B
    Data.c $0191, $0192
    Data.c $0193, $0260
    Data.c $0194, $0263
    Data.c $0196, $0269
    Data.c $0197, $0268
    Data.c $0198, $0199
    Data.c $019C, $026F
    Data.c $019D, $0272
    Data.c $019F, $0275
    Data.c $01A0, $01A1
    Data.c $01A2, $01A3
    Data.c $01A4, $01A5
    Data.c $01A6, $0280
    Data.c $01A7, $01A8
    Data.c $01A9, $0283
    Data.c $01AC, $01AD
    Data.c $01AE, $0288
    Data.c $01AF, $01B0
    Data.c $01B1, $028A
    Data.c $01B2, $028B
    Data.c $01B3, $01B4
    Data.c $01B5, $01B6
    Data.c $01B7, $0292
    Data.c $01B8, $01B9
    Data.c $01BC, $01BD
    Data.c $01C4, $01C6
    Data.c $01C5, $01C6
    Data.c $01C7, $01C9
    Data.c $01C8, $01C9
    Data.c $01CA, $01CC
    Data.c $01CB, $01CC
    Data.c $01CD, $01CE
    Data.c $01CF, $01D0
    Data.c $01D1, $01D2
    Data.c $01D3, $01D4
    Data.c $01D5, $01D6
    Data.c $01D7, $01D8
    Data.c $01D9, $01DA
    Data.c $01DB, $01DC
    Data.c $01DE, $01DF
    Data.c $01E0, $01E1
    Data.c $01E2, $01E3
    Data.c $01E4, $01E5
    Data.c $01E6, $01E7
    Data.c $01E8, $01E9
    Data.c $01EA, $01EB
    Data.c $01EC, $01ED
    Data.c $01EE, $01EF
    Data.c $01F1, $01F3
    Data.c $01F2, $01F3
    Data.c $01F4, $01F5
    Data.c $01F6, $0195
    Data.c $01F7, $01BF
    Data.c $01F8, $01F9
    Data.c $01FA, $01FB
    Data.c $01FC, $01FD
    Data.c $01FE, $01FF
    Data.c $0200, $0201
    Data.c $0202, $0203
    Data.c $0204, $0205
    Data.c $0206, $0207
    Data.c $0208, $0209
    Data.c $020A, $020B
    Data.c $020C, $020D
    Data.c $020E, $020F
    Data.c $0210, $0211
    Data.c $0212, $0213
    Data.c $0214, $0215
    Data.c $0216, $0217
    Data.c $0218, $0219
    Data.c $021A, $021B
    Data.c $021C, $021D
    Data.c $021E, $021F
    Data.c $0220, $019E
    Data.c $0222, $0223
    Data.c $0224, $0225
    Data.c $0226, $0227
    Data.c $0228, $0229
    Data.c $022A, $022B
    Data.c $022C, $022D
    Data.c $022E, $022F
    Data.c $0230, $0231
    Data.c $0232, $0233
    Data.c $023A, $2C65
    Data.c $023B, $023C
    Data.c $023D, $019A
    Data.c $023E, $2C66
    Data.c $0241, $0242
    Data.c $0243, $0180
    Data.c $0244, $0289
    Data.c $0245, $028C
    Data.c $0246, $0247
    Data.c $0248, $0249
    Data.c $024A, $024B
    Data.c $024C, $024D
    Data.c $024E, $024F
    Data.c $0345, $03B9
    Data.c $0370, $0371
    Data.c $0372, $0373
    Data.c $0376, $0377
    Data.c $037F, $03F3
    Data.c $0386, $03AC
    Data.c $0388, $03AD
    Data.c $0389, $03AE
    Data.c $038A, $03AF
    Data.c $038C, $03CC
    Data.c $038E, $03CD
    Data.c $038F, $03CE
    Data.c $0391, $03B1
    Data.c $0392, $03B2
    Data.c $0393, $03B3
    Data.c $0394, $03B4
    Data.c $0395, $03B5
    Data.c $0396, $03B6
    Data.c $0397, $03B7
    Data.c $0398, $03B8
    Data.c $0399, $03B9
    Data.c $039A, $03BA
    Data.c $039B, $03BB
    Data.c $039C, $03BC
    Data.c $039D, $03BD
    Data.c $039E, $03BE
    Data.c $039F, $03BF
    Data.c $03A0, $03C0
    Data.c $03A1, $03C1
    Data.c $03A3, $03C3
    Data.c $03A4, $03C4
    Data.c $03A5, $03C5
    Data.c $03A6, $03C6
    Data.c $03A7, $03C7
    Data.c $03A8, $03C8
    Data.c $03A9, $03C9
    Data.c $03AA, $03CA
    Data.c $03AB, $03CB
    Data.c $03C2, $03C3
    Data.c $03CF, $03D7
    Data.c $03D0, $03B2
    Data.c $03D1, $03B8
    Data.c $03D5, $03C6
    Data.c $03D6, $03C0
    Data.c $03D8, $03D9
    Data.c $03DA, $03DB
    Data.c $03DC, $03DD
    Data.c $03DE, $03DF
    Data.c $03E0, $03E1
    Data.c $03E2, $03E3
    Data.c $03E4, $03E5
    Data.c $03E6, $03E7
    Data.c $03E8, $03E9
    Data.c $03EA, $03EB
    Data.c $03EC, $03ED
    Data.c $03EE, $03EF
    Data.c $03F0, $03BA
    Data.c $03F1, $03C1
    Data.c $03F4, $03B8
    Data.c $03F5, $03B5
    Data.c $03F7, $03F8
    Data.c $03F9, $03F2
    Data.c $03FA, $03FB
    Data.c $03FD, $037B
    Data.c $03FE, $037C
    Data.c $03FF, $037D
    Data.c $0400, $0450
    Data.c $0401, $0451
    Data.c $0402, $0452
    Data.c $0403, $0453
    Data.c $0404, $0454
    Data.c $0405, $0455
    Data.c $0406, $0456
    Data.c $0407, $0457
    Data.c $0408, $0458
    Data.c $0409, $0459
    Data.c $040A, $045A
    Data.c $040B, $045B
    Data.c $040C, $045C
    Data.c $040D, $045D
    Data.c $040E, $045E
    Data.c $040F, $045F
    Data.c $0410, $0430
    Data.c $0411, $0431
    Data.c $0412, $0432
    Data.c $0413, $0433
    Data.c $0414, $0434
    Data.c $0415, $0435
    Data.c $0416, $0436
    Data.c $0417, $0437
    Data.c $0418, $0438
    Data.c $0419, $0439
    Data.c $041A, $043A
    Data.c $041B, $043B
    Data.c $041C, $043C
    Data.c $041D, $043D
    Data.c $041E, $043E
    Data.c $041F, $043F
    Data.c $0420, $0440
    Data.c $0421, $0441
    Data.c $0422, $0442
    Data.c $0423, $0443
    Data.c $0424, $0444
    Data.c $0425, $0445
    Data.c $0426, $0446
    Data.c $0427, $0447
    Data.c $0428, $0448
    Data.c $0429, $0449
    Data.c $042A, $044A
    Data.c $042B, $044B
    Data.c $042C, $044C
    Data.c $042D, $044D
    Data.c $042E, $044E
    Data.c $042F, $044F
    Data.c $0460, $0461
    Data.c $0462, $0463
    Data.c $0464, $0465
    Data.c $0466, $0467
    Data.c $0468, $0469
    Data.c $046A, $046B
    Data.c $046C, $046D
    Data.c $046E, $046F
    Data.c $0470, $0471
    Data.c $0472, $0473
    Data.c $0474, $0475
    Data.c $0476, $0477
    Data.c $0478, $0479
    Data.c $047A, $047B
    Data.c $047C, $047D
    Data.c $047E, $047F
    Data.c $0480, $0481
    Data.c $048A, $048B
    Data.c $048C, $048D
    Data.c $048E, $048F
    Data.c $0490, $0491
    Data.c $0492, $0493
    Data.c $0494, $0495
    Data.c $0496, $0497
    Data.c $0498, $0499
    Data.c $049A, $049B
    Data.c $049C, $049D
    Data.c $049E, $049F
    Data.c $04A0, $04A1
    Data.c $04A2, $04A3
    Data.c $04A4, $04A5
    Data.c $04A6, $04A7
    Data.c $04A8, $04A9
    Data.c $04AA, $04AB
    Data.c $04AC, $04AD
    Data.c $04AE, $04AF
    Data.c $04B0, $04B1
    Data.c $04B2, $04B3
    Data.c $04B4, $04B5
    Data.c $04B6, $04B7
    Data.c $04B8, $04B9
    Data.c $04BA, $04BB
    Data.c $04BC, $04BD
    Data.c $04BE, $04BF
    Data.c $04C0, $04CF
    Data.c $04C1, $04C2
    Data.c $04C3, $04C4
    Data.c $04C5, $04C6
    Data.c $04C7, $04C8
    Data.c $04C9, $04CA
    Data.c $04CB, $04CC
    Data.c $04CD, $04CE
    Data.c $04D0, $04D1
    Data.c $04D2, $04D3
    Data.c $04D4, $04D5
    Data.c $04D6, $04D7
    Data.c $04D8, $04D9
    Data.c $04DA, $04DB
    Data.c $04DC, $04DD
    Data.c $04DE, $04DF
    Data.c $04E0, $04E1
    Data.c $04E2, $04E3
    Data.c $04E4, $04E5
    Data.c $04E6, $04E7
    Data.c $04E8, $04E9
    Data.c $04EA, $04EB
    Data.c $04EC, $04ED
    Data.c $04EE, $04EF
    Data.c $04F0, $04F1
    Data.c $04F2, $04F3
    Data.c $04F4, $04F5
    Data.c $04F6, $04F7
    Data.c $04F8, $04F9
    Data.c $04FA, $04FB
    Data.c $04FC, $04FD
    Data.c $04FE, $04FF
    Data.c $0500, $0501
    Data.c $0502, $0503
    Data.c $0504, $0505
    Data.c $0506, $0507
    Data.c $0508, $0509
    Data.c $050A, $050B
    Data.c $050C, $050D
    Data.c $050E, $050F
    Data.c $0510, $0511
    Data.c $0512, $0513
    Data.c $0514, $0515
    Data.c $0516, $0517
    Data.c $0518, $0519
    Data.c $051A, $051B
    Data.c $051C, $051D
    Data.c $051E, $051F
    Data.c $0520, $0521
    Data.c $0522, $0523
    Data.c $0524, $0525
    Data.c $0526, $0527
    Data.c $0528, $0529
    Data.c $052A, $052B
    Data.c $052C, $052D
    Data.c $052E, $052F
    Data.c $0531, $0561
    Data.c $0532, $0562
    Data.c $0533, $0563
    Data.c $0534, $0564
    Data.c $0535, $0565
    Data.c $0536, $0566
    Data.c $0537, $0567
    Data.c $0538, $0568
    Data.c $0539, $0569
    Data.c $053A, $056A
    Data.c $053B, $056B
    Data.c $053C, $056C
    Data.c $053D, $056D
    Data.c $053E, $056E
    Data.c $053F, $056F
    Data.c $0540, $0570
    Data.c $0541, $0571
    Data.c $0542, $0572
    Data.c $0543, $0573
    Data.c $0544, $0574
    Data.c $0545, $0575
    Data.c $0546, $0576
    Data.c $0547, $0577
    Data.c $0548, $0578
    Data.c $0549, $0579
    Data.c $054A, $057A
    Data.c $054B, $057B
    Data.c $054C, $057C
    Data.c $054D, $057D
    Data.c $054E, $057E
    Data.c $054F, $057F
    Data.c $0550, $0580
    Data.c $0551, $0581
    Data.c $0552, $0582
    Data.c $0553, $0583
    Data.c $0554, $0584
    Data.c $0555, $0585
    Data.c $0556, $0586
    Data.c $10A0, $2D00
    Data.c $10A1, $2D01
    Data.c $10A2, $2D02
    Data.c $10A3, $2D03
    Data.c $10A4, $2D04
    Data.c $10A5, $2D05
    Data.c $10A6, $2D06
    Data.c $10A7, $2D07
    Data.c $10A8, $2D08
    Data.c $10A9, $2D09
    Data.c $10AA, $2D0A
    Data.c $10AB, $2D0B
    Data.c $10AC, $2D0C
    Data.c $10AD, $2D0D
    Data.c $10AE, $2D0E
    Data.c $10AF, $2D0F
    Data.c $10B0, $2D10
    Data.c $10B1, $2D11
    Data.c $10B2, $2D12
    Data.c $10B3, $2D13
    Data.c $10B4, $2D14
    Data.c $10B5, $2D15
    Data.c $10B6, $2D16
    Data.c $10B7, $2D17
    Data.c $10B8, $2D18
    Data.c $10B9, $2D19
    Data.c $10BA, $2D1A
    Data.c $10BB, $2D1B
    Data.c $10BC, $2D1C
    Data.c $10BD, $2D1D
    Data.c $10BE, $2D1E
    Data.c $10BF, $2D1F
    Data.c $10C0, $2D20
    Data.c $10C1, $2D21
    Data.c $10C2, $2D22
    Data.c $10C3, $2D23
    Data.c $10C4, $2D24
    Data.c $10C5, $2D25
    Data.c $10C7, $2D27
    Data.c $10CD, $2D2D
    Data.c $13F8, $13F0
    Data.c $13F9, $13F1
    Data.c $13FA, $13F2
    Data.c $13FB, $13F3
    Data.c $13FC, $13F4
    Data.c $13FD, $13F5
    Data.c $1C80, $0432
    Data.c $1C81, $0434
    Data.c $1C82, $043E
    Data.c $1C83, $0441
    Data.c $1C84, $0442
    Data.c $1C85, $0442
    Data.c $1C86, $044A
    Data.c $1C87, $0463
    Data.c $1C88, $A64B
    Data.c $1E00, $1E01
    Data.c $1E02, $1E03
    Data.c $1E04, $1E05
    Data.c $1E06, $1E07
    Data.c $1E08, $1E09
    Data.c $1E0A, $1E0B
    Data.c $1E0C, $1E0D
    Data.c $1E0E, $1E0F
    Data.c $1E10, $1E11
    Data.c $1E12, $1E13
    Data.c $1E14, $1E15
    Data.c $1E16, $1E17
    Data.c $1E18, $1E19
    Data.c $1E1A, $1E1B
    Data.c $1E1C, $1E1D
    Data.c $1E1E, $1E1F
    Data.c $1E20, $1E21
    Data.c $1E22, $1E23
    Data.c $1E24, $1E25
    Data.c $1E26, $1E27
    Data.c $1E28, $1E29
    Data.c $1E2A, $1E2B
    Data.c $1E2C, $1E2D
    Data.c $1E2E, $1E2F
    Data.c $1E30, $1E31
    Data.c $1E32, $1E33
    Data.c $1E34, $1E35
    Data.c $1E36, $1E37
    Data.c $1E38, $1E39
    Data.c $1E3A, $1E3B
    Data.c $1E3C, $1E3D
    Data.c $1E3E, $1E3F
    Data.c $1E40, $1E41
    Data.c $1E42, $1E43
    Data.c $1E44, $1E45
    Data.c $1E46, $1E47
    Data.c $1E48, $1E49
    Data.c $1E4A, $1E4B
    Data.c $1E4C, $1E4D
    Data.c $1E4E, $1E4F
    Data.c $1E50, $1E51
    Data.c $1E52, $1E53
    Data.c $1E54, $1E55
    Data.c $1E56, $1E57
    Data.c $1E58, $1E59
    Data.c $1E5A, $1E5B
    Data.c $1E5C, $1E5D
    Data.c $1E5E, $1E5F
    Data.c $1E60, $1E61
    Data.c $1E62, $1E63
    Data.c $1E64, $1E65
    Data.c $1E66, $1E67
    Data.c $1E68, $1E69
    Data.c $1E6A, $1E6B
    Data.c $1E6C, $1E6D
    Data.c $1E6E, $1E6F
    Data.c $1E70, $1E71
    Data.c $1E72, $1E73
    Data.c $1E74, $1E75
    Data.c $1E76, $1E77
    Data.c $1E78, $1E79
    Data.c $1E7A, $1E7B
    Data.c $1E7C, $1E7D
    Data.c $1E7E, $1E7F
    Data.c $1E80, $1E81
    Data.c $1E82, $1E83
    Data.c $1E84, $1E85
    Data.c $1E86, $1E87
    Data.c $1E88, $1E89
    Data.c $1E8A, $1E8B
    Data.c $1E8C, $1E8D
    Data.c $1E8E, $1E8F
    Data.c $1E90, $1E91
    Data.c $1E92, $1E93
    Data.c $1E94, $1E95
    Data.c $1E9B, $1E61
    Data.c $1E9E, $00DF
    Data.c $1EA0, $1EA1
    Data.c $1EA2, $1EA3
    Data.c $1EA4, $1EA5
    Data.c $1EA6, $1EA7
    Data.c $1EA8, $1EA9
    Data.c $1EAA, $1EAB
    Data.c $1EAC, $1EAD
    Data.c $1EAE, $1EAF
    Data.c $1EB0, $1EB1
    Data.c $1EB2, $1EB3
    Data.c $1EB4, $1EB5
    Data.c $1EB6, $1EB7
    Data.c $1EB8, $1EB9
    Data.c $1EBA, $1EBB
    Data.c $1EBC, $1EBD
    Data.c $1EBE, $1EBF
    Data.c $1EC0, $1EC1
    Data.c $1EC2, $1EC3
    Data.c $1EC4, $1EC5
    Data.c $1EC6, $1EC7
    Data.c $1EC8, $1EC9
    Data.c $1ECA, $1ECB
    Data.c $1ECC, $1ECD
    Data.c $1ECE, $1ECF
    Data.c $1ED0, $1ED1
    Data.c $1ED2, $1ED3
    Data.c $1ED4, $1ED5
    Data.c $1ED6, $1ED7
    Data.c $1ED8, $1ED9
    Data.c $1EDA, $1EDB
    Data.c $1EDC, $1EDD
    Data.c $1EDE, $1EDF
    Data.c $1EE0, $1EE1
    Data.c $1EE2, $1EE3
    Data.c $1EE4, $1EE5
    Data.c $1EE6, $1EE7
    Data.c $1EE8, $1EE9
    Data.c $1EEA, $1EEB
    Data.c $1EEC, $1EED
    Data.c $1EEE, $1EEF
    Data.c $1EF0, $1EF1
    Data.c $1EF2, $1EF3
    Data.c $1EF4, $1EF5
    Data.c $1EF6, $1EF7
    Data.c $1EF8, $1EF9
    Data.c $1EFA, $1EFB
    Data.c $1EFC, $1EFD
    Data.c $1EFE, $1EFF
    Data.c $1F08, $1F00
    Data.c $1F09, $1F01
    Data.c $1F0A, $1F02
    Data.c $1F0B, $1F03
    Data.c $1F0C, $1F04
    Data.c $1F0D, $1F05
    Data.c $1F0E, $1F06
    Data.c $1F0F, $1F07
    Data.c $1F18, $1F10
    Data.c $1F19, $1F11
    Data.c $1F1A, $1F12
    Data.c $1F1B, $1F13
    Data.c $1F1C, $1F14
    Data.c $1F1D, $1F15
    Data.c $1F28, $1F20
    Data.c $1F29, $1F21
    Data.c $1F2A, $1F22
    Data.c $1F2B, $1F23
    Data.c $1F2C, $1F24
    Data.c $1F2D, $1F25
    Data.c $1F2E, $1F26
    Data.c $1F2F, $1F27
    Data.c $1F38, $1F30
    Data.c $1F39, $1F31
    Data.c $1F3A, $1F32
    Data.c $1F3B, $1F33
    Data.c $1F3C, $1F34
    Data.c $1F3D, $1F35
    Data.c $1F3E, $1F36
    Data.c $1F3F, $1F37
    Data.c $1F48, $1F40
    Data.c $1F49, $1F41
    Data.c $1F4A, $1F42
    Data.c $1F4B, $1F43
    Data.c $1F4C, $1F44
    Data.c $1F4D, $1F45
    Data.c $1F59, $1F51
    Data.c $1F5B, $1F53
    Data.c $1F5D, $1F55
    Data.c $1F5F, $1F57
    Data.c $1F68, $1F60
    Data.c $1F69, $1F61
    Data.c $1F6A, $1F62
    Data.c $1F6B, $1F63
    Data.c $1F6C, $1F64
    Data.c $1F6D, $1F65
    Data.c $1F6E, $1F66
    Data.c $1F6F, $1F67
    Data.c $1F88, $1F80
    Data.c $1F89, $1F81
    Data.c $1F8A, $1F82
    Data.c $1F8B, $1F83
    Data.c $1F8C, $1F84
    Data.c $1F8D, $1F85
    Data.c $1F8E, $1F86
    Data.c $1F8F, $1F87
    Data.c $1F98, $1F90
    Data.c $1F99, $1F91
    Data.c $1F9A, $1F92
    Data.c $1F9B, $1F93
    Data.c $1F9C, $1F94
    Data.c $1F9D, $1F95
    Data.c $1F9E, $1F96
    Data.c $1F9F, $1F97
    Data.c $1FA8, $1FA0
    Data.c $1FA9, $1FA1
    Data.c $1FAA, $1FA2
    Data.c $1FAB, $1FA3
    Data.c $1FAC, $1FA4
    Data.c $1FAD, $1FA5
    Data.c $1FAE, $1FA6
    Data.c $1FAF, $1FA7
    Data.c $1FB8, $1FB0
    Data.c $1FB9, $1FB1
    Data.c $1FBA, $1F70
    Data.c $1FBB, $1F71
    Data.c $1FBC, $1FB3
    Data.c $1FBE, $03B9
    Data.c $1FC8, $1F72
    Data.c $1FC9, $1F73
    Data.c $1FCA, $1F74
    Data.c $1FCB, $1F75
    Data.c $1FCC, $1FC3
    Data.c $1FD8, $1FD0
    Data.c $1FD9, $1FD1
    Data.c $1FDA, $1F76
    Data.c $1FDB, $1F77
    Data.c $1FE8, $1FE0
    Data.c $1FE9, $1FE1
    Data.c $1FEA, $1F7A
    Data.c $1FEB, $1F7B
    Data.c $1FEC, $1FE5
    Data.c $1FF8, $1F78
    Data.c $1FF9, $1F79
    Data.c $1FFA, $1F7C
    Data.c $1FFB, $1F7D
    Data.c $1FFC, $1FF3
    Data.c $2126, $03C9
    Data.c $212A, $006B
    Data.c $212B, $00E5
    Data.c $2132, $214E
    Data.c $2160, $2170
    Data.c $2161, $2171
    Data.c $2162, $2172
    Data.c $2163, $2173
    Data.c $2164, $2174
    Data.c $2165, $2175
    Data.c $2166, $2176
    Data.c $2167, $2177
    Data.c $2168, $2178
    Data.c $2169, $2179
    Data.c $216A, $217A
    Data.c $216B, $217B
    Data.c $216C, $217C
    Data.c $216D, $217D
    Data.c $216E, $217E
    Data.c $216F, $217F
    Data.c $2183, $2184
    Data.c $24B6, $24D0
    Data.c $24B7, $24D1
    Data.c $24B8, $24D2
    Data.c $24B9, $24D3
    Data.c $24BA, $24D4
    Data.c $24BB, $24D5
    Data.c $24BC, $24D6
    Data.c $24BD, $24D7
    Data.c $24BE, $24D8
    Data.c $24BF, $24D9
    Data.c $24C0, $24DA
    Data.c $24C1, $24DB
    Data.c $24C2, $24DC
    Data.c $24C3, $24DD
    Data.c $24C4, $24DE
    Data.c $24C5, $24DF
    Data.c $24C6, $24E0
    Data.c $24C7, $24E1
    Data.c $24C8, $24E2
    Data.c $24C9, $24E3
    Data.c $24CA, $24E4
    Data.c $24CB, $24E5
    Data.c $24CC, $24E6
    Data.c $24CD, $24E7
    Data.c $24CE, $24E8
    Data.c $24CF, $24E9
    Data.c $2C00, $2C30
    Data.c $2C01, $2C31
    Data.c $2C02, $2C32
    Data.c $2C03, $2C33
    Data.c $2C04, $2C34
    Data.c $2C05, $2C35
    Data.c $2C06, $2C36
    Data.c $2C07, $2C37
    Data.c $2C08, $2C38
    Data.c $2C09, $2C39
    Data.c $2C0A, $2C3A
    Data.c $2C0B, $2C3B
    Data.c $2C0C, $2C3C
    Data.c $2C0D, $2C3D
    Data.c $2C0E, $2C3E
    Data.c $2C0F, $2C3F
    Data.c $2C10, $2C40
    Data.c $2C11, $2C41
    Data.c $2C12, $2C42
    Data.c $2C13, $2C43
    Data.c $2C14, $2C44
    Data.c $2C15, $2C45
    Data.c $2C16, $2C46
    Data.c $2C17, $2C47
    Data.c $2C18, $2C48
    Data.c $2C19, $2C49
    Data.c $2C1A, $2C4A
    Data.c $2C1B, $2C4B
    Data.c $2C1C, $2C4C
    Data.c $2C1D, $2C4D
    Data.c $2C1E, $2C4E
    Data.c $2C1F, $2C4F
    Data.c $2C20, $2C50
    Data.c $2C21, $2C51
    Data.c $2C22, $2C52
    Data.c $2C23, $2C53
    Data.c $2C24, $2C54
    Data.c $2C25, $2C55
    Data.c $2C26, $2C56
    Data.c $2C27, $2C57
    Data.c $2C28, $2C58
    Data.c $2C29, $2C59
    Data.c $2C2A, $2C5A
    Data.c $2C2B, $2C5B
    Data.c $2C2C, $2C5C
    Data.c $2C2D, $2C5D
    Data.c $2C2E, $2C5E
    Data.c $2C60, $2C61
    Data.c $2C62, $026B
    Data.c $2C63, $1D7D
    Data.c $2C64, $027D
    Data.c $2C67, $2C68
    Data.c $2C69, $2C6A
    Data.c $2C6B, $2C6C
    Data.c $2C6D, $0251
    Data.c $2C6E, $0271
    Data.c $2C6F, $0250
    Data.c $2C70, $0252
    Data.c $2C72, $2C73
    Data.c $2C75, $2C76
    Data.c $2C7E, $023F
    Data.c $2C7F, $0240
    Data.c $2C80, $2C81
    Data.c $2C82, $2C83
    Data.c $2C84, $2C85
    Data.c $2C86, $2C87
    Data.c $2C88, $2C89
    Data.c $2C8A, $2C8B
    Data.c $2C8C, $2C8D
    Data.c $2C8E, $2C8F
    Data.c $2C90, $2C91
    Data.c $2C92, $2C93
    Data.c $2C94, $2C95
    Data.c $2C96, $2C97
    Data.c $2C98, $2C99
    Data.c $2C9A, $2C9B
    Data.c $2C9C, $2C9D
    Data.c $2C9E, $2C9F
    Data.c $2CA0, $2CA1
    Data.c $2CA2, $2CA3
    Data.c $2CA4, $2CA5
    Data.c $2CA6, $2CA7
    Data.c $2CA8, $2CA9
    Data.c $2CAA, $2CAB
    Data.c $2CAC, $2CAD
    Data.c $2CAE, $2CAF
    Data.c $2CB0, $2CB1
    Data.c $2CB2, $2CB3
    Data.c $2CB4, $2CB5
    Data.c $2CB6, $2CB7
    Data.c $2CB8, $2CB9
    Data.c $2CBA, $2CBB
    Data.c $2CBC, $2CBD
    Data.c $2CBE, $2CBF
    Data.c $2CC0, $2CC1
    Data.c $2CC2, $2CC3
    Data.c $2CC4, $2CC5
    Data.c $2CC6, $2CC7
    Data.c $2CC8, $2CC9
    Data.c $2CCA, $2CCB
    Data.c $2CCC, $2CCD
    Data.c $2CCE, $2CCF
    Data.c $2CD0, $2CD1
    Data.c $2CD2, $2CD3
    Data.c $2CD4, $2CD5
    Data.c $2CD6, $2CD7
    Data.c $2CD8, $2CD9
    Data.c $2CDA, $2CDB
    Data.c $2CDC, $2CDD
    Data.c $2CDE, $2CDF
    Data.c $2CE0, $2CE1
    Data.c $2CE2, $2CE3
    Data.c $2CEB, $2CEC
    Data.c $2CED, $2CEE
    Data.c $2CF2, $2CF3
    Data.c $A640, $A641
    Data.c $A642, $A643
    Data.c $A644, $A645
    Data.c $A646, $A647
    Data.c $A648, $A649
    Data.c $A64A, $A64B
    Data.c $A64C, $A64D
    Data.c $A64E, $A64F
    Data.c $A650, $A651
    Data.c $A652, $A653
    Data.c $A654, $A655
    Data.c $A656, $A657
    Data.c $A658, $A659
    Data.c $A65A, $A65B
    Data.c $A65C, $A65D
    Data.c $A65E, $A65F
    Data.c $A660, $A661
    Data.c $A662, $A663
    Data.c $A664, $A665
    Data.c $A666, $A667
    Data.c $A668, $A669
    Data.c $A66A, $A66B
    Data.c $A66C, $A66D
    Data.c $A680, $A681
    Data.c $A682, $A683
    Data.c $A684, $A685
    Data.c $A686, $A687
    Data.c $A688, $A689
    Data.c $A68A, $A68B
    Data.c $A68C, $A68D
    Data.c $A68E, $A68F
    Data.c $A690, $A691
    Data.c $A692, $A693
    Data.c $A694, $A695
    Data.c $A696, $A697
    Data.c $A698, $A699
    Data.c $A69A, $A69B
    Data.c $A722, $A723
    Data.c $A724, $A725
    Data.c $A726, $A727
    Data.c $A728, $A729
    Data.c $A72A, $A72B
    Data.c $A72C, $A72D
    Data.c $A72E, $A72F
    Data.c $A732, $A733
    Data.c $A734, $A735
    Data.c $A736, $A737
    Data.c $A738, $A739
    Data.c $A73A, $A73B
    Data.c $A73C, $A73D
    Data.c $A73E, $A73F
    Data.c $A740, $A741
    Data.c $A742, $A743
    Data.c $A744, $A745
    Data.c $A746, $A747
    Data.c $A748, $A749
    Data.c $A74A, $A74B
    Data.c $A74C, $A74D
    Data.c $A74E, $A74F
    Data.c $A750, $A751
    Data.c $A752, $A753
    Data.c $A754, $A755
    Data.c $A756, $A757
    Data.c $A758, $A759
    Data.c $A75A, $A75B
    Data.c $A75C, $A75D
    Data.c $A75E, $A75F
    Data.c $A760, $A761
    Data.c $A762, $A763
    Data.c $A764, $A765
    Data.c $A766, $A767
    Data.c $A768, $A769
    Data.c $A76A, $A76B
    Data.c $A76C, $A76D
    Data.c $A76E, $A76F
    Data.c $A779, $A77A
    Data.c $A77B, $A77C
    Data.c $A77D, $1D79
    Data.c $A77E, $A77F
    Data.c $A780, $A781
    Data.c $A782, $A783
    Data.c $A784, $A785
    Data.c $A786, $A787
    Data.c $A78B, $A78C
    Data.c $A78D, $0265
    Data.c $A790, $A791
    Data.c $A792, $A793
    Data.c $A796, $A797
    Data.c $A798, $A799
    Data.c $A79A, $A79B
    Data.c $A79C, $A79D
    Data.c $A79E, $A79F
    Data.c $A7A0, $A7A1
    Data.c $A7A2, $A7A3
    Data.c $A7A4, $A7A5
    Data.c $A7A6, $A7A7
    Data.c $A7A8, $A7A9
    Data.c $A7AA, $0266
    Data.c $A7AB, $025C
    Data.c $A7AC, $0261
    Data.c $A7AD, $026C
    Data.c $A7AE, $026A
    Data.c $A7B0, $029E
    Data.c $A7B1, $0287
    Data.c $A7B2, $029D
    Data.c $A7B3, $AB53
    Data.c $A7B4, $A7B5
    Data.c $A7B6, $A7B7
    Data.c $AB70, $13A0
    Data.c $AB71, $13A1
    Data.c $AB72, $13A2
    Data.c $AB73, $13A3
    Data.c $AB74, $13A4
    Data.c $AB75, $13A5
    Data.c $AB76, $13A6
    Data.c $AB77, $13A7
    Data.c $AB78, $13A8
    Data.c $AB79, $13A9
    Data.c $AB7A, $13AA
    Data.c $AB7B, $13AB
    Data.c $AB7C, $13AC
    Data.c $AB7D, $13AD
    Data.c $AB7E, $13AE
    Data.c $AB7F, $13AF
    Data.c $AB80, $13B0
    Data.c $AB81, $13B1
    Data.c $AB82, $13B2
    Data.c $AB83, $13B3
    Data.c $AB84, $13B4
    Data.c $AB85, $13B5
    Data.c $AB86, $13B6
    Data.c $AB87, $13B7
    Data.c $AB88, $13B8
    Data.c $AB89, $13B9
    Data.c $AB8A, $13BA
    Data.c $AB8B, $13BB
    Data.c $AB8C, $13BC
    Data.c $AB8D, $13BD
    Data.c $AB8E, $13BE
    Data.c $AB8F, $13BF
    Data.c $AB90, $13C0
    Data.c $AB91, $13C1
    Data.c $AB92, $13C2
    Data.c $AB93, $13C3
    Data.c $AB94, $13C4
    Data.c $AB95, $13C5
    Data.c $AB96, $13C6
    Data.c $AB97, $13C7
    Data.c $AB98, $13C8
    Data.c $AB99, $13C9
    Data.c $AB9A, $13CA
    Data.c $AB9B, $13CB
    Data.c $AB9C, $13CC
    Data.c $AB9D, $13CD
    Data.c $AB9E, $13CE
    Data.c $AB9F, $13CF
    Data.c $ABA0, $13D0
    Data.c $ABA1, $13D1
    Data.c $ABA2, $13D2
    Data.c $ABA3, $13D3
    Data.c $ABA4, $13D4
    Data.c $ABA5, $13D5
    Data.c $ABA6, $13D6
    Data.c $ABA7, $13D7
    Data.c $ABA8, $13D8
    Data.c $ABA9, $13D9
    Data.c $ABAA, $13DA
    Data.c $ABAB, $13DB
    Data.c $ABAC, $13DC
    Data.c $ABAD, $13DD
    Data.c $ABAE, $13DE
    Data.c $ABAF, $13DF
    Data.c $ABB0, $13E0
    Data.c $ABB1, $13E1
    Data.c $ABB2, $13E2
    Data.c $ABB3, $13E3
    Data.c $ABB4, $13E4
    Data.c $ABB5, $13E5
    Data.c $ABB6, $13E6
    Data.c $ABB7, $13E7
    Data.c $ABB8, $13E8
    Data.c $ABB9, $13E9
    Data.c $ABBA, $13EA
    Data.c $ABBB, $13EB
    Data.c $ABBC, $13EC
    Data.c $ABBD, $13ED
    Data.c $ABBE, $13EE
    Data.c $ABBF, $13EF
    Data.c $FF21, $FF41
    Data.c $FF22, $FF42
    Data.c $FF23, $FF43
    Data.c $FF24, $FF44
    Data.c $FF25, $FF45
    Data.c $FF26, $FF46
    Data.c $FF27, $FF47
    Data.c $FF28, $FF48
    Data.c $FF29, $FF49
    Data.c $FF2A, $FF4A
    Data.c $FF2B, $FF4B
    Data.c $FF2C, $FF4C
    Data.c $FF2D, $FF4D
    Data.c $FF2E, $FF4E
    Data.c $FF2F, $FF4F
    Data.c $FF30, $FF50
    Data.c $FF31, $FF51
    Data.c $FF32, $FF52
    Data.c $FF33, $FF53
    Data.c $FF34, $FF54
    Data.c $FF35, $FF55
    Data.c $FF36, $FF56
    Data.c $FF37, $FF57
    Data.c $FF38, $FF58
    Data.c $FF39, $FF59
    Data.c $FF3A, $FF5A
    Data.c $0000, $0000
  EndDataSection

EndModule

;- End Of Module

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  UseModule CaseUnicode
 
  Debug "PB-LCase"
  t1.s = "ABCdef 0123456789, äöü, ÄÖÜ, áóú"
  r1.s = LCase(t1)
  Debug r1
 
  Debug "Uni-LCase"
  t1.s = "ABCdef 0123456789, äöü, ÄÖÜ, áóú"
  r1.s = LCaseW(t1)
  Debug r1
 
  Debug "PB-UCase"
  t1.s = "ABCdef 0123456789, äöü, ÄÖÜ, áóú"
  r1.s = UCase(t1)
  Debug r1
 
  Debug "Uni-UCase"
  t1.s = "ABCdef 0123456789, äöü, ÄÖÜ, áóú"
  r1.s = UCaseW(t1)
  Debug r1
 
  Debug "PB-FindString"
  Debug FindString(t1, "äÖ", 1, #PB_String_NoCase)
 
  Debug "Uni-FindString"
  Debug FindStringW(t1, "äÖ")
 
  Debug "Uni-ULCase"
  t1.s = "ABCdef 0123456789, äöü, ÄÖÜ, áóú"
  r1.s = ULCaseW(t1)
  Debug r1
 
  Debug "Uni-ULCase"
  t1.s = "h e l l o  w o r l d"
  r1.s = ULCaseW(t1)
  Debug r1
  
CompilerEndIf
