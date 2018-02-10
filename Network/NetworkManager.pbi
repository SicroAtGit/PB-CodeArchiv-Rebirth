;   Description: For simple string, data and file transfer
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28989
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015-2016 Sicro
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

; Version: 1.0.3

DeclareModule NetworkManager
  
  EnableExplicit
  
  Enumeration DataType
    #DataType_DataHeader
    #DataType_String
    #DataType_Binary
    #DataType_File
  EndEnumeration
  
  Enumeration EventType
    #Event_DataHeaderReceived           
    #Event_DataHeaderReceivingInProgress
    #Event_DataHeaderReceivingTimeOut
    #Event_BinaryDataReceived
    #Event_BinaryDataReceivingInProgress
    #Event_BinaryDataReceivingTimeOut
    #Event_StringReceived
    #Event_StringReceivingInProgress
    #Event_StringReceivingTimeOut
    #Event_StringReceivingError
    #Event_ClientConnected
    #Event_ClientDisconnected
  EndEnumeration
  
  Declare.s GetDataTypeAsString(DataType.i)
  Declare.i CreateServer(Port.i, IPv6.i=#False, BindedIP.s="")
  Declare   CloseServer(Server.i)
  Declare.i OpenClient(ServerAdress.s, Port.i, IPv6.i=#False, TimeOut.i=60000, LocalIP.s="", LocalPort=0)
  Declare   CloseClient(Client.i)
  Declare.i ServerSendString(Server.i, Client.i, String.s)
  Declare.i ServerSendBinaryData(Server.i, Client.i, *Memory, MemorySize.i)
  Declare.i ServerSendFile(Server.i, Client.i, FilePath.s, FileName.s = "")
  Declare.i ClientSendString(Client.i, String.s)
  Declare.i ClientSendBinaryData(Client.i, *Memory, MemorySize.i)
  Declare.i ClientSendFile(Client.i, FilePath.s, FileName.s = "")
  Declare   ServerReceiveDataHandler(AddresseOfProcedure.i)
  Declare   ClientReceiveDataHandler(AddresseOfProcedure.i)
  Declare   FreeServerClientStringBuffer(Server.i, Client.i)
  Declare   FreeClientStringBuffer(Client.i)
  
EndDeclareModule

Module NetworkManager
  
  ; Interne Einstellungen
  #BufferSize       = 4*1024    ; 4 Kilobyte
  #StringBufferSize = 1024*1024 ; 1 Megabyte
  #SendTimeOut      = 30*1000   ; 30 Sekunden
  #ReceiveTimeOut   = 30*1000   ; 30 Sekunden
  
  InitNetwork()
  
  Structure DataHeader_Struc
    DataSize.q
    FileName.b[1000] ; FileName darf maximal 1000 Bytes lang sein, andernfalls wird abgeschnitten (Datei-Endung bleibt aber erhalten)
    DataType.b       ; muss am Ende der Struktur und ein Byte sein
  EndStructure
  
  Structure Client_Struc
    DataHeader.DataHeader_Struc
    *Buffer
    *StringBuffer ; Speicher wird erst bei String-Empfang allokiert und kann nach dem Empfang wieder freigegeben werden
    CountOfAllReceivedBytes.q
    LastSendTime.i
    LastReceiveTime.i
  EndStructure
  
  Structure Server_Struc
    Map Clients.Client_Struc()
  EndStructure
  
  Prototype ProtoServerCallback(EventServer.i, EventClient.i, Event.i, Param1.i=0, Param2.i=0, Param3.q=0, Param4.q=0, Param5.q=0)
  Prototype ProtoClientCallback(EventClient.i, Event.i, Param1.i=0, Param2.i=0, Param3.q=0, Param4.q=0, Param5.q=0)
  
  Global.Client_Struc NewMap Clients()
  Global.Server_Struc NewMap Servers()
  
  Procedure UpdateLastSendTime(Server.i, Client.i)
    
    If Server
      If FindMapElement(Servers(), Str(Server)) And FindMapElement(Servers()\Clients(), Str(Client))
        Servers()\Clients()\LastSendTime = ElapsedMilliseconds()
      EndIf
    Else
      If FindMapElement(Clients(), Str(Client))
        Clients()\LastSendTime = ElapsedMilliseconds()
      EndIf
    EndIf
    
  EndProcedure
  Procedure.i IsReachedSendTimeOut(Server.i, Client.i)
    
    If Server
      If FindMapElement(Servers(), Str(Server)) And FindMapElement(Servers()\Clients(), Str(Client))
        With Servers()\Clients()
          If ElapsedMilliseconds()-\LastSendTime >= #SendTimeOut
            ProcedureReturn #True
          EndIf
        EndWith
      EndIf
    Else
      If FindMapElement(Clients(), Str(Client)) And ElapsedMilliseconds()-Clients()\LastSendTime >= #SendTimeOut
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
    
  EndProcedure
  Procedure FreeServerClientStringBuffer(Server.i, Client.i)
    
    If FindMapElement(Servers(), Str(Server)) And FindMapElement(Servers()\Clients(), Str(Client))
      With Servers()\Clients()
        If \StringBuffer
          FreeMemory(\StringBuffer)
          \StringBuffer = 0
        EndIf
      EndWith
    EndIf
    
  EndProcedure
  Procedure FreeClientStringBuffer(Client.i)
    
    If FindMapElement(Clients(), Str(Client))
      With Clients()
        If \StringBuffer
          FreeMemory(\StringBuffer)
          \StringBuffer = 0
        EndIf
      EndWith
    EndIf
    
  EndProcedure
  Procedure.s GetDataTypeAsString(DataType.i)
    
    ProcedureReturn StringField("Datenkopf,String,Binärdaten,Datei", DataType+1, ",")
    
  EndProcedure
  Procedure.i CreateServer(Port.i, IPv6.i=#False, BindedIP.s="")
    
    Protected.i Server, Type
    
    Select IPv6
      Case #False : Type = #PB_Network_IPv4
      Case #True  : Type = #PB_Network_IPv6
    EndSelect
    
    Server = CreateNetworkServer(#PB_Any, Port, Type|#PB_Network_TCP, BindedIP)
    If Server = 0 : ProcedureReturn #False : EndIf
    
    If AddMapElement(Servers(), Str(Server))
      ProcedureReturn Server
    Else
      CloseNetworkServer(Server)
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  Procedure CloseServer(Server.i)
    
    If FindMapElement(Servers(), Str(Server))
      With Servers()
        ForEach \Clients()
          FreeMemory(\Clients()\Buffer)
          If \Clients()\StringBuffer
            FreeMemory(\Clients()\StringBuffer)
          EndIf
          CloseNetworkConnection(Val(MapKey(\Clients())))
          DeleteMapElement(\Clients())
        Next
      EndWith
      DeleteMapElement(Servers())
      CloseNetworkServer(Server)
    EndIf
    
  EndProcedure
  Procedure.i OpenClient(ServerAddresse.s, Port.i, IPv6.i=#False, TimeOut.i=60000, LocalIP.s="", LocalPort=0)
    
    Protected.i Client, Type
    
    Select IPv6
      Case #False : Type = #PB_Network_IPv4
      Case #True  : Type = #PB_Network_IPv6
    EndSelect
    
    Client = OpenNetworkConnection(ServerAddresse, Port, Type|#PB_Network_TCP, TimeOut, LocalIP, LocalPort)
    If Client = 0 : ProcedureReturn #False : EndIf
    
    If AddMapElement(Clients(), Str(Client))
      With Clients()
        \DataHeader\DataType = #DataType_DataHeader
        \Buffer = AllocateMemory(#BufferSize, #PB_Memory_NoClear)
        If \Buffer = 0
          CloseNetworkConnection(Client)
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      CloseNetworkConnection(Client)
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn Client
    
  EndProcedure
  Procedure CloseClient(Client.i)
    
    CloseNetworkConnection(Client)
    If FindMapElement(Clients(), Str(Client))
      With Clients()
        FreeMemory(\Buffer)
        If \StringBuffer
          FreeMemory(\StringBuffer)
        EndIf
      EndWith
      DeleteMapElement(Clients())
    EndIf
    
  EndProcedure
  Procedure.i ServerSendString(Server.i, Client.i, String.s)
    
    Protected.DataHeader_Struc *Memory
    Protected.i SentData_Length, SentData_All_Length, StringByteLength
    
    ; String kürzen, wenn das Limit überschritten wird
    Repeat
      StringByteLength = StringByteLength(String, #PB_UTF8)
      If StringByteLength <= #StringBufferSize
        Break
      EndIf
      String = Left(String, Len(String) - 1)
    ForEver
    
    ; Datenkopf und String in einen Speicher schreiben
    *Memory = AllocateMemory(SizeOf(DataHeader_Struc)+StringByteLength)
    If *Memory = 0 : ProcedureReturn #False : EndIf
    *Memory\DataType = #DataType_String
    *Memory\DataSize = StringByteLength
    If PokeS(*Memory+SizeOf(DataHeader_Struc), String, -1, #PB_UTF8|#PB_String_NoZero) <> StringByteLength
      FreeMemory(*Memory)
      ProcedureReturn #False
    EndIf
    
    ; Speicher senden
    UpdateLastSendTime(Server, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, *Memory+SentData_All_Length, MemorySize(*Memory)-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(Server, Client)
      EndIf
      If IsReachedSendTimeOut(Server, Client)
        FreeMemory(*Memory)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = SizeOf(DataHeader_Struc)+StringByteLength
    
    FreeMemory(*Memory)
    ProcedureReturn #True
    
  EndProcedure
  Procedure.i ServerSendBinaryData(Server.i, Client.i, *Memory, MemorySize.i)
    
    Protected.DataHeader_Struc DataHeader
    Protected.q SentData_Length, SentData_All_Length
    
    If *Memory = 0 : ProcedureReturn #False : EndIf
    
    ; Datenkopf senden
    DataHeader\DataType = #DataType_Binary
    DataHeader\DataSize = MemorySize
    UpdateLastSendTime(Server, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, @DataHeader+SentData_All_Length, SizeOf(DataHeader_Struc)-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(Server, Client)
      EndIf
      If IsReachedSendTimeOut(Server, Client)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = SizeOf(DataHeader_Struc)
    
    ; Speicher senden
    SentData_All_Length = 0
    UpdateLastSendTime(Server, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, *Memory+SentData_All_Length, MemorySize-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(Server, Client)
      EndIf
      If IsReachedSendTimeOut(Server, Client)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = MemorySize
    
    ProcedureReturn #True
    
  EndProcedure
  Procedure.i ServerSendFile(Server.i, Client.i, FilePath.s, FileName.s="")
    
    Protected.i File, StringByteLength
    Protected.q FileLength, ReadedData_Length, SentData_Length, SentData_All_Length
    Protected.s TempFileName
    Protected.DataHeader_Struc DataHeader
    Protected *Memory
    
    *Memory = AllocateMemory(#BufferSize, #PB_Memory_NoClear)
    If *Memory = 0 : ProcedureReturn #False : EndIf
    
    File = ReadFile(#PB_Any, FilePath, #PB_File_SharedRead)
    If File = 0
      FreeMemory(*Memory)
      ProcedureReturn #False
    EndIf
    
    FileLength = Lof(File)
    
    If FileName = ""
      FileName = GetFilePart(FilePath)
    EndIf
    
    ; Dateiname evtl. kürzen, dabei die Datei-Endung bestehen lassen
    Repeat
      StringByteLength = StringByteLength(FileName, #PB_UTF8)
      If StringByteLength <= 1000 ; Dateiname darf nur maximal 1000 Bytes benötigen
        Break
      EndIf
      TempFileName = GetFilePart(FileName, #PB_FileSystem_NoExtension)
      TempFileName = Left(TempFileName, Len(TempFileName)-1)
      If GetExtensionPart(FileName)
        TempFileName + "." + GetExtensionPart(FileName)
      EndIf
      FileName = TempFileName
    ForEver
    
    ; Datenkopf senden
    DataHeader\DataType = #DataType_File
    DataHeader\DataSize = FileLength
    PokeS(@DataHeader\FileName[0], FileName, -1, #PB_UTF8)
    UpdateLastSendTime(Server, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, @DataHeader+SentData_All_Length, SizeOf(DataHeader_Struc)-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(Server, Client)
      EndIf
      If IsReachedSendTimeOut(Server, Client)
        FreeMemory(*Memory)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = SizeOf(DataHeader_Struc)
    
    ; Datei senden
    While Not Eof(File)
      ReadedData_Length = ReadData(File, *Memory, #BufferSize)
      If ReadedData_Length = 0
        FreeMemory(*Memory)
        CloseFile(File)
        ProcedureReturn #False
      EndIf
      
      SentData_All_Length = 0
      UpdateLastSendTime(Server, Client)
      Repeat
        SentData_Length = SendNetworkData(Client, *Memory+SentData_All_Length, ReadedData_Length-SentData_All_Length)
        If SentData_Length > 0
          UpdateLastSendTime(Server, Client)
          SentData_All_Length + SentData_Length
        Else
          FreeMemory(*Memory)
          CloseFile(File)
          ProcedureReturn #False
        EndIf
        If IsReachedSendTimeOut(Server, Client)
          FreeMemory(*Memory)
          CloseFile(File)
          ProcedureReturn #False
        EndIf
      Until SentData_All_Length = ReadedData_Length
    Wend
    
    FreeMemory(*Memory)
    CloseFile(File)
    ProcedureReturn #True
    
  EndProcedure
  Procedure.i ClientSendString(Client.i, String.s)
    
    Protected.DataHeader_Struc *Memory
    Protected.i SentData_Length, SentData_All_Length, StringByteLength
    
    ; String kürzen, wenn das Limit überschritten wird
    Repeat
      StringByteLength = StringByteLength(String, #PB_UTF8)
      If StringByteLength <= #StringBufferSize
        Break
      EndIf
      String = Left(String, Len(String) - 1)
    ForEver
    
    ; Datenkopf und String in einen Speicher schreiben
    *Memory = AllocateMemory(SizeOf(DataHeader_Struc)+StringByteLength)
    If *Memory = 0 : ProcedureReturn #False : EndIf
    *Memory\DataType = #DataType_String
    *Memory\DataSize = StringByteLength
    If PokeS(*Memory+SizeOf(DataHeader_Struc), String, -1, #PB_UTF8|#PB_String_NoZero) <> StringByteLength
      FreeMemory(*Memory)
      ProcedureReturn #False
    EndIf
    
    ; Speicher senden
    UpdateLastSendTime(0, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, *Memory+SentData_All_Length, MemorySize(*Memory)-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(0, Client)
      EndIf
      If IsReachedSendTimeOut(0, Client)
        FreeMemory(*Memory)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = SizeOf(DataHeader_Struc)+StringByteLength
    
    FreeMemory(*Memory)
    ProcedureReturn #True
    
  EndProcedure
  Procedure.i ClientSendBinaryData(Client.i, *Memory, MemorySize.i)
    
    Protected.DataHeader_Struc DataHeader
    Protected.q SentData_Length, SentData_All_Length
    
    If *Memory = 0 : ProcedureReturn #False : EndIf
    
    ; Datenkopf senden
    DataHeader\DataType = #DataType_Binary
    DataHeader\DataSize = MemorySize
    UpdateLastSendTime(0, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, @DataHeader+SentData_All_Length, SizeOf(DataHeader_Struc)-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(0, Client)
      EndIf
      If IsReachedSendTimeOut(0, Client)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = SizeOf(DataHeader_Struc)
    
    ; Speicher senden
    SentData_All_Length = 0
    UpdateLastSendTime(0, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, *Memory+SentData_All_Length, MemorySize-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(0, Client)
      EndIf
      If IsReachedSendTimeOut(0, Client)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = MemorySize
    
    ProcedureReturn #True
    
  EndProcedure
  Procedure.i ClientSendFile(Client.i, FilePath.s, FileName.s="")
    
    Protected.i File, StringByteLength
    Protected.q FileLength, ReadedData_Length, SentData_Length, SentData_All_Length
    Protected.s TempFileName
    Protected.DataHeader_Struc DataHeader
    Protected *Memory
    
    *Memory = AllocateMemory(#BufferSize, #PB_Memory_NoClear)
    If *Memory = 0 : ProcedureReturn #False : EndIf
    
    File = ReadFile(#PB_Any, FilePath, #PB_File_SharedRead)
    If File = 0
      FreeMemory(*Memory)
      ProcedureReturn #False
    EndIf
    
    FileLength = Lof(File)
    
    If FileName = ""
      FileName = GetFilePart(FilePath)
    EndIf
    
    ; Dateiname evtl. kürzen, dabei die Datei-Endung bestehen lassen
    Repeat
      StringByteLength = StringByteLength(FileName, #PB_UTF8)
      If StringByteLength <= 1000 ; Dateiname darf nur maximal 1000 Bytes benötigen
        Break
      EndIf
      TempFileName = GetFilePart(FileName, #PB_FileSystem_NoExtension)
      TempFileName = Left(TempFileName, Len(TempFileName)-1)
      If GetExtensionPart(FileName)
        TempFileName + "." + GetExtensionPart(FileName)
      EndIf
      FileName = TempFileName
    ForEver
    
    ; Datenkopf senden
    DataHeader\DataType = #DataType_File
    DataHeader\DataSize = FileLength
    PokeS(@DataHeader\FileName[0], FileName, -1, #PB_UTF8)
    UpdateLastSendTime(0, Client)
    Repeat
      SentData_Length = SendNetworkData(Client, @DataHeader+SentData_All_Length, SizeOf(DataHeader_Struc)-SentData_All_Length)
      If SentData_Length > 0
        SentData_All_Length + SentData_Length
        UpdateLastSendTime(0, Client)
      EndIf
      If IsReachedSendTimeOut(0, Client)
        FreeMemory(*Memory)
        ProcedureReturn #False
      EndIf
    Until SentData_All_Length = SizeOf(DataHeader_Struc)
    
    ; Datei senden
    While Not Eof(File)
      ReadedData_Length = ReadData(File, *Memory, #BufferSize)
      If ReadedData_Length = 0
        FreeMemory(*Memory)
        CloseFile(File)
        ProcedureReturn #False
      EndIf
      
      SentData_All_Length = 0
      UpdateLastSendTime(0, Client)
      Repeat
        SentData_Length = SendNetworkData(Client, *Memory+SentData_All_Length, ReadedData_Length-SentData_All_Length)
        If SentData_Length > 0
          UpdateLastSendTime(0, Client)
          SentData_All_Length + SentData_Length
        Else
          FreeMemory(*Memory)
          CloseFile(File)
          ProcedureReturn #False
        EndIf
        If IsReachedSendTimeOut(0, Client)
          FreeMemory(*Memory)
          CloseFile(File)
          ProcedureReturn #False
        EndIf
      Until SentData_All_Length = ReadedData_Length
    Wend
    
    FreeMemory(*Memory)
    CloseFile(File)
    ProcedureReturn #True
    
  EndProcedure
  Procedure ServerReceiveDataHandler(Callback.ProtoServerCallback)
    
    Protected.i Event, ReceivedDataSize, BufferOffset
    
    Event = NetworkServerEvent()
    Select Event
      Case #PB_NetworkEvent_None
        If FindMapElement(Servers(), Str(EventServer())) And FindMapElement(Servers()\Clients(), Str(EventClient()))
          With Servers()\Clients()
            If ElapsedMilliseconds()-\LastReceiveTime >= #ReceiveTimeOut
              Select \DataHeader\DataType
                Case #DataType_Binary, #DataType_File
                  Callback(EventServer(), EventClient(), #Event_BinaryDataReceivingTimeOut)
                Case #DataType_String
                  Callback(EventServer(), EventClient(), #Event_StringReceivingTimeOut)
                Case #DataType_DataHeader
                  If \CountOfAllReceivedBytes > 0
                    Callback(EventServer(), EventClient(), #Event_DataHeaderReceivingTimeOut)
                  EndIf
              EndSelect
            EndIf
          EndWith
        EndIf
      Case #PB_NetworkEvent_Data
        If FindMapElement(Servers(), Str(EventServer())) And FindMapElement(Servers()\Clients(), Str(EventClient()))
          With Servers()\Clients()
            ReceivedDataSize = ReceiveNetworkData(EventClient(), \Buffer, #BufferSize)
            If ReceivedDataSize > 0
              BufferOffset = 0
              Repeat
                If \DataHeader\DataType = #DataType_DataHeader
                  \LastReceiveTime = ElapsedMilliseconds()
                  If ReceivedDataSize-BufferOffset >= SizeOf(DataHeader_Struc)-\CountOfAllReceivedBytes
                    ; Rest des Datenkopfs ist komplett im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, @\DataHeader+\CountOfAllReceivedBytes, SizeOf(DataHeader_Struc)-\CountOfAllReceivedBytes)
                    Callback(EventServer(), EventClient(), #Event_DataHeaderReceived, \DataHeader\DataType, @\DataHeader\FileName, \DataHeader\DataSize)
                    BufferOffset + SizeOf(DataHeader_Struc)-\CountOfAllReceivedBytes
                    \CountOfAllReceivedBytes = 0 ; Datenkopf komplett empfangen, deshalb den Zähler wieder zurücksetzten
                  Else
                    ; Nur ein (weiterer) Teil des Datenkopfs ist im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, @\DataHeader+\CountOfAllReceivedBytes, ReceivedDataSize-BufferOffset)
                    \CountOfAllReceivedBytes + ReceivedDataSize-BufferOffset
                    Callback(EventServer(), EventClient(), #Event_DataHeaderReceivingInProgress, 0, 0, \CountOfAllReceivedBytes, SizeOf(DataHeader_Struc))
                    Break ; Keine weiteren Daten vorhanden, daher weitere Verarbeitung überspringen
                  EndIf
                EndIf
                
                If \DataHeader\DataType = #DataType_Binary Or \DataHeader\DataType = #DataType_File
                  \LastReceiveTime = ElapsedMilliseconds()
                  If ReceivedDataSize-BufferOffset >= \DataHeader\DataSize-\CountOfAllReceivedBytes
                    ; Rest der Binär-Daten ist komplett im Speicher vorhanden
                    Callback(EventServer(), EventClient(), #Event_BinaryDataReceived, \DataHeader\DataType, \Buffer+BufferOffset, \DataHeader\DataSize-\CountOfAllReceivedBytes, \DataHeader\DataSize)
                    BufferOffset + \DataHeader\DataSize-\CountOfAllReceivedBytes
                    \CountOfAllReceivedBytes = 0 ; Binär-Daten komplett empfangen, deshalb den Zähler wieder zurücksetzten
                    \DataHeader\DataType = #DataType_DataHeader ; Es wird nun wieder ein Datenkopf erwartet
                  Else
                    ; Nur ein Teil der Binär-Daten ist im Speicher vorhanden
                    \CountOfAllReceivedBytes + ReceivedDataSize-BufferOffset
                    Callback(EventServer(), EventClient(), #Event_BinaryDataReceivingInProgress, \DataHeader\DataType, \Buffer+BufferOffset, ReceivedDataSize-BufferOffset, \CountOfAllReceivedBytes, \DataHeader\DataSize)
                    Break ; Keine weiteren Daten vorhanden, daher weitere Verarbeitung überspringen
                  EndIf
                EndIf
                
                If \DataHeader\DataType = #DataType_String
                  \LastReceiveTime = ElapsedMilliseconds()
                  
                  ;TODO: StringBuffer-Overflow-Schutz einbauen
                  
                  If \StringBuffer = 0
                    \StringBuffer = AllocateMemory(#StringBufferSize+1) ; Speicher muss genullt werden (+1 für die abschließende Null)
                    If \StringBuffer = 0
                      \CountOfAllReceivedBytes + \DataHeader\DataSize ; String-Daten überspringen
                      \DataHeader\DataType = #DataType_DataHeader     ; Es wird nun wieder ein Datenkopf erwartet
                      Callback(EventServer(), EventClient(), #Event_StringReceivingError)
                      Continue
                    EndIf
                  EndIf
                  
                  If ReceivedDataSize-BufferOffset >= \DataHeader\DataSize-\CountOfAllReceivedBytes
                    ; Rest des Strings ist komplett im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, \StringBuffer+\CountOfAllReceivedBytes, \DataHeader\DataSize-\CountOfAllReceivedBytes)
                    Callback(EventServer(), EventClient(), #Event_StringReceived, \StringBuffer, 0, \DataHeader\DataSize)
                    BufferOffset + \DataHeader\DataSize-\CountOfAllReceivedBytes
                    \CountOfAllReceivedBytes = 0 ; String komplett empfangen, deshalb den Zähler wieder zurücksetzten
                    \DataHeader\DataType = #DataType_DataHeader ; Es wird nun wieder ein Datenkopf erwartet
                  Else
                    ; Nur ein Teil des Strings ist im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, \StringBuffer+\CountOfAllReceivedBytes, ReceivedDataSize-BufferOffset)
                    \CountOfAllReceivedBytes + ReceivedDataSize-BufferOffset
                    Callback(EventServer(), EventClient(), #Event_StringReceivingInProgress, 0, 0, \CountOfAllReceivedBytes, \DataHeader\DataSize)
                    Break ; Keine weiteren Daten vorhanden, daher weitere Verarbeitung überspringen
                  EndIf
                EndIf
              Until BufferOffset = ReceivedDataSize
            EndIf
          EndWith
        EndIf
      Case #PB_NetworkEvent_Connect
        If FindMapElement(Servers(), Str(EventServer()))
          With Servers()
            If AddMapElement(\Clients(), Str(EventClient()))
              \Clients()\Buffer = AllocateMemory(#BufferSize, #PB_Memory_NoClear)
              If \Clients()\Buffer
                Callback(EventServer(), EventClient(), #Event_ClientConnected)
              Else
                CloseNetworkConnection(EventClient())
                DeleteMapElement(\Clients())
              EndIf
            Else
              CloseNetworkConnection(EventClient())
            EndIf
          EndWith
        EndIf
      Case #PB_NetworkEvent_Disconnect
        ; PureBasic schließt die Verbindung automatisch, kein CloseNetworkConnection() notwendig
        If FindMapElement(Servers(), Str(EventServer())) And FindMapElement(Servers()\Clients(), Str(EventClient()))
          With Servers()\Clients()
            FreeMemory(\Buffer)
            If \StringBuffer
              FreeMemory(\StringBuffer)
            EndIf
            DeleteMapElement(Servers()\Clients())
            Callback(EventServer(), EventClient(), #Event_ClientDisconnected)
          EndWith
        EndIf
    EndSelect
    
  EndProcedure
  Procedure ClientReceiveDataHandler(Callback.ProtoClientCallback)
    
    Protected.i Event, ReceivedDataSize, BufferOffset, Client
    
    ForEach Clients()
      Client = Val(MapKey(Clients()))
      Event = NetworkClientEvent(Client)
      Select Event
        Case #PB_NetworkEvent_None
          With Clients()
            If ElapsedMilliseconds()-\LastReceiveTime >= #ReceiveTimeOut
              Select \DataHeader\DataType
                Case #DataType_Binary, #DataType_File
                  Callback(Client, #Event_BinaryDataReceivingTimeOut)
                  \CountOfAllReceivedBytes = 0
                  \DataHeader\DataType = #DataType_DataHeader
                Case #DataType_String
                  Callback(Client, #Event_StringReceivingTimeOut)
                  \CountOfAllReceivedBytes = 0
                  \DataHeader\DataType = #DataType_DataHeader
                Case #DataType_DataHeader
                  If \CountOfAllReceivedBytes > 0
                    Callback(Client, #Event_DataHeaderReceivingTimeOut)
                    \CountOfAllReceivedBytes = 0
                    \DataHeader\DataType = #DataType_DataHeader
                  EndIf
              EndSelect
            EndIf
          EndWith
        Case #PB_NetworkEvent_Data
          With Clients()
            ReceivedDataSize = ReceiveNetworkData(Client, \Buffer, #BufferSize)
            If ReceivedDataSize > 0
              BufferOffset = 0
              Repeat
                If \DataHeader\DataType = #DataType_DataHeader
                  \LastReceiveTime = ElapsedMilliseconds()
                  If ReceivedDataSize-BufferOffset >= SizeOf(DataHeader_Struc)-\CountOfAllReceivedBytes
                    ; Rest des Datenkopfs ist komplett im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, @\DataHeader+\CountOfAllReceivedBytes, SizeOf(DataHeader_Struc)-\CountOfAllReceivedBytes)
                    Callback(Client, #Event_DataHeaderReceived, \DataHeader\DataType, @\DataHeader\FileName, \DataHeader\DataSize)
                    BufferOffset + SizeOf(DataHeader_Struc)-\CountOfAllReceivedBytes
                    \CountOfAllReceivedBytes = 0 ; Datenkopf komplett empfangen, deshalb den Zähler wieder zurücksetzten
                  Else
                    ; Nur ein (weiterer) Teil des Datenkopfs ist im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, @\DataHeader+\CountOfAllReceivedBytes, ReceivedDataSize-BufferOffset)
                    \CountOfAllReceivedBytes + ReceivedDataSize-BufferOffset
                    Callback(Client, #Event_DataHeaderReceivingInProgress, 0, 0, \CountOfAllReceivedBytes, SizeOf(DataHeader_Struc))
                    Break ; Keine weiteren Daten vorhanden, daher weitere Verarbeitung überspringen
                  EndIf
                EndIf
                
                If \DataHeader\DataType = #DataType_Binary Or \DataHeader\DataType = #DataType_File
                  \LastReceiveTime = ElapsedMilliseconds()
                  If ReceivedDataSize-BufferOffset >= \DataHeader\DataSize-\CountOfAllReceivedBytes
                    ; Rest der Binär-Daten ist komplett im Speicher vorhanden
                    Callback(Client, #Event_BinaryDataReceived, \DataHeader\DataType, \Buffer+BufferOffset, \DataHeader\DataSize-\CountOfAllReceivedBytes, \DataHeader\DataSize)
                    BufferOffset + \DataHeader\DataSize-\CountOfAllReceivedBytes
                    \CountOfAllReceivedBytes = 0 ; Binär-Daten komplett empfangen, deshalb den Zähler wieder zurücksetzten
                    \DataHeader\DataType = #DataType_DataHeader ; Es wird nun wieder ein Datenkopf erwartet
                  Else
                    ; Nur ein Teil der Binär-Daten ist im Speicher vorhanden
                    \CountOfAllReceivedBytes + ReceivedDataSize-BufferOffset
                    Callback(Client, #Event_BinaryDataReceivingInProgress, \DataHeader\DataType, \Buffer+BufferOffset, ReceivedDataSize-BufferOffset, \CountOfAllReceivedBytes, \DataHeader\DataSize)
                    Break ; Keine weiteren Daten vorhanden, daher weitere Verarbeitung überspringen
                  EndIf
                EndIf
                
                If \DataHeader\DataType = #DataType_String
                  \LastReceiveTime = ElapsedMilliseconds()
                  
                  ;TODO: StringBuffer-Overflow-Schutz einbauen
                  
                  If \StringBuffer = 0
                    \StringBuffer = AllocateMemory(#StringBufferSize+1) ; Speicher muss genullt werden (+1 für die abschließende Null)
                    If \StringBuffer = 0
                      \CountOfAllReceivedBytes + \DataHeader\DataSize ; String-Daten überspringen
                      \DataHeader\DataType = #DataType_DataHeader     ; Es wird nun wieder ein Datenkopf erwartet
                      Callback(Client, #Event_StringReceivingError)
                    EndIf
                  EndIf
                  
                  If ReceivedDataSize-BufferOffset >= \DataHeader\DataSize-\CountOfAllReceivedBytes
                    ; Rest des Strings ist komplett im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, \StringBuffer+\CountOfAllReceivedBytes, \DataHeader\DataSize-\CountOfAllReceivedBytes)
                    Callback(Client, #Event_StringReceived, \StringBuffer, 0, \DataHeader\DataSize)
                    BufferOffset + \DataHeader\DataSize-\CountOfAllReceivedBytes
                    \CountOfAllReceivedBytes = 0 ; String komplett empfangen, deshalb den Zähler wieder zurücksetzten
                    \DataHeader\DataType = #DataType_DataHeader ; Es wird nun wieder ein Datenkopf erwartet
                  Else
                    ; Nur ein Teil des Strings ist im Speicher vorhanden
                    CopyMemory(\Buffer+BufferOffset, \StringBuffer+\CountOfAllReceivedBytes, ReceivedDataSize-BufferOffset)
                    \CountOfAllReceivedBytes + ReceivedDataSize-BufferOffset
                    Callback(Client, #Event_StringReceivingInProgress, 0, 0, \CountOfAllReceivedBytes, \DataHeader\DataSize)
                    Break ; Keine weiteren Daten vorhanden, daher weitere Verarbeitung überspringen
                  EndIf
                EndIf
              Until BufferOffset = ReceivedDataSize
            EndIf
          EndWith
      EndSelect
    Next
    
  EndProcedure
  
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ;IncludeFile "NetworkManager.pbi"
  
  Procedure ServerCallback(EventServer.i, EventClient.i, Event.i, Param1.i, Param2.i, Param3.q, Param4.q, Param5.q)
    ;                                                                         Param1 (Integer)           Param2 (Integer)          Param3 (Quad)            Param4 (Quad)            Param5 (Quad)
    ; #Event_DataHeaderReceived            : EventServer, EventClient, Event, DataType,                  AddresseOfFileNameString, DataSize,                0,                       0
    ; #Event_DataHeaderReceivingInProgress : EventServer, EventClient, Event, 0,                         0,                        CountOfAllReceivedBytes, HeaderSize,              0
    ; #Event_BinaryDataReceived            : EventServer, EventClient, Event, DataType,                  BufferStartAddresse,      BufferDataLength,        DataSize,                0
    ; #Event_BinaryDataReceivingInProgress : EventServer, EventClient, Event, DataType,                  BufferStartAddresse,      BufferDataLength,        CountOfAllReceivedBytes, DataSize
    ; #Event_StringReceived                : EventServer, EventClient, Event, StringBufferStartAddresse, 0,                        DataSize,                0,                       0
    ; #Event_StringReceivingInProgress     : EventServer, EventClient, Event, 0,                         0,                        CountOfAllReceivedBytes, DataSize,                0
    ; #Event_StringReceivingError          : EventServer, EventClient, Event, 0,                         0,                        0,                       0,                       0
    ; #Event_ClientConnected               : EventServer, EventClient, Event, 0,                         0,                        0,                       0,                       0
    ; #Event_ClientDisconnected            : EventServer, EventClient, Event, 0,                         0,                        0,                       0,                       0
    
    Static.i File
    
    Select Event
      Case NetworkManager::#Event_ClientConnected
        Debug "[Server] Client hat sich verbunden: " + Str(EventClient)
        NetworkManager::ServerSendString(EventServer, EventClient, "Hallo Client "+#DQUOTE$+Str(EventClient)+#DQUOTE$+" !")
      Case NetworkManager::#Event_DataHeaderReceivingInProgress
        Debug "[Server] Datenkopf wird empfangen: " + Str(Param3) + " von " + Str(Param4) + " Bytes empfangen"
      Case NetworkManager::#Event_DataHeaderReceivingTimeOut
        Debug "[Server] Zeitüberschreitung beim Empfang des Datenkopfs"
      Case NetworkManager::#Event_DataHeaderReceived
        If Param1 = NetworkManager::#DataType_File
          Debug "[Server] Datenkopf empfangen (Datentyp: " + NetworkManager::GetDataTypeAsString(Param1) + " -- Datengröße: " + Str(Param3) + " Bytes -- Dateiname: " + PeekS(Param2, -1, #PB_UTF8)
          ;         File = CreateFile(#PB_Any, GetPathPart(ProgramFilename()) + PeekS(Param2, -1, #PB_UTF8))
        Else
          Debug "[Server] Datenkopf empfangen (Datentyp: " + NetworkManager::GetDataTypeAsString(Param1) + " -- Datengröße: " + Str(Param3) + " Bytes"
        EndIf
      Case NetworkManager::#Event_BinaryDataReceivingInProgress
        Select Param1
          Case NetworkManager::#DataType_Binary
            Debug "[Server] Binärdaten werden empfangen: " + Str(Param4) + " von " + Str(Param5) + " Bytes empfangen"
          Case NetworkManager::#DataType_File
            Debug "[Server] Datei wird empfangen: " + Str(Param4) + " von " + Str(Param5) + " Bytes empfangen"
            ;           If File
            ;             WriteData(File, Param2, Param3)
            ;           EndIf
        EndSelect
      Case NetworkManager::#Event_BinaryDataReceivingTimeOut
        Debug "[Server] Zeitüberschreitung beim Empfang der Binärdaten"
      Case NetworkManager::#Event_BinaryDataReceived
        Select Param1
          Case NetworkManager::#DataType_Binary
            Debug "[Server] Binärdaten wurden empfangen: " + Str(Param4) + " Bytes"
          Case NetworkManager::#DataType_File
            Debug "[Server] Datei wurde empfangen: " + Str(Param4) + " Bytes"
            ;           If File
            ;             WriteData(File, Param2, Param3)
            ;             CloseFile(File)
            ;             File = 0
            ;           EndIf
        EndSelect
      Case NetworkManager::#Event_StringReceivingInProgress
        Debug "[Server] String wird empfangen: " + Str(Param3) + " von " + Str(Param4) + " Bytes empfangen"
      Case NetworkManager::#Event_StringReceivingTimeOut
        Debug "[Server] Zeitüberschreitung beim Empfang des Strings"
      Case NetworkManager::#Event_StringReceivingError
        Debug "[Server] Fehler: String konnte nicht empfangen werden"
      Case NetworkManager::#Event_StringReceived
        Debug "[Server] String wurde empfangen: " + PeekS(Param1, -1, #PB_UTF8)
        NetworkManager::FreeServerClientStringBuffer(EventServer, EventClient) ; StringBuffer wieder freigeben, nicht notwendig
      Case NetworkManager::#Event_ClientDisconnected
        Debug "[Server] Client hat sich getrennt: " + Str(EventClient)
    EndSelect
    
  EndProcedure
  Procedure ClientCallback(EventClient.i, Event.i, Param1.i, Param2.i, Param3.q, Param4.q, Param5.q)
    ;                                                            Param1 (Integer)           Param2 (Integer)          Param3 (Quad)            Param4 (Quad)            Param5 (Quad)
    ; #Event_DataHeaderReceived            : EventClient, Event, DataType,                  AddresseOfFileNameString, DataSize,                0,                       0
    ; #Event_DataHeaderReceivingInProgress : EventClient, Event, 0,                         0,                        CountOfAllReceivedBytes, HeaderSize,              0
    ; #Event_BinaryDataReceived            : EventClient, Event, DataType,                  BufferStartAddresse,      BufferDataLength,        DataSize,                0
    ; #Event_BinaryDataReceivingInProgress : EventClient, Event, DataType,                  BufferStartAddresse,      BufferDataLength,        CountOfAllReceivedBytes, DataSize
    ; #Event_StringReceived                : EventClient, Event, StringBufferStartAddresse, 0,                        DataSize,                0,                       0
    ; #Event_StringReceivingInProgress     : EventClient, Event, 0,                         0,                        CountOfAllReceivedBytes, DataSize,                0
    ; #Event_StringReceivingError          : EventClient, Event, 0,                         0,                        0,                       0,                       0
    
    Select Event
      Case NetworkManager::#Event_DataHeaderReceivingInProgress
        Debug "[Client] Datenkopf wird empfangen: " + Str(Param3) + " von " + Str(Param4) + " Bytes empfangen"
      Case NetworkManager::#Event_DataHeaderReceivingTimeOut
        Debug "[Client] Zeitüberschreitung beim Empfang des Datenkopfs"
      Case NetworkManager::#Event_DataHeaderReceived
        If Param1 = NetworkManager::#DataType_File
          Debug "[Client] Datenkopf empfangen (Datentyp: " + NetworkManager::GetDataTypeAsString(Param1) + " -- Datengröße: " + Str(Param3) + " Bytes -- Dateiname: " + PeekS(Param2, -1, #PB_UTF8)
        Else
          Debug "[Client] Datenkopf empfangen (Datentyp: " + NetworkManager::GetDataTypeAsString(Param1) + " -- Datengröße: " + Str(Param3) + " Bytes"
        EndIf
      Case NetworkManager::#Event_BinaryDataReceivingInProgress
        Select Param1
          Case NetworkManager::#DataType_Binary
            Debug "[Client] Binärdaten werden empfangen: " + Str(Param4) + " von " + Str(Param5) + " Bytes empfangen"
          Case NetworkManager::#DataType_File
            Debug "[Client] Datei wird empfangen: " + Str(Param4) + " von " + Str(Param5) + " Bytes empfangen"
        EndSelect
      Case NetworkManager::#Event_BinaryDataReceivingTimeOut
        Debug "[Client] Zeitüberschreitung beim Empfang der Binärdaten"
      Case NetworkManager::#Event_BinaryDataReceived
        Select Param1
          Case NetworkManager::#DataType_Binary
            Debug "[Client] Binärdaten wurden empfangen: " + Str(Param4) + " Bytes"
          Case NetworkManager::#DataType_File
            Debug "[Client] Datei wurde empfangen: " + Str(Param4) + " Bytes"
        EndSelect
      Case NetworkManager::#Event_StringReceivingInProgress
        Debug "[Client] String wird empfangen: " + Str(Param3) + " von " + Str(Param4) + " Bytes empfangen"
      Case NetworkManager::#Event_StringReceivingTimeOut
        Debug "[Client] Zeitüberschreitung beim Empfang des Strings"
      Case NetworkManager::#Event_StringReceivingError
        Debug "[Client] Fehler: String konnte nicht empfangen werden"
      Case NetworkManager::#Event_StringReceived
        Debug "[Client] String wurde empfangen: " + PeekS(Param1, -1, #PB_UTF8)
        NetworkManager::FreeClientStringBuffer(EventClient) ; StringBuffer wieder freigeben, nicht notwendig
    EndSelect
    
  EndProcedure
  
  #Port = 6001
  Define.i Server1, Server2
  Define.i Client1, Client2, Client3
  Define.i Event
  
  Server1 = NetworkManager::CreateServer(#Port)
  If Not Server1
    Debug "Server konnte nicht gestartet werden!"
    End
  EndIf
  
  Server2 = NetworkManager::CreateServer(#Port+1)
  If Not Server2
    Debug "Server konnte nicht gestartet werden!"
    NetworkManager::CloseServer(Server1)
    End
  EndIf
  
  Client1 = NetworkManager::OpenClient("localhost", #Port)
  If Not Client1
    Debug "Client konnte nicht gestartet werden!"
    NetworkManager::CloseServer(Server1)
    NetworkManager::CloseServer(Server2)
    End
  EndIf
  
  Client2 = NetworkManager::OpenClient("localhost", #Port)
  If Not Client2
    Debug "Client konnte nicht gestartet werden!"
    NetworkManager::CloseClient(client1)
    NetworkManager::CloseServer(Server1)
    NetworkManager::CloseServer(Server2)
    End
  EndIf
  
  Client3 = NetworkManager::OpenClient("localhost", #Port+1)
  If Not Client3
    Debug "Client konnte nicht gestartet werden!"
    NetworkManager::CloseClient(Client1)
    NetworkManager::CloseClient(Client2)
    NetworkManager::CloseServer(Server1)
    NetworkManager::CloseServer(Server2)
    End
  EndIf
  
  Debug "Server und Clients erfolgreich gestartet"
  
  NetworkManager::ClientSendString(Client1, "Hallo Server-1! Hier ist Client-1")
  NetworkManager::ClientSendString(Client1, "Hallo Server-1! Hier ist Client-1 -- 2x")
  NetworkManager::ClientSendString(Client1, "Hallo Server-1! Hier ist Client-1 -- 3x")
  NetworkManager::ClientSendString(Client3, "Hallo Server-2! Hier ist Client-3")
  NetworkManager::ClientSendString(Client2, "Hallo Server-1! Hier ist Client-2. Ich sende eine Datei...")
  ;NetworkManager::ClientSendFile(Client2, "/home/alexander/Schreibtisch/Bild.png")
  
  ; Jetzt Strings parallel per Threads senden
  ; === ACHTUNG: ===========================================================
  ; = Das parallele Senden funktioniert nur mit unterschiedlichen Clients, =
  ; = weil die Daten beim Server sonst durcheinander ankommen würden und   =
  ; = nicht korrekt getrennt werden könnten                                =
  ; ========================================================================
  CompilerIf #PB_Compiler_Thread
    Procedure SendThread(Client.i)
      NetworkManager::ClientSendString(Client, "Client " + Str(Client) + " hat per Thread gesendet")
    EndProcedure
    CreateThread(@SendThread(), Client1) ; Client-1 => Server-1
    CreateThread(@SendThread(), Client2) ; Client-2 => Server-1
    CreateThread(@SendThread(), Client3) ; Client-3 => Server-2
  CompilerElse
    Debug "Thread-sicherer Modus ausgeschaltet, Threads-Test wird übersprungen"
  CompilerEndIf
  
  OpenWindow(0, 0, 0, 300, 100, "NetworkManager", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  Repeat
    Event = WindowEvent()
    NetworkManager::ServerReceiveDataHandler(@ServerCallback())
    NetworkManager::ClientReceiveDataHandler(@ClientCallback())
  Until Event = #PB_Event_CloseWindow
  
  NetworkManager::CloseClient(Client1)
  NetworkManager::CloseClient(Client2)
  NetworkManager::CloseClient(Client3)
  NetworkManager::CloseServer(Server1)
  NetworkManager::CloseServer(Server2)
CompilerEndIf
