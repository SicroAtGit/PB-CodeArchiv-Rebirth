; Tool Settings:
; - Arguments: "%TEMPFILE"
; - Event:     Menu Or Shortcut
; For MacOS, the field "Commandline" must contain the full path to the executable
; file, e.g.: .../Program.app/Contents/MacOS/Program

; =============================================================================
;- Compiler Settings
; =============================================================================

EnableExplicit

; =============================================================================
;- Include Files
; =============================================================================

XIncludeFile "../../Lexer/PBLexer.pbi"
XIncludeFile "../../FileSystem/EnsureTrailingSlashExists.pbi"
XIncludeFile "../../Preprocessor/PBPreprocessor.pbi"

; =============================================================================
;- Define Structures
; =============================================================================

Structure FunctionsMapStruc
  List DependsOnLibrary$()
EndStructure

; =============================================================================
;- Declare Procedures
; =============================================================================

Declare$ GetLicenseText(LibraryName$)
Declare  ScanPBCodeFile(CodeFilePath$, CompilerFilePath$,
                        Map Functions.FunctionsMapStruc(),
                        Map NeededThirdPartyLibrary.b())

; =============================================================================
;- Define Maps
; =============================================================================

; Only the map keys are used. The smallest data type has been selected for the
; map values To avoid unnecessary memory wastage.
NewMap NeededThirdPartyLibrary.b()

NewMap Functions.FunctionsMapStruc()

; =============================================================================
;- Define Constants
; =============================================================================

#Program_Name = "CreatePBLicenseFile"

; =============================================================================
;- Define Variables
; =============================================================================

Define File, i
Define PBFunctionName$, Default_ThirdParty_Library$, ThirdParty_Library$
Define Result$, LicenseTextFilePath$, CodeFilePath$, CompilerFilePath$

; =============================================================================
;- Set Variables
; =============================================================================

CodeFilePath$     = ProgramParameter(0)
CompilerFilePath$ = GetEnvironmentVariable("PB_TOOL_Compiler")

; =============================================================================
;- Main Code
; =============================================================================

SetCurrentDirectory(GetPathPart(ProgramFilename()))

If Not OpenPreferences("PBLibrariesInfo.pref")
  MessageRequester(#Program_Name, "Error: OpenPreferences()",
                   #PB_MessageRequester_Error)
  End
EndIf

If Not ExaminePreferenceGroups()
  ClosePreferences()
  MessageRequester(#Program_Name, "Error: ExaminePreferenceGroups()",
                   #PB_MessageRequester_Error)
  End
EndIf

While NextPreferenceGroup()
  
  If Not ExaminePreferenceKeys() : Continue : EndIf
  
  While NextPreferenceKey()
    
    PBFunctionName$     = PreferenceKeyName()
    ThirdParty_Library$ = Trim(PreferenceKeyValue(), #DQUOTE$)
    
    If PBFunctionName$ = "Default"
      Default_ThirdParty_Library$ = ThirdParty_Library$
      Continue
    EndIf
    
    If ThirdParty_Library$ = ""
      If Default_ThirdParty_Library$ <> ""
        ThirdParty_Library$ = Default_ThirdParty_Library$
      Else
        Continue
      EndIf
    EndIf
    
    If AddMapElement(Functions(), PBFunctionName$)
      For i = CountString(ThirdParty_Library$, ",") + 1 To 1 Step -1
        If AddElement(Functions()\DependsOnLibrary$())
          Functions()\DependsOnLibrary$() = StringField(ThirdParty_Library$, i,
                                                        ",")
        EndIf
      Next
    EndIf
    
  Wend
  
Wend

ClosePreferences()

ScanPBCodeFile(CodeFilePath$, CompilerFilePath$, Functions(),
               NeededThirdPartyLibrary())

ForEach NeededThirdPartyLibrary()
  
  Result$ + "--------------------------" + #CRLF$ +
            MapKey(NeededThirdPartyLibrary()) + #CRLF$ +
            "--------------------------" + #CRLF$ + #CRLF$ +
            GetLicenseText(MapKey(NeededThirdPartyLibrary())) + #CRLF$ + #CRLF$
  
Next

If Result$ = ""
  MessageRequester(#Program_Name,
                   "The code doesn't use functions which depends on third-party libraries.",
                   #PB_MessageRequester_Info)
  End
EndIf

LicenseTextFilePath$ = SaveFileRequester(#Program_Name,
                                         "ThirdPartyLibs_Licenses.txt", "", 0)
If LicenseTextFilePath$ = ""
  MessageRequester(#Program_Name, "The file save request was canceled.",
                   #PB_MessageRequester_Error)
  End
EndIf

File = CreateFile(#PB_Any, LicenseTextFilePath$)
If File = 0
  MessageRequester(#Program_Name, "The license file could not be created.",
                   #PB_MessageRequester_Error)
  End
EndIf

WriteString(File, "Third-party libraries in use:" + #CRLF$ + #CRLF$)
WriteString(File, Result$)
CloseFile(File)
MessageRequester(#Program_Name, "The license file was successfully created.",
                 #PB_MessageRequester_Info)

; =============================================================================
;- Define Procedures
; =============================================================================

Procedure$ GetLicenseText(LibraryName$)
  
  Protected FilePath$, FileContent$
  Protected File, StringFormat
  
  FilePath$ = GetPathPart(ProgramFilename()) + "Licenses"
  FilePath$ = EnsureTrailingSlashExists(FilePath$)
  
  File = ReadFile(#PB_Any, FilePath$ + LibraryName$)
  If File = 0
    ProcedureReturn "Error: License file not found"
  EndIf
  
  StringFormat = ReadStringFormat(File)
  Select StringFormat
    Case #PB_Ascii, #PB_UTF8, #PB_Unicode
    Default
      ; ReadString() supports fewer string formats than ReadStringFormat(), so
      ; in case of an unsupported format it is necessary to fall back to a
      ; supported format
      StringFormat = #PB_UTF8
  EndSelect
  
  FileContent$ = ReadString(File, StringFormat | #PB_File_IgnoreEOL)
  
  CloseFile(File)
  
  ProcedureReturn FileContent$
  
EndProcedure

Procedure ScanPBCodeFile(CodeFilePath$, CompilerFilePath$,
                         Map Functions.FunctionsMapStruc(),
                         Map NeededThirdPartyLibrary.b())
  
  Protected CodeFileContent$, IdentifierName$
  Protected *Lexer
  
  CodeFileContent$ = GetContentOfPreProcessedFile(CodeFilePath$,
                                                  CompilerFilePath$)
  If CodeFileContent$ = ""
    ProcedureReturn #False
  EndIf
  
  *Lexer = PBLexer::Create(@CodeFileContent$, 250, #False, #False)
  If Not *Lexer
    ProcedureReturn #False
  EndIf
  
  While PBLexer::NextToken(*Lexer)
    If PBLexer::TokenType(*Lexer) = PBLexer::#TokenType_Identifier
      IdentifierName$ = PBLexer::TokenValue(*Lexer)
      If PBLexer::NextToken(*Lexer) And PBLexer::TokenValue(*Lexer) = "("
        If FindMapElement(Functions(), IdentifierName$)
          ForEach Functions()\DependsOnLibrary$()
            AddMapElement(NeededThirdPartyLibrary(),
                          Functions()\DependsOnLibrary$())
          Next
        EndIf
      EndIf
    EndIf
  Wend
  
  PBLexer::Free(*Lexer)
  
EndProcedure
