;   Description: Generates code39 bar code
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=67126
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 Poshu
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

; Code39 barcode generator module for PB 5.50
; Note : this is DIRTY, a lot of wasted ram and a slow way to process each string. A better solution would be to make a big bit array, and ascii() the string. Sadly, this was done in less than 10 minutes and I'm way to lazy to change it.

DeclareModule Code39
  Declare.i Generate(String.s)
EndDeclareModule

Module Code39
  EnableExplicit
  #CodebarHeight = 30
  #CharWidth = 19
  
  Global NewMap char.i() ;{ char map
  char("A") = AllocateMemory(32) : PokeL(char("A"),250031)
  char("B") = AllocateMemory(32) : PokeL(char("B"),250045)
  char("C") = AllocateMemory(32) : PokeL(char("C"),181743)
  char("D") = AllocateMemory(32) : PokeL(char("D"),250341)
  char("E") = AllocateMemory(32) : PokeL(char("E"),182191)
  char("F") = AllocateMemory(32) : PokeL(char("F"),182205)
  char("G") = AllocateMemory(32) : PokeL(char("G"),252965)
  char("H") = AllocateMemory(32) : PokeL(char("H"),159919)
  char("I") = AllocateMemory(32) : PokeL(char("I"),159933)
  char("J") = AllocateMemory(32) : PokeL(char("J"),192997)
  char("K") = AllocateMemory(32) : PokeL(char("K"),246959)
  char("L") = AllocateMemory(32) : PokeL(char("L"),246973)
  char("M") = AllocateMemory(32) : PokeL(char("M"),136687)
  char("N") = AllocateMemory(32) : PokeL(char("N"),247269)
  char("O") = AllocateMemory(32) : PokeL(char("O"),137135)
  char("P") = AllocateMemory(32) : PokeL(char("P"),137149)
  char("Q") = AllocateMemory(32) : PokeL(char("Q"),247717)
  char("R") = AllocateMemory(32) : PokeL(char("R"),138415)
  char("S") = AllocateMemory(32) : PokeL(char("S"),138429)
  char("T") = AllocateMemory(32) : PokeL(char("T"),138725)
  char("U") = AllocateMemory(32) : PokeL(char("U"),251023)
  char("V") = AllocateMemory(32) : PokeL(char("V"),251361)
  char("W") = AllocateMemory(32) : PokeL(char("W"),186255)
  char("X") = AllocateMemory(32) : PokeL(char("X"),251809)
  char("Y") = AllocateMemory(32) : PokeL(char("Y"),155279)
  char("Z") = AllocateMemory(32) : PokeL(char("Z"),188385)
  char("0") = AllocateMemory(32) : PokeL(char("0"),194437)
  char("1") = AllocateMemory(32) : PokeL(char("1"),250927)
  char("2") = AllocateMemory(32) : PokeL(char("2"),250941)
  char("3") = AllocateMemory(32) : PokeL(char("3"),184815)
  char("4") = AllocateMemory(32) : PokeL(char("4"),251781)
  char("5") = AllocateMemory(32) : PokeL(char("5"),187951)
  char("6") = AllocateMemory(32) : PokeL(char("6"),187965)
  char("7") = AllocateMemory(32) : PokeL(char("7"),253061)
  char("8") = AllocateMemory(32) : PokeL(char("8"),193583)
  char("9") = AllocateMemory(32) : PokeL(char("9"),193597)
  char("-") = AllocateMemory(32) : PokeL(char("-"),253089)
  char("$") = AllocateMemory(32) : PokeL(char("$"),181281)
  char("%") = AllocateMemory(32) : PokeL(char("%"),135301)
  char(".") = AllocateMemory(32) : PokeL(char("."),160911)
  char("/") = AllocateMemory(32) : PokeL(char("/"),136225)
  char("+") = AllocateMemory(32) : PokeL(char("+"),135329)
  char("*") = AllocateMemory(32) : PokeL(char("*"),194465)
  char(" ") = AllocateMemory(32) : PokeL(char(" "),194017)
  ;}
  
  Procedure.i Generate(String.s)
    Protected state, mf,*tb.byte, char.s
    Protected.i Loop, CharLoop, Result, Len = Len(String)+1
    Protected.i Width = len*#CharWidth+18
    
    String = "*"+String+"*"
    Result = CreateImage(#PB_Any,Width,#CodebarHeight,24,$FFFFFF)
    
    If Result
      StartDrawing(ImageOutput(Result))
      For loop = 0 To Len
        char = Mid(String, loop+1, 1)
        For CharLoop = 0 To 17
          mf = (CharLoop % 8)
          *tb = char(char)+(CharLoop>>3)
          If (*tb\b & (1 << mf)) >> mf
            Line(loop*#CharWidth+CharLoop,0,1,#CodebarHeight,0)
          EndIf
        Next
      Next
      StopDrawing()
    EndIf
    
    ProcedureReturn Result
    
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  OpenWindow(0,#PB_Ignore,#PB_Ignore,305,50,"Code 39",#PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  image = Code39::Generate("PUREBASIC FTW")
  ImageGadget(1,10,10,0,0,ImageID(image))
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
CompilerEndIf
