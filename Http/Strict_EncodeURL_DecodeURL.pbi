;   Description: Strict functions for EncodeURL and DecodeURL
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=22286
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2010, 2013 helpy
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

; ================================================================================
; Funktion:     Result.s = URLEncoderX( URL.s [, Encoding] )
;
; Argumente:    URL ........ Zu codierende URL
;               Encoding ... Zu verwendende Codierung
;                            Gültige Argumente:  #PB_UTF8, PB_Ascii
;                            Standard-Codierung: #PB_UTF8
;
; Beschreibung: Diese Funktion codiert einen String, sodass dieser als Argument
;               einer URL übergeben werden kann. Besondere Zeichen werden mit
;               dem Prozentzeichen und dem HEX-Code dargestellt.
;               Beispiel 1: URLEncoderX( "test_ä.html", #PB_Ascii )
;                           liefert als Ergebnis: test_%E4.html
;
;               Beispiel 2: URLEncoderX( "test_ä.html", #PB_UTF8 )
;                           liefert als Ergebnis: test_%C3%A4.html
;
Procedure.s URLEncoderX( URL.s, Encoding = #PB_UTF8 )
  Protected *memory, *UTF8.Ascii, EncodedURL.s

  Select Encoding
    Case #PB_UTF8, #PB_Ascii
      *memory = AllocateMemory( Len(URL) * 4 + 1 )
      *UTF8 = *memory

      If *UTF8
        ; Wenn als Ascii-Codierung verwendet wird, dann können nur 255 Zeichen
        ; dargestellt werden. Bei der Umwandlung in einen Ascii-String entsteht
        ; also ein falsches Ergebnis, wenn der URL-String Unicode-Zeichen enthält
        PokeS( *UTF8, URL, -1, Encoding )

        While *UTF8\a

          Select *UTF8\a

            Case 'A' To 'Z', 'a' To 'z', '0' To '9', '-', '_', '.', '~'
              ; Keine Codierung dieser Zeichen notwendig
              EncodedURL + Chr(*UTF8\a)

            Default
              ; Codierung notwendig
              EncodedURL + "%" + RSet(Hex(*UTF8\a, #PB_Ascii),2,"0")

          EndSelect

          *UTF8 + 1
        Wend

        FreeMemory( *memory )
      Else
        ; Wenn kein Speicher allokiert werden konnte,
        ; liefert die Funktion einen Leer-String zurück.
      EndIf

    Default
      ; Encoding nicht erlaubt!
      ; Funktion liefert einen Leer-String zurück.

  EndSelect

  ProcedureReturn EncodedURL
EndProcedure

 ; ================================================================================
; Funktion:     Result.s = URLDecoderX( URL.s [, Encoding] )
;
; Argumente:    URL ........ Zu decodierende URL
;               Encoding ... Codierung, in der die URL vorliegt
;                            Gültige Argumente:  #PB_UTF8, PB_Ascii
;                            Standard-Codierung: #PB_UTF8
;
; Beschreibung: Diese Funktion decodiert einen URL-kodierten String.
;
Procedure.s URLDecoderX( URL.s, Encoding = #PB_UTF8 )
  Protected *URL.Character
  Protected *DecodedString, *DecodedByte.Ascii, DecodedURL.s, EncodedCharacter.s

  Select Encoding
    Case #PB_UTF8, #PB_Ascii
      *URL = @URL

      If *URL And *URL\c
        *DecodedString = AllocateMemory( Len(URL) + 1 )
        *DecodedByte = *DecodedString

        If *DecodedString
          While *URL\c

            Select *URL\c

              Case '%'
                ; Dekodierung
                *URL + SizeOf(Character)
                EncodedCharacter = Chr(*URL\c)
                *URL + SizeOf(Character)
                EncodedCharacter + Chr(*URL\c)
                *DecodedByte\a = Val( "$" + EncodedCharacter )

              Default
                ; Zeichen direkt übernehmen!
                *DecodedByte\a = *URL\c

            EndSelect

            *DecodedByte + 1
            *URL + SizeOf(Character)
          Wend

          DecodedURL = PeekS( *DecodedString, -1, Encoding )
          FreeMemory( *DecodedString )
        Else

        EndIf

      Else
        ; Leer-String
      EndIf

    Default
      ; Encoding nicht erlaubt!
      ; Funktion liefert einen Leer-String zurück.

  EndSelect

  ProcedureReturn DecodedURL
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Debug URLEncoder("http://www.purebasic.com/sub dir/test With space.php3")
  ; Will print "http://www.purebasic.com/sub%20dir/test%20with%20space.php3"
  
  Debug URLEncoderX("http://www.purebasic.com/sub dir/test With space.php3")
  ; Will print "http%3A%2F%2Fwww.purebasic.com%2Fsub%20dir%2Ftest%20With%20space.php3"
CompilerEndIf
