;   Description: Macros and procedures for creation and handling of objects
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29124&start=20#p332885
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 GPI
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

DeclareModule oop
  EnableExplicit
  
  
  ;-################ flags
  #AutoMutex=1
  #NoCreation=2
  #NoChild=4
  
  ;-################ macro
  Macro MacroColon 
    :
  EndMacro
  Macro MacroQuote 
    "
  EndMacro
  Macro MacroSingleQuote
    '
  EndMacro
  
  
  Macro JoinMacroParts (P1, P2=, P3=, P4=, P5=, P6=, P7=, P8=) : P1#P2#P3#P4#P5#P6#P7#P8 : EndMacro
  Macro CreateMacro (name,macroBody=)
    oop::JoinMacroParts (Macro name, oop::MacroColon, macroBody, oop::MacroColon, EndMacro) : 
  EndMacro
  Macro CreateQuote (name)
    oop::JoinMacroParts (oop::MacroQuote,name,oop::MacroQuote)
  EndMacro
  Macro CreateSingleQuote (name)
    oop::JoinMacroParts (oop::MacroSingleQuote,name,oop::MacroSingleQuote)
  EndMacro
  Macro IfSet(a,b):a=b:If a:EndMacro: ;endindent ;endindent
  Macro IfNotSet(a,b):a=b:If a=#False:EndMacro: ;endindent ;endindent
  
  ;-################ subTable und vTable
  Prototype.i prot_NoParameter()
  Prototype.i prot_OneParameter(a.i)
  Prototype.i prot_TwoParameter(a.i,b.i)
  
  Structure subTable
    AllocateStructure.prot_noParameter
    CopyStructure.prot_twoParameter
    ClearStructure.prot_oneParameter
    Initalize.prot_twoParameter
    Dispose.prot_oneParameter
    Clone.prot_oneParameter
    *vTableParent
    flags.i
    *SubObjects.SubObjects
    CompilerIf #PB_Compiler_Debugger
      Name.s
    CompilerEndIf    
  EndStructure
  
  Macro GetSubTable(vTable)
    (vTable-SizeOf(oop::subTable))
  EndMacro
  
  Macro CreateVTable(ClassName)
    Structure ClassName#__class_vTable extends oop::subTable
      vtable.b[SizeOf(ClassName)]
    EndStructure
    Global ClassName#__class_subTable.ClassName#__class_vTable
    Global ClassName#__class_vTable.i=@ClassName#__class_subTable+SizeOf(oop::subTable)    
    CompilerIf #PB_Compiler_Debugger
      ClassName#__class_subTable\Name=oop::CreateQuote(ClassName)
    CompilerEndIf
  EndMacro
  
  ;-################ Basis object  
  Interface object
  EndInterface
  
  Structure object__class_Object
    *__vTable
    *__DisposeChain    
    __Mutex.i
    CompilerIf #PB_Compiler_Debugger
      __ObjectName.s
      __FileName.s
      __Line.i
    CompilerEndIf    
  EndStructure
  
  Declare object__class___AllocateStructure()
  Declare object__class___CopyStructure(*self,*new)
  Declare object__class___ClearStructure(*self)
  
  CreateVTable(object)
  
  object__class_subTable\AllocateStructure=@object__class___AllocateStructure()
  object__class_subTable\CopyStructure    =@object__class___CopyStructure()
  object__class_subTable\ClearStructure   =@object__class___ClearStructure()
  
  ;-################ SubObjects
  Structure SubObjects
    *nextObject.SubObjects
    OffsetOf.i
    vTable.i
    count.i
    InitValue.i
    CompilerIf #PB_Compiler_Debugger
      Name.s
    CompilerEndIf    
  EndStructure
  
  
  ;-################ Object-Handling  
  CompilerIf #PB_Compiler_Debugger
    Macro DefineParameter
      ,ObjectName.s="",FileName.s="",Line.i=-1
    EndMacro
    Macro AddParameter(name)
      ,oop::CreateQuote(name),#PB_Compiler_Filename,#PB_Compiler_Line
    EndMacro
  CompilerElse
    Macro DefineParameter
    EndMacro
    Macro AddParameter(name)
    EndMacro
  CompilerEndIf
  Declare CreateObj(*obj.object__class_Object,*vTable,*disposeChain.integer,InitValue.i DefineParameter)
  Declare InitObj(*obj.object__class_Object,*vTable,InitValue.i DefineParameter)
  Declare DispObj(*obj.object__class_Object,*vTable=0)
  Declare CopyObj(*Source.object__class_Object,*Dest.object__class_Object)
  Declare CloneObj(*obj.object__class_Object,*vTable=0 DefineParameter)
  Declare ClearObj(*obj.object__class_Object)
  Declare DisposeChain(*Chain.object__class_Object)
  Declare CheckClass(*obj.object__class_Object,*vtable)
  
  CompilerIf #PB_Compiler_Debugger
    Declare.s DebugObj(*obj.oop::object__class_Object,Message$)
  CompilerEndIf
  
  CompilerIf #PB_Compiler_Debugger
    Declare CheckVTABLE(*vtable,size)
  CompilerEndIf
  
  
  Macro CheckDispose    
    CompilerIf oop::CreateQuote(__Class__endprocedurecheck()) <> "__Class__endprocedurecheck()"
      CompilerError "Missing _Endprocedure above this line"
    CompilerEndIf
  EndMacro
  
  Macro CreateCheckDispose
    oop::CheckDispose
    oop::CreateMacro(__Class__endprocedurecheck(),#True) :
  EndMacro
  
  Macro EndCheckDispose
    CompilerIf oop::CreateQuote(__Class__endprocedurecheck()) <> "__Class__endprocedurecheck()"
      UndefineMacro __Class__endprocedurecheck
    CompilerEndIf
  EndMacro
  
  CompilerIf #PB_Compiler_Debugger
    Global NewList *ObjectList.object__class_object()
    Global ObjectCount.q
    Global ObjectListMutex=CreateMutex()
    Declare AddObject(*obj)
    Declare SubObject(*obj)
    
  CompilerElse
    Macro AddObject(obj)
    EndMacro
    Macro SubObject(obj)
    EndMacro    
  CompilerEndIf
  
  
  ;-################ Helper
  
  Macro class_EndStructure
    CompilerIf Not Defined(__class_#__currentClass()_EndStructure,#PB_Constant)
      EndStructure;Indent
      #__class_#__currentClass()_EndStructure=#True
    CompilerEndIf
  EndMacro
  
  Macro class_EndInterface
    CompilerIf Not Defined(__class_#__currentClass()_EndInterface,#PB_Constant)
      EndInterface;Indent
      #__class_#__currentClass()_EndInterface=#True
    CompilerEndIf
  EndMacro
  
  
  Global *DefineDisposeChain
  Global *GlobalDisposeChain
  
  Macro DoDisposeChain()
    CompilerIf #PB_Compiler_Procedure<>""
      CompilerIf Defined(*__class_DisposeChain,#PB_Variable)
        *__class_DisposeChain=oop::DisposeChain(*__class_DisposeChain)
      CompilerEndIf
    CompilerElse
      oop::*DefineDisposeChain=oop::DisposeChain(oop::*DefineDisposeChain)
      oop::*GlobalDisposeChain=oop::DisposeChain(oop::*GlobalDisposeChain)
    CompilerEndIf
  EndMacro
  
EndDeclareModule

Module oop
  ;-################ Basis-Klasse
  Procedure object__class___AllocateStructure()
    ProcedureReturn AllocateStructure(object__class_Object)
  EndProcedure
  
  Procedure object__class___CopyStructure(*self,*new)
    ProcedureReturn CopyStructure(*self,*new,object__class_Object)
  EndProcedure
  
  Procedure object__class___ClearStructure(*self)
    ProcedureReturn ClearStructure(*self,object__class_Object)
  EndProcedure
  
  ;-################ Object-Handling
  Global GlobalChainMutex=CreateMutex()
  
  Procedure CreateObj(*obj.object__class_Object,*vTable,*disposeChain.integer,InitValue.i DefineParameter)
    Protected ok
    Protected *subTable.subTable=GetSubTable(*vTable)
    
    If *obj
      ProcedureReturn *obj
    EndIf
    
    If *subTable\flags & oop::#NoCreation
      ProcedureReturn 0
    EndIf
    
    IfNotSet(*obj,*subTable\AllocateStructure())
      ProcedureReturn 0
    EndIf
    
    Debug "CreateObject:"+*obj+" "+*vTable+" "+*subTable\Name+"  "+ObjectName,10
    AddObject(*obj)
    
    *obj\__vTable=*vTable
    CompilerIf #PB_Compiler_Debugger
      *obj\__ObjectName=ObjectName
      *obj\__FileName=FileName
      *obj\__Line=Line
    CompilerEndIf      
    
    If *subTable\flags & oop::#AutoMutex
      *obj\__Mutex=CreateMutex()
    EndIf      
    
    CompilerIf #PB_Compiler_Debugger
      ok=InitObj(*obj,*vTable,InitValue, ObjectName.s,FileName.s,Line )
    CompilerElse
      ok=InitObj(*obj,*vTable,InitValue)
    CompilerEndIf
    
    If ok=0
      DispObj(*obj)
      *obj=0
    ElseIf  *disposeChain
      If *disposeChain=oop::*GlobalDisposeChain
        LockMutex(GlobalChainMutex)
        *obj\__DisposeChain=*disposeChain\i
        *disposeChain\i=*obj
        UnlockMutex(GlobalChainMutex)
      Else
        *obj\__DisposeChain=*disposeChain\i
        *disposeChain\i=*obj
      EndIf
    EndIf
    
    Debug "EndCreateObject:"+*obj+" "+*vTable+" "+*subTable\Name+"  "+ObjectName,10
    
    ProcedureReturn *obj
  EndProcedure
  
  Procedure InitObj(*obj.object__class_Object,*vTable,InitValue.i DefineParameter)
    Protected *subTable.subTable=GetSubTable(*vTable)
    Protected i
    Protected *integer.integer
    Protected *SubObjects.SubObjects
    Protected ok=#True
    
    ;Erst Parent erzeugen!
    If *subTable\vTableParent
      CompilerIf #PB_Compiler_Debugger
        If InitObj(*obj,*subTable\vTableParent,InitValue, ObjectName.s,FileName.s,Line )=0
          ok=#False
        EndIf        
      CompilerElse
        If InitObj(*obj,*subTable\vTableParent,InitValue)=0
          ok=#False
        EndIf        
      CompilerEndIf
    EndIf
    
    Debug "InitalizeObject:"+*obj+" "+*vTable+" "+*subTable\Name+"  "+ObjectName,10
    
    ; objecte in variable initalizieren
    If ok
      *SubObjects=*subTable\SubObjects
      While *SubObjects
        
        *integer=*obj+ *SubObjects\OffsetOf
        i=*SubObjects\Count
        While i
          CompilerIf #PB_Compiler_Debugger
            *integer\i=CreateObj(0,*SubObjects\vTable,0,*SubObjects\InitValue,ObjectName+"."+*SubObjects\Name+"["+Str(*SubObjects\Count-i)+"]",FileName,Line) 
          CompilerElse            
            *integer\i=CreateObj(0,*SubObjects\vTable,0,*SubObjects\InitValue) 
          CompilerEndIf
          
          If *integer\i=0
            ok=#False:Break 2
          EndIf
          
          *integer + SizeOf(integer)
          i-1
        Wend
        *SubObjects=*SubObjects\nextObject
      Wend
    EndIf
    
    ;Gibts ein Initalize?
    If *subTable\Initalize And ok
      If *subTable\Initalize(*obj,InitValue)=0
        ok=#False
      EndIf      
    EndIf
    
    If ok=#False
      ProcedureReturn 0
    EndIf
    
    ProcedureReturn *obj    
  EndProcedure
  
  Procedure DispObj(*obj.object__class_Object,*vTable=0)
    Protected *subTable.subTable
    Protected i
    Protected *integer.integer
    Protected *SubObjects.SubObjects
    Protected FirstStart
    
    If *obj=0
      ProcedureReturn 0
    EndIf
    
    If *vTable=0
      *vTable=*obj\__vTable
      FirstStart=#True
      
      SubObject(*obj)
    EndIf
    
    *subTable.subTable=GetSubTable(*vTable)
    
    ;erst child zerstören
    Debug "DisposeObject:"+*obj+" "+*vTable+" "+*subTable\Name+"  "+*obj\__ObjectName,10
    
    ;Gibts ein Dispose
    If *subTable\Dispose 
      *subTable\Dispose(*obj)
    EndIf
    
    ;objecte in Variable zerstören
    *SubObjects=*subTable\SubObjects
    While *SubObjects
      
      *integer=*obj+ *SubObjects\OffsetOf
      i=*SubObjects\Count
      While i
        *integer\i=DispObj(*integer\i)
        i-1
        *integer + SizeOf(integer)
      Wend
      *SubObjects=*SubObjects\nextObject
    Wend
    
    ; danach parent zerstören
    If *subTable\vTableParent
      DispObj(*obj,*subTable\vTableParent)
    EndIf
    
    If FirstStart
      ;Mutex Freigeben
      If *obj\__Mutex
        FreeMutex(*obj\__Mutex)
      EndIf
      
      ;Object freigeben
      If *obj 
        FreeStructure(*obj)
        *obj=0
      EndIf
    EndIf
    
    ProcedureReturn *obj
  EndProcedure
  
  Procedure ClearObj(*obj.object__class_Object)
    Protected *vTable=*obj\__vTable
    Protected *subTable.subTable=GetSubTable(*vTable)
    Protected *oldchain=*obj\__DisposeChain
    Protected oldMutex=*obj\__Mutex    
    Protected ok
    
    CompilerIf #PB_Compiler_Debugger
      Protected oldObjectName.s=*obj\__ObjectName
      Protected oldFileName.s=*obj\__FileName
      Protected oldLine=*obj\__Line
    CompilerEndIf
    
    ;Zerstören, aber nicht freigeben
    DispObj(*obj,*obj\__vTable)
    
    ;daten zurücksetzen
    *subTable\ClearStructure(*obj)
    *obj\__Mutex=oldMutex
    *obj\__DisposeChain=*oldchain
    *obj\__vTable=*vTable
    
    ;Object neu initalisieren
    CompilerIf #PB_Compiler_Debugger
      ok=InitObj(*obj,*vTable,0, oldObjectName,oldFileName,oldLine )
    CompilerElse
      ok=InitObj(*obj,*vTable,0)
    CompilerEndIf
    
    If ok=0
      DispObj(*obj)
      *obj=0
    EndIf
    
    ProcedureReturn *obj
  EndProcedure   
  
  Procedure CopyObj(*Source.object__class_Object,*Dest.object__class_Object)
    Protected ok=#True
    If *Source\__vTable<>*dest\__vTable Or *source=*dest
      ClearObj(*dest)
      ProcedureReturn #False
    EndIf
    
    Protected *oldchain=*Dest\__DisposeChain
    Protected oldMutex=*Dest\__Mutex    
    Protected *subTable.subTable=GetSubTable(*Dest\__vTable)
    
    CompilerIf #PB_Compiler_Debugger
      Protected oldObjectName.s=*Dest\__ObjectName
      Protected oldFileName.s=*Dest\__FileName
      Protected oldLine=*Dest\__Line
    CompilerEndIf
    
    ;Ziel zerstören, aber nicht freigeben (deswegen vTable)
    DispObj(*Dest,*Dest\__vTable)
    
    ;Quelle auf Ziel kopieren
    *subTable\CopyStructure(*Source,*Dest)
    
    ;CloneObj aufrufen, aber nicht neu anlegen (deswegen vTable)
    CompilerIf #PB_Compiler_Debugger
      If CloneObj(*Dest,*Dest\__vTable,OldObjectName,oldFileName,oldLine)=0
        ClearObj(*Dest)
        ok=#False        
      EndIf
    CompilerElse
      If CloneObj(*Dest,*Dest\__vTable)=0
        ClearObj(*Dest)
        ok=#False
      EndIf
    CompilerEndIf
    
    ;Gesicherte Werte zurücksetzen
    If *dest
      *Dest\__DisposeChain=*oldchain
      *Dest\__Mutex=oldMutex
    EndIf
    
    ProcedureReturn ok
    
  EndProcedure
  
  Procedure CloneObj(*obj.object__class_Object,*vTable=0 DefineParameter)
    Protected *new.object__class_Object
    Protected ok=#True
    Protected FirstStart
    Protected *subTable.subTable
    Protected *SubObjects.SubObjects
    Protected *integer.integer
    Protected i
    
    If *vTable=0
      ;Erster Aufruf!
      FirstStart=#True
      *vTable=*obj\__vTable
      *subTable.subTable=GetSubTable(*vTable)
      
      ;Object erstmal mit Allocate anlegen
      IfNotSet(*new,*subTable\AllocateStructure())
        ProcedureReturn 0
      EndIf
      
      AddObject(*new)
      
      ;Object erstmal 1:1 kopieren
      *subTable\CopyStructure(*obj,*new)
      
      ;und zum aktuellen machen
      *obj=*new
      
      ;DisposeChain löschen
      *obj\__DisposeChain=0      
      ;Debug-Werte schreiben
      CompilerIf #PB_Compiler_Debugger
        *obj\__ObjectName=ObjectName
        *obj\__FileName=FileName
        *obj\__Line=Line
      CompilerEndIf
      
      If *obj\__Mutex
        *obj\__Mutex=CreateMutex()
      EndIf      
    Else
      *subTable.subTable=GetSubTable(*vTable)
    EndIf
    
    ;Erst Parent clonen!
    If *subTable\vTableParent
      CompilerIf #PB_Compiler_Debugger
        
        If CloneObj(*obj,*subTable\vTableParent,ObjectName,FileName,Line)=0
          ok=#False
        EndIf      
      CompilerElse
        If CloneObj(*obj,*subTable\vTableParent)=0
          ok=#False
        EndIf      
      CompilerEndIf
      
    EndIf
    
    Debug "CloneObject:"+*obj+" "+*vTable+" "+*subTable\Name+"  "+*obj\__ObjectName,10
    
    ; objecte in Variable clonen
    *SubObjects=*subTable\SubObjects
    While *SubObjects
      
      *integer=*obj+ *SubObjects\OffsetOf
      i=*SubObjects\Count
      While i
        
        If ok
          
          CompilerIf #PB_Compiler_Debugger
            *integer\i=CloneObj(*integer\i,0,ObjectName+"."+*SubObjects\Name+"["+Str(*SubObjects\Count-i)+"]",FileName,Line) 
          CompilerElse            
            *integer\i=CloneObj(*integer\i,0) 
          CompilerEndIf
          
          If *integer\i=0
            ok=#False
          EndIf
          
        Else
          *integer\i=0
        EndIf
        
        *integer + SizeOf(integer)
        i-1
      Wend
      *SubObjects=*SubObjects\nextObject
    Wend
    
    
    If *subTable\Clone And *subTable\Clone(*obj)=0
      ok=#False
    EndIf
    
    If FirstStart 
      
      If ok=#False
        *obj=DispObj(*obj)
      EndIf
      ProcedureReturn *obj      
    EndIf
    
    If ok
      ProcedureReturn *obj
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure DisposeChain(*Chain.object__class_Object)
    Protected *NextChain
    While *chain
      *NextChain=*chain\__DisposeChain
      DispObj(*chain)
      *chain=*NextChain
    Wend
    ProcedureReturn 0
  EndProcedure
  
  Procedure CheckClass(*obj.object__class_Object,*vtable)
    Protected ret
    Protected *ThisTable=*Obj\__vTable
    Protected *subTable.subTable
    
    If *obj=object__class_vTable
      ProcedureReturn #True
    EndIf
    
    While *ThisTable<>0 
      If *ThisTable=*vtable
        ret= #True
        Break
      EndIf
      *subTable=GetSubTable(*thisTable)
      *ThisTable=*subTable\vTableParent 
    Wend
    ProcedureReturn ret
  EndProcedure  
  
  CompilerIf #PB_Compiler_Debugger
    Procedure.s DebugObj(*obj.oop::object__class_Object,Message$)
      If *obj
        Protected *subTable.subTable=GetSubTable(*obj\__vTable)
        
        ProcedureReturn message$+" "+*obj\__ObjectName+"."+*subTable\Name+" ("+ *obj\__FileName +"@"+ *obj\__Line +")"
      Else
        ProcedureReturn "NULL: "+Message$
      EndIf
    EndProcedure
    
    Procedure AddObject(*obj)
      LockMutex(oop::ObjectListMutex)
      ObjectCount+1
      AddElement(*ObjectList())
      *ObjectList()=*obj
      UnlockMutex(oop::ObjectListMutex)
    EndProcedure
    
    Procedure SubObject(*obj)
      LockMutex(oop::ObjectListMutex)
      ObjectCount-1
      ForEach *ObjectList()
        If *ObjectList()=*obj
          DeleteElement(*ObjectList())
          Break
        EndIf
      Next
      UnlockMutex(oop::ObjectListMutex)
    EndProcedure
    
    CompilerIf #PB_Compiler_Debugger
      Procedure CheckVTABLE(*vtable,size)
        Protected *start.integer=*vtable
        Protected *end=*vtable+size
        While *start<*end
          If *start\i=0
            ProcedureReturn #True
          EndIf          
          *start+SizeOf(integer)
        Wend
        ProcedureReturn #False
      EndProcedure
    CompilerEndIf
    
  CompilerEndIf
  
  
EndModule

DeclareModule EnableClass
  Macro InitalizeClass(ClassName,ParentClass=oop::object) 
    CompilerIf Not #PB_Compiler_Procedure=""  
      CompilerError "Don't initalize Class in Procedures"
    CompilerEndIf
    oop::CreateVTable(ClassName)
    Gosub __class_#ClassName#_Initalize
    
    CompilerIf #PB_Compiler_Debugger
      If oop::CheckVTABLE(ClassName#__class_vTable,SizeOf(ClassName))
        Debug "[ERROR] Missing definied Method!"
        CallDebugger
        End
      EndIf      
    CompilerEndIf
    
    oop::CreateMacro(ClassName#__class_Parent,ParentClass) :
    
    #ClassName#__class_isDeclared=#True
  EndMacro
  Macro InitalizeClassEx(ClassName,ParentClass=oop::object);Endindent
    InitalizeClass(ClassName)
    oop::CreateMacro(__currentClass(),ClassName) : 
    Structure ClassName#__class_object extends ParentClass#__class_object ;endindent  
  EndMacro
  Macro EndInitalizeClassEx 
    ;Indent
    oop::class_EndStructure
    UndefineMacro __currentClass
  EndMacro
  
  Macro DeclareClass(ClassName,ParentClass=oop::object);Endindent
    oop::CreateMacro(__currentClass(),ClassName) :
    oop::CreateMacro(__currentParentClass(),ParentClass) :
    
    Interface ClassName Extends ParentClass;Endindent
    
    
  EndMacro
  
  Macro Properties
    oop::class_EndInterface
    
    Structure __currentClass()__class_object extends __currentParentClass()__class_object;Endindent
  EndMacro
  
  
  Macro EndDeclareClass
    ;Indent
    
    CompilerIf Defined(__currentClass()__class_object,#PB_Structure)
      oop::class_EndStructure
    CompilerElse      
      oop::class_EndInterface
    CompilerEndIf
    
    InitalizeClass(__currentClass(),__currentParentClass())
    
    UndefineMacro __currentClass
    UndefineMacro __currentParentClass
  EndMacro
  
  Macro Class(ClassName,ClassFlags=0)      ;Endindent
    __class(ClassName,ClassName#__class_Parent,ClassFlags)
  EndMacro
  
  Macro __Class(ClassName,ParentClass=oop::object,ClassFlags=0)  
    CompilerIf Not #PB_Compiler_Procedure=""  
      CompilerError "Don't define Class in Procedures"
    CompilerEndIf
    
    CompilerIf Not Defined (ClassName#__class_isDeclared,#PB_Constant)
      CompilerError "Missing declaration of Class"
    CompilerEndIf
    
    ;Block übersprigen
    Goto  __class_#ClassName#_EndTag
    __class_#ClassName#_Initalize:
    
    CopyMemory(ParentClass#__class_vTable,ClassName#__class_vTable,SizeOf(ParentClass))
    
    CompilerIf oop::CreateQuote(ParentClass)<>"oop::object"
      ClassName#__class_subTable\vTableParent = ParentClass#__class_vTable
    CompilerEndIf
    ClassName#__class_subTable\Flags=ClassFlags    
    
    CompilerIf #PB_Compiler_Debugger
      If ParentClass#__class_subTable\Flags & oop::#NoChild
        Debug "[ERROR] "+oop::CreateQuote(ParentClass)+" is not allowed as Parent"
        CallDebugger
        End
      EndIf
    CompilerEndIf
    
    oop::CreateMacro(__this_class(),*self.ClassName#__class_object) :    
    oop::CreateMacro(__currentClass(),ClassName) : 
    oop::CreateMacro(__flags(),ClassFlags) :
    
    CompilerIf Not Defined(__class_#ClassName#_EndStructure,#PB_Constant)
      Structure ClassName#__class_object extends ParentClass#__class_object ;endindent      
    CompilerEndIf
  EndMacro 
  
  Macro InitalizeObject(obj,ClassName,countnb=1,IValue=0)
    oop::class_EndStructure
    
    ;ein neues Subobject
    Global __class_SubObjects_#MacroExpandedCount.oop::SubObjects
    
    ;in die Subtable einhängen
    __class_SubObjects_#MacroExpandedCount\nextObject=__currentClass()__class_subTable\SubObjects
    __currentClass()__class_subTable\SubObjects=__class_SubObjects_#MacroExpandedCount
    
    ;Werte speichern
    __class_SubObjects_#MacroExpandedCount\OffsetOf=OffsetOf(__currentClass()__class_Object\obj)
    __class_SubObjects_#MacroExpandedCount\vTable=ClassName#__class_vTable
    __class_SubObjects_#MacroExpandedCount\Count=countnb
    __class_SubObjects_#MacroExpandedCount\InitValue=IValue
    CompilerIf #PB_Compiler_Debugger
      __class_SubObjects_#MacroExpandedCount\Name=oop::CreateQuote(obj)
    CompilerEndIf
    
  EndMacro
  
  Macro This
    __this_class()
  EndMacro
  
  Macro MethodAlias(oldfunc,newfunc)
    oop::class_EndStructure
    PokeI(__currentClass()__class_vTable+OffsetOf(__currentClass()\newfunc()),
          PeekI(__currentClass()__class_vTable+OffsetOf(__currentClass()\oldfunc())) )
  EndMacro  
  
  Macro Method(ret,func,para=) ;endindent
    oop::class_EndStructure
    CompilerIf oop::CreateQuote(func)="Initalize" Or oop::CreateQuote(func)="initalize"
      Declare.i __class_#__currentClass()_#func (This,*initValue)
      __currentClass()__class_subTable\func = @__class_#__currentClass()_#func()
      CompilerIf oop::CreateQuote(para)=""
        Procedure.ret __class_#__currentClass()_#func (This,*__InitValue) ;endindent
      CompilerElse        
        Procedure.ret __class_#__currentClass()_#func para ;endindent        
      CompilerEndIf
      Protected __class_return.i=This
      
    CompilerElseIf oop::CreateQuote(func)="Dispose" Or oop::CreateQuote(func)="dispose" Or oop::CreateQuote(func)="Clone"  Or oop::CreateQuote(func)="clone"  
      Declare.i __class_#__currentClass()_#func (This)
      __currentClass()__class_subTable\func = @__class_#__currentClass()_#func()
      CompilerIf oop::CreateQuote(para)=""
        Procedure.ret __class_#__currentClass()_#func (This) ;endindent
      CompilerElse        
        Procedure.ret __class_#__currentClass()_#func para ;endindent        
      CompilerEndIf
      Protected __class_return.i=This
      
    CompilerElseIf oop::CreateQuote(para)=""
      Declare.ret __class_#__currentClass()_#func (This)
      PokeI(__currentClass()__class_vTable+OffsetOf(__currentClass()\func()),@__class_#__currentClass()_#func())
      Procedure.ret __class_#__currentClass()_#func (This)  ;endindent
      Protected __class_return.ret
      
    CompilerElse
      Declare.ret __class_#__currentClass()_#func para
      PokeI(__currentClass()__class_vTable+OffsetOf(__currentClass()\func()),@__class_#__currentClass()_#func())
      Procedure.ret __class_#__currentClass()_#func para  ;endindent
      Protected __class_return.ret
      
    CompilerEndIf
    Protected self.__currentClass()=This
    
    CompilerIf __flags() & oop::#AutoMutex
      LockMutex(This\__Mutex)
    CompilerEndIf
    
    CompilerIf Not Defined(*self,#PB_Variable)
      CompilerError "Missing 'This'!"
    CompilerEndIf    
    
  EndMacro
  Macro MethodReturn(a=)
    __class_return=a
    Goto __class_EndMethod
  EndMacro
  
  Macro EndMethod 
    ;Indent
    __class_EndMethod:
    CompilerIf __flags() & oop::#AutoMutex
      UnlockMutex(This\__Mutex)
    CompilerEndIf
    oop::DoDisposeChain()
    ProcedureReturn __class_return
    _EndProcedure;indent
  EndMacro
  
  Macro EndClass  
    ;Indent
    oop::class_EndStructure
    
    
    Procedure __currentClass()__class___AllocateStructure()
      ProcedureReturn AllocateStructure(__currentClass()__class_Object)
    EndProcedure
    Procedure __currentClass()__class___CopyStructure(*self,*new)
      ProcedureReturn CopyStructure(*self,*new,__currentClass()__class_Object)
    EndProcedure
    Procedure __currentClass()__class___ClearStructure(*self)
      ProcedureReturn ClearStructure(*self,__currentClass()__class_Object)
    EndProcedure
    __currentClass()__class_subTable\AllocateStructure=@__currentClass()__class___AllocateStructure()
    __currentClass()__class_subTable\CopyStructure=@__currentClass()__class___CopyStructure()
    __currentClass()__class_subTable\ClearStructure=@__currentClass()__class___ClearStructure()
    
    Return
    __class_#__currentClass()_EndTag:
    
    UndefineMacro __currentClass   
    UndefineMacro __this_class
    UndefineMacro __Flags
  EndMacro
  
  Macro Define_Object(Object,ClassName,InitValue=0)
    CompilerIf #PB_Compiler_Procedure=""
      oop::CheckDispose
      Define Object.ClassName=oop::CreateObj(Object.ClassName,ClassName#__class_vTable,oop::@*DefineDisposeChain,InitValue oop::AddParameter(Object))
    CompilerElse
      CompilerIf Not Defined(*__class_DisposeChain,#PB_Variable)
        Protected *__class_DisposeChain
        oop::CreateCheckDispose
      CompilerEndIf
      Define Object.ClassName=oop::CreateObj(Object.ClassName,ClassName#__class_vTable,@*__class_DisposeChain,InitValue oop::AddParameter(Object))
    CompilerEndIf
  EndMacro
  
  Macro Global_Object(Object,ClassName,InitValue=0)
    oop::CheckDispose
    Global Object.ClassName=oop::CreateObj(Object.ClassName,ClassName#__class_vTable,oop::@*GlobalDisposeChain,InitValue oop::AddParameter(Object))    
  EndMacro
  
  Macro Static_Object(Object,ClassName,InitValue=0)    
    Static Object.ClassName
    Object=oop::CreateObj(Object.ClassName,ClassName#__class_vTable,oop::@*GlobalDisposeChain,InitValue oop::AddParameter(Object))    
  EndMacro
  
  Macro Protected_Object(Object,ClassName,InitValue=0)
    CompilerIf Not Defined(*__class_DisposeChain,#PB_Variable)
      Protected *__class_DisposeChain
      oop::CreateCheckDispose
    CompilerEndIf
    Protected Object.ClassName=oop::CreateObj(Object.ClassName,ClassName#__class_vTable,@*__class_DisposeChain,InitValue oop::AddParameter(Object))
  EndMacro
  
  Macro CloneObject(object)
    oop::CloneObj(object,0 oop::AddParameter( $Clone(object) ))
  EndMacro
  Macro AllocateObject(ClassName,InitValue=0)
    oop::CreateObj(0,ClassName#__class_vTable,0,InitValue oop::AddParameter($Alloc))
  EndMacro
  Macro FreeObject(obj)
    oop::DispObj(obj)
  EndMacro
  
  Macro _ProcedureReturn
    oop::DoDisposeChain()
    ProcedureReturn
  EndMacro
  Macro _EndProcedure
    ;indent
    oop::EndCheckDispose
    oop::DoDisposeChain()
    EndProcedure;indent
  EndMacro
  Macro _FakeEnd    
    oop::CheckDispose
    
    CompilerIf #PB_Compiler_Procedure<>""
      CompilerError "Don't use _End and _FakeEnd in Procedures"
    CompilerEndIf
    oop::DoDisposeChain()
    
    CompilerIf #PB_Compiler_Debugger
      If oop::ObjectCount<>0
        Debug "[WARNING] Undisposed Objects found: "+oop::ObjectCount
        ForEach oop::*ObjectList()
          Debug oop::*ObjectList()\__ObjectName.s+" "+oop::*ObjectList()\__FileName+"@"+oop::*ObjectList()\__Line
        Next
      EndIf
    CompilerEndIf
    
    
  EndMacro
  
  Macro _End
    _FakeEnd
    End
  EndMacro
  
  Macro CheckClass(obj,ClassName)
    oop::CheckClass(obj,ClassName#__class_vTable)
  EndMacro
  
  Macro CopyObject(source,dest)
    oop::CopyObj(source,dest)
  EndMacro
  
  Macro ResetObject(obj)
    oop::ClearObj(obj)
  EndMacro
  
  CompilerIf #PB_Compiler_Debugger
    Macro DebugObject(Object,Message,Level=0)
      Debug oop::DebugObj(Object,Message) ,Level
    EndMacro
  CompilerElse
    Macro DebugObject(Object,Message,Level=0)
    EndMacro
  CompilerEndIf
  
EndDeclareModule

Module EnableClass
  
  
  
EndModule

UseModule EnableClass

;-Example

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit

  
  ;XIncludeFile "test.pbi"
  DeclareModule test
    Macro MacroColon 
      :
    EndMacro
    Macro MacroQuote 
      "
    EndMacro
    Macro JoinMacroParts (P1, P2=, P3=, P4=, P5=, P6=, P7=, P8=) : P1#P2#P3#P4#P5#P6#P7#P8 : EndMacro
    Macro CreateMacro (name,macroBody=)
      test::JoinMacroParts (Macro name, test::MacroColon, macroBody, test::MacroColon, EndMacro) : 
    EndMacro
    Macro CreateQuote (name)
      test::JoinMacroParts (test::MacroQuote,name,test::MacroQuote)
    EndMacro
    
    Declare finish()
    
    Define __aa.i,__cc.i
    Define __aad.d,__ccd.d
    Define __aaf.f,__ccf.f
    Define __aas.s,__ccs.s
    
    Macro i(a,ss,c)
      test::__aa=a
      test::__cc=c
      test::t(#PB_Compiler_Procedure,Bool(test::__aa ss test::__cc),test::CreateQuote(a ss c),Str(test::__aa),Str(test::__cc),test::CreateQuote(ss))
    EndMacro
    Macro d(a,ss,c,xxx=2)
      test::__aad=a
      test::__ccd=c
      test::t(#PB_Compiler_Procedure,Bool(test::__aad ss test::__ccd),test::CreateQuote(a ss c),StrD(test::__aad,xxx),StrD(test::__ccd,xxx),test::CreateQuote(ss))
    EndMacro
    Macro f(a,ss,c)
      test::__aaf=a
      test::__ccf=c
      test::t(#PB_Compiler_Procedure,Bool(test::__aaf ss test::__ccf),test::CreateQuote(a ss c),StrD(test::__aaf),StrD(test::__ccf),test::CreateQuote(ss))
    EndMacro
    Macro s(a,ss,c)
      test::__aas=a
      test::__ccs=c
      test::t(#PB_Compiler_Procedure,Bool(test::__aas ss test::__ccs),test::CreateQuote(a ss )+" "+test::__ccs,"",""," ")
    EndMacro
    
    
    Declare T(p.s,bool.i,sa.s,a.s,c.s,s.s)
    Declare finish()
    Declare Set(name.s)
  EndDeclareModule
  Module test
    Global TestName.s
    Global TestResult=#True  
    
    Procedure Set(name.s)
      TestName=name
    EndProcedure
    
    
    Procedure finish()
      PrintN("")
      PrintN("")
      If TestResult
        ConsoleColor(10,0)
        PrintN( "Test OK!")
      Else
        ConsoleColor(12,0)
        PrintN( "Test Fail!")  
      EndIf
      PrintN("")
      PrintN("")
      PrintN("Press [Return]")
      Input()
      CloseConsole()
      End
    EndProcedure
    
    Procedure T(p.s,bool.i,sa.s,a.s,c.s,s.s)
      If s="<>":s="!":EndIf
      Static back,lastp$,lastTestName$
      Define fc,cok,cfail
      
      If lastTestName$<>TestName
        lastTestName$=TestName
        ConsoleColor(8,0)
        PrintN(TestName+":")
        lastp$=""
      EndIf
      
      If lastp$<>p
        lastp$=p
        ConsoleColor(8,0)
        If lastp$<>""
          PrintN("  ("+lastp$+")")
        Else
          PrintN("  (Main)")
        EndIf    
      EndIf
      
      Print ("     ")
      back!1
      If back
        fc=15
        cfail=12
        cok=10
      Else
        fc=7
        cfail=4
        cok=2    
      EndIf
      
      Define state.s
      ConsoleColor(fc,0)
      
      Print(Left(sa+Space(35+24-10),35+24-10) )
      
      Print(Left(Right(Space(5+5)+a,5+5)+s.s+Left(c+Space(5+5),5+5),11+10))
      If bool
        ConsoleColor(cok,0)
        PrintN("ok  ")
        ConsoleColor(fc,0)
      Else
        ConsoleColor(cfail,0)
        PrintN("FAIL")
        ConsoleColor(fc,0)
        Debug "Fail:"+sa
        TestResult=#False
      EndIf  
      ConsoleColor(7,0)
    EndProcedure
  EndModule
  
  EnableExplicit
  OpenConsole()
  PrintN("Start")
  PrintN("")
  
  ;endXIncludeFile "test.pbi"
  ;-***
  ;-*** TEST
  ;-***
  
  
  Global NewMap _fakealloc()
  
  Procedure fakealloc()
    Static c.i
    c+1
    _fakealloc(Str(c))=1
    ProcedureReturn c
  EndProcedure
  Procedure fakefree(c)
    If _fakealloc(Str(c))>0
      _fakealloc(Str(c))=0
    Else
      _fakealloc(Str(c))=-1
    EndIf
    
  EndProcedure
  Procedure listfake()
    Define ok=#True
    ForEach _fakealloc()
      If _fakealloc()<>0
        ok=#False
      EndIf
    Next
    ProcedureReturn ok
  EndProcedure
  Procedure falidFake(c)
    ProcedureReturn Bool(_fakealloc(Str(c))>0)
  EndProcedure
  
  
  Global Init_test.i=1
  Global Clone_test.i=1
  
  Interface cTestParent;- cTestParent
  EndInterface
  InitalizeClass(cTestParent)
  
  Class(cTestParent) ;-cTestParent
    Method(i,Initalize)
      init_test+1
    EndMethod
    Method(i,Dispose)
      init_test-3
    EndMethod
    Method(i,Clone)
      Clone_test+2
      MethodReturn (#True)
    EndMethod
    
  EndClass
  
  
  Interface cTestChild Extends cTestParent;- cTestChild
    get()
  EndInterface
  InitalizeClass(cTestChild,cTestParent)
  
  
  
  DeclareClass (cTestGrandChild,cTestChild);- cTestGrandchild
    getvar()
    setvar(v.i)
  EndDeclareClass
  ;EndInterface
  ;InitalizeClass(cTestGrandChild,cTestChild)
  
  
  
  Interface cTestChild2 Extends cTestParent;- cTestChild2
  EndInterface
  InitalizeClass(cTestChild2,cTestParent)
  
  Interface cTestCloneFail Extends cTestGrandChild;- cTestCloneFail
  EndInterface
  InitalizeClass(cTestCloneFail,cTestGrandChild)
  
  
  Interface cVar;- cVar
    Set(x)
    Get()
  EndInterface 
  InitalizeClass(cVar)
  
  
  Interface  cVar2 Extends cVar;- cVar2
    OldSet(x)
  EndInterface
  InitalizeClass(cVar2,cVar)
  
  
  Interface CSubs;- cSubs
    Get(w.i)
    Set(w.i,v.i)
  EndInterface
  InitalizeClass(cSubs)
  
  
  
  Interface CSubs2;- cSubs2
    Get(w.i)
    Set(w.i,v.i)
  EndInterface
  InitalizeClass(cSubs2)
  
  
  
  Interface cDeep1;- cDeep1
    get()
    set(v.i)
    GetFake()
  EndInterface
  InitalizeClass(cDeep1)
  
  
  Interface cDeep2;- cDeep2
    get(p.i)
    set(p.i,v.i)
    GetFake(p.i)
  EndInterface
  InitalizeClass(cDeep2)
  
  Interface cDeep3;- cDeep3
    get(p.i)
    set(p.i,v.i)
    GetFake(p.i)
  EndInterface
  InitalizeClass(cDeep3)
  
  Interface cDeep4;- cDeep4
    get(p.i)
    set(p.i,v.i)
    GetFake(p.i)
    GetFake2()
  EndInterface
  InitalizeClass(cDeep4)      
  
  
  Interface cDeep5 Extends cDeep4;- cDeep5
    GetFake3()
  EndInterface
  InitalizeClass(cDeep5,cDeep4)    
  
  Interface cMutex;-cMutex
    Output(text.s)
  EndInterface
  InitalizeClass(cMutex)
  
  Interface cNoMutex;-cNoMutex
    Output(text.s)
  EndInterface
  InitalizeClass(cNoMutex)
  
  Interface cNoCreate;-cNoCreate
  EndInterface
  InitalizeClass(cNoCreate)
  
  Interface cNCChild Extends cNoCreate;-cNCChild
  EndInterface
  InitalizeClass(cNCChild,cNoCreate)
  
  OpenConsole()
  EnableGraphicalConsole(1)
  ConsoleColor(7,0)
  ClearConsole()
  
  test::set("Initialize Tests");-{ Initalize Tests
  Procedure InitTest1()
    Define_Object(obj1,cTestParent)
    test::i(Init_Test,=,2)
    Define_Object(obj2,cTestChild)
    test::i(Init_Test,=,6)
    Define_Object(obj3,cTestGrandChild)
    test::i(Init_Test,=,20)
    Define_Object(obj5,cTestChild2)
    test::i(Init_Test,=,105)
  _EndProcedure
  InitTest1()
  ;}
  
  test::set("Disopse Tests");-{ Dispose Tests
  Procedure DisposeTest1()
    Protected_Object(obj1,cTestGrandChild)
    test::i(Init_Test,=,48)
  _EndProcedure
  Procedure DisposeTest2()
    Protected_Object(obj1,cTestChild2)
    test::i(Init_Test,=,910)
  _EndProcedure
  Init_test=20
  DisposeTest1()
  Test::i(Init_Test,=,181)
  DisposeTest2()
  Test::i(Init_Test,=,11827)
  ;}
  
  
  test::set("Clone Tests");-{ Clone Tests
  Procedure CloneTest1()
    Protected i
    Protected *mem1,*mem2
    Protected_Object(obj1,cTestGrandChild)
    Protected_Object(obj2,cTestGrandChild)
    Protected_Object(obj3,cTestParent)
    *mem1=obj1\get()
    *mem2=obj2\get()
    Init_Test=54
    Clone_Test=1
    test::i(CopyObject(obj2,obj1),<>,0)
    test::i(Init_test,=,205)
    test::i(Clone_Test,=,18)
    
    test::i(obj1\get(),<>,obj2\get())
    test::i(obj1\get(),<>,*mem1)
    test::i(obj2\get(),=,*mem2)
    test::i(falidfake(obj1\get()),=,#True)
    test::i(falidfake(obj2\get()),=,#True)
    
    obj1\setvar(99)
    test::i(CopyObject(obj3,obj1),=,#False)
    test::i(obj1\getvar(),=,0)
    obj1\setvar(99)
    test::i(CopyObject(obj1,obj1),=,#False)
    test::i(obj1\getvar(),=,0)
  _EndProcedure
  Procedure CloneTest2()
    Protected_Object(obj1,cVar)
    Protected_Object(obj2,cvar)
    obj1\Set(1)
    obj2\Set(2)
    CopyObject(obj2,obj1)
    Test::i(obj1\Get(),=,2)
    obj1\Set(3)
    Test::i(obj2\Get(),=,2)
  _EndProcedure
  Procedure CloneTest3()
    Protected *clone
    init_test=0
    Protected_Object(obj1,cTestCloneFail)
    Protected_Object(obj2,cTestCloneFail)
    
    
    obj2\setvar(99)
    test::i(CopyObject(obj1,obj2),=,#False)
    test::i(obj2\getvar(),=,0)
    init_Test=1
    *clone=CloneObject(obj2)
    test::i(*clone,=,#False)
    test::i(Init_test,=,-7)
    
  _EndProcedure
  
  test::i(listfake(),=,#True)
  CloneTest1()
  
  test::i(listfake(),=,#True)
  CloneTest2()
  
  
  test::i(listfake(),=,#True)
  CloneTest3()
  
  test::i(listfake(),=,#True)
  
  ;}
  
  
  Test::set("Global Tests");-{ Global Tests
  Global_Object(gVar,cVar)
  Procedure GlobalTest1()
    gvar\Set(gvar\get()+1)
  _EndProcedure
  gvar\set(20)
  globalTest1()
  test::i(gvar\get(),=,21)
  ;}
  
  Test::set("Bad Obj1=Obj2 Test");-{ Bad Test
  Procedure BadSet()
    Protected_Object(obj1,cVar)
    Protected_Object(obj2,cVar)
    obj1\set(10)
    obj2\set(20)
    obj1=obj2
    test::i(obj1\Get(),=,obj2\get())
    
  _EndProcedure
  BadSet()
  ;}
  
  Test::set("Pointer Tests");-{ Pointer Test
  Procedure pointer(*obj.cVar)
    test::i(CheckClass(*obj,cVar),<>,#False)
    
    If Not CheckClass(*obj,cVar)
      ProcedureReturn
    EndIf
    
    *obj\set(*obj\get()+10)
    
  _EndProcedure
  Define_Object(pointer1,cvar)
  Define_Object(pointer2,cTestParent)
  pointer(pointer1)
  test::i(pointer1\Get(),=,10)
  pointer(pointer1)
  test::i(pointer1\Get(),=,20)
  ;}
  
  Test::set("Recursive Test");-{ Recursive Test
  Procedure recursive(*obj.cvar)
    Protected_Object(obj2,cvar)
    Protected x
    x=*obj\get()+1
    *obj\set(x)
    obj2\set(x)
    If *obj\get()<5
      recursive(*obj)
    EndIf
    test::i(obj2\get(),=,x)
  _EndProcedure
  pointer1\set(0)
  recursive(pointer1)
  test::i(pointer1\get(),=,5)
  ;}
  
  Test::set("Loop Test");-{ Loop Test
  Procedure loop()
    Define i
    For i=1 To 10
      Define_Object(obj,cVar)
      obj\Set(obj\Get()+1)
    Next
    test::i(obj\Get(),=,10)
  _EndProcedure
  loop()
  ;}
  
  Test::set("Static Test");-{ Static Test
  Procedure StaticTest(x)
    Static_Object(obj,cvar)
    obj\Set(obj\Get()+1)
    Test::i(obj\get(),=,x)  
  _EndProcedure
  StaticTest(1)
  StaticTest(2)
  ;}
  
  Test::set("Check Class Test");-{ Check Class Test
  Procedure CheckTest()
    Protected_Object(obj1,cTestParent)
    Protected_Object(obj2,cTestChild)
    Protected_Object(obj3,cTestGrandChild)
    Protected_Object(obj4,cVar)
    Protected_Object(obj5,cTestChild2)
    test::i(CheckClass(obj1,cTestParent),<>,0)
    test::i(CheckClass(obj2,cTestParent),<>,0)
    test::i(CheckClass(obj3,cTestParent),<>,0)
    test::i(CheckClass(obj4,cTestParent),=,0)
    test::i(CheckClass(obj5,cTestParent),<>,0)
    test::i(CheckClass(obj1,cTestChild),=,0)
    test::i(CheckClass(obj2,cTestChild),<>,0)
    test::i(CheckClass(obj3,cTestChild),<>,0)
    test::i(CheckClass(obj4,cTestChild),=,0)
    test::i(CheckClass(obj5,cTestChild),=,0)
    test::i(CheckClass(obj1,cTestGrandChild),=,0)
    test::i(CheckClass(obj2,cTestGrandChild),=,0)
    test::i(CheckClass(obj3,cTestGrandChild),<>,0)  
    test::i(CheckClass(obj4,cTestGrandChild),=,0)
    test::i(CheckClass(obj5,cTestGrandChild),=,0)
    test::i(CheckClass(obj1,cVar),=,0)
    test::i(CheckClass(obj2,cVar),=,0)
    test::i(CheckClass(obj3,cVar),=,0)
    test::i(CheckClass(obj4,cVar),<>,0)
    test::i(CheckClass(obj5,cVar),=,0)
    test::i(CheckClass(obj1,cTestChild2),=,0)
    test::i(CheckClass(obj2,cTestChild2),=,0)
    test::i(CheckClass(obj3,cTestChild2),=,0)
    test::i(CheckClass(obj4,cTestChild2),=,0)
    test::i(CheckClass(obj5,cTestChild2),<>,0)
  _EndProcedure
  CheckTest()
  ;}
  
  Test::set("Modul Test");-{ Modul Test
  DeclareModule TestModul1
    UseModule EnableClass
    
    
    DeclareClass(cTm1)
      Get()
      Set(v.i)
      Properties
      value.i
    EndDeclareClass
    
    ;Interface cTM1
    ;  Get()
    ;  Set(v.i)
    ;EndInterface
    ;InitalizeClassEx(cTM1)
    ;  value.i
    ;EndInitalizeClassEx
    
  EndDeclareModule
  Module TestModul1
    Class(cTM1)
      Method(i,Get)
        MethodReturn (*self\value)
      EndMethod
      Method(i,Set, (This,v.i) )
        *self\value=v
      EndMethod
    EndClass
  EndModule
  
  Procedure Test_Modul1()
    Protected_Object(obj1,TestModul1::cTM1)
    obj1\set(10)
    Test::i(obj1\get(),=,10)
  _EndProcedure
  
  DeclareModule TestModul2
    UseModule EnableClass
    Declare Output()
    Declare Output2()
  EndDeclareModule
  Module TestModul2
    Interface cTM2 Extends TestModul1::cTM1
      Get2()
      Set2(v.i)
    EndInterface
    InitalizeClass(cTm2, TestModul1::cTM1)
    
    Class(cTM2)
      Value2.i
      Method(i,Get2)
        MethodReturn (*self\Value2)
      EndMethod
      Method(i,Set2, (This,v.i) )
        *self\Value2=v
      EndMethod
    EndClass
    
    Global_Object(obj2,cTM2)
    
    Procedure Output()
      obj2\set(11)
      ProcedureReturn obj2\get()
    EndProcedure
    
    Procedure Output2()
      obj2\set2(22)
      ProcedureReturn obj2\get2()
    EndProcedure
  EndModule
  
  DeclareModule TestModul3
    UseModule EnableClass
    Global_Object(obj1,TestModul1::cTM1)
  EndDeclareModule
  Module TestModul3
    obj1\set(33)
  EndModule
  
  Test_Modul1()
  test::i(TestModul2::Output(),=,11)
  test::i(TestModul2::Output2(),=,22)
  test::i(TestModul2::Output(),=,11)
  test::i(TestModul2::Output2(),=,22)  
  test::i(TestModul3::obj1\get(),=,33)        
  ;}
  
  Test::Set("Allocate Test");-{ Allocate Test
  Procedure Allocate1()
    Define *obj.cVar
    *obj=AllocateObject(cVar)
    *obj\set(912)
    test::i(*obj\get(),=,912)
    FreeObject(*obj)  
    *obj=0
  EndProcedure  
  Procedure Allocate2()
    Define *obj.cVar
    Define *obj2.cVar
    *obj=AllocateObject(cVar)
    *obj\set(193)
    test::i(*obj\get(),=,193)
    *obj2=CloneObject(*obj)
    test::i(*obj2\get(),=,193)
    
    FreeObject(*obj)
    test::i(*obj2\get(),=,193)
    FreeObject(*obj2)
  EndProcedure
  
  Allocate1()
  Allocate2()
  ;}
  
  Test::set("Class Name Test");-{ Class Name Test
  Procedure ClassName()
    Define_Object(obj1,cTestParent)
    Define_Object(obj2,cTestChild)
    Define_Object(obj3,cTestGrandChild)
    Define_Object(obj4,cVar)
    ;test::s(GetObjectClassName(obj1),=,GetClassName(cTestParent))
    ;test::s(GetObjectClassName(obj2),=,GetClassName(cTestChild))
    ;test::s(GetObjectClassName(obj3),=,GetClassName(cTestGrandChild))
    ;test::s(GetObjectClassName(obj4),=,GetClassName(cVar))
  _EndProcedure
  ClassName()
  ;}
  
  Test::set("Overwrite Method Test");-{ Overwrite Method Test
  Procedure Overwrite()
    Define_Object(obj1,cVar2)
    obj1\Set(30)
    test::i(obj1\Get(),=,60)
    obj1\OldSet(30)
    test::i(obj1\Get(),=,30)
    Define *obj.cVar=obj1
    *obj\Set(30)
    test::i(*obj\Get(),=,60)
    
  _EndProcedure
  Overwrite()
  ;}
  
  Test::Set("BaseClass Test");-{ BaseClass Test
  Procedure baseclass()
    Define_Object(obj1,cvar)
    obj1\set(30)
    
    Define *obj.oop::object
    Define *obj2.cvar
    Define *new.cVar
    *obj=obj1
    
    *new=CloneObject(*obj)
    test::i(*new\get(),=,30)
    *new\set(20)
    test::i(*new\get(),=,20)
    test::i(obj1\get(),=,30)
    
    
    *obj=AllocateObject(cVar)
    CopyObject(*new,*obj)
    
    *obj2=*obj
    test::i(*obj2\get(),=,20)
    *obj2\set(10)
    test::i(*obj2\get(),=,10)
    test::i(*new\get(),=,20)
    
    ;test::s(GetObjectClassName(*obj),=,GetClassName(cVar))
    ;test::s(GetObjectClassName(*obj2),=,GetClassName(cVar))
    ;test::s(GetObjectClassName(*new),=,GetClassName(cVar))
    
    ;test::i(SizeOfObject(*obj),=,SizeOfClass(cVar))
    ;test::i(SizeOfObject(*obj2),=,SizeOfClass(cVar))
    ;test::i(SizeOfObject(*new),=,SizeOfClass(cVar))
    
    FreeObject(*obj)
    FreeObject(*new)
    
  _EndProcedure
  baseclass()
  ;}
  
  Test::set("Objects in Class Test");-{ Objects in Class Test
  Procedure ObjInClass()
    Define_Object(obj,cSubs)
    Define_Object(obj2,cSubs)
    obj\Set(1,33)
    obj\Set(2,55)
    obj2\Set(1,233)
    obj2\Set(2,255)
    test::i(obj\Get(1),=,33)
    test::i(obj\Get(2),=,55)
    test::i(obj2\Get(1),=,233)
    test::i(obj2\Get(2),=,255)
  _EndProcedure
  Procedure ObjInClass2()
    Define_Object(obj,cSubs2)
    Define_Object(obj2,cSubs2)
    obj\Set(1,66)
    obj\Set(2,99)
    obj2\Set(1,266)
    obj2\Set(2,299)
    test::i(obj\Get(1),=,66)
    test::i(obj\Get(2),=,99)
    test::i(obj2\Get(1),=,266)
    test::i(obj2\Get(2),=,299)
    test::i(CopyObject(obj2,obj),=,#True)
    test::i(obj\Get(1),=,266)
    test::i(obj2\Get(1),=,266)
    obj\Set(1,399)
    test::i(obj\Get(1),=,399)
    test::i(obj2\Get(1),=,266)
    
    ;ProcedureReturn 0
  _EndProcedure
  Procedure ObjInClass3()
    Define_Object(obj,cDeep5)
    Define_Object(obj2,cDeep5)
    Define i
    For i=1 To 6
      obj\Set(i,i)
      obj2\set(i,i*10)
    Next
    For i=1 To 6
      test::i(obj\get(i),=,i)
      test::i(obj2\get(i),=,i*10)
      test::i(obj\getfake(i),<>,obj2\getfake(i))
    Next
    test::i(obj\getfake2(),<>,obj2\getfake2())
    test::i(obj\getfake3(),<>,obj2\getfake3())
    test::i(CopyObject(obj2,obj),=,#True)
    For i=1 To 6
      test::i(obj\get(i),=,i*10)
      test::i(obj2\get(i),=,i*10)
      test::i(obj\getfake(i),<>,obj2\getfake(i))
    Next
    test::i(obj\getfake2(),<>,obj2\getfake2())
    test::i(obj\getfake3(),<>,obj2\getfake3())
    For i=1 To 6
      obj\Set(i,i)
    Next
    For i=1 To 6
      test::i(obj\get(i),=,i)
      test::i(obj2\get(i),=,i*10)
    Next
    test::i(CopyObject(obj,obj),=,#False)
    For i=1 To 6
      test::i(obj\get(i),=,0)
      test::i(obj2\get(i),=,i*10)
    Next
  _EndProcedure
  Procedure ObjInClass4()
    Define_Object(obj,cDeep5)
    Define *obj2.cDeep5
    Define i
    For i=1 To 6
      obj\Set(i,i)
    Next
    
    *obj2=CloneObject(obj)
    test::i(*obj2,<>,#False)
    If *obj2
      For i=1 To 6
        test::i(obj\get(i),=,i)
        test::i(*obj2\get(i),=,i)
        test::i(obj\getfake(i),<>,*obj2\getfake(i))
      Next
      test::i(obj\getfake2(),<>,*obj2\getfake2())
      test::i(obj\getfake3(),<>,*obj2\getfake3())
      For i=1 To 6
        *obj2\Set(i,i*10)
      Next
      For i=1 To 6
        test::i(obj\get(i),=,i)
        test::i(*obj2\get(i),=,i*10)
      Next
      
      FreeObject(*obj2)
    EndIf
  _EndProcedure
  
  ObjInClass()
  ObjInClass2()
  ObjInClass3()
  test::i(listfake(),=,#True)
  objinclass4()
  test::i(listfake(),=,#True)
  ;}
  
  Test::Set("Reset Test");-{ Reset Test
  Procedure ResetTest()
    Protected_Object(obj1,cVar)
    obj1\Set(20)
    test::i(Obj1\Get(),=,20)
    ResetObject(obj1)
    test::i(obj1\Get(),=,0)
  _EndProcedure
  ResetTest()
  ;}
  
  Test::Set("ClassID Test");-{ Reset Test
  Procedure ClassIDTest()
    Protected_Object(obj1,cVar)
    ;test::i(GetObjectClassID(obj1),=,GetClassID(cVar))
    ;test::i(GetObjectClassID(obj1),<>,GetClassID(cVar2))
  _EndProcedure
  ClassIDTest()
  ;}
  
  Test::Set("Mutex Test");-{ Mutex Test
  Procedure MutexThread(*obj.cMutex)
    *obj\Output("Thread:" +Str( Random(100) ) )
  EndProcedure
  Procedure MutexTest()
    Protected t1,t2,t3
    Protected_Object (myobj,cMutex)
    t1=CreateThread(@MutexThread(),myobj)
    Delay(100)
    t2=CreateThread(@MutexThread(),myobj)
    Delay(100)
    t3=CreateThread(@MutexThread(),myobj)
    
    WaitThread(t1)
    WaitThread(t2)
    WaitThread(t3)
    
    Protected_Object(myObj2,cNoMutex)
    t1=CreateThread(@MutexThread(),myobj2)
    Delay(100)
    t2=CreateThread(@MutexThread(),myobj2)
    Delay(100)
    t3=CreateThread(@MutexThread(),myobj2)
    
    WaitThread(t1)
    WaitThread(t2)
    WaitThread(t3)
  _EndProcedure
  MutexTest()  
  ;}
  
  Test::Set("NoCreate Test");-{ NoCreate
  Procedure NoCreateTest()
    Protected_Object(obj1,cNoCreate)
    Protected *obj2.cNoCreate
    Protected_Object(obj3,cNCChild)
    Protected *obj4.cNCChild
    
    test::i(obj1,=,0)
    *obj2=AllocateObject(cNoCreate)
    test::i(*obj2,=,0)
    
    test::i(obj3,<>,0)
    *obj4=AllocateObject(cNCChild)
    test::i(*obj4,<>,0)
    
    FreeObject(*obj4)    
  _EndProcedure
  NoCreateTest()
  ;}
  
  
  
  ; TODO alles bei disposechain löschen
  _FakeEnd
  
  
  
  
  CompilerIf #PB_Compiler_Debugger
    Test::set("All objects disposed?")
    test::i(oop::ObjectCount,=,0)
    
  CompilerEndIf
  
  
  ;- Class Declaration
  
  
  
  Class (cTestChild) ;-cTestChild
    *fakemem
    
    Method(i,Initalize)
      init_test*2
      *self\fakemem=fakealloc()
    EndMethod
    Method(i,Dispose)
      init_test*4
      fakefree(*self\fakemem)
      *self\fakemem=0
    EndMethod
    Method(i,Clone)
      ;*old=*self\fakmem
      *self\fakemem=fakealloc()
      ;copy *old\fakemem to *self\fakemem
      Clone_Test*3
      MethodReturn (#True)
    EndMethod        
    Method(i,get)
      MethodReturn (*self\fakemem)
    EndMethod    
  EndClass
  
  
  
  Class(cTestGrandChild);- cTestGrandchild
    value.i
    Method(i,Initalize)
      init_test+6
    EndMethod
    Method(i,Dispose)
      init_test-2
    EndMethod
    Method(i,Clone)      
      Clone_test+9
      MethodReturn (#True)
    EndMethod
    Method(i,GetVar)
      MethodReturn (*self\value)
    EndMethod
    Method(i,SetVar, (This,v.i) )
      This\value=v
    EndMethod
    
  EndClass
  
  
  Class(cTestChild2);- cTestChild2
    
    Method(i,Initalize)
      init_test*5
    EndMethod
    Method(i,Dispose)
      init_test*13
    EndMethod
    Method(i,Clone)
      Clone_test*7
      MethodReturn (#True)
    EndMethod
  EndClass
  
  Class(cTestCloneFail);- cTestCloneFail
    Method(i,Clone)
      Debug "CloneFailCheck"
      
      MethodReturn (#False)
    EndMethod
  EndClass
  
  
  Class(cVar);- cVar
    value.i
    
    Method(i,Set, (This,x.i))
      *self\value=x
    EndMethod
    Method(i,Get)
      MethodReturn (*self\value)
    EndMethod
  EndClass
  
  Class(cVar2);- cVar2
    MethodAlias(Set,OldSet)
    Method(i,Set, (This,x) )
      *self\value=x*2
    EndMethod
  EndClass
  
  
  Class(CSubs);- cSubs
    Var.cVar
    Var2.cVar
    
    InitalizeObject(Var,cVar)
    InitalizeObject(Var2,cVar)
    Method(i,Get, (This, w.i) )
      If w=1
        MethodReturn (*self\Var\Get())
      EndIf
      MethodReturn (*self\Var2\Get())
    EndMethod
    Method(i,Set, (This,w.i,v.i) )
      If w=1
        MethodReturn (*self\Var\Set(v))
      EndIf
      MethodReturn (*self\Var2\Set(v))
    EndMethod
  EndClass
  
  
  Class(CSubs2);- cSubs2
    Var.cVar[2]
    
    InitalizeObject(Var,cVar,2)
    Method(i,Get, (This, w.i) )
      MethodReturn (*self\Var[w-1]\Get())
    EndMethod
    Method(i,Set, (This,w.i,v.i) )
      MethodReturn (*self\Var[w-1]\Set(v))
    EndMethod
  EndClass
  
  Class(cDeep1);- cDeep1
    *fakemem
    value.i
    Method(i,Initalize)
      *self\fakemem=fakealloc()
    EndMethod
    Method(i,Dispose)
      fakefree(*self\fakemem)
      *self\fakemem=0
    EndMethod
    Method(i,Clone)
      *self\fakemem=fakealloc()
      ;copy *old\fakemem to *self\fakemem
      MethodReturn (#True)
    EndMethod   
    Method(i,Set, (This,v.i) )
      *self\value=v
    EndMethod
    Method(i,Get)
      MethodReturn (*self\value)
    EndMethod
    Method(i,GetFake)
      MethodReturn (*self\fakemem)
    EndMethod    
  EndClass
  
  Class(cDeep2);- cDeep2
    *fakemem
    value.i
    var.cDeep1[2]
    var99.cDeep1
    
    InitalizeObject(var,cDeep1,2)
    InitalizeObject(var99,cDeep1)
    
    Method(i,Initalize)
      *self\fakemem=fakealloc()
    EndMethod
    Method(i,Dispose)
      fakefree(*self\fakemem)
      *self\fakemem=0
    EndMethod
    Method(i,Clone)
      *self\fakemem=fakealloc()
      ;copy *old\fakemem to *self\fakemem
      MethodReturn (#True)
    EndMethod   
    Method(i,Set, (This,p.i,v.i) )
      If p=1
        *self\var\set(v)
      Else
        *self\value=v
      EndIf      
    EndMethod
    Method(i,Get, (This,p.i) )
      If p=1
        MethodReturn (*self\var\get())
      Else
        MethodReturn (*self\value)
      EndIf      
    EndMethod
    Method(i,GetFake, (This,p) )
      If p=1
        MethodReturn (*self\var\getfake())
      Else
        MethodReturn (*self\fakemem)
      EndIf
    EndMethod
  EndClass
  
  Class(cDeep3);- cDeep3
    *fakemem
    value.i
    var.cDeep2
    
    InitalizeObject (var,cDeep2)
    
    Method(i,Initalize)
      *self\fakemem=fakealloc()
    EndMethod
    Method(i,Dispose)
      fakefree(*self\fakemem)
      *self\fakemem=0
    EndMethod
    Method(i,Clone)
      *self\fakemem=fakealloc()
      ;copy *old\fakemem to *self\fakemem
      MethodReturn (#True)
    EndMethod   
    Method(i,Set, (This,p.i,v.i) )
      If p=1 Or p=2
        *self\var\set(p,v)
      Else
        *self\value=v
      EndIf      
    EndMethod
    Method(i,Get, (This,p.i) )
      If p=1 Or p=2
        MethodReturn (*self\var\get(p))
      Else
        MethodReturn (*self\value)
      EndIf      
    EndMethod
    Method(i,GetFake, (This,p) )
      If p=1 Or p=2
        MethodReturn (*self\var\getfake(p))
      Else
        MethodReturn (*self\fakemem)
      EndIf
    EndMethod
  EndClass
  
  Class(cDeep4);- cDeep4
    *fakemem
    var.cDeep3
    
    InitalizeObject(var,cDeep3)
    Method(i,Initalize)
      *self\fakemem=fakealloc()
    EndMethod
    Method(i,Dispose)
      fakefree(*self\fakemem)
      *self\fakemem=0
    EndMethod
    Method(i,Clone)
      *self\fakemem=fakealloc()
      ;copy *old\fakemem to *self\fakemem
      MethodReturn (#True)
    EndMethod   
    Method(i,Set, (This,p.i,v.i) )
      MethodReturn (*self\var\set(p,v))
    EndMethod
    Method(i,Get, (This,p.i) )
      MethodReturn (*self\var\get(p))
    EndMethod
    Method(i,GetFake, (This,p.i) )      
      MethodReturn (*self\var\getfake(p))
    EndMethod
    Method(i,GetFake2)
      MethodReturn (*self\fakemem)
    EndMethod    
  EndClass
  
  
  Class(cDeep5);- cDeep5
    *fakemem2
    var2.cDeep3
    
    InitalizeObject(var2,cDeep3)
    Method(i,Initalize)
      *self\fakemem2=fakealloc()
    EndMethod
    Method(i,Dispose)
      fakefree(*self\fakemem2)
      *self\fakemem2=0
    EndMethod
    Method(i,Clone)
      *self\fakemem2=fakealloc()
      ;copy *old\fakemem to *self\fakemem
      MethodReturn (#True)
    EndMethod   
    Method(i,Set, (This,p.i,v.i) )
      If p<4
        *self\var\set(p,v)
      Else
        *self\var2\set(p-3,v)
      EndIf      
    EndMethod
    Method(i,Get, (This,p.i) )
      If p<4
        MethodReturn (*self\var\get(p))
      Else
        MethodReturn (*self\var2\get(p-3))
      EndIf      
    EndMethod
    Method(i,GetFake3)
      MethodReturn (*self\fakemem2)
    EndMethod    
  EndClass
  
  Class(cMutex,oop::#AutoMutex);-cMutex
    Method(i,Output, (This,text.s) )
      Protected i
      For i=0 To 4
        PrintN("Mutex-Test:"+i+" "+text)
        Delay(200)
      Next
    EndMethod
  EndClass
  
  Class(cNoMutex);-cNoMutex
    Method(i,Output, (This,text.s) )
      Protected i
      For i=0 To  4
        PrintN("NoMutex-Test:"+i+" "+text)
        Delay(200)
      Next
    EndMethod
  EndClass
  
  Class(cNoCreate,oop::#NoCreation) ;- cNoCreate
  EndClass
  
  Class(cNCChild) ;- cNCChild
  EndClass
  
  
  Test::finish()
  
CompilerEndIf
