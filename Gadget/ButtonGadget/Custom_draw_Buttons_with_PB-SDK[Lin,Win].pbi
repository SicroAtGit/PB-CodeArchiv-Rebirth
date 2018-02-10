;   Description: Custom Draw Button Gadget with PB-SDK
;            OS: Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27851
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 mk-soft
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

; Kommentar     : Modul ButtonColorGadget (development version)
; Author        : mk-soft
; Second Author :
; Datei         : *.pb
; Version       : 1.19
; Erstellt      : 21.03.2014
; Geändert      : 19.04.2014
;
; Compilermode  : ASCII, Unicode
; OS            : Windows, Linux
;
; ***************************************************************************************

CompilerIf #PB_Compiler_OS=#PB_OS_MacOS
 CompilerError "Windows&Linux Only!"
CompilerEndIf


;- Modul Public
DeclareModule ButtonColorGadget
  
  Declare Create(id, x, y, dx, dy, text.s, flags = #PB_Button_Default)
  
EndDeclareModule

;- Modul Private
Module ButtonColorGadget
  EnableExplicit
  
  ;- PB Interne System Funktionen
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Import ""
      CompilerElse ;EndIndent
    ImportC ""
    CompilerEndIf
    PB_Object_GetObject(Objects.i, ID.i)
    PB_Gadget_Objects.i
  EndImport
  
  Import ""
    SYS_GetParameterIndex(String)
    SYS_GetOutputBuffer(StringLength, PreviousPosition)
    SYS_ResolveParameter(ParameterIndex)
  EndImport
  
  ;- Konstanten
  #ButtonColorStateDefault = 0
  #ButtonColorStateOver = 1
  #ButtonColorStateDown = 2
  
  ;- Declare Basisfunktionen
  Declare NewData(*this)
  Declare FreeData(*this)
  
  ;- Declare Eigene Funktionen
  Declare Draw(*MyGadgetVT)
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;- PB Interne Struktur Gadget Windows
    Structure Gadget
      Gadget.i
      *vt.GadgetVT
      UserData.i
      OldCallback.i
      Daten.i[4]
    EndStructure
  CompilerElse
    ;- PB Interne Struktur Gadget Linux
    Structure Gadget
      Gadget.i
      GadgetContainer.i
      *vt.GadgetVT
      UserData.i
      Daten.i[4]
    EndStructure
  CompilerEndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;- PB Interne Prototypen Windows
    Prototype Proc_Callback(*this.Gadget, Window, Message, wParam, lParam)
    Prototype Proc_FreeGadget(*this.Gadget)
    Prototype Proc_GetGadgetState(*this.Gadget)
    Prototype Proc_SetGadgetState(*this.Gadget, State)
    Prototype Proc_GetGadgetText(*this.Gadget, PreviousStringPosition)
    Prototype Proc_SetGadgetText(*this.Gadget, *Text)
    Prototype Proc_AddGadgetItem2(*this.Gadget, Position, *Text, *Image)
    Prototype Proc_AddGadgetItem3(*this.Gadget, Position, *Text, *Image, Flags)
    Prototype Proc_RemoveGadgetItem(*this.Gadget, Item)
    Prototype Proc_ClearGadgetItemList(*this.Gadget)
    Prototype Proc_ResizeGadget(*this.Gadget, x, y, width, height)
    Prototype Proc_CountGadgetItems(*this.Gadget)
    Prototype Proc_GetGadgetItemState(*this.Gadget, Item)
    Prototype Proc_SetGadgetItemState(*this.Gadget, Item, State)
    Prototype Proc_GetGadgetItemText(*this.Gadget, Item, Column, PreviousStringPosition)
    Prototype Proc_SetGadgetItemText(*this.Gadget, Item, *Text, Column)
    Prototype Proc_OpenGadgetList2(*this.Gadget, Item)
    Prototype Proc_GadgetX(*this.Gadget)
    Prototype Proc_GadgetY(*this.Gadget)
    Prototype Proc_GadgetWidth(*this.Gadget)
    Prototype Proc_GadgetHeight(*this.Gadget)
    Prototype Proc_HideGadget(*this.Gadget, State)
    Prototype Proc_AddGadgetColumn(*this.Gadget, Item, *Text, Column)
    Prototype Proc_RemoveGadgetColumn(*this.Gadget, Position)
    Prototype Proc_GetGadgetAttribute(*this.Gadget, Attribute)
    Prototype Proc_SetGadgetAttribute(*this.Gadget, Attribute, Value)
    Prototype Proc_GetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Column)
    Prototype Proc_SetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Value, Column)
    Prototype Proc_SetGadgetColor(*this.Gadget, ColorType, Color)
    Prototype Proc_GetGadgetColor(*this.Gadget, ColorType)
    Prototype Proc_SetGadgetItemColor2(*this.Gadget, Item, ColorType, Color, Column)
    Prototype Proc_GetGadgetItemColor2(*this.Gadget, Item, ColorType, Column)
    Prototype Proc_SetGadgetItemData(*this.Gadget, Item, Value)
    Prototype Proc_GetGadgetItemData(*this.Gadget, Item)
    Prototype Proc_GetRequiredSize(*this.Gadget, *Width.integer, *Height.integer)
    Prototype Proc_SetActiveGadget(*this.Gadget)
    Prototype Proc_GetGadgetFont(*this.Gadget)
    Prototype Proc_SetGadgetFont(*this.Gadget, hFont)
    Prototype Proc_SetGadgetItemImage(*this.Gadget, hImage)
  CompilerElse
    ;- PB Interne Prototypen Linux
    PrototypeC Proc_ActivateGadget(*this.Gadget)
    PrototypeC Proc_FreeGadget(*this.Gadget)
    PrototypeC Proc_GetGadgetState(*this.Gadget)
    PrototypeC Proc_SetGadgetState(*this.Gadget, State)
    PrototypeC Proc_GetGadgetText(*this.Gadget, PreviousStringPosition)
    PrototypeC Proc_SetGadgetText(*this.Gadget, Text)
    PrototypeC Proc_AddGadgetItem2(*this.Gadget, Position, *Text, *Image)
    PrototypeC Proc_AddGadgetItem3(*this.Gadget, Position, *Text, *Image, Flags)
    PrototypeC Proc_RemoveGadgetItem(*this.Gadget, Item)
    PrototypeC Proc_ClearGadgetItemList(*this.Gadget)
    PrototypeC Proc_ResizeGadget(*this.Gadget, x, y, width, height)
    PrototypeC Proc_CountGadgetItems(*this.Gadget)
    PrototypeC Proc_GetGadgetItemState(*this.Gadget, Item)
    PrototypeC Proc_SetGadgetItemState(*this.Gadget, Item, State)
    PrototypeC Proc_GetGadgetItemText(*this.Gadget, Item, Column, PreviousStringPosition)
    PrototypeC Proc_SetGadgetItemText(*this.Gadget, Item, *Text, Column)
    PrototypeC Proc_OpenGadgetList2(*this.Gadget, Item)
    PrototypeC Proc_GadgetX(*this.Gadget)
    PrototypeC Proc_GadgetY(*this.Gadget)
    PrototypeC Proc_GadgetWidth(*this.Gadget)
    PrototypeC Proc_GadgetHeight(*this.Gadget)
    PrototypeC Proc_HideGadget(*this.Gadget, State)
    PrototypeC Proc_AddGadgetColumn(*this.Gadget, Item, *Text, Column)
    PrototypeC Proc_RemoveGadgetColumn(*this.Gadget, Position)
    PrototypeC Proc_GetGadgetAttribute(*this.Gadget, Attribute)
    PrototypeC Proc_SetGadgetAttribute(*this.Gadget, Attribute, Value)
    PrototypeC Proc_GetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Column)
    PrototypeC Proc_SetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Value, Column)
    PrototypeC Proc_SetGadgetColor(*this.Gadget, ColorType, Color)
    PrototypeC Proc_GetGadgetColor(*this.Gadget, ColorType)
    PrototypeC Proc_SetGadgetItemColor2(*this.Gadget, Item, ColorType, Color, Column)
    PrototypeC Proc_GetGadgetItemColor2(*this.Gadget, Item, ColorType, Column)
    PrototypeC Proc_SetGadgetItemData(*this.Gadget, Item, Value)
    PrototypeC Proc_GetGadgetItemData(*this.Gadget, Item)
    PrototypeC Proc_GetRequiredSize(*this.Gadget, *Width.integer, *Height.integer)
    PrototypeC Proc_SetActiveGadget(*this.Gadget)
    PrototypeC Proc_GetGadgetFont(*this.Gadget)
    PrototypeC Proc_SetGadgetFont(*this.Gadget, hFont)
    PrototypeC Proc_SetGadgetItemImage(*this.Gadget, hImage)
  CompilerEndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ;- PB Interne Struktur GadgetVT Windows
    Structure GadgetVT
      GadgetType.l   
      SizeOf.l       
      GadgetCallback.Proc_Callback
      FreeGadget.Proc_FreeGadget
      GetGadgetState.Proc_GetGadgetState
      SetGadgetState.Proc_SetGadgetState
      GetGadgetText.Proc_GetGadgetText
      SetGadgetText.Proc_SetGadgetText
      AddGadgetItem2.Proc_AddGadgetItem2
      AddGadgetItem3.Proc_AddGadgetItem3
      RemoveGadgetItem.Proc_RemoveGadgetItem
      ClearGadgetItemList.Proc_ClearGadgetItemList
      ResizeGadget.Proc_ResizeGadget
      CountGadgetItems.Proc_CountGadgetItems
      GetGadgetItemState.Proc_GetGadgetItemState
      SetGadgetItemState.Proc_SetGadgetItemState
      GetGadgetItemText.Proc_GetGadgetItemText
      SetGadgetItemText.Proc_SetGadgetItemText
      OpenGadgetList2.Proc_OpenGadgetList2
      GadgetX.Proc_GadgetX
      GadgetY.Proc_GadgetY
      GadgetWidth.Proc_GadgetWidth
      GadgetHeight.Proc_GadgetHeight
      HideGadget.Proc_HideGadget
      AddGadgetColumn.Proc_AddGadgetColumn
      RemoveGadgetColumn.Proc_RemoveGadgetColumn
      GetGadgetAttribute.Proc_GetGadgetAttribute
      SetGadgetAttribute.Proc_SetGadgetAttribute
      GetGadgetItemAttribute2.Proc_GetGadgetItemAttribute2
      SetGadgetItemAttribute2.Proc_SetGadgetItemAttribute2
      SetGadgetColor.Proc_SetGadgetColor
      GetGadgetColor.Proc_GetGadgetColor
      SetGadgetItemColor2.Proc_SetGadgetItemColor2
      GetGadgetItemColor2.Proc_GetGadgetItemColor2
      SetGadgetItemData.Proc_SetGadgetItemData
      GetGadgetItemData.Proc_GetGadgetItemData
      GetRequiredSize.Proc_GetRequiredSize
      SetActiveGadget.Proc_SetActiveGadget
      GetGadgetFont.Proc_GetGadgetFont
      SetGadgetFont.Proc_SetGadgetFont
      SetGadgetItemImage.Proc_SetGadgetItemImage
    EndStructure
  CompilerElse
    ;- PB Interne Struktur GadgetVT Linux
    Structure GadgetVT
      SizeOf.l
      GadgetType.l
      ActivateGadget.Proc_ActivateGadget;
      FreeGadget.Proc_FreeGadget        ;
      GetGadgetState.Proc_GetGadgetState;
      SetGadgetState.Proc_SetGadgetState;
      GetGadgetText.Proc_GetGadgetText  ;
      SetGadgetText.Proc_SetGadgetText  ;
      AddGadgetItem2.Proc_AddGadgetItem2;
      AddGadgetItem3.Proc_AddGadgetItem3;
      RemoveGadgetItem.Proc_RemoveGadgetItem;
      ClearGadgetItemList.Proc_ClearGadgetItemList;
      ResizeGadget.Proc_ResizeGadget              ;
      CountGadgetItems.Proc_CountGadgetItems      ;
      GetGadgetItemState.Proc_GetGadgetItemState  ;
      SetGadgetItemState.Proc_SetGadgetItemState  ;
      GetGadgetItemText.Proc_GetGadgetItemText    ;
      SetGadgetItemText.Proc_SetGadgetItemText    ;
      SetGadgetFont.Proc_SetGadgetFont            ;
      OpenGadgetList2.Proc_OpenGadgetList2        ;
      AddGadgetColumn.Proc_AddGadgetColumn        ;
      GetGadgetAttribute.Proc_GetGadgetAttribute  ;
      SetGadgetAttribute.Proc_SetGadgetAttribute  ;
      GetGadgetItemAttribute2.Proc_GetGadgetItemAttribute2;
      SetGadgetItemAttribute2.Proc_SetGadgetItemAttribute2;
      RemoveGadgetColumn.Proc_RemoveGadgetColumn          ;
      SetGadgetColor.Proc_SetGadgetColor                  ;
      GetGadgetColor.Proc_GetGadgetColor                  ;
      SetGadgetItemColor2.Proc_SetGadgetItemColor2        ;
      GetGadgetItemColor2.Proc_GetGadgetItemColor2        ;
      SetGadgetItemData.Proc_SetGadgetItemData            ;
      GetGadgetItemData.Proc_GetGadgetItemData            ;
      GetGadgetFont.Proc_GetGadgetFont                    ;
      HideGadget.Proc_HideGadget                          ; Nicht bei Linux vorhanden, sondern bei MacOS
    EndStructure
  CompilerEndIf
  
  ;- Eigene interne Struktur MyGadgetVT
  Structure udtMyGadgetVT
    ; Basis
    vt.GadgetVT ; Virtuelle Funktionstabelle. Nicht Verschieben!
    *vt_org.GadgetVT  ; Orginal virtuelle Funktionstabelle
    id.i              ; Gadget PB_ID
                      ; Eigene Daten
    dx.i
    dy.i
    text.s
    flags.i
    state.i
    cstate.i
    style.i
    hFont.i
    frontcolor.i
    backcolor.i
    bordercolor.i
  EndStructure
  
  ;- Eigene interne Daten (Speicher)
  Global NewMap MyGadgetData.udtMyGadgetVT()
  
  ; -------------------------------------------------------------------------------------
  
  ;- PB Interne Funktionen (Proceduren)
  
  ; -------------------------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    
    Procedure Proc_GadgetCallback(*this.Gadget, Window, Message, wParam, lParam)
      
      Protected *MyGadgetVT.udtMyGadgetVT
      Protected result
      
      *MyGadgetVT = *this\vt
      
      ; Nicht geklärt!
      result = #PB_ProcessPureBasicEvents
      
      ; SKD: Result to 0, if you don't want the event to be populated to next handlers
      
      If *MyGadgetVT\vt_org\GadgetCallback
        result = *MyGadgetVT\vt_org\GadgetCallback(*this.Gadget, Window, Message, wParam, lParam)
      EndIf
      ProcedureReturn result;
      
    EndProcedure
    
    ; -------------------------------------------------------------------------------------
    
  CompilerElse
    
    ProcedureC Proc_ActivateGadget(*this.Gadget)
      
      Protected *MyGadgetVT.udtMyGadgetVT
      Protected result
      
      *MyGadgetVT = *this\vt
      
      If *MyGadgetVT\vt_org\ActivateGadget
        result = *MyGadgetVT\vt_org\ActivateGadget(*this.Gadget)
      EndIf
      ProcedureReturn result;
      
    EndProcedure
    
    ; -------------------------------------------------------------------------------------
    
  CompilerEndIf
  
  ; -------------------------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Procedure Proc_FreeGadget(*this.Gadget)
      CompilerElse ;EndIndent
    ProcedureC Proc_FreeGadget(*this.Gadget)
    CompilerEndIf 
    
    Protected *MyGadgetVT.udtMyGadgetVT, result
    
    ; Eigene Daten freigeben 
    *MyGadgetVT = *this\vt
    If *MyGadgetVT
      ; Code
      Debug "FreeGadget"
      
      ; Daten und Gadget freigeben
      result = FreeData(*this)
    EndIf
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Procedure Proc_GetGadgetState(*this.Gadget)
      CompilerElse ;EndIndent
    ProcedureC Proc_GetGadgetState(*this.Gadget)
    CompilerEndIf 
    
    Protected *MyGadgetVT.udtMyGadgetVT, result
    
    *MyGadgetVT = *this\vt
    If *MyGadgetVT
      ; Code
      result = *MyGadgetVT\state
    EndIf
    
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Procedure Proc_SetGadgetState(*this.Gadget, State)
      CompilerElse ;EndIndent
    ProcedureC Proc_SetGadgetState(*this.Gadget, State)
    CompilerEndIf 
    
    Protected *MyGadgetVT.udtMyGadgetVT, result
    
    *MyGadgetVT = *this\vt
    If *MyGadgetVT
      ; Code
      With *MyGadgetVT
        \state = State
      EndWith
      Draw(*MyGadgetVT)
    EndIf
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Procedure Proc_GetGadgetText(*this.Gadget, PreviousStringPosition)
      CompilerElse ;EndIndent
    ProcedureC Proc_GetGadgetText(*this.Gadget, PreviousStringPosition)
    CompilerEndIf 
    
    Protected *MyGadgetVT.udtMyGadgetVT, result
    
    Protected String.s
    Protected StringLength
    Protected *output.Character
    
    *MyGadgetVT = *this\vt
    If *MyGadgetVT
      String = *MyGadgetVT\text
      StringLength = Len(string)
      
      ; String zurückgeben
      *Output = SYS_GetOutputBuffer(StringLength, PreviousStringPosition)
      CopyMemory(@String, *output, StringLength * SizeOf(character))
      *output + StringLength * SizeOf(character)
      *output\c = 0
    EndIf
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Procedure Proc_SetGadgetText(*this.Gadget, *Text)
      CompilerElse ;EndIndent
    ProcedureC Proc_SetGadgetText(*this.Gadget, *Text)
    CompilerEndIf 
    
    Protected *MyGadgetVT.udtMyGadgetVT, result
    Protected ParameterIndex, String.s
    
    *MyGadgetVT = *this\vt
    If *MyGadgetVT
      ; Get the index of the parameter in the internal buffer (will Return 0 If it's not in the internal buffer)
      ParameterIndex = SYS_GetParameterIndex(*Text)
      If ParameterIndex
        ; Get back the string pointer only if it was on the internal buffer
        *Text = SYS_ResolveParameter(ParameterIndex)
      EndIf
      ; Anpassung Linux
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        String = PeekS(*Text)
        CompilerElse ;EndIndent
      String = PeekS(*Text,-1, #PB_UTF8)
    CompilerEndIf
    
    *MyGadgetVT\text = String
    Draw(*MyGadgetVT)
  EndIf
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_AddGadgetItem2(*this.Gadget, Position, *Text, *Image)
    CompilerElse ;EndIndent
  ProcedureC Proc_AddGadgetItem2(*this.Gadget, Position, *Text, *Image)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_AddGadgetItem3(*this.Gadget, Position, *Text, *Image, Flags)
    CompilerElse ;EndIndent
  ProcedureC Proc_AddGadgetItem3(*this.Gadget, Position, *Text, *Image, Flags)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_RemoveGadgetItem(*this.Gadget, Item)
    CompilerElse ;EndIndent
  ProcedureC Proc_RemoveGadgetItem(*this.Gadget, Item)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_ClearGadgetItemList(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_ClearGadgetItemList(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_ResizeGadget(*this.Gadget, x.l, y.l, width.l, height.l)
    CompilerElse ;EndIndent
  ProcedureC Proc_ResizeGadget(*this.Gadget, x.l, y.l, width.l, height.l)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
    ; Orginale Funktion aufrufen
    If *MyGadgetVT\vt_org\ResizeGadget
      result =*MyGadgetVT\vt_org\ResizeGadget(*this.Gadget, x, y, width, height)
    EndIf
    
    ; Neu zeichnen
    If width <> #PB_Ignore
      *MyGadgetVT\dx = width
    EndIf
    If height <> #PB_Ignore
      *MyGadgetVT\dy = height
    EndIf
    Draw(*MyGadgetVT)
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_CountGadgetItems(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_CountGadgetItems(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetItemState(*this.Gadget, Item)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetGadgetItemState(*this.Gadget, Item)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetItemState(*this.Gadget, Item, State)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetItemState(*this.Gadget, Item, State)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetItemText(*this.Gadget, Item, Column, PreviousStringPosition)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetGadgetItemText(*this.Gadget, Item, Column, PreviousStringPosition)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  Protected String.s
  Protected StringLength
  Protected *output.Character
  
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    String = "Colum " + Str(Column)
    StringLength = Len(string)
    
    ; String zurückgeben
    *Output = SYS_GetOutputBuffer(StringLength, PreviousStringPosition)
    CopyMemory(@String, *output, StringLength)
    *output + StringLength * SizeOf(character)
    *output\c = 0
  EndIf
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetItemText(*this.Gadget, Item, *Text, Column)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetItemText(*this.Gadget, Item, *Text, Column)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  Protected ParameterIndex, String.s
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Get the index of the parameter in the internal buffer (will Return 0 If it's not in the internal buffer)
    ParameterIndex = SYS_GetParameterIndex(*Text)
    If ParameterIndex
      ; Get back the string pointer only if it was on the internal buffer
      *Text = SYS_ResolveParameter(ParameterIndex)
    EndIf
    ; Anpassung Linux
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      String = PeekS(*Text)
      CompilerElse ;EndIndent
    String = PeekS(*Text,-1, #PB_UTF8)
  CompilerEndIf
  
  ; Code
  
EndIf
ProcedureReturn result

EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_OpenGadgetList2(*this.Gadget, Item)
    CompilerElse ;EndIndent
  ProcedureC Proc_OpenGadgetList2(*this.Gadget, Item)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GadgetX(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_GadgetX(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GadgetY(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_GadgetY(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GadgetWidth(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_GadgetWidth(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GadgetHeight(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_GadgetHeight(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_HideGadget(*this.Gadget, State)
    CompilerElse ;EndIndent
  ProcedureC Proc_HideGadget(*this.Gadget, State)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    Debug "HideGadget " + Str(State)
    
    ; Orginal HideGadget aufrufen
    CompilerIf #PB_Compiler_OS <> #PB_OS_Linux
      If *MyGadgetVT\vt_org\HideGadget
        result = *MyGadgetVT\vt_org\HideGadget(*this, State)
      EndIf
    CompilerEndIf
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_AddGadgetColumn(*this.Gadget, Item, *Text, Column)
    CompilerElse ;EndIndent
  ProcedureC Proc_AddGadgetColumn(*this.Gadget, Item, *Text, Column)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_RemoveGadgetColumn(*this.Gadget, Position)
    CompilerElse;EndIndent
  ProcedureC Proc_RemoveGadgetColumn(*this.Gadget, Position)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetAttribute(*this.Gadget, Attribute)
    CompilerElse;EndIndent
  ProcedureC Proc_GetGadgetAttribute(*this.Gadget, Attribute)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    If Attribute < 1024 ; CanvasGadget Attribute
      If *MyGadgetVT\vt_org\GetGadgetAttribute
        result = *MyGadgetVT\vt_org\GetGadgetAttribute(*this, Attribute)
      EndIf
    Else ; User Attribute ab 1024
      
    EndIf
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetAttribute(*this.Gadget, Attribute, Value)
    CompilerElse;EndIndent
  ProcedureC Proc_SetGadgetAttribute(*this.Gadget, Attribute, Value)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    If Attribute < 1024 ; CanvasGadget Attribute
      If *MyGadgetVT\vt_org\GetGadgetAttribute
        result = *MyGadgetVT\vt_org\SetGadgetAttribute(*this, Attribute, Value)
      EndIf
    Else ; User Attribute ab 1024
      
    EndIf
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Column)
    CompilerElse;EndIndent
  ProcedureC Proc_GetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Column)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Value, Column)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetItemAttribute2(*this.Gadget, Item, Attribute, Value, Column)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetColor(*this.Gadget, ColorType, Color)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetColor(*this.Gadget, ColorType, Color)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    Select ColorType
      Case #PB_Gadget_BackColor
        *MyGadgetVT\backcolor = Color
        Draw(*MyGadgetVT)
      Case #PB_Gadget_FrontColor
        *MyGadgetVT\frontcolor = Color
        Draw(*MyGadgetVT)
      Case #PB_Gadget_LineColor
        *MyGadgetVT\bordercolor = Color
        Draw(*MyGadgetVT)
    EndSelect
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetColor(*this.Gadget, ColorType)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetGadgetColor(*this.Gadget, ColorType)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    Select ColorType
      Case #PB_Gadget_BackColor
        result = *MyGadgetVT\backcolor
      Case #PB_Gadget_FrontColor
        result = *MyGadgetVT\frontcolor
      Case #PB_Gadget_LineColor
        result = *MyGadgetVT\bordercolor
        
    EndSelect
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetItemColor2(*this.Gadget, Item, ColorType, Color, Column)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetItemColor2(*this.Gadget, Item, ColorType, Color, Column)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetItemColor2(*this.Gadget, Item, ColorType, Column)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetGadgetItemColor2(*this.Gadget, Item, ColorType, Column)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetItemData(*this.Gadget, Item, Value)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetItemData(*this.Gadget, Item, Value)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetItemData(*this.Gadget, Item)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetGadgetItemData(*this.Gadget, Item)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetRequiredSize(*this.Gadget, *Width.integer, *Height.integer)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetRequiredSize(*this.Gadget, *Width.integer, *Height.integer)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetActiveGadget(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetActiveGadget(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_GetGadgetFont(*this.Gadget)
    CompilerElse ;EndIndent
  ProcedureC Proc_GetGadgetFont(*this.Gadget)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    result = *MyGadgetVT\hFont
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetFont(*this.Gadget, hFont)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetFont(*this.Gadget, hFont)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    If hFont
      *MyGadgetVT\hFont = hFont
    Else
      *MyGadgetVT\hFont = #PB_Default
    EndIf
    Draw(*MyGadgetVT)
  EndIf
  ProcedureReturn result
  
EndProcedure

; -------------------------------------------------------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure Proc_SetGadgetItemImage(*this.Gadget, hImage)
    CompilerElse ;EndIndent
  ProcedureC Proc_SetGadgetItemImage(*this.Gadget, hImage)
  CompilerEndIf 
  
  Protected *MyGadgetVT.udtMyGadgetVT, result
  
  *MyGadgetVT = *this\vt
  If *MyGadgetVT
    ; Code
    
  EndIf
  ProcedureReturn result
  
EndProcedure

; *************************************************************************************

;- Datenverwaltung

Procedure NewData(*this.gadget)
  
  Protected *MyGadgetVT.udtMyGadgetVT, key.s
  
  key = "ID-" + Str(*this\Gadget)
  *MyGadgetVT = AddMapElement(MyGadgetData(), key)
  If *MyGadgetVT
    ; ----------------------------------------------------------
    ; Orginale Funktionstabelle kopieren
    CopyMemory(*this\vt, *MyGadgetVT\vt, SizeOf(GadgetVT))
    With *MyGadgetVT\vt
      ; Eigene Funktion FreeGadget eintragen, WIRD IMMER GEBRAUCHT
      \FreeGadget = @Proc_FreeGadget()
      
      ; Eigene Funktionen hinzufügen/umleiten
      \GetGadgetState = @Proc_GetGadgetState()
      \SetGadgetState = @Proc_SetGadgetState()
      \GetGadgetText = @Proc_GetGadgetText()
      \SetGadgetText = @Proc_SetGadgetText()
      \ResizeGadget = @Proc_ResizeGadget()
      \GetGadgetColor = @Proc_GetGadgetColor()
      \SetGadgetColor = @Proc_SetGadgetColor()
      \GetGadgetFont = @Proc_GetGadgetFont()
      \SetGadgetFont = @Proc_SetGadgetFont()
      ; ...
    EndWith
    ; ----------------------------------------------------------
    
    ; Orginale Funktionentabelle sichern
    *MyGadgetVT\vt_org = *this\vt
    ; Orginale Funktionentabelle ersetzen
    *this\vt = *MyGadgetVT
    
  EndIf
  
  ProcedureReturn *MyGadgetVT
  
EndProcedure

; -------------------------------------------------------------------------------------

Procedure FreeData(*this.gadget)
  
  Protected result, *MyGadgetVT.udtMyGadgetVT, key.s
  
  key = "ID-" + Str(*this\Gadget)
  *MyGadgetVT = FindMapElement(MyGadgetData(), key)
  If *MyGadgetVT
    ; Orginal FreeGadget aufrufen
    If *MyGadgetVT\vt_org\FreeGadget
      *MyGadgetVT\vt_org\FreeGadget(*this)
    EndIf
    ; Orginale Funktionstabelle wiederherstellen
    *this\vt = *MyGadgetVT\vt_org
    ; Eigene Daten löschen
    DeleteMapElement(MyGadgetData())
  EndIf
  ProcedureReturn result
  
EndProcedure

; *************************************************************************************

;- Interne Funktionen

Procedure DrawTextBox(x, y, dx, dy, text.s, flags)
  
  Protected is_multiline, is_left, is_right
  Protected text_width, text_height
  Protected text_x, text_y
  Protected rows , row_text.s, row_text1.s, start, count
  
  is_multiline = flags & #PB_Button_MultiLine
  is_left = flags & #PB_Button_Left
  is_right = flags & #PB_Button_Right
  
  text_width = TextWidth(text)
  text_height = TextHeight(text)
  
  If Not is_multiline
    If is_left
      text_x = 6
      text_y = dy / 2 - text_height / 2
    ElseIf is_right
      text_x = dx - text_width - 6
      text_y = dy / 2 - text_height / 2
    Else
      text_x = dx / 2 - text_width / 2
      text_y = dy / 2 - text_height / 2
    EndIf
    DrawText(x + text_x, y + text_y, text)
    ProcedureReturn 1
  EndIf
  
  rows = text_width / dx
  start = 1
  text_y = (dy / 2 - text_height / 2) - (text_height / 2 * rows)
  count = CountString(text, " ") + 1
  Repeat
    row_text = StringField(text, start, " ") + " "
    Repeat
      start + 1
      row_text1 = StringField(text, start, " ")
      If TextWidth(row_text + row_text1) < dx - 12
        row_text + row_text1 + " "
      Else
        Break
      EndIf
    Until start > count
    row_text = Trim(row_text)
    If is_left
      text_x = 6
    ElseIf is_right
      text_x = dx - TextWidth(row_text) - 6
    Else
      text_x = dx / 2 - TextWidth(row_text) / 2
    EndIf
    DrawText(x + text_x, y + text_y, row_text)
    text_y + text_height
  Until start > count
  
EndProcedure

; -------------------------------------------------------------------------------------

Procedure Draw(*MyGadgetVT.udtMyGadgetVT)
  
  Protected backcolor, backcolor2, bordercolor2
  Protected dx, dy
  Protected text_width, text_height
  Protected text_x, text_y
  
  With *MyGadgetVT
    
    If \cstate = #ButtonColorStateDown Or \state = 1
      backcolor = RGB(Red(\backcolor) * 85 / 100, Green(\backcolor) * 85 / 100, Blue(\backcolor) * 85 / 100)
      bordercolor2 = $00C0C0C0
    ElseIf \cstate = #ButtonColorStateOver
      backcolor = RGB(Red(\backcolor) * 95 / 100, Green(\backcolor) * 95 / 100, Blue(\backcolor) * 95 / 100)
      bordercolor2 = $00FFFFFF
    Else
      backcolor = \backcolor
      bordercolor2 = $00FFFFFF
    EndIf
    StartDrawing(CanvasOutput(\id))
    If \dx > 2 And \dy > 2
      If \style
        ; Style Windows 8
        Box(0, 0, \dx, \dy, \bordercolor)
        Box(1, 1, \dx - 2, \dy - 2, backColor)
      Else
        ; Style Windows 7
        backcolor2 = RGB(Red(backcolor) * 95 / 100, Green(backcolor) * 95 / 100, Blue(backcolor) * 95 / 100)
        Box(0, 0, \dx, \dy, \bordercolor)
        Box(1, 1, \dx - 2, \dy - 2, bordercolor2)
        dx = \dx - 4
        dy = (\dy - 4) / 2
        Box(2, 2, dx, dy, backColor)
        Box(2, 2 + dy, dx, dy, backcolor2)
        Plot(0, 0, $00FFFFFF) : Plot(\dx - 1, 0, $00FFFFFF) : Plot(0 ,\dy - 1, $00FFFFFF) : Plot(\dx - 1,\dy - 1, $00FFFFFF)
        Plot(1, 1, \bordercolor) : Plot(\dx - 2, 1, \bordercolor) : Plot(1 ,\dy - 2, \bordercolor) : Plot(\dx - 2,\dy - 2, \bordercolor)
        Plot(2, 2, bordercolor2) : Plot(\dx - 3, 2, bordercolor2) : Plot(2 ,\dy - 3, bordercolor2) : Plot(\dx - 3,\dy - 3, bordercolor2)
      EndIf
      DrawingFont(\hFont)
      DrawingMode(#PB_2DDrawing_Transparent)
      FrontColor(\frontcolor)
      DrawTextBox(0, 0, \dx, \dy, \text, \flags)
    Else
      Box(0, 0, \dx, \dy, $00808080)
    EndIf
    StopDrawing() 
    
  EndWith
  
EndProcedure

; -------------------------------------------------------------------------------------

Procedure EventHandler()
  
  Protected *Gadget.Gadget, *MyGagetVT.udtMyGadgetVT
  
  *Gadget = IsGadget(EventGadget())
  If *Gadget
    *MyGagetVT = *Gadget\vt
    With *MyGagetVT
      Select EventType()
        Case #PB_EventType_MouseMove
          If \cstate = #ButtonColorStateDefault
            \cstate = #ButtonColorStateOver
            Draw(*MyGagetVT)
          EndIf
        Case #PB_EventType_MouseLeave
          \cstate = #ButtonColorStateDefault
          Draw(*MyGagetVT)
        Case #PB_EventType_LeftButtonDown
          \cstate = #ButtonColorStateDown
          Draw(*MyGagetVT)
        Case #PB_EventType_LeftButtonUp
          \cstate = #ButtonColorStateOver
          Draw(*MyGagetVT)
        Case #PB_EventType_LeftClick
          If \flags & #PB_Button_Toggle = #PB_Button_Toggle
            If \state
              \state = 0
            Else
              \state = 1
            EndIf
            Draw(*MyGagetVT)
          EndIf
      EndSelect
      
    EndWith
  EndIf
  
EndProcedure

; *************************************************************************************

;- Public Funktionen

Procedure Create(id, x, y, dx, dy, text.s, flags = #PB_Button_Default)
  
  Protected result, nr, *Gadget.Gadget, *MyGadgetVT.udtMyGadgetVT
  
  Repeat
    ; Gadget anlegen
    result = CanvasGadget(id, x, y , dx, dy)
    If result = 0
      Break
    EndIf
    If id = #PB_Any
      nr = result
    Else
      nr = id
    EndIf
    *Gadget = IsGadget(nr)
    ;*Gadget = PB_Object_GetObject(PB_Gadget_Objects, nr)
    If *Gadget
      ; Eigene Daten anlegen
      *MyGadgetVT = NewData(*Gadget)
      If *MyGadgetVT = 0
        FreeGadget(nr)
        Break
      EndIf
      *MyGadgetVT\id = nr
      With *MyGadgetVT
        ; Eigene Daten zuweisen
        \dx = dx
        \dy = dy
        \text = text
        \flags = flags
        \state = 0
        \cstate = #ButtonColorStateDefault
        \hFont = GetGadgetFont(#PB_Default)
        \frontcolor = $00000000
        \backcolor = $00F0F0F0
        \bordercolor = $00808080
        If OSVersion() >= #PB_OS_Windows_8 And OSVersion() <= #PB_OS_Windows_Future
          \style = 1
        Else
          \style = 0
        EndIf
      EndWith
      ; Zeichnen
      Draw(*MyGadgetVT)
      
      ; Eventhandler setzen
      BindGadgetEvent(nr, @EventHandler(), #PB_All)
      
    Else
      result = 0
      Break
    EndIf
  Until #True
  
  ProcedureReturn result
  
EndProcedure


EndModule

; ***************************************************************************************

;- Example

CompilerIf #PB_Compiler_IsMainFile
  
  ;- Konstanten
  Enumeration ; Window ID
    #Window
  EndEnumeration
  
  Enumeration ; Menu ID
    #Menu
  EndEnumeration
  
  Enumeration ; MenuItem ID
    #Menu_Exit
  EndEnumeration
  
  Enumeration ; Statusbar ID
    #Statusbar
  EndEnumeration
  
  Enumeration ; Gadget ID
    
  EndEnumeration
  
  ; ***************************************************************************************
  
  ;- Globale Variablen
  Global exit = 0
  
  Macro ButtonGadget(Gadget, x, y, Width, Height, Text, Flags = #PB_Button_Default)
    ButtonColorGadget::Create(Gadget, x, y, Width, Height, Text, Flags)
  EndMacro
  
  ;- Fenster
  style = #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
  If OpenWindow(#Window, #PB_Ignore, #PB_Ignore, 500, 400, "Fenster", style)
    ; Menu
    If CreateMenu(#Menu, WindowID(#Window))
      MenuTitle("&Datei")
      MenuItem(#Menu_Exit, "Be&enden")
    EndIf
    ; Statusbar
    CreateStatusBar(#Statusbar, WindowID(#Window))
    ; Gadgets
    
    LoadFont(0, "Arial", 16)
    
    ButtonColorGadget::Create(0, 10 ,10, 200, 40, "Button 1", #PB_Button_Left)
    
    ButtonColorGadget::Create(1, 10 ,60, 200, 40, "Button 2", #PB_Button_MultiLine)
    SetGadgetColor(1, #PB_Gadget_BackColor, $00FF4040)
    SetGadgetColor(1, #PB_Gadget_FrontColor, $00FFFFFF)
    
    SetGadgetFont(1, FontID(0))
    
    ; Durch macro ersetzt
    ButtonGadget(2, 10, 180, 200, 40, "Button 3", #PB_Button_Toggle | #PB_Button_Right)
    SetGadgetColor(2, #PB_Gadget_BackColor, $000000FF)
    
    ResizeGadget(1, 10, 80, 200, 80)
    SetGadgetText(1, "Hello World! Button multiline")
    Debug "Button (" + GetGadgetText(1) + ")"
    
    ;-- Hauptschleife
    Repeat
      event   = WaitWindowEvent()
      Select event
        Case #PB_Event_Menu
          Select menu
            Case #Menu_Exit
              Exit = 1
          EndSelect
        Case #PB_Event_Gadget
          Select EventGadget()
            Case 0
              If EventType() = #PB_EventType_LeftClick
                Debug "Button 1"
              EndIf
            Case 1
              If EventType() = #PB_EventType_LeftClick
                Debug "Button 2"
              EndIf
            Case 2
              If EventType() = #PB_EventType_LeftClick
                Debug "Button 3 State " + Str(GetGadgetState(2))
              EndIf
              
          EndSelect
          
          
        Case #PB_Event_CloseWindow
          Exit = 1
          
      EndSelect
      
    Until Exit
  EndIf
  
  CloseWindow(#Window)
  
CompilerEndIf
