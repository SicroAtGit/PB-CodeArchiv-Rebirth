;   Description: Creates a text file that contains all licenses of the third-party libraries used by the code
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2018 Sicro
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

; Tool Settings:
; - Arguments: "%TEMPFILE"
; - Event:     Menu Or Shortcut

EnableExplicit

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  IncludeFile "..\..\FileSystem\IsAbsolutePath.pbi"
  IncludeFile "..\..\FileSystem\EnsureTrailingSlashExists.pbi"
CompilerElse
  IncludeFile "../../FileSystem/IsAbsolutePath.pbi"
  IncludeFile "../../FileSystem/EnsureTrailingSlashExists.pbi"
CompilerEndIf

Structure FunctionStruc
  FunctionName$
  List DependsOnLibrary$()
EndStructure

; Only the map keys are used. The smallest data type has been selected for the
; map values To avoid unnecessary memory wastage.
NewMap NeededThirdPartyLibrary.b()

Procedure$ RemoveLeadingTabsAndWhiteSpacesFromString(String$)
  
  Repeat
    
    Select Left(String$, 1)
      Case " "   : String$ = LTrim(String$)
      Case #TAB$ : String$ = LTrim(String$, #TAB$)
      Default    : Break
    EndSelect
    
  ForEver
  
  ProcedureReturn String$
  
EndProcedure

Procedure CheckForAnyFunctionOfAnyLibraryInUse(CodeLine$, List Function.FunctionStruc(), Map NeededThirdPartyLibrary.b())
  
  ForEach Function()
    
    If FindString(CodeLine$, Function()\FunctionName$ + "(")
      
      ForEach Function()\DependsOnLibrary$()
        AddMapElement(NeededThirdPartyLibrary(), Function()\DependsOnLibrary$())
      Next
      
    EndIf
    
  Next
  
EndProcedure

Procedure$ ExtractStringBetweenFirstQuotesPair(String$)
  
  Protected StartPos, EndPos, Length
  
  StartPos = FindString(String$, #DQUOTE$)
  StartPos + 1 ; Jump to the first character after the quote
  
  EndPos = FindString(String$, #DQUOTE$, StartPos)
  
  Length = EndPos - StartPos
  
  ProcedureReturn Mid(String$, StartPos, Length)
  
EndProcedure

Procedure ScanPBCodeFileRecursivly(FilePath$, List Function.FunctionStruc(), Map NeededThirdPartyLibrary.b())
  
  Protected File, BOM
  Protected CodeLine$, CurrentDirectoryOfIncludes$, PathOfIncludeFile$
  
  File = ReadFile(#PB_Any, FilePath$, #PB_File_SharedRead)
  If File = 0 : ProcedureReturn : EndIf
  
  BOM = ReadStringFormat(File)
  
  While Not Eof(File)
    
    CodeLine$ = ReadString(File, BOM)
    
    ; Skip IDE settings at the end of the code
    If Left(CodeLine$, 25) = "; IDE Options = PureBasic"
      Break
    EndIf
    
    CodeLine$ = RemoveLeadingTabsAndWhiteSpacesFromString(CodeLine$)
    
    CheckForAnyFunctionOfAnyLibraryInUse(CodeLine$, Function(), NeededThirdPartyLibrary())
    
    ; IncludePath support
    If Left(LCase(CodeLine$), 11) = "includepath"
      CurrentDirectoryOfIncludes$ = ExtractStringBetweenFirstQuotesPair(CodeLine$)
      If Not IsAbsolutePath(CurrentDirectoryOfIncludes$)
        ; Create absolute path
        CurrentDirectoryOfIncludes$ = GetPathPart(FilePath$) + CurrentDirectoryOfIncludes$
      EndIf
      CurrentDirectoryOfIncludes$ = EnsureTrailingSlashExists(CurrentDirectoryOfIncludes$)
      Continue
    EndIf
    
    ; IncludeFile/XIncludeFile support
    CodeLine$ = ReplaceString(CodeLine$, "XIncludeFile", "IncludeFile")
    If Left(LCase(CodeLine$), 11) = "includefile"
      PathOfIncludeFile$ = ExtractStringBetweenFirstQuotesPair(CodeLine$)
      If Not IsAbsolutePath(PathOfIncludeFile$)
        ; Create absolute path
        PathOfIncludeFile$ = CurrentDirectoryOfIncludes$ + PathOfIncludeFile$
      EndIf
      ScanPBCodeFileRecursivly(PathOfIncludeFile$, Function(), NeededThirdPartyLibrary())
    EndIf
    
  Wend
  
  CloseFile(File)
  
EndProcedure

Procedure$ GetLicenseText(LibraryName$)
  
  Protected FilePath$, FileContent$
  Protected File
  
  FilePath$ = GetPathPart(ProgramFilename()) + "Licenses"
  FilePath$ = EnsureTrailingSlashExists(FilePath$)
  
  File = ReadFile(#PB_Any, FilePath$ + LibraryName$)
  If File = 0
    ProcedureReturn "Error: License file not found"
  EndIf
  
  FileContent$ = ReadString(File, #PB_File_IgnoreEOL)
  
  CloseFile(File)
  
  ProcedureReturn FileContent$
  
EndProcedure

NewList Function.FunctionStruc()

Define File
Define PBFunctionName$, Default_ThirdParty_Library$, ThirdParty_Library$, Result$, LicenseTextFilePath$
Define i

#PROGRAM_NAME = "CreateLicenseFileForPBThirdPartyLibs"
SetCurrentDirectory(GetPathPart(ProgramFilename()))

If Not OpenPreferences("PBLibrariesInfo.pref")
  MessageRequester(#PROGRAM_NAME, "Error: OpenPreferences()", #PB_MessageRequester_Error)
  End
EndIf

If Not ExaminePreferenceGroups()
  ClosePreferences()
  MessageRequester(#PROGRAM_NAME, "Error: ExaminePreferenceGroups()", #PB_MessageRequester_Error)
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
    
    If AddElement(Function())
      Function()\FunctionName$ = PBFunctionName$
      For i = CountString(ThirdParty_Library$, ",") + 1 To 1 Step -1
        If AddElement(Function()\DependsOnLibrary$())
          Function()\DependsOnLibrary$() = StringField(ThirdParty_Library$, i, ",")
        EndIf
      Next
    EndIf
    
  Wend
  
Wend

ClosePreferences()

ScanPBCodeFileRecursivly(ProgramParameter(0), Function(), NeededThirdPartyLibrary())

ForEach NeededThirdPartyLibrary()
  
  Result$ + "--------------------------" + #CRLF$ +
            MapKey(NeededThirdPartyLibrary()) + #CRLF$ +
            "--------------------------" + #CRLF$ + #CRLF$ +
            GetLicenseText(MapKey(NeededThirdPartyLibrary())) + #CRLF$ + #CRLF$
  
Next

If Result$ = ""
  MessageRequester(#PROGRAM_NAME, "The code doesn't use functions which depends on third-party libraries.", #PB_MessageRequester_Info)
  End
EndIf

LicenseTextFilePath$ = SaveFileRequester(#PROGRAM_NAME, "ThirdPartyLibs_Licenses.txt", "", 0)
If LicenseTextFilePath$ = ""
  MessageRequester(#PROGRAM_NAME, "The file save request was canceled.", #PB_MessageRequester_Error)
  End
EndIf

File = CreateFile(#PB_Any, LicenseTextFilePath$)
If File = 0
  MessageRequester(#PROGRAM_NAME, "The license file could not be created.", #PB_MessageRequester_Error)
  End
EndIf

WriteString(File, "Third-party libraries in use:" + #CRLF$ + #CRLF$)
WriteString(File, Result$)
CloseFile(File)
MessageRequester(#PROGRAM_NAME, "The license file was successfully created.", #PB_MessageRequester_Info)
