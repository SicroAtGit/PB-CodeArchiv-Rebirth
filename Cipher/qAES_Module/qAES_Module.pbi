;   Description: Quick & secure AES - Encryption/Decryption 
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=73334
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31610
; -----------------------------------------------------------------------------

;/ =========================
;/ =    qAES_Module.pbi    =
;/ =========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ based on code of Werner Albus - www.nachtoptik.de
;/ 
;/ < No warranty whatsoever - Use at your own risk >
;/
;/ Module by Thorsten Hoeppner (07/2019) 
;/

; Last Update: 16.08.2019

; - Added: ProgressBar for CheckIntegrity()
; - Added: ProgressProcedure()


;{ ===== MIT License =====
;
; Copyright (c) 2019 Werner Albus - www.nachtoptik.de
; Copyright (c) 2019 Thorsten Hoeppner
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
;}


; [Security Level 1]: No normal mortal should be able to access my data.
; [Security Level 2]: I'm a little paranoid about my data.
; [Security Level 3]: Security level 2 + CreateSecureKey(Key, 1e5)

;{ _____ qAES - Commands _____

; qAES::CreateSecureKey()           - use secure keys to make brute force attacks more difficult
; qAES::SetAttribute()              - [#EnlargeBytes/#HashLength/#ProtectedMarker/#CryptMarker]
; qAES::SetSalt()                   - add your own salt
; qAES::ProgressProcedure()         - define a procedure to show progress
; qAES::GetErrorMessage()           - returns error message 
; qAES::SmartCoder()                - encrypt / decrypt ascii strings, unicode strings and binary data (#Binary/#Ascii/#Unicode)

; ----- #Enable_BasicCoders [Security Level 1] -----

; qAES::EncodeFile()                - encrypt file with SmartCoder()
; qAES::DecodeFile()                - decrypt file with SmartCoder()
; qAES::FileCoder()                 - encrypt & decrypt  with SmartCoder()
; qAES::String()                    - encrypt / decrypt string with SmartCoder()
; qAES::StringToFile()              - create an encrypted string file with SmartCoder()
; qAES::File2String()               - read an encrypted string file with SmartCoder()
; qAES::IsCryptFile()               - checks if the file is encrypted. with SmartCoder()

; ----- #Enable_LoadSaveCrypt [Security Level 1] -----

; qAES::LoadCryptImage()            - similar to LoadImage()
; qAES::SaveCryptImage()            - similar to SaveImage()
; qAES::LoadCryptJSON()             - similar to LoadJSON()
; qAES::SaveCryptJSON()             - similar to SaveJSON()
; qAES::LoadCryptXML()              - similar to LoadXML()
; qAES::SaveCryptXML()              - similar to SaveXML()

; ----- #Enable_CryptPacker [Security Level 1] -----

; qAES::AddCryptPackFile()          - similar to AddPackFile()
; qAES::UncompressCryptPackFile()   - similar to UncompressPackFile()
; qAES::AddCryptPackMemory()        - similar to AddPackMemory()
; qAES::UncompressCryptPackMemory() - similar to UncompressPackMemory()
; qAES::AddCryptPackXML()           - similar to SaveXML(), but for packer
; qAES::UncompressCryptPackXML()    - similar to LoadXML(), but for packer
; qAES::AddCryptPackJSON()          - similar to SaveJSON(), but for packer
; qAES::UncompressCryptPackJSON()   - similar to LoadJSON(), but for packer
; qAES::AddCryptPackImage()         - similar to SaveImage(), but for packer
; qAES::UncompressCryptPackImage()  - similar to LoadImage(), but for packer
; qAES::IsCryptPackFile()           - checks if the packed file is encrypted

; ----- #Enable_SmartFileCoder [Security Level 2] -----

; qAES::SmartFileCoder()            - encrypting or decrypting file
; qAES::CheckIntegrity()            - checks the integrity of a encrypted file
; qAES::IsEncrypted()               - checks if a file is already encrypted
; qAES::IsProtected()               - checks if a file is already protected
; qAES::GetFileSize()               - returns the real file size
; qAES::CreateStringFile()          - create an encrypted string file
; qAES::ReadStringFile()            - read an encrypted string file
; qAES::ReadProtectedFile()         - read protected file and write it to memory
; qAES::EncryptImage()              - encrypt an image
; qAES::DecryptImage()              - decrypt an image
; qAES::LoadEncryptedImage()        - load an encrypted image (returns image number)

;}


DeclareModule qAES
  
  #Enable_BasicCoders    = #True  ; [Security Level 1]
  #Enable_LoadSaveCrypt  = #True  ; [Security Level 1]
  #Enable_CryptPacker    = #True  ; [Security Level 1]
  #Enable_SmartFileCoder = #True  ; [Security Level 2]
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================
  
  #ProtectCounter = 18

  #Binary  = 0  ; Mode BINARY, you can encrypt binary data, don't use this for on demand string encryption, it break the string termination!
  #Ascii   = 1  ; Mode ASCII, you can encrypt mixed data, string and binary - This ignore the encryption of zero bytes, recommended for mixed datea with ASCII strings.
  #Unicode = 2  ; Mode UNICODE, you can encrypt mixed data, ascii strings, unicode strings and binary - This ignore the encryption of zero bytes.
  
  #SecureKey      = 1
  #SmartFileCoder = 2
  #BasicCoder     = 3
  
  Enumeration
    #Auto
    #Encrypt
    #Decrypt
    #Protect
    #Unprotect
  EndEnumeration
  
  Enumeration 1
    #CryptMarker     ; preset crypt marker
    #EnlargeBytes    ; enlarge file length bytes
    #RandomizeBytes  ; randomize file length bytes
    #HashLength      ; (224, 256, 384, 512)
    #ProtectedMarker ; preset protected marker
    #CounterAES      ; CounterAES for SmartCoder()
  EndEnumeration
  
  EnumerationBinary
    #EnlargeSize       ; enlarge file with random data (#EnlargeBytes)
    #RandomizeSize     ; randomize the file length (0 - 256 Bytes)
  EndEnumeration
  
  Enumeration 1
    #ERROR_ALREADY_ENCRYPTED
    #ERROR_CAN_NOT_CREATE_COUNTER
    #ERROR_CAN_NOT_OPEN_FILE
    #ERROR_ENCODING_FAILS
    #ERROR_INTEGRITY_CORRUPTED
    #ERROR_FILE_NOT_EXIST
    #ERROR_FILE_HASH_BROKEN
    #ERROR_FINGERPRINT_FAILS
    #ERROR_NOT_ENCRYPTED
    #ERROR_INCORRECT_DATA
  EndEnumeration
  
	;- ===========================================================================
	;-   DeclareModule - Structures
	;- ===========================================================================  
  
  Structure Progress_Structure
    Gadget.i
    State.i
    Row.i
    Column.i
    Index.i
    Label.s
    Flag.i
  EndStructure
  Global Progress.Progress_Structure
  
  Structure Memory_Structure
	  *Buffer
	  Size.i
	EndStructure
  
	;- ===========================================================================
	;-   DeclareModule
  ;- ===========================================================================
  
  CompilerIf #Enable_BasicCoders
    Declare.i DecodeFile(File.s, Key.s, CryptExtension.s="", ProgressBar.i=#False) 
    Declare.i EncodeFile(File.s, Key.s, CryptExtension.s="", ProgressBar.i=#False) 
    Declare.i FileCoder(File.s, Key.s, CryptExtension.s="", ProgressBar.i=#False)
    Declare.s FileToString(File.s, Key.s)
    Declare.s String(String.s, Key.s) 
    Declare.i StringToFile(String.s, File.s, Key.s)
  CompilerEndIf
  
  CompilerIf #Enable_SmartFileCoder
    Declare.i CheckIntegrity(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#False, ProgressBar.i=#PB_Default)
    Declare.i SmartFileCoder(Mode.i, File.s, Key.s, CryptExtension.s="", Flags.i=#False, ProtectCounter.i=#False, ProgressBar.i=#PB_Default)
    Declare.i IsEncrypted(File.s, Key.s, CryptExtension.s="")
    Declare.i IsProtected(File.s, Key.s, ProtectExtension.s="", ProtectCounter.i=#ProtectCounter)
    Declare.i GetFileSize(File.s, Key.s, FileExtension.s="", ProtectCounter.i=#False)
    Declare.i CreateStringFile(String.s, File.s, Key.s, Flags.i=#False, ProtectCounter.i=#ProtectCounter)
    Declare.s ReadStringFile(File.s, Key.s, ProtectCounter.i=#ProtectCounter)
    Declare.i ReadProtectedFile(File.s, *Memory.Memory_Structure, Key.s, FileExtension.s="")
    Declare.i EncryptImage(File.s, Key.s, CryptExtension.s="", Flags.i=#False, ProtectCounter.i=#ProtectCounter)
    Declare.i DecryptImage(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#ProtectCounter)
    Declare.i LoadEncryptedImage(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#ProtectCounter)
  CompilerEndIf
  
  CompilerIf #Enable_LoadSaveCrypt
    Declare.i LoadCryptImage(Image.i, File.s, Key.s, ProgressBar.i=#False)
    Declare.i LoadCryptJSON(JSON.i, File.s, Key.s)
    Declare.i LoadCryptXML(XML.i, File.s, Key.s)
    Declare.i SaveCryptImage(Image.i, File.s, Key.s, ProgressBar.i=#False)
    Declare.i SaveCryptJSON(JSON.i, File.s, Key.s)
    Declare.i SaveCryptXML(XML.i, File.s, Key.s)
  CompilerEndIf
  
  CompilerIf #Enable_CryptPacker
    
    Declare.i AddCryptPackFile(Pack.i, File.s, Key.s, ProgressBar.i=#False)
    Declare.i UncompressCryptPackFile(Pack.i, File.s, Key.s, PackedFileName.s="", ProgressBar.i=#False)
    
    Declare.i AddCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s)
    Declare.i UncompressCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s="")
    
    Declare.i AddCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s)
    Declare.i UncompressCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s="")
    
    Declare.i AddCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s)
    Declare.i UncompressCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s="")
    
    Declare.i AddCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s, ProgressBar.i=#False)
    Declare.i UncompressCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s="", ProgressBar.i=#False)
    
    Declare.i IsCryptPackFile(Pack.i, PackedFileName.s)
    Declare.s PackFileHash(Pack.i, PackedFileName.s)
    
  CompilerEndIf
  
  Declare.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
  Declare.s CreateSecureKey(Key.s, Loops.i=2048, ProgressBar.i=#PB_Default)
  Declare   SetAttribute(Attribute.i, Value.q)
  Declare   SetSalt(String.s)
  Declare.i GetError()
  Declare.s GetErrorMessage()
  Declare.s GetHash()
  Declare.i IsCryptFile(File.s, CryptExtension.s="") ; NOT: SmartFileCoder
  Declare.s FileHash(File.s, CryptExtension.s="")    ; NOT: SmartFileCoder
  Declare   ProgressProcedure(*ProcAddress)
  
EndDeclareModule

Module qAES

	EnableExplicit
	
	UseSHA3Fingerprint()
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#qAES  = 113656983
	#Salt$ = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"

	;- ============================================================================
  ;-   Module - Structure
	;- ============================================================================
	
	Structure Footer_Structure
	  ID.q
	  Counter.q
	  Hash.s
	EndStructure
	
	Structure AES_Structure ;{ qAES\...
	  CryptExtLength.i
	  CounterAES.q
	  EnlargeBytes.i
	  RandomizeBytes.i
	  Hash.s
	  HashLength.i
	  ProtectedMarker.q
	  CryptMarker.q
	  Salt.s
	  *ProcPtr
	  Error.i
	EndStructure ;}
	Global qAES.AES_Structure

  ;- ==========================================================================
	;-   Module - Internal Procedures
	;- ==========================================================================
	
	Procedure.s ExtendedFileName_(File.s, Extension.s, FileMustExist.i=#False)
    Define.s ExtendedFile 
    
    ExtendedFile = GetPathPart(File) + GetFilePart(File, #PB_FileSystem_NoExtension) + Extension + "." + GetExtensionPart(File)
    
    If FileMustExist
      
      If FileSize(ExtendedFile) > 0
        ProcedureReturn ExtendedFile
      Else
        ProcedureReturn File
      EndIf
      
    Else
      ProcedureReturn ExtendedFile
    EndIf 
    
  EndProcedure
	
	
	Procedure.q GetCounter_()
	  Define.q Counter
	  
	  If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
    Else
      RandomData(@Counter, 8)
    EndIf
    
    ProcedureReturn Counter
	EndProcedure
	
	Procedure   EncodeHash_(Hash.s, Counter.q, *Hash)
    Define.i i
    
    Static Dim Hash.q(31)
    
    For i=0 To 31
      PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash + i * SizeOf(character) << 1, 2)))
    Next
    
    SmartCoder(#Binary, @Hash(0), *Hash, 32, Str(Counter))
    
  EndProcedure
  
  
  Procedure   SetProgressState_(Gadget.i, State.i, Flag.i)
    
    If qAES\ProcPtr
      Progress\Gadget = Gadget
      Progress\State  = State
      Progress\Flag   = Flag
      CallFunctionFast(qAES\ProcPtr)
    Else
      SetGadgetState(Gadget, State)
    EndIf
    
    While WindowEvent() : Wend
    
  EndProcedure
  
	Procedure.s KeyStretching_(Key.s, Loops.i, ProgressBar.i=#PB_Default)
    ; Author Werner Albus - www.nachtoptik.de
    Define.i i, Timer
    Define.s Salt$
    
    If qAES\Salt = "" 
	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  Else  
	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  EndIf
    
    If IsGadget(ProgressBar)
      Timer = ElapsedMilliseconds()
      SetProgressState_(ProgressBar, 0, #SecureKey)
    EndIf
    
    For i=1 To Loops
      
      Key = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512)
      
      If IsGadget(ProgressBar)
        If ElapsedMilliseconds() > Timer + 100
          SetProgressState_(ProgressBar, 100 * i / Loops, #SecureKey)
          Timer = ElapsedMilliseconds()
        EndIf
      EndIf
      
    Next
    
    Key = ReverseString(Key) + Salt$ + Key + ReverseString(Key)
    Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512) ; Finalize
    
    If IsGadget(ProgressBar)
      SetProgressState_(ProgressBar, 100, #SecureKey)
    EndIf
    
    ProcedureReturn Key
  EndProcedure
  
  
  Procedure.i IsEncrypted_(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#False)
	  Define.q FileSize, fCounter, Magic, fMagic
	  Define.i FileID, EncryptedFileFound
	  Define.s Key$, Salt$

	  If CryptExtension
	    File = ExtendedFileName_(File, CryptExtension, #True)
	  EndIf
	  
	  If FileSize(File) <= 0
	    qAES\Error = #ERROR_FILE_NOT_EXIST
	    ProcedureReturn #False
	  EndIf
	  
	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
	  If qAES\Salt = "" 
	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  Else  
	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  EndIf
	  
	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
	  
	  If ProtectCounter ;{ Counter / Magic
      Magic = qAES\ProtectedMarker
    Else
      Magic = qAES\CryptMarker
      ;}
    EndIf

    Key$  = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
    Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
    
    SmartCoder(#Binary, @Magic, @Magic, 8, Salt$ + ReverseString(Key$) + Str(Magic) + Key$)
    
	  FileID = ReadFile(#PB_Any, File)
	  If FileID
	    
	    FileSize = Lof(FileID)
	    
	    If FileSize - qAES\CryptExtLength > 0
	      
  	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
  	    
  	    ReadData(FileID, @fCounter, 8)
  	    ReadData(FileID, @fMagic, 8)
  	    
  	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + Salt$)
        SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
      EndIf
      
      If fMagic = Magic 
        EncryptedFileFound = #True
      EndIf    
   
      CloseFile(FileID)
    Else 
      qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
      ProcedureReturn #False  
	  EndIf
	  
	  ProcedureReturn EncryptedFileFound
	EndProcedure
	
  Procedure.i NotEncrypted_(*Buffer, Size.i) 
    Define.q Counter, qAES_ID
    
    qAES_ID = PeekQ(*Buffer + Size - 16)
    Counter = PeekQ(*Buffer + Size -  8)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    If qAES_ID = #qAES
      qAES\Error = #ERROR_ALREADY_ENCRYPTED
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True    
  EndProcedure
  
  
  Procedure   CryptBlockwise(*Buffer, Size.i, Key.s, Counter.q, ProgressBar.i=#False)
    Define.i BlockSize, Bytes
    Define.q Timer, CounterAES
    
    BlockSize = 4096 << 2
	  Bytes = 0
	  
    ;{ ___ ProgressBar ___
    If IsGadget(ProgressBar)
      Timer = ElapsedMilliseconds()
      SetProgressState_(ProgressBar, 0, #BasicCoder)
    EndIf ;}
	  
	  Repeat
	    
	    If Bytes + BlockSize <= Size
	      SmartCoder(#Binary, *Buffer + Bytes, *Buffer + Bytes, BlockSize, Key, Counter, CounterAES)
	    Else
	      SmartCoder(#Binary, *Buffer + Bytes, *Buffer + Bytes, Size - Bytes, Key, Counter, CounterAES)
	    EndIf 
	    
	    ;{ ___ ProgressBar ___
      If IsGadget(ProgressBar)
        If ElapsedMilliseconds() > Timer + 30
          SetProgressState_(ProgressBar, 100 * Bytes / Size, #BasicCoder)
          Timer = ElapsedMilliseconds()
        EndIf
      EndIf ;}
	    
	    Bytes + BlockSize
	    
	    Counter + 1
	    CounterAES + 1
	    
	  Until Bytes >= Size
	  
	  ;{ ___ ProgressBar ___
    If IsGadget(ProgressBar)
      SetProgressState_(ProgressBar, 100, #BasicCoder)
    EndIf ;}
	  
  EndProcedure
  
  
	Procedure.i WriteEncryptedFile_(File.s, *Buffer, Size.i, Key.s, ProgressBar.i=#False) 
	  Define.i FileID, Size, Result
    Define.q Counter, qAES_ID = #qAES
    Define   *Buffer, *Hash
    
    Counter = GetCounter_()
    
    qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
    *Hash = AllocateMemory(32)
    If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    CryptBlockwise(*Buffer, Size, Key, Counter, ProgressBar)
    
    FileID = CreateFile(#PB_Any, File)
    If FileID 
      Result = WriteData(FileID, *Buffer, Size)
      WriteData(FileID, *Hash, 32)
      WriteQuad(FileID, qAES_ID)
      WriteQuad(FileID, Counter)
      CloseFile(FileID)
    EndIf
    
    If *Hash : FreeMemory(*Hash) : EndIf
    
    ProcedureReturn Result
	EndProcedure
	
  Procedure.i WriteDecryptedFile_(File.s, *Buffer, Size.i, Key.s, ProgressBar.i=#False) 
	  Define.i i, FileID, Result
    Define.q Counter, qAES_ID
    Static Dim Hash.q(31)
    
    Counter = PeekQ(*Buffer + Size - 8)
    qAES_ID = PeekQ(*Buffer + Size - 16)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    SmartCoder(#Binary, *Buffer + Size - 48, @Hash(0), 32, Str(Counter))
    
    qAES\Hash = ""
    For i = 0 To 31
      qAES\Hash + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
    Next i
    qAES\Hash = LCase(qAES\Hash)
    
    If qAES_ID = #qAES
      
      Size - 48
      
      CryptBlockwise(*Buffer, Size, Key, Counter, ProgressBar)
      
      If qAES\Hash <> Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        qAES\Error = #ERROR_INTEGRITY_CORRUPTED
        qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        FreeMemory(*Buffer)
        ProcedureReturn #False
      EndIf

    Else
      qAES\Error = #ERROR_NOT_ENCRYPTED
    EndIf
  
    FileID = CreateFile(#PB_Any, File)
    If FileID 
      Result = WriteData(FileID, *Buffer, Size)
      CloseFile(FileID)
    EndIf
    
    ProcedureReturn Result
	EndProcedure
	
  Procedure   WriteEncryptedMemory_(*Buffer, Size.i, Key.s, ProgressBar.i=#False)
    Define.i i
    Define.q Counter, qAES_ID = #qAES
    Static Dim Hash.q(31)
    
    Counter = GetCounter_()
    
    qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
    For i=0 To 31
      PokeA(@Hash(0) + i, Val("$" + PeekS(@qAES\Hash + i * SizeOf(character) << 1, 2)))
    Next
    
    CryptBlockwise(*Buffer, Size, Key, Counter, ProgressBar)
    
    SmartCoder(#Binary, @Hash(0), *Buffer + Size, 32, Str(Counter))
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    PokeQ(*Buffer + Size + 32, qAES_ID)
    PokeQ(*Buffer + Size + 40, Counter)
    
  EndProcedure
  
  
  Procedure.i ReadFileFooter_(FileID.i, FileSize.i, *Footer.Footer_Structure)
    Define i.i, qAES_ID.q 
    Define *Hash
    Static Dim Hash.q(31)

    *Hash = AllocateMemory(32)
    If *Hash
      
      FileSeek(FileID, FileSize - 48)
      ReadData(FileID, *Hash, 32)
      qAES_ID = ReadQuad(FileID) 
      *Footer\Counter = ReadQuad(FileID)
      FileSeek(FileID, 0)
      
      SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(*Footer\Counter))
      SmartCoder(#Binary, *Hash, @Hash(0), 32, Str(*Footer\Counter))
      
      *Footer\ID = qAES_ID
      
      *Footer\Hash = ""
      For i = 0 To 31
        *Footer\Hash + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
      Next
      *Footer\Hash = LCase(*Footer\Hash)
      
      FreeMemory(*Hash)
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure   ReadMemoryFooter_(*Buffer, Size.i, *Footer.Footer_Structure)
    Define i.i, qAES_ID.q 
    Static Dim Hash.q(31)
    
    *Footer\Counter = PeekQ(*Buffer + Size - 8)
    qAES_ID = PeekQ(*Buffer + Size - 16)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(*Footer\Counter))
    SmartCoder(#Binary, *Buffer + Size - 48, @Hash(0), 32, Str(*Footer\Counter))
   
    *Footer\ID = qAES_ID
   
    *Footer\Hash = ""
    For i = 0 To 31
      *Footer\Hash + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
    Next
    *Footer\Hash = LCase(*Footer\Hash)

  EndProcedure
  
	Procedure.i DecryptBuffer_(*Buffer, Size.i, Key.s, Counter.q, ProgressBar.i=#False) 
	  
	  CryptBlockwise(*Buffer, Size, Key, Counter, ProgressBar)
	  
    If qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
      ProcedureReturn #True
    Else  
      qAES\Error = #ERROR_INTEGRITY_CORRUPTED
      qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
      ProcedureReturn #False
    EndIf
    
  EndProcedure
	
	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  ;- _____ Tools _____

  Procedure.s CreateSecureKey(Key.s, Loops.i=2048, ProgressBar.i=#PB_Default)
    ProcedureReturn KeyStretching_(Key, Loops, ProgressBar)
  EndProcedure
  
  Procedure.i GetError()
    ProcedureReturn qAES\Error
  EndProcedure
  
  Procedure.s GetErrorMessage()
    
    Select qAES\Error
      Case #ERROR_CAN_NOT_CREATE_COUNTER
        ProcedureReturn "Error: Can't create counter."
      Case #ERROR_INTEGRITY_CORRUPTED
        ProcedureReturn "Error: Integrity is corrupted."
      Case #ERROR_FILE_NOT_EXIST
        ProcedureReturn "Error: File not found."
      Case #ERROR_FILE_HASH_BROKEN 
        ProcedureReturn "Error: File hash broken."
      Case #ERROR_FINGERPRINT_FAILS
        ProcedureReturn "Error: Fingerprint fails."
      Case #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn "Error: Can't open file."
      Case #ERROR_ENCODING_FAILS
        ProcedureReturn "No error found."
      Case #ERROR_NOT_ENCRYPTED
        ProcedureReturn "Not qAES encrypted."
      Case #ERROR_ALREADY_ENCRYPTED
        ProcedureReturn "Is already qAES encrypted." 
      Case #ERROR_INCORRECT_DATA
        ProcedureReturn "Incorrect data."   
    EndSelect
    
    ProcedureReturn "No error found."
  EndProcedure
  
  Procedure.s GetHash()
    ProcedureReturn qAES\Hash
  EndProcedure
  
  Procedure   ProgressProcedure(*ProcAddress)
    
    qAES\ProcPtr = *ProcAddress
    
  EndProcedure
  
  ;- _____ Settings _____

  Procedure   SetAttribute(Attribute.i, Value.q)
    
    Select Attribute
      Case #EnlargeBytes
        qAES\EnlargeBytes    = Value
      Case #HashLength
        qAES\HashLength      = Value
      Case #ProtectedMarker
        qAES\ProtectedMarker = Value
      Case #CryptMarker
        qAES\CryptMarker     = Value
      Case #CounterAES
        qAES\CounterAES      = Value
      Case #RandomizeBytes
        qAES\RandomizeBytes  = Value
    EndSelect
    
  EndProcedure

  Procedure   SetSalt(String.s)
	  qAES\Salt = String
	EndProcedure
	
	;- _____ SmartCoder _____
	
  ; - This coder go always forward, an extra decoder isn't necessary, just use exactly the same calling convention for encrypting and decrypting!
  ; - This coder can handle automatic string termination for any strings - In compiler mode ASCII and UNICODE !
  ; - The coder works with all data lengths, also < 16 Byte	
	
	Procedure.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
	  ; Author: Werner Albus - www.nachtoptik.de (No warranty whatsoever - Use at your own risk)
    ; CounterKey: If you cipher a file blockwise, always set the current block number with this counter (consecutive numbering).
    ; CounterAES: This counter will be automatically used by the coder, but you can change the startpoint.
	  Define.i i, ii, iii, cStep
	  Define.q Rounds, Remaining
	  Define.s Hash$, Salt$
	  Define   *aRegister.ascii, *wRegister.word, *aBufferIn.ascii, *aBufferOut.ascii, *qBufferIn.quad, *qBufferOut.quad
	  Static   FixedKey${64}
	  Static   Dim Register.q(3)
	  
	  If qAES\Salt = "" 
	    Salt$ = #Salt$
	  Else  
	    Salt$ = qAES\Salt + #Salt$
	  EndIf
	  
	  If CounterAES = 0 : CounterAES = qAES\CounterAES :  EndIf
	  
	  Hash$     = Salt$ + Key + Str(CounterKey) + ReverseString(Salt$)
	  FixedKey$ = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, 256)	  
	  
	  cStep     = SizeOf(character) << 1
	  Rounds    = Size >> 4
	  Remaining = Size % 16
	  
	  For ii = 0 To 31
	    PokeA(@Register(0) + ii, Val("$" + PeekS(@FixedKey$ + iii, 2)))
	    iii + cStep
	  Next
	  
	  Register(1) + CounterAES

	  Select Mode
	    Case #Binary  ;{ Binary content
	      
	      *qBufferIn  = *Input
	      *qBufferOut = *Output
	      
	      If Size < 16 ;{ Size < 16
	        
	        *aBufferOut = *qBufferOut
	        *aBufferIn  = *qBufferIn
	        *aRegister  = @register(0)
	        
	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
	          qAES\Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
          For ii=0 To Size - 1
            *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
          Next
          
          ProcedureReturn #True
          ;}
        EndIf
        
        While i < Rounds ;{ >= 16 Byte
          
          If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
            qAES\Error = #ERROR_ENCODING_FAILS
            ProcedureReturn #False
          EndIf
          
          *qBufferOut\q=*qBufferIn\q ! register(0)
          *qBufferIn  + 8
          *qBufferOut + 8
          *qBufferOut\q = *qBufferIn\q ! register(1)
          *qBufferIn  + 8
          *qBufferOut + 8
          
          i + 1
        Wend ;}
        
        If Remaining
          
          *aBufferOut = *qBufferOut
          *aBufferIn  = *qBufferIn
          *aRegister  = @Register(0)
          
          If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
            qAES\Error = #ERROR_ENCODING_FAILS
            ProcedureReturn #False
          EndIf
          
          For ii=0 To Remaining - 1
            *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
          Next
          
        EndIf
	      ;}
	    Case #Ascii   ;{ Ascii content
	      
	      *aBufferIn  = *Input
	      *aBufferOut = *Output
	      
	      Repeat
	        
	        If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
	          qAES\Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
	        *aRegister = @Register(0)
	        
	        For ii=0 To 15
	          
            If *aBufferIn\a And *aBufferIn\a ! *aRegister\a
              *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            Else
              *aBufferOut\a = *aBufferIn\a
            EndIf
            
            If i > Size - 2 : Break 2 : EndIf
            
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
            
            i + 1
          Next ii
          
        ForEver
  	    ;}
	    Case #Unicode ;{ Unicode content
	      
	      Repeat
	        
	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
	          qAES\Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
	        *wRegister = @Register(0)
          
	        For ii=0 To 15 Step 2
	          
            If *Input\w And *Input\w ! *wRegister\w
              *Output\w = *Input\w ! *wRegister\w
            Else
              *Output\w = *Input\w
            EndIf
            
            If i > Size - 3 : Break 2 : EndIf
            
            *Input + 2
            *Output + 2
            *wRegister + 2
            
            i + 2
          Next ii
          
        ForEver
	      
	      ;}
	  EndSelect
	  
	  ProcedureReturn #True
	EndProcedure
	
	
	CompilerIf #Enable_SmartFileCoder

	  Procedure.i SmartFileCoder(Mode.i, File.s, Key.s, CryptExtension.s="", Flags.i=#False, ProtectCounter.i=#False, ProgressBar.i=#PB_Default)
	    ; Flags: #EnlargeSize | #RandomizeSize
  	  ; Set Flags = #Protect to activate the file protection mode (against changes)
  	  ; ProtectCounter define the CounterAES from the universal crypter
      ; This protect a file, but don't encrypt the file. Mostly files you can normaly use protected
  	  Define.i i, CryptRandom, EncryptedFileFound, HashBytes, ProtectMode
  	  Define.i FileID, BlockSize, Blocks, BlockCounter, Remaining, FileBroken, EnlargeFile
  	  Define.q Counter, cCounter, spCounter, Magic, Timer
  	  Define.q FileSize, fCounter, ReadBytes, WritenBytes, fMagic, FakeLength, fFakeLength
  	  Define.s Key$, Hash$, fHash$, cHash$, Salt$
  	  Define   *Buffer, *Enlarge

  	  qAES\Error = #False
  	  qAES\Hash  = ""
  	  
  	  If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf

  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256 : EndIf
  	  If qAES\EnlargeBytes    = 0 : qAES\EnlargeBytes    = 128 : EndIf
  	  If qAES\RandomizeBytes  = 0 : qAES\RandomizeBytes  = 256 : EndIf 
  	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\Salt = "" 
  	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  Else  
  	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + 8 + qAES\HashLength >> 3
  	  Dim Hash.q(qAES\HashLength >> 3 - 1)
  	  
  	  If Mode = #Protect Or (Mode = #Auto And ProtectCounter)
  	    ;{ Protect File
  	    If ProtectCounter
  	      Counter = ProtectCounter
  	    Else
  	      Counter = #ProtectCounter
  	    EndIf
  	    ProtectMode = #True
        Magic   = qAES\ProtectedMarker
        ;}
      ElseIf Mode = #Unprotect
        ;{ Unprotect File
        ProtectMode = #True
        Magic   = qAES\ProtectedMarker
        ;}
      Else
        ;{ Encrypt / Decrypt File
        Counter = GetCounter_()
        
        Magic = qAES\CryptMarker
        
        If Not Counter 
          qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
          ProcedureReturn #False
        EndIf
        ;}
      EndIf
      
      ;{ ___ ProgressBar ___
      If IsGadget(ProgressBar)
        Timer = ElapsedMilliseconds()
        SetProgressState_(ProgressBar, 0, #SmartFileCoder)
      EndIf ;}
      
      If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2 ; Check Fingerprint
        qAES\Error = #ERROR_FINGERPRINT_FAILS
        ProcedureReturn #False
      EndIf
      
      Key$  = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, Salt$ + ReverseString(Key$) + Str(Magic) + Key$)
  
      FileID = OpenFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        BlockSize = 4096 << 2
        FileBuffersSize(FileID, BlockSize)
        
        *Buffer = AllocateMemory(BlockSize)
        If *Buffer
          
          If FileSize - qAES\CryptExtLength >= 0
            
            FileSeek(FileID, FileSize - qAES\CryptExtLength)
            
            ;{ ___ Read & decrypt file footer ___
            ReadData(FileID, @fFakeLength, 8)
            ReadData(FileID, @fCounter, 8)
            ReadData(FileID, @fMagic, 8)
            ReadData(FileID, @Hash(0), qAES\HashLength >> 3)
            FileSeek(FileID, 0)
  
            SmartCoder(#Binary, @fFakeLength, @fFakeLength, 8, Key$ + ReverseString(Key$))
            SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + Salt$)
            SmartCoder(#Binary, @fMagic, @fMagic, 8, ReverseString(Key$) + Key$, fCounter)
            SmartCoder(#Binary, @Hash(0), @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), fCounter)
            ;}
            
          EndIf
          
          If fMagic = Magic ;{ File encrypted?
            
            If Mode = #Encrypt Or Mode = #Protect
              qAES\Error = #ERROR_ALREADY_ENCRYPTED
              FreeMemory(*Buffer)
              CloseFile(FileID)
              ProcedureReturn #False
            EndIf
            
            EncryptedFileFound = #True
            
            For i = 0 To qAES\HashLength >> 3 - 1
              fHash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
            Next i
            fHash$ = LCase(fHash$)
            
            If fFakeLength < 0 Or fFakeLength >= FileSize - qAES\CryptExtLength
              qAES\Error = #ERROR_INCORRECT_DATA
              FreeMemory(*Buffer)
              CloseFile(FileID)
              ProcedureReturn #False
            EndIf
            
            qAES\CryptExtLength + fFakeLength
            
            cCounter = fCounter
          Else
            
            If Mode = #Decrypt Or Mode = #Unprotect
              qAES\Error = #ERROR_NOT_ENCRYPTED
              FreeMemory(*Buffer)
              CloseFile(FileID)
              ProcedureReturn #False
            EndIf
            
            SmartCoder(#Binary, @Magic, @Magic, 8, ReverseString(Key$) + Key$, Counter) ; Encrypt magic
            
            cCounter = Counter
            ;}
          EndIf
          
          Blocks    = (FileSize - qAES\CryptExtLength) / BlockSize
          Remaining = FileSize - (BlockSize * Blocks)
          
          If EncryptedFileFound : Remaining - qAES\CryptExtLength : EndIf
          
          Repeat 
            
            ReadBytes = ReadData(FileID, *Buffer, BlockSize)
        
            If EncryptedFileFound ;{ File encrypted
            
              HashBytes = ReadBytes - qAES\CryptExtLength
          
              If ReadBytes = BlockSize : HashBytes = ReadBytes : EndIf
              
              ;{ ___ Calculate Hash ___
              If HashBytes > 0
                
                BlockCounter + 1
                
                If Remaining 
                  If BlockCounter > Remaining : HashBytes = Remaining : EndIf
                Else
                  HashBytes = FileSize - qAES\CryptExtLength
                EndIf
                
                Hash$  = Fingerprint(*buffer, HashBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$
                
              EndIf ;}
  
              If ProtectMode = #False
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; decrypt block
              EndIf
              
              ;}
            Else                  ;{ File not encrypted
              
              If ProtectMode = #False
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; encrypt block
              EndIf
              
              ;{ ___ Calculate Hash ___
              If ReadBytes > 0
                Hash$  = Fingerprint(*Buffer, ReadBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$ 
              EndIf ;}
              
              ;}
            EndIf
            
            FileSeek(FileID, -ReadBytes, #PB_Relative)
            WritenBytes + WriteData(FileID, *Buffer, ReadBytes)
            
            ;{ ___ ProgressBar ___
            If IsGadget(ProgressBar)
              If ElapsedMilliseconds() > Timer + 30
                SetProgressState_(ProgressBar, 100 * WritenBytes / FileSize, #SmartFileCoder)
                Timer = ElapsedMilliseconds()
              EndIf
            EndIf ;}
            
            cCounter  + 1
            spCounter + 1
            
          Until ReadBytes = 0
          
          Hash$ + Key$ + Salt$ ; Finishing fingerprint
          Hash$ = LCase(Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength))
          qAES\Hash = Hash$
          
          If EncryptedFileFound ;{ File encrypted
            
            ; ___ Check file integrity ___
            If Hash$ <> fHash$ : FileBroken = #True : EndIf
            
            FileSeek(FileID, -qAES\CryptExtLength, #PB_Relative)
            TruncateFile(FileID)
            
            ;}
          Else                  ;{ File not encrypted
            
            ;{ ___ Enlarge file with random data ___
            FakeLength = 0
            
            If Flags & #EnlargeSize
              FakeLength + qAES\EnlargeBytes
              EnlargeFile = #True
            EndIf
            
            If Flags & #RandomizeSize
              If OpenCryptRandom()
                FakeLength + CryptRandom(qAES\RandomizeBytes)
              Else
                FakeLength + Random(qAES\RandomizeBytes)
              EndIf  
              EnlargeFile = #True
            EndIf
            
            If EnlargeFile And FakeLength
              
              *Enlarge = AllocateMemory(FakeLength)
              If *Enlarge
                
                If OpenCryptRandom()
                  CryptRandomData(*Enlarge, FakeLength)
                Else
                  RandomData(*Enlarge, FakeLength)
                EndIf
                
                WritenBytes + WriteData(FileID, *Enlarge, FakeLength)
                
                FreeMemory(*Enlarge)
              EndIf
              
            EndIf ;}
            
            For i=0 To qAES\HashLength >> 3 - 1
              PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash$ + i *SizeOf(character) << 1, 2)))
            Next
            
            ;{ ___ Encrypt & write file footer ___
            SmartCoder(#Binary, @FakeLength, @FakeLength, 8, Key$ + ReverseString(Key$))
            SmartCoder(#Binary, @Hash(0), @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), Counter)
            SmartCoder(#Binary, @Counter, @Counter, 8, ReverseString(Key$) + Key$ + Salt$)
            
            WritenBytes + WriteData(FileID, @FakeLength, 8)
            WritenBytes + WriteData(FileID, @Counter, 8)
            WritenBytes + WriteData(FileID, @Magic, 8)
            WritenBytes + WriteData(FileID, @Hash(0), qAES\HashLength >> 3)
            ;}
            
            ;}
          EndIf
          
          ;{ ___ ProgressBar ___
          If IsGadget(ProgressBar)
            SetProgressState_(ProgressBar, 100, #SmartFileCoder)
            While WindowEvent() : Wend
          EndIf ;}
          
          FreeMemory(*Buffer)
        EndIf
        
        CloseFile(FileID)
        
        If CryptExtension  ;{ Rename File
          If EncryptedFileFound
            RenameFile(File, RemoveString(File, CryptExtension))
          Else
            RenameFile(File, ExtendedFileName_(File, CryptExtension))
          EndIf ;}
        EndIf
        
        If FileBroken      ;{ Integrity corrupted
          qAES\Error = #ERROR_FILE_HASH_BROKEN
          ProcedureReturn #False
        Else
          ProcedureReturn #True
          ;}
        EndIf
        
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False
      EndIf
      
  	EndProcedure
  	
  	
    Procedure.i CheckIntegrity(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#False, ProgressBar.i=#PB_Default)
  	  Define.q FileSize, fCounter, cCounter, spCounter, ReadBytes, WritenBytes, Magic, fMagic, fFakeLength, Timer
  	  Define.i FileID, CryptRandom, EncryptedFileFound, CheckIntegrity, FileBroken
  	  Define.i i, Blocks, BlockSize, Remaining, HashBytes, BlockCounter
  	  Define.s Key$, Hash$, fHash$, cHash$, Salt$
  	  Define   *Buffer
  	  
  	  qAES\Hash  = ""
  	  qAES\Error = #False
  	  
  	  If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf
  	  
  	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
  	  If qAES\Salt = "" 
  	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  Else  
  	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + 8 + qAES\HashLength >> 3
  	  Dim Hash.q(qAES\HashLength >> 3 - 1)
  	  
  	  If ProtectCounter ;{ Counter / Magic
        Magic   = qAES\ProtectedMarker
      Else
        Magic = qAES\CryptMarker
        ;}
      EndIf
      
      ;{ ___ ProgressBar ___
      If IsGadget(ProgressBar)
        Timer = ElapsedMilliseconds()
        SetProgressState_(ProgressBar, 0, #SmartFileCoder)
      EndIf ;}      
      
      If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2
        qAES\Error = #ERROR_FINGERPRINT_FAILS
        ProcedureReturn #False
      EndIf

      Key$  = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, Salt$ + ReverseString(Key$) + Str(Magic) + Key$)
      
  	  FileID = ReadFile(#PB_Any, File)
  	  If FileID
  	    
  	    FileSize = Lof(FileID)
  	    
  	    BlockSize = 4096 << 2
        FileBuffersSize(FileID, BlockSize)
        
        *Buffer = AllocateMemory(BlockSize)
        If *Buffer
          
          If FileSize - qAES\CryptExtLength > 0
            
      	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
      	    
      	    ;{ Read file footer
      	    ReadData(FileID, @fFakeLength, 8)
      	    ReadData(FileID, @fCounter, 8)
      	    ReadData(FileID, @fMagic, 8)
      	    ReadData(FileID, @Hash(0), qAES\HashLength >> 3)
            FileSeek(FileID, 0)
            ;}
    
            ;{ Decrypt file footer
            SmartCoder(#Binary, @fFakeLength, @fFakeLength, 8, Key$ + ReverseString(Key$))
      	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + Salt$)
            SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
            SmartCoder(#Binary, @Hash(0),  @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), fCounter)
            ;}
            
          EndIf
          
          If fMagic = Magic ;{ File encrypted
            
            EncryptedFileFound = #True
            cCounter = fCounter
            
            For i = 0 To qAES\HashLength >> 3 - 1
              fHash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
            Next i
            fHash$ = LCase(fHash$)
            
            If fFakeLength < 0 Or fFakeLength >= FileSize - qAES\CryptExtLength
              FreeMemory(*Buffer)
              CloseFile(FileID)
              ProcedureReturn #False
            EndIf
            
            qAES\CryptExtLength + fFakeLength
            ;}
          EndIf    
          
          Blocks    = (FileSize - qAES\CryptExtLength) / BlockSize
          Remaining = FileSize - (BlockSize * Blocks)
         
          If EncryptedFileFound : Remaining - qAES\CryptExtLength : EndIf
          
          Repeat 
            
            ReadBytes = ReadData(FileID, *Buffer, BlockSize)
            
            If EncryptedFileFound ;{ File encrypted
              
              HashBytes = ReadBytes - qAES\CryptExtLength
          
              If ReadBytes = BlockSize : HashBytes = ReadBytes : EndIf
              
              If HashBytes > 0
                
                BlockCounter + 1
                
                If Remaining 
                  If BlockCounter > Remaining : HashBytes = Remaining : EndIf
                Else
                  HashBytes = FileSize - qAES\CryptExtLength
                EndIf
                
                Hash$  = Fingerprint(*Buffer, HashBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$
  
              EndIf
              
              If Not ProtectCounter
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
              EndIf
              ;}
            Else                  ;{ File not encrypted  
              
              If Not ProtectCounter
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
              EndIf
              
              If ReadBytes > 0
                Hash$  = Fingerprint(*Buffer, ReadBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$ 
              EndIf
              ;}
            EndIf
            
            WritenBytes + ReadBytes
            
            ;{ ___ ProgressBar ___
            If IsGadget(ProgressBar)
              If ElapsedMilliseconds() > Timer + 30
                SetProgressState_(ProgressBar, 100 * WritenBytes / FileSize, #SmartFileCoder)
                Timer = ElapsedMilliseconds()
              EndIf
            EndIf ;}
            
            cCounter  + 1
            spCounter + 1
            
          Until ReadBytes = 0
          
          Hash$ + Key$ + Salt$ ; Finishing fingerprint
          Hash$ = LCase(Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength))
          
          If EncryptedFileFound
            
            If Hash$ = fHash$
              qAES\Hash = Hash$
            Else
              FileBroken = #True
            EndIf
            
          EndIf
          
          ;{ ___ ProgressBar ___
          If IsGadget(ProgressBar)
            SetProgressState_(ProgressBar, 100, #SmartFileCoder)
            While WindowEvent() : Wend
          EndIf ;}
          
          FreeMemory(*Buffer)
        EndIf
        
        CloseFile(FileID)
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False  
  	  EndIf
  	  
  	  If FileBroken
  	    ProcedureReturn #False
  	  Else
  	    ProcedureReturn #True
  	  EndIf
  	  
  	EndProcedure
  	
  	Procedure.i IsEncrypted(File.s, Key.s, CryptExtension.s="")
  	  qAES\Hash  = ""
  	  qAES\Error = #False
  	  ProcedureReturn IsEncrypted_(File, Key, CryptExtension)
  	EndProcedure
  	
  	Procedure.i IsProtected(File.s, Key.s, ProtectExtension.s="", ProtectCounter.i=#ProtectCounter)
  	  qAES\Error = #False
  	  qAES\Hash  = ""
  	  ProcedureReturn IsEncrypted_(File, Key, ProtectExtension, ProtectCounter)
  	EndProcedure
  	
  	
  	Procedure.i GetFileSize(File.s, Key.s, FileExtension.s="", ProtectCounter.i=#False)
      Define.q fCounter, Magic, fMagic, fFakeLength
  	  Define.i FileID, FileSize, RealFileSize
  	  Define.s Key$, Salt$
  	  
  	  qAES\Error = #False
  	  qAES\Hash  = ""
  	  
  	  If FileExtension
  	    File = ExtendedFileName_(File, FileExtension, #True)
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf
  	  
  	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
  	  If qAES\Salt = "" 
  	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  Else  
  	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + 8 + qAES\HashLength >> 3
  	  
  	  If ProtectCounter ;{ Counter / Magic
        Magic = qAES\ProtectedMarker
      Else
        Magic = qAES\CryptMarker
        ;}
      EndIf

      Key$  = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, Salt$ + ReverseString(Key$) + Str(Magic) + Key$)
      
  	  FileID = ReadFile(#PB_Any, File)
  	  If FileID
  	    
  	    FileSize = Lof(FileID)
  	    
  	    If FileSize - qAES\CryptExtLength > 0
  	      
    	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
    	    
    	    ReadData(FileID, @fFakeLength, 8)
    	    ReadData(FileID, @fCounter, 8)
    	    ReadData(FileID, @fMagic, 8)
    	    
    	    SmartCoder(#Binary, @fFakeLength, @fFakeLength, 8, Key$ + ReverseString(Key$))
    	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + Salt$)
    	    SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
    	    
        EndIf
        
        If fMagic = Magic
          qAES\CryptExtLength + fFakeLength
          RealFileSize = FileSize - qAES\CryptExtLength
        Else
          RealFileSize = FileSize
        EndIf    
     
        CloseFile(FileID)
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False  
  	  EndIf
  	  
  	  ProcedureReturn RealFileSize
    EndProcedure
    
    Procedure.i ReadProtectedFile(File.s, *Memory.Memory_Structure, Key.s, FileExtension.s="")
      Define.q fCounter, Magic, fMagic, fFakeLength
  	  Define.i FileID, FileSize, Result
  	  Define.s Key$, Salt$
  	  
  	  qAES\Error = #False
  	  qAES\Hash  = ""
  	  
  	  If FileExtension
  	    File = ExtendedFileName_(File, FileExtension, #True)
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf
  	  
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
  	  If qAES\Salt = "" 
  	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  Else  
  	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
  	  EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + 8 + qAES\HashLength >> 3
  	  
      Magic = qAES\ProtectedMarker

      Key$  = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, Salt$ + ReverseString(Key$) + Str(Magic) + Key$)
      
  	  FileID = ReadFile(#PB_Any, File)
  	  If FileID
  	    
  	    FileSize = Lof(FileID)
  	    
  	    If FileSize - qAES\CryptExtLength > 0
  	      
    	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
    	    
    	    ReadData(FileID, @fFakeLength, 8)
    	    ReadData(FileID, @fCounter, 8)
    	    ReadData(FileID, @fMagic, 8)
    	    
    	    SmartCoder(#Binary, @fFakeLength, @fFakeLength, 8, Key$ + ReverseString(Key$))
    	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + Salt$)
    	    SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
    	    
        EndIf
        
        If fMagic = Magic
          qAES\CryptExtLength + fFakeLength
          *Memory\Size = FileSize - qAES\CryptExtLength
        Else
          ProcedureReturn #False
        EndIf    
        
        If *Memory\Size
          
          *Memory\Buffer = AllocateMemory(*Memory\Size)
          If *Memory\Buffer
            FileSeek(FileID, 0)
            Result = ReadData(FileID, *Memory\Buffer, *Memory\Size)
          EndIf 
          
        EndIf
        
        CloseFile(FileID)
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False  
  	  EndIf
  	  
  	  ProcedureReturn Result
    EndProcedure
    
    
  	Procedure.i CreateStringFile(String.s, File.s, Key.s, Flags.i=#False, ProtectCounter.i=#ProtectCounter)
  	  ; Flags: #EnlargeSize | #RandomizeSize
  	  Define.i FileID, StrgSize, Result
      Define.q Counter
      Define   *Buffer
      
      qAES\Error = #False
      qAES\Hash  = ""
      
      Counter = GetCounter_()
      
      StrgSize = StringByteLength(String)
      If StrgSize
        
        *Buffer = AllocateMemory(StrgSize)
        If *Buffer
          
          CopyMemory(@String, *Buffer, StrgSize)
          SmartCoder(#Binary, *Buffer, *Buffer, MemorySize(*Buffer), Key, Counter)
          
          FileID = CreateFile(#PB_Any, File)
          If FileID 
            Result = WriteData(FileID, *Buffer, MemorySize(*Buffer))
            WriteQuad(FileID, Counter)
            CloseFile(FileID)
          EndIf

          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      If ProtectCounter
        SmartFileCoder(#Protect, File, Key, "", Flags, ProtectCounter) ; Protect the File
      EndIf  
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.s ReadStringFile(File.s, Key.s, ProtectCounter.i=#ProtectCounter)
      Define.i Result
      Define.q Counter
      Define.s String
      Define   Memory.Memory_Structure
      
      qAES\Error = #False
      qAES\Hash  = ""
      
      If ReadProtectedFile(File, @Memory, Key)
        
        If Memory\Buffer
          
          Counter = PeekQ(Memory\Buffer + Memory\Size - 8)
          Memory\Size - 8
          
          String = Space(Memory\Size / SizeOf(character))
          SmartCoder(#Binary, Memory\Buffer, @String, Memory\Size, Key, Counter)
          
          FreeMemory(Memory\Buffer)
        EndIf

      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn ""
      EndIf
      
      ProcedureReturn String
    EndProcedure 
    
    
    Procedure.i EncryptImage(File.s, Key.s, CryptExtension.s="", Flags.i=#False, ProtectCounter.i=#ProtectCounter)
      ; Flags: #EnlargeSize | #RandomizeSize
      Define.i FileID, FileSize, Result
      Define.q Counter
      Define   *Buffer
      
      qAES\Error = #False
      qAES\Hash  = ""
      
      If ProtectCounter = 0 : ProtectCounter = #ProtectCounter : EndIf
      
      If IsEncrypted_(File, Key, CryptExtension, ProtectCounter) : ProcedureReturn #False : EndIf
      
      Counter = GetCounter_()
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        *Buffer = AllocateMemory(FileSize)
        If *Buffer
          
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            SmartCoder(#Binary, *Buffer, *Buffer, FileSize, Key, Counter)

            FileID = CreateFile(#PB_Any, File)
            If FileID
              Result = WriteData(FileID, *Buffer, FileSize)
              WriteQuad(FileID, Counter)
            EndIf
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
        CloseFile(FileID)
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False  
      EndIf 
      
      If SmartFileCoder(#Protect, File, Key, "", Flags, ProtectCounter) ; Protect the File
        If CryptExtension
          RenameFile(File, ExtendedFileName_(File, CryptExtension))
        EndIf
      Else
        Result = #False
      EndIf  

      ProcedureReturn Result
  EndProcedure
  
    Procedure.i DecryptImage(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#ProtectCounter)
      Define.i FileID, FileSize, Result
      Define.q Counter
      Define   *Buffer
      
      qAES\Error = #False
      qAES\Hash  = ""
      
      If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
  	  
  	  If ProtectCounter = 0 : ProtectCounter = #ProtectCounter : EndIf

      If SmartFileCoder(#Unprotect, File, Key, "", #False, ProtectCounter) 
      
        FileID = ReadFile(#PB_Any, File)
        If FileID
          
          FileSize = Lof(FileID)
          
          FileSeek(FileID, FileSize - 8)
          Counter = ReadQuad(FileID)
          FileSize - 8
          FileSeek(FileID, 0)
          
          *Buffer = AllocateMemory(FileSize)
          If *Buffer
            
            If ReadData(FileID, *Buffer, FileSize)
              
              CloseFile(FileID)
              
              SmartCoder(#Binary, *Buffer, *Buffer, FileSize, Key, Counter)
              
              FileID = CreateFile(#PB_Any, File)
              If FileID
                Result = WriteData(FileID, *Buffer, FileSize)
              EndIf
              
            EndIf
  
            FreeMemory(*Buffer)
          EndIf
      
          CloseFile(FileID)
        Else
          qAES\Error = #ERROR_FILE_NOT_EXIST
          ProcedureReturn #False 
        EndIf 
      
        If Result And CryptExtension
          RenameFile(File, RemoveString(File, CryptExtension))
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadEncryptedImage(File.s, Key.s, CryptExtension.s="", ProtectCounter.i=#ProtectCounter)
      Define.i Image
      Define.q Counter
      Define   Memory.Memory_Structure
      
      qAES\Error = #False
      qAES\Hash  = ""
      
      If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
  	  
  	  If ReadProtectedFile(File, @Memory, Key)
  	    
  	    If Memory\Buffer
          
          Counter = PeekQ(Memory\Buffer + Memory\Size - 8)
          Memory\Size - 8

          SmartCoder(#Binary, Memory\Buffer, Memory\Buffer, Memory\Size, Key, Counter)
          
          Image = CatchImage(#PB_Any, Memory\Buffer, Memory\Size)
          
          FreeMemory(Memory\Buffer)
        EndIf

      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False 
      EndIf 
      
      ProcedureReturn Image
    EndProcedure
    
  CompilerEndIf  
  
	;- _____ Encode / Decode only _____
	
	CompilerIf #Enable_BasicCoders
	  
    Procedure.s String(String.s, Key.s) 
      Define.i StrgSize
      Define.s Output$

      If String
        
        SmartCoder(SizeOf(character), @String, @String, StringByteLength(String), Key)
        
      EndIf
      
      ProcedureReturn String
    EndProcedure
    
    Procedure.i StringToFile(String.s, File.s, Key.s) 
      Define   *Buffer
      Define.i StrgSize, Result

      StrgSize = StringByteLength(String)
      If StrgSize

        *Buffer = AllocateMemory(StrgSize)
        If *Buffer
          
          CopyMemory(@String, *Buffer, StrgSize)
          
          Result = WriteEncryptedFile_(File, *Buffer, StrgSize, Key)
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf

      ProcedureReturn Result
    EndProcedure  
    
    Procedure.s FileToString(File.s, Key.s) 
      Define.i FileID, FileSize, Result
      Define.s String
      Define   Footer.Footer_Structure
      Define   *Buffer

      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          FileSize - 48
          qAES\Hash = Footer\Hash
        Else  
          qAES\Hash  = ""
          qAES\Error = #ERROR_NOT_ENCRYPTED
          CloseFile(FileID)
          ProcedureReturn ""
        EndIf
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            String = Space(FileSize / SizeOf(character))
            
            SmartCoder(#Binary, *Buffer, *Buffer, FileSize, Key, Footer\Counter)
            
            CopyMemory(*Buffer, @String, FileSize)

            If qAES\Hash <> Fingerprint(*Buffer, FileSize, #PB_Cipher_SHA3)
              qAES\Error = #ERROR_INTEGRITY_CORRUPTED
              qAES\Hash  = Fingerprint(*Buffer, FileSize, #PB_Cipher_SHA3)
              FreeMemory(*Buffer)
              ProcedureReturn ""
            EndIf

          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn ""
      EndIf
      
      ProcedureReturn String
    EndProcedure 
    
    
    Procedure.i EncodeFile(File.s, Key.s, CryptExtension.s="", ProgressBar.i=#False)  
      Define.i FileID, FileSize, Result
      Define   *Buffer

      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
          
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)

            If NotEncrypted_(*Buffer, FileSize) 
              Result = WriteEncryptedFile_(File, *Buffer, FileSize, Key, ProgressBar)
            EndIf 
          
            If Result And CryptExtension
              RenameFile(File, ExtendedFileName_(File, CryptExtension))
            EndIf
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i DecodeFile(File.s, Key.s, CryptExtension.s="", ProgressBar.i=#False)
      Define.i FileID, FileSize, Encrypted, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          FileSize - 48
          qAES\Hash = Footer\Hash
          Encrypted = #True
        Else  
          qAES\Hash  = ""
          qAES\Error = #ERROR_NOT_ENCRYPTED
          CloseFile(FileID)
          ProcedureReturn #False
        EndIf
        
        *Buffer = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            If DecryptBuffer_(*Buffer, FileSize, Key, Footer\Counter, ProgressBar)

              FileID = CreateFile(#PB_Any, File)
              If FileID 
                Result = WriteData(FileID, *Buffer, FileSize)
                CloseFile(FileID)
              EndIf

              If Result And CryptExtension
                RenameFile(File, RemoveString(File, CryptExtension))
              EndIf
              
            EndIf 
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf

      ProcedureReturn Result
    EndProcedure 
    
    Procedure.i FileCoder(File.s, Key.s, CryptExtension.s="", ProgressBar.i=#False)
      Define.i FileID, FileSize, Encrypted, Result
      Define   Footer.Footer_Structure
      Define   *Buffer

      If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          FileSize - 48
          qAES\Hash = Footer\Hash
          Encrypted = #True
        Else  
          qAES\Hash  = ""
        EndIf
        
        *Buffer = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)

            If Encrypted ;{ Decode file
              
              If DecryptBuffer_(*Buffer, FileSize, Key, Footer\Counter, ProgressBar)

                FileID = CreateFile(#PB_Any, File)
                If FileID 
                  Result = WriteData(FileID, *Buffer, FileSize)
                  CloseFile(FileID)
                EndIf
                
                If Result And CryptExtension
                  RenameFile(File, RemoveString(File, CryptExtension))
                EndIf
                
              EndIf 
              ;}
            Else         ;{ Encode file

              Result = WriteEncryptedFile_(File, *Buffer, FileSize, Key, ProgressBar)
              
              If Result And CryptExtension
                RenameFile(File, ExtendedFileName_(File, CryptExtension))
              EndIf
              ;}
            EndIf 
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf

      ProcedureReturn Result
    EndProcedure 
    
    
    Procedure.i IsCryptFile(File.s, CryptExtension.s="")
      Define.i FileID, FileSize, Result
      Define   Footer.Footer_Structure
      
      If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          Result = #True
        Else  
          qAES\Error = #ERROR_NOT_ENCRYPTED
          Result = #False
        EndIf 
        
        CloseFile(FileID)
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.s FileHash(File.s, CryptExtension.s="")
      Define.i FileID, FileSize, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      If CryptExtension
  	    File = ExtendedFileName_(File, CryptExtension, #True)
  	  EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          qAES\Hash = Footer\Hash
        Else  
          *Buffer = AllocateMemory(FileSize)
          If *Buffer
            If ReadData(FileID, *Buffer, FileSize)
              qAES\Hash = Fingerprint(*Buffer, FileSize, #PB_Cipher_SHA3)
            EndIf
            FreeMemory(*Buffer)
          EndIf
        EndIf 
        
        CloseFile(FileID)
      EndIf
      
      ProcedureReturn qAES\Hash
    EndProcedure
    
  CompilerEndIf
  
  
  CompilerIf #Enable_LoadSaveCrypt
  
    Procedure.i SaveCryptImage(Image.i, File.s, Key.s, ProgressBar.i=#False)
      Define.i Size, Result
      Define   *Buffer
      
      If IsImage(Image)

        *Buffer = EncodeImage(Image)
        If *Buffer
     
          Size = MemorySize(*Buffer)
          
          Result = WriteEncryptedFile_(File, *Buffer, Size, Key, ProgressBar)

          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadCryptImage(Image.i, File.s, Key.s, ProgressBar.i=#False) ; Use SaveCryptImage() or EncodeFile() to encrypt image
      Define.i FileID, FileSize, Encrypted, Result
      Define   Footer.Footer_Structure
      Define   *Buffer

      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          FileSize - 48
          qAES\Hash = Footer\Hash
          Encrypted = #True
        Else  
          qAES\Hash  = ""
          qAES\Error = #ERROR_NOT_ENCRYPTED
        EndIf 
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            If Encrypted
              If DecryptBuffer_(*Buffer, FileSize, Key, Footer\Counter, ProgressBar)
                Result = CatchImage(Image, *Buffer, FileSize)
              EndIf
            Else
              Result = CatchImage(Image, *Buffer, FileSize)
            EndIf
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
  
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i SaveCryptXML(XML.i, File.s, Key.s)
      Define.i Size, Result
      Define   *Buffer
      
      If IsXML(XML)
        
        Size = ExportXMLSize(XML)
        If Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If ExportXML(XML, *Buffer, Size)
              
              Result = WriteEncryptedFile_(File, *Buffer, Size, Key)
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadCryptXML(XML.i, File.s, Key.s)     ; Use SaveCryptXML() or EncodeFile() to encrypt XML
      Define.i FileID, FileSize, Encrypted, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          FileSize - 48
          qAES\Hash = Footer\Hash
          Encrypted = #True
        Else  
          qAES\Hash  = ""
          qAES\Error = #ERROR_NOT_ENCRYPTED
        EndIf 
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            If Encrypted
              
              If DecryptBuffer_(*Buffer, FileSize, Key, Footer\Counter) 
                Result = CatchXML(XML, *Buffer, FileSize)
              EndIf
              
            Else
              Result = CatchXML(XML, *Buffer, FileSize)
            EndIf
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
  
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i SaveCryptJSON(JSON.i, File.s, Key.s)
      Define.i Size, Result
      Define   *Buffer
      
      If IsJSON(JSON)
        
        Size = ExportJSONSize(JSON)
        If Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If ExportJSON(JSON, *Buffer, Size)
              
             Result = WriteEncryptedFile_(File, *Buffer, Size, Key)
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadCryptJSON(JSON.i, File.s, Key.s)   ; Use SaveCryptJSON() or EncodeFile() to encrypt XML
      Define.i FileID, FileSize, Encrypted, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ReadFileFooter_(FileID, FileSize, @Footer)

        If Footer\ID = #qAES
          FileSize - 48
          qAES\Hash = Footer\Hash
          Encrypted = #True
        Else  
          qAES\Hash  = ""
          qAES\Error = #ERROR_NOT_ENCRYPTED
        EndIf 
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            If Encrypted
              
              If DecryptBuffer_(*Buffer, FileSize, Key, Footer\Counter) 
                Result = CatchJSON(JSON, *Buffer, FileSize)
              EndIf
              
            Else
              Result = CatchJSON(JSON, *Buffer, FileSize)
            EndIf         

          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
  
      ProcedureReturn Result
    EndProcedure
    
  CompilerEndIf
  
  ;- _____ Packer _____
  
  CompilerIf #Enable_CryptPacker

    Procedure.i AddCryptPackFile(Pack.i, File.s, Key.s, ProgressBar.i=#False) 
      Define.i FileID, Size, Result
      Define   *Buffer
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        Size = Lof(FileID)
        
        *Buffer  = AllocateMemory(Size + 48)
        If *Buffer
          
          If ReadData(FileID, *Buffer, Size)
            
            CloseFile(FileID)
            
            If NotEncrypted_(*Buffer, Size) 
              WriteEncryptedMemory_(*Buffer, Size, Key, ProgressBar)
              Size + 48
            EndIf

            Result = AddPackMemory(Pack, *Buffer, Size, GetFilePart(File))

          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
    EndProcedure  

    Procedure.i UncompressCryptPackFile(Pack.i, File.s, Key.s, PackedFileName.s="", ProgressBar.i=#False) 
      Define.i Size, Result = -1
      Define   *Buffer

      If PackedFileName = "" : PackedFileName = GetFilePart(File) : EndIf
      
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                Result = WriteDecryptedFile_(File, *Buffer, Size, Key, ProgressBar)
  
              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend

      EndIf
      
      ProcedureReturn Result
    EndProcedure 
    
    
    Procedure.i AddCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s)
      Define   *Buffer, *Hash, *Output
      Define.q Counter,qAES_ID = #qAES
      Define.i Size, Result

      If *Buffer
        
        *Output = AllocateMemory(Size + 48)
        If *Output
          
          qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
          *Hash = AllocateMemory(32)
          If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
          
          SmartCoder(#Binary, *Buffer, *Output, Size, Key, Counter)
          SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
          
          CopyMemory(*Hash, *Output + Size, 32)
          PokeQ(*Output + Size + 32, qAES_ID)
          PokeQ(*Output + Size + 40, Counter)
          
          Result = AddPackMemory(Pack, *Output, Size + 48, PackedFileName)
          
          If *Hash : FreeMemory(*Hash) : EndIf
          
          FreeMemory(*Output)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i UncompressCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s="")
      Define.i Size, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      If *Buffer

        If UncompressPackMemory(Pack, *Buffer, Size, PackedFileName) <> -1
          
          ReadMemoryFooter_(*Buffer, Size, @Footer)

          If Footer\ID = #qAES
            
            Size - 48
            
            qAES\Hash = Footer\Hash
            
            DecryptBuffer_(*Buffer, Size, Key, Footer\Counter)  
            
          Else
            qAES\Hash = ""
            qAES\Error = #ERROR_NOT_ENCRYPTED
          EndIf 

          Result = Size
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    

    Procedure.i AddCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s)
      Define   *Buffer
      Define.i Size, Result

      If IsXML(XML)

        Size = ExportXMLSize(XML)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            If ExportXML(XML, *Buffer, Size)
              
              WriteEncryptedMemory_(*Buffer, Size, Key)
              
              Result = AddPackMemory(Pack, *Buffer, Size + 48, PackedFileName)
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s="")
      Define.i Size, Result
      Define   Footer.Footer_Structure
      Define   *Buffer

      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ReadMemoryFooter_(*Buffer, Size, @Footer)
                
                If Footer\ID = #qAES
                  
                  Size - 48
                  
                  qAES\Hash = Footer\Hash
                  
                  If DecryptBuffer_(*Buffer, Size, Key, Footer\Counter) 
                    Result = CatchXML(XML, *Buffer, Size)
                  EndIf   
                  
                Else
                  qAES\Hash = ""
                  qAES\Error = #ERROR_NOT_ENCRYPTED
                  Result = CatchXML(XML, *Buffer, Size)
                EndIf 

              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
    
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i AddCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s)
      Define   *Buffer
      Define.i Size, Result
      
      If IsJSON(JSON)

        Size = ExportJSONSize(JSON)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            If ExportJSON(JSON, *Buffer, Size)
              
              WriteEncryptedMemory_(*Buffer, Size, Key)
              
              Result = AddPackMemory(Pack, *Buffer, Size + 48, PackedFileName)
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s="")
      Define.q Counter, qAES_ID
      Define.i Size, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ReadMemoryFooter_(*Buffer, Size, @Footer)
                
                If Footer\ID = #qAES
                  
                  Size - 48
                  
                  qAES\Hash = Footer\Hash
                  
                  If DecryptBuffer_(*Buffer, Size, Key, Footer\Counter) 
                    Result = CatchJSON(JSON, *Buffer, Size)
                  EndIf   
                  
                Else
                  qAES\Hash = ""
                  qAES\Error = #ERROR_NOT_ENCRYPTED
                  Result = CatchJSON(JSON, *Buffer, Size)
                EndIf

              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
    
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i AddCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s, ProgressBar.i=#False)
      Define   *Buffer, *Hash
      Define.i Size, Result
 
      If IsImage(Image)

        *Buffer = EncodeImage(Image)
        If *Buffer
     
          Size = MemorySize(*Buffer)
          
          *Buffer = ReAllocateMemory(*Buffer, Size + 48)
          If *Buffer
            
            WriteEncryptedMemory_(*Buffer, Size, Key, ProgressBar)
           
            Result = AddPackMemory(Pack, *Buffer, Size + 48, PackedFileName)

          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s="", ProgressBar.i=#False)
      Define.q Counter, qAES_ID
      Define.i Size, Result
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ReadMemoryFooter_(*Buffer, Size, @Footer)
                
                If Footer\ID = #qAES
                  
                  Size - 48
                  
                  qAES\Hash = Footer\Hash
                  
                  If DecryptBuffer_(*Buffer, Size, Key, Footer\Counter, ProgressBar) 
                    Result = CatchImage(Image, *Buffer, Size)
                  EndIf   
                  
                Else
                  qAES\Hash = ""
                  qAES\Error = #ERROR_NOT_ENCRYPTED
                  Result = CatchImage(Image, *Buffer, Size)
                EndIf

              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
    
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.s PackFileHash(Pack.i, PackedFileName.s)
      Define.q Counter, qAES_ID
      Define.i Size, Result = -1
      Define   Footer.Footer_Structure
      Define   *Buffer
      
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ReadMemoryFooter_(*Buffer, Size, @Footer)

                If Footer\ID = #qAES
                  qAES\Hash = Footer\Hash
                Else    
                  qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
                EndIf 
              
              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
  
      EndIf
      
      ProcedureReturn qAES\Hash
    EndProcedure

    Procedure.i IsCryptPackFile(Pack.i, PackedFileName.s)
      Define.q Counter, qAES_ID
      Define.i Size, Result = -1
      Define   Footer.Footer_Structure
      Define   *Buffer

      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1

                ReadMemoryFooter_(*Buffer, Size, @Footer)
                
                If Footer\ID = #qAES
                  Result = #True
                Else
                  Result     = #False
                  qAES\Error = #ERROR_NOT_ENCRYPTED
                EndIf 
              
              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
  
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
  CompilerEndIf
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 3
  
  ; === BasicCoders ===
  ;  1: String
  ;  2: String to File
  ;  3: EncodeFile() / DecodeFile()
  ;  4: FileCoder()
  ; === SmartFileCoder ===
  ;  5: SmartFileCoder()
  ;  6: SmartFileCoder() with CryptExtension
  ;  7: CreateStringFile() & CreateStringFile()
  ;  8: LoadEncryptedImage()
  ;  9: Check integrity
  ; 10: Protected Mode
  ; === load/save crypted files ===
  ; 11: Image
  ; 12: XML
  ; 13: JSON
  ; === pack crypted files ===
  ; 14: Packer
  ; 15: Packer: XML
  ; 16: Packer: JSON
  ; 17: Packer: Image
  ; === SmartFileCoder === 
  ; 18: ReadProtectedFile()
  
  Enumeration 1
    #Window
    #ProgressBar
    #Image
  EndEnumeration
  
  #ProtectExtension$ = " [protected]"
  #CryptExtension$   = " [encrypted]"
  
  Procedure UpdateProgressBar()
    SetGadgetState(qAES::Progress\Gadget, qAES::Progress\State)
  EndProcedure
  qAES::ProgressProcedure(@UpdateProgressBar())
  
  If OpenWindow(#Window, 0, 0, 280, 50, "",  #PB_Window_ScreenCentered|#PB_Window_Invisible|#PB_Window_BorderLess|#PB_Window_SystemMenu)
    
    ProgressBarGadget(#ProgressBar, 10, 10, 260, 30, 0, 100, #PB_ProgressBar_Smooth)
    
    ;Key$ = "18qAES07PW67"
    Key$ = qAES::CreateSecureKey("18qAES07PW67")                     ; improves the security for Level 1 & Level 2
    
    HideWindow(#Window, #False)
    ;Key$ = qAES::CreateSecureKey("18qAES07PW67", 1e5, #ProgressBar)   ; recommended for security Level 3
    ;HideWindow(#Window, #True)
    
    CompilerSelect #Example
      CompilerCase 1 
        
        CompilerIf qAES::#Enable_BasicCoders
          
          Text$ = "• This is a test text for the qAES-Module. ( α )"
          
          Text$ = qAES::String(Text$, Key$) 
          Debug Text$

          Text$ = qAES::String(Text$, Key$)
          Debug Text$
          
        CompilerEndIf
        
      CompilerCase 2  
        
        CompilerIf qAES::#Enable_BasicCoders
          
          Text$ = "This is a test text for the qAES-Module."
          
          If qAES::StringToFile(Text$, "String.aes", Key$) 
            String$ = qAES::FileToString("String.aes", Key$)
            Debug String$
          EndIf
          
        CompilerEndIf
        
      CompilerCase 3 
        
        CompilerIf qAES::#Enable_BasicCoders

          qAES::EncodeFile("Test.jpg", Key$, "", #ProgressBar) 
          ;Debug "Hash: " + qAES::GetHash()
          
          MessageRequester("qAES", "Decode file!")
          
          qAES::DecodeFile("Test.jpg", Key$, "", #ProgressBar)
          ;Debug "Hash: " + qAES::GetHash()

        CompilerEndIf
        
      CompilerCase 4 
        
        CompilerIf qAES::#Enable_BasicCoders
          
          qAES::FileCoder("Test.jpg", Key$, #CryptExtension$) ;
          If qAES::IsCryptFile("Test.jpg", #CryptExtension$) ;
            Debug "File is encrypted"
            Debug "Hash: " + qAES::GetHash()
          Else
            Debug "File is not encrypted"
          EndIf
          
        CompilerEndIf
        
      CompilerCase 5  
        
        CompilerIf qAES::#Enable_SmartFileCoder
          qAES::SmartFileCoder(qAES::#Auto, "Test.jpg", Key$)
        CompilerEndIf
      
      CompilerCase 6  
        
        CompilerIf qAES::#Enable_SmartFileCoder
          
          qAES::SmartFileCoder(qAES::#Auto, "Test.jpg", Key$, #CryptExtension$, qAES::#RandomizeSize|qAES::#EnlargeSize)
          
          If qAES::IsEncrypted("Test.jpg", Key$, #CryptExtension$)
            Debug "File is encrypted"
          Else
            Debug "File is not encrypted"
          EndIf
          
        CompilerEndIf
        
      CompilerCase 7  
        
        CompilerIf qAES::#Enable_SmartFileCoder
          
          Text$ = "• This is a test text for the qAES-Module. ( α )"
          
          qAES::CreateStringFile(Text$, "String.aes", Key$, qAES::#RandomizeSize)
          
          String$ = qAES::ReadStringFile("String.aes", Key$)
          Debug String$
          
        CompilerEndIf  
        
      CompilerCase 8  
        
        CompilerIf qAES::#Enable_SmartFileCoder
          
          UseJPEGImageDecoder()
          
          qAES::EncryptImage("Test.jpg", Key$, #CryptExtension$, qAES::#EnlargeSize|qAES::#RandomizeSize)
          
          Image.i = qAES::LoadEncryptedImage("Test.jpg", Key$, #CryptExtension$)
          If IsImage(Image)
            SaveImage(Image, "Decrypted.jpg")
          EndIf
          
          qAES::DecryptImage("Test.jpg", Key$, #CryptExtension$)

        CompilerEndIf
        
      CompilerCase 9
        
        CompilerIf qAES::#Enable_SmartFileCoder
          
          qAES::SmartFileCoder(qAES::#Encrypt, "Test.jpg", Key$, #CryptExtension$)
          
          If qAES::CheckIntegrity("Test.jpg", Key$, #CryptExtension$)
            Debug "File integrity succesfully checked"
          Else
            Debug "File hash not valid"
          EndIf 

        CompilerEndIf
        
      CompilerCase 10
        
        CompilerIf qAES::#Enable_SmartFileCoder
          
          qAES::SmartFileCoder(qAES::#Protect, "Test.jpg", Key$, #ProtectExtension$, qAES::#RandomizeSize, qAES::#ProtectCounter)  

          If qAES::IsProtected("Test.jpg", Key$, #ProtectExtension$, qAES::#ProtectCounter)
            Debug "File is protected"
          Else
            Debug "File is not protected"
          EndIf
          
          If qAES::CheckIntegrity("Test.jpg", Key$, #ProtectExtension$, qAES::#ProtectCounter)
            Debug "File integrity succesfully checked"
          Else
            Debug "File hash not valid"
          EndIf
          
          MessageRequester("qAES", "Unprotect file!")
          
          qAES::SmartFileCoder(qAES::#Unprotect, "Test.jpg", Key$, #ProtectExtension$)  
          
          If qAES::IsProtected("Test.jpg", Key$, #ProtectExtension$, qAES::#ProtectCounter)
            Debug "File is protected"
          Else
            Debug "File is not protected"
          EndIf
          
        CompilerEndIf
        
      CompilerCase 11
        
        CompilerIf  qAES::#Enable_LoadSaveCrypt
          
          UseJPEGImageDecoder()
          
          ;qAES::EncodeFile("Test.jpg", Key$)
          
          If LoadImage(#Image, "Test.jpg")
            qAES::SaveCryptImage(#Image, "Test.jpg.aes", Key$)
          EndIf
          
          If qAES::IsCryptFile("Test.jpg.aes")
            Debug "File is encrypted."
          Else
            Debug "File is not encrypted."
          EndIf
          
          If qAES::LoadCryptImage(#Image, "Test.jpg.aes", Key$)
            SaveImage(#Image, "DecryptedImage.jpg")
          EndIf
  
        CompilerEndIf
        
      CompilerCase 12
        
        CompilerIf  qAES::#Enable_LoadSaveCrypt
        
          #XML = 1
          
          NewList Shapes$()
          
          AddElement(Shapes$()): Shapes$() = "square"
          AddElement(Shapes$()): Shapes$() = "circle"
          AddElement(Shapes$()): Shapes$() = "triangle"
        
          If CreateXML(#XML)
            InsertXMLList(RootXMLNode(#XML), Shapes$())
            qAES::SaveCryptXML(#XML, "Shapes.xml", Key$)
            FreeXML(#XML)
          EndIf
          
          If qAES::LoadCryptXML(#XML, "Shapes.xml", Key$)
            Debug ComposeXML(#XML)
            FreeXML(#XML)
          EndIf
          
        CompilerEndIf
        
      CompilerCase 13
        
        CompilerIf  qAES::#Enable_LoadSaveCrypt
        
          #JSON = 1
          
          If CreateJSON(#JSON)
            Person.i = SetJSONObject(JSONValue(#JSON))
            SetJSONString(AddJSONMember(Person, "FirstName"), "John")
            SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
            SetJSONInteger(AddJSONMember(Person, "Age"), 42)
            qAES::SaveCryptJSON(#JSON, "Person.json", Key$)
            FreeJSON(#JSON)
          EndIf
          
          If qAES::LoadCryptJSON(#JSON, "Person.json", Key$)
            Debug ComposeJSON(#JSON, #PB_JSON_PrettyPrint)
            FreeJSON(#JSON)
          EndIf
          
        CompilerEndIf
        
      CompilerCase 14
        
        CompilerIf qAES::#Enable_CryptPacker
          
          UseZipPacker()
  
          #Pack = 1
          
          If CreatePack(#Pack, "TestPB.zip", #PB_PackerPlugin_Zip)
            
            qAES::AddCryptPackFile(#Pack, "Test.txt", Key$)
            
            ClosePack(#Pack) 
          EndIf
          
          If OpenPack(#Pack, "TestPB.zip", #PB_PackerPlugin_Zip)
            
            If qAES::IsCryptPackFile(#Pack, "Test.txt")
              Debug "Packed file is encrypted."
            Else
              Debug "Packed file is not encrypted."
            EndIf
            
            qAES::UncompressCryptPackFile(#Pack, "Encrypted.txt", Key$, "Test.txt")
            
            ClosePack(#Pack) 
          EndIf
        
        CompilerEndIf
        
      CompilerCase 15
        
        CompilerIf qAES::#Enable_CryptPacker
          
          UseZipPacker()
  
          #Pack = 1
          #XML  = 1
          
          NewList Shapes$()
          
          AddElement(Shapes$()): Shapes$() = "square"
          AddElement(Shapes$()): Shapes$() = "circle"
          AddElement(Shapes$()): Shapes$() = "triangle"
        
          If CreateXML(#XML)
            InsertXMLList(RootXMLNode(#XML), Shapes$())
            
            If CreatePack(#Pack, "TestXML.zip", #PB_PackerPlugin_Zip)
              
              qAES::AddCryptPackXML(#Pack, #XML, Key$, "Shapes.xml")
              
              ClosePack(#Pack) 
            EndIf
  
            FreeXML(#XML)
          EndIf
          
          If OpenPack(#Pack, "TestXML.zip", #PB_PackerPlugin_Zip)
            
            If qAES::UncompressCryptPackXML(#Pack, #XML, Key$, "Shapes.xml")
              Debug ComposeXML(#XML)
              FreeXML(#XML)
            EndIf
            
            ClosePack(#Pack) 
          EndIf
          
        CompilerEndIf
        
      CompilerCase 16
        
        CompilerIf qAES::#Enable_CryptPacker
          
          UseZipPacker()
  
          #Pack = 1  
          #JSON = 1
          
          If CreateJSON(#JSON)
            
            Person.i = SetJSONObject(JSONValue(#JSON))
            SetJSONString(AddJSONMember(Person, "FirstName"), "John")
            SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
            SetJSONInteger(AddJSONMember(Person, "Age"), 42)
            
            If CreatePack(#Pack, "TestJSON.zip", #PB_PackerPlugin_Zip) 
              qAES::AddCryptPackJSON(#Pack, #JSON, Key$, "Person.json")
              ClosePack(#Pack) 
            EndIf
            
            FreeJSON(#JSON)
          EndIf
          
          If OpenPack(#Pack, "TestJSON.zip", #PB_PackerPlugin_Zip)
            
            If qAES::UncompressCryptPackJSON(#Pack, #JSON, Key$, "Person.json")
              Debug ComposeJSON(#JSON, #PB_JSON_PrettyPrint)
              FreeJSON(#JSON)
            EndIf
            
            ClosePack(#Pack) 
          EndIf
          
        CompilerEndIf
        
      CompilerCase 17
        
        CompilerIf qAES::#Enable_CryptPacker
          
          UseJPEGImageDecoder()
          UseZipPacker()  
  
          #Pack  = 1 
          
          If LoadImage(#Image, "Test.jpg")
            
            If CreatePack(#Pack, "TestImage.zip", #PB_PackerPlugin_Zip)
              qAES::AddCryptPackImage(#Pack, #Image, Key$, "Test.jpg")
              ClosePack(#Pack) 
            EndIf
          
          EndIf
          
          If OpenPack(#Pack, "TestImage.zip", #PB_PackerPlugin_Zip)
            
            If qAES::UncompressCryptPackImage(#Pack, #Image, Key$, "Test.jpg")
              SaveImage(#Image, "DecryptedImage.jpg")
            EndIf
            
            ClosePack(#Pack) 
          EndIf
  
        CompilerEndIf
        
      CompilerCase 18
        
        CompilerIf qAES::#Enable_SmartFileCoder
          
          Define Memory.qAES::Memory_Structure
          
          #JSON = 1
          
          If CreateJSON(#JSON)
            Person.i = SetJSONObject(JSONValue(#JSON))
            SetJSONString(AddJSONMember(Person, "FirstName"), "John")
            SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
            SetJSONInteger(AddJSONMember(Person, "Age"), 42)
            SaveJSON(#JSON, "Person.json")
            FreeJSON(#JSON)
          EndIf
          
          qAES::SmartFileCoder(qAES::#Protect, "Person.json", Key$)
          
          If qAES::ReadProtectedFile("Person.json", @Memory, Key$)
            If CatchJSON(#JSON, Memory\Buffer, Memory\Size)
              Debug ComposeJSON(#JSON, #PB_JSON_PrettyPrint)
              FreeJSON(#JSON)
            EndIf
            FreeMemory(Memory\Buffer)
          EndIf
          
        CompilerEndIf
        
      CompilerEndSelect

    CloseWindow(#Window)
  EndIf
  
CompilerEndIf
