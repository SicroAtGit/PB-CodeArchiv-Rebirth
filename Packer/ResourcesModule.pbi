;   Description: Packed resources for programs
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72721
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=30481
; -----------------------------------------------------------------------------

;/ =============================
;/ =    ResourcesModule.pbi    =
;/ =============================
;/
;/ [ PB V5.7x / 64Bit / all OS / DPI ]
;/
;/ © 2019 Thorsten1867 (03/2019)
;/


; Last Update: 29.4.2019
  
#PackResource = #False


;{ ----- PackResource - Commands -----

  ; PackResource::Open()   - Open and define resource file and resource name
  ; PackResource::Close()  - Close resource creation
  ; PackResource::Add()    - Add resource (Image/XML/JSON/Sound)
  ; PackResource::Create() - Create resource file

;} --------------------------------

;{ ----- Resources - Commands -----

  ; Resource::Open()          - Open resource file
  ; Resource::GetImage()      - Load image from resource file
  ; Resource::GetXML()        - Load XML from resource file
  ; Resource::GetJSON()       - Load JSON from resource file
  ; Resource::GetSound()      - Load Sound from resource file
  ; Resource::GetFileSize()   - Get size of resource    (Image/XML/JSON/Sound)
  ; Resource::GetFileMemory() - Copy resource to memory (Image/XML/JSON/Sound)
  ; Resource::Close()         - Close resource file
  
;} -------------------------------


CompilerIf #PackResource
  
  DeclareModule PackResource
    
    Declare Open(File$, Name$)
    Declare Close(Name$)
    Declare Add(Name$, File$)
    Declare Create(Name$)
    
  EndDeclareModule

  Module PackResource
    
    EnableExplicit
    
    UseLZMAPacker()

    #Pack = 1
    #Json = 1
    
    Structure File_Structure
      File.s
      Size.i
    EndStructure
    
    Structure ResPack_Structure
      Open.i
      File.s
      Map Files.File_Structure()
    EndStructure
    
    Global NewMap ResPack.ResPack_Structure()
    
    Procedure Open(File$, Name$)
      
      If AddMapElement(ResPack(), Name$)
        ResPack()\Open = #True
        ResPack()\File = File$
        ProcedureReturn #True
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure Create(Name$)
      Define Size.i, *Buffer
      Define File$, PackFile$
      
      If FindMapElement(ResPack(), Name$)
        
        PackFile$ = ResPack()\File
        
        If CreatePack(#Pack, PackFile$, #PB_PackerPlugin_Lzma)
          
          ForEach ResPack()\Files()
            File$ = ResPack()\Files()\File
            AddPackFile(#Pack, File$, GetFilePart(File$))
          Next
  
          ClosePack(#Pack)
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure Add(Name$, File$)
      Define FileName$, Size.i
      
      If FindMapElement(ResPack(), Name$)
        
        Size = FileSize(File$)
        If Size > 0
          
          FileName$ = GetFilePart(File$)
          ResPack()\Files(FileName$)\File = File$
          ResPack()\Files(FileName$)\Size = Size
          
          ProcedureReturn #True
        EndIf
        
      EndIf
      
      ProcedureReturn #False
    EndProcedure
    
    Procedure Close(Name$)
      If FindMapElement(ResPack(), Name$)
        DeleteMapElement(ResPack())
      EndIf
    EndProcedure
    
  EndModule

CompilerEndIf


DeclareModule Resource
  
  Declare.i Open(Pack.i, File$)
  Declare.i GetImage(Pack.i, Image.i, FileName$)
  Declare.i GetXML(Pack.i, XML.i, FileName$, Flags.i=#False, Encoding.i=#PB_UTF8)
  Declare.i GetJSON(Pack.i, JSON.i, FileName$, Flags.i=#False)
  Declare.i GetSound(Pack.i, Sound.i, FileName$, Flags.i=#False)
  Declare.i GetFileSize(Pack.i, FileName$)
  Declare.i GetFileMemory(Pack.i, *Buffer, FileName$)
  Declare Close(Pack.i)
  
EndDeclareModule

Module Resource
  
  EnableExplicit

  UseLZMAPacker()
  
  #Pack = 0
  #JSON = 1
  
  Structure Content_Structure
    PackFile.s
    Map Content.i()
  EndStructure
  
  Global NewMap ResEx.Content_Structure()
  
  Procedure.i Open(Pack.i, PackFile$)
    Define.i Result
    Define File$
   
    Result = OpenPack(Pack, PackFile$, #PB_PackerPlugin_Lzma)
    If Result
      
      If Pack = #PB_Any : Pack = Result : EndIf
      
      If AddMapElement(ResEx(), Str(Pack))
        ResEx()\PackFile = PackFile$
        If ExaminePack(Pack)
          While NextPackEntry(Pack)
            File$ = PackEntryName(Pack)
            ResEx()\Content(File$) = PackEntrySize(Pack)
          Wend  
        EndIf
      EndIf

      ProcedureReturn Pack
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetImage(Pack.i, Image.i, FileName$)
    Define.i Result.i, *Buffer
    If FindMapElement(ResEx(), Str(Pack))
      FileName$ = GetFilePart(FileName$)
      If FindMapElement(ResEx()\Content(), FileName$)
        *Buffer = AllocateMemory(ResEx()\Content())
        If *Buffer
          If UncompressPackMemory(Pack, *Buffer, ResEx()\Content(), FileName$) >= 0
            Result = CatchImage(Image, *Buffer, ResEx()\Content())
            If Result
              If Image = #PB_Any : Image = Result :  EndIf
            Else
              Image = #False
            EndIf
          EndIf
          FreeMemory(*Buffer)
        EndIf
        
        ProcedureReturn Image
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetSound(Pack.i, Sound.i, FileName$, Flags.i=#False)
    Define.i Result.i, *Buffer

    If FindMapElement(ResEx(), Str(Pack))
      
      FileName$ = GetFilePart(FileName$)
      If FindMapElement(ResEx()\Content(), FileName$)
        
        *Buffer = AllocateMemory(ResEx()\Content())
        If *Buffer
          If UncompressPackMemory(Pack, *Buffer, ResEx()\Content(), FileName$)
            Result =  CatchSound(Sound, *Buffer, ResEx()\Content(), Flags)
            If Result
              If Sound = #PB_Any : Sound = Result :  EndIf
            Else
              Sound = #False
            EndIf
          EndIf
          FreeMemory(*Buffer)
        EndIf
        
        ProcedureReturn Sound
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetXML(Pack.i, XML.i, FileName$, Flags.i=#False, Encoding.i=#PB_UTF8)
    Define.i Result.i, *Buffer

    If FindMapElement(ResEx(), Str(Pack))
      FileName$ = GetFilePart(FileName$)
      If FindMapElement(ResEx()\Content(), FileName$)
        *Buffer = AllocateMemory(ResEx()\Content())
        If *Buffer
          If UncompressPackMemory(Pack, *Buffer, ResEx()\Content(), FileName$)
            Result = CatchXML(XML, *Buffer, ResEx()\Content(), Flags, Encoding)
            If Result
              If XML = #PB_Any : XML = Result :  EndIf
            Else
              XML = #False
            EndIf
          EndIf
          FreeMemory(*Buffer)
        EndIf
      EndIf
      ProcedureReturn XML
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i GetJSON(Pack.i, JSON.i, FileName$, Flags.i=#False)
    Define Result.i, *Buffer

    If FindMapElement(ResEx(), Str(Pack))
      FileName$ = GetFilePart(FileName$)
      If FindMapElement(ResEx()\Content(), FileName$)
        *Buffer = AllocateMemory(ResEx()\Content())
        If *Buffer
          If UncompressPackMemory(Pack, *Buffer, ResEx()\Content(), FileName$)
            Result = CatchJSON(JSON, *Buffer, ResEx()\Content(), Flags)
            If Result
              If JSON = #PB_Any : JSON = Result :  EndIf
            Else
              JSON = #False
            EndIf
          EndIf
          FreeMemory(*Buffer)
        EndIf
      EndIf
      ProcedureReturn JSON
    EndIf
  EndProcedure
  
  Procedure.i GetFileSize(Pack.i, FileName$)
    If FindMapElement(ResEx(), Str(Pack))
      FileName$ = GetFilePart(FileName$)
      If FindMapElement(ResEx()\Content(), FileName$)
        ProcedureReturn ResEx()\Content()
      EndIf
    EndIf
  EndProcedure
  
  Procedure.i GetFileMemory(Pack.i, *Buffer, FileName$)
    Define Result.i
    
    If FindMapElement(ResEx(), Str(Pack))
      FileName$ = GetFilePart(FileName$)
      If FindMapElement(ResEx()\Content(), FileName$)
        Result = UncompressPackMemory(Pack, *Buffer, ResEx()\Content(), FileName$)
        ProcedureReturn Result
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure Close(Pack.i)
    If FindMapElement(ResEx(), Str(Pack))
      DeleteMapElement(ResEx())
      ClosePack(Pack)
    EndIf
  EndProcedure
  
EndModule

;- ========  Module - Demo ========

CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  CompilerIf #PackResource
    If PackResource::Open("Test.res", "Test")
      
      PackResource::Add("Test", #PB_Compiler_Home + "examples\sources\Data\PureBasic.bmp")
      PackResource::Add("Test", #PB_Compiler_Home + "examples\sources\Data\CdPlayer.ico")
      PackResource::Add("Test", #PB_Compiler_Home + "examples\sources\Data\world.png")
      
      PackResource::Create("Test")
      
      PackResource::Close("Test")
    EndIf
  CompilerEndIf
  
  #Win = 0
  #Pack = 1
  #ImageGadget = 1
  #Image = 1
  
  If Resource::Open(#Pack, "Test.res")
    Resource::GetImage(#Pack, #Image, "PureBasic.bmp")
    Resource::Close(#Pack)
  EndIf
  
  
  If OpenWindow(#Win, 100, 100, 300, 200, "Resource - Image")
    
    If IsImage(#Image)
      ImageGadget(#ImageGadget, 10, 10, 100, 100, ImageID(#Image), #PB_Image_Border) 
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
    
    CloseWindow(#Win)
  EndIf

CompilerEndIf
