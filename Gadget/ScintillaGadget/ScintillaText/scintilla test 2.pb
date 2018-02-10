;-* 
;-* scintilla
;-*

DeclareModule Scintilla
  EnableExplicit
  
  Prototype prot_LexerCallback(gadget,*scinotify.SCNotification)
  Prototype prot_LexerInit(gadget,*LexerStyle)
  Structure LexerInfo; for the lexer - use()-Command
    callback.prot_LexerCallback
    init.prot_LexerInit
  EndStructure
  
  ;-** Declare
  Declare init()
  Declare Gadget(id,x,y,cx,cy,*lexer,*style=0)
  Declare SetText(gadget,text.s)
  Declare AppendText(gadget,text.s)
  Declare.s GetText(gadget)
EndDeclareModule

Module Scintilla
  Procedure init()
    ;with Debugger - copy the Scintilla.dll in the main directory 
    ;Initalize the scintilla-gadget by loading the scintilla32/scintilla64 dll or as fallback scintilla.dll/scilexer.dll
    CompilerIf #PB_Compiler_OS=#PB_OS_Windows
      CompilerIf #PB_Compiler_Processor=#PB_Processor_x86
        #DLL_Scintilla="Scintilla32.dll"
      CompilerElse
        #DLL_Scintilla="Scintilla64.dll"
      CompilerEndIf
      
      CompilerIf #PB_Compiler_Debugger
        If FileSize(#DLL_Scintilla)<>FileSize(#PB_Compiler_Home+"Compilers\Scintilla.dll")
          CopyFile(#PB_Compiler_Home+"Compilers\Scintilla.dll",#DLL_Scintilla)
        EndIf
      CompilerEndIf
      If InitScintilla(#DLL_Scintilla)=0
        If InitScintilla("Scintilla.dll")=0
          If InitScintilla("SciLexer.dll")=0
            ProcedureReturn #False
          EndIf
        EndIf
      EndIf      
    CompilerEndIf
    ProcedureReturn #True
  EndProcedure
  Procedure SetText(Gadget,text.s) ;Quick method to set a long Text, because SetGadgetText doesn't work
    Protected *buf=UTF8(text)
    ScintillaSendMessage(Gadget,#SCI_SETTEXT,0,*buf)
    FreeMemory(*buf)
    ScintillaSendMessage(gadget,#SCI_EMPTYUNDOBUFFER)
  EndProcedure
  Procedure AppendText(Gadget,text.s) ;Append the text without scrolling to the position
    Protected *buf=UTF8(text)
    ScintillaSendMessage(Gadget,#SCI_APPENDTEXT,StringByteLength(text,#PB_UTF8),*buf)
    FreeMemory(*buf)
  EndProcedure
  Procedure.s GetText(Gadget)  ;GetGadgetText doesn't work (because it use unicode not ascii)
    Protected *buf,bufsize,ret.s
    bufsize=ScintillaSendMessage(gadget,#SCI_GETLENGTH)+1
    *buf=AllocateMemory(bufsize)
    If *buf
      ScintillaSendMessage(Gadget,#SCI_GETTEXT,bufsize,*buf)
      ret=PeekS(*buf,-1,#PB_UTF8)
      FreeMemory(*buf)
    EndIf
    ProcedureReturn ret
  EndProcedure
  Procedure Gadget(id,x,y,cx,cy,*lexer.LexerInfo,*style=0)  ;Create a Scintilla gadget. *lexer-info should be a lexer.use()-call
    Protected Gadget , keyword.s
    Protected ret
    
    ret = ScintillaGadget(id,x,y,cx,cy,*lexer\callback)
    
    If id <> #PB_Any
      Gadget = id
    Else
      Gadget = ret
    EndIf
    If ret And *lexer\init
      *lexer\init(gadget,*style)
    EndIf
    
    ProcedureReturn ret
    
  EndProcedure  
EndModule

;-
;- _Base_Lexer
;-
DeclareModule _Base_Lexer
  ;-{ ** Structures
  ;Style ofthe Gadget 
  Structure Color
    fore.i
    back.i
  EndStructure
  Structure FontStyle
    fore.i
    back.i
    FontStyle.i; combination form #pb_font_bold, #pb_font_italic, #pb_font_underline. #PB_Font_StrikeOut is used for "eol filled"
    font.s
    size.i
  EndStructure
  Structure ColorAlpha
    color.i
    alpha.i
  EndStructure
  Structure LexerStyle; used to store the Style for the lexer
    None.FontStyle            ; Default-Style, base for every Font-Style in this structure
    Type.FontStyle[#STYLE_DEFAULT]  ; Style for every #LType_...
    LineNumber.FontStyle
    CallTip.FontStyle
    CallTipHilight.i
    FolderMark.Color          ; Color for the folder Icons in the margin
    RepeatedSelection.ColorAlpha  ; Color for the repeated selection
    Brace.ColorAlpha          ; Brace-Highlight color
    BadBrace.ColorAlpha       ; Brace highlight for a bad brace
    Currentline.ColorAlpha    ; Change the background of the current line - with alpha it will be drawn over the text!
    MinLinenumberSize.i       ; count of minimum visible digits
    AutoFillUpChars.s         ; When a autocomplete is open, this char automatic insert the current selection
    showCalltips.i            ; Show CallTips for functions
    UseSpaceForIndention.i    ; Use Space instead of Tabs for indention
    fold.i                    ; #True Enable Fold
    AutoIndention.i           ; Automatic indention, see __Base_Lexer Constants
    IndentGuide.color         ; Color of the dotted indent guide. -1 disable it
    TabSize.i                 ; Size of a Tab in Spaces
    doAutocompletion.i        ; Do autocomplete-suggestion-list
  EndStructure
  ;Internal Structures
  Structure Searcher
    RegEx.i                   ; Start-RegEx-Handle
    Type.i                    ; #ltype
    RegExEnd.i                ; End-RegEx-Handle
    Flags.i                   ; Searcher-flags - see constants
  EndStructure
  Structure Remap
    Word.s                    ; The Word in the list
    SortWord.s                ; Word for Sorting and compare - with no match case in uppercase
    calltip.s                 ; String with a calltip. First line should be the Parameterlist
    tooltip.s                 ; ToolTip for the Word, for example the value of constants
    ConvertTo.i               ; Convert the type to #LType_...
    Flags.i                   ; Flags, see constants
    IndentionAfter.i          ; Indention change after this keyword/line
    IndentionBefore.i         ; Indention change before this keyword
    count.i                   ; How often this keyword is in the text. When it value is <=0, the keyword will be deleted form the list
  EndStructure
  Structure list_Remap
    List Remap.Remap()        ; Wordlist for the type (see structure BaseLexer)
    dontCount.i               ; Don't collect words for this list (for example operator, whitelist)
  EndStructure
  Structure BaseLexer
    List Searcher.Searcher()  ; List of all searchers
    Type.list_Remap[#STYLE_DEFAULT] ; for every #LType a remap word list
    Brace.s                   ; Charas allowed for braces [](){}<>
    WordChars.s               ; All allowed Chars for a word, used by Scintilla for wordselection and so on
    PunctuationChars.s        ; same for punctuation chars
    WhiteSpaceChars.s         ; Whitespace chars, should be tab and space
    MatchCase.i               ; when #true, character case is important
    CallTipStart.s            ; Single char for the start of the parameter block of a function "("
    CallTipEnd.s              ; in the most cases ")"    
    CallTipLimiter.s          ; in the most cases ","
    CallTipIgnoreHilight.s    ; for the most cases, option parameter a in [], so enter "[]"
    ForceCaseMatch.i          ; Force the case of "word" in the remap list. For Example Change "endif" to "EndIf" 
  EndStructure
  Structure calltiplist       ; Internal Use only
    startpos.i
    startbrace.i
    endbrace.i
    limiter.s
    calltip.s
  EndStructure
  Structure Property          ; Property-List for every Gadget. Internal Use only
    CursorWord.s
    CursorWordType.i
    IndentStart.i
    IndentEnd.i
    MinLinenumberSize.i
    AutoIndention.i
    Fold.i
    RepeatedSelection.i
    Brace.i
    BraceVisible.i
    RepeatedSelectionVisible.i
    Type.list_Remap[#STYLE_DEFAULT]   ; collection of all Words.
    List CallTipList.calltiplist()    ; Position of all the calltip-parameter-block in the current line
    List ToolTipList.calltiplist()    ; Position of all Tooltips
    CallTipLine.i
    CallTipOpen.s
    ShowCallTips.i
    LastActiveLine.i
    DoAutocompletion.i
    DoIndent.i
  EndStructure
  ;}
  
  ;-{ ** Enumeration
  #SearcherAllowMask=63
  EnumerationBinary 64
    #Searcher_MarkSizeEqual           ; When a Searcher has a multiline start-mark and end-mark, both must be the same size
    #Searcher_LineStartOnly           ; Searcher only valid on line start
    #Searcher_SetAllowFlagOnly        ; If match, set the "Allow Flag" to 'Flags&#SearcherAllowMask', doesn't set a #LType
    #Searcher_OnlyWithAllowFlag       ; When match and the AllowFlag is set, clear the AllowFag and use the match. Otherwise does nothing
    #Searcher_ForceThisKeywordTo      ; Do the the normal match and remap, but change the type to 'Flags&#SearcherAllowMask', when type is #LTYPE_Keyword
    #Searcher_TypeBefore              ; Searcher is only valid, when type was before 'Flags&#SearcherAllowMask' (#LTYPE_WhiteSpace is ignored)
  EndEnumeration
  #LTypeFlagMask=63
  EnumerationBinary 64;
    #LTypeFlag_FoldStart              ; Word is a Fold start
    #LTypeFlag_FoldEnd                ; Word is a Fold end
    #LTypeFlag_NoAutoComplete         ; Word is not in the autocomplete list
    #LTypeFlag_ForceNextKeyword       ; Next #LType_Keyword is forced to be 'Flag&#LTypeFlagMask'
    #LTypeFlag_ConvertNeedSearcherForceThis ; when Searcher has #Searcher_ForceThisKeywordTo and the mask here and in Search is the same
                                            ; use the ConvertTo-field of the Remap-structure, otherwise this word is only used for autocompletion
    #LTypeFlag_Counter                ; Entry is only a counter for user-autocomplete-list
    #LTypeFlag_DeclareKeyword         ; word is a declare line for function to detect calltips from the text
  EndEnumeration
  Enumeration 0
    #AutoIndention_none               ; no automatic indention change
    #AutoIndention_simple             ; indention based on the last line - like in pb
    #AutoIndention_force              ; indent change automatic the complete text
  EndEnumeration
  Enumeration 0
    #LType_Invalid
    #LType_Command
    #LType_keyword                    ; Joker type for all
    #LType_Number
    #LType_HexNumber
    #LType_BinNumber
    #LType_String
    #LType_String2
    #LType_StringBlock
    #LType_Comment
    #LType_CommentBlock
    #LType_WhiteSpace                 ; space included!
    #LType_Operator
    #LType_Label
    #LType_Constant
    #LType_Function
    #LType_Macro    
    #LTYPE__ForLexer                  ; Start of custom #LType for the lexer
  EndEnumeration
  Enumeration 1                       ; Internal use
    #indicator_selection
    #indicator_brace
    #indicator_badbrace
  EndEnumeration
  Enumeration 0                       ; Internal use
    #margin_linenumber
    #margin_fold
  EndEnumeration
  ;                                     Linestate is a 32-Bit variable. It must store diffrent values for every line
  #linestate_ForceMask               =%00000000000000000000000000111111; 0000003F
  #linestate_ForceShift              =0
  #linestate_ForceAdd                =1;$20; 100000 32
  #linestate_ForceMax                =63
  ;
  #linestate_ForceSizeMask           =%00000000000000000000011111000000; 000007C0
  #linestate_ForceSizeShift          =6
  #linestate_ForceSizeAdd            =$10; 10000 16
  #linestate_ForceSizeMax            =31
  ;
  #linestate_FoldChangeMask          =%00000000000000000111100000000000; 00007800
  #linestate_FoldChangeShift         =11
  #linestate_FoldChangeAdd           =$8; 1000 8
  #linestate_FoldChangeMax           =15
  ;
  #linestate_IndentChangeMask        =%00000000000001111000000000000000; 00078000
  #linestate_IndentChangeShift       =15
  #linestate_IndentChangeAdd         =$8; 1000 8
  #linestate_IndentChangeMax         =15
  ;
  #linestate_IndentBeforeMask        =%00000000011110000000000000000000; 00780000
  #linestate_IndentBeforeShift       =19
  #linestate_IndentBeforeAdd         =$8; 1000 8
  #linestate_IndentBeforeMax         =15
  ;
  #linestate_IndentMask              =%01111111100000000000000000000000; 7F800000
  #linestate_IndentShift             =23
  #linestate_IndentAdd               =$80; 10000000 128
  #linestate_IndentMax               =255
  ;}
  
  ;-{ ** Declare  
  Declare _GetDefault(*Lexer.LexerStyle)
  Declare SetStyle(Gadget,*lexer.LexerStyle)  
  Declare.i AddSearcher(List searcher.searcher(),type.i,Exp.s,ExpFlag=0,ExpEnd.s="",ExpEndFlag=0,Flags=0)
  Declare.i _init(gadget,*style.lexerstyle,*lexer.BaseLexer)
  Declare.i _Callback(Gadget, *scinotify.SCNotification,*lexer.BaseLexer)
  Declare.i FindRemap(List test.remap(),x.s)
  Declare GetProperty(gadget)
  Declare FreeProperty(gadget=#PB_Any)
  ;}
  
  ;Help-Macro to fast set default FontStyle
  Macro __SetStyle(name,vFore=-1,vBack=-1,vFontstyle=-1,vFont="",vSize=0)
    name\fore=vFore
    name\back=vBack
    name\FontStyle=vFontStyle
    name\font=vFont
    name\size=vSize
  EndMacro 
EndDeclareModule
;--- 
Module _Base_Lexer
  EnableExplicit
  ;- structure
  Structure datalist                      ; Structure for Get/SetGadgetData()
    gadget.i
    Property.Property
  EndStructure
  ;- constant
  #Buffer_GetSize=-1
  
  ;- declare
  Declare __GetData(gadget)
  Declare setLineWidth(gadget)
  
  ;- global
  Global NewList datalist.datalist()      ; Property is stored here
  
  ;-** internal routines
    
  Procedure GetBuffer(size) ; static buffer for various routines. minimum size is 1024 Bytes. 
    Static *buf,bufsize
    If size=#Buffer_GetSize
      ProcedureReturn bufsize
    EndIf
    
    If size<1024
      size=1024
    EndIf
    
    If bufsize<size Or *buf=0 
      If *buf
        FreeMemory(*buf)
        *buf=0
      EndIf
      *buf=AllocateMemory(Size,#PB_Memory_NoClear)
      bufsize=Size
      Debug "GetBuffer:"+Str(size)+" 0x"+Hex(*buf)
    EndIf
    ProcedureReturn *buf
  EndProcedure
  Procedure FastASCII(str.s) ; fast convert to #pb_ascii. use GetBuffer()
    Protected *buf
    *buf=GetBuffer(Len(str)+1)
    PokeS(*buf,str,-1,#PB_Ascii)
    ProcedureReturn *buf
  EndProcedure
  
  Procedure __SetFontStyle(id,style,*FontStyle.FontStyle) ; Set Front Style (use Buffer)
    If *FontStyle\fore>=0
      ScintillaSendMessage(id,#SCI_STYLESETFORE,style,*FontStyle\fore)
    EndIf
    If *FontStyle\back>=0
      ScintillaSendMessage(id,#SCI_STYLESETBACK,style,*FontStyle\back)
    EndIf
    If *FontStyle\FontStyle>=0
      ScintillaSendMessage(id,#SCI_STYLESETBOLD,style,Bool(*FontStyle\FontStyle & #PB_Font_Bold))
      ScintillaSendMessage(id,#SCI_STYLESETITALIC,style,Bool(*FontStyle\FontStyle & #PB_Font_Italic))
      ScintillaSendMessage(id,#SCI_STYLESETUNDERLINE,style,Bool(*FontStyle\FontStyle & #PB_Font_Underline))
      ScintillaSendMessage(id,#SCI_STYLESETEOLFILLED,style,Bool(*FontStyle\FontStyle & #PB_Font_StrikeOut))
    EndIf
    If *FontStyle\size>0
      ScintillaSendMessage(id,#SCI_STYLESETSIZE,style,*FontStyle \size)
    EndIf
    If *FontStyle\font<>""
      ScintillaSendMessage(id,#SCI_STYLESETFONT,style,FastASCII(*FontStyle\font))
    EndIf  
  EndProcedure
  Procedure __GetData(gadget) ; Get (and create) the structure saved in the (set)GadgetData().  (for property)
    Protected *buf.datalist
    *buf=GetGadgetData(gadget)
    If *buf=0
      AddElement(datalist())
      datalist()\gadget=gadget
      *buf=@datalist()
      SetGadgetData(Gadget,*buf)
    EndIf
    ProcedureReturn *buf
  EndProcedure
  
  ; routines for set the #linestate - values
  Procedure SetBits(value,shift,add,max)
    value+add
    If value<0
      value=0
    ElseIf value>max
      value=max
    EndIf
    ProcedureReturn (value<<shift)
  EndProcedure
  Procedure GetBits(value,mask,shift,add)
    ProcedureReturn ((value&mask)>>shift)-add
  EndProcedure    
  Macro GetBitsM(value,a):GetBits(value,a#Mask,a#Shift,a#Add):EndMacro
  Macro SetBitsM(value,a):SetBits(value,a#Shift,a#Add,a#Max):EndMacro
  
  
  Procedure Autocomplete(gadget,word.s,List WordList.remap(),List Wordlist2.remap(),*lexer.baselexer) ; Build (and cancel) the automatic word list from to lists (lexer-list and user-list)
    If (ListSize(WordList())<=1 And ListSize(wordlist2())<=1) Or Len(word)>100 Or Len(word)=1
      ProcedureReturn 0
    EndIf
    Protected *buf=GetBuffer(1)
    Protected size=GetBuffer(#Buffer_GetSize)
    Protected *writepos.ascii,written,a,count
    Protected foundword.s,insertword.s,insertsortword.s
    
    If *lexer\MatchCase=#False
      word=UCase(word)
    EndIf
    
    written=size-2
    *writepos=*buf
    FindRemap(WordList(),word)
    FindRemap(wordlist2(),word)
    ;foundword=WordList()\SortWord
    Repeat  
      While WordList()\Flags & #LTypeFlag_NoAutoComplete And NextElement(wordlist())
      Wend
      While (wordlist2()\flags& #LTypeFlag_NoAutoComplete Or (WordList2()\Flags&#LTypeFlag_Counter And WordList2()\SortWord=word)) And NextElement(wordlist2())
      Wend
      If Left(wordlist()\sortword,Len(word))<>word And Left(wordlist2()\SortWord,Len(word))<>word
        Break
      EndIf
      If (wordlist()\SortWord<wordlist2()\SortWord And wordlist()\SortWord<>"") Or wordlist2()\SortWord=""
        insertword=wordlist()\word
        insertsortword=wordlist()\SortWord
        NextElement(WordList())
      Else
        insertword=wordlist2()\Word
        insertsortword=wordlist()\SortWord
        NextElement(wordlist2())
        
      EndIf
      
      If foundword=""
        foundword=insertsortword
      EndIf
      
      If written<Len(WordList()\Word)
        written=-1
        Break
      EndIf
      *writepos\a=32:*writepos+1
      a=PokeS(*writepos,insertword,-1,#PB_Ascii)
      *writepos+a
      written-(a+1)
      count+1
    ForEver
    
    *writepos\a=0
    
    If ScintillaSendMessage(gadget,#SCI_AUTOCACTIVE)=#False
      If count>0 And written>=0 And Not(count=1 And foundword=word)
        ScintillaSendMessage(gadget,#SCI_AUTOCSHOW,Len(word),*buf+1)
      EndIf
    ElseIf count=0 Or foundword=word
      ScintillaSendMessage(gadget,#SCI_AUTOCCANCEL)      
    EndIf      
    
  EndProcedure
    
  Procedure SimpleIndentLine(gadget,line,UseSelection=#False); Simple line indention, useselection = add the indention of a new line
    Protected tabsize,LineState,indentlevel,force,word.s,pos
    
    tabsize=ScintillaSendMessage(gadget,#SCI_GETTABWIDTH)
    
    If line>0
      indentlevel=ScintillaSendMessage(gadget,#SCI_GETLINEINDENTATION,line-1)/tabsize
      LineState=ScintillaSendMessage(gadget,#SCI_GETLINESTATE,line-1)
      force=GetBitsM(LineState,#linestate_Force)
      IndentLevel+GetBitsM(linestate,#linestate_IndentChange)
    Else
      force=-1
      IndentLevel=0
    EndIf
    If UseSelection
      pos=ScintillaSendMessage(gadget,#SCI_POSITIONFROMLINE,line)+indentlevel*tabsize
      ScintillaSendMessage(gadget,#SCI_SETLINEINDENTATION,line,indentlevel * tabsize)
      ;Correct cursor position
      ScintillaSendMessage(gadget,#SCI_SETCURRENTPOS,pos)
      ScintillaSendMessage(gadget,#SCI_SETANCHOR,pos)            
    ElseIf force=-1
      LineState=ScintillaSendMessage(gadget,#SCI_GETLINESTATE,line)
      IndentLevel+GetBitsM(LineState,#linestate_IndentBefore)
      ScintillaSendMessage(gadget,#SCI_SETLINEINDENTATION,line,indentlevel*tabsize)
    EndIf  
  EndProcedure
  Procedure IndentLine(gadget,line,UseSelection=#False); use the indention-value set by  Highlight()
    Protected tabsize
    Protected LineState,force,IndentLevel,IndentAfter,pos
    
    tabsize=ScintillaSendMessage(gadget,#SCI_GETTABWIDTH)
    
    If line>0
      LineState=ScintillaSendMessage(gadget,#SCI_GETLINESTATE,line-1)
      force=GetBitsM(LineState,#linestate_Force)
      If force>=0
        IndentAfter=ScintillaSendMessage(gadget,#SCI_GETLINEINDENTATION,line-1)/tabsize
      Else
        IndentAfter=GetBitsM(LineState,#linestate_Indent)+GetBitsM(linestate,#linestate_IndentChange)
      EndIf
    Else
      force=-1
    EndIf
    
    If UseSelection
      If IndentAfter<0
        IndentAfter=0
      EndIf
      
      pos=ScintillaSendMessage(gadget,#SCI_POSITIONFROMLINE,line)+IndentAfter*tabsize
      ScintillaSendMessage(gadget,#SCI_SETLINEINDENTATION,line,IndentAfter * tabsize)
      ScintillaSendMessage(gadget,#SCI_SETCURRENTPOS,pos)
      ScintillaSendMessage(gadget,#SCI_SETANCHOR,pos)
    ElseIf force=-1      
      LineState=ScintillaSendMessage(gadget,#SCI_GETLINESTATE,line)
      IndentLevel=GetBitsM(LineState,#linestate_Indent)
      ScintillaSendMessage(gadget,#SCI_SETLINEINDENTATION,line,IndentLevel * tabsize)
    EndIf
  EndProcedure
  
  Procedure.s CreateCalltip(line.s,*lexer.baselexer); create a calltip form the text, remove () in parameter block, used by highlight
    Protected a,b,c
    a=FindString(line,*lexer\CallTipStart)
    If a
      Repeat
        
        b=FindString(line,*lexer\CallTipStart,a+1)
        c=FindString(line,*lexer\CallTipEnd,b)
        If b And c
          line=Left(line,b-1)+Mid(line,c+1)
        Else
          Break
        EndIf
      ForEver
    EndIf
    b=FindString(line,*lexer\CallTipEnd)
    line=Trim(Left(line,b+1))+#LF$+Trim(Mid(line,b+1))
    While Right(line,1)=#CR$ Or Right(line,1)=#LF$
      line=Left(line,Len(line)-1)
    Wend
    ProcedureReturn line
  EndProcedure
  
  Procedure Highlight(Gadget,startPos, endPos,*lexer.baseLexer,doStyle=#True,countStep=0)
    Protected startLine,endLine
    Protected MaxSize,size
    Protected i,line.s,pos,r,dif
    Protected type,length
    Protected force,forcesize
    Protected LineState
    Protected word.s,sortword.s
    Protected foldlevel,foldchange,foldchangeCurrent
    Protected IndentLevel,IndentBefore,IndentAfter
    Protected *buf
    Protected CursorPos,LinePos,CursorLine
    Protected List
    Protected *Property.Property=GetProperty(gadget)
    Protected ForceNextKeyword,ForceThisKeyword
    Protected LastCallTip.s,LastCallTipPos.i
    Protected bracelevel
    Protected TargetStart,TargetEnd
    Protected AllowFlag
    Protected do,flags,TypeBefore,DeclareFlag
    Protected cutline.s
    
    
    startLine=ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,startPos)
    endLine=ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,endPos)
    
    If doStyle
      ; Save line for indention-change
      If startLine<*Property\IndentStart Or *Property\IndentStart=-1 : *Property\IndentStart=startline : EndIf
      If endline>*Property\IndentEnd : *Property\IndentEnd=endLine : EndIf
    EndIf
    
    ;Debug "style:"+startline+" "+endline+" "+dostyle+" "+countStep
    
    CursorPos=ScintillaSendMessage(Gadget,#SCI_GETCURRENTPOS)
    CursorLine=ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,CursorPos)
    
    ;{ get the longest line
    For i=startLine To endLine
      size=ScintillaSendMessage(gadget,#SCI_GETLINE,i)
      If size>MaxSize
        MaxSize=size
      EndIf
    Next
    MaxSize+1 ;nullterminator!
    
    *buf=GetBuffer(MaxSize)
    ;}
    
    ;{ get foldlevel,indentlevel from line before
    If startLine>0
      foldlevel=ScintillaSendMessage(gadget,#SCI_GETFOLDLEVEL,startline-1) & #SC_FOLDLEVELNUMBERMASK
      LineState=ScintillaSendMessage(gadget,#SCI_GETLINESTATE,startLine-1)
      
      foldchange=GetBitsm(LineState,#linestate_FoldChange)
      foldlevel+foldchange
      
      force=GetBitsM(LineState,#linestate_Force)
      forcesize=GetBitsM(LineState,#linestate_ForceSize)
      
      IndentLevel=GetBitsM(LineState,#linestate_Indent)
      IndentAfter=GetBitsM(LineState,#linestate_IndentChange)
      
      IndentLevel+IndentAfter      
    Else
      foldlevel=#SC_FOLDLEVELBASE
      force=-1
      forcesize=0
    EndIf
    ;}
    
    
    For i=startLine To endLine
      
      If i=CursorLine And countStep=0
        ;Clear old Call/ToolTip list of current line
        ClearList(*Property\CallTipList())
        ClearList(*property\ToolTipList())
        *Property\CallTipLine=i
      EndIf
      
      LinePos=ScintillaSendMessage(gadget,#SCI_POSITIONFROMLINE,i)
      If doStyle
        ;start styling of the line
        ScintillaSendMessage(gadget, #SCI_STARTSTYLING, LinePos)
      EndIf
      
      size=ScintillaSendMessage(gadget,#SCI_GETLINE,i,*buf)
      line=PeekS(*buf,size,#PB_Ascii)
      
      ;Reset some values
      pos=1      
      foldchange=0:foldchangeCurrent=0
      IndentAfter=0:IndentBefore=0
      AllowFlag=-1:TypeBefore=-1:DeclareFlag=#False
      ForceNextKeyword=-1
      
      Repeat
        
        ForceThisKeyword=-1
        
        cutline=Mid(line,pos)
        
        If force=-1
          ;{ no multi-line 
          
          type=#LType_Invalid:length=1
          
          ;Check all searchers, and stop, if one match
          ForEach *lexer\searcher()             
            r=*lexer\Searcher()\RegEx
            flags=*lexer\Searcher()\flags
            do=#True
            If flags&#Searcher_LineStartOnly And pos>1
              do=#False
            EndIf
            If flags&#Searcher_OnlyWithAllowFlag And AllowFlag <> flags&#SearcherAllowMask
              do=#False
            EndIf
            If flags&#Searcher_TypeBefore And TypeBefore <> flags&#SearcherAllowMask
              do=#False
            EndIf
            
            If do
              If ExamineRegularExpression(r, cutline)
                If NextRegularExpressionMatch(r) 
                  If *lexer\Searcher()\Flags&#Searcher_SetAllowFlagOnly
                    AllowFlag=*lexer\Searcher()\Flags & #SearcherAllowMask
                  Else  
                    If flags&#Searcher_OnlyWithAllowFlag And AllowFlag= flags&#SearcherAllowMask
                      AllowFlag=-1
                    EndIf
                    If flags&#Searcher_ForceThisKeywordTo
                      ForceThisKeyword=flags&#SearcherAllowMask
                    EndIf
                    
                    length=RegularExpressionMatchLength(r)
                    type=*lexer\Searcher()\type
                    If *lexer\Searcher()\RegExEnd
                      force=ListIndex(*lexer\Searcher())
                      forcesize=length
                    EndIf
                    
                    Break
                  EndIf
                  
                EndIf
              EndIf
            EndIf
          Next
          ;}
          
        Else
          ;{ Multi-Line Searcher is activ, search for end mark
          SelectElement(*lexer\Searcher(),force)
          type=*lexer\Searcher()\Type:length=size-pos+1; if end mark is not found, complete line
          
          ;Search for endmark
          r=*lexer\Searcher()\RegExEnd
          If ExamineRegularExpression(r, cutline)
            While NextRegularExpressionMatch(r)
              If (*lexer\Searcher()\Flags & #Searcher_MarkSizeEqual)=0 Or RegularExpressionMatchLength(r)=forcesize
                length=RegularExpressionMatchPosition(r)+RegularExpressionMatchLength(r)-1
                force=-1
              EndIf
            Wend
          EndIf
          type=*lexer\Searcher()\Type
          ;}
        EndIf
        
        ; "Fuse" - allways color one char!
        If length<=0
          length=1
          type=#LType_Invalid
        EndIf
        
        ;Overwrite type KEYWORD
        If type=#LType_keyword And ForceNextKeyword>-1
          type=ForceNextKeyword
          ForceNextKeyword=-1
        EndIf
        
        ;{ Search Word under cursor (for autocomplete)
        If LinePos<CursorPos And CursorPos<=LinePos+length
          If force=-1
            *Property\CUrsorWordType=type
            If CursorPos-LinePos<length
              *Property\CursorWord=Mid(line,pos,CursorPos-LinePos)
            Else
              *Property\CursorWord=Mid(line,pos,length)
            EndIf
          Else
            *Property\CUrsorWordType=#LType_Invalid
            *Property\CursorWord=""
          EndIf          
        EndIf
        ;}
        
        ;{ remap? (and call/tooltip Preparation
        
        ;Get Word and SortWord
        word=Mid(line,pos,length)        
        If *lexer\MatchCase
          sortword=word
        Else
          sortword=UCase(word)
        EndIf
        
        With *lexer\Type[type]
          ;Search in the word list
          If word<>"" And FindRemap(\Remap(),sortword)
            
            If i=CursorLine And countStep=0
              ;Set Calltip and Tooltip
              If \Remap()\calltip<>""
                LastCallTip=\Remap()\calltip
                LastCallTipPos=LinePos
              EndIf
              If \Remap()\tooltip<>""
                InsertElement(*Property\ToolTipList())
                *Property\ToolTipList()\calltip=\Remap()\tooltip
                *Property\ToolTipList()\endbrace=LinePos+length-1
                *Property\ToolTipList()\startbrace=LinePos
                *Property\ToolTipList()\startpos=LinePos
              EndIf              
            EndIf         
            
            ;Force the case match
            If Not(LinePos<CursorPos And CursorPos<=LinePos+length) And *lexer\ForceCaseMatch=#True And doStyle And countStep=0
              If \Remap()\Flags&#LTypeFlag_Counter=0 And \Remap()\Word<>word 
                TargetStart=ScintillaSendMessage(gadget,#SCI_GETTARGETSTART)
                TargetEnd=ScintillaSendMessage(gadget,#SCI_GETTARGETEND)
                ScintillaSendMessage(gadget,#SCI_SETUNDOCOLLECTION,#False)
                ScintillaSendMessage(gadget,#SCI_SETTARGETSTART,linepos)
                ScintillaSendMessage(gadget,#SCI_SETTARGETEND,linepos+length)
                ScintillaSendMessage(gadget,#SCI_REPLACETARGET,length,FastASCII(\Remap()\Word))
                ScintillaSendMessage(gadget,#SCI_SETUNDOCOLLECTION,#True)
                ScintillaSendMessage(gadget,#SCI_SETTARGETSTART,TargetStart)
                ScintillaSendMessage(gadget,#SCI_SETTARGETEND,TargetEnd)                
              EndIf              
            EndIf
            
            ;Check Fold-Flags
            If (\Remap()\Flags) & (#LTypeFlag_FoldEnd|#LTypeFlag_FoldStart) = #LTypeFlag_FoldEnd|#LTypeFlag_FoldStart
              foldchangeCurrent-1
              foldchange+1
            ElseIf (\Remap()\Flags) & #LTypeFlag_FoldEnd
              foldchange-1
            ElseIf \Remap()\Flags & #LTypeFlag_FoldStart
              foldchange+1
            EndIf
            
            ;Check Indention-Values
            If \Remap()\IndentionBefore<0 And \Remap()\IndentionAfter=0 And IndentAfter>=-\Remap()\IndentionBefore
              IndentAfter+\Remap()\IndentionBefore
            Else
              IndentAfter+ \Remap()\IndentionAfter
              IndentBefore+ \Remap()\IndentionBefore
            EndIf
            
            ;Force Next Keyword?
            If \Remap()\Flags & #LTypeFlag_ForceNextKeyword
              ForceNextKeyword=\remap()\Flags & #LTypeFlagMask
            EndIf
            
            ;DeclareLine?
            If \remap()\Flags & #LTypeFlag_DeclareKeyword
              DeclareFlag=#True
            EndIf
            
            ;Remap Type to Type of the word
            ;must be last statement, because we change type!
            If \remap()\Flags&#LTypeFlag_ConvertNeedSearcherForceThis
              If ForceThisKeyword=\remap()\Flags & #LTypeFlagMask
                If \Remap()\ConvertTo>=0 
                  type=\Remap()\ConvertTo
                EndIf
              EndIf
            Else
              If \Remap()\ConvertTo>=0 
                type=\Remap()\ConvertTo
              EndIf
            EndIf
            
          ElseIf sortword<>"" And \dontCount=#False
            ;Search in the user-list for the gadget
            If FindRemap(*Property\Type[type]\Remap(),sortword)
              
              ;Call/Tooltip?
              If DeclareFlag=#False And i=CursorLine And countStep=0
                If *Property\Type[type]\Remap()\calltip<>""
                  LastCallTip=*Property\Type[type]\Remap()\calltip
                  LastCallTipPos=LinePos
                EndIf
                If *Property\Type[type]\Remap()\tooltip<>""
                  InsertElement(*Property\ToolTipList())
                  *Property\ToolTipList()\calltip=*Property\Type[type]\Remap()\tooltip
                  *Property\ToolTipList()\endbrace=LinePos+length-1
                  *Property\ToolTipList()\startbrace=LinePos
                  *Property\ToolTipList()\startpos=LinePos
                EndIf   
              EndIf
              
              ;The user-List-Calltip
              If countStep
                If declareflag And type=#LType_keyword
                  *property\type[type]\Remap()\calltip=CreateCalltip(Mid(line,pos),*lexer)
                EndIf
                *Property\type[type]\Remap()\count+countStep
                If *Property\type[type]\Remap()\count=0
                  DeleteElement(*Property\type[type]\Remap())
                EndIf
              EndIf
              
            ElseIf countstep
              ;Add word, if not in the List
              InsertElement(*Property\type[type]\Remap())
              *Property\type[type]\Remap()\Word=word
              *Property\type[type]\Remap()\SortWord=sortword
              *Property\type[type]\Remap()\ConvertTo=-1
              *Property\type[type]\Remap()\count=countStep
              *Property\type[type]\Remap()\Flags=#LTypeFlag_Counter
              If declareflag And type=#LType_keyword
                *property\type[type]\Remap()\calltip=CreateCalltip(Mid(line,pos),*lexer)  
              EndIf
            EndIf
            
            ;Clear declareFlag, if type is KEYWORD
            If type=#LType_keyword
              DeclareFlag=#False
            EndIf
            
          EndIf
          
        EndWith
        ;}
        
        ;{ CallTip search for Parameter block
        If i=CursorLine And countStep=0
          If word=*lexer\CallTipStart
            bracelevel+1
            InsertElement(*Property\CallTipList())
            *Property\CallTipList()\calltip=LastCallTip
            *Property\CallTipList()\startpos=LastCallTipPos
            *Property\CallTipList()\startbrace=LinePos
            LastCallTip=""
            LastCallTipPos=0
          ElseIf word=*lexer\CallTipEnd And bracelevel>0
            *Property\CallTipList()\endbrace=linepos
            bracelevel-1
            NextElement(*Property\CallTipList())
          ElseIf word=*lexer\CallTipLimiter And bracelevel>0
            *Property\CallTipList()\limiter + Str(LinePos)+","            
          EndIf          
        EndIf
        ;}
        
        ;Store type, when not whitespace
        If type<>#LType_WhiteSpace
          TypeBefore=type
        EndIf
        
        ;do styling
        If doStyle
          If ForceThisKeyword>-1 And type=#LType_keyword
            type=ForceThisKeyword
          EndIf          
          ScintillaSendMessage(gadget,#SCI_SETSTYLING,length,type)
        EndIf
        
        ;Next word
        linepos+length
        pos+length
      Until pos>size
      
      ; Set Fold-State
      If *Property\Fold And doStyle
        foldlevel+foldchangeCurrent
        If foldchange>0
          ScintillaSendMessage(gadget,#SCI_SETFOLDLEVEL,i,foldlevel|#SC_FOLDLEVELHEADERFLAG)
        Else        
          ScintillaSendMessage(gadget,#SCI_SETFOLDLEVEL,i,foldlevel)
        EndIf
      EndIf
      
      ;Change Indention before
      IndentLevel+IndentBefore
      
      ;Save Indention and force values in Linestate
      If doStyle
        linestate= SetBitsM(force,#linestate_Force)
        linestate+ SetBitsM(forcesize,#linestate_ForceSize)
        linestate+ SetBitsM(foldchange,#linestate_FoldChange)
        linestate+ SetBitsM(IndentLevel,#linestate_Indent)
        linestate+ SetBitsM(IndentAfter,#linestate_IndentChange)
        linestate+ SetBitsM(IndentBefore,#linestate_IndentBefore)
        ScintillaSendMessage(gadget,#SCI_SETLINESTATE,i,linestate)
      EndIf
      
      ;Change Indention and fold level
      foldlevel+foldchange
      IndentLevel+IndentAfter
      
      ;clear and fix calltip-endmark
      If i=CursorLine And countStep=0
        ForEach *Property\CallTipList()
          If *Property\CallTipList()\calltip=""
            DeleteElement (*Property\CallTipList())
          ElseIf  *Property\CallTipList()\endbrace=0
            *Property\CallTipList()\endbrace=linepos
          EndIf          
        Next 
      EndIf
      
      
    Next
    
    
    
  EndProcedure
  
  Procedure MarkBrace(gadget,brace.s) ; Highlight of a brace
    ;check if under the current position is a brace and hilight it
    ;brace is a combination from "(){}[]<>"
    Protected pos,char,findpos
    Protected *Property.Property=GetProperty(gadget)
    
    If *Property\Brace
      
      pos=ScintillaSendMessage(gadget,#SCI_GETCURRENTPOS)
      If pos=ScintillaSendMessage(gadget,#SCI_GETANCHOR)
        
        char=ScintillaSendMessage(gadget,#SCI_GETCHARAT,pos)
        If FindString(Brace,Chr(char))
          findpos=ScintillaSendMessage(gadget,#SCI_BRACEMATCH,pos)
          If findpos>=0
            ScintillaSendMessage(gadget,#SCI_BRACEHIGHLIGHT,pos,findpos)
          Else
            ScintillaSendMessage(gadget,#SCI_BRACEBADLIGHT,pos)
          EndIf
          *Property\BraceVisible=#True
        ElseIf *Property\BraceVisible
          ScintillaSendMessage(gadget,#SCI_BRACEHIGHLIGHT,-1,-1)
          ScintillaSendMessage(gadget,#SCI_BRACEBADLIGHT,-1)
          *Property\BraceVisible=#False
        EndIf
      ElseIf *Property\BraceVisible
        ScintillaSendMessage(gadget,#SCI_BRACEHIGHLIGHT,-1,-1)
        ScintillaSendMessage(gadget,#SCI_BRACEBADLIGHT,-1)
        *Property\BraceVisible=#False
      EndIf
    EndIf
  EndProcedure
  
  Procedure setLineWidth(gadget) ; check, if the linenumber can be displayed in the margin
    Protected maxlines,width,digit,min
    Protected *Property.Property=GetProperty(gadget)
    
    maxlines=ScintillaSendMessage(gadget,#SCI_GETLINECOUNT)
    min=*Property\MinLinenumberSize
    
    While maxlines>0
      maxlines/10
      digit+1
    Wend
    If digit<min
      digit=min
    EndIf
    
    width=ScintillaSendMessage(gadget,#SCI_TEXTWIDTH,#STYLE_LINENUMBER, @"9");because i send only one char, unicode=ascii
    width*(digit+1)
    
    If ScintillaSendMessage(Gadget,#SCI_GETMARGINWIDTHN,#margin_linenumber)<>width
      ScintillaSendMessage(gadget,#SCI_SETMARGINWIDTHN,#margin_linenumber,width)
    EndIf
  EndProcedure
  
  Procedure RepeatedSelection(gadget) ; check, if the selection highlight a word and mark all words in the document
    Protected startPos,endPos
    Protected *buf.ascii,buflength,size,i
    Protected *Property.Property=GetProperty(gadget)
    
    
    If *Property\RepeatedSelection
      
      size=ScintillaSendMessage(gadget,#SCI_GETLENGTH)
      ScintillaSendMessage(gadget,#SCI_SETINDICATORCURRENT,#indicator_selection)
      
      If *Property\RepeatedSelectionVisible
        ScintillaSendMessage(gadget, #SCI_INDICATORCLEARRANGE,0,size)
        *Property\RepeatedSelectionVisible=#False
      EndIf
      
      startPos=ScintillaSendMessage(gadget,#SCI_GETSELECTIONSTART)
      endpos=ScintillaSendMessage(gadget,#SCI_GETSELECTIONEND)
      
      If startPos=ScintillaSendMessage(gadget,#SCI_WORDSTARTPOSITION,startpos,#True) And endpos=ScintillaSendMessage(gadget,#SCI_WORDENDPOSITION,startPos,#True)
        buflength=ScintillaSendMessage(gadget,#SCI_GETSELTEXT)
        If buflength>2
          *buf=GetBuffer(buflength)
          
          ScintillaSendMessage(gadget,#SCI_GETSELTEXT,0,*buf)
          
          ScintillaSendMessage(gadget,#SCI_SETTARGETSTART,0)
          ScintillaSendMessage(gadget,#SCI_SETTARGETEND, size )
          ScintillaSendMessage(gadget,#SCI_SETSEARCHFLAGS, #SCFIND_MATCHCASE|#SCFIND_WHOLEWORD)          
          
          Repeat
            i= ScintillaSendMessage(gadget,#SCI_SEARCHINTARGET,buflength-1,*buf)
            If i<0
              Break
            EndIf
            
            If i<>startPos
              ScintillaSendMessage(gadget,#SCI_INDICATORFILLRANGE,i,buflength-1)
            EndIf            
            
            ScintillaSendMessage(gadget,#SCI_SETTARGETSTART,i+buflength-1)
            ScintillaSendMessage(gadget,#SCI_SETTARGETEND, size )
          ForEver
          
          *Property\RepeatedSelectionVisible=#True
          
        EndIf
        
      EndIf        
    EndIf
    
  EndProcedure
  
  Procedure Calltip(gadget,*lexer.baselexer,force=#False,forceshow=#False) ; Test if a call/tooltip can be displayed, highlight parameter in parameterblock
    Protected calltip.s,calltippos.i=-1,para
    Protected startpos,i,lineNumber,endPos
    Protected word.s
    Protected *Property.Property=GetProperty(gadget)
    Protected maxpos
    Protected dohilight
    
    If *Property\ShowCallTips=#False Or (forceshow=#False And ScintillaSendMessage(gadget,#SCI_AUTOCACTIVE))
      ProcedureReturn #False
    EndIf
    
    startpos=ScintillaSendMessage(gadget,#SCI_GETCURRENTPOS)
    lineNumber=ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,startpos)
    If *Property\CallTipLine<>lineNumber Or force
      Highlight(gadget,startpos,startpos,*lexer,#False)
    EndIf
    ;first tooltip
    ForEach *Property\ToolTipList()
      If *Property\ToolTipList()\startbrace<=startPos And startpos<=*Property\ToolTipList()\endbrace
        calltippos=*Property\ToolTipList()\startpos
        calltip=*Property\ToolTipList()\calltip
        Break
      EndIf
    Next
    ;then calltip
    If calltippos=-1
      ForEach *Property\CallTipList()
        If *Property\CallTipList()\startbrace<=startPos And startpos<=*Property\CallTipList()\endbrace
          calltippos=*Property\CallTipList()\startpos
          calltip=*Property\CallTipList()\calltip
          para=0
          word=*Property\CallTipList()\limiter
          Repeat
            i=Val( StringField(word,para+1,","))
            If i=0 Or startPos<=i :Break:EndIf
            para+1
          ForEver
          Break
        EndIf
      Next
      dohilight=#True
    EndIf
    ;display
    If *Property\CallTipOpen<>calltip Or (calltip<>"" And ScintillaSendMessage(gadget,#SCI_CALLTIPACTIVE)=#False)
      If calltip=""
        ScintillaSendMessage(gadget,#SCI_CALLTIPCANCEL)
      Else
        ScintillaSendMessage(gadget,#SCI_CALLTIPSHOW,calltippos,FastASCII(calltip))
      EndIf
      *Property\CallTipOpen=calltip
    EndIf
    ;Hilight parameter
    If dohilight And ScintillaSendMessage(gadget,#SCI_CALLTIPACTIVE)
      startpos=FindString(*Property\CallTipOpen,*lexer\CallTipStart)
      For i=1 To para
        startPos=FindString(*Property\CallTipOpen,*lexer\CallTipLimiter,startpos+1)
        If startpos=0
          Break
        EndIf
      Next
      If startpos
        
        maxpos=FindString(*Property\CallTipOpen,~"\n")
        If maxpos=0:maxpos=Len(*Property\CallTipOpen):EndIf
        
        endPos=FindString(*Property\CallTipOpen,*lexer\CallTipLimiter,startpos+1)
        If endpos=0 Or endPos>maxpos
          endpos=FindString(*Property\CallTipOpen,*lexer\CallTipEnd,startpos+1)
        EndIf
        If endpos
          While FindString(*lexer\CallTipIgnoreHilight,Mid(*Property\CallTipOpen,startpos+1,1)):startpos+1:Wend
          While endpos>0 And FindString(*lexer\CallTipIgnoreHilight,Mid(*property\CallTipOpen,endpos-1,1)):endpos-1:Wend
        EndIf
      EndIf
      
      If startpos And endpos And startpos<endpos  
        ScintillaSendMessage(gadget,#SCI_CALLTIPSETHLT,startpos,endpos-1)
      Else
        ScintillaSendMessage(gadget,#SCI_CALLTIPSETHLT,0,0)
      EndIf
    EndIf
  EndProcedure
  
  ;- ** Public
  
  Procedure FindRemap(List test.remap(),x.s); search a word in the list. Return #false if faild, but listpostition is at the insertposition
    Protected c,pos,count
    count=ListSize(test())-1
    If count=-1
      InsertElement(test())
      ProcedureReturn #False
    EndIf
    c=count
    pos=c/2
    c/4
    
    While c>2
      SelectElement(test(),pos)
      If test()\SortWord=x
        Break
      ElseIf test()\SortWord>x
        pos-c
      Else
        pos+c
      EndIf
      c/2
    Wend
    SelectElement(test(),pos)
    
    While test()\SortWord>=x  And PreviousElement(test())
      pos-1
    Wend
    While test()\SortWord<x And pos<count And NextElement(test())
      pos+1
    Wend  
    ProcedureReturn Bool(test()\SortWord=x)    
  EndProcedure
  Procedure GetProperty(Gadget) ; get the Property-Structure of the gadget
    Protected *buf.datalist=__GetData(gadget)
    ProcedureReturn @ *buf\Property
  EndProcedure
  Procedure FreeProperty(gadget=#PB_Any) ; Free a property and clear the datalist from freeed gadget
    ForEach dataList()
      If Not IsGadget(dataList()\gadget) Or datalist()\gadget=gadget
        DeleteElement(datalist())
      EndIf
    Next
    If gadget<>#PB_Any
      FreeGadget(gadget)
    EndIf    
  EndProcedure
  
  Procedure _GetDefault(*Lexer.LexerStyle) ; Get the default style
    ;Get Default Style 
    Protected back=$DFFFFF
    Protected backMargin=$dfefef
    Protected backgrey=$010101* ((back&$ff+(back>>8)&$ff +(back>>16)&$ff)/3) -$050505 ;$DFDFDF
    Protected i
    __SetStyle(*Lexer\None          ,$000000,back,0,"Courier New",10) ;Also default-Value for all undefinied types
    __SetStyle(*Lexer\LineNumber    ,$666666,backMargin)
    
    For i=0 To #STYLE_DEFAULT-1
      __SetStyle(*lexer\type[i])
    Next
    
    __SetStyle(*Lexer\type[#LType_String]        ,$ff7f00)
    __SetStyle(*Lexer\type[#LType_String2]       ,$dd4f00)
    __SetStyle(*lexer\type[#LType_StringBlock]   ,$ff7f00,backgrey,#PB_Font_StrikeOut)
    __SetStyle(*Lexer\type[#LType_Comment]       ,$AAAA00)
    __SetStyle(*Lexer\type[#LType_CommentBlock]  ,$AAAA00,backgrey,#PB_Font_StrikeOut)
    __SetStyle(*Lexer\type[#LType_Number]        ,$663300)
    __SetStyle(*Lexer\type[#LType_HexNumber]     ,$663300)
    __SetStyle(*Lexer\type[#LType_BinNumber]     ,$663300)
    __SetStyle(*Lexer\type[#LType_Keyword]       ,$666600)
    __SetStyle(*Lexer\type[#LType_Function]      ,$666600,back,#PB_Font_Bold)
    __SetStyle(*Lexer\type[#LType_Macro]         ,$666600,back,#PB_Font_Bold)
    __SetStyle(*Lexer\type[#LType_Constant]      ,$666666,back,#PB_Font_Bold)
    __SetStyle(*Lexer\type[#LType_Command]       ,$000000,back,#PB_Font_Bold)
    __SetStyle(*Lexer\type[#LType_Label]         ,$ff00ff)
    __SetStyle(*Lexer\Type[#LType_Invalid]       ,$0000ff)
    
    ;whitespace, operator = None/default style
    
    __SetStyle(*lexer\CallTip,$666666,$efffff,0,"Arial",9)
    *lexer\CallTipHilight=$aa0000
    
    *lexer\IndentGuide\fore=$aaaaaa
    *lexer\IndentGuide\back=$aaaaaa
    
    *Lexer\FolderMark\fore=$ffffff
    *Lexer\FolderMark\back=$000000
    *Lexer\RepeatedSelection\color=$006600
    *Lexer\RepeatedSelection\alpha=50
    *Lexer\Brace\color=$006600
    *Lexer\Brace\alpha=50
    *Lexer\BadBrace\color=$0000ff
    *Lexer\BadBrace\alpha=128
    *Lexer\Fold=#True
    *Lexer\AutoIndention=#AutoIndention_force
    *Lexer\TabSize=2
    *Lexer\Currentline\color=$0
    *Lexer\Currentline\alpha=10;#SC_ALPHA_NOALPHA
    *Lexer\MinLinenumberSize=3
    *lexer\UseSpaceForIndention=#True
    *lexer\AutoFillUpChars=""
    *lexer\showCalltips=#True
    *lexer\doAutocompletion=#True
  EndProcedure
  Procedure SetStyle(Gadget,*lexer.LexerStyle) ; Set a Style
    Protected *Property.Property=GetProperty(gadget)
    ;Set Style for a Scintilla-Gadget
    Protected width,i
    With *lexer
      __SetFontStyle(Gadget,#STYLE_DEFAULT,\None)
      ScintillaSendMessage(Gadget,#SCI_STYLECLEARALL)
      __SetFontStyle(Gadget,#STYLE_LINENUMBER,\LineNumber)
      __SetFontStyle(gadget,#STYLE_CALLTIP,\CallTip)
      ScintillaSendMessage(gadget, #SCI_CALLTIPSETFOREHLT,\CallTipHilight)
      
      For i=0 To #STYLE_DEFAULT-1
        __SetFontStyle(Gadget,i,\Type[i])
      Next
      ScintillaSendMessage(Gadget,#SCI_SETFOLDMARGINCOLOUR,#margin_fold,\LineNumber\back)
      ScintillaSendMessage(Gadget,#SCI_SETFOLDMARGINHICOLOUR,#margin_fold,\LineNumber\back)
      
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDER,\FolderMark\fore); +
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDER, \FolderMark\back); +
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPEN,\FolderMark\fore); -
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPEN, \FolderMark\back); -
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPENMID, \FolderMark\fore) ; -|
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPENMID, \FolderMark\back) ; -|
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEREND, \FolderMark\fore)     ; -|
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEREND, \FolderMark\back)     ; -| 
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDERSUB, \FolderMark\back)     ; |
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERSUB, \FolderMark\back)     ; |
      
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDERTAIL, \FolderMark\fore) ; /
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERTAIL, \FolderMark\back) ; /
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDERMIDTAIL,\FolderMark\fore) ; /|
      ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERMIDTAIL, \FolderMark\back); /|
      
      ScintillaSendMessage(gadget,#SCI_INDICSETSTYLE,#indicator_selection,#INDIC_STRAIGHTBOX);fullbox
      ScintillaSendMessage(gadget,#SCI_INDICSETFORE,#indicator_selection,\RepeatedSelection\color)
      ScintillaSendMessage(gadget,#SCI_INDICSETALPHA,#indicator_selection,\RepeatedSelection\alpha)
      ScintillaSendMessage(gadget,#SCI_INDICSETUNDER,#indicator_selection,#True)
      
      ScintillaSendMessage(gadget,#SCI_INDICSETSTYLE,#indicator_brace,#INDIC_STRAIGHTBOX);fullbox
      ScintillaSendMessage(gadget,#SCI_INDICSETFORE,#indicator_brace,\Brace\color)
      ScintillaSendMessage(gadget,#SCI_INDICSETALPHA,#indicator_brace,\Brace\alpha)
      ScintillaSendMessage(gadget,#SCI_INDICSETUNDER,#indicator_brace,#True)
      
      ScintillaSendMessage(gadget,#SCI_INDICSETSTYLE,#indicator_badbrace,#INDIC_STRAIGHTBOX);fullbox
      ScintillaSendMessage(gadget,#SCI_INDICSETFORE,#indicator_badbrace,\badBrace\color)
      ScintillaSendMessage(gadget,#SCI_INDICSETALPHA,#indicator_badbrace,\badBrace\alpha)
      ScintillaSendMessage(gadget,#SCI_INDICSETUNDER,#indicator_badbrace,#True)
      
      *Property\Fold=\fold
      *Property\RepeatedSelection=Bool(\RepeatedSelection\alpha)
      If \fold 
        width=ScintillaSendMessage(gadget,#SCI_TEXTWIDTH,#STYLE_LINENUMBER,@"9")*2
        ScintillaSendMessage(Gadget,#SCI_SETMARGINWIDTHN,#margin_fold, width)
      Else
        ScintillaSendMessage(Gadget,#SCI_SETMARGINWIDTHN,#margin_fold, 0)
      EndIf
      *Property\Brace=Bool(\Brace\alpha Or \BadBrace\alpha)
      *Property\AutoIndention=\AutoIndention
      *Property\MinLinenumberSize=\MinLinenumberSize
      ;*Property\UseSpaceForIndention=\UseSpaceForIndention
      
      ScintillaSendMessage(gadget,#SCI_SETUSETABS,Bool(Not \UseSpaceForIndention))
      
      width=ScintillaSendMessage(gadget,#SCI_TEXTWIDTH,#STYLE_CALLTIP,@" ")* \TabSize
      ScintillaSendMessage(gadget,#SCI_SETTABWIDTH,\TabSize)
      ScintillaSendMessage(gadget,#SCI_CALLTIPUSESTYLE,width)
      
      ScintillaSendMessage(gadget,#SCI_SETCARETLINEVISIBLE,Bool( \Currentline\alpha))
      ScintillaSendMessage(gadget,#SCI_SETCARETLINEBACK,\Currentline\color)
      ScintillaSendMessage(Gadget,#SCI_SETCARETLINEBACKALPHA,\Currentline\alpha)
      
      ;Autocomplete-select-chars
      ScintillaSendMessage(gadget,#SCI_AUTOCSETFILLUPS,0,FastASCII(\AutoFillUpChars))  
      
      *Property\ShowCallTips=\showCalltips
      
      If \IndentGuide\fore>-1 And \IndentGuide\back>-1
        ScintillaSendMessage(gadget,#SCI_STYLESETFORE,#STYLE_INDENTGUIDE,\IndentGuide\fore)
        ScintillaSendMessage(gadget,#SCI_STYLESETBACK,#STYLE_INDENTGUIDE,\IndentGuide\back)
        ScintillaSendMessage(gadget,#SCI_SETINDENTATIONGUIDES,#SC_IV_LOOKFORWARD)
      Else
        ScintillaSendMessage(gadget,#SCI_SETINDENTATIONGUIDES,#SC_IV_NONE)
      EndIf
      
      *Property\DoAutocompletion=\doAutocompletion
      setLineWidth(gadget)
      
      
    EndWith
  EndProcedure
  
  Procedure AddSearcher(List searcher.searcher(),type.i,Exp.s,ExpFlag=0,ExpEnd.s="",ExpEndFlag=0,Flags=0) ; Add a Searcher
    Protected r=CreateRegularExpression(#PB_Any,Exp,ExpFlag)
    If R
      AddElement( Searcher())
      Searcher()\RegEx=r
      searcher()\type=type
      
      If ExpEnd<>""
        Searcher()\RegExEnd=CreateRegularExpression(#PB_Any,ExpEnd,ExpEndFlag)
        CompilerIf #PB_Compiler_Debugger
          If Searcher()\RegExEnd=0
            Debug "add:"+ExpEnd+"°°"+ RegularExpressionError()
            CallDebugger
          EndIf
        CompilerEndIf
      EndIf
      
      Searcher()\Flags=flags
      
      CompilerIf #PB_Compiler_Debugger
      Else
        Debug "add:"+exp+"°°"+ RegularExpressionError()
        CallDebugger
      CompilerEndIf
      
    EndIf
    ProcedureReturn r
  EndProcedure
  
  Procedure _Callback(Gadget, *scinotify.SCNotification,*lexer.BaseLexer) ; scintilla-Callback for the lexer
    Protected startPos,lineNumber,mode,width,i,EndLineNumber
    Protected *Property.Property=GetProperty(gadget)
    Protected word.s
    Protected type
    
    ;When undo is disabled, don nothing (for example happend with ForceCaseMatch
    If ScintillaSendMessage(gadget,#SCI_GETUNDOCOLLECTION)=#False
      ProcedureReturn #False
    EndIf
        
    Select *scinotify\nmhdr\code
      Case #SCN_ZOOM
        ;correct the linenumber and fold-margin
        setLineWidth(gadget)
        If *Property\Fold
          width=ScintillaSendMessage(gadget,#SCI_TEXTWIDTH,#STYLE_LINENUMBER,@"9")*2
          ScintillaSendMessage(Gadget,#SCI_SETMARGINWIDTHN, #margin_fold, width)
        EndIf
        
      Case #SCN_UPDATEUI
        ;Selection/Cursor has changed
        If *scinotify\updated&#SC_UPDATE_SELECTION
          MarkBrace(gadget,*lexer\Brace)
          RepeatedSelection(gadget)          
          calltip(gadget,*lexer)
          
          ;Test if the current line has changed
          startpos=ScintillaSendMessage(gadget,#SCI_GETCURRENTPOS)
          lineNumber=ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,startPos)
          If lineNumber<> *Property\LastActiveLine
            *Property\LastActiveLine=lineNumber
            
            ;do autoindention 
            If *Property\AutoIndention=#AutoIndention_force
              If *Property\IndentEnd>-1
                *Property\DoIndent=#True
                ScintillaSendMessage(gadget,#SCI_BEGINUNDOACTION)
                For i= *Property\IndentStart To *Property\IndentEnd
                  If i<>lineNumber
                    IndentLine(gadget,i)
                  EndIf
                Next
                ScintillaSendMessage(gadget,#SCI_ENDUNDOACTION)
                *Property\DoIndent=#False
                *Property\IndentEnd=-1
                *Property\IndentStart=-1
              EndIf
            EndIf
          EndIf
        EndIf
        
      Case #SCN_MODIFIED
        ; Search for new words for the user-list. Removed unused
        If *Property\DoIndent=#False And *Property\DoAutocompletion
          If (*scinotify\modificationType&#SC_MOD_BEFOREINSERT)
            Highlight(gadget,*scinotify\position,*scinotify\position,*lexer,#False,-1)
          EndIf
          If (*scinotify\modificationType&#SC_MOD_BEFOREDELETE)
            Highlight(gadget,*scinotify\position,*scinotify\position+*scinotify\length,*lexer,#False,-1)
          EndIf
          If (*scinotify\modificationType&#SC_MOD_INSERTTEXT)
            Highlight(gadget,*scinotify\position,*scinotify\position+*scinotify\length,*lexer,#False,1)
          EndIf
          If (*scinotify\modificationType&#SC_MOD_DELETETEXT)
            Highlight(gadget,*scinotify\position,*scinotify\position+*scinotify\length,*lexer,#False,1)
          EndIf
        EndIf
        
        ;Correct brace
        If *scinotify\modificationType  & (#SC_MOD_DELETETEXT)
          MarkBrace(gadget,*lexer\Brace)
        EndIf
        
        ;User delete Text
        If *scinotify\length=1 And (*scinotify\modificationType&#SC_MOD_DELETETEXT) And *scinotify\position=ScintillaSendMessage(gadget,#SCI_GETCURRENTPOS) 
          word=Left(*Property\CursorWord,Len(*Property\CursorWord)-1)
          Autocomplete(gadget,word,
                       *lexer\Type[*Property\CUrsorWordType]\Remap(),
                       *Property\Type[*Property\CursorWordType]\Remap(),*lexer)
          calltip(gadget,*lexer)
        EndIf
        
        ;check if the linenumber-margin is width engouht
        If (*scinotify\modificationType  & (#SC_MOD_INSERTTEXT|#SC_MOD_DELETETEXT)) And *scinotify\linesAdded
          setLineWidth(gadget)
        EndIf
        
      Case #SCN_CHARADDED
        word=*Property\CursorWord+Chr(*scinotify\ch)
        Autocomplete(gadget,word,
                     *lexer\Type[*Property\CUrsorWordType]\Remap(),
                     *Property\Type[*Property\CursorWordType]\Remap(),*lexer)
        
       
        startpos=ScintillaSendMessage(gadget,#SCI_GETCURRENTPOS)
        lineNumber=ScintillaSendMessage(gadget,#SCI_LINEFROMPOSITION,startPos)
        *Property\LastActiveLine=lineNumber
        
        ;New Line? Do Indention
        If (*scinotify\ch=10 Or *scinotify\ch=13) And *Property\AutoIndention
          
          mode=ScintillaSendMessage(gadget,#SCI_GETEOLMODE)
          If (mode=#SC_EOL_CR And *scinotify\ch=13) Or (mode<>#SC_EOL_CR And *scinotify\ch=10)
            Highlight(gadget,startpos-1,startpos-1,*lexer)
            
            *Property\DoIndent=#True
            ScintillaSendMessage(gadget,#SCI_BEGINUNDOACTION)
            
            If *Property\AutoIndention=#AutoIndention_simple
              SimpleIndentLine(Gadget,lineNumber-1)
              SimpleIndentLine(gadget,lineNumber,#True)
            Else
              
              If *Property\IndentEnd>-1
                For i= *Property\IndentStart To *Property\IndentEnd
                  If i<>lineNumber
                    IndentLine(gadget,i)
                  EndIf
                Next
                *Property\IndentEnd=-1
                *Property\IndentStart=-1
              EndIf
              IndentLine(gadget,lineNumber,#True)
            EndIf
            
            ScintillaSendMessage(gadget,#SCI_ENDUNDOACTION)
            *Property\DoIndent=#False
            
          EndIf     
          
        EndIf
        
        MarkBrace(gadget,*lexer\Brace)
        calltip(gadget,*lexer,#True,Bool(*scinotify\ch=Asc(*lexer\CallTipStart) Or *scinotify\ch=Asc(*lexer\CallTipLimiter) ) )
        
        
      Case #SCN_MARGINCLICK
        ;Disabled by automatic handling
        ;         If *scinotify\margin = #margin_fold
        ;           lineNumber = ScintillaSendMessage(Gadget,#SCI_LINEFROMPOSITION,*scinotify\position)
        ;           ScintillaSendMessage(Gadget,#SCI_TOGGLEFOLD, lineNumber, 0)
        ;         EndIf
        
        
      Case #SCN_AUTOCCHARDELETED
        word=Left(*Property\CursorWord,Len(*Property\CursorWord)-1)
        Autocomplete(gadget,word,
                     *lexer\Type[*Property\CUrsorWordType]\Remap(),
                     *Property\Type[*Property\CursorWordType]\Remap(),*lexer)
        
      Case #SCN_AUTOCSELECTION
        *Property\CursorWord=PeekS(*scinotify\text,-1,#PB_Ascii)
        
      Case  #SCN_STYLENEEDED
        startPos =ScintillaSendMessage(Gadget,#SCI_GETENDSTYLED)
        Highlight(Gadget,startPos, *scinotify\position,*lexer);positions are automatic corrected to line
        
    EndSelect
    
    ProcedureReturn #True
  EndProcedure  
  
  Procedure _Init(gadget,*style.lexerstyle,*lexer.BaseLexer); Default init
    Protected defaultstyle.lexerstyle
    Protected *Property.Property=GetProperty(gadget)
    
    ;Don't collect words for this types
    *lexer\Type[#LType_Number]\dontCount=#True
    *lexer\Type[#LType_BinNumber]\dontCount=#True
    *lexer\Type[#LType_HexNumber]\dontCount=#True
    *lexer\Type[#LType_WhiteSpace]\dontCount=#True
    *lexer\Type[#LType_Comment]\dontCount=#True
    *lexer\Type[#LType_CommentBlock]\dontCount=#True
    *lexer\Type[#LType_String]\dontCount=#True
    *lexer\Type[#LType_string2]\dontCount=#True
    *lexer\Type[#LType_StringBlock]\dontCount=#True
    *lexer\Type[#LType_Invalid]\dontCount=#True
    *lexer\type[#LType_Operator]\dontCount=#True
    *lexer\type[#LType_Invalid]\dontCount=#True
    
    ; remove closed gadgets.
    FreeProperty()
    
    ; Get Default style
    If *style=0
      _GetDefault(defaultstyle)
      *style=defaultstyle
    EndIf
    
    *Property\IndentEnd=-1
    *Property\IndentStart=-1
    
    ; Use Indicators for Brace-Highlight
    ScintillaSendMessage(gadget,#SCI_BRACEHIGHLIGHTINDICATOR,#True,#indicator_brace)
    ScintillaSendMessage(gadget,#SCI_BRACEBADLIGHTINDICATOR,#True,#indicator_badbrace)
    
    ; Fix the horizontal scrolling bar
    ScintillaSendMessage(gadget,#SCI_SETSCROLLWIDTHTRACKING,#True)
    ScintillaSendMessage(gadget,#SCI_SETSCROLLWIDTH,100)
    
    ; Scroll before the Cursor reach the boarder
    ScintillaSendMessage(gadget,#SCI_SETXCARETPOLICY,#CARET_SLOP|#CARET_EVEN|#CARET_STRICT 	,100)
    ScintillaSendMessage(gadget,#SCI_SETYCARETPOLICY,#CARET_SLOP|#CARET_EVEN|#CARET_STRICT 	,3)
    
    ; Set fold-Margin
    ScintillaSendMessage(Gadget,#SCI_SETMARGINTYPEN,  #margin_fold, #SC_MARGIN_SYMBOL )
    ScintillaSendMessage(Gadget,#SCI_SETMARGINMASKN,  #margin_fold, #SC_MASK_FOLDERS)
    ScintillaSendMessage(Gadget,#SCI_SETMARGINSENSITIVEN, #margin_fold, #True)
    
    ; Fold-Symbols
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPEN     , #SC_MARK_BOXMINUS)
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDER         , #SC_MARK_BOXPLUS)
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERSUB      , #SC_MARK_VLINE)
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERTAIL     , #SC_MARK_LCORNER)
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEREND      , #SC_MARK_BOXPLUSCONNECTED)
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPENMID  , #SC_MARK_BOXMINUSCONNECTED)
    ScintillaSendMessage(Gadget,#SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERMIDTAIL  , #SC_MARK_TCORNER)
    
    ; Automatic fold handling
    ScintillaSendMessage(Gadget,#SCI_SETAUTOMATICFOLD,#SC_AUTOMATICFOLD_SHOW|#SC_AUTOMATICFOLD_CLICK|#SC_AUTOMATICFOLD_CHANGE)
    ScintillaSendMessage(gadget,#SCI_SETFOLDFLAGS,#SC_FOLDFLAG_LINEAFTER_CONTRACTED)
    
    ;Set Lexer to Container
    ScintillaSendMessage(Gadget,#SCI_SETLEXER,#SCLEX_CONTAINER)
    
    ;Chars for Word-Detection
    ScintillaSendMessage(gadget,#SCI_SETWORDCHARS,0, FastASCII(*lexer\WordChars))
    ScintillaSendMessage(gadget,#SCI_SETPUNCTUATIONCHARS,0,FastASCII(*lexer\PunctuationChars))
    ScintillaSendMessage(gadget,#SCI_SETWHITESPACECHARS,0,FastASCII(*lexer\WhiteSpaceChars))
    
    ;autocompletion
    ScintillaSendMessage(gadget,#SCI_AUTOCSETIGNORECASE,Bool(*lexer\MatchCase=#False ))
    ScintillaSendMessage(gadget,#SCI_AUTOCSTOPS,0,FastASCII(#CRLF$))
    
    ;the style
    SetStyle(Gadget,*style)
        
    ProcedureReturn #True
  EndProcedure
  
EndModule
;---
DeclareModule LUA_Lexer
  ;We need some more type
  Enumeration _Base_Lexer::#LTYPE__ForLexer
    #LType_OperatorBad
  EndEnumeration
  Declare.i use()
  Declare.i GetRemap(type.i)
  Declare.i init()
  Declare.i GetDefault(*style._Base_Lexer::LexerStyle)
  
  
EndDeclareModule

Module LUA_Lexer
  EnableExplicit
  UseModule _Base_Lexer
    
  Global Lexer.BaseLexer
  
  Procedure GetRemap(ltype);Get the Remap-Table
    ProcedureReturn @lexer\Type[ltype]
  EndProcedure
 
  Procedure GetDefault(*style.Lexerstyle); Get default Style for this lexer
    _GetDefault(*style)
    __SetStyle(*style\type[#LType_OperatorBad]   ,$0000ff)
  EndProcedure
  
  Procedure LuaCallback(Gadget,*scinotify.SCNotification); simple call the default callback with our lexer table
    ProcedureReturn _Callback(Gadget, *scinotify, Lexer)
  EndProcedure
  
  Procedure init()
    Protected word.s,type,convert,SortWord.s,calltip.s,i,tooltip.s
    
    ;only initalise once
    If lexer\WordChars=""
      lexer\WordChars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
      lexer\PunctuationChars=~"~}|{`^]\\[@?>=<;:/.-,+*)('&%$#\"!"
      Lexer\WhiteSpaceChars=#TAB$+" "
      lexer\Brace="[](){}"
      lexer\MatchCase=#False
      lexer\CallTipStart="("
      lexer\CallTipEnd=")"
      lexer\CallTipLimiter=","
      lexer\CallTipIgnoreHilight="[]"
      
      ;Searcherlist
      AddSearcher(lexer\Searcher(),#LType_keyword,     "^[a-zA-Z_]{1}[a-zA-Z0-9_]*(?:\.[a-zA-Z_]{1}[a-zA-Z0-9_]*|\.)?")
      
      AddSearcher(lexer\Searcher(),#LType_String,     ~"^\"\"|^\".*?[^\\\\]\"",#PB_RegularExpression_MultiLine|#PB_RegularExpression_AnyNewLine)
      AddSearcher(lexer\Searcher(),#LType_String2,     "^''|^'.*?[^\\]'",#PB_RegularExpression_MultiLine|#PB_RegularExpression_AnyNewLine)
      AddSearcher(lexer\Searcher(),#LType_Invalid,    ~"^['\"].*$")
      AddSearcher(Lexer\Searcher(),#LType_StringBlock, "^\[\=*\[", 0,"\]\=*\]",0,#Searcher_MarkSizeEqual)
      
      AddSearcher(lexer\Searcher(),#LType_Label,       "^::[a-zA-Z_]{1}[a-zA-Z0-9_]*?::")
      
      AddSearcher(lexer\Searcher(),#LType_Number,      "^[0-9]+(?:\.[0-9]*)?(?:[eE][\+\-]?[0-9]+)?(?=[^a-zA-Z0-9\_\.]|$)")
      Addsearcher(lexer\Searcher(),#LType_HexNumber,   "^0[xX][0-9a-fA-F]+(?:\.[0-9a-fA-F]*)?(?:[pP][\+\-]?[0-9a-fA-F]+)?(?=[^a-zA-Z0-9\_\.]|$)")
      addsearcher(lexer\Searcher(),#LType_Invalid,     "^[0-9][0-9a-zA-Z\._\+\-]*")
      
      Addsearcher(lexer\Searcher(),#LType_WhiteSpace,  "^[\x09\x20]+")
      
      AddSearcher(Lexer\Searcher(),#LType_CommentBlock,"^\-\-\[\=*\[", 0,"\-\-\]\=*\]",0,#Searcher_MarkSizeEqual);before normal comment!
      AddSearcher(lexer\Searcher(),#LType_Comment,     "^\-\-.*") ;line comment
      
      AddSearcher(Lexer\Searcher(),#LType_OperatorBad, "^[\+\-\*\/\%\^\#\&\~\|\<\>\=\:\.]+")
      addsearcher(lexer\Searcher(),#LType_Operator,    "^[\(\)\{\}\[\]\,\;]");always "alone", so multi-char-operator can be colored correct
      
      ;Read the word list. #...tab... - constant are used for indention-marks
      #TABplus$=#TAB$+"a+"
      #TABminus$=#TAB$+"a-"
      #plusTAB$=#TAB$+"b+"
      #minusTAB$=#TAB$+"b-"
      Restore reservedWords
      Repeat
        Read type
        If type=-1
          Break
        EndIf
        Read convert
        With lexer\type[type]
          Repeat
            Read.s word:If word="":Break:EndIf
            If Asc(word)<32
              If FindString(word,#LF$)
                \Remap()\Flags=#LTypeFlag_FoldStart  
              EndIf
              If FindString(word,#CR$)
                \Remap()\Flags=#LTypeFlag_FoldEnd
              EndIf
              \Remap()\IndentionAfter=CountString(word,#TABplus$)-CountString(word,#TABminus$)
              \remap()\IndentionBefore=CountString(word,#plusTAB$)-CountString(word,#minusTAB$)
            Else
              i=FindString(word,~"\n")
              If i
                calltip=Left(word,i-1)+Mid(word,i+1)
                word=Left(word,i-1)
              Else
                calltip=""
              EndIf
              i=FindString(word,~"\r")
              If i
                tooltip=Mid(word,i+1)
                word=Left(word,i-1)
              Else
                tooltip=""
              EndIf
              
              If lexer\MatchCase
                SortWord=word
              Else
                SortWord=UCase(word)
              EndIf  
              FindRemap(\Remap(),sortword)
              
              InsertElement(\Remap())
              \Remap()\SortWord=SortWord             
              \Remap()\Word=word
              \remap()\calltip=calltip
              \remap()\tooltip=tooltip
              \Remap()\ConvertTo=convert
            EndIf
          ForEver
        EndWith
      ForEver
    EndIf
    
    ProcedureReturn #True
    
    DataSection
      ;lf=FoldStart, cr=foldend,
      ;#...tab... - constant are used for indention-marks
      ;\r seperate a tooltip, \n calltip
      reservedWords:  
      Data.i #LType_CommentBlock,-1 ; remaplist, ConvertTo 
      Data.s "--[[",#LF$,"--]]",#CR$,
             ""
      
      Data.i #LType_keyword,#LType_Command
      Data.s "and","break","do",#LF$+#TABplus$,"else",#LFCR$+#TABplus$+#minusTAB$,"elseif",#LFCR$+#TABplus$+#minusTAB$,"end",#CR$+#minusTAB$,
             "false","for","function",#LF$+#TABplus$,"goto","if",#LF$+#TABplus$,"in","local","nil","not","or","repeat",#LF$+#TABplus$,"return",
             "then","true","until",#CR$+#minusTAB$, "while",
             ""
      
      Data.i #LType_keyword,#LType_Constant
      Data.s ~"package.config\rA string describing some compile-time configurations for packages",
             ~"package.cpath\rThe path used by require to search for a C loader",
             ~"package.loaded\rA table used by require to control which modules are already loaded",
             ~"package.path\rThe path used by require to search for a Lua loader",
             ~"package.preload\rA table to store loaders for specific modules (see require)",
             ~"package.searchers\rA table used by require to control how to load modules",
             ~"_G\rholds the global environment",
             ~"_VERSION\rstring containing the running Lua version. \"Lua 5.3\"",
             ~"utf8.charpattern\rThe pattern \"[\\0-\\x7F\\xC2-\\xF4][\\x80-\\xBF]*\"",
             ~"math.huge\rThe float value HUGE_VAL, larger than any other value",
             ~"math.maxinteger\rAn integer with the maximum value for an integer",
             ~"math.mininteger\rAn integer with the minimum value for an integer",
             ~"math.pi\rThe value of π",
             "coroutine","package","string","utf8","table","math","io","os",
             ""
      
      Data.i #LType_keyword,#LType_Function
      Data.s ~"assert\n(value [, message])\nCalls error if the value of its argument v is false/nil",
             ~"collectgarbage\n([opt [, arg]])\n\"collect\",\"stop\",\"restart\",\"count\",\"step\",\"setpause\",\"setstepmul\",\"isrunning\"",
             ~"dofile\n([filename])\nOpen file and execute",
             ~"error\n(message [, level])\nTerminates with error message",
             ~"getmetatable\n(object)\nReturn metatable or nil",
             ~"ipairs\n(table)\ninterate over all integer key-value of table t",
             ~"load\n(chunk [, chunkname [, mode [, env]]])\ncunk is a string or function, mode \"b\" \"t\" or \"bt\"",
             ~"loadfile\n([filename [, mode [, env]]])\nload a file, mode \"b\" \"t\" or \"bt\"",
             ~"next\n(table [, index])\nAllows a program to traverse all fields of a table",
             ~"pairs\n(table)\niterate over all key–value pairs of table t",
             ~"pcall\n(function [, arg1, ···])\nCalls function in protected mode",
             ~"print\n(···)\nprints their values",
             ~"rawequal\n(v1, v2)\nChecks whether v1 is equal to v2",
             ~"rawget\n(table, index)\nGets the real value of table[index]",
             ~"rawlen\n(value)\nReturns the length of a table or string",
             ~"rawset\n(table, index, value)\nSets the real value of table[index] to value",
             ~"select\n(index, ···)\nreturns all after index; <0 from the end; \"#\" total number",
             ~"setmetatable\n(table, metatable)\nSets the metatable",
             ~"tonumber\n(value [, base])\nConvert to a number",
             ~"tostring\n(value)\nconverts it to a string",
             ~"type\n(value)\n\"nil\", \"number\", \"string\", \"boolean\", \"table\", \"function\", \"thread\",  \"userdata\"",
             ~"xpcall\n(function, msgh [, arg1, ···])\nCall function with message handler msgh",
             ~"coroutine.create\n(f)\nCreates a new coroutine",
             ~"coroutine.isyieldable\n()\nReturns true when the running coroutine can yield",
             ~"coroutine.resume\n(co [, val1, ···])\nStarts or continues the execution of coroutine co",
             ~"coroutine.running\n()\nReturns the running coroutine + a boolean, true when is the main",
             ~"coroutine.status\n(co)\nReturns \"running\", \"suspended\", \"normal\", \"dead\"",
             ~"coroutine.wrap\n(function)\nCreates a new coroutine",
             ~"coroutine.yield\n(···)\nSuspends the execution of the calling coroutine",
             ~"require\n(modname)\nLoads the given module",
             ~"package.loadlib\n(libname, funcname)\nDynamically links the host program with the C library libname",
             ~"package.searchpath\n(name, path [, sep=. [, rep=\\]])\nSearches for the given name in the given path",
             ~"string.byte\n(string [, start [, end]])\nReturns numeric of the characters",
             ~"string.char\n(···)\nReturns a string with character equal its argument",
             ~"string.dump\n(function [, strip])\nReturns a binary of the function",
             ~"string.find\n(string, pattern [, init [, plain]])\nLooks for the first match of pattern",
             ~"string.format\n(formatstring, ···)\nReturns a formatted version of its variable",
             ~"string.gmatch\n(string, pattern)\niterator for the captures from pattern",
             ~"string.gsub\n(string, pattern, replace [, count])\nReturns in which count occurrences of the pattern",
             ~"string.len\n(string)\nReturns a string length",
             ~"string.lower\n(string)\nuppercase letters changed to lowercase",
             ~"string.match\n(string, pattern [, init])\nLooks for the first match of pattern in the string string",
             ~"string.pack\n(formatstring, v1, v2, ···)\nReturns a binary string containing the v1, v2, etc. packed",
             ~"string.packsize\n(formatstring)\nReturns the size of a string.pack",
             ~"string.rep\n(string, count [, seperator])\nReturns a string that is count copies of the string with separator",
             ~"string.reverse\n(string)\nReturns a reversed string",
             ~"string.sub\n(string, start [, end])\nReturns the substring",
             ~"string.unpack\n(formatstring, string [, pos])\nReturns the values packed in string string",
             ~"string.upper\n(s)\nlowercase letters changed to uppercase",
             ~"utf8.char\n(···)\nconverts to UTF-8 byte sequence",
             ~"utf8.codes\n(string)\niterator for position and utf8-code",
             ~"utf8.codepoint\n(string [, start [, end]])\nReturns the codepoints (as integers)",
             ~"utf8.len\n(string [, start [, end]])\nReturns the number of UTF-8 characters",
             ~"utf8.offset\n(string, position [, start])\nReturns the position in bytes",
             ~"table.concat\n(list [, seperator [, start [, end]]])\nCombine the elements with the seperator",
             ~"table.insert\n(list, [pos,] value)\nInserts value at position in list, shifting up the elements",
             ~"table.move\n(a1, start, end, insertposition [,a2])\nMoves elements from table a1 to table a2,",
             ~"table.pack\n(···)\nReturns a table with all parameters stored into keys",
             ~"table.remove\n(list [, pos])\nRemoves from list the element at position",
             ~"table.sort\n(list [, comp])\nSorts list. If comp is given, then it must be a function",
             ~"table.unpack\n(list [, start [, end]])\nReturns the elements from the given list",
             ~"math.abs\n(x)\nReturns the absolute value of x. (integer/float)",
             ~"math.acos\n(x)\nReturns the arc cosine of x (in radians)",
             ~"math.asin\n(x)\nReturns the arc sine of x (in radians)",
             ~"math.atan\n(y [, x])\nReturns the arc tangent of y/x (in radians)",
             ~"math.ceil\n(x)\nReturns the smallest integral value larger than or equal to x",
             ~"math.cos\n(x)\nReturns the cosine of x (assumed to be in radians)",
             ~"math.deg\n(x)\nConverts the angle x from radians to degrees",
             ~"math.exp\n(x)\nReturns the value ex (where e is the base of natural logarithms)",
             ~"math.fmod\n(x, y)\nReturns the remainder of the division of x by y that rounds the quotient towards zero. (integer/float)",
             ~"math.log\n(x [, base])\nReturns the logarithm of x in the base (default e)",
             ~"math.max\n(x, ···)\nReturns the argument with the maximum value",
             ~"math.min\n(x, ···)\nReturns the argument with the minimum value",
             ~"math.modf\n(x)\nReturns the integral of x and the fractional of x",
             ~"math.rad\n(x)\nConverts the angle x from degrees to radians",
             ~"math.random\n([m [, n]])\nreturns a pseudo-random (0-1;1-n;n-m)",
             ~"math.randomseed\n(x)\nSets x as the \"seed\" for the pseudo-random",
             ~"math.sin\n(x)\nReturns the sine of x (assumed to be in radians)",
             ~"math.sqrt\n(x)\nReturns the square root of x",
             ~"math.tan\n(x)\nReturns the tangent of x (assumed to be in radians)",
             ~"math.tointeger\n(x)\nconvert to an integer or nil",
             ~"math.type\n(x)\nReturns \"integer\", \"float\" or nil",
             ~"math.ult\n(m, n)\nunsigned compare m<n",
             ~"io.close\n([file])\nClose file. Equivalent to file:close()",
             ~"io.flush\n()\nSaves any written data. Equivalent to io.output():flush()",
             ~"io.input\n([file])\nit opens the file (text mode), and sets as default input",
             ~"io.lines\n([filename, ···])\nOpens the file in read mode and returns an iterator function",
             ~"io.open\n(filename [, mode])\nThis function opens a file. Mode= \"r\",\"w\",\"r+\",\"w+\",\"a+\" +'b'",
             ~"io.output\n([file])\nIt opens the file (text mode), and sets as default output",
             ~"io.popen\n(prog [, mode])\nStart Program and its output/intput is redirected",
             ~"io.read\n(···)\nReads the file file, according to the given formats. Equivalent to io.input():read(···)",
             ~"io.tmpfile\n()\nReturns a handle for a temporary file",
             ~"io.type\n(obj)\nReturns \"file\", \"closed file\" or nil",
             ~"io.write\n(···)\nWrites the value of each of its arguments to file. Equivalent to io.output():write(···)",
             ~"os.clock\n()\nReturns the amount in seconds of CPU time used by the program",
             ~"os.date\n([format [, time]])\nReturns a string or a table containing date and time",
             ~"os.difftime\n(t2, t1)\nReturns the difference, in seconds",
             ~"os.execute\n([command])\nExecute a system-command!",
             ~"os.exit\n([code [, close]])\nExit the host program!",
             ~"os.getenv\n(varname)\nReturns of the process environment variable or nil",
             ~"os.remove\n(filename)\nDeletes the file",
             ~"os.rename\n(oldname, newname)\nRenames the file",
             ~"os.setlocale\n(locale [, category])\nSets the current locale of the program",
             ~"os.time\n([table])\nReturns the (current) time when called without arguments",
             ~"os.tmpname\n()\nReturns a string with a name that can be used for a temporary file",
             ""
      Data.i #LType_OperatorBad,#LType_Operator      
      Data.s "+","-","*","/","%","^","#","&","~","|","<<",">>","//","==","~=","<=",">=","<",">","=","(",")","{","}","[","]","::",";",":",",",".","..","...",
             ""
      Data.i -1,-1
      
    EndDataSection
  EndProcedure
  
  Procedure LuaInit(gadget,*style.lexerstyle); called by Scintilla::Gadget
    Protected DefStyle.lexerstyle
    If *style=0
      GetDefault(DefStyle)
      *style=DefStyle
    EndIf
    
    init()
    ProcedureReturn _init(gadget,*style,lexer)
  EndProcedure
  
  Procedure use() ;used for selection of the lexer. return a lexerinfo structure
    ProcedureReturn ?ret
    DataSection
      ret:
      Data.i @LuaCallback(),@LuaInit()
    EndDataSection
  EndProcedure
  
EndModule

DeclareModule PB_Lexer
  Enumeration _Base_Lexer::#LTYPE__ForLexer
    #LType_OperatorBad
    #LType_ConstantBad
    #LType_OperatorCompare
    #LType_Module
    #LType_Assembler
    #LType_Pointer
    #LType_Structure
    #LType_StructureField
    #LType_PBFunction
  EndEnumeration
  
  Declare.i use()
  Declare.i GetRemap(type.i)
  Declare.i init()
  Declare.i GetDefault(*style._Base_Lexer::LexerStyle)
  
  
EndDeclareModule
Module PB_Lexer
  EnableExplicit
  UseModule _Base_Lexer
   
  Global Lexer.BaseLexer
  
  Procedure GetRemap(ltype)
    ProcedureReturn @lexer\Type[ltype]
  EndProcedure
  
  Procedure PBCallback(Gadget,*scinotify.SCNotification)
    ProcedureReturn _Callback(Gadget, *scinotify, Lexer)
  EndProcedure
  
  Procedure init()
    Protected word.s,type,convert,SortWord.s,calltip.s,i,tooltip.s
    
    If lexer\WordChars=""
      lexer\WordChars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_#$"
      lexer\PunctuationChars=~"~}|{`^]\\[@?>=<;:/.-,+*)('&%\"!"
      Lexer\WhiteSpaceChars=#TAB$+" "
      lexer\Brace="[](){}"
      lexer\MatchCase=#False
      lexer\CallTipStart="("
      lexer\CallTipEnd=")"
      lexer\CallTipLimiter=","
      lexer\CallTipIgnoreHilight="[]"
      lexer\ForceCaseMatch=#True
      
      
      ;Pointer aren't easy to detect...
      ; *buf = 100+*buf
      ; is valid, so a *-pointer is after *+-([.!%&/|,~:
      ;in this case this activate
      AddSearcher(lexer\Searcher(),0,       "^[\*\+\-\(\[\.\!\%\&\/\|\,\~\:][ \t]*?\*[a-zA-Z_]",0,"",0,#Searcher_SetAllowFlagOnly|#LType_Pointer);Activate only the flag, doesn't select anything
      ;this searcher for the next round
      addsearcher(lexer\Searcher(),#LType_pointer,    "^\*[a-zA-Z_]{1}[a-zA-Z0-9_]*",0,"",0,#Searcher_OnlyWithAllowFlag|#LType_Pointer)
      ;also searcher are valid after command and operatorcompare
      addsearcher(lexer\Searcher(),#LType_pointer,    "^\*[a-zA-Z_]{1}[a-zA-Z0-9_]*",0,"",0,#Searcher_TypeBefore|#LType_Command)
      addsearcher(lexer\Searcher(),#LType_pointer,    "^\*[a-zA-Z_]{1}[a-zA-Z0-9_]*",0,"",0,#Searcher_TypeBefore|#LType_OperatorCompare)
      ;and on line start
      addsearcher(lexer\Searcher(),#LType_pointer,    "^[ \t]*?\*[a-zA-Z_]{1}[a-zA-Z0-9_]*",0,"",0,#Searcher_LineStartOnly)
      
      ;variable types or structures
      addsearcher(lexer\Searcher(),0,                 "^\.[a-zA-Z_]",0,"",0,#Searcher_SetAllowFlagOnly|#LType_Structure)
      addsearcher(Lexer\Searcher(),#LType_Structure,  "^[a-zA-Z_]{1}[a-zA-Z0-9_]*",0,"",0,#Searcher_OnlyWithAllowFlag|#LType_Structure)
      
      ;structure field
      addsearcher(lexer\Searcher(),0,                 "^\\[a-zA-Z_]",0,"",0,#Searcher_SetAllowFlagOnly|#LType_StructureField)
      addsearcher(Lexer\Searcher(),#LType_StructureField,  "^[a-zA-Z_]{1}[a-zA-Z0-9_]*",0,"",0,#Searcher_OnlyWithAllowFlag|#LType_StructureField)
      
      
      AddSearcher(lexer\Searcher(),#LType_Assembler,     "^[ \t]*?\!.*$",0,"",0,#Searcher_LineStartOnly);Only on Linestart
      addsearcher(lexer\Searcher(),#LType_ConstantBad,    "^#[a-zA-Z_]{1}[a-zA-Z0-9_]*\$?")
      AddSearcher(lexer\Searcher(),#LType_Label,       "^[a-zA-Z_]{1}[a-zA-Z0-9_]*?(?=:(?=[^:A-Za-z_#]|$))")
      AddSearcher(lexer\Searcher(),#LType_Module,       "^[a-zA-Z_]{1}[a-zA-Z0-9_]*?::")
      
      ;Functions are a little bit special. they are normal keywords with a ( at the end
      ;the problem is, that the autocomplete can't detect this, because the "(" typed at last
      ;so we do the handle with #LTYPE_KEYWORD and then "overwrite" this to #LTYPE_FUNCTION
      AddSearcher(lexer\Searcher(),#LType_keyword,     "^[a-zA-Z_]{1}[a-zA-Z0-9_]*(?=[ \t]*?\()",0,"",0,#Searcher_ForceThisKeywordTo|#LType_Function)
      
      ;normal Keyword handling
      AddSearcher(lexer\Searcher(),#LType_keyword,     "^[a-zA-Z_]{1}[a-zA-Z0-9_]*\$?")
      
      ;Literal strings
      AddSearcher(lexer\Searcher(),#LType_String,     ~"^~\"\"|^~\".*?[^\\\\]\"",#PB_RegularExpression_MultiLine|#PB_RegularExpression_AnyNewLine)
      ;Normal strings
      AddSearcher(lexer\Searcher(),#LType_String,     ~"^\".*?\"")
      ;'Char'
      AddSearcher(lexer\Searcher(),#LType_String2,     "^'.*?'")
      ;String without end mark = RED
      AddSearcher(lexer\Searcher(),#LType_Invalid,     ~"^\\~?['\"].*$")      
      
      ;Numbers
      AddSearcher(lexer\Searcher(),#LType_Number,      "^[0-9]+(?:\.[0-9]*)?(?:[eE][\+\-]?[0-9]+)?(?=[^a-zA-Z0-9\_\.\$]|$)")
      Addsearcher(lexer\Searcher(),#LType_HexNumber,   "^\$[0-9a-fA-F]*?(?=[^a-zA-Z0-9\_\.\$]|$)")
      addsearcher(lexer\Searcher(),#LType_BinNumber,   "^%[01]*?(?=[^a-zA-Z0-9\_\.\$]|$)")
      ;invalid number
      addsearcher(lexer\Searcher(),#LType_Invalid,     "^[0-9\$%][0-9a-zA-Z\._\+\-]*")
      
      Addsearcher(lexer\Searcher(),#LType_WhiteSpace,  "^[\x09\x20]+")
      
      ;comment with fold-mark - because wie need ;\{ as single word, we use a Multiline-Format with Line-End as EndMark 
      AddSearcher(lexer\Searcher(),#LType_comment,     "^;\{",0,"$")
      ;Bookmark-Comment with fold-mark
      AddSearcher(lexer\Searcher(),#LType_CommentBlock,"^;-\{",0,".*",#PB_RegularExpression_DotAll)
      ;Bookmark-Comment
      AddSearcher(lexer\Searcher(),#LType_CommentBlock,     "^;\-.*",#PB_RegularExpression_DotAll)
      ;Comment mit fold-end-mark
      AddSearcher(lexer\Searcher(),#ltype_comment,     "^;}",0,"$")
      ;normal comment
      AddSearcher(lexer\Searcher(),#LType_Comment,     "^;.*")
      
      ;Operators for the remap-table
      AddSearcher(Lexer\Searcher(),#LType_OperatorBad, "^[\<\>\=]+")
      ;Single-Char-Operator
      addsearcher(lexer\Searcher(),#LType_Operator,  "^[\(\)\{\}\[\]\%\,\.\@\:\+\-\*\\\~\/\&\|\!\?]");Brace are always "alone", so multi-char-operator can be colored correct
      
      
      ;Read wordlist
      #TABplus$=#TAB$+"a+"
      #TABminus$=#TAB$+"a-"
      #plusTAB$=#TAB$+"b+"
      #minusTAB$=#TAB$+"b-"
      Restore reservedWords
      Repeat
        Read type
        If type=-1
          Break
        EndIf
        Read convert
        With lexer\type[type]
          Repeat
            Read.s word:If word="":Break:EndIf
            If Asc(word)<32
              If FindString(word,#LF$)
                \Remap()\Flags=#LTypeFlag_FoldStart  
              EndIf
              If FindString(word,#CR$)
                \Remap()\Flags=#LTypeFlag_FoldEnd
              EndIf
              \Remap()\IndentionAfter=CountString(word,#TABplus$)-CountString(word,#TABminus$)
              \remap()\IndentionBefore=CountString(word,#plusTAB$)-CountString(word,#minusTAB$)
            Else
              i=FindString(word,~"\n")
              If i
                calltip=Left(word,i-1)+Mid(word,i+1)
                word=Left(word,i-1)
              Else
                calltip=""
              EndIf
              i=FindString(word,~"\r")
              If i
                tooltip=Mid(word,i+1)
                word=Left(word,i-1)
              Else
                tooltip=""
              EndIf
              
              If lexer\MatchCase
                SortWord=word
              Else
                SortWord=UCase(word)
              EndIf  
              FindRemap(\Remap(),sortword)
              
              InsertElement(\Remap())
              \Remap()\SortWord=SortWord             
              \Remap()\Word=word
              \remap()\calltip=calltip
              \remap()\tooltip=tooltip
              \Remap()\ConvertTo=convert
            EndIf
          ForEver
        EndWith
      ForEver
      
      ;After GOTO, GOSUB, RESTORE,? is the next Keyword ALWAYS a Label
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"GOTO")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Label)
      EndIf
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"GOSUB")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Label)
      EndIf
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"RESTORE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Label)
      EndIf
      ;? is missing, so we add this
      If FindRemap(lexer\Type[#LType_Operator]\Remap(),"?")=0
        InsertElement(lexer\type[#LType_Operator]\remap())
        lexer\type[#LType_Operator]\remap()\ConvertTo=-1
        lexer\type[#LType_Operator]\remap()\Word="?"
        lexer\type[#LType_Operator]\remap()\SortWord="?"
      EndIf
      lexer\Type[#LType_Operator]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Label)
      
      ;Module-Name-Change
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"MODULE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Module)
      EndIf
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"DECLAREMODULE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Module)
      EndIf
      
      ;define declare-Keywords
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"DECLARE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_DeclareKeyword)
      EndIf
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"PROCEDURE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_DeclareKeyword)
      EndIf
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"PROCEDUREC")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_DeclareKeyword)
      EndIf
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"PROCEDUREDLL")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_DeclareKeyword)
      EndIf
      
      ;Force Structure-type
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"STRUCTURE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Structure)
      EndIf      
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"INTERFACE")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Structure)
      EndIf      
      If FindRemap(lexer\Type[#LType_keyword]\Remap(),"EXTENDS")
        lexer\Type[#LType_keyword]\Remap()\Flags | (#LTypeFlag_ForceNextKeyword|#LType_Structure)
      EndIf
      
    EndIf
    DataSection
      ;lf=FoldStart, cr=foldend, 
      
      reservedWords:  
      Data.i #LType_Constant
      Data.s "#True","#False"
      Data.s ""
      Data.i #LType_Comment,-1
      Data.s ";{",#LF$,";}",#CR$
      Data.s ""
      Data.i #LType_CommentBlock,-1
      Data.s ";-{",#LF$
      Data.s ""
      
      Data.i #LType_keyword,#LType_Command
      Data.s "End","Goto","Swap"
      Data.s "Break","Continue"
      Data.s "For",#TABplus$,"ForEach",#TABplus$,"To","Step","Next",#minusTAB$
      Data.s "Gosub","FakeReturn","Return"
      Data.s "If",#TABplus$,"Else",#TABplus$+#minusTAB$,"ElseIf",#TABplus$+#minusTAB$,"Endif",#minusTAB$
      Data.s "Repeat",#TABplus$,"Until",#minusTAB$,"ForEver",#minusTAB$
      Data.s "Select",#tabplus$+#TABplus$,"Case",#TABplus$+#minusTAB$,"Default",#TABplus$+#minusTAB$,"EndSelect",#minusTAB$+#minusTAB$
      Data.s "While",#tabplus$,"Wend",#minusTAB$
      Data.s "Define","Global","Threaded"
      Data.s "Dim","ReDim"
      Data.s "EnumerationBinary",#TABplus$,"Enumeration",#TABplus$,"EndEnumeration",#minusTAB$
      Data.s "Interface",#TABplus$,"EndInterface",#minusTAB$,"Extends"
      Data.s "DeclareModule",#TABplus$+#LF$,"EndDeclareModule",#minusTAB$+#CR$,"Module",#TABplus$+#LF$,"EndModule",#minusTAB$+#CR$,"UseModule","UnuseModule"
      Data.s "NewList","NewMap"
      Data.s "Structure",#TABplus$,"EndStructure",#minusTAB$,"Align","StructureUnion",#TABplus$,"EndStructureUnion"+#minusTAB$
      Data.s "With",#TABplus$,"EndWith",#minusTAB$
      Data.s "Procedure",#TABplus$+#LF$,"ProcedureC",#TABplus$+#LF$,"ProcedureDLL",#TABplus$+#LF$,"EndProcedure",#minusTAB$+#CR$,"ProcedureReturn","Declare","Protected","Shared","Static"
      Data.s "Import",#TABplus$,"ImportC",#TABplus$,"EndImport",#minusTAB$
      Data.s "Macro",#tabplus$+#LF$,"EndMacro",#minusTAB$+#CR$,"UndefineMacro","MacroExpandedCount"
      Data.s "Prototype","PrototypeC"
      Data.s "Runtime"
      Data.s "DataSection",#TABplus$,"EndDataSection",#minusTAB$,"Data","Restore","Read"
      Data.s "Debug","CallDebugger","DebugLevel","DisableDebugger","EnableDebugger"
      Data.s "IncludeFile","XIncludeFile","IncludeBinary","IncludePath"
      Data.s "CompilerIf",#TABplus$,"CompilerElse",#TABplus$+#minusTAB$,"CompilerElseIf",#TABplus$+#minusTAB$,"CompilerEndif",#minusTAB$
      Data.s "CompilerSelect",#tabplus$+#TABplus$,"CompilerCase",#TABplus$+#minusTAB$,"CompilerDefault",#TABplus$+#minusTAB$,"CompilerEndSelect",#minusTAB$+#minusTAB$
      Data.s "CompilerError","CompilerWarning","DisableExplicit","EnableExplicit"
      Data.s "EnableASM",#TABplus$,"DisableASM",#minusTAB$
      
      Data.s ""
      
      Data.i #LType_keyword,#LType_OperatorCompare
      Data.s "And","Or","XOr","Not"
      Data.s ""
      
      Data.i #LType_OperatorBad,#LType_OperatorCompare
      Data.s "<",">","<=","=<",">=","=>","<>","="
      Data.s ""
      
      Data.i -1
      
    EndDataSection
  EndProcedure
  
  Procedure GetDefault(*style.Lexerstyle)
    _GetDefault(*style)
    __SetStyle(*style\type[#LType_OperatorBad]   ,$0000ff)
    __SetStyle(*style\type[#LType_Constant]      ,$aa00aa)
    __SetStyle(*style\type[#LType_ConstantBad]   ,$770077)
    __SetStyle(*style\type[#LType_Module]        ,$666666)
    __setstyle(*style\type[#LType_Assembler]     ,$00ff00) 
    __setstyle(*style\type[#LType_Pointer]       ,$666633,-1,#PB_Font_Italic)
    __setstyle(*style\type[#LType_Structure]     ,$666688)
    __setstyle(*style\type[#LType_StructureField],$555500)
    __setstyle(*style\type[#LType_PBFunction]    ,$000000,-1,#PB_Font_Bold)
  EndProcedure
  
  Procedure PBInit(gadget,*style.lexerstyle)
    Protected DefStyle.lexerstyle
    If *style=0
      GetDefault(DefStyle)
      *style=DefStyle
    EndIf
    init()
    ProcedureReturn _init(gadget,*style,lexer)
  EndProcedure
  
  Procedure use()
    ProcedureReturn ?ret
    DataSection
      ret:
      Data.i @PBCallback(),@PBInit()
    EndDataSection
  EndProcedure
  
EndModule


;-
;-##################################################################
;-
;- Demo Code
CompilerIf #PB_Compiler_IsMainFile
  Define hWnd
  Define text.s
  Define event
  Define gadget,gadget2
  
  scintilla::init()
  
  
  hWnd = OpenWindow(0,0,100,800,480,"leer",#PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget)
  ;SmartWindowRefresh(0,1)
  RemoveKeyboardShortcut(0,#PB_Shortcut_Tab)
  RemoveKeyboardShortcut(0,#PB_Shortcut_Tab|#PB_Shortcut_Shift)
  
  gadget= scintilla::gadget(#PB_Any,0,0,WindowWidth(0)/2,WindowHeight(0),Lua_Lexer::use())
  gadget2= scintilla::gadget(#PB_Any,WindowWidth(0)/2,0,WindowWidth(0)/2,WindowHeight(0),pb_Lexer::use())
  
  
  ;word-list can be downloaded here: http://game.gpihome.eu/PureBasic/scintilla/PBList.7z
  ;they are in the format, the compiler in "/standby"-modus output
  
  Debug "Read Constant List for PB"
  *Wordlist._Base_Lexer::list_remap=PB_Lexer::GetRemap(PB_Lexer::#LType_ConstantBad)
  file=ReadFile(#PB_Any,"PBConstantList.txt")
  If file
    While Not Eof(file)
      a$=ReadString(file)
      If a$
        type.s=StringField(a$,1,#TAB$)
        name.s=StringField(a$,2,#TAB$)
        value.s=StringField(a$,3,#TAB$)
        If type="2"
          value=Chr(34)+value+Chr(34)
        EndIf
        name="#"+name
        sortname.s=UCase(name)
        
        ;Insert in the #LTYPE_CONSTANTBAD-List convert to normal Constant
        If _Base_Lexer::FindRemap(*Wordlist\Remap(),sortname)=#False
          InsertElement(*Wordlist\Remap())
          With *Wordlist\Remap()
            \ConvertTo=_Base_Lexer::#LType_Constant
            \SortWord=sortname
            \tooltip=value
            \Word=name
          EndWith
        EndIf
        
      EndIf
    Wend
    CloseFile(file)
  EndIf
  
  *wordlist._Base_Lexer::list_remap=PB_Lexer::GetRemap(_Base_Lexer::#LType_keyword)
  Debug "Read Function List for PB"
  file=ReadFile(#PB_Any,"PBFunctionList.txt")
  If file
    While Not Eof(file)
      a$=ReadString(file)
      If a$
        i=FindString(a$,"(")
        name.s=Trim(Left(a$,i-1))
        a$=Trim(Mid(a$,i))
        i=FindString(a$,")")
        calltip.s=name.s+Trim(Left(a$,i))
        a$=Trim(Mid(a$,i+1))
        While Left(a$,1)=" " Or Left(a$,1)="-"
          a$=Mid(a$,2)
        Wend
        calltip+#LF$+a$        
        sortname.s=UCase(name)
        
        If _Base_Lexer::FindRemap(*Wordlist\Remap(),sortname) = #False
          ;This is now a little bit complicated. Same problen like in the Searcher-Section of the pb_lexer
          ;we need the entries in the KEYWORD-List for the autocomplete-list.
          ;It should only convert LTYPE_FUNCTION to LTYPE_PBFUNCTION
          ;and not LTYPE_KEYWORD to LTYPE_PBFUNCTION. this will do the flag above
          ;The Problem is, that OpenFile() is a SystemFunction, but OpenFile.i is a variable and should colored diffrent
          InsertElement(*Wordlist\Remap())
          With *Wordlist\Remap()
            \ConvertTo=pb_Lexer::#LType_PBFunction
            \SortWord=sortname
            \calltip=calltip
            \Flags=_Base_Lexer::#LTypeFlag_ConvertNeedSearcherForceThis|_Base_Lexer::#LType_Function
            \Word=name
          EndWith
        EndIf
        
        
      EndIf
    Wend
    CloseFile(file)
  EndIf
  
  
  text.s = "function test()"        + #CRLF$
  text.s + "  'blub' äöüß "               + #LF$
  text.s + "  load(asdf,wer((fasddasf)),afsd) "+#LF$
  text.s + "  load(adsf,rawlen(adsfkl))"+#LF$
  text.s + "  for [[something]] in 1 do " + #LF$
  text.s + "  end " + #LF$
  
  text.s + "end" +#LF$
  
  
  Scintilla::SetText(gadget,text)
  
  Define *type_operatorbad._Base_Lexer::list_remap=LUA_Lexer::GetRemap(LUA_Lexer::#LType_OperatorBad)
  
  ;   ForEach *type_operatorbad\Remap()
  ;     Debug *type_operatorbad\Remap()\Word
  ;   Next
  
  
  Repeat
    event = WaitWindowEvent()
    
    If event = #PB_Event_SizeWindow
      ResizeGadget(gadget,0,0,WindowWidth(0)/2,WindowHeight(0))
      ResizeGadget(gadget2,WindowWidth(0)/2,0,WindowWidth(0)/2,WindowHeight(0)) 
    EndIf
    
  Until event = #PB_Event_CloseWindow
  
  
  ;----
  ;---- EOL-Typ setzen auf correcten wert!
  ;----
  
  ;calltyp/tooltip style
  ;dotooltip/calltip
  ;free property einfügen.
  
  ;text=Scintilla::GetText(gadget)
  ;Debug text
  
CompilerEndIf
