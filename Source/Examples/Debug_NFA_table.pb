
EnableExplicit

IncludePath ".."
IncludeFile "RegExEngine.pbi"

Procedure$ GetSymbolAsString(*state.RegEx::NfaStateStruc)
  If *state\stateType => RegEx::#StateType_Final
    ProcedureReturn "Final:" + Str(*state\stateType - RegEx::#StateType_Final)
  ElseIf *state\stateType = RegEx::#StateType_EpsilonMove
    ProcedureReturn "Move"
  ElseIf *state\stateType = RegEx::#StateType_SplitMove
    ProcedureReturn "Split"
  Else
    ProcedureReturn RSet(Hex(*state\byteRange\min), 2, "0") + "-" + RSet(Hex(*state\byteRange\max), 2, "0")
  EndIf
EndProcedure

Define.RegEx::RegExEngineStruc *regEx
Define nfaPoolNumber

*regEx = RegEx::Init()
If *regEx = 0
  Debug "Error"
  End
EndIf

If RegEx::AddNfa(*regEx, "a*") = #False
  Debug RegEx::GetLastErrorMessages()
  RegEx::Free(*regEx)
  End
EndIf

ForEach *regEx\nfaPools()
  nfaPoolNumber + 1
  Debug ">>>> NFA-Pool-Number: " + nfaPoolNumber
  Debug ""
  
  Debug Space(5) + "Initial state: " + *regEx\nfaPools()\initialNfaState
  Debug ""
  Debug Space(5) + "| State               | Symbol range | Next state 1        | Next state 2        |"
  Debug Space(5) + "| =================== | ============ | =================== | =================== |"
  ForEach *regEx\nfaPools()\nfaStates()
    Debug Space(5) + "| " + LSet(Str(@*regEx\nfaPools()\nfaStates()), 19) +
          " | " + LSet(GetSymbolAsString(*regEx\nfaPools()\nfaStates()), 12) +
          " | " + LSet(Str(*regEx\nfaPools()\nfaStates()\nextState1), 19) +
          " | " + LSet(Str(*regEx\nfaPools()\nfaStates()\nextState2), 19) + " |"
    Debug Space(5) + "| ------------------- | ------------ | ------------------- | ------------------- |"
  Next
  
  Debug ""
Next

RegEx::Free(*regEx)
