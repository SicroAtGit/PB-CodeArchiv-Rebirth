;   Description: Modul to send and receive arrays
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=65988
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29690
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 mk-soft
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

; Comment: NetworkArray
; Author : mk-soft
; Version: v1.091
; Created: 12.06.2016
; Updated: 02.07.2016
; Link De: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29690
; Link En: http://www.purebasic.fr/english/viewtopic.php?f=12&t=65988

; ***************************************************************************************

;- Begin Declare Module

CompilerIf #PB_Compiler_Thread = 0
  CompilerError "Use Compileroption Threadsafe!"
CompilerEndIf

DeclareModule NetworkArray

  Enumeration 1
    #NetStringArray
    #NetByteArray
    #NetIntegerArray
    #NetLongArray
    #NetFloatArray
    #NetDoubleArray
    #NetRawData
  EndEnumeration

  Structure udtAny
    StructureUnion
      bVal.b[0]
      wVal.w[0]
      iVal.i[0]
      lVal.l[0]
      fVal.f[0]
      dVal.d[0]
    EndStructureUnion
  EndStructure

  Structure udtDataset
    DataID.i
    Type.i
    Array Text.s(0)
    Array Byte.b(0)
    Array Integer.i(0)
    Array Long.l(0)
    Array Float.f(0)
    Array Double.d(0)
    *RawData.udtAny
  EndStructure

  Declare BindLogging(Event, Gadget)
  Declare UnBindLogging(Event, Gadget)
  Declare Logging(Info.s)

  Declare InitServer(Port, *NewDataCallback = 0, BindedIP.s = "")
  Declare CloseServer(ServerID)
  Declare InitClient(IP.s, Port, *NewDataCallback = 0, Timeout = 0)
  Declare CloseClient(ConnectionID)
  Declare SetServerNewDataCB(ServerID, *NewDataCallback)
  Declare SetClientNewDataCB(ConnectionID, *NewDataCallback)
  Declare NetSendStringArray(ConnectionID, DataID, Array SendData.s(1))
  Declare NetSendByteArray(ConnectionID, DataID, Array SendData.b(1))
  Declare NetSendIntegerArray(ConnectionID, DataID, Array SendData.i(1))
  Declare NetSendLongArray(ConnectionID, DataID, Array SendData.l(1))
  Declare NetSendFloatArray(ConnectionID, DataID, Array SendData.f(1))
  Declare NetSendDoubleArray(ConnectionID, DataID, Array SendData.d(1))
  Declare NetSendRawData(ConnectionID, DataID, *Data.udtAny, SizeOfData)

EndDeclareModule

;- Begin Module

Module NetworkArray

  EnableExplicit

  Global ProtocolID.l = $EFAA2016

  ; -----------------------------------------------------------------------------------

  Prototype ProtoNewDataCB(SEvent, ConnectionID, *NewData.udtDataset)

  ; -----------------------------------------------------------------------------------

  ; Size of blockdata without header
  #BlockSizeData = 1024
  #BlockSizeText = 60002

  Structure udtServerList
    ServerID.i
    ThreadID.i
    NewDataCB.ProtoNewDataCB
    ExitServer.i
  EndStructure

  Structure udtClientList
    ConnectionID.i
    ThreadID.i
    NewDataCB.ProtoNewDataCB
    ExitClient.i
  EndStructure

  Structure udtDataBlock
    ProtocolID.l
    Datalen.l
    DataID.l
    State.w
    Type.w
    Size.l
    Index.l
    Count.l
    pData.udtAny
  EndStructure

  Structure udtBuffer
    b.b[$FFFF]
  EndStructure

  Structure udtNetData
    Map Dataset.udtDataset()
    ConnectionID.i
    DataOffset.i
    Datalen.i
    StructureUnion
      Receive.udtDataBlock
      Buffer.udtBuffer
    EndStructureUnion
  EndStructure

  Structure udtSendBuffer
    StructureUnion
      Send.udtDataBlock
      Buffer.udtBuffer
    EndStructureUnion
  EndStructure

  ; -----------------------------------------------------------------------------------

  Global LoggingEvent
  Global LoggingGadget

  Global LockSend

  Threaded NewMap NetData.udtNetData()
  Threaded ReceiveBuffer.udtBuffer
  Threaded SendBuffer.udtSendBuffer

  ; -----------------------------------------------------------------------------------

  Global NewMap ServerList.udtServerList()
  Global NewMap ClientList.udtClientList()

  ; -----------------------------------------------------------------------------------

  InitNetwork()
  LockSend = CreateMutex()

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

  Procedure BindLogging(Event, Gadget)
    BindEvent(Event, @AddLoggingItem(), 0, Gadget)
    LoggingEvent = Event
    LoggingGadget = Gadget
  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure UnbindLogging(Event, Gadget)
    UnbindEvent(Event, @AddLoggingItem(), 0, Gadget)
    LoggingEvent = 0
    LoggingGadget = 0
  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure InitServer(Port, *NewDataCallback = 0, BindedIP.s = "")
    Protected ServerID, keyServerID.s

    ServerID = CreateNetworkServer(#PB_Any, Port, #PB_Network_TCP, BindedIP)
    If ServerID
      keyServerID = Str(ServerID)
      AddMapElement(ServerList(), keyServerID)
      ServerList()\ServerID = ServerID
      ServerList()\NewDataCB = *NewDataCallback
      ServerList()\ThreadID = CreateThread(@ThreadServer(), @ServerList())
      Logging("Network: Init Server: ID " + Str(ServerID))
    Else
      Logging("Network: Error Init Network Server")
    EndIf
    ProcedureReturn ServerID
  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure CloseServer(ServerID)
    Protected keyServerID.s, count

    keyServerID = Str(ServerID)
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
      keyConnectionID = Str(ConnectionID)
      AddMapElement(ClientList(), keyConnectionID)
      ClientList()\ConnectionID = ConnectionID
      ClientList()\NewDataCB = *NewDataCallback
      ClientList()\ThreadID = CreateThread(@ThreadClient(), @ClientList())
      Logging("Network: Init Network Connection: ID " + Str(ConnectionID))
    Else
      Logging("Network: Error Init Network Connection")
    EndIf
    ProcedureReturn ConnectionID
  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure SetServerNewDataCB(ServerID, *NewDataCallback)
    Protected keyServerID.s

    keyServerID = Str(ServerID)
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

    keyConnectionID = Str(ConnectionID)
    If FindMapElement(ClientList(), keyConnectionID)
      ClientList()\NewDataCB = *NewDataCallback
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure CloseClient(ConnectionID)
    Protected keyConnectionID.s, count

    keyConnectionID = Str(ConnectionID)
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

  ; Bugfix MacOS PB v5.42 X64 (DIM) Not use Select Case

  Procedure DimDataset(Map Dataset.udtDataset(), Type, Size)
    Protected result

    With Dataset()
      If Type = #NetStringArray
        Dim \Text(Size)
        result = ArraySize(\Text())
      ElseIf Type = #NetByteArray
        Dim \Byte(Size)
        result = ArraySize(\Byte())
      ElseIf Type = #NetIntegerArray
        Dim \Integer(Size)
        result = ArraySize(\Integer())
      ElseIf Type = #NetLongArray
        Dim \Long(Size)
        result = ArraySize(\Long())
      ElseIf Type = #NetFloatArray
        Dim \Float(Size)
        result = ArraySize(\Float())
      ElseIf Type = #NetDoubleArray
        Dim \Double(Size)
        result = ArraySize(\Double())
      ElseIf Type = #NetRawData
        If \RawData
          FreeMemory(\RawData)
        EndIf
        \RawData = AllocateMemory(Size)
        If \RawData
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      EndIf
      If result >= 0
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    EndWith

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure FreeDataset(Map Dataset.udtDataset())
    With Dataset()
      \DataID = 0
      \Type = 0
      FreeArray(\Text())
      FreeArray(\Byte())
      FreeArray(\Integer())
      FreeArray(\Long())
      FreeArray(\Float())
      FreeArray(\Double())
      If \RawData
        FreeMemory(\RawData)
        \RawData = 0
      EndIf
    EndWith
  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendStringArray(ConnectionID, DataID, Array SendData.s(1))
    Protected count, len, index

    LockMutex(LockSend)

    With SendBuffer\Send
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetStringArray
      \Size = ArraySize(SendData())
      \Count = 1
      For index = 0 To \Size
        If index >= \Size
          \State + 2
        EndIf
        \Index = index
        \Datalen = SizeOf(udtDataBlock) + Len(Senddata(index)) * SizeOf(character) + SizeOf(character)
        PokeS(\pData, Senddata(index))
        count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
        If count <> \Datalen
          Logging("Network: Error SendStringArray: DataID " + Str(\DataID))
          UnlockMutex(LockSend)
          ProcedureReturn 0
        EndIf
        If \State
          \State = 0
        EndIf
      Next

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendByteArray(ConnectionID, DataID, Array SendData.b(1))
    Protected count, len, size, index, ofs

    LockMutex(LockSend)

    With SendBuffer\Send
      size = ArraySize(SendData())
      index = 0
      ofs = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetByteArray
      \Size = size
      \Index = 0
      \Count = 1
      Repeat
        \pData\bVal[ofs] = SendData(index)
        index + 1
        ofs + 1
        If ofs = #BlockSizeData Or index > size
          If index > size
            \State + 2
          EndIf
          \Count = ofs
          \Datalen = SizeOf(udtDataBlock) + SizeOf(byte) * ofs
          count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
          If count <> \Datalen
            Logging("Network: Error SendByteArray: DataID " + Str(\DataID))
            UnlockMutex(LockSend)
            ProcedureReturn 0
          EndIf
          \Index + ofs
          \State = 0
          ofs = 0
        EndIf
      Until index > size

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendIntegerArray(ConnectionID, DataID, Array SendData.i(1))
    Protected count, len, size, index, ofs

    LockMutex(LockSend)

    With SendBuffer\Send
      size = ArraySize(SendData())
      index = 0
      ofs = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetIntegerArray
      \Size = size
      \Index = 0
      \Count = 1
      Repeat
        \pData\iVal[ofs] = SendData(index)
        index + 1
        ofs + 1
        If ofs = #BlockSizeData / SizeOf(integer) Or index > size
          If index > size
            \State + 2
          EndIf
          \Count = ofs
          \Datalen = SizeOf(udtDataBlock) + SizeOf(integer) * ofs
          count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
          If count <> \Datalen
            Logging("Network: Error SendIntegerArray: DataID " + Str(\DataID))
            UnlockMutex(LockSend)
            ProcedureReturn 0
          EndIf
          \Index + ofs
          \State = 0
          ofs = 0
        EndIf
      Until index > size

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendLongArray(ConnectionID, DataID, Array SendData.l(1))
    Protected count, len, size, index, ofs

    LockMutex(LockSend)

    With SendBuffer\Send
      size = ArraySize(SendData())
      index = 0
      ofs = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetLongArray
      \Size = size
      \Index = 0
      \Count = 1
      Repeat
        \pData\lVal[ofs] = SendData(index)
        index + 1
        ofs + 1
        If ofs = #BlockSizeData / SizeOf(long) Or index > size
          If index > size
            \State + 2
          EndIf
          \Count = ofs
          \Datalen = SizeOf(udtDataBlock) + SizeOf(long) * ofs
          count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
          If count <> \Datalen
            Logging("Network: Error SendIntegerArray: DataID " + Str(\DataID))
            UnlockMutex(LockSend)
            ProcedureReturn 0
          EndIf
          \Index + ofs
          \State = 0
          ofs = 0
        EndIf
      Until index > size

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendFloatArray(ConnectionID, DataID, Array SendData.f(1))
    Protected count, len, size, index, ofs

    LockMutex(LockSend)

    With SendBuffer\Send
      size = ArraySize(SendData())
      index = 0
      ofs = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetFloatArray
      \Size = size
      \Index = 0
      \Count = 1
      Repeat
        \pData\fVal[ofs] = SendData(index)
        index + 1
        ofs + 1
        If ofs = #BlockSizeData / SizeOf(float) Or index > size
          If index > size
            \State + 2
          EndIf
          \Count = ofs
          \Datalen = SizeOf(udtDataBlock) + SizeOf(float) * ofs
          count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
          If count <> \Datalen
            Logging("Network: Error SendIntegerArray: DataID " + Str(\DataID))
            UnlockMutex(LockSend)
            ProcedureReturn 0
          EndIf
          \Index + ofs
          \State = 0
          ofs = 0
        EndIf
      Until index > size

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendDoubleArray(ConnectionID, DataID, Array SendData.d(1))
    Protected count, len, size, index, ofs

    LockMutex(LockSend)

    With SendBuffer\Send
      size = ArraySize(SendData())
      index = 0
      ofs = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetDoubleArray
      \Size = size
      \Index = 0
      \Count = 1
      Repeat
        \pData\dVal[ofs] = SendData(index)
        index + 1
        ofs + 1
        If ofs = #BlockSizeData / SizeOf(double) Or index > size
          If index > size
            \State + 2
          EndIf
          \Count = ofs
          \Datalen = SizeOf(udtDataBlock) + SizeOf(double) * ofs
          count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
          If count <> \Datalen
            Logging("Network: Error SendIntegerArray: DataID " + Str(\DataID))
            UnlockMutex(LockSend)
            ProcedureReturn 0
          EndIf
          \Index + ofs
          \State = 0
          ofs = 0
        EndIf
      Until index > size

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetSendRawData(ConnectionID, DataID, *Data.udtAny, SizeOfData)
    Protected count, len, size, index, ofs

    LockMutex(LockSend)

    With SendBuffer\Send
      size = SizeOfData
      index = 0
      ofs = 0
      \ProtocolID = ProtocolID
      \DataID = DataID
      \State = 1
      \Type = #NetRawData
      \Size = size
      \Index = 0
      \Count = 1
      Repeat
        \pData\bVal[ofs] = *Data\bVal[index]
        index + 1
        ofs + 1
        If ofs = #BlockSizeData Or index > size
          If index > size
            \State + 2
          EndIf
          \Count = ofs
          \Datalen = SizeOf(udtDataBlock) + SizeOf(byte) * ofs
          count = SendNetworkData(ConnectionID, SendBuffer, \Datalen)
          If count <> \Datalen
            Logging("Network: Error SendRawData: DataID " + Str(\DataID))
            UnlockMutex(LockSend)
            ProcedureReturn 0
          EndIf
          \Index + ofs
          \State = 0
          ofs = 0
        EndIf
      Until index > size

    EndWith

    UnlockMutex(LockSend)

    ProcedureReturn 1

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure NetReceiveData(ConnectionID, *NewDataCB.ProtoNewDataCB)
    Protected count, size, ofs, len, index, lbound, ubound, error, keyConnectionID.s, keyData.s

    ; Set or Create NetData
    keyConnectionID = Str(ConnectionID)
    If Not FindMapElement(NetData(), keyConnectionID)
      AddMapElement(NetData(), keyConnectionID)
      NetData()\ConnectionID = ConnectionID
      NetData()\DataOffset = 0
      NetData()\Datalen = 0
    EndIf

    error = #False

    Repeat
      With NetData()
        ; Read header
        If \DataOffset < SizeOf(udtDataBlock)
          count = ReceiveNetworkData(ConnectionID, ReceiveBuffer, SizeOf(udtDataBlock) - \DataOffset)
          If count <= 0
            Logging("Network: Error Receive Data: ID " + keyConnectionID)
            Break
          EndIf
          CopyMemory(ReceiveBuffer, \Receive + \DataOffset, count)
          \DataOffset + count
          If \DataOffset < SizeOf(udtDataBlock)
            Break
          Else
            ; Check header
            If \Receive\ProtocolID <> ProtocolID
              Logging("Network: Error ProtocolID: ID " + keyConnectionID)
              error = #True
              Break
            EndIf
            \Datalen = \Receive\Datalen
            If \Receive\Type = #NetStringArray
              If \Datalen > #BlockSizeText + SizeOf(udtDataBlock)
                Logging("Network: Error Datalen: ID " + keyConnectionID)
                error = #True
                Break
              EndIf
            Else
              If \Datalen > #BlockSizeData + SizeOf(udtDataBlock)
                Logging("Network: Error Datalen: ID " + keyConnectionID)
                error = #True
                Break
              EndIf
            EndIf
          EndIf
          Break
        EndIf
        ; Read data
        count = ReceiveNetworkData(ConnectionID, ReceiveBuffer, \Datalen - \DataOffset)
        If count <= 0
          Logging("Network: Error Receive Data: ID " + keyConnectionID)
          Break
        EndIf
        CopyMemory(ReceiveBuffer, \Receive + \DataOffset, count)
        \DataOffset + count
        If \DataOffset < \Datalen
          Break
        EndIf
        \DataOffset = 0
        \Datalen = 0
      EndWith

      ; Daten auswerten
      With NetData()\Receive
        ; Set or Create Dataset over DataID
        keyData = Str(\DataID)
        If Not FindMapElement(NetData()\Dataset(), keyData)
          If Not AddMapElement(NetData()\Dataset(), keyData)
            Logging("Network: Error Out of memory")
            error = #True
            Break
          EndIf
        EndIf
        ; Check first Datablock
        If \State & 1
          If Not DimDataset(NetData()\Dataset(), \Type, \Size)
            Logging("Network: Error Out of memory")
            error = #True
            Break
          EndIf
          NetData()\Dataset()\DataID = \DataID
          NetData()\Dataset()\Type = \Type
        EndIf

        Select \Type
          Case #NetStringArray
            NetData()\Dataset()\Text(\Index) = PeekS(\pData)

          Case #NetByteArray
            lbound = \Index
            ubound = \Index + \Count - 1
            ofs = 0
            For index = lbound To ubound
              NetData()\Dataset()\Byte(index) = \pData\bVal[ofs]
              ofs + 1
            Next

          Case #NetIntegerArray
            lbound = \Index
            ubound = \Index + \Count - 1
            ofs = 0
            For index = lbound To ubound
              NetData()\Dataset()\Integer(index) = \pData\iVal[ofs]
              ofs + 1
            Next

          Case #NetLongArray
            lbound = \Index
            ubound = \Index + \Count - 1
            ofs = 0
            For index = lbound To ubound
              NetData()\Dataset()\Long(index) = \pData\lVal[ofs]
              ofs + 1
            Next

          Case #NetFloatArray
            lbound = \Index
            ubound = \Index + \Count - 1
            ofs = 0
            For index = lbound To ubound
              NetData()\Dataset()\Float(index) = \pData\fVal[ofs]
              ofs + 1
            Next

          Case #NetDoubleArray
            lbound = \Index
            ubound = \Index + \Count - 1
            ofs = 0
            For index = lbound To ubound
              NetData()\Dataset()\Double(index) = \pData\dVal[ofs]
              ofs + 1
            Next

          Case #NetRawData
            lbound = \Index
            ubound = \Index + \Count - 1
            ofs = 0
            For index = lbound To ubound
              NetData()\Dataset()\RawData\bVal[index] = \pData\bVal[ofs]
              ofs + 1
            Next

        EndSelect
        ; Check last Datablock
        If \State & 2
          If *NewDataCB
            If *NewDataCB(#PB_NetworkEvent_Data, ConnectionID, @NetData()\Dataset())
              FreeDataset(NetData()\Dataset())
              DeleteMapElement(NetData()\Dataset())
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
      If FindMapElement(NetData(), keyConnectionID)
        ForEach NetData()\Dataset()
          FreeDataset(Netdata()\Dataset())
        Next
        DeleteMapElement(NetData(), keyConnectionID)
      EndIf
    EndIf

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure ThreadServer(*this.udtServerList)
    Protected Event, ConnectionID, keyConnectionID.s
    With *this
      Repeat
        Event = NetworkServerEvent(\ServerID)
        Select Event
          Case #PB_NetworkEvent_Connect
            ; Create NetData
            ConnectionID = EventClient()
            keyConnectionID = Str(ConnectionID)
            If Not FindMapElement(NetData(), keyConnectionID)
              AddMapElement(NetData(), keyConnectionID)
              NetData()\ConnectionID = ConnectionID
              NetData()\DataOffset = 0
              NetData()\Datalen = 0
            EndIf
            Logging("Network: Client connected: ID " + keyConnectionID)
            If \NewDataCB
              \NewDataCB(#PB_NetworkEvent_Connect, ConnectionID, 0)
            EndIf

          Case #PB_NetworkEvent_Data
            NetReceiveData(EventClient(),\NewDataCB)

          Case #PB_NetworkEvent_Disconnect
            ; Destroy NetData
            ConnectionID = EventClient()
            keyConnectionID = Str(ConnectionID)
            Logging("Network: Client disconnected: ID " + keyConnectionID)
            If \NewDataCB
              \NewDataCB(#PB_NetworkEvent_Disconnect, ConnectionID, 0)
            EndIf
            If FindMapElement(NetData(), keyConnectionID)
              ForEach NetData()\Dataset()
                FreeDataset(Netdata()\Dataset())
              Next
              DeleteMapElement(NetData(), keyConnectionID)
            EndIf

          Default
            Delay(10)

        EndSelect

      Until \ExitServer
      ; Exit Thread
      \ExitServer = 0
    EndWith

  EndProcedure

  ; -----------------------------------------------------------------------------------

  Procedure ThreadClient(*this.udtClientList)
    Protected Event, keyConnectionID.s

    With *this
      ; Create NetData
      keyConnectionID = Str(\ConnectionID)
      If Not FindMapElement(NetData(), keyConnectionID)
        AddMapElement(NetData(), keyConnectionID)
        NetData()\ConnectionID = \ConnectionID
        NetData()\DataOffset = 0
        NetData()\Datalen = 0
      EndIf

      Repeat
        Event = NetworkClientEvent(\ConnectionID)
        Select Event
          Case #PB_NetworkEvent_Data
            NetReceiveData(\ConnectionID, \NewDataCB)

          Case #PB_NetworkEvent_Disconnect
            If \NewDataCB
              \NewDataCB(#PB_NetworkEvent_Disconnect, \ConnectionID, 0)
            EndIf
            Break

          Default
            Delay(10)

        EndSelect

      Until \ExitClient
      ; Destroy NetData
      If FindMapElement(NetData(), keyConnectionID)
        ForEach NetData()\Dataset()
          FreeDataset(Netdata()\Dataset())
        Next
        DeleteMapElement(NetData(), keyConnectionID)
      EndIf
      ; Exit Thread
      \ExitClient = 0
    EndWith

  EndProcedure

  ; -----------------------------------------------------------------------------------

EndModule

;- End Module


;-Example
CompilerIf #PB_Compiler_IsMainFile
CompilerEndIf
