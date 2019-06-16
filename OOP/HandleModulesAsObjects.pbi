;   Description: Add support to handle modules as OOP-objects
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=64305
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29343
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015-2019 mk-soft
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

;-Begin Module BaseClass Small Version

; Comment : Module as Object
; Author  : mk-soft
; Version : v1.13
; Created : 16.08.2017
; Updated : 03.05.2019
; Link GE : http://www.purebasic.fr/german/viewtopic.php?f=8&t=29343
; Link EN : http://www.purebasic.fr/english/viewtopic.php?f=12&t=64305

; OS      : All
; License : MIT

; ***************************************************************************************

DeclareModule BaseClass
 
  ; ---------------------------------------------------------------------------
 
  ; Internal class declaration
 
  Prototype ProtoInvoke(*This)
 
  Structure udtInvoke
    *Invoke.ProtoInvoke
  EndStructure
 
  Structure udtClass
    Array *vTable(3)
    Array Initialize.udtInvoke(0)
    Array Dispose.udtInvoke(0)
  EndStructure
 
  ; ---------------------------------------------------------------------------
 
  ; BaseClass declaration
 
  Structure sBaseSystem
    *vTable
    *Self.udtClass
    RefCount.i
    Mutex.i
  EndStructure
 
  ; Public Structure
  Structure sBaseClass
    System.sBaseSystem
  EndStructure
 
  ; Public Interface
  Interface iBaseClass
    QueryInterface(*riid, *addr)
    AddRef()
    Release()
  EndInterface
 
  ; ---------------------------------------------------------------------------
 
  Macro dq
    "
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Added New Class
  Declare AddClass(ClassName.s, ClassExtends.s, Size) ; Internal
 
  Macro NewClass(ClassInterface, ClassExtends=)
    ; Interface helper
    Interface __Interface Extends ClassInterface
    EndInterface
    ; Internal class pointer
    Global *__Class.udtClass
    ; Add new class
    Procedure __NewClass()
      *__Class = AddClass(dq#ClassInterface#dq, dq#ClassExtends#dq, SizeOf(ClassInterface) / SizeOf(integer))
    EndProcedure : __NewClass()
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Macro for init object (short)
  Macro InitObject(sProperty)
    Protected *Object.sProperty, __cnt, __index
    *Object = AllocateStructure(sProperty)
    If *Object
      *Object\System\vTable = *__Class\vTable()
      *Object\System\Self = *__Class
      *Object\System\RefCount = 0
      *Object\System\Mutex = CreateMutex()
      __cnt = ArraySize(*Object\System\Self\Initialize())
      For __index = 1 To __cnt
        *Object\System\Self\Initialize(__index)\Invoke(*Object)
      Next
    EndIf
    ProcedureReturn *Object
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Macros for init object (advanced)
  Macro AllocateObject(Object, sProperty)
    Object = AllocateStructure(sProperty)
    If Object
      Object\System\vTable = *__Class\vTable()
      Object\System\Self = *__Class
      Object\System\RefCount = 0
      Object\System\Mutex = CreateMutex()
    EndIf
  EndMacro
 
  Macro InitializeObject(Object)
    If Object
      Protected __cnt, __index
      __cnt = ArraySize(Object\System\Self\Initialize())
      For __index = 1 To __cnt
        Object\System\Self\Initialize(__index)\Invoke(Object)
      Next
    EndIf
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Macros for clone object
  Macro CloneObject(This, Clone, sProperty)
    Clone = AllocateStructure(sProperty)
    If Clone
      CopyStructure(This, Clone, sProperty)
      Clone\System\RefCount = 0
      Clone\System\Mutex = CreateMutex()
    EndIf
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  Macro LockObject(This)
    LockMutex(This\System\Mutex)
  EndMacro
 
  Macro UnlockObject(This)
    UnlockMutex(This\System\Mutex)
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Macros to defined Initialize, Dispose, Methods
 
  ; Add Procedure as Initialize Object
  Macro AsInitializeObject(Name)
    Procedure __AddInitializeObject#Name()
      Protected index
      index = ArraySize(*__Class\Initialize()) + 1
      ReDim *__Class\Initialize(index)
      *__Class\Initialize(index)\Invoke = @Name()
    EndProcedure : __AddInitializeObject#Name()
  EndMacro
 
  ; Add Procedure as Dispose Object
  Macro AsDisposeObject(Name)
    Procedure __AddDisposeObject#Name()
      Protected index
      index = ArraySize(*__Class\Dispose()) + 1
      ReDim *__Class\Dispose(index)
      *__Class\Dispose(index)\Invoke = @Name()
    EndProcedure : __AddDisposeObject#Name()
  EndMacro
 
  ; Add Procedure as Method or Overwrite inheritance method
  Macro AsMethod(Name)
    Procedure __AddMethod#Name()
      *__Class\vTable(OffsetOf(__Interface\Name()) / SizeOf(integer)) = @Name()
    EndProcedure : __AddMethod#Name()
  EndMacro
 
  Macro AsNewMethod(Name)
    AsMethod(Name)
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Debugger functions
 
  Macro CheckInterface()
    CompilerIf #PB_Compiler_Debugger
      Procedure __CheckInterface()
        Protected *xml, *node, ErrorCount
        *xml = CreateXML(#PB_Any)
        If *xml
          *node = InsertXMLStructure(RootXMLNode(*xml), *__Class\vTable(), __Interface)
          *node = ChildXMLNode(*node)
          Repeat
            If Not *node
              Break
            EndIf
            If GetXMLNodeText(*node) = "0"
              ErrorCount + 1
              Debug "Module " + #PB_Compiler_Module + ": Error Interface - Missing Method '" + GetXMLNodeName(*node) + "()'"
            EndIf
            *node = NextXMLNode(*node)
          ForEver
          FreeXML(*xml)
          If ErrorCount
            Debug "Module " + #PB_Compiler_Module + ": Error Count " + ErrorCount
            CallDebugger
          EndIf
        EndIf
      EndProcedure : __CheckInterFace()
    CompilerEndIf
  EndMacro

; ---------------------------------------------------------------------------

EndDeclareModule

Module BaseClass
 
  EnableExplicit
 
  Procedure InitBaseClass()
    Global NewMap Class.udtClass()
  EndProcedure : InitBaseClass()
   
  ; ---------------------------------------------------------------------------
 
  Procedure QueryInterface(*This.sBaseClass, *riid, *addr)
    ProcedureReturn $80004002 ; (#E_NOINTERFACE)
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  Procedure AddRef(*This.sBaseClass)
    LockMutex(*This\System\Mutex)
    *This\System\RefCount + 1
    UnlockMutex(*This\System\Mutex)
    ProcedureReturn *This\System\RefCount
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  Procedure Release(*This.sBaseClass)
    Protected index, cnt
    With *This\System
      LockMutex(*This\System\Mutex)
      If \RefCount = 0
        cnt = ArraySize(\Self\Dispose())
        For index = cnt To 1 Step -1
          \Self\Dispose(index)\Invoke(*This)
        Next
        FreeMutex(*This\System\Mutex)
        FreeStructure(*This)
        ProcedureReturn 0
      Else
        \RefCount - 1
      EndIf
      UnlockMutex(*This\System\Mutex)
      ProcedureReturn \RefCount
    EndWith
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  Procedure AddClass(ClassName.s, ClassExtends.s, Size)
    Protected *class.udtClass, *extends.udtClass, sClassName.s, sClassExtends.s
    sClassName = LCase(ClassName)
    sClassExtends = LCase(ClassExtends)
    CompilerIf #PB_Compiler_Debugger
      If FindMapElement(Class(), sClassName)
        Debug "Error: Class '" + ClassName + "' already exists!"
        CallDebugger
        End -1
      EndIf
      If Bool(sClassExtends)
        *extends = FindMapElement(Class(), sClassExtends)
        If Not *extends
          Debug "Error: Extends Class '" + ClassExtends + "' not exists!"
          CallDebugger
          End -1
        EndIf
      EndIf
    CompilerEndIf
    *class = AddMapElement(Class(), sClassName)
    If *class
      If Bool(sClassExtends)
        *extends = FindMapElement(Class(), sClassExtends)
        CopyStructure(*extends, *class, udtClass)
        ReDim *class\vTable(Size)
        ProcedureReturn *class
      Else
        ReDim *class\vTable(Size)
        *class\vTable(0) = @QueryInterface()
        *class\vTable(1) = @AddRef()
        *class\vTable(2) = @Release()
        ProcedureReturn *class
      EndIf
    Else
      Debug "Error: Class '" + ClassName + "' Out Of Memory!"
      CallDebugger
      End -1
    EndIf
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
EndModule

;- End Module BaseClass

; ***************************************************************************************
