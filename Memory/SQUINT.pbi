;   Description: Squint is a compact prefix Trie indexed by nibbles into a sparse array with performance metrics close to a map
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=75783
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; SQUINT 2, Sparse Quad Union Indexed Nibble Trie
; Copyright (c) 2020 Andrew Ferguson
; Version 2.0.5b
; PB 5.72 x86 x64 Linux OSX Windows
; Thanks Wilbert for the high low insight and utf8 str asm help.
; Squint is a compact prefix Trie indexed by nibbles into a sparse array with performance metrics close to a map
; It provides O(K*2) performance with a memory size ~32 times smaller than a 256 node Trie
; The overheads are similar to that of a QP Trie, thats a 1/3 smaller than a Critbit.
; In terms of speed SquintSet and SquintGet should be at worst ~2 times slower than a Map.
; Lexographical enumerations are however magnitudes faster than what you could achieve otherwise
; In fast Numeric mode it's gets are closer to 1:1 with a map
;
; see https://en.wikipedia.org/wiki/Trie
;     https://dotat.at/prog/qp/blog-2015-10-04.html
;     https://cr.yp.to/critbit.html
;
; Squint supports Set, Get, Enum, Walk, Delete and Prune with a flag in Delete
; keys can be either Unicode, Ascii, UTF8 or Integers, the type must be specified
; keys are all mapped to UTF8
;
; SquintNumeric (fast numeric) supports, SetNumeric GetNumeric DeleteNumeric and WalkNumeric
; it's provided as a direct subtitute for a numeric map, though lacks enumeration
; keys are returned as Integers 
;
; MIT License
; Permission is hereby granted, SquintFree of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; To use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS Or
; IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF MERCHANTABILITY,
; FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For ANY CLAIM, DAMAGES Or OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT Or OTHERWISE, ARISING FROM,
; OUT OF Or IN CONNECTION With THE SOFTWARE Or THE USE Or OTHER DEALINGS IN THE
; SOFTWARE.

DeclareModule SQUINT
  
  #SQUINT_MAX_KEY = 1024
  
  Structure squint_node
    *vertex.edge
    StructureUnion
      squint.q
      value.i
    EndStructureUnion
  EndStructure   
  
  Structure edge
    e.squint_node[0]
  EndStructure
  
  Structure squint
    *vt
    *root.squint_node
    size.l
    datasize.l
    count.l
    ib.a[22]
    sb.a[#SQUINT_MAX_KEY]
  EndStructure
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
    #Squint_Pmask = $ffffffff
  CompilerElse
    #Squint_Pmask = $ffffffffffff
  CompilerEndIf
  
  ;-Squint Callback prototype
  Prototype Squint_CB(*key,*value=0,*userdata=0)
  
  Declare SquintNew()
  Declare SquintFree(*this.Squint)
  Declare SquintDelete(*this.squint,*key,prune=0,mode=#PB_Unicode)
  Declare SquintSet(*this.squint,*key,value.i,mode=#PB_Unicode)
  Declare SquintGet(*this.squint,*key,mode=#PB_Unicode)
  Declare SquintEnum(*this.squint,*key,*pfn.squint_CB,*userdata=0,ReturnMatch=0,mode=#PB_Unicode)
  Declare SquintWalk(*this.squint,*pfn.squint_CB,*userdata=0)
  Declare SquintSetNumeric(*this.squint,key.i,value.i)
  Declare SquintGetNumeric(*this.squint,key.i)
  Declare SquintDeleteNumeric(*this.squint,key.i)
  Declare SquintWalkNumeric(*this.squint,*pfn.squint_CB,*userdata=0)
  
  ;-Squint Inteface iSquint 
  Interface iSquint
    Free()
    Delete(*key,prune=0,mode=#PB_Unicode)
    Set(*key,value.i,mode=#PB_Unicode)
    Get(*key,mode=#PB_Unicode)
    Enum(*key,*pfn.squint_CB,*userdata=0,ReturnMatch=0,mode=#PB_Unicode)
    Walk(*pfn.squint_CB,*userdata=0)
    SetNumeric(key.i,value.i)
    GetNumeric(key.i)
    SquintDeleteNumeric(key.i)
    WalkNumeric(*pfn.Squint_CB,*userdata=0)
  EndInterface
  
  DataSection: vtSquint:
    Data.i @SquintFree()
    Data.i @SquintDelete()
    Data.i @SquintSet()
    Data.i @SquintGet()
    Data.i @SquintEnum()
    Data.i @SquintWalk()
    Data.i @SquintSetNumeric()
    Data.i @SquintGetNumeric()
    Data.i @SquintDeleteNumeric()
    Data.i @SquintWalkNumeric()
  EndDataSection   
  
EndDeclareModule

Module SQUINT
  
  EnableExplicit
  ;-macros
  Macro _SETINDEX(in,index,number)
    in = in & ~(15 << (index << 2)) | (number << (index << 2))
  EndMacro
  
  Macro _GETNODECOUNT()
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      nodecount = MemorySize(*node\vertex) / SizeOf(squint_node)
    CompilerElse
      nodecount = (*node\vertex >> 48)
    CompilerEndIf
  EndMacro
  
  Macro _POKENHL(in,Index,Number)
    *Mem.Ascii = in
    *Mem + Index >> 1
    If Index & 1
      *Mem\a = (*Mem\a & $f0) | (Number & $f)
    Else
      *Mem\a = (*Mem\a & $0f) | (Number << 4)
    EndIf
  EndMacro
  
  Macro _STR()
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      ; backup registers
      !mov [rsp - 8], rbx
      !mov [rsp - 16], rdi
      ; get procedure arguments
      !mov rax, [p.v_char]
      !mov rdi, [p.p_out]
      ; determine sign
      !xor ebx, ebx
      !cmp rax, rbx
      !jge .l0
      !neg rax
      !mov rdx, 1
      !mov [rsp - 24],rdx
      !.l0:
      ; convert number to ascii characters
      !add rdi, 22
      !mov byte [rdi], 0
      !mov rbx, 0xcccccccccccccccd
      !.l1:
      !mov rcx, rax
      !mul rbx
      !mov rax, rdx
      !shr rax, 3
      !imul rdx, rax, 10
      !sub rcx, rdx
      !or rcx, 0x30
      !sub rdi, 1
      !mov [rdi], cl
      !test rax, rax
      !jnz .l1
      ;look up sign
      !mov rax,[rsp-24]
      !cmp rax,1
      !jnz .l2
      !sub rdi, 1
      !mov byte [rdi], '-'
      !.l2:
      ;store start of string
      !mov [p.v_offset],rdi
      ;restore registers
      !mov rdi, [rsp - 16]
      !mov rbx, [rsp - 8]
    CompilerElse
      ; backup registers
      !mov [esp - 4], ebx
      !mov [esp - 8], edi
      ; get procedure arguments
      !mov eax, [p.v_char]
      !mov edi, [p.p_out]
      ; determine length
      !xor ebx, ebx
      !cmp eax, ebx
      !jge .l0
      !neg eax
      !mov edx, 1
      !mov [esp - 12],edx
      !.l0:
      ; convert number to ascii characters
      !add edi, 22
      !mov byte [edi], 0
      !mov ebx, 0xcccccccd
      !.l1:
      !mov ecx, eax
      !mul ebx
      !mov eax, edx
      !shr eax, 3
      !imul edx, eax, 10
      !sub ecx, edx
      !or ecx, 0x30
      !sub edi, 1
      !mov [edi], cl
      !test eax, eax
      !jnz .l1
      ;look up sign
      !mov eax,[esp-12]
      !cmp eax,1
      !jnz .l2
      !sub edi, 1
      !mov byte [edi], '-'
      !.l2:
      ;store offset to start of string
      !mov [p.v_offset],edi
      ;restore registers
      !mov edi, [esp - 8]
      !mov ebx, [esp - 4]
    CompilerEndIf
    
  EndMacro
  
  Macro _CONVERTUTF8()
    If mode <> #PB_Integer
      char= PeekU(*key)
    Else   
      char = PeekI(*key)
      *out = @*this\ib[0]
      _STR()
      *key = offset
      mode = #PB_Ascii
      char= PeekU(*key)
    EndIf
    
    If mode = #PB_Unicode 
      !mov eax, [p.v_char]
      !cmp eax, 0x0080
      !jb .l3
      !cmp eax, 0x0800
      !jae .l4
      !shl eax, 2
      !shr al, 2
      !or eax, 1100000010000000b
      !bswap eax
      !shr eax, 16
      !jmp .l3
      !.l4:
      !shl eax, 4
      !shr ax, 2
      !shr al, 2
      !or eax, 111000001000000010000000b
      !bswap eax
      !shr eax, 8
      !.l3:
      !mov [p.v_char],eax
    EndIf
  EndMacro
  
  Macro _MODECHECK()
    _CONVERTUTF8()
    If mode <> #PB_Unicode
      If (char >> ((count&1)<<4) & $ff = 0)
        Break
      EndIf
    Else
      *this\datasize+1
    EndIf
  EndMacro
  
  Macro _SETNODE()
    If *node\vertex
      _GETNODECOUNT()
      If (offset <> 15 Or nodecount = 16)
        *node = *node\Vertex\e[offset] & #Squint_Pmask
      Else 
        *this\size + SizeOf(squint_node)
        offset = nodecount
        nodecount+1
        *node\vertex = ReAllocateMemory(*node\vertex & #Squint_Pmask,(nodecount)*SizeOf(squint_node))
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
          *node\vertex | ((nodecount) << 48)
        CompilerEndIf
        _SETINDEX(*node\squint,idx,offset)
        *node = *node\Vertex\e[offset] & #Squint_Pmask
      EndIf
    Else
      *this\size + SizeOf(squint_node)
      *node\vertex = AllocateMemory(SizeOf(squint_Node))
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        *node\vertex | (1 << 48)
      CompilerEndIf
      *node\squint = -1
      _SETINDEX(*node\squint,idx,0)
      *node = *node\Vertex\e[0] & #Squint_Pmask
      *this\count+1
    EndIf
  EndMacro
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
    Macro rax : eax : EndMacro
  CompilerEndIf   
  ;-General functions
  Procedure SquintNew()
    Protected *this.squint,a
    *this = AllocateMemory(SizeOf(squint))
    If *this
      *this\vt = ?vtSquint
      *this\root = AllocateMemory(SizeOf(squint_node))
      ProcedureReturn *this
    EndIf
  EndProcedure
  
  Procedure ISquintFree(*this.squint,*node.squint_node=0)
    Protected a,offset,nodecount
    If Not *node
      ProcedureReturn 0
    EndIf
    For a=0 To 15
      offset = (*node\squint >> (a<<2)) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          ISquintFree(*this,*node\Vertex\e[offset] & #Squint_Pmask)
        EndIf
      EndIf
    Next
    If *node\vertex
      _GETNODECOUNT()
      *this\size - nodecount
      *this\count - 1
      FreeMemory(*node\Vertex & #Squint_Pmask)
      *node\vertex=0
    EndIf
    ProcedureReturn *node
  EndProcedure
  
  Procedure SquintFree(*this.squint)
    Protected a,offset,*node.squint_node,nodecount
    *node = *this\root
    For a=0 To 15
      offset = (*node\squint >> (a<<2)) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          ISquintFree(*this,*node)
        EndIf
      EndIf
    Next
    FreeMemory(*this\root)
    nodecount = *this\count
    FreeMemory(*this)
    ProcedureReturn nodecount
  EndProcedure
  ;-string functions
  Procedure SquintDelete(*this.squint,*key.Unicode,prune=0,mode=#PB_Unicode)
    Protected *node.squint_node,idx,*mem.Character,offset,nodecount,char.i,count,*out
    *node = *this\root
    _CONVERTUTF8()
    While char
      offset = (*node\squint >> ((char & $f0) >> 2 )) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          *node = *node\Vertex\e[offset] & #Squint_Pmask
        EndIf
      Else
        ProcedureReturn 0
      EndIf
      If *node
        offset = (*node\squint >> ((char & $0f) << 2)) & $f
        If *node\vertex
          _GETNODECOUNT()
          If (offset <> 15 Or nodecount = 16)
            *node = *node\Vertex\e[offset] & #Squint_Pmask
          EndIf
        Else
          ProcedureReturn 0
        EndIf
      EndIf
      char >> 8
      If char = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    If prune
      ISquintFree(*this,*node)
      If (*node\vertex & #Squint_Pmask) = 0
        *node\squint = 0
      EndIf
    Else
      offset = *node\squint & $f
      _GETNODECOUNT()
      If offset <= nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        If (*node\vertex & #Squint_Pmask) = 0
          *node\squint = 0
        EndIf
      Else
        ProcedureReturn 0
      EndIf
    EndIf
  EndProcedure
  
  Procedure SquintSet(*this.squint,*key,value.i,mode=#PB_Unicode)
    Protected *node.squint_node,idx,offset,nodecount,char.i,count,*out
    *node = *this\root & #Squint_Pmask
    _CONVERTUTF8()
    While char
      idx = (char >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SETNODE()
      idx = char & $0f
      offset = (*node\squint >> (idx<<2)) & $f
      _SETNODE()
      *this\datasize+1
      char >> 8
      count+1
      If char = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    idx=0
    offset = *node\squint & $f
    _SETNODE()
    *node\value = value
    ProcedureReturn
  EndProcedure
  
  Procedure SquintGet(*this.squint,*key,mode=#PB_Unicode)
    Protected *node.squint_Node,idx,offset,nodecount,char.i,count,*out
    *node = *this\root & #Squint_Pmask
    _CONVERTUTF8()
    While char
      offset = (*node\squint >> ((char & $f0) >> 2 )) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      offset = (*node\squint >> ((char & $0f) << 2)) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      char >> 8
      count+1
      If char = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    offset = *node\squint & $f
    _GETNODECOUNT()
    If offset <= nodecount
      *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      ProcedureReturn *node\value
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure IEnum(*this.squint,*node.squint_Node,depth,*pfn.squint_CB,*userdata=0)
    Protected a.i,offset,nodecount,*mem.Ascii
    If Not *node
      ProcedureReturn 0
    EndIf
    For a=0 To 15
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          _POKENHL(@*this\sb,depth,a)
          IEnum(*this,*node\Vertex\e[offset] & #Squint_Pmask,depth+1,*pfn,*userdata)
        EndIf
      EndIf
    Next
    If *node\vertex=0
      If *pfn
        PokeA(@*this\sb+((depth>>1)),0)
        *pfn(@*this\sb,*node\value,*userdata)
      EndIf
    EndIf
    ProcedureReturn *node
  EndProcedure
  
  Procedure SquintEnum(*this.squint,*key.Unicode,*pfn.squint_CB,*userdata=0,ReturnMatch=0,mode=#PB_Unicode)
    Protected *node.squint_Node,idx,*mem.Ascii,offset,nodecount,depth,char.i,count,*out
    If ReturnMatch
      If SquintGetNumeric(*this,*key)
        If *pfn
          *pfn(*key,0,*userdata)
        EndIf
        ProcedureReturn
      EndIf
    EndIf
    *node = *this\root
    _CONVERTUTF8()
    While char
      idx = (char >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          ;POKENHL(@*this\sb,depth,idx)
          *mem = @*this\sb+(depth>>1)
          *mem\a = (*mem\a & $0f) | (idx<<4)
          depth+1
          *node = *node\Vertex\e[offset] & #Squint_Pmask
        EndIf
      EndIf
      If Not *node Or *node\vertex = 0
        ProcedureReturn 0
      EndIf
      idx = char & $f
      offset = (*node\squint >> (idx<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          ;POKENHL(@*this\sb,depth,idx)
          *mem = @*this\sb+(depth>>1)
          *Mem\a = (*Mem\a & $f0) | (idx & $f)
          depth+1
          *node = *node\Vertex\e[offset] & #Squint_Pmask
        EndIf
      EndIf
      If Not *node Or *node\vertex = 0
        ProcedureReturn 0
      EndIf
      char >> 8
      count+1
      If char = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    IEnum(*this,*node,depth,*pfn,*userdata)
  EndProcedure
  
  Procedure SquintWalk(*this.squint,*pfn.squint_CB,*userdata=0)
    IEnum(*this,*this\root,0,*pfn,*userdata)
  EndProcedure
  
  ;-Numeric functions
  Procedure SquintSetNumeric(*this.squint,key.i,value.i)
    Protected *node.squint_node,idx,offset,nodecount,char.i,count
    *node = *this\root & #Squint_Pmask
    char = key
    EnableASM
    mov rax, char
    bswap rax;
    mov char,rax
    DisableASM
    While count < SizeOf(Integer)
      idx = (char >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      idx = (char & $f)
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      *this\datasize+1
      char >> 8
      count+1
    Wend
    *node\value = value
    ProcedureReturn
  EndProcedure
  
  Procedure SquintGetNumeric(*this.squint,key.i)
    Protected *node.squint_Node,idx,offset,nodecount,char.i,count,skey.s
    *node = *this\root & #Squint_Pmask
    char = key
    EnableASM
    mov rax, char
    bswap rax;
    mov char,rax
    DisableASM
    While count < SizeOf(Integer)
      offset = (*node\squint >> ((char & $f0) >> 2 )) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      offset = (*node\squint >> ((char & $0f) << 2)) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      char>>8
      count+1
    Wend
    ProcedureReturn *node\value
  EndProcedure
  
  Procedure SquintDeleteNumeric(*this.squint,key.i)
    Protected *node.squint_node,idx,*mem.Character,offset,nodecount,char.i,count
    *node = *this\root & #Squint_Pmask
    char = key
    EnableASM
    mov rax, char
    bswap rax;
    mov char,rax
    DisableASM
    While count < SizeOf(Integer)
      offset = (*node\squint >> ((char & $f0) >> 2 )) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      offset = (*node\squint >> ((char & $0f) << 2)) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      char>>8
      count+1
    Wend
    If (*node\vertex & #Squint_Pmask) = 0
      *node\squint = 0
    EndIf
  EndProcedure
  
  Procedure IEnumNumeric(*this.squint,*node.squint_Node,idx,depth,*pfn.squint_CB,*userdata=0)
    Protected a.i,offset,nodecount,*mem.Ascii,char.i
    If Not *node
      ProcedureReturn 0
    EndIf
    For a=0 To 15
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          _POKENHL(@*this\sb,depth,a)
          IEnumNumeric(*this,*node\Vertex\e[offset] & #Squint_Pmask,0,depth+1,*pfn,*userdata)
        EndIf
      EndIf
    Next
    If *node\vertex=0
      char = PeekI(@*this\sb)
      EnableASM
      mov rax, char
      bswap rax;
      mov char,rax
      DisableASM
      If *pfn
        *pfn(@char,*node\value,*userdata)
      EndIf
    EndIf
    ProcedureReturn *node
  EndProcedure
  
  Procedure SquintWalkNumeric(*this.squint,*pfn.squint_CB,*userdata=0)
    IEnumNumeric(*this,*this\root,0,0,*pfn,*userdata)
  EndProcedure
  
  DisableExplicit
  ;-End of module   
EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  UseModule SQUINT
  
  Global msg.s
  
  Procedure Map_Enum(Map mp.i(),key.s,len)
    Protected NewList items.s()
    Protected word.s
    ForEach mp()
      word = MapKey(mp())
      If Left(word,len) = key
        AddElement(items())
        items() = word
      EndIf
    Next   
    SortList(items(),#PB_Sort_Ascending)
  EndProcedure   
  
  Procedure CBSquint(*key,*value,*userData)
    If *key
      msg + PeekS(*key,-1,#PB_UTF8) + #LF$
    EndIf   
  EndProcedure
  
  Procedure CBSquintUTF8(*key,*value,*userData)
    Debug PeekS(*key,-1,#PB_UTF8) + " " + PeekS(*userData)
  EndProcedure
  
  Procedure CBSquintAscii(*key,*value,*userData)
    Debug PeekS(*key,-1,#PB_Ascii) + " " + PeekS(*userData)
  EndProcedure
  
  Procedure CBSquintInteger(*key,*value,*userData)
    Debug PeekS(*userData)  + " " + Str(PeekI(*key)) + " / " + Str(*value) 
  EndProcedure
  
  Define ct=1000000
  Define *mt.squint = SquintNew()
  Define NewMap mp.i(ct)
  Define key.s,key1.s,*utf8,ikey
  Define TrieSet,TrieGet,MapSet,MapGet,TrieEnum,MapEnum,TrieSquintSetNum,TriGetNum
  Define st,et,a,seed = 1234
  
  CompilerIf #PB_Compiler_Debugger
    
    ;unicode
    key = Chr($f6) + Chr($20ac) + Chr($e0)
    SquintSet(*mt,@key,@key)
    Debug PeekS(SquintGet(*mt,@key)) + " test unicode SquintGet "
    key = Chr($f6)
    SquintEnum(*mt,@key,@CBSquintUTF8(),@"test unicode SquintEnum")
    
    ;UTF8
    key = Chr($f6) + Chr($20ac) + Chr($e0)
    *utf8 = UTF8(key)
    SquintSet(*mt,*utf8,*utf8,#PB_UTF8) ;overwrite the unicode key
    Debug PeekS(SquintGet(*mt,*utf8,#PB_UTF8),-1,#PB_UTF8) + " test utf8 SquintGet"
    FreeMemory(*utf8)
    *utf8 = UTF8(Chr($f6))
    SquintEnum(*mt,*utf8,@CBSquintUTF8(),@"test utf8 SquintEnum",0,#PB_UTF8)
    FreeMemory(*utf8)
    
    ;Ascii
    *ascii = Ascii("An ascii string")
    SquintSet(*mt,*ascii,*ascii,#PB_Ascii)
    Debug PeekS(SquintGet(*mt,*ascii,#PB_Ascii),-1,#PB_Ascii)
    FreeMemory(*ascii)
    *ascii = Ascii("An")
    SquintEnum(*mt,*ascii,@CBSquintAscii(),@"testing Ascii SquintEnum",0,#PB_Ascii)
    FreeMemory(*ascii)
    
    ;Numeric string
    a = -123456
    SquintSet(*mt,@a,a,#PB_Integer)
    Debug SquintGet(*mt,@a,#PB_Integer)
    a = -123
    SquintEnum(*mt,@a,@CBSquintUTF8(),@"test numeric SquintEnum",0,#PB_Integer)
    
    ;Fast Numeric
    SquintFree(*mt)
    *mt = SquintNew()
    
    For a = 500 To 1000
      SquintSetNumeric(*mt,a,a)
    Next   
    
    For a = 500 To 1000
      Debug SquintGetNumeric(*mt,a)
    Next   
    a=100
    SquintDeleteNumeric(*mt,a)
    
    Debug "test delete " + Str(SquintGetNumeric(*mt,a))
    Debug "test SquintWalk"
    SquintWalkNumeric(*mt,@CBSquintInteger(),@"SquintNumeric Key / Value: ")
    
    SquintFree(*mt)
    
    End
  CompilerEndIf
  
  RandomSeed(seed)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    SquintSet(*mt,@ikey,ikey,#PB_Integer)
  Next
  et = ElapsedMilliseconds()
  TrieSet = et-st
  
  RandomSeed(seed)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    mp(Str(ikey)) = ikey
  Next
  et = ElapsedMilliseconds()
  MapSet = et-st
  
  RandomSeed(seed+1)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    out = SquintGet(*mt,@ikey,#PB_Integer)
    If (ikey <> out And out <> 0)
      MessageRequester("error", Str(ikey) + " " + Str(out))
      End
    EndIf
  Next
  et = ElapsedMilliseconds()
  TrieGet = et-st
  
  RandomSeed(seed+1)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    out = mp(Str(ikey))
    If (ikey <> out And  out <> 0)
      MessageRequester("error", Str(ikey) + " " + Str(out))
      End
    EndIf
  Next
  et = ElapsedMilliseconds()
  MapGet = et-st
  
  st = ElapsedMilliseconds()
  key = "575"
  SquintEnum(*mt,@key,0)
  et = ElapsedMilliseconds()
  TrieEnum = et-st
  
  st = ElapsedMilliseconds()
  key = "575"
  Map_Enum(mp(),key,3)
  et = ElapsedMilliseconds()
  MapEnum = et-st
  
  msg.s = Trim(CPUName()) + " " + Str(SizeOf(integer)*8) + " bit" + #LF$
  msg.s + "Items " + Str(ct) + #LF$
  msg + "Squint Set " + Str(TrieSet) + " ms"+ #LF$
  msg + "Map Set " + Str(MapSet) + " ms" + #LF$
  msg + "Squint Get " + Str(TrieGet) + " ms" + #LF$
  msg + "Map Get " + Str(MapGet) + " ms" + #LF$
  msg + "Squint Enum " + Str(TrieEnum) + " ms" + #LF$
  msg + "Map Enum " + Str(MapEnum) + " ms" + #LF$
  msg + "=========================" + #LF$
  msg + "Squint Set Ratio " + StrF(TrieSet / MapSet,3) + " slower" + #LF$
  msg + "Squint Get Ratio " + StrF(TrieGet / MapGet,3) + " slower " + #LF$
  msg + "Squint Enum Ratio " + StrF(MapEnum / TrieEnum,3) + " faster " + #LF$
  msg + "=========================" + #LF$
  msg + "Key Input Size " + StrF(*mt\datasize / 1024 / 1024,2) + " mb" + #LF$
  msg + "Squint Memory Size " + StrF(*mt\size / 1024 / 1024,2) + " mb" + #LF$
  msg + "Overhead " + StrF(*mt\size / *mt\datasize,2) + " bytes input" + #LF$
  msg + "Map Size ~ " + StrF(((4*SizeOf(Integer)*MapSize(mp())*1.42)+*mt\datasize) / 1024 / 1024,2) + "mb" + #LF$
  
  SetClipboardText(msg)
  MessageRequester("SQUINT strings keys",msg)
  
  msg=""
  in.s = "57567"
  SquintEnum(*mt,@in,@cbsquint())
  SquintDelete(*mt,@in,1)
  msg + "Pruned from " + in + #LF$
  SquintEnum(*mt,@in,@cbsquint())
  msg + "check pune worked  SquintEnum again" + #LF$
  nodecount = SquintFree(*mt)
  msg + "SquintFree check node count is zero " + Str(Nodecount) 
  MessageRequester("Enumeration",msg)
  
  ;numeric test
  Define ikey.i
  msg=""
  
  FreeMap(Mp())
  NewMap mp.i(ct)
  *mt.SQUINT = SquintNew()
  
  RandomSeed(seed)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    SquintSetNumeric(*mt,ikey,ikey)
  Next
  et = ElapsedMilliseconds()
  TrieSet = et-st
  
  RandomSeed(seed)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    mp(Str(ikey)) = ikey
  Next
  et = ElapsedMilliseconds()
  MapSet = et-st
  
  RandomSeed(seed+1)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    out = SquintGetNumeric(*mt,ikey)
    If (ikey <> out And  out <> 0)
      MessageRequester("error", Str(ikey) + " " + Str(out))
      End
    EndIf
  Next
  et = ElapsedMilliseconds()
  TrieGet = et-st
  
  RandomSeed(seed+1)
  st = ElapsedMilliseconds()
  For a = 0 To ct
    ikey = Random($FFFFFF)
    out = mp(Str(ikey))
    If (ikey <> out And  out <> 0)
      MessageRequester("error", Str(ikey) + " " + Str(out))
      End
    EndIf
  Next
  et = ElapsedMilliseconds()
  MapGet = et-st
  
  msg.s + "Items " + Str(ct) + #LF$
  msg + "Squint Numeric Set " + Str(TrieSet) + " ms"+ #LF$
  msg + "Map Set " + Str(MapSet) + " ms" + #LF$
  msg + "Squint numeric Get " + Str(TrieGet) + " ms" + #LF$
  msg + "Map Get " + Str(MapGet) + " ms" + #LF$
  msg + "=========================" + #LF$
  msg + "Squint Set Ratio " + StrF(TrieSet / MapSet,3) + " slower" + #LF$
  msg + "Squint Get Ratio " + StrF(MapGet / TrieGet,3) + " faster" + #LF$
  msg + "=========================" + #LF$
  msg + "Key Input Size " + StrF(*mt\datasize / 1024 / 1024,2) + " mb" + #LF$
  msg + "Squint Memory Size " + StrF(*mt\size / 1024 / 1024,2) + " mb" + #LF$
  msg + "Overhead " + StrF(*mt\size / *mt\datasize,2) + " bytes input" + #LF$
  msg + "Map Size ~ " + StrF(((4*SizeOf(Integer)*MapSize(mp())*1.42)+*mt\datasize) / 1024 / 1024,2) + "mb" + #LF$
  
  SetClipboardText(msg)
  MessageRequester("SQUINT Integer keys",msg)
  
  SquintFree(*mt)
  
CompilerEndIf
