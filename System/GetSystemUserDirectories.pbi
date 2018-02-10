;   Description: Find several system/user default folders
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=64216
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=3&t=29320
; -----------------------------------------------------------------------------

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

DeclareModule Directory
  Global Program.s;Need Admin/Root-Rights for Windows & Linux
  Global Documents.s
  Global Desktop.s
  Global Downloads.s
  Global ProgramData.s
  Global AllUserData.s;On Linux/Mac you must create with root rights a folder here and give access for everybody.
  Global Movies.s
  Global Music.s
  Global Pictures.s
  Global Public.s
  Global Temporary.s
  Global Home.s
EndDeclareModule

Module Directory
  EnableExplicit
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_MacOS;{      
      Procedure.s GetPath(NSSearchPathDirectory,NSDomainMask)        
        Protected ret.s
        Protected x,y,z
        Protected FileManager
        Protected URLArray
        FileManager = CocoaMessage(0, 0, "NSFileManager defaultManager")
        URLArray = CocoaMessage(0, FileManager,
                                "URLsForDirectory:", NSSearchPathDirectory,
                                "inDomains:", NSDomainMask)
        If URLArray          
          If CocoaMessage(0,URLArray,"count")=1
            x=CocoaMessage(0, URLArray, "objectAtIndex:", 0)
            y=CocoaMessage(0, x, "path")
            z=CocoaMessage(0, y,"UTF8String")
            ret= PeekS(z, -1, #PB_UTF8)+"/";PB always has a slash at the end
          EndIf
        EndIf
        ProcedureReturn ret
      EndProcedure
      Macro _Create(xx,cc,dd=#NSUserDomainMask)
        xx=GetPath(cc,dd)
      EndMacro
      _Create(Program,#NSApplicationDirectory)
      _Create(Documents,#NSDocumentDirectory)
      _Create(Desktop,#NSDesktopDirectory)
      _Create(Downloads,#NSDownloadsDirectory)
      _Create(ProgramData,#NSApplicationSupportDirectory)
      _Create(AllUserData,#NSApplicationSupportDirectory,#NSLocalDomainMask)
      _Create(Movies,#NSMoviesDirectory)
      _Create(Music,#NSMusicDirectory)
      _Create(Pictures,#NSPicturesDirectory)
      _Create(Public,#NSSharedPublicDirectory)
      ;}
      
    CompilerCase #PB_OS_Windows;{      
      Prototype Prot_SHGetKnownFolderPath(rfid,dwFlags,hToken,*pppszPath) 
      Define shell32dll=OpenLibrary(#PB_Any, "shell32.dll")
      Global SHGetKnownFolderPath_.Prot_SHGetKnownFolderPath=GetFunction(shell32dll, "SHGetKnownFolderPath")
      
      Procedure.s GetPath(*FOLDERID)
        Protected Path
        Protected ret.s        
        If SHGetKnownFolderPath_(*FOLDERID,0,0,@Path)=#S_OK And Path
          ret=PeekS(Path,-1,#PB_Unicode)+"\"
          CoTaskMemFree_(path)
        EndIf
        ProcedureReturn ret
      EndProcedure

      Macro _Create(xx,cc,d1,d2,d3,d4,d5)
        DataSection
          cc:
          Data.l $d1
          Data.w $d2,$d3
          Data.b ($d4>>8)&$ff,($d4)&$ff
          Data.b ($d5>>(5*8))&$FF,($d5>>(4*8))&$FF,($d5>>(3*8))&$FF,($d5>>(2*8))&$FF,($d5>>(1*8))&$FF,$d5&$FF
        EndDataSection
        xx=GetPath(?cc)
      EndMacro
      _Create(Program,FOLDERID_ProgramFiles,905e63b6,c1bf,494e,b29c,65b732d3d21a)
      _Create(Documents,FOLDERID_Documents,FDD39AD0,238F,46AF,ADB4,6C85480369C7)
      _Create(Desktop,FOLDERID_Desktop,B4BFCC3A,DB2C,424C,B029,7FE99A87C641)
      _Create(Downloads,FOLDERID_Downloads,374DE290,123F,4565,9164,39C4925E467B)
      _Create(ProgramData,FOLDERID_RoamingAppData,3EB685DB,65F9,4CF6,A03A,E3EF65729F3D)
      _Create(AllUserData,FOLDERID_ProgramData,62AB5D82,FDC1,4DC3,A9DD,070D1D495D97)
      _Create(Movies,FOLDERID_Videos,18989B1D,99B5,455B,841C,AB7C74E4DDFC)
      _Create(Music,FOLDERID_Music,4BD8D571,6D19,48D3,BE97,422220080E43)
      _Create(Pictures,FOLDERID_Pictures,33E28130,4E1E,4676,835A,98395C3BC3BB)
      _Create(Public,FOLDERID_PublicDocuments,ED4824AF,DCE4,45A8,81E2,FC7965083634)
      CloseLibrary(shell32dll)

      ;}
      
    CompilerCase #PB_OS_Linux
      Define ff
      Define key.s,line.s,path.s
      Define pos_equal,pos_quote1,pos_quote2
      FF  = ReadFile(#PB_Any, GetHomeDirectory() + ".config/user-dirs.dirs")
      ;ff=ReadFile(#PB_Any,"E:\purebasic\Temp\user-dirs.dirs")
      If FF
        While Not Eof(FF)
          line = ReadString(FF, #PB_UTF8)
          If Left(line,1)<>"#"
            
            pos_equal=FindString(line,"=")
            pos_quote1=FindString(line,~"\"",pos_equal+1)
            pos_quote2=FindString(line,~"\"",pos_quote1+1)
            If pos_equal And pos_quote1 And pos_quote1<pos_quote2
              key.s=UCase(Trim(Left(line,pos_equal-1)))
              path.s=Mid(line,pos_quote1+1,pos_quote2-pos_quote1-1)+"/"        
              path=ReplaceString(path,"$HOME/",GetHomeDirectory())
              Select key
                Case "XDG_DOCUMENTS_DIR":Documents=path
                Case "XDG_DESKTOP_DIR":Desktop=path
                Case "XDG_DOWNLOAD_DIR":Downloads=path
                Case "XDG_VIDEOS_DIR":Movies=path
                Case "XDG_MUSIC_DIR":Music=path
                Case "XDG_PICTURES_DIR":Pictures=path
                Case "XDG_PUBLICSHARE_DIR":Public=path
              EndSelect
              
            EndIf
          EndIf
          
        Wend
        CloseFile(FF)
      EndIf
      ProgramData=GetHomeDirectory()+"."
      Program="/usr/local/bin/";https://wiki.ubuntuusers.de/Verzeichnisstruktur
      AllUserData="/var/local/";http://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/var.html
      
  CompilerEndSelect
  Temporary= GetTemporaryDirectory()
  Home= GetHomeDirectory()
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Debug Directory::Program
  Debug Directory::Documents
  Debug Directory::Desktop
  Debug Directory::Downloads
  Debug Directory::ProgramData
  Debug Directory::AllUserData
  Debug Directory::Movies
  Debug Directory::Music
  Debug Directory::Pictures
  Debug Directory::Public
  Debug Directory::Temporary
  Debug Directory::Home
  
  Debug "----"
  Debug "Pictures-Directory:"
  path.s=Directory::Pictures
  dir=ExamineDirectory(#PB_Any,path,"*.*")
  If dir
    While NextDirectoryEntry(dir)
      Debug "  "+DirectoryEntryName(dir)+" "+DirectoryEntryType(dir)
    Wend
    FinishDirectory(dir)
  EndIf
    
CompilerEndIf
