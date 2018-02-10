;   Description: DOT is a plain text graph description language. It is a simple way of describing graphs that both humans and computer programs can use. 
;            OS: Windows, Mac, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29191
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

;https://en.wikipedia.org/wiki/DOT_%28graph_description_language%29
;Download and install Graphviz from http://www.graphviz.org/
;And change the #DotExe constant!
;See DOT_(graph_description_language)_example_result.png


EnableExplicit

#DotExe="C:\Program Files (x86)\Graphviz\bin\dot.exe" 

Procedure.s ReadXmlStructure(Node)
  
  Static ReturnValue.s
  
  Protected ChildNode
  Protected ChildXMLNodeName.s
  Protected ParentXMLNodeName.s
  
  ChildNode = ChildXMLNode(Node)
  
  While ChildNode <> 0
    
    If XMLNodeType(ParentXMLNode(ChildNode)) = #PB_XML_Normal
      ParentXMLNodeName = GetXMLNodeName(ParentXMLNode(ChildNode))
    EndIf
    
    If XMLNodeType(ChildNode) = #PB_XML_Normal
      ChildXMLNodeName = GetXMLNodeName(ChildNode)
    EndIf
    
    If ParentXMLNodeName <> "" And ChildXMLNodeName <> ""
      ReturnValue + ParentXMLNodeName + " -> " + ChildXMLNodeName + ";" + #CRLF$
    EndIf
    
    If XMLChildCount(ChildNode)
      ReadXmlStructure(ChildNode)
    EndIf
    
    ChildNode = NextXMLNode(ChildNode)
    
  Wend
  
  ProcedureReturn ReturnValue
  
EndProcedure

InitNetwork()

Define XmlStructure.s
Define TempXmlFileName.s
Define TempDotFileName.s
Define TempPngFileName.s
Define DotExe.s
Define FF, oXML

TempXmlFileName ="DOT_(graph_description_language)_example.xml"; GetTemporaryDirectory() + "dot.xml"

;If ReceiveHTTPFile("http://www.w3schools.com/xml/cd_catalog.xml", TempXmlFileName)
  
  oXML = LoadXML(#PB_Any, TempXmlFileName)
  
  If oXML
    
    If XMLStatus(oXML) = #PB_XML_Success
      
      XmlStructure = ReadXmlStructure(RootXMLNode(oXML))
      
      XmlStructure = RemoveString(XmlStructure, ".") ; DOT mag keine Punkte als Bezeichner?
      
      XmlStructure = "strict digraph xml {" + #CRLF$ + "graph [rankdir=LR];" + XmlStructure + "}"
      
      TempDotFileName = GetTemporaryDirectory() + "dot.dot"
      TempPngFileName = GetTemporaryDirectory() + "dot.png"
      
      FF = CreateFile(#PB_Any, TempDotFileName)
      
      If FF
        
        WriteString(FF, XmlStructure)
        CloseFile(FF)
        
        TempDotFileName = Chr(34) + TempDotFileName + Chr(34)
        TempPngFileName = Chr(34) + TempPngFileName + Chr(34)
        
        DotExe = #DotExe
        
        If RunProgram(DotExe, "-Tpng " + TempDotFileName + " -o " + TempPngFileName, "", #PB_Program_Wait | #PB_Program_Hide)
          
          RunProgram(TempPngFileName)
          
        Else
          
          Debug "!RunProgram()"
          
        EndIf
        
      Else
        
        Debug "!CreateFile()"
        
      EndIf
      
    Else
      
      Debug "!XMLStatus()"
      Debug XMLError(oXML)
      
    EndIf
    
    FreeXML(oXML)
    
  Else
    
    Debug "!oXML"
    
  EndIf
  
;Else
  
;  Debug "!ReceiveHTTPFile()"
  
;EndIf
