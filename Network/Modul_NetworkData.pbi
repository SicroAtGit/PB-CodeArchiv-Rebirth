;   Description: Modul to send and receive datas per network
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=66075
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29743
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016-2017 mk-soft
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

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Thread-Safe is needed!"
CompilerEndIf

;-TOP

; Comment: NetworkData
; Author : mk-soft
; Version: v1.15
; Created: 03.07.2016
; Updated: 09.09.2017
; Link En: http://www.purebasic.fr/english/viewtopic.php?f=12&t=66075
; Link De:

; ***************************************************************************************

;- Begin Declare Module

CompilerIf #PB_Compiler_Thread = 0
  CompilerError "Use Compileroption Threadsafe!"
CompilerEndIf

DeclareModule NetworkData
 
  Enumeration 1 ; Type of data
    #NetInteger
    #NetString
    #NetData
    #NetList
    #NetFile
  EndEnumeration
 
  ; -----------------------------------------------------------------------------------
 
  Structure udtAny
    StructureUnion
      bVal.b[0]
      cVal.c[0]
      wVal.w[0]
      uVal.u[0]
      iVal.i[0]
      lVal.l[0]
      qVal.q[0]
      fVal.f[0]
      dVal.d[0]
    EndStructureUnion
  EndStructure
 
  Structure udtDataSet
    ; Header
    ConnectionID.i
    DataID.i
    Type.i
    ; User data
    Integer.i
    String.s
    Filename.s
    *Data.udtAny
    List Text.s()
  EndStructure
 
  ; -----------------------------------------------------------------------------------
 
  Declare BindLogging(EventCustomValue, ListviewGadget)
  Declare UnBindLogging(EventCustomValue, ListviewGadget)
  Declare Logging(Info.s)
 
  Declare InitServer(Port, *NewDataCallback = 0, BindedIP.s = "")
  Declare CloseServer(ServerID)
  Declare InitClient(IP.s, Port, *NewDataCallback = 0, Timeout = 0)
  Declare CloseClient(ConnectionID)
  Declare SetServerNewDataCB(ServerID, *NewDataCallback)
  Declare SetClientNewDataCB(ConnectionID, *NewDataCallback)
  Declare SendInteger(ConnectionID, DataID, Value.i)
  Declare SendString(ConnectionID, DataID, String.s)
  Declare SendData(ConnectionID, DataID, *Data.udtAny, SizeOfData)
  Declare SendList(ConnectionID, DataID, List Text.s())
  Declare SendFile(ConnectionID, DataID, Filename.s)
 
  Declare SetAESData(*AESDataKey, Bits=192)
 
  Declare SetUserData(ConnectionID, UserData)
  Declare GetUserData(ConnectionID)
 
  Declare CopyDataSet(*Source.udtDataSet, *Destination.udtDataSet)
  Declare ClearDataSet(*Data.udtDataSet)
  Declare SetDataFolder(Folder.s)
 
  ; -----------------------------------------------------------------------------------
 
EndDeclareModule

;- Begin Module

Module NetworkData
 
  EnableExplicit
 
  ; Level 0 : Standard
  ; Level 1 : File transfer
  ; Level 2 : Received datablocks
 
  DebugLevel 0
 
  Global ProtocolID.l = $FFEE2017
 
  Global *AESData, AESBits
 
  ; -----------------------------------------------------------------------------------
 
  Prototype ProtoNewDataCB(SEvent, ConnectionID, *NewData.udtDataSet)
 
  ; -----------------------------------------------------------------------------------
 
  ; Size of data without header
  #BlockSizeData = 1024
 
  Structure udtServerList
    ServerID.i
    ThreadID.i
    ExitServer.i
    NewDataCB.ProtoNewDataCB
  EndStructure
 
  Structure udtClientList
    ConnectionID.i
    ThreadID.i
    ExitClient.i
    NewDataCB.ProtoNewDataCB
  EndStructure
 
  Structure udtDataPacket
    ; Datablock validation
    OffsetString.q        ; Offset of next string data
    OffsetData.q          ; Offset of next raw data
    OffsetList.q          ; Offset of next string data (List)
    OffsetFile.q          ; Offset of next file data
    FilePB.i              ; File ID (#PB_any)
    ; Receive dataset
    User.udtDataSet       ; Receive dataset
  EndStructure
   
  Structure udtDataBlock
    ProtocolID.l          ; Protocol Ident; For check of valid datablock
    Datalen.l             ; Len of datablock
    DataID.l              ; User data ident
    State.w               ; State of datablock; 1 First datablock, 2 Last datablock
    Type.w                ; Type of data
    Size.q                ; Size of complete data
    Offset.q              ; Offset of data
    Count.l               ; Bytecount of data
    pData.udtAny          ; Data
  EndStructure
 
  Structure udtBufferS
    b.b[2048]             ; Defined size of send buffer
  EndStructure
 
  Structure udtBufferR
    b.b[65535]            ; Defined size of receive buffer
  EndStructure
 
  Structure udtSendBuffer
    StructureUnion
      Send.udtDataBlock
      Buffer.udtBufferS
    EndStructureUnion
  EndStructure
 
  Structure udtReceiveBuffer
      Buffer.udtBufferR
  EndStructure
 
  Structure udtDataConnection
    Map DataPacket.udtDataPacket()
    ConnectionID.i          ; Connection Ident
    UserData.i              ; Userdata buffer
    DataOffset.i            ; Offset of receive datablock
    Datalen.i               ; Size of receive datablock
    StructureUnion
      Receive.udtDataBlock  ; Complete receive datablock
      Buffer.udtBufferR     ; Complete sen datablock
    EndStructureUnion
  EndStructure
 
  Structure udtAESBuffer
    bVal.b[#BlockSizeData]
  EndStructure
 
  ; -----------------------------------------------------------------------------------
 
  Global LoggingEvent
  Global LoggingGadget
 
  Global LockSend
  Global LockAES
 
  ;Global NewMap DataConnection.udtDataConnection() ; Change only for debugging with one server
  Threaded NewMap DataConnection.udtDataConnection()
  Threaded ReceiveBuffer.udtReceiveBuffer
  Threaded SendBuffer.udtSendBuffer
 
  Threaded AESBuffer.udtAESBuffer
 
  ; -----------------------------------------------------------------------------------
 
  Global NewMap ServerList.udtServerList()
  Global NewMap ClientList.udtClientList()
 
  ; -----------------------------------------------------------------------------------
 
  Global DataFolder.s = GetTemporaryDirectory()
 
  ; -----------------------------------------------------------------------------------
 
  InitNetwork()
  LockSend = CreateMutex()
  LockAES = CreateMutex()
 
  ; -----------------------------------------------------------------------------------
 
  Declare ThreadServer(*this.udtServerList)
  Declare ThreadClient(*this.udtClientList)
 
  ; -----------------------------------------------------------------------------------
 
  Procedure Logging(Info.s)
    Protected text.s, *mem
    If LoggingEvent
      text = FormatDate("[%YYYY-%MM-%DD %HH:%II:%SS] ", Date()) + Info
      *mem = AllocateMemory(StringByteLength(text) + SizeOf(character))
      PokeS(*mem, text)
      PostEvent(LoggingEvent, 0, LoggingGadget, 0, *mem)
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure AddLoggingItem()
    Protected gadget, count, *mem
    gadget = EventGadget()
    *mem = EventData()
    If *mem
      If IsGadget(gadget)
        AddGadgetItem(gadget, -1, PeekS(*mem))
        count = CountGadgetItems(gadget)
        If count > 1000
          RemoveGadgetItem(gadget, 0)
          count - 1
        EndIf
        count - 1
        SetGadgetState(gadget, count)
        SetGadgetState(gadget, -1)
      EndIf
      FreeMemory(*mem)
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure BindLogging(EventCustomValue, ListViewGadget)
    BindEvent(EventCustomValue, @AddLoggingItem(), 0, ListviewGadget)
    LoggingEvent = EventCustomValue
    LoggingGadget = ListviewGadget
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure UnbindLogging(EventCustomValue, ListviewGadget)
    UnbindEvent(EventCustomValue, @AddLoggingItem(), 0, ListviewGadget)
    LoggingEvent = 0
    LoggingGadget = 0
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure InitServer(Port, *NewDataCallback = 0, BindedIP.s = "")
    Protected ServerID, keyServerID.s
   
    ServerID = CreateNetworkServer(#PB_Any, Port, #PB_Network_TCP, BindedIP)
    If ServerID
      keyServerID = Hex(ServerID)
      AddMapElement(ServerList(), keyServerID)
      ServerList()\ServerID = ServerID
      ServerList()\NewDataCB = *NewDataCallback
      ServerList()\ThreadID = CreateThread(@ThreadServer(), @ServerList())
      Logging("Network: Init Server: ID " + Hex(ServerID))
    Else
      Logging("Network: Error Init Network Server")
    EndIf
    ProcedureReturn ServerID
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure CloseServer(ServerID)
    Protected keyServerID.s, count
   
    keyServerID = Hex(ServerID)
    If FindMapElement(ServerList(), keyServerID)
      Logging("Network: Close Network Server: ID " + keyServerID)
      CloseNetworkServer(ServerID)
      ServerList()\ExitServer = 1
      Repeat
        If ServerList()\ExitServer = 0
          Break
        Else
          count + 1
          If count >= 10
            KillThread(ServerList()\ThreadID)
            Logging("Network: Error - Kill Network Server: ID " + keyServerID)
            Break
          EndIf
        EndIf
        Delay(100)
      ForEver
      DeleteMapElement(ServerList(), keyServerID)
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure InitClient(IP.s, Port, *NewDataCallback = 0, Timeout = 0)
    Protected ConnectionID, keyConnectionID.s
   
    ConnectionID = OpenNetworkConnection(IP, Port, #PB_Network_TCP, Timeout)
    If ConnectionID
      keyConnectionID = Hex(ConnectionID)
      AddMapElement(ClientList(), keyConnectionID)
      ClientList()\ConnectionID = ConnectionID
      ClientList()\NewDataCB = *NewDataCallback
      ClientList()\ThreadID = CreateThread(@ThreadClient(), @ClientList())
      Logging("Network: Init Network Connection: ID " + Hex(ConnectionID))
    Else
      Logging("Network: Error Init Network Connection")
    EndIf
    ProcedureReturn ConnectionID
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure CloseClient(ConnectionID)
    Protected keyConnectionID.s, count
   
    keyConnectionID = Hex(ConnectionID)
    If FindMapElement(ClientList(), keyConnectionID)
      Logging("Network: Close Network Client: ID " + keyConnectionID)
      CloseNetworkConnection(ConnectionID)
      ClientList()\ExitClient = 1
      Repeat
        If ClientList()\ExitClient = 0
          Break
        Else
          count + 1
          If count >= 10
            KillThread(ClientList()\ThreadID)
            Logging("Network: Error - Kill Network Client: ID " + keyConnectionID)
            Break
          EndIf
        EndIf
        Delay(100)
      ForEver
      DeleteMapElement(ClientList(), keyConnectionID)
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SetServerNewDataCB(ServerID, *NewDataCallback)
    Protected keyServerID.s
   
    keyServerID = Hex(ServerID)
    If FindMapElement(ServerList(), keyServerID)
      ServerList()\NewDataCB = *NewDataCallback
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SetClientNewDataCB(ConnectionID, *NewDataCallback)
    Protected keyConnectionID.s
   
    keyConnectionID = Hex(ConnectionID)
    If FindMapElement(ClientList(), keyConnectionID)
      ClientList()\NewDataCB = *NewDataCallback
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure InitDataPacket(Map DataPacket.udtDataPacket(), Type, Size)
    Protected result
   
    With DataPacket()
      Select type
        Case #NetInteger
          \User\Integer = 0
          ProcedureReturn #True
         
        Case #NetString
          \User\String = Space(Size / SizeOf(character))
          \OffsetString = 0
          ProcedureReturn #True
         
        Case #NetData
          If \User\Data
            FreeMemory(\User\Data)
          EndIf
          \User\Data = AllocateMemory(Size)
          \OffsetData = 0
          If \User\Data
            ProcedureReturn #True
          Else
            ProcedureReturn #False
          EndIf
         
        Case #NetList
          AddElement(\User\Text())
          \OffsetList = 0
          ProcedureReturn #True
         
        Case #NetFile
          \OffsetFile = 0
          \User\Filename = DataFolder + \User\ConnectionID + "-" + \User\DataID + "-" + Date() + ".dat"
          \FilePB = CreateFile(#PB_Any, \User\Filename)
          If \FilePB
            Debug ("Network; Level 1; ConnectionID " + \User\ConnectionID + "; DataID " + \User\DataID + "; New File: " + \User\Filename), 1
            ProcedureReturn #True
          Else
            Logging("Network: Error - CreateFile: " + \User\Filename)
            ProcedureReturn #False
          EndIf
         
        Default
          ProcedureReturn #False
         
      EndSelect
    EndWith
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure ClearDataPacket(Map DataPacket.udtDataPacket())
    With DataPacket()
      \User\DataID = 0
      \User\Type = 0
      \User\Integer = 0
      \User\String = #Null$
      \User\Filename = #Null$
      If \User\Data
        FreeMemory(\User\Data)
        \User\Data = 0
      EndIf
      ClearList(\User\Text())
      If \FilePB
        If IsFile(\FilePB)
          CloseFile(\FilePB)
        EndIf
        \FilePB = 0
      EndIf
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure NetworkDecoder(*Data.udtDataBlock)
    Protected *pData, *pVector, count
    *pData = *Data + OffsetOf(udtDataBlock\pData)
    *pVector = *Data + OffsetOf(udtDataBlock\Size)
    count = *Data\Count
    If count > 16
      CopyMemory(*pData , AESBuffer, count)
      AESDecoder(AESBuffer, *pData , count, *AESData, AESBits, *pVector, #PB_Cipher_CBC)
    Else
      *Data\pData\qVal[0] ! PeekQ(*AESData)
      *Data\pData\qVal[1] ! PeekQ(*AESData + 8)
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure NetworkEncoder(*Data.udtDataBlock)
    Protected *pData, *pVector, count
    *pData = *Data + OffsetOf(udtDataBlock\pData)
    *pVector = *Data + OffsetOf(udtDataBlock\Size)
    count = *Data\Count
    If count > 16
      CopyMemory(*pData , AESBuffer, count)
      AESEncoder(AESBuffer, *pData , count, *AESData, AESBits, *pVector, #PB_Cipher_CBC)
    Else
      *Data\pData\qVal[0] ! PeekQ(*AESData)
      *Data\pData\qVal[1] ! PeekQ(*AESData + 8)
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendInteger(ConnectionID, DataID, Value.i)
    Protected count
   
    With SendBuffer\Send
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 3
      \Type = #NetInteger
      \Size = SizeOf(quad)
      \Offset = 0
      \Count = SizeOf(quad)
      \pData\qVal[0] = Value ; Send allway as quad
      \Datalen = SizeOf(udtDataBlock) + SizeOf(quad)
      LockMutex(LockSend)
      If *AESData
          NetworkEncoder(SendBuffer)
      EndIf
      count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
      UnlockMutex(LockSend)
      If count <> \Datalen
        Logging("Network: Error SendInteger: DataID " + Str(\DataID))
        ProcedureReturn 0
      EndIf
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendString(ConnectionID, DataID, String.s)
    Protected count.i, size.q, index.q, len.i, *data
   
    *data = @String
   
    With SendBuffer\Send
      size = StringByteLength(String) + SizeOf(character)
      index = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetString
      \Size = size
      \Offset = 0
      \Count = 0
      Repeat
        If index + #BlockSizeData > size
          len = size - index
        Else
          len = #BlockSizeData
        EndIf
        CopyMemory(*data, \pData, len)
        *data + len
        index + len
        If index >= size
          \State + 2
        EndIf
        \Count = len
        \Datalen = SizeOf(udtDataBlock) + len
        LockMutex(LockSend)
        If *AESData
          NetworkEncoder(SendBuffer)
        EndIf
        count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
        UnlockMutex(LockSend)
        If count <> \Datalen
          Logging("Network: Error SendString: DataID " + Str(\DataID))
          ProcedureReturn 0
        EndIf
        \Offset + len
        \State = 0
      Until index >= size
     
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendData(ConnectionID, DataID, *Data, SizeOfData)
    Protected count.i, size.q, index.q, len.i
   
    With SendBuffer\Send
      size = SizeOfData
      index = 0
      len = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetData
      \Size = size
      \Offset = 0
      \Count = 0
      Repeat
        If index + #BlockSizeData > size
          len = size - index
        Else
          len = #BlockSizeData
        EndIf
        CopyMemory(*Data, \pData, len)
        *Data + len
        index + len
        If index >= size
          \State + 2
        EndIf
        \Count = len
        \Datalen = SizeOf(udtDataBlock) + len
        LockMutex(LockSend)
        If *AESData
          NetworkEncoder(SendBuffer)
        EndIf
        count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
        UnlockMutex(LockSend)
        If count <> \Datalen
          Logging("Network: Error SendString: DataID " + Str(\DataID))
          ProcedureReturn 0
        EndIf
        \Offset + len
        \State = 0
      Until index >= size
     
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendListPart(ConnectionID, DataID, String.s, Last)
    Protected count.i, size.q, index.q, len.i, *data
   
    *data = @String
   
    With SendBuffer\Send
      size = StringByteLength(String) + SizeOf(character)
      index = 0
      len = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetList
      \Size = size
      \Offset = 0
      \Count = 0
      Repeat
        If index + #BlockSizeData > size
          len = size - index
        Else
          len = #BlockSizeData
        EndIf
        CopyMemory(*data, \pData, len)
        *data + len
        index + len
        If index >= size And Last
          \State + 2
        EndIf
        \Count = len
        \Datalen = SizeOf(udtDataBlock) + len
        LockMutex(LockSend)
        If *AESData
          NetworkEncoder(SendBuffer)
        EndIf
        count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
        UnlockMutex(LockSend)
        If count <> \Datalen
          Logging("Network: Error SendList: DataID " + Str(\DataID))
          ProcedureReturn 0
        EndIf
        \Offset + len
        \State = 0
      Until index >= size
     
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendList(ConnectionID, DataID, List Text.s())
    Protected result.i, size.i, index.i, last.i
   
    size = ListSize(Text())
    index = 0
    last = #False
    ForEach Text()
      index + 1
      If index >= size
        last = #True
      EndIf
      result = SendListPart(ConnectionID, DataID, Text(), last)
      If Not result
        Break
      EndIf
    Next
   
    ProcedureReturn result
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SendFile(ConnectionID, DataID, Filename.s)
    Protected count.i, len.q, size.q, index.q, ofs.i, filePB.i
   
    size = FileSize(Filename)
    If size <= 0
      ProcedureReturn 0
    EndIf
    filePB = ReadFile(#PB_Any, Filename)
    If Not filePB
      ProcedureReturn 0
    EndIf
   
    With SendBuffer\Send
      index = 0
      len = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetFile
      \Size = size
      \Offset = 0
      \Count = 0
      Repeat
        len = ReadData(filePB, \pData, #BlockSizeData)
        index + len
        If index >= size
          \State + 2
        EndIf
        \Count = len
        \Datalen = SizeOf(udtDataBlock) + len
        LockMutex(LockSend)
        If *AESData
          NetworkEncoder(SendBuffer)
        EndIf
        count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
        UnlockMutex(LockSend)
        If count <> \Datalen
          Logging("Network: Error SendFile: DataID " + Str(\DataID))
          ProcedureReturn 0
        EndIf
        \Offset + len
        \State = 0
        len = 0
      Until index >= size
      CloseFile(filePB)
     
    EndWith
   
    ProcedureReturn 1
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure ReceiveData(ConnectionID, *NewDataCB.ProtoNewDataCB)
    Protected count.i, size.q, error.i, keyConnectionID.s, keyData.s, *data.udtAny
   
    ; Set or create DataConnection
    keyConnectionID = Hex(ConnectionID)
    If Not FindMapElement(DataConnection(), keyConnectionID)
      AddMapElement(DataConnection(), keyConnectionID)
      DataConnection()\ConnectionID = ConnectionID
      DataConnection()\DataOffset = 0
      DataConnection()\Datalen = 0
    EndIf
   
    error = #False
   
    Repeat
      With DataConnection()
        ; Read block header
        If \DataOffset < SizeOf(udtDataBlock)
          count = ReceiveNetworkData(ConnectionID, ReceiveBuffer, SizeOf(udtDataBlock) - \DataOffset)
          If count <= 0
            Logging("Network: Error - ReceiveNetworkData: ConnectionID " + keyConnectionID)
            Break
          EndIf
          CopyMemory(ReceiveBuffer, \Receive + \DataOffset, count)
          \DataOffset + count
          If \DataOffset < SizeOf(udtDataBlock)
            Break
          Else
            ; Check header
            If \Receive\ProtocolID <> ProtocolID
              Logging("Network: Error - ProtocolID: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            \Datalen = \Receive\Datalen
            If \Datalen > #BlockSizeData + SizeOf(udtDataBlock)
              Logging("Network: Error - Datalen: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
          EndIf 
          Break
        Else ; Read block data
          count = ReceiveNetworkData(ConnectionID, ReceiveBuffer, \Datalen - \DataOffset)
          If count <= 0
            Logging("Network: Error - ReceiveNetworkData : ConnectionID " + keyConnectionID)
            Break
          EndIf
          CopyMemory(ReceiveBuffer, \Receive + \DataOffset, count)
          \DataOffset + count
          If \DataOffset < \Datalen
            Break
          EndIf
          \DataOffset = 0
          \Datalen = 0
        EndIf
      EndWith
     
      ; Check Data
      With DataConnection()\Receive
        ; Set or Create DataPacket over DataID
        keyData = Str(\DataID)
        If Not FindMapElement(DataConnection()\DataPacket(), keyData)
          If (\State & 1) <> 1
            Logging("Network: Error - Missing first block: ConnectionID " + keyConnectionID)
            error = #True
            Break
          EndIf 
          If Not AddMapElement(DataConnection()\DataPacket(), keyData)
            Logging("Network: Error - Out of memory: ConnectionID " + keyConnectionID)
            error = #True
            Break
          EndIf
        EndIf
        ; Check first data block
        If \State & 1
          DataConnection()\DataPacket()\User\ConnectionID = ConnectionID
          DataConnection()\DataPacket()\User\DataID = \DataID
          DataConnection()\DataPacket()\User\Type = \Type
          If Not InitDataPacket(DataConnection()\DataPacket(), \Type, \Size)
            Logging("Network: Error - Init packet data: ConnectionID " + keyConnectionID)
            error = #True
            Break
          EndIf
        EndIf
       
        ; Debuglevel 2
        Debug ("Network; Level 2; ConnectionID " + keyConnectionID + "; DataID " + keyData + "; Type " + \Type + "; State " + \State + "; Offset " + \Offset + "; Count " + \Count) , 2
       
        If *AESData
          LockMutex(LockAES)
          NetworkDecoder(DataConnection()\Receive)
          UnlockMutex(LockAES)
        EndIf
           
        Select \Type
          Case #NetInteger
            DataConnection()\DataPacket()\User\Integer = \pData\iVal[0]
           
          Case #NetString
            ; Check valid index
            If \Offset <> DataConnection()\DataPacket()\OffsetString
              Logging("Network: Error - Invalid offset of string: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            *data = @DataConnection()\DataPacket()\User\String
            CopyMemory(\pData, *data + \Offset, \Count)
            DataConnection()\DataPacket()\OffsetString + \Count
           
          Case #NetData
            ; Check valid index
            If \Offset <> DataConnection()\DataPacket()\OffsetData
              Logging("Network: Error - Invalid offset of data: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            *data = DataConnection()\DataPacket()\User\Data
            ; Check valid size
            size = \Offset + \Count
            If size > MemorySize(*data)
              Logging("Network: Error - Invalid datasize of data: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            CopyMemory(\pData, *data + \Offset, \Count)
            DataConnection()\DataPacket()\OffsetData + \Count
           
          Case #NetList
            ; Check valid index
            If \Offset <> DataConnection()\DataPacket()\OffsetList
              Logging("Network: Error - Invalid offset of list: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            DataConnection()\DataPacket()\User\Text() + PeekS(\pData, \Count)
            DataConnection()\DataPacket()\OffsetList + \Count
           
          Case #NetFile
            ; Check valid file index
            If \Offset <> DataConnection()\DataPacket()\OffsetFile
              Logging("Network: Error - Invalid offset of file: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            *data = DataConnection()\DataPacket()\FilePB
            ; Check valid file
            If Not IsFile(*data)
              Logging("Network: Error - Invalid file: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            size = \Offset + \Count
            If \Offset <> Loc(*data)
              Logging("Network: Error - Invalid loc of file: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf
            If WriteData(*data, \pData, \Count) <> \Count
              Logging("Network: Error - Write data of file: ConnectionID " + keyConnectionID)
              error = #True
              Break
            EndIf 
            DataConnection()\DataPacket()\Offsetfile + \Count
            If \State & 2
              If IsFile(*data)
                CloseFile(*data)
                DataConnection()\DataPacket()\FilePB = 0
              EndIf
            EndIf
           
          Default
            Logging("Network: Error - Invalid datatype: ConnectionID " + keyConnectionID)
            error = #True
            Break
           
        EndSelect
        ; Check last data block
        If \State & 2
          If *NewDataCB
            If *NewDataCB(#PB_NetworkEvent_Data, ConnectionID, @DataConnection()\DataPacket()\User)
              ClearDataPacket(DataConnection()\DataPacket())
              DeleteMapElement(DataConnection()\DataPacket())
            EndIf
          EndIf
        EndIf
      EndWith
    Until #True
   
    ; On error delete connection and data
    If error
      CloseNetworkConnection(ConnectionID)
      If *NewDataCB
        *NewDataCB(#PB_NetworkEvent_Disconnect, ConnectionID, 0)
      EndIf
      If FindMapElement(DataConnection(), keyConnectionID)
        ForEach DataConnection()\DataPacket()
          ClearDataPacket(DataConnection()\DataPacket())
        Next
        DeleteMapElement(DataConnection(), keyConnectionID)
      EndIf
    EndIf
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure ThreadServer(*this.udtServerList)
    Protected Event, ConnectionID, keyConnectionID.s, count
    With *this
      Repeat
        Event = NetworkServerEvent(\ServerID)
        Select Event
          Case #PB_NetworkEvent_Connect
            ; Create DataConnection
            ConnectionID = EventClient()
            keyConnectionID = Hex(ConnectionID)
            If FindMapElement(DataConnection(), keyConnectionID)
              ForEach DataConnection()\DataPacket()
                ClearDataPacket(DataConnection()\DataPacket())
              Next
              DeleteMapElement(DataConnection(), keyConnectionID)
            Else
              AddMapElement(DataConnection(), keyConnectionID)
              DataConnection()\ConnectionID = ConnectionID
              DataConnection()\DataOffset = 0
              DataConnection()\Datalen = 0
              Logging("Network: Client connected: ID " + keyConnectionID)
            EndIf
            If \NewDataCB
              \NewDataCB(#PB_NetworkEvent_Connect, ConnectionID, 0)
            EndIf
           
          Case #PB_NetworkEvent_Data
            ReceiveData(EventClient(),\NewDataCB)
           
          Case #PB_NetworkEvent_Disconnect
            ; Destroy DataConnection
            ConnectionID = EventClient()
            keyConnectionID = Hex(ConnectionID)
            Logging("Network: Client disconnected: ID " + keyConnectionID)
            If \NewDataCB
              \NewDataCB(#PB_NetworkEvent_Disconnect, ConnectionID, 0)
            EndIf
            If FindMapElement(DataConnection(), keyConnectionID)
              ForEach DataConnection()\DataPacket()
                ClearDataPacket(DataConnection()\DataPacket())
              Next
              DeleteMapElement(DataConnection(), keyConnectionID)
            EndIf
           
          Default
            Delay(10)
           
        EndSelect
       
      Until \ExitServer
     
      ; Clear all DataConnection. We can delete all the data, because each server have their own DataConnection. DataConnection is threaded
      ForEach DataConnection()
        If \NewDataCB
          \NewDataCB(#PB_NetworkEvent_Disconnect, DataConnection()\ConnectionID, 0)
        EndIf
        ForEach DataConnection()\DataPacket()
          ClearDataPacket(DataConnection()\DataPacket())
        Next
        ClearMap(DataConnection()\DataPacket())
      Next
      ClearMap(DataConnection())
      ; Exit Thread
      \ExitServer = 0
    EndWith
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure ThreadClient(*this.udtClientList)
    Protected Event, keyConnectionID.s
   
    With *this
      ; Create DataConnection
      keyConnectionID = Hex(\ConnectionID)
      If Not FindMapElement(DataConnection(), keyConnectionID)
        AddMapElement(DataConnection(), keyConnectionID)
        DataConnection()\ConnectionID = \ConnectionID
        DataConnection()\DataOffset = 0
        DataConnection()\Datalen = 0
      EndIf
     
      Repeat
        Event = NetworkClientEvent(\ConnectionID)
        Select Event
          Case #PB_NetworkEvent_Data
            ReceiveData(\ConnectionID, \NewDataCB)
           
          Case #PB_NetworkEvent_Disconnect
            If \NewDataCB
              \NewDataCB(#PB_NetworkEvent_Disconnect, \ConnectionID, 0)
            EndIf
            Break
           
          Default
            Delay(10)
           
        EndSelect
       
      Until \ExitClient
      ; Destroy DataConnection
      If FindMapElement(DataConnection(), keyConnectionID)
        ForEach DataConnection()\DataPacket()
          ClearDataPacket(DataConnection()\DataPacket())
        Next
        DeleteMapElement(DataConnection(), keyConnectionID)
      EndIf
      ; Exit Thread
      \ExitClient = 0
    EndWith
   
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SetAESData(*AESDataKey, Bits=192)
    *AESData = *AESDataKey
    AESBits = Bits
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  ; Connection Userdata
 
  Procedure SetUserData(ConnectionID, UserData) ; Result old userdata
    Protected keyConnectionID.s, old_userdata
    keyConnectionID = Hex(ConnectionID)
    If FindMapElement(DataConnection(), keyConnectionID)
      old_userdata = DataConnection()\UserData
      DataConnection()\UserData = UserData
    EndIf
    ProcedureReturn old_userdata
  EndProcedure
     
  ; -----------------------------------------------------------------------------------
 
  Procedure GetUserData(ConnectionID) ; Result userdata
    Protected keyConnectionID.s, userdata
    keyConnectionID = Hex(ConnectionID)
    If FindMapElement(DataConnection(), keyConnectionID)
      userdata = DataConnection()\UserData
    EndIf
    ProcedureReturn userdata
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
  ; Dataset help functions
 
  Procedure CopyDataSet(*Source.udtDataSet, *Destination.udtDataSet)
    With *Destination
      \ConnectionID = *Source\ConnectionID
      \DataID = *Source\DataID
      \Type = *Source\Type
      \Integer = *Source\Integer
      \String = *Source\String
      If *Source\Data
        If \Data
          FreeMemory(\Data)
        EndIf
        \Data = AllocateMemory(MemorySize(*Source\Data))
        If \Data = 0
          ProcedureReturn #False
        EndIf
        CopyMemory(*Source\Data, \Data, MemorySize(*Source\Data))
      EndIf
      If CopyList(*Source\Text(), \Text()) = 0
        ProcedureReturn #False
      EndIf
      ProcedureReturn #True
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure ClearDataSet(*Data.udtDataSet)
    With *data
      ; ConnectionID, DataID not cleared
      \Type = 0
      \Integer = 0
      \String = #Null$
      \Filename = #Null$
      If \Data
        FreeMemory(\Data)
        \Data = 0
      EndIf
      ClearList(\Text())
    EndWith
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  Procedure SetDataFolder(Folder.s)
    If FileSize(Folder) = -2
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        If Right(Folder, 1) <> "\"
          DataFolder = Folder + "\"
        Else
          DataFolder = Folder
        EndIf
      CompilerElse
        If Right(Folder, 1) <> "/"
          DataFolder = Folder + "/"
        Else
          DataFolder = Folder
        EndIf
      CompilerEndIf
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
 
  ; -----------------------------------------------------------------------------------
 
  DebugLevel 0
 
EndModule

;- End Module

;-Example
CompilerIf #PB_Compiler_IsMainFile
CompilerEndIf
