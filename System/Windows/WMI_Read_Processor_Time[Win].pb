;   Description: Read processor time with WMI
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29242
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 Kiffi
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

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf
EnableExplicit

Define VbScript.s
Define VBS
Define Xml.s

VbScript = "Set objWMIService = GetObject(''winmgmts:\\localhost\root\CIMV2'')" + #CRLF$ +
           "Set CPUInfo = objWMIService.ExecQuery(''SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfOS_Processor'',,48)" + #CRLF$ +
           "Output = ''<list>''" + #CRLF$ +
           "For Each Item in CPUInfo" + #CRLF$ +
           "  Output = Output & ''<element>'' & Item.PercentProcessorTime & ''</element>''" + #CRLF$ +
           "Next" + #CRLF$ +
           "Output = Output & ''</list>''" + #CRLF$ +
           "WScript.StdOut.Writeline Output" + #CRLF$

VbScript = ReplaceString(VbScript, "''", Chr(34))

CreateFile(0, GetTemporaryDirectory() + "cpuinfo.vbs")
WriteString(0, VbScript)
CloseFile(0)

VBS = RunProgram("wscript", GetTemporaryDirectory() + "cpuinfo.vbs", "", #PB_Program_Open | #PB_Program_Read)

If VBS
  Xml = ReadProgramString(VBS)
  CloseProgram(VBS)
Else
  Debug "!RunProgram"
EndIf

If ParseXML(0, Xml) And XMLStatus(0) = #PB_XML_Success
  NewList Value.s()
  ExtractXMLList(MainXMLNode(0), Value())
  FreeXML(0)
  ForEach Value()
    Debug "PercentProcessorTime: " + Value()
  Next
Else
  Debug XMLError(0)
EndIf
