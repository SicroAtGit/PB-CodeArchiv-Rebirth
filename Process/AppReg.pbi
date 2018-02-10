;   Description: Create a custom "registry" in ProgramData / Library/Application Support/ / Home-directory 
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27741
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Thorsten1867
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

;/ ===== Application Registry (Module) ===== [ PureBasic V5.2x/V5.3x ]
;/ Registry (XML) for your program (e.g. for preferences)

DeclareModule AppReg
  Declare   Open(AppName.s, File.s="Registry.xml", Publisher.s="")
  Declare   Close()
  Declare   Save()
  Declare   SetValue(hKey.s, key.s, Name.s, Value.s)
  Declare.s GetValue(hKey.s, key.s, Name.s, DefaultValue.s="")
  Declare   SetInteger(hKey.s, key.s, Name.s, Value.i)
  Declare.i GetInteger(hKey.s, key.s, Name.s, DefaultValue.i=#Null)
  Declare   SetFloat(hKey.s, key.s, Name.s, Value.f)
  Declare.f GetFloat(hKey.s, key.s, Name.s, DefaultValue.f=#Null)
  Declare   Clear(hKey.s, key.s="")
  Declare   Delete(hKey.s, key.s, Name.s)
EndDeclareModule

Module AppReg
  
  EnableExplicit
  
  Structure AppRegStructure
    id.i
    File.s
  EndStructure 
  
  Procedure.s XMLDecode(xml$)
    Define txt$
    txt$ = ReplaceString(xml$, "&amp;", "&")
    txt$ = ReplaceString(txt$, "&lt;", "<")
    txt$ = ReplaceString(txt$, "&gt;", ">")
    txt$ = ReplaceString(txt$, "&apos;", "'")
    txt$ = ReplaceString(txt$, "&quot;", Chr(34))
    txt$ = ReplaceString(txt$, "&#128", "€")
    ProcedureReturn Trim(txt$)
  EndProcedure
  
  Procedure.s XMLEncode(txt$)
    Define xml$
    xml$ = ReplaceString(txt$, "&", "&amp;")
    xml$ = ReplaceString(xml$, "<", "&lt;")
    xml$ = ReplaceString(xml$, ">", "&gt;")
    xml$ = ReplaceString(xml$, "'", "&apos;")
    xml$ = ReplaceString(xml$, "€", "&#128")
    xml$ = ReplaceString(xml$, Chr(34), "&quot;")
    ProcedureReturn xml$
  EndProcedure
  
  ;- Open / Close Registry
  
  Procedure.s GetDefaultPath(AppName.s, Publisher.s = "")
    Protected Path.s, Slash.s
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        Slash = "\"
        Path = GetEnvironmentVariable("APPDATA") + "\"
      CompilerCase #PB_OS_MacOS
        Slash = "/"
        Path = GetHomeDirectory() + "Library/Application Support/"
      CompilerCase #PB_OS_Linux
        Slash = "/"
        Path = GetHomeDirectory() + "."   
    CompilerEndSelect
    If Publisher
      Path + Publisher + Slash
      If Not FileSize(Path) = - 2
        CreateDirectory(Path)
      EndIf
    EndIf
    Path + AppName + Slash
    If Not FileSize(Path) = - 2
      CreateDirectory(Path)
    EndIf
    If FileSize(Path) = -2
      ProcedureReturn Path
    EndIf
  EndProcedure
  
  Procedure Open(AppName.s, File.s="Registry.xml", Publisher.s="")
    Protected *Node
    Global AppReg.AppRegStructure
    If GetPathPart(File) = "" ;{ Default Path
      File = GetDefaultPath(AppName, Publisher) + File
    EndIf ;}
    If FileSize(File) > 0 ;{ Registry vorhanden
      AppReg\id = LoadXML(#PB_Any, File, #PB_UTF8)
      If XMLStatus(AppReg\id) = #PB_XML_Success
        AppReg\File = File
        ProcedureReturn #True
      EndIf
    EndIf ;}
          ;{ New Registry
    AppReg\id = CreateXML(#PB_Any, #PB_UTF8)
    If AppReg\id
      CompilerIf #PB_Compiler_Version >= 530
        *Node = CreateXMLNode(RootXMLNode(AppReg\id), "Registry")
        If *Node
          AppReg\File = File
          ProcedureReturn #True
        EndIf
      CompilerElse 
        *Node = CreateXMLNode(RootXMLNode(AppReg\id))
        If *Node
          SetXMLNodeName(*Node, "Registry")
          AppReg\File = File
          ProcedureReturn #True
        EndIf
      CompilerEndIf 
    EndIf
    AppReg\File = ""
    ProcedureReturn #False
    ;}
  EndProcedure
  
  Procedure Close()
    If IsXML(AppReg\id) And AppReg\File
      If SaveXML(AppReg\id, AppReg\File)
        FreeXML(AppReg\id)
        ProcedureReturn #True
      Else
        FreeXML(AppReg\id)
        ProcedureReturn #False
      EndIf
    ElseIf IsXML(AppReg\id)
      FreeXML(AppReg\id)
      ProcedureReturn #False
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure Save()
    If IsXML(AppReg\id) And AppReg\File
      If SaveXML(AppReg\id, AppReg\File)
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  ;- Set / Get Value
  
  Procedure.s GetAppRegPath(hKey.s, key.s, Name.s)
    If hKey And key
      If Name
        ProcedureReturn hKey+"/"+ReplaceString(key, "\", "/")+"/"+Name
      Else
        ProcedureReturn hKey+"/"+ReplaceString(key, "\", "/")
      EndIf
    ElseIf hKey
      If Name
        ProcedureReturn hKey+"/"+Name
      Else
        ProcedureReturn hKey
      EndIf
    ElseIf key
      If Name
        ProcedureReturn ReplaceString(key, "\", "/")+"/"+Name
      Else
        ProcedureReturn ReplaceString(key, "\", "/")
      EndIf
    Else
      ProcedureReturn Name
    EndIf
  EndProcedure
  
  Procedure SetValue(hKey.s, key.s, Name.s, Value.s)
    Protected n.i, RegPath.s, NodeName.s, *MainNode, *Node, *LastNode
    RegPath = GetAppRegPath(hKey.s, key.s, Name.s)
    If IsXML(AppReg\id) And RegPath
      *MainNode = MainXMLNode(AppReg\id)
      If *MainNode
        *Node = XMLNodeFromPath(*MainNode, RegPath)
        If Not *Node ;{ New Node
          *LastNode = *MainNode
          For n = 1 To CountString(RegPath, "/")+1
            NodeName = StringField(RegPath, n, "/")
            *Node = XMLNodeFromPath(*LastNode, NodeName)
            If Not *Node
              CompilerIf #PB_Compiler_Version >= 530
                *Node = CreateXMLNode(*LastNode, NodeName, -1)
                If *Node
                  *LastNode = *Node
                EndIf
              CompilerElse
                *Node = CreateXMLNode(*LastNode, -1)
                If *Node
                  SetXMLNodeName(*Node, NodeName)
                  *LastNode = *Node
                EndIf
              CompilerEndIf
            Else
              *LastNode = *Node
            EndIf
          Next
        EndIf ;}
        If *Node
          SetXMLNodeText(*Node, XMLEncode(Value))
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure SetInteger(hKey.s, key.s, Name.s, Value.i)
    SetValue(hKey, key, Name, Str(Value))
  EndProcedure
  
  Procedure SetFloat(hKey.s, key.s, Name.s, Value.f)
    SetValue(hKey, key, Name, StrF(Value))
  EndProcedure 
  
  Procedure.s GetValue(hKey.s, key.s, Name.s, DefaultValue.s="")
    Protected *MainNode, *Node, RegPath.s, Result.s
    RegPath = GetAppRegPath(hKey.s, key.s, Name.s)
    If IsXML(AppReg\id)
      *MainNode = MainXMLNode(AppReg\id)
      If *MainNode
        *Node = XMLNodeFromPath(*MainNode, RegPath)
        If *Node
          Result = XMLDecode(GetXMLNodeText(*Node))
          If Result
            ProcedureReturn Result
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn DefaultValue
  EndProcedure
  
  Procedure.i GetInteger(hKey.s, key.s, Name.s, DefaultValue.i=#Null)
    Protected Value.s = GetValue(hKey, key, Name, Str(DefaultValue))
    ProcedureReturn Val(Value)
  EndProcedure
  
  Procedure.f GetFloat(hKey.s, key.s, Name.s, DefaultValue.f=#Null)
    Protected Value.s = GetValue(hKey, key, Name, StrF(DefaultValue))
    ProcedureReturn ValF(Value)
  EndProcedure
  
  ;- Delete
  
  Procedure ClearChilds_AppReg(*CurrentNode)
    Protected *ChildNode
    If XMLNodeType(*CurrentNode) = #PB_XML_Normal
      *ChildNode = ChildXMLNode(*CurrentNode)
      While *ChildNode <> 0
        If XMLChildCount(*ChildNode)
          ClearChilds_AppReg(*ChildNode)
        Else
          SetXMLNodeText(*ChildNode, "")
        EndIf
        *ChildNode = NextXMLNode(*ChildNode)
      Wend       
    EndIf
  EndProcedure
  
  Procedure Clear(hKey.s, key.s="")
    Protected *MainNode, *Node, RegPath.s
    If IsXML(AppReg\id)
      *MainNode = MainXMLNode(AppReg\id)
      If *MainNode
        If hKey And key ;{ RegPath ermitteln
          RegPath = hKey+"/"+ReplaceString(key, "\", "/")
        ElseIf hKey
          RegPath = hKey
        EndIf ;}
        If RegPath
          *Node = XMLNodeFromPath(*MainNode, RegPath)
          If *Node
            If XMLChildCount(*Node)
              ClearChilds_AppReg(*Node)
            Else
              SetXMLNodeText(*Node, "")
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf 
  EndProcedure
  
  Procedure Delete(hKey.s, key.s, Name.s)
    Protected *MainNode, *Node, RegPath.s
    RegPath = GetAppRegPath(hKey.s, key.s, Name.s)
    If IsXML(AppReg\id)
      *MainNode = MainXMLNode(AppReg\id)
      If *MainNode
        *Node = XMLNodeFromPath(*MainNode, RegPath)
        If *Node
          DeleteXMLNode(*Node)
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Define Combo.i, Check.i, quitAppReg.l = #False
  #Window = 0
  Enumeration 1
    #Gadget_Frame1
    #Gadget_Frame2
    #Gadget_File
    #Gadget_Button
    #Gadget_ComboBox
    #Gadget_CheckBox
  EndEnumeration
  
  AppReg::Open("MyProg")
  
  If OpenWindow(#Window,90,96,240,124," Application Registry",#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    FrameGadget(#Gadget_Frame1,10,5,220,50,"Preference")
    FrameGadget(#Gadget_Frame2,10,65,220,50,"Remember Last Path")
    StringGadget(#Gadget_File,20,85,145,20,"",#PB_String_ReadOnly)
    ButtonGadget(#Gadget_Button,170,85,50,20,"Select")
    ComboBoxGadget(#Gadget_ComboBox,20,25,120,20)
    AddGadgetItem(#Gadget_ComboBox, 0, "Option 1")
    AddGadgetItem(#Gadget_ComboBox, 1, "Option 2")
    CheckBoxGadget(#Gadget_CheckBox,155,25,65,20," Option 3")
    HideWindow(#Window,0)
    
    Combo = AppReg::GetInteger("Preference", "General", "ComboBox", -1)
    SetGadgetState(#Gadget_ComboBox, Combo)
    Check = AppReg::GetInteger("Preference", "General", "CheckBox", 0)
    SetGadgetState(#Gadget_CheckBox, Check)
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          AppReg::SetInteger("Preference", "General", "ComboBox", GetGadgetState(#Gadget_ComboBox))
          AppReg::SetInteger("Preference", "General", "CheckBox", GetGadgetState(#Gadget_CheckBox))
          quitAppReg = #True
        Case #PB_Event_Gadget
          If EventGadget() = #Gadget_Button
            File$ = OpenFileRequester("Open File", AppReg::GetValue("Intern", "Last", "Path", "C:\"), "All Files (*.*)|*.*", 0)
            If File$
              SetGadgetText(#Gadget_File, GetFilePart(File$))
              AppReg::SetValue("Intern", "Last", "Path", GetPathPart(File$))
            EndIf
          EndIf
      EndSelect
    Until quitAppReg
    CloseWindow(#Window)
  EndIf
  
  AppReg::Close()
  
CompilerEndIf
