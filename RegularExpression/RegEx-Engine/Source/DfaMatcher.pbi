
DeclareModule DfaMatcher
  
  EnableExplicit
  
  #State_DfaDeadState = 0 ; Index number of the DFA dead state
  
  Structure DfaStateStruc
    nextState.u[256] ; Index is the symbol (0-255) and the value is the next DFA state
    isFinalState.u   ; Positive number if the DFA state is a final state, otherwise null
  EndStructure
  
  Structure DfaStatesArrayStruc
    states.DfaStateStruc[0] ; Array pointer to the DFA states
  EndStructure
  
  ; Simplifies extracting the matched string via its memory address and length
  ; info obtained from a `Match()` call.
  Macro GetString(_memoryAddress_, _lengthInBytes_)
    PeekS(_memoryAddress_, (_lengthInBytes_) >> 1)
  EndMacro
  
  ; Runs the DFA against the target string, passed via a pointer.
  ; The match search will start from the beginning of the string. If a match is
  ; found, the byte length of the match is returned, otherwise null.
  ; If the address of an integer variable was passed as the optional `*regExId`
  ; parameter, the RegEx ID number of the matching RegEx is written into it.
  ; If multiple RegExes match the same string, each having been assigned a
  ; different RegEx ID number, the RegEx ID number of the last matching RegEx
  ; will be picked, i.e. the matching RegEx that was last added with the
  ; `AddNfa()` function.
  Declare Match(*dfaMemory, *string.Unicode, *regExId.Integer = 0)
  
EndDeclareModule

Module DfaMatcher
  
  Procedure Match(*dfaMemory.DfaStatesArrayStruc, *string.Unicode, *regExId.Integer = 0)
    Protected.Ascii *stringPointer
    Protected *stringStartPos
    Protected dfaState, lastFinalStateMatchLength
    
    *stringPointer = *string
    *stringStartPos = *string
    dfaState = 1 ; dfaState '0' is the dead state, so it will be skipped
    
    Repeat
      dfaState = *dfaMemory\states[dfaState]\nextState[*stringPointer\a]
      If dfaState = #State_DfaDeadState
        Break
      EndIf
      
      *stringPointer + SizeOf(Ascii)
      
      If *dfaMemory\states[dfaState]\isFinalState
        lastFinalStateMatchLength = *stringPointer - *stringStartPos
        If *regExId
          *regExId\i = *dfaMemory\states[dfaState]\isFinalState - 1
        EndIf
      EndIf
    ForEver
    
    ProcedureReturn lastFinalStateMatchLength
  EndProcedure
  
EndModule
