;   Description: Add support to handle modules as OOP-objects
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=64305
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29343
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015-2017 mk-soft
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

 ;-Begin Module BaseClass

; Comment : Module as Object
; Author  : mk-soft
; Version : v1.33
; Created : 13.12.2015
; Updated : 21.12.2017
; Link GE : http://www.purebasic.fr/german/viewtopic.php?f=8&t=29343
; Link EN : http://www.purebasic.fr/english/viewtopic.php?f=12&t=64305

; OS      : All
; License : MIT

; ***************************************************************************************

DeclareModule BaseClass
 
  ; ---------------------------------------------------------------------------
 
  ; Internal Class Manager
 
  Prototype ProtoInvoke(*This)
 
  Structure udtInvoke
    *Invoke.ProtoInvoke
  EndStructure
 
  Structure udtClass
    Array *vTable(3)
    Map vMethodeID.i()
    Array Initialize.udtInvoke(0)
    Array Dispose.udtInvoke(0)
  EndStructure
 
  Structure udtClasses
    Map Entry.udtClass()
    ObjectCounter.i
    Mutex.i
  EndStructure
 
  Global Class.udtClasses
 
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
 
  Macro NewClass(ClassInterface, ClassExtends=BaseClass)
    ; Interface helper
    Interface __Interface Extends ClassInterface
    EndInterface
    ; Add new class
    AddClass(#PB_Compiler_Module, dq#ClassExtends#dq, SizeOf(__Interface) / SizeOf(integer))
  EndMacro
 
 
  ; ---------------------------------------------------------------------------
 
  ; Macro for init object (short)
  Macro InitObject(sProperty)
    Protected *Object.sProperty, __cnt, __index
    *Object = AllocateStructure(sProperty)
    If *Object
      LockMutex(Class\Mutex)
      Class\ObjectCounter + 1
      UnlockMutex(Class\Mutex)
      *Object\System\vTable = Class\Entry(#PB_Compiler_Module)\vTable()
      *Object\System\Self = @Class\Entry(#PB_Compiler_Module)
      *Object\System\RefCount = 0
      *Object\System\Mutex = CreateMutex()
      If Not *Object\System\Mutex
        Debug "Error: CreateMutex Class '" + #PB_Compiler_Module + "'!"
        FreeStructure(*Object)
        *Object = 0
        LockMutex(Class\Mutex)
        Class\ObjectCounter - 1
        UnlockMutex(Class\Mutex)
      Else
        __cnt = ArraySize(*Object\System\Self\Initialize())
        For __index = 1 To __cnt
          *Object\System\Self\Initialize(__index)\Invoke(*Object)
        Next
      EndIf
    EndIf
    ProcedureReturn *Object
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Macros for init object (advanced)
  Macro AllocateObject(Object, sProperty)
    Object = AllocateStructure(sProperty)
    If Object
      LockMutex(Class\Mutex)
      Class\ObjectCounter + 1
      UnlockMutex(Class\Mutex)
      Object\System\vTable = Class\Entry(#PB_Compiler_Module)\vTable()
      Object\System\Self = @Class\Entry(#PB_Compiler_Module)
      Object\System\RefCount = 0
      Object\System\Mutex = CreateMutex()
      If Not Object\System\Mutex
        Debug "Error: CreateMutex Class '" + #PB_Compiler_Module + "'!"
        FreeStructure(Object)
        Object = 0
        LockMutex(Class\Mutex)
        Class\ObjectCounter - 1
        UnlockMutex(Class\Mutex)
      EndIf
    EndIf
  EndMacro
 
  Macro InitializeObject(Object, sProperty=)
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
      If Not Clone\System\Mutex
        Debug "Error: CreateMutex Class '" + #PB_Compiler_Module + "'!"
        FreeStructure(Clone)
        Clone = 0
      EndIf
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
      If FindMapElement(Class\Entry(), #PB_Compiler_Module)
        index = ArraySize(Class\Entry()\Initialize()) + 1
        ReDim Class\Entry()\Initialize(index)
        Class\Entry()\Initialize(index)\Invoke = @Name()
      Else
        Debug "Error: Class is not initialized. Module '" + #PB_Compiler_Module + "'!"
        CallDebugger
      EndIf
    EndProcedure : __AddInitializeObject#Name()
  EndMacro
 
  ; Add Procedure as Dispose Object
  Macro AsDisposeObject(Name)
    Procedure __AddDisposeObject#Name()
      Protected index
      If FindMapElement(Class\Entry(), #PB_Compiler_Module)
        index = ArraySize(Class\Entry()\Dispose()) + 1
        ReDim Class\Entry()\Dispose(index)
        Class\Entry()\Dispose(index)\Invoke = @Name()
      Else
        Debug "Error: Class is not initialized. Module '" + #PB_Compiler_Module + "'!"
        CallDebugger
      EndIf
    EndProcedure : __AddDisposeObject#Name()
  EndMacro
 
  ; Add Procedure as Methode
  Macro AsMethode(Name)
    Procedure __AddMethode#Name()
      Protected MethodeID
      If FindMapElement(Class\Entry(), #PB_Compiler_Module)
        MethodeID = OffsetOf(__Interface\Name()) / SizeOf(integer)
        Class\Entry()\vTable(MethodeID) = @Name()
        Class\Entry()\vMethodeID(dq#Name#dq) = MethodeID
      Else
        Debug "Error: Class is not initialized. Module '" + #PB_Compiler_Module + "'!"
        CallDebugger
      EndIf
    EndProcedure : __AddMethode#Name()
  EndMacro
 
  ; Overwrite inheritance methode
  Macro AsNewMethode(Name)
    Procedure __OverwriteMethode#Name()
      Protected MethodeID
      If FindMapElement(Class\Entry(#PB_Compiler_Module)\vMethodeID(), dq#Name#dq)
        MethodeID = Class\Entry()\vMethodeID()
        Class\Entry()\vTable(MethodeID) = @Name()
      Else
        Debug "Error: Method in the inherited class not found. [" + dq#name#dq + "()]"
        CallDebugger
      EndIf
    EndProcedure : __OverwriteMethode#Name()
  EndMacro
 
  ; ---------------------------------------------------------------------------
 
  ; Debugger functions
 
  Macro ShowInterface(ClassName=#PB_Compiler_Module)
    CompilerIf #PB_Compiler_Debugger
      Define __index
      Debug "Interface " + ClassName
      Debug "{"
      If FindMapElement(BaseClass::Class\Entry(), ClassName)
        For __index = 0 To ArraySize(BaseClass::Class\Entry()\vTable()) - 1
          ForEach BaseClass::Class\Entry()\vMethodeID()
            If BaseClass::Class\Entry()\vMethodeID() = __index
              Debug " - MethodeID " + BaseClass::Class\Entry()\vMethodeID() + " - " + MapKey(BaseClass::Class\Entry()\vMethodeID()) + "()"
              Break
            EndIf
          Next
        Next
      Else
        Debug " - Interface not found."
      EndIf
      Debug "}"
    CompilerEndIf
  EndMacro
 
  Macro ShowClasses()
    CompilerIf #PB_Compiler_Debugger
      ForEach BaseClass::Class\Entry()
        Define __index
        Debug "Interface " + MapKey(BaseClass::Class\Entry())
        Debug "{"
        For __index = 0 To ArraySize(BaseClass::Class\Entry()\vTable()) - 1
          ForEach BaseClass::Class\Entry()\vMethodeID()
            If BaseClass::Class\Entry()\vMethodeID() = __index
              Debug " - MethodeID " + BaseClass::Class\Entry()\vMethodeID() + " - " + MapKey(BaseClass::Class\Entry()\vMethodeID()) + "()"
              Break
            EndIf
          Next
        Next
        Debug "}"
      Next
  CompilerEndIf
  EndMacro
 
  Macro CheckInterface(InterfaceName)
    CompilerIf #PB_Compiler_Debugger
      CompilerIf Defined(InterfaceName, #PB_Interface)
        Define __SizeOfInterface = SizeOf(InterfaceName) / SizeOf(Integer)
        Define __IndexOfInterface
        For __IndexOfInterface = 0 To __SizeOfInterface - 1
          If Class\Entry(#PB_Compiler_Module)\vTable(__IndexOfInterface) = 0
            Debug "Error: Invalid Interface " + dq#InterfaceName#dq + " by MethodeID " + __IndexOfInterface
            ShowInterface()
            CallDebugger
          EndIf
        Next
      CompilerElse
        Debug "Error: Interface not exists"
        CallDebugger
      CompilerEndIf
    CompilerEndIf
  EndMacro

  ; ---------------------------------------------------------------------------
 
EndDeclareModule

Module BaseClass
 
  EnableExplicit
 
  ; ---------------------------------------------------------------------------
 
  Procedure AddClass(ClassName.s, ClassExtends.s, Size)
    Protected r1
    If FindMapElement(Class\Entry(), ClassExtends)
      r1 = AddMapElement(Class\Entry(), ClassName)
    Else
      Debug "Error: Extends Class '" + ClassExtends + "' not exists!"
      CallDebugger
    EndIf
    If r1
      CopyStructure(Class\Entry(ClassExtends), Class\Entry(ClassName), udtClass)
      ReDim Class\Entry(ClassName)\vTable(Size)
    Else
      Debug "Warning: Class '" + ClassName + "' not Initialized!"
    EndIf
    ProcedureReturn r1
  EndProcedure

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
        LockMutex(Class\Mutex)
        If Class\ObjectCounter > 0
          Class\ObjectCounter - 1
        EndIf
        UnlockMutex(Class\Mutex)
        ProcedureReturn 0
      Else
        \RefCount - 1
      EndIf
      UnlockMutex(*This\System\Mutex)
      ProcedureReturn \RefCount
    EndWith
  EndProcedure
 
  ; ---------------------------------------------------------------------------
 
  Procedure InitBaseClass()
    Class\Mutex = CreateMutex()
    AddMapElement(Class\Entry(), "BaseClass")
    With Class\Entry("BaseClass")
      \vTable(0) = @QueryInterface()
      \vTable(1) = @AddRef()
      \vTable(2) = @Release()
      \vMethodeID("QueryInterface") = 0
      \vMethodeID("AddRef") = 1
      \vMethodeID("Release") = 2
    EndWith
  EndProcedure : InitBaseClass()
 
  ; ---------------------------------------------------------------------------
 
EndModule

;- End Module BaseClass
