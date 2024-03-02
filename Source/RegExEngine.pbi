
DeclareModule RegEx
  
  EnableExplicit
  
  EnumerationBinary RegExModes
    #RegExMode_NoCase ; Activates case-insensitive mode
    #RegExMode_Ascii  ; Activates ASCII mode
  EndEnumeration
  
  Enumeration NfaStateTypes
    #StateType_EpsilonMove ; Used for NFA epsilon moves
    #StateType_SymbolMove  ; Used for NFA symbol moves
    #StateType_SplitMove   ; Used for NFA unions
    #StateType_Final       ; Used for NFA final state
  EndEnumeration
  
  #State_DfaDeadState = 0 ; Index number of the DFA dead state
  
  Structure ByteRangeStruc
    min.a ; Minimum byte value (0-255)
    max.a ; Maximum byte value (0-255)
  EndStructure
  
  Structure NfaStateStruc
    stateType.u               ; Type of the NFA state (regExId = stateType - #StateType_NfaFinal)
    byteRange.ByteRangeStruc  ; A byte range is used as a transition symbol
    *nextState1.NfaStateStruc ; Pointer to the first next NFA state
    *nextState2.NfaStateStruc ; Pointer to the second next NFA state
  EndStructure
  
  Structure DfaStateStruc
    nextState.u[256] ; Index is the symbol (0-255) and the value is the next DFA state
    isFinalState.u   ; Positive number if the DFA state is a final state, otherwise null
  EndStructure
  
  Structure DfaStatesArrayStruc
    states.DfaStateStruc[0] ; Array pointer to the DFA states
  EndStructure
  
  Structure NfaPoolStruc
    List nfaStates.NfaStateStruc() ; Holds all NFA states of the NFA pool
    *initialNfaState.NfaStateStruc ; Pointer to the NFA initial state
  EndStructure
  
  Structure RegExEngineStruc
    List nfaPools.NfaPoolStruc()       ; Holds all NFA pools
    *dfaStatesPool.DfaStatesArrayStruc ; Holds all DFA states
    isUseDfaFromMemory.b               ; `#True` if `UseDfaFromMemory()` was used, otherwise `#False`
  EndStructure
  
  ; Simplifies extracting the matched string via its memory address and length
  ; info obtained from a `Match()` call.
  Macro GetString(_memoryAddress_, _lengthInBytes_)
    PeekS(_memoryAddress_, (_lengthInBytes_) >> 1)
  EndMacro
  
  ; Creates a new RegEx engine and returns the pointer to the
  ; `RegExEngineStruc` structure. If an error occurred null is returned.
  Declare Init()
  
  ; Compiles the RegEx string into an NFA which is added to the NFAs pool
  ; in the RegEx engine. On success `#True` is returned, otherwise `#False`.
  ; A unique number can be passed to `regExId` to determine later which RegEx
  ; has matched. The optional `regExModes` parameter allows defining which
  ; RegEx modes should be activated at the beginning.
  Declare AddNfa(*regExEngine.RegExEngineStruc, regExString$, regExId = 0, regExModes = 0)
  
  ; Creates a single DFA from the existing NFAs in the RegEx engine.
  ; `Match()` will henceforth always use the DFA, which is much faster.
  ; Because the NFAs are no longer used after this, they are cleared by default;
  ; to preserve them set parameter `clearNfa` to `#False`.
  ; On success `#True` is returned, otherwise `#False`.
  ; If a DFA already exists, the DFA will be freed before creating a new DFA.
  Declare CreateDfa(*regExEngine.RegExEngineStruc, clearNfa = #True)
  
  ; Frees the RegEx engine
  Declare Free(*regExEngine.RegExEngineStruc)
  
  ; Creates a new RegEx engine and assigns an existing DFA stored in external
  ; memory to the RegEx engine. After calling this procedure, the RegEx engine
  ; is immediately ready for use, without requiring to call `Init()`, `AddNfa()`
  ; or `CreateDfa()`.
  ; On success the pointer to `RegExEngineStruc` is returned, otherwise null.
  Declare UseDfaFromMemory(*dfaMemory)
  
  ; Runs the RegEx engine against the target string, passed via a pointer.
  ; The match search will start from the beginning of the string. If a match is
  ; found, the byte length of the match is returned, otherwise null.
  ; If the address of an integer variable was passed as the optional `*regExId`
  ; parameter, the RegEx ID number of the matching RegEx is written into it.
  ; If multiple RegExes match the same string, each having been assigned a
  ; different RegEx ID number, the RegEx ID number of the last matching RegEx
  ; will be picked, i.e. the matching RegEx that was last added with the
  ; `AddNfa()` function.
  Declare Match(*regExEngine.RegExEngineStruc, *string.Unicode, *regExId.Integer = 0)
  
  ; Returns the error messages of the last `AddNfa()` call, as a human-readable
  ; string.
  Declare$ GetLastErrorMessages()
  
  ; Exports the created DFA as a binary file. On success `#True` is returned,
  ; otherwise `#False`.
  Declare ExportDfa(*regExEngine.RegExEngineStruc, filePath$)
  
EndDeclareModule

Module RegEx
  
  CompilerIf #PB_Compiler_Debugger
    ; In debug mode the RegEx engine quickly
    ; becomes very slow with complex RegExes.
    DisableDebugger
  CompilerEndIf
  
  IncludeFile "UnicodeTables" + #PS$ + "PredefinedCharacterClasses.pbi"
  IncludeFile "UnicodeTables" + #PS$ + "SimpleCaseUnfolding.pbi"
  
  Structure NfaStruc
    *startState.NfaStateStruc
    *endState.NfaStateStruc
  EndStructure
  
  Structure EClosureStruc
    List *nfaStates.NfaStateStruc()
  EndStructure
  
  Structure CharacterStruc
    StructureUnion
      u.u
      a.a[2]
    EndStructureUnion
  EndStructure
  
  Structure RegExStringStruc
    *startPosition
    *currentPosition.CharacterStruc
  EndStructure
  
  Structure ByteRangesStruc
    byte1Range.ByteRangeStruc
    List byte2Ranges.ByteRangeStruc()
  EndStructure
  
  Global lastErrorMessages$
  
  Declare ParseRegEx(List nfaPool.NfaStateStruc(), *regExString.RegExStringStruc, finalStateValue, *regExModes.Integer)
  
  ; Returns the pointer to `NfaStateStruc`. On error, null is returned.
  Procedure CreateNfaState(List nfaPool.NfaStateStruc())
    ProcedureReturn AddElement(nfaPool())
  EndProcedure
  
  Procedure DeleteNfaState(List nfaPool.NfaStateStruc(), *state.NfaStateStruc)
    ChangeCurrentElement(nfaPool(), *state)
    DeleteElement(nfaPool())
  EndProcedure
  
  ; Creates a Thompson NFA with a state transition labeled with the symbol range.
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaByteRange(List nfaPool.NfaStateStruc(), minByteValue, maxByteValue, finalStateValue)
    Protected.NfaStruc *resultNfa = AllocateStructure(NfaStruc)
    
    If *resultNfa = 0
      ProcedureReturn 0
    EndIf
    
    *resultNfa\startState = CreateNfaState(nfaPool())
    If *resultNfa\startState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\startState\stateType = #StateType_SymbolMove
    *resultNfa\startState\byteRange\min = minByteValue
    *resultNfa\startState\byteRange\max = maxByteValue
    
    *resultNfa\endState = CreateNfaState(nfaPool())
    If *resultNfa\endState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\endState\stateType = finalStateValue
    
    *resultNfa\startState\nextState1 = *resultNfa\endState
    
    ProcedureReturn *resultNfa
  EndProcedure
  
  ; Creates a Thompson NFA concatenation.
  ; With the Thompson NFA, there are two ways to do this:
  ; - Connect the two NFAs with an epsilon transition
  ; - End state of the first NFA is replaced by the start state of the second NFA.
  ; Here, the second method is used because it avoids the need for an additional
  ; NFA state.
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaConcatenation(List nfaPool.NfaStateStruc(), *nfa1.NfaStruc, *nfa2.NfaStruc)
    Protected.NfaStruc *resultNfa = AllocateStructure(NfaStruc)
    
    If *resultNfa = 0
      ProcedureReturn 0
    EndIf
    
    *nfa1\endState\stateType = *nfa2\startState\stateType
    *nfa1\endState\byteRange\min = *nfa2\startState\byteRange\min
    *nfa1\endState\byteRange\max = *nfa2\startState\byteRange\max
    *nfa1\endState\nextState1 = *nfa2\startState\nextState1
    *nfa1\endState\nextState2 = *nfa2\startState\nextState2
    
    DeleteNfaState(nfaPool(), *nfa2\startState)
    
    *resultNfa\startState = *nfa1\startState
    *resultNfa\endState = *nfa2\endState
    
    ProcedureReturn *resultNfa
  EndProcedure
  
  ; Creates a Thompson NFA union construction.
  ; Note: In Thompson NFA, a union construction may only connect two states.
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaUnion(List nfaPool.NfaStateStruc(), *nfa1.NfaStruc, *nfa2.NfaStruc, finalStateValue)
    Protected.NfaStruc *resultNfa = AllocateStructure(NfaStruc)
    
    If *resultNfa = 0
      ProcedureReturn 0
    EndIf
    
    *resultNfa\startState = CreateNfaState(nfaPool())
    If *resultNfa\startState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\startState\stateType = #StateType_SplitMove
    *resultNfa\startState\nextState1 = *nfa1\startState
    *resultNfa\startState\nextState2 = *nfa2\startState
    
    *resultNfa\endState = CreateNfaState(nfaPool())
    If *resultNfa\endState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\endState\stateType = finalStateValue
    
    *nfa1\endState\stateType = #StateType_EpsilonMove
    *nfa1\endState\nextState1 = *resultNfa\endState
    
    *nfa2\endState\stateType = #StateType_EpsilonMove
    *nfa2\endState\nextState1 = *resultNfa\endState
    
    ProcedureReturn *resultNfa
  EndProcedure
  
  ; Creates a Thompson NFA "kleene star" construction.
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaZeroOrMore(List nfaPool.NfaStateStruc(), *nfa.NfaStruc, finalStateValue)
    Protected.NfaStruc *resultNfa = AllocateStructure(NfaStruc)
    
    If *resultNfa = 0
      ProcedureReturn 0
    EndIf
    
    *resultNfa\startState = CreateNfaState(nfaPool())
    If *resultNfa\startState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\startState\stateType = #StateType_SplitMove
    
    *resultNfa\endState = CreateNfaState(nfaPool())
    If *resultNfa\endState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\endState\stateType = finalStateValue
    
    *resultNfa\startState\nextState1 = *nfa\startState
    *resultNfa\startState\nextState2 = *resultNfa\endState
    
    *nfa\endState\stateType = #StateType_SplitMove
    *nfa\endState\nextState1 = *resultNfa\endState
    *nfa\endState\nextState2 = *nfa\startState
    
    ProcedureReturn *resultNfa
  EndProcedure
  
  ; This construction is a custom construction and not part of the Thompson NFA
  ; constructions. It reduces required NFA states that one would have if
  ; limited to the Thompson NFA constructions only.
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaOneOrMore(List nfaPool.NfaStateStruc(), *nfa.NfaStruc, finalStateValue)
    Protected.NfaStruc *resultNfa = AllocateStructure(NfaStruc)
    
    If *resultNfa = 0
      ProcedureReturn 0
    EndIf
    
    *resultNfa\startState = CreateNfaState(nfaPool())
    If *resultNfa\startState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\startState\stateType = #StateType_EpsilonMove
    
    *resultNfa\endState = CreateNfaState(nfaPool())
    If *resultNfa\endState = 0
      ProcedureReturn 0
    EndIf
    *resultNfa\endState\stateType = finalStateValue
    
    *resultNfa\startState\nextState1 = *nfa\startState
    
    *nfa\endState\stateType = #StateType_SplitMove
    *nfa\endState\nextState1 = *resultNfa\endState
    *nfa\endState\nextState2 = *nfa\startState
    
    ProcedureReturn *resultNfa
  EndProcedure
  
  ; This construction is a custom construction and not part of the Thompson NFA
  ; constructions.
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaZeroOrOne(List nfaPool.NfaStateStruc(), *nfa.NfaStruc, finalStateValue)
    Protected.NfaStruc *nfa2, *resultNfa
    
    *nfa2 = AllocateStructure(NfaStruc)
    If *nfa2 = 0
      ProcedureReturn 0
    EndIf
    
    *nfa2\startState = CreateNfaState(nfaPool())
    If *nfa2\startState = 0
      ProcedureReturn 0
    EndIf
    *nfa2\startState\stateType = #StateType_EpsilonMove
    
    *nfa2\endState = CreateNfaState(nfaPool())
    If *nfa2\endState = 0
      ProcedureReturn 0
    EndIf
    *nfa2\endState\stateType = finalStateValue
    
    *nfa2\startState\nextState1 = *nfa2\endState
    
    *resultNfa = CreateNfaUnion(nfaPool(), *nfa, *nfa2, finalStateValue)
    FreeStructure(*nfa2)
    
    ProcedureReturn *resultNfa
  EndProcedure
  
  ; Returns the RegEx string position as a number of characters
  Procedure GetCurrentCharacterPosition(*regExString.RegExStringStruc)
    Protected position = *regExString\currentPosition
    position - *regExString\startPosition
    position >> 1 ; Fast division by 2
    ProcedureReturn position + 1
  EndProcedure
  
  ; Creates from the byte tree the corresponding Thompson NFA construction.
  ; Byte ranges are combined into other byte ranges, if possible, in order to
  ; reduce the number of byte ranges and thus the number of NFA states
  ; required. Examples:
  ; - byte ranges `[1-2][1-2]` and `[3-4][1-2]` are combined as `[1-4][1-2]`
  ; - byte ranges `[1-2][1-2]` and `[1-2][3-4]` are combined as `[1-2][1-4]`
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure CreateNfaByteRangeSequences(List nfaPool.NfaStateStruc(), Array byteSequences.b(2), finalStateValue, isNegated = #False)
    Protected.NfaStruc *nfa1, *nfa2, *nfa2_new, *nfa3, *base, *base_new
    Protected.ByteRangesStruc NewList byteRanges()
    Protected byte1, byte2, previousByte1, isByte2Found, isIdentical
    Protected *currentElement.ByteRangesStruc
    
    previousByte1 = -1
    
    If Not isNegated
      For byte1 = 0 To $FF
        For byte2 = 0 To $FF
          
          If byte1 = 0 And byte2 = 0
            Continue ; Skip null character
          EndIf
          
          If byteSequences(byte1, byte2)
            
            ; Avoid duplicate identical byte ranges
            If previousByte1 <> byte1
              If Not AddElement(byteRanges())
                ProcedureReturn 0
              EndIf
              byteRanges()\byte1Range\min = byte1
              byteRanges()\byte1Range\max = byte1
              previousByte1 = byte1
            EndIf
            
            ; Try to merge byte 2 ranges
            isByte2Found = #False
            ForEach byteRanges()\byte2Ranges()
              If byteRanges()\byte2Ranges()\min =< byte2 And byteRanges()\byte2Ranges()\max => byte2
                isByte2Found = #True
              ElseIf byteRanges()\byte2Ranges()\min - 1 = byte2
                byteRanges()\byte2Ranges()\min - 1
                isByte2Found = #True
              ElseIf byteRanges()\byte2Ranges()\max + 1 = byte2
                byteRanges()\byte2Ranges()\max + 1
                isByte2Found = #True
              EndIf
            Next
            If Not isByte2Found
              If Not AddElement(byteRanges()\byte2Ranges())
                ProcedureReturn 0
              EndIf
              byteRanges()\byte2Ranges()\min = byte2
              byteRanges()\byte2Ranges()\max = byte2
            EndIf
            
          EndIf
        Next
      Next
    Else
      For byte1 = 0 To $FF
        For byte2 = 0 To $FF
          
          ; Skip null character
          If byte1 = 0 And byte2 = 0
            Continue
          EndIf
          
          If Not byteSequences(byte1, byte2)
            
            ; Avoid duplicate identical byte ranges
            If previousByte1 <> byte1
              If Not AddElement(byteRanges())
                ProcedureReturn 0
              EndIf
              byteRanges()\byte1Range\min = byte1
              byteRanges()\byte1Range\max = byte1
              previousByte1 = byte1
            EndIf
            
            ; Try to merge byte 2 ranges
            isByte2Found = #False
            ForEach byteRanges()\byte2Ranges()
              If byteRanges()\byte2Ranges()\min =< byte2 And byteRanges()\byte2Ranges()\max => byte2
                isByte2Found = #True
              ElseIf byteRanges()\byte2Ranges()\min - 1 = byte2
                byteRanges()\byte2Ranges()\min - 1
                isByte2Found = #True
              ElseIf byteRanges()\byte2Ranges()\max + 1 = byte2
                byteRanges()\byte2Ranges()\max + 1
                isByte2Found = #True
              EndIf
            Next
            If Not isByte2Found
              If Not AddElement(byteRanges()\byte2Ranges())
                ProcedureReturn 0
              EndIf
              byteRanges()\byte2Ranges()\min = byte2
              byteRanges()\byte2Ranges()\max = byte2
            EndIf
            
          EndIf
        Next
      Next
    EndIf
    
    ; Try to merge byte 1 ranges
    ; Note: When merging a byte 1 range, the subordinate byte 2 ranges must
    ; also be identical.
    ForEach byteRanges()
      *currentElement.ByteRangesStruc = @byteRanges()
      PushListPosition(byteRanges())
      ForEach byteRanges()
        If @byteRanges() = *currentElement
          Continue
        EndIf
        If ListSize(byteRanges()\byte2Ranges()) = ListSize(*currentElement\byte2Ranges())
          ResetList(byteRanges()\byte2Ranges())
          ResetList(*currentElement\byte2Ranges())
          isIdentical = #True
          While NextElement(byteRanges()\byte2Ranges()) And NextElement(*currentElement\byte2Ranges())
            If byteRanges()\byte2Ranges()\min <> *currentElement\byte2Ranges()\min Or
               byteRanges()\byte2Ranges()\max <> *currentElement\byte2Ranges()\max
              isIdentical = #False
            EndIf
          Wend
        Else
          isIdentical = #False
        EndIf
        If isIdentical
          If *currentElement\byte1Range\min = byteRanges()\byte1Range\min And *currentElement\byte1Range\max = byteRanges()\byte1Range\max
            DeleteElement(byteRanges())
          ElseIf *currentElement\byte1Range\min - 1 = byteRanges()\byte1Range\min
            *currentElement\byte1Range\min - 1
            DeleteElement(byteRanges())
          ElseIf *currentElement\byte1Range\max + 1 = byteRanges()\byte1Range\max
            *currentElement\byte1Range\max + 1
            DeleteElement(byteRanges())
          EndIf
        EndIf
      Next
      PopListPosition(byteRanges())
    Next
    
    ; Iterate the minimized byte ranges and create the corresponding NFA
    ; construction
    ForEach byteRanges()
      *nfa1 = CreateNfaByteRange(nfaPool(), byteRanges()\byte1Range\min, byteRanges()\byte1Range\max, finalStateValue)
      *nfa2 = 0
      ForEach byteRanges()\byte2Ranges()
        If *nfa2
          *nfa3 = CreateNfaByteRange(nfaPool(), byteRanges()\byte2Ranges()\min, byteRanges()\byte2Ranges()\max, finalStateValue)
          *nfa2_new = CreateNfaUnion(nfaPool(), *nfa2, *nfa3, finalStateValue)
          FreeStructure(*nfa2)
          FreeStructure(*nfa3)
          *nfa2 = *nfa2_new
        Else
          *nfa2 = CreateNfaByteRange(nfaPool(), byteRanges()\byte2Ranges()\min, byteRanges()\byte2Ranges()\max, finalStateValue)
        EndIf
      Next
      If *base
        *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
        FreeStructure(*nfa1)
        FreeStructure(*nfa2)
        *nfa2 = *nfa2_new
        *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
        FreeStructure(*base)
        FreeStructure(*nfa2)
        *base = *base_new
      Else
        *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
        FreeStructure(*nfa1)
        FreeStructure(*nfa2)
      EndIf
    Next
    
    ProcedureReturn *base
  EndProcedure
  
  ; Adds the byte sequence to the byte tree
  Procedure AddByteSequence(Array byteSequences.b(2), startValue, endValue, *regExModes.Integer = 0)
    Protected i, ii, count
    Protected.CharacterStruc char
    
    For i = startValue To endValue
      char\u = i
      byteSequences(char\a[0], char\a[1]) = #True
      If *regExModes And *regExModes\i & #RegExMode_NoCase
        If *regExModes\i & #RegExMode_Ascii
          Select char\u
            Case 'A' To 'Z'
              char\u = char\u + 32
              byteSequences(char\a[0], char\a[1]) = #True
            Case 'a' To 'z'
              char\u = char\u - 32
              byteSequences(char\a[0], char\a[1]) = #True
          EndSelect
        Else
          If *caseUnfold(char\u)
            count = *caseUnfold(char\u)\charsCount
            For ii = 0 To count
              char\u = *caseUnfold(char\u)\chars[ii]
              byteSequences(char\a[0], char\a[1]) = #True
            Next
          EndIf
        EndIf
      EndIf
    Next
  EndProcedure
  
  ; Adds the predefined byte sequences to the byte tree
  Procedure AddPredefinedByteSequences(Array byteSequences.b(2), *label)
    Protected offset, startValue, endValue
    
    Repeat
      startValue = PeekU(*label + offset)
      If startValue = 0 ; End of the predefined character class
        Break
      EndIf
      offset + SizeOf(Unicode)
      endValue = PeekU(*label + offset)
      offset + SizeOf(Unicode)
      AddByteSequence(byteSequences(), startValue, endValue)
    ForEver
  EndProcedure
  
  ; Returns the hexadecimal number as an integer. On an error, null is returned.
  Procedure DecodeHexCode(*regExString.RegExStringStruc, requiredLength)
    Protected hexCode$
    
    Select requiredLength
      Case 2
        If *regExString\currentPosition\u <> 0
          hexCode$ = Chr(*regExString\currentPosition\u)
        EndIf
        *regExString\currentPosition + SizeOf(Unicode)
        If *regExString\currentPosition\u <> 0
          hexCode$ + Chr(*regExString\currentPosition\u)
          *regExString\currentPosition + SizeOf(Unicode)
        Else
          hexCode$ = ""
        EndIf
      Case 4
        If *regExString\currentPosition\u <> 0
          hexCode$ = Chr(*regExString\currentPosition\u)
        EndIf
        *regExString\currentPosition + SizeOf(Unicode)
        If *regExString\currentPosition\u <> 0
          hexCode$ + Chr(*regExString\currentPosition\u)
          *regExString\currentPosition + SizeOf(Unicode)
        Else
          hexCode$ = ""
        EndIf
        If *regExString\currentPosition\u <> 0
          hexCode$ + Chr(*regExString\currentPosition\u)
          *regExString\currentPosition + SizeOf(Unicode)
        Else
          hexCode$ = ""
        EndIf
        If *regExString\currentPosition\u <> 0
          hexCode$ + Chr(*regExString\currentPosition\u)
          *regExString\currentPosition + SizeOf(Unicode)
        Else
          hexCode$ = ""
        EndIf
      Default
        hexCode$ = ""
    EndSelect
    
    ProcedureReturn Val("$" + hexCode$)
  EndProcedure
  
  ; Returns the current RegEx character class base symbol as a character.
  ; On an error, a empty string is returned.
  Procedure$ ParseRegExCharacterClassBase(*regExString.RegExStringStruc)
    Protected result$
    
    Select *regExString\currentPosition\u
      Case '\'
        *regExString\currentPosition + SizeOf(Unicode)
        Select *regExString\currentPosition\u
          Case 'r'
            result$ = #CR$
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'n'
            result$ = #LF$
            *regExString\currentPosition + SizeOf(Unicode)
          Case 't'
            result$ = #TAB$
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'f'
            result$ = #FF$
            *regExString\currentPosition + SizeOf(Unicode)
          Case '\', '[', ']', '-'
            result$ = Chr(*regExString\currentPosition\u)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'd', 'D', 's', 'S', 'w', 'W'
            lastErrorMessages$ + "Predefined character classes inside of character classes are not allowed [Pos: " +
                                 Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                 #CRLF$
            result$ = "" 
          Case 'x'
            *regExString\currentPosition + SizeOf(Unicode)
            result$ = Chr(DecodeHexCode(*regExString, 2))
            If result$ = ""
              lastErrorMessages$ + "Escape sequence is invalid [Pos: " +
                                   Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                   #CRLF$
            EndIf
          Case 'u'
            *regExString\currentPosition + SizeOf(Unicode)
            result$ = Chr(DecodeHexCode(*regExString, 4))
            If result$ = ""
              lastErrorMessages$ + "Escape sequence is invalid [Pos: " +
                                   Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                   #CRLF$
            EndIf
          Default
            lastErrorMessages$ + "Symbol to be escaped is invalid: '" +
                                 Chr(*regExString\currentPosition\u) + "' [Pos: " +
                                 Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                 #CRLF$
            result$ = ""
        EndSelect
      Case '['
        lastErrorMessages$ + "Opening square bracket not allowed here [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        result$ = ""
      Case ']'
        lastErrorMessages$ + "Closing square bracket not allowed here [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        result$ = ""
      Case '-'
        lastErrorMessages$ + "Character range is incomplete here [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        result$ = ""
      Default
        result$ = Chr(*regExString\currentPosition\u)
        *regExString\currentPosition + SizeOf(Unicode)
    EndSelect
    
    ProcedureReturn result$
  EndProcedure
  
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure ParseRegExCharacterClass(List nfaPool.NfaStateStruc(), *regExString.RegExStringStruc, finalStateValue, *regExModes.Integer)
    Protected base$, base2$
    Protected base, base2
    Protected Dim byteSequences.b($FF, $FF)
    Protected isNegated
    
    If *regExString\currentPosition\u = '^'
      *regExString\currentPosition + SizeOf(Unicode)
      isNegated = #True
    EndIf
    
    If *regExString\currentPosition\u = ']'
      lastErrorMessages$ + "Empty classes are not allowed [Pos: " +
                           Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                           #CRLF$
      ProcedureReturn 0
    EndIf
    
    While *regExString\currentPosition\u <> 0 And *regExString\currentPosition\u <> ']'
      base$ = ParseRegExCharacterClassBase(*regExString)
      base = Asc(base$)
      If base = 0
        ProcedureReturn 0
      EndIf
      If *regExString\currentPosition\u = '-'
        *regExString\currentPosition + SizeOf(Unicode)
        base2$ = ParseRegExCharacterClassBase(*regExString)
        base2 = Asc(base2$)
        If base2 = 0
          ProcedureReturn 0
        EndIf
        If base > base2
          lastErrorMessages$ + "Range out of order (`[z-a]` must be `[a-z]`, for example) [Pos: " +
                               Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                               #CRLF$
          ProcedureReturn 0
        EndIf
        AddByteSequence(byteSequences(), base, base2, *regExModes)
      Else
        AddByteSequence(byteSequences(), base, base, *regExModes)
      EndIf
    Wend
    
    If *regExString\currentPosition\u <> ']'
      lastErrorMessages$ + "Missing closing square bracket [Pos: " +
                           Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                           #CRLF$
      ProcedureReturn 0
    EndIf
    
    ProcedureReturn CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue, isNegated)
  EndProcedure
  
  ; On success `#True` is returned, otherwise `#False`.
  Procedure ParseRegExModes(*regExString.RegExStringStruc, *regExModes.Integer)
    Protected oldPosition = *regExString\currentPosition
    
    Repeat
      If *regExString\currentPosition\u <> '('
        Break
      EndIf
      *regExString\currentPosition + SizeOf(Unicode)
      If *regExString\currentPosition\u <> '?'
        *regExString\currentPosition = oldPosition
        Break
      EndIf
      *regExString\currentPosition + SizeOf(Unicode)
      If *regExString\currentPosition\u = ')'
        *regExString\currentPosition + SizeOf(Unicode)
        lastErrorMessages$ + "Invalid RegEx mode setting [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        ProcedureReturn #False
      EndIf
      Repeat
        Select *regExString\currentPosition\u
          Case 'i'
            *regExString\currentPosition + SizeOf(Unicode)
            *regExModes\i | #RegExMode_NoCase
          Case 'a'
            *regExString\currentPosition + SizeOf(Unicode)
            *regExModes\i | #RegExMode_Ascii
          Case '-'
            *regExString\currentPosition + SizeOf(Unicode)
            If *regExString\currentPosition\u = ')'
              lastErrorMessages$ + "Invalid RegEx mode setting [Pos: " +
                                   Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                   #CRLF$
              *regExString\currentPosition + SizeOf(Unicode)
              ProcedureReturn #False
            EndIf
            Select *regExString\currentPosition\u
              Case 'i'
                *regExString\currentPosition + SizeOf(Unicode)
                *regExModes\i & ~#RegExMode_NoCase
              Case 'a'
                *regExString\currentPosition + SizeOf(Unicode)
                *regExModes\i & ~#RegExMode_Ascii
              Default
                lastErrorMessages$ + "Invalid RegEx mode setting [Pos: " +
                                     Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                     #CRLF$
                ProcedureReturn #False
            EndSelect
          Case ')'
            *regExString\currentPosition + SizeOf(Unicode)
            oldPosition = *regExString\currentPosition
            Break
          Default
            lastErrorMessages$ + "Invalid RegEx mode setting [Pos: " +
                                 Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                 #CRLF$
            ProcedureReturn #False
        EndSelect
      ForEver
    ForEver
    
    ProcedureReturn #True
  EndProcedure
  
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure ParseRegExBase(List nfaPool.NfaStateStruc(), *regExString.RegExStringStruc, finalStateValue, *regExModes.Integer)
    Protected.NfaStruc *base, *base_new, *nfa1, *nfa2, *nfa2_new
    Protected Dim byteSequences.b($FF, $FF)
    Protected.CharacterStruc char
    Protected regExModes, count, ii
    
    If ParseRegExModes(*regExString, *regExModes) = #False
      ProcedureReturn 0
    EndIf
    
    regExModes = *regExModes\i
    
    Select *regExString\currentPosition\u
      Case '('
        *regExString\currentPosition + SizeOf(Unicode)
        *base = ParseRegEx(nfaPool(), *regExString, finalStateValue, @regExModes)
        If *regExString\currentPosition\u <> ')'
          lastErrorMessages$ + "Missing closing round bracket [Pos: " +
                               Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                               #CRLF$
          ProcedureReturn 0
        EndIf
        *regExString\currentPosition + SizeOf(Unicode)
      Case '['
        *regExString\currentPosition + SizeOf(Unicode)
        *base = ParseRegExCharacterClass(nfaPool(), *regExString, finalStateValue, *regExModes)
        If *base = 0
          ProcedureReturn 0
        EndIf
        *regExString\currentPosition + SizeOf(Unicode)
      Case '\'
        *regExString\currentPosition + SizeOf(Unicode)
        Select *regExString\currentPosition\u
          Case 'r'
            *nfa1 = CreateNfaByteRange(nfaPool(), #CR, #CR, finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), 0, 0, finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'n'
            *nfa1 = CreateNfaByteRange(nfaPool(), #LF, #LF, finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), 0, 0, finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 't'
            *nfa1 = CreateNfaByteRange(nfaPool(), #TAB, #TAB, finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), 0, 0, finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'f'
            *nfa1 = CreateNfaByteRange(nfaPool(), #FF, #FF, finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), 0, 0, finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'd'
            Dim byteSequences.b($FF, $FF)
            If *regExModes\i & #RegExMode_Ascii
              AddPredefinedByteSequences(byteSequences(), ?DigitByteSequences_AsciiMode)
            Else
              AddPredefinedByteSequences(byteSequences(), ?DigitByteSequences)
            EndIf
            *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'D'
            Dim byteSequences.b($FF, $FF)
            If *regExModes\i & #RegExMode_Ascii
              AddPredefinedByteSequences(byteSequences(), ?NoDigitByteSequences_AsciiMode)
            Else
              AddPredefinedByteSequences(byteSequences(), ?NoDigitByteSequences)
            EndIf
            *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 's'
            Dim byteSequences.b($FF, $FF)
            If *regExModes\i & #RegExMode_Ascii
              AddPredefinedByteSequences(byteSequences(), ?WhiteSpaceByteSequences_AsciiMode)
            Else
              AddPredefinedByteSequences(byteSequences(), ?WhiteSpaceByteSequences)
            EndIf
            *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'S'
            Dim byteSequences.b($FF, $FF)
            If *regExModes\i & #RegExMode_Ascii
              AddPredefinedByteSequences(byteSequences(), ?NoWhiteSpaceByteSequences_AsciiMode)
            Else
              AddPredefinedByteSequences(byteSequences(), ?NoWhiteSpaceByteSequences)
            EndIf
            *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'w'
            Dim byteSequences.b($FF, $FF)
            If *regExModes\i & #RegExMode_Ascii
              AddPredefinedByteSequences(byteSequences(), ?WordByteSequences_AsciiMode)
            Else
              AddPredefinedByteSequences(byteSequences(), ?WordByteSequences)
            EndIf
            *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'W'
            Dim byteSequences.b($FF, $FF)
            If *regExModes\i & #RegExMode_Ascii
              AddPredefinedByteSequences(byteSequences(), ?NoWordByteSequences_AsciiMode)
            Else
              AddPredefinedByteSequences(byteSequences(), ?NoWordByteSequences)
            EndIf
            *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
            *regExString\currentPosition + SizeOf(Unicode)
          Case 'x'
            *regExString\currentPosition + SizeOf(Unicode)
            char\u = DecodeHexCode(*regExString, 2)
            If char\u = 0
              lastErrorMessages$ + "Escape sequence is invalid [Pos: " +
                                   Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                   #CRLF$
              ProcedureReturn 0
            EndIf
            *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            If *regExModes\i & #RegExMode_NoCase
              If *regExModes\i & #RegExMode_Ascii
                Select char\u
                  Case 'A' To 'Z'
                    char\u = char\u + 32
                  Case 'a' To 'z'
                    char\u = char\u - 32
                EndSelect
                *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
                *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
                *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
                FreeStructure(*nfa1)
                FreeStructure(*nfa2)
                *nfa2 = *nfa2_new
                *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
                FreeStructure(*base)
                FreeStructure(*nfa2)
                *base = *base_new
              Else
                If *caseUnfold(char\u)
                  count = *caseUnfold(char\u)\charsCount
                  For ii = 0 To count
                    char\u = *caseUnfold(char\u)\chars[ii]
                    *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
                    *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
                    *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
                    FreeStructure(*nfa1)
                    FreeStructure(*nfa2)
                    *nfa2 = *nfa2_new
                    *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
                    FreeStructure(*base)
                    FreeStructure(*nfa2)
                    *base = *base_new
                  Next
                EndIf
              EndIf
            EndIf
          Case 'u'
            *regExString\currentPosition + SizeOf(Unicode)
            char\u = DecodeHexCode(*regExString, 4)
            If char\u = 0
              lastErrorMessages$ + "Escape sequence is invalid [Pos: " +
                                   Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                   #CRLF$
              ProcedureReturn 0
            EndIf
            *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            If *regExModes\i & #RegExMode_NoCase
              If *regExModes\i & #RegExMode_Ascii
                Select char\u
                  Case 'A' To 'Z'
                    char\u = char\u + 32
                  Case 'a' To 'z'
                    char\u = char\u - 32
                EndSelect
                *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
                *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
                *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
                FreeStructure(*nfa1)
                FreeStructure(*nfa2)
                *nfa2 = *nfa2_new
                *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
                FreeStructure(*base)
                FreeStructure(*nfa2)
                *base = *base_new
              Else
                If *caseUnfold(char\u)
                  count = *caseUnfold(char\u)\charsCount
                  For ii = 0 To count
                    char\u = *caseUnfold(char\u)\chars[ii]
                    *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
                    *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
                    *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
                    FreeStructure(*nfa1)
                    FreeStructure(*nfa2)
                    *nfa2 = *nfa2_new
                    *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
                    FreeStructure(*base)
                    FreeStructure(*nfa2)
                    *base = *base_new
                  Next
                EndIf
              EndIf
            EndIf
          Case '*', '+', '?', '|', '(', ')', '\', '.', '[', ']'
            *nfa1 = CreateNfaByteRange(nfaPool(), *regExString\currentPosition\a[0], *regExString\currentPosition\a[0],
                                       finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), *regExString\currentPosition\a[1], *regExString\currentPosition\a[1],
                                       finalStateValue)
            *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            *regExString\currentPosition + SizeOf(Unicode)
          Default
            lastErrorMessages$ + "Symbol to be escaped is invalid: '" +
                                 Chr(*regExString\currentPosition\u) + "' [Pos: " +
                                 Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                                 #CRLF$
            ProcedureReturn 0
        EndSelect
      Case '.'
        Dim byteSequences.b($FF, $FF)
        AddPredefinedByteSequences(byteSequences(), ?DotByteSequences)
        *base = CreateNfaByteRangeSequences(nfaPool(), byteSequences(), finalStateValue)
        *regExString\currentPosition + SizeOf(Unicode)
      Case '*', '+', '?', '|'
        lastErrorMessages$ + "Symbol not allowed here: '" +
                             Chr(*regExString\currentPosition\u) + "' [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        ProcedureReturn 0
      Case 0
        lastErrorMessages$ + "Empty RegEx not allowed [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        ProcedureReturn 0
      Case ')'
        lastErrorMessages$ + "Empty groups are not allowed [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        ProcedureReturn 0
      Case ']'
        lastErrorMessages$ + "Missing opening square bracket [Pos: " +
                             Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                             #CRLF$
        ProcedureReturn 0
      Default
        char\u = *regExString\currentPosition\u
        *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
        *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
        *base = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
        FreeStructure(*nfa1)
        FreeStructure(*nfa2)
        If *regExModes\i & #RegExMode_NoCase
          If *regExModes\i & #RegExMode_Ascii
            Select char\u
              Case 'A' To 'Z'
                char\u = char\u + 32
              Case 'a' To 'z'
                char\u = char\u - 32
            EndSelect
            *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
            *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
            *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
            FreeStructure(*nfa1)
            FreeStructure(*nfa2)
            *nfa2 = *nfa2_new
            *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
            FreeStructure(*base)
            FreeStructure(*nfa2)
            *base = *base_new
          Else
            If *caseUnfold(char\u)
              count = *caseUnfold(char\u)\charsCount
              For ii = 0 To count
                char\u = *caseUnfold(char\u)\chars[ii]
                *nfa1 = CreateNfaByteRange(nfaPool(), char\a[0], char\a[0], finalStateValue)
                *nfa2 = CreateNfaByteRange(nfaPool(), char\a[1], char\a[1], finalStateValue)
                *nfa2_new = CreateNfaConcatenation(nfaPool(), *nfa1, *nfa2)
                FreeStructure(*nfa1)
                FreeStructure(*nfa2)
                *nfa2 = *nfa2_new
                *base_new = CreateNfaUnion(nfaPool(), *base, *nfa2, finalStateValue)
                FreeStructure(*base)
                FreeStructure(*nfa2)
                *base = *base_new
              Next
            EndIf
          EndIf
        EndIf
        *regExString\currentPosition + SizeOf(Unicode)
    EndSelect
    
    If ParseRegExModes(*regExString, *regExModes) = #False
      ProcedureReturn 0
    EndIf
    
    ProcedureReturn *base
  EndProcedure
  
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure ParseRegExFactor(List nfaPool.NfaStateStruc(), *regExString.RegExStringStruc, finalStateValue, *regExModes.Integer)
    Protected.NfaStruc *base = ParseRegExBase(nfaPool(), *regExString, finalStateValue, *regExModes)
    Protected.NfaStruc *factor
    
    If *base = 0
      ProcedureReturn 0
    EndIf
    
    Select *regExString\currentPosition\u
      Case '*'
        *regExString\currentPosition + SizeOf(Unicode)
        *factor = CreateNfaZeroOrMore(nfaPool(), *base, finalStateValue)
        FreeStructure(*base)
      Case '+'
        *regExString\currentPosition + SizeOf(Unicode)
        *factor = CreateNfaOneOrMore(nfaPool(), *base, finalStateValue)
        FreeStructure(*base)
      Case '?'
        *regExString\currentPosition + SizeOf(Unicode)
        *factor = CreateNfaZeroOrOne(nfaPool(), *base, finalStateValue)
        FreeStructure(*base)
      Default
        *factor = *base
    EndSelect
    
    ProcedureReturn *factor
  EndProcedure
  
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure ParseRegExTerm(List nfaPool.NfaStateStruc(), *regExString.RegExStringStruc, finalStateValue, *regExModes.Integer)
    Protected.NfaStruc *factor, *newFactor, *nextFactor
    
    *factor = ParseRegExFactor(nfaPool(), *regExString, finalStateValue, *regExModes)
    
    If *factor = 0
      ProcedureReturn 0
    EndIf
    
    While *regExString\currentPosition\u <> 0 And *regExString\currentPosition\u <> ')' And
          *regExString\currentPosition\u <> '|'
      
      *nextFactor = ParseRegExFactor(nfaPool(), *regExString, finalStateValue, *regExModes)
      
      If *nextFactor = 0
        ProcedureReturn 0
      EndIf
      
      *newFactor = CreateNfaConcatenation(nfaPool(), *factor, *nextFactor)
      FreeStructure(*factor)
      FreeStructure(*nextFactor)
      *factor = *newFactor
    Wend
    
    ProcedureReturn *factor
  EndProcedure
  
  ; Returns a pointer to a `NfaStruc`. On an error, null is returned.
  Procedure ParseRegEx(List nfaPool.NfaStateStruc(), *regExString.RegExStringStruc, finalStateValue, *regExModes.Integer)
    Protected.NfaStruc *term = ParseRegExTerm(nfaPool(), *regExString, finalStateValue, *regExModes)
    Protected.NfaStruc *regEx, *union
    
    If *term And *regExString\currentPosition\u = '|'
      *regExString\currentPosition + SizeOf(Unicode)
      *regEx = ParseRegEx(nfaPool(), *regExString, finalStateValue, *regExModes)
      If *regEx
        *union = CreateNfaUnion(nfaPool(), *term, *regEx, finalStateValue)
      Else
        *union = 0
      EndIf
      FreeStructure(*term)
      FreeStructure(*regEx)
      ProcedureReturn *union
    Else
      ProcedureReturn *term
    EndIf
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure Init()
    Protected.RegExEngineStruc *regExEngine
    
    *regExEngine = AllocateStructure(RegExEngineStruc)
    
    ProcedureReturn *regExEngine
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure AddNfa(*regExEngine.RegExEngineStruc, regExString$, regExId = 0, regExModes = 0)
    Protected.NfaStruc *resultNfa
    Protected.RegExStringStruc *regExString
    
    If *regExEngine = 0
      ProcedureReturn #False
    EndIf
    
    lastErrorMessages$ = ""
    
    If regExString$ = ""
      lastErrorMessages$ + "Empty RegEx not allowed" + #CRLF$
      ProcedureReturn #False
    EndIf
    
    *regExString = AllocateStructure(RegExStringStruc)
    If *regExString
      *regExString\startPosition = @regExString$
      *regExString\currentPosition = @regExString$
    Else
      ProcedureReturn #False
    EndIf
    
    If AddElement(*regExEngine\nfaPools())
      *resultNfa = ParseRegEx(*regExEngine\nfaPools()\nfaStates(), *regExString, #StateType_Final + regExId, @regExModes)
      If *resultNfa
        If *regExString\currentPosition\u <> 0
          ; If the RegEx string could not be parsed completely, there are syntax
          ; errors
          lastErrorMessages$ + "Missing opening round bracket [Pos: " +
                               Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                               #CRLF$
          DeleteElement(*regExEngine\nfaPools())
          FreeStructure(*regExString)
          ProcedureReturn #False
        EndIf
        *regExEngine\nfaPools()\initialNfaState = *resultNfa\startState
        FreeStructure(*resultNfa)
      Else
        If *regExString\currentPosition\u = ')'
          ; If the RegEx string could not be parsed completely, there are syntax
          ; errors
          lastErrorMessages$ + "Missing opening round bracket [Pos: " +
                               Str(GetCurrentCharacterPosition(*regExString)) + "]" +
                               #CRLF$
        EndIf
        DeleteElement(*regExEngine\nfaPools())
        FreeStructure(*regExString)
        ProcedureReturn #False
      EndIf
    EndIf
    
    FreeStructure(*regExString)
    ProcedureReturn #True
  EndProcedure
  
  ; Follows the epsilon-move states and adds the target states to the list.
  ; Used for the subset construction (NFA -> DFA conversion).
  Procedure AddState(*state.NfaStateStruc, List *states.NfaStateStruc())
    If *state\stateType = #StateType_SplitMove
      If Not AddState(*state\nextState1, *states())
        ProcedureReturn #False
      EndIf
      AddState(*state\nextState2, *states())
    ElseIf *state\stateType = #StateType_EpsilonMove
      AddState(*state\nextState1, *states())
    Else
      
      ; Required to prevent an endless loop on the following RegExes:
      ; - `x*x*`
      ; - `x*x+`
      ; - `x+x*`
      ; - `x+x+`
      ; `x` can also be a more complex RegEx.
      ForEach *states()
        If *states() = *state
          ProcedureReturn #False
        EndIf
      Next
      
      AddElement(*states())
      *states() = *state
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  ; Searches the epsilon closures for a set of NFA states and returns the
  ; position of the set. The position number and the DFA state number are
  ; identical.
  ; Used for the subset construction (NFA -> DFA conversion).
  Procedure FindStatesSet(Array eClosures.EClosureStruc(1), List *states.NfaStateStruc())
    Protected sizeOfArray, dfaState, countOfStates, isFound, result
    
    sizeOfArray = ArraySize(eClosures())
    countOfStates = ListSize(*states())
    
    ; dfaState '0' is the dead state, so it will be skipped.
    
    For dfaState = 1 To sizeOfArray
      
      isFound = #True
      
      If ListSize(eClosures(dfaState)\nfaStates()) <> countOfStates
        Continue
      EndIf
      
      ResetList(*states())
      ResetList(eClosures(dfaState)\nfaStates())
      
      While NextElement(*states()) And NextElement(eClosures(dfaState)\nfaStates())
        If eClosures(dfaState)\nfaStates() <> *states()
          isFound = #False
          Break
        EndIf
      Wend
      
      If isFound
        result = dfaState
        Break
      EndIf
    Next
    
    ProcedureReturn result
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure CreateDfa(*regExEngine.RegExEngineStruc, clearNfa = #True)
    Protected.EClosureStruc Dim eClosures(1), NewMap symbols()
    Protected.NfaStateStruc *state
    Protected sizeOfArray, dfaState, result, symbol
    Protected *newMemory
    
    If *regExEngine = 0
      ProcedureReturn #False
    EndIf
    
    If *regExEngine\isUseDfaFromMemory = #False And *regExEngine\dfaStatesPool
      FreeMemory(*regExEngine\dfaStatesPool)
    EndIf
    
    *regExEngine\dfaStatesPool = AllocateMemory(SizeOf(DfaStateStruc) << 1)
    *regExEngine\isUseDfaFromMemory = #False
    If *regExEngine\dfaStatesPool = 0
      ProcedureReturn #False
    EndIf
    
    dfaState = 1
    
    ; dfaState '0' is the dead state, so it will be skipped.
    ; eClosures(0) is then always unused, but it is easier that way.
    
    ForEach *regExEngine\nfaPools()
      AddState(*regExEngine\nfaPools()\initialNfaState, eClosures(dfaState)\nfaStates())
    Next
    
    For dfaState = 1 To ArraySize(eClosures())
      
      ClearMap(symbols())
      
      ForEach eClosures(dfaState)\nfaStates()
        *state = eClosures(dfaState)\nfaStates()
        If *state\stateType => #StateType_Final
          *regExEngine\dfaStatesPool\states[dfaState]\isFinalState = *state\stateType - #StateType_Final + 1
        Else
          For symbol = *state\byteRange\min To *state\byteRange\max
            AddState(*state\nextState1, symbols(Chr(symbol))\nfaStates())
          Next
        EndIf
      Next
      
      ForEach symbols()
        result = FindStatesSet(eClosures(), symbols()\nfaStates())
        If result
          *regExEngine\dfaStatesPool\states[dfaState]\nextState[Asc(MapKey(symbols()))] = result
        Else
          sizeOfArray = ArraySize(eClosures())
          ReDim eClosures(sizeOfArray + 1)
          *newMemory = ReAllocateMemory(*regExEngine\dfaStatesPool,
                                        MemorySize(*regExEngine\dfaStatesPool) +
                                        SizeOf(DfaStateStruc))
          If *newMemory
            *regExEngine\dfaStatesPool = *newMemory
          Else
            FreeMemory(*regExEngine\dfaStatesPool)
            *regExEngine\dfaStatesPool = 0
            ProcedureReturn #False
          EndIf
          If Not CopyList(symbols()\nfaStates(), eClosures(sizeOfArray + 1)\nfaStates())
            ProcedureReturn #False
          EndIf
          *regExEngine\dfaStatesPool\states[dfaState]\nextState[Asc(MapKey(symbols()))] = sizeOfArray + 1
        EndIf
      Next
      
    Next
    
    If clearNfa
      ClearList(*regExEngine\nfaPools())
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure Free(*regExEngine.RegExEngineStruc)
    If *regExEngine\isUseDfaFromMemory = #False And *regExEngine\dfaStatesPool
      FreeMemory(*regExEngine\dfaStatesPool)
    EndIf
    FreeStructure(*regExEngine)
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure UseDfaFromMemory(*dfaMemory)
    Protected.RegExEngineStruc *regExEngine
    
    If *dfaMemory = 0
      ProcedureReturn 0
    EndIf
    
    *regExEngine = AllocateStructure(RegExEngineStruc)
    If *regExEngine
      *regExEngine\dfaStatesPool = *dfaMemory
      *regExEngine\isUseDfaFromMemory = #True
    EndIf
    
    ProcedureReturn *regExEngine
  EndProcedure
  
  ; Returns the longest match as byte length
  Procedure NfaMatch(*regExEngine.RegExEngineStruc, *string.Ascii, *regExId.Integer)
    Protected.NfaStateStruc *state
    Protected.NfaStateStruc NewList *currentStates(), NewList *nextStates()
    Protected *stringStartPos
    Protected lastFinalStateMatchLength
    
    *stringStartPos = *string
    
    ForEach *regExEngine\nfaPools()
      AddState(*regExEngine\nfaPools()\initialNfaState, *currentStates())
    Next
    
    Repeat
      ForEach *currentStates()
        *state = *currentStates()
        If *state\stateType = #StateType_SymbolMove
          If *state\byteRange\min =< *string\a And *state\byteRange\max => *string\a
            AddState(*state\nextState1, *nextStates())
          EndIf
        ElseIf *state\stateType => #StateType_Final
          lastFinalStateMatchLength = *string - *stringStartPos
          If *regExId
            *regExId\i = *state\stateType - #StateType_Final
          EndIf
        EndIf
      Next
      
      If ListSize(*nextStates()) = 0
        Break
      EndIf
      
      ClearList(*currentStates())
      MergeLists(*nextStates(), *currentStates())
      
      *string + SizeOf(Ascii)
    ForEver
    
    ProcedureReturn lastFinalStateMatchLength
  EndProcedure
  
  ; Returns the longest match as byte length
  Procedure DfaMatch(*regExEngine.RegExEngineStruc, *string.Ascii, *regExId.Integer)
    Protected dfaState, lastFinalStateMatchLength
    Protected *stringStartPos
    
    *stringStartPos = *string
    dfaState = 1
    
    ; dfaState '0' is the dead state, so it will be skipped.
    
    Repeat
      dfaState = *regExEngine\dfaStatesPool\states[dfaState]\nextState[*string\a]
      If dfaState = #State_DfaDeadState
        Break
      EndIf
      
      *string + SizeOf(Ascii)
      
      If *regExEngine\dfaStatesPool\states[dfaState]\isFinalState
        lastFinalStateMatchLength = *string - *stringStartPos
        If *regExId
          *regExId\i = *regExEngine\dfaStatesPool\states[dfaState]\isFinalState - 1
        EndIf
      EndIf
    ForEver
    
    ProcedureReturn lastFinalStateMatchLength
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure Match(*regExEngine.RegExEngineStruc, *string.Unicode, *regExId.Integer = 0)
    If *regExEngine\dfaStatesPool <> 0
      ProcedureReturn DfaMatch(*regExEngine, *string, *regExId)
    Else
      ProcedureReturn NfaMatch(*regExEngine, *string, *regExId)
    EndIf
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure$ GetLastErrorMessages()
    ProcedureReturn lastErrorMessages$
  EndProcedure
  
  ; Public Function. Description in the module declaration block.
  Procedure ExportDfa(*regExEngine.RegExEngineStruc, filePath$)
    Protected file
    
    If *regExEngine = 0 Or *regExEngine\dfaStatesPool = 0
      ProcedureReturn #False
    EndIf
    
    file = CreateFile(#PB_Any, filePath$)
    If file = 0
      ProcedureReturn #False
    EndIf
    
    If Not WriteData(file, *regExEngine\dfaStatesPool, MemorySize(*regExEngine\dfaStatesPool))
      CloseFile(file)
      ProcedureReturn #False
    EndIf
    
    CloseFile(file)
    ProcedureReturn #True
  EndProcedure
  
  CompilerIf #PB_Compiler_Debugger
    EnableDebugger
  CompilerEndIf
  
EndModule
