;   Description: Provides functions to easily manage program settings
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72471
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31347
; -----------------------------------------------------------------------------

;/ ============================
;/ =   AppRegistryModule.pbi  =
;/ ============================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Application Registry
;/
;/ © 2019 Thorsten1867 (03/2019)
;/


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
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
;}


;{ _____ AppRegistry-Commands _____

; AppReg::Remove()     - remove this application registry
; AppReg::Delete()     - deletes a 'Name' or a 'HKey'

; AppReg::GetFloat()   - returns the value as float
; AppReg::GetInfo()    - returns infos about the application (AppName/Publisher/Date of modification)
; AppReg::GetInteger() - returns the value as integer
; AppReg::GetValue()   - returns the value as string

; AppReg::SetFloat()   - store a float number
; AppReg::SetInteger() - store an integer number
; AppReg::SetValue()   - store a string

; AppReg::Open()       - open new or existing Application Registry
; AppReg::Close()      - close Application Registry and save it to file
  
;}

DeclareModule AppReg
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
  
  Declare   Remove(ID.i)
  Declare   Delete(ID.i, Key.s, Name.s="")
  
  Declare.f GetFloat(ID.i, Key.s, Name.s, DefaultValue.f=#PB_Default)
  Declare.i GetInteger(ID.i, Key.s, Name.s, DefaultValue.i=#PB_Default)
  Declare.s GetInfo(ID.i, Attribute.i)
  Declare.s GetValue(ID.i, Key.s, Name.s, DefaultValue.s="")
  
  Declare   SetFloat(ID.i, Key.s, Name.s, Value.f)
  Declare   SetInteger(ID.i, Key.s, Name.s, Value.i)
  Declare   SetValue(ID.i, Key.s, Name.s, Value.s)
  
  Declare   Open(ID.i, File.s="Registry.reg", AppName.s="", Publisher.s="")
  Declare   Close(ID.i)

EndDeclareModule


Module AppReg

  EnableExplicit
  
  ;- ===========================================================================
  ;-   Module
  ;- ===========================================================================  
  
  #JSON = 0
  
  #Application = 1
  #Publisher   = 2
  #Modified    = 3
  
  Structure AppReg_HKey_Structure
    Map Name.s()
  EndStructure
  
  Structure AppReg_Structure
    AppName.s
    Publisher.s
    Modified.i
    File.s
    Map Key.AppReg_HKey_Structure()
  EndStructure
  Global NewMap AppReg.AppReg_Structure()
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ========================================================================== 
  
  Procedure   Remove(ID.i)
    
    If FindMapElement(AppReg(), Str(ID))
      
      DeleteMapElement(AppReg(), Str(ID))
      
    EndIf  
    
  EndProcedure
  
  Procedure   Delete(ID.i, Key.s, Name.s="")
    
    If FindMapElement(AppReg(), Str(ID))
      
      If Name
        
        If FindMapElement(AppReg()\Key(), Key)
          DeleteMapElement(AppReg()\Key()\Name(), Name)
        EndIf
        
      Else
        
        DeleteMapElement(AppReg()\Key(), Key)
        
      EndIf
      
    EndIf
      
  EndProcedure
  
  Procedure.s GetInfo(ID.i, Attribute.i)
    
    If FindMapElement(AppReg(), Str(ID))
      
      Select Attribute
        Case #Application
          ProcedureReturn AppReg()\AppName
        Case #Publisher
          ProcedureReturn AppReg()\Publisher
        Case #Modified
          ProcedureReturn FormatDate("%dd.%mm.%yyyy / %hh:%ii:%ss", AppReg()\Modified)
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure.s GetValue(ID.i, Key.s, Name.s, DefaultValue.s="")
    
    If FindMapElement(AppReg(), Str(ID))
      If AppReg()\Key(Key)\Name(Name)
        ProcedureReturn AppReg()\Key(Key)\Name(Name)
      Else
        ProcedureReturn DefaultValue
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure.i GetInteger(ID.i, Key.s, Name.s, DefaultValue.i=#PB_Default)
    
    If FindMapElement(AppReg(), Str(ID))
      If AppReg()\Key(Key)\Name(Name)
        ProcedureReturn Val(AppReg()\Key(Key)\Name(Name))
      Else
        ProcedureReturn DefaultValue
      EndIf
    EndIf
    
  EndProcedure
  
  Procedure.f GetFloat(ID.i, Key.s, Name.s, DefaultValue.f=#PB_Default)
    
    If FindMapElement(AppReg(), Str(ID))
      If AppReg()\Key(Key)\Name(Name)
        ProcedureReturn ValF(AppReg()\Key(Key)\Name(Name))
      Else
        ProcedureReturn DefaultValue
      EndIf
    EndIf
    
  EndProcedure
  
  
  Procedure SetValue(ID.i, Key.s, Name.s, Value.s)
    
    If FindMapElement(AppReg(), Str(ID))
      AppReg()\Key(Key)\Name(Name) = Value
    EndIf
    
  EndProcedure
  
  Procedure SetInteger(ID.i, Key.s, Name.s, Value.i)
    
    If FindMapElement(AppReg(), Str(ID))
      AppReg()\Key(Key)\Name(Name) = Str(Value)
    EndIf
    
  EndProcedure
  
  Procedure SetFloat(ID.i, Key.s, Name.s, Value.f)
    
    If FindMapElement(AppReg(), Str(ID))
      AppReg()\Key(Key)\Name(Name) = StrF(Value)
    EndIf
    
  EndProcedure
  
  
  Procedure Open(ID.i, File.s="Registry.reg", AppName.s="", Publisher.s="")
    
    If AddMapElement(AppReg(), Str(ID))
      
      AppReg()\AppName   = AppName
      AppReg()\Publisher = Publisher
      AppReg()\File      = File
      
      If LoadJSON(#JSON, File)
        ExtractJSONMap(JSONValue(#JSON), AppReg())
        FreeJSON(#JSON)
      EndIf
      
    EndIf
  
  EndProcedure
  
  Procedure Close(ID.i)
    
    If FindMapElement(AppReg(), Str(ID))
      
      AppReg()\Modified = Date()
      
      If CreateJSON(#JSON)
        InsertJSONMap(JSONValue(#JSON), AppReg())
        SaveJSON(#JSON, AppReg()\File)
        FreeJSON(#JSON)
      EndIf
    
    EndIf

  EndProcedure
  
EndModule


;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  Define Combo.i, Check.i, quitAppReg.i = #False
  
  #Window = 0
  #HKey = 1
  
  Enumeration 1
    #Gadget_Frame1
    #Gadget_Frame2
    #Gadget_File
    #Gadget_Button
    #Gadget_ComboBox
    #Gadget_CheckBox
  EndEnumeration
  
  AppReg::Open(#HKey)
  
  If OpenWindow(#Window, 90, 96, 240, 124, " Application Registry", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    
    FrameGadget(#Gadget_Frame1, 10,  5, 220, 50, " Preference")
    FrameGadget(#Gadget_Frame2, 10, 65, 220, 50, "Remember Last Path")
    StringGadget(#Gadget_File,  20, 85, 145, 20, "",#PB_String_ReadOnly)
    SetGadgetText(#Gadget_File, AppReg::GetValue(#HKey, "Last", "Path"))
    ButtonGadget(#Gadget_Button, 170, 85, 50, 20, "Select")
    ComboBoxGadget(#Gadget_ComboBox, 20, 25, 120, 20)
    AddGadgetItem(#Gadget_ComboBox, 0, "Option 1")
    AddGadgetItem(#Gadget_ComboBox, 1, "Option 2")
    CheckBoxGadget(#Gadget_CheckBox, 155, 25, 65, 20, " Option 3")
    HideWindow(#Window, #False)
    
    Combo = AppReg::GetInteger(#HKey, "General", "ComboBox", -1)
    SetGadgetState(#Gadget_ComboBox, Combo)
    Check = AppReg::GetInteger(#HKey, "General", "CheckBox", 0)
    SetGadgetState(#Gadget_CheckBox, Check)
    
    Repeat 
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          AppReg::SetInteger(#HKey, "General", "ComboBox", GetGadgetState(#Gadget_ComboBox))
          AppReg::SetInteger(#HKey, "General", "CheckBox", GetGadgetState(#Gadget_CheckBox))
          quitAppReg = #True
        Case #PB_Event_Gadget
          If EventGadget() = #Gadget_Button
            File$ = OpenFileRequester("Open File", AppReg::GetValue(#HKey, "Last", "Path", "C:\"), "All Files (*.*)|*.*", 0)
            If File$
              SetGadgetText(#Gadget_File, GetFilePart(File$))
              AppReg::SetValue(#HKey, "Last", "Path", GetPathPart(File$))
            EndIf
          EndIf
      EndSelect
    Until quitAppReg
    
    CloseWindow(#Window)
  EndIf
  
  AppReg::Close(#HKey)
  
CompilerEndIf
