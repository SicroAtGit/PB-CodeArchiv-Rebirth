;   Description: Resource generator for manifests (DPI-Aware etc.)
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=30440
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017-2018 Sicro
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

; ## Start of settings #############################################################
#Enable_Modern_Theme_Support = #True
#Enable_DPI_Aware            = #True

#Request_Execution_Level = "asInvoker"             ; Request user mode (no virtualization)
;#Request_Execution_Level = "requireAdministrator" ; Request administrator mode

CompilerSelect #PB_Compiler_Processor
  CompilerCase #PB_Processor_x86: #Bit_System = "X86"
  CompilerCase #PB_Processor_x64: #Bit_System = "amd64"
CompilerEndSelect
; ## End of settings ###############################################################

CompilerIf Not #PB_Compiler_Debugger
  CompilerError "Activate the debugger and run the code only inside the PB-IDE"
CompilerEndIf

Define CurrentDirectory$ = PathRequester("Save resource", GetUserDirectory(#PB_Directory_Desktop))
If CurrentDirectory$ = ""
  Debug "Error: PathRequester"
  End
EndIf

SetCurrentDirectory(CurrentDirectory$)

; Create RC file
If Not CreateFile(0, "Resource.rc", #PB_Ascii)
  Debug "Error: CreateFile(0, 'Resource.rc')"
  End
EndIf
WriteString(0, ~"1 24 \"" + GetCurrentDirectory() + ~"Data_1.bin\"" + #CRLF$ + #CRLF$)
CloseFile(0)

; Create BIN file
If Not CreateFile(0, "Data_1.bin", #PB_Ascii)
  Debug "Error: CreateFile(0, 'Data_1.bin')"
  End
EndIf
If #Enable_Modern_Theme_Support
  WriteString(0, ~"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" + #LF$)
  WriteString(0, ~"<assembly xmlns=\"urn:schemas-microsoft-com:asm.v1\" manifestVersion=\"1.0\">" + #LF$)
  WriteString(0, ~"  <assemblyIdentity" + #LF$)
  WriteString(0, ~"    version=\"1.0.0.0\"" + #LF$)
  WriteString(0, ~"    processorArchitecture=\"" + #Bit_System + ~"\"" + #LF$)
  WriteString(0, ~"    name=\"CompanyName.ProductName.YourApp\"" + #LF$)
  WriteString(0, ~"    type=\"win32\" />" + #LF$)
  WriteString(0, ~"  <description></description>" + #LF$)
  WriteString(0, ~"  <dependency>" + #LF$)
  WriteString(0, ~"    <dependentAssembly>" + #LF$)
  WriteString(0, ~"      <assemblyIdentity" + #LF$)
  WriteString(0, ~"        type=\"win32\"" + #LF$)
  WriteString(0, ~"        name=\"Microsoft.Windows.Common-Controls\"" + #LF$)
  WriteString(0, ~"        version=\"6.0.0.0\"" + #LF$)
  WriteString(0, ~"        processorArchitecture=\"" + #Bit_System + ~"\"" + #LF$)
  WriteString(0, ~"        publicKeyToken=\"6595b64144ccf1df\"" + #LF$)
  WriteString(0, ~"        language=\"*\" />" + #LF$)
  WriteString(0, ~"    </dependentAssembly>" + #LF$)
  WriteString(0, ~"  </dependency>" + #LF$)
EndIf
If #Enable_DPI_Aware
  WriteString(0, ~"  <asmv3:application xmlns:asmv3=\"urn:schemas-microsoft-com:asm.v3\">" + #LF$)
  WriteString(0, ~"    <asmv3:windowsSettings xmlns=\"http://schemas.microsoft.com/SMI/2005/WindowsSettings\">" + #LF$)
  WriteString(0, ~"      <dpiAware>true</dpiAware>" + #LF$)
  WriteString(0, ~"    </asmv3:windowsSettings>" + #LF$)
  WriteString(0, ~"  </asmv3:application>" + #LF$)
EndIf
CompilerIf Defined(Request_Exection_Level, #PB_Constant)
  WriteString(0, ~"    <trustInfo xmlns=\"urn:schemas-microsoft-com:asm.v2\">" + #LF$)
  WriteString(0, ~"    <security>" + #LF$)
  WriteString(0, ~"      <requestedPrivileges>" + #LF$)
  WriteString(0, ~"        <requestedExecutionLevel" + #LF$)
  WriteString(0, ~"          level=\"" + #Request_Execution_Level + ~"\"" + #LF$)
  WriteString(0, ~"          uiAccess=\"false\"/>" + #LF$)
  WriteString(0, ~"      </requestedPrivileges>" + #LF$)
  WriteString(0, ~"    </security>" + #LF$)
  WriteString(0, ~"  </trustInfo>" + #LF$)
CompilerEndIf
WriteString(0, ~"" + #LF$)
WriteString(0, ~"</assembly>")
CloseFile(0) 
