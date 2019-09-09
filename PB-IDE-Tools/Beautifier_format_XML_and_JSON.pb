;   Description: Format xml and json for easier reading
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28470
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Kiffi
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

; Tool Settings:
; - Event: Menu Or Shortcut
; For MacOS, the field "Commandline" must contain the full path to the executable
; file, e.g.: .../Program.app/Contents/MacOS/Program

Enumeration FormWindow
  #frmMain
EndEnumeration

Enumeration FormGadget
  #cmdBeautify
  #edIn
  #edOut
  #Splitter_0
EndEnumeration

Declare ResizeGadgetsfrmMain()

Procedure OpenfrmMain(x = 0, y = 0, width = 590, height = 480)
  OpenWindow(#frmMain, x, y, width, height, "Beautifier", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
  ButtonGadget(#cmdBeautify, 480, 440, 100, 30, "Beautify")
  EditorGadget(#edIn, 10, 10, 570, 210, #PB_Editor_WordWrap)
  EditorGadget(#edOut, 10, 229, 570, 201)
  SplitterGadget(#Splitter_0, 10, 10, 570, 420, #edIn, #edOut)
  SetGadgetState(#Splitter_0, 210)
EndProcedure

Procedure ResizeGadgetsfrmMain()
  Protected FormWindowWidth, FormWindowHeight
  FormWindowWidth = WindowWidth(#frmMain)
  FormWindowHeight = WindowHeight(#frmMain)
  ResizeGadget(#cmdBeautify, FormWindowWidth - 110, FormWindowHeight - 40, 100, 30)
  ResizeGadget(#Splitter_0, 10, 10, FormWindowWidth - 20, FormWindowHeight - 60)
EndProcedure
EnableExplicit

;XIncludeFile "Beautifier.pbf"

OpenfrmMain()

Procedure BeautifyXml()
  
  Protected Xml
  
  Xml = ParseXML(#PB_Any, GetGadgetText(#edIn))
  
  If Xml And XMLStatus(Xml) = #PB_XML_Success
    FormatXML(Xml, #PB_XML_ReFormat)
    SetGadgetText(#edOut, ComposeXML(Xml))
    FreeXML(Xml)
  Else
    SetGadgetText(#edOut, XMLError(Xml) + #CRLF$ + "Line: " + Str(XMLErrorLine(Xml)) + #CRLF$ + "Position: " + Str(XMLErrorPosition(Xml)))
  EndIf
  
EndProcedure

Procedure BeautifyJson()
  
  Protected Json
  
  Json = ParseJSON(#PB_Any, GetGadgetText(#edIn))
  
  If Json
    SetGadgetText(#edOut, ComposeJSON(Json, #PB_JSON_PrettyPrint))
    FreeJSON(Json)
  Else
    SetGadgetText(#edOut, JSONErrorMessage() + #CRLF$ + "Line: " + Str(JSONErrorLine()) + #CRLF$ + "Position: " + Str(JSONErrorPosition()))
  EndIf
  
EndProcedure

Procedure cmdBeautify_Event()
  
  Protected TextToBeautify.s = GetGadgetText(#edIn)
  
  While Left(TextToBeautify, 1) = Chr(32) Or Left(TextToBeautify, 1) = #TAB$
    TextToBeautify = Trim(TextToBeautify, Chr(32))
    TextToBeautify = Trim(TextToBeautify, #TAB$)
  Wend   
  
  Select Left(TextToBeautify, 1)
    Case "<"
      BeautifyXml()
    Case "[", "{"
      BeautifyJson()
    Default
      MessageRequester("Beautifier", "?")
  EndSelect
  
EndProcedure

BindEvent(#PB_Event_SizeWindow, @ResizeGadgetsfrmMain())
BindGadgetEvent(#cmdBeautify, @cmdBeautify_Event(), #PB_EventType_LeftClick)
SetActiveGadget(#edIn)

Repeat
Until WaitWindowEvent()=#PB_Event_CloseWindow
