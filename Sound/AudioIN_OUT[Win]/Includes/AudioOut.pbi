; ##################################################### License / Copyright #########################################
;     
;     The MIT License (MIT)
;     
;     Copyright (c) 2014  David Vogel
;     
;     Permission is hereby granted, free of charge, To any person obtaining a copy
;     of this software And associated documentation files (the "Software"), To deal
;     in the Software without restriction, including without limitation the rights
;     To use, copy, modify, merge, publish, distribute, sublicense, And/Or sell
;     copies of the Software, And To permit persons To whom the Software is
;     furnished To do so, subject To the following conditions:
;     
;     The above copyright notice And this permission notice shall be included in all
;     copies Or substantial portions of the Software.
;     
;     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS Or
;     IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF MERCHANTABILITY,
;     FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT. IN NO EVENT SHALL THE
;     AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For ANY CLAIM, DAMAGES Or OTHER
;     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT Or OTHERWISE, ARISING FROM,
;     OUT OF Or IN CONNECTION With THE SOFTWARE Or THE USE Or OTHER DEALINGS IN THE
;     SOFTWARE.
; 
; Inspired by AudioIN by Chimorin (Bananenfreak)
;   See: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28447
; 
; ##################################################### Documentation ###############################################
; 
; #### AudioOUT ####
; 
; Enable Threadsafe!
; 
; Working OS:
; - Windows
;   - Tested: 7
; 
; 
; 
; Version history:
; - V1.000 (14.10.2014)
;   - Everything done
; 
; - V1.002 (24.10.2014)
;   - Added waveOutPause_ to Deinitialize. (To fix a crash)
;   - Check if "Threadsafe" is enabled
; 
; - V1.006 (06.11.2014)
;   - Check arguments of Initialize()
;   - Playback of waveform-data which isn't a multiple of the blocksize is working
;   - Little fixes here and there
; 
; ##################################################### Check #######################################################

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Threadsafe isn't enabled"
CompilerEndIf

; ##################################################### Begin #######################################################

DeclareModule AudioOut
  EnableExplicit
  
  ; ##################################################### Constants #################################################
  
  #Version = 1006
  
  ; ##################################################### Structures ################################################
  
  ; ##################################################### Variables #################################################
  
  Global NewList Device.WAVEOUTCAPS()
  
  ; ##################################################### Declares ##################################################
  
  ; #### Methods
  Declare.s GetError()                                  ; Returns the error-message of the last error
  Declare   GetDevices()                                ; Refreshes the list of devices ( AudioOut::Device() )
  Declare   Initialize(DeviceID.i, Samplerate.i, Channels.i, Bits.i, *CallBack=#Null, Buffer_Blocksize.i=4096, Buffer_Blocks.i=10) ; Initializes a new output. It returns a handle to the instance
  Declare   Deinitialize(*AudioOut)                     ; Deinitializes the instance
  Declare   Restart(*AudioOut)                          ; Restarts playback
  Declare   Pause(*AudioOut)                            ; Pauses playback
  Declare   GetBufferBlocksize(*AudioOut)               ; Returns the size of a bufferblock
  Declare   GetQueuedBlocks(*AudioOut)                  ; Returns the amount of blocks in the output, for gapless playback this number shouldn't get smaller than 2.
  Declare   GetQueuedData(*AudioOut)                    ; Returns the amount of queued data in bytes, that data didn't got forwarded to the soundcard yet.
  Declare   Write_Data(*AudioOut, *Source, Amount.i)    ; Writes a specific amount of data from *Source to the output-queue. If an error occurred, the result will be #False.
  
EndDeclareModule


Module AudioOut
  
  ; ##################################################### Includes/UseModules #######################################
  
  ; ##################################################### Prototypes ################################################
  
  Prototype   External_CallBack(*AudioOut)
  
  ; ##################################################### Constants #################################################
  
  ; ##################################################### Structures ################################################
  
  Structure AudioOut_Buffer
    *Buffer
    Size.i
    
    Position.i
  EndStructure
  
  Structure AudioOut
    uDeviceID.i
    hwo.i
    
    Mutex.i
    
    List outHdr.WAVEHDR()
    Buffer_Blocksize.i
    
    List Buffer.AudioOut_Buffer()
    Queued_Data.i
    Queued_Blocks.i
    
    External_CallBack.External_CallBack
  EndStructure
  
  ; ##################################################### Variables #################################################
  
  Threaded Last_Error.i
  
  ; ##################################################### Procedures ################################################
  
  Procedure.s GetError() ; Returns the last error-message.
    Protected Text.s
    
    Text = Space(#MAXERRORLENGTH)
    waveOutGetErrorText_(Last_Error, Text, #MAXERRORLENGTH)
    
    ProcedureReturn Text
  EndProcedure
  
  Procedure Error(mmrError.i)
    Last_Error = mmrError
    
    If mmrError
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure GetDevices() ; Lists all the available output-devices
    Protected.i i, Devices
    
    ; #### Get amount of available output-devices
    Devices = waveOutGetNumDevs_()
    
    ClearList(Device())
    
    For i = 0 To Devices - 1
      AddElement(Device())
      waveOutGetDevCaps_(i, Device(), SizeOf(WAVEOUTCAPS))
    Next
    
  EndProcedure
  
  Procedure Write(*AudioOut.AudioOut, *outHdr.WAVEHDR)
    Protected Temp_Size.i
    Protected Amount.i = *AudioOut\Buffer_Blocksize
    Protected *Destination = *outHdr\lpData
    Protected Bytes_Written.i
    
    ; #### Check if there is data
    If *AudioOut\Queued_Data <= 0
      ProcedureReturn #False
    EndIf
    
    ; #### Check if the *outHdr isn't in the playback queue.
    If *outHdr\dwUser
      ProcedureReturn #False
    EndIf
    
    While (Amount > 0 And FirstElement(*AudioOut\Buffer()))
      Temp_Size = *AudioOut\Buffer()\Size - *AudioOut\Buffer()\Position
      If Temp_Size > Amount
        Temp_Size = Amount
      EndIf
      
      CopyMemory(*AudioOut\Buffer()\Buffer + *AudioOut\Buffer()\Position, *Destination, Temp_Size)
      
      *AudioOut\Buffer()\Position + Temp_Size
      If *AudioOut\Buffer()\Position >= *AudioOut\Buffer()\Size
        FreeMemory(*AudioOut\Buffer()\Buffer)
        DeleteElement(*AudioOut\Buffer())
      EndIf
      
      *Destination + Temp_Size
      Amount - Temp_Size
      *AudioOut\Queued_Data - Temp_Size
      Bytes_Written + Temp_Size
    Wend
    
    *outHdr\dwBufferLength = Bytes_Written ; dwBufferLength isn't larger than *AudioOut\Buffer_Blocksize
    
    *outHdr\dwUser = #True
    
    waveOutWrite_(*AudioOut\hwo, *outHdr, SizeOf(WAVEHDR))
    *AudioOut\Queued_Blocks + 1
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure CallBack(*hwo, uMsg.i, *AudioOut.AudioOut, *dwParam1, *dwParam2)
    Protected *wvhdr.WAVEHDR
    
    Select uMsg
      Case #WOM_DONE
        *wvhdr = *dwParam1
        
        ; #### All that stuff should be packed into its own thread. It's not safe to call system-stuff in this callback.
        ; #### See: http://msdn.microsoft.com/en-us/library/dd743869%28v=vs.85%29.aspx
        
        ; #### try to fill the waveform-audio buffer with the next data, if available.
        LockMutex(*AudioOut\Mutex)
        *wvhdr\dwUser = #False
        *AudioOut\Queued_Blocks - 1
        Write(*AudioOut, *wvhdr)
        UnlockMutex(*AudioOut\Mutex)
        
        If *AudioOut\External_CallBack
          *AudioOut\External_CallBack(*AudioOut)
        EndIf
        
      Case #WOM_OPEN
        
      Case #WOM_CLOSE
        
    EndSelect
  EndProcedure
  
  Procedure Initialize(DeviceID.i, Samplerate.i, Channels.i, Bits.i, *CallBack=#Null, Buffer_Blocksize.i=4096, Buffer_Blocks.i=10) ; To use the windows wavemapper set uDeviceID = #WAVE_MAPPER
    Protected wfx.WAVEFORMATEX ; wfx.WAVEFORMATEX identifies the desired format for recording waveform-audio data.
    Protected *AudioOut.AudioOut = AllocateStructure(AudioOut)
    Protected i
    
    ; #### Check arguments
    If Buffer_Blocksize <= 0
      ProcedureReturn #Null
    EndIf
    
    If Buffer_Blocks <= 0
      ProcedureReturn #Null
    EndIf
    
    wfx\wFormatTag      = #WAVE_FORMAT_PCM
    wfx\nChannels       = Channels
    wfx\wBitsPerSample  = Bits
    wfx\nSamplesPerSec  = Samplerate
    wfx\nBlockAlign     = Channels * (Bits/8)
    wfx\nAvgBytesPerSec = Samplerate * wfx\nBlockAlign
    wfx\cbSize          = 0
    
    If Error( waveOutOpen_(@*AudioOut\hwo, DeviceID, wfx, @CallBack(), *AudioOut, #CALLBACK_FUNCTION | #WAVE_FORMAT_DIRECT) ) ; The waveOutOpen function opens the given waveform-audio output device for playback.
      FreeStructure(*AudioOut)
      ProcedureReturn #Null
    EndIf
    
    *AudioOut\Buffer_Blocksize = Buffer_Blocksize
    For i = 1 To Buffer_Blocks
      AddElement(*AudioOut\outHdr())
      
      *AudioOut\outHdr()\lpData = AllocateMemory(Buffer_Blocksize)
      *AudioOut\outHdr()\dwBufferLength = Buffer_Blocksize
      
      waveOutPrepareHeader_(*AudioOut\hwo, *AudioOut\outHdr(), SizeOf(WAVEHDR))
    Next
    
    *AudioOut\Mutex = CreateMutex()
    
    *AudioOut\External_CallBack = *CallBack
    
    ProcedureReturn *AudioOut
  EndProcedure
  
  Procedure Deinitialize(*AudioOut.AudioOut)  ; Deinitialize the instance.
    If Not *AudioOut
      ProcedureReturn #False
    EndIf
    
    waveOutPause_(*AudioOut\hwo)
    
    ;waveOutReset_(*AudioOut\hwo)
    
    ForEach *AudioOut\outHdr()
      waveOutUnprepareHeader_(*AudioOut\hwo, *AudioOut\outHdr(), SizeOf(WAVEHDR))
      FreeMemory(*AudioOut\outHdr()\lpData)
    Next
    
    waveOutClose_(*AudioOut\hwo)
    
    ForEach *AudioOut\Buffer()
      FreeMemory(*AudioOut\Buffer()\Buffer)
    Next
    
    FreeMutex(*AudioOut\Mutex)
    
    FreeStructure(*AudioOut)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure Restart(*AudioOut.AudioOut)
    If Not *AudioOut
      ProcedureReturn #False
    EndIf
    
    If Error( waveOutRestart_(*AudioOut\hwo) )
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure Pause(*AudioOut.AudioOut)
    If Not *AudioOut
      ProcedureReturn #False
    EndIf
    
    If Error( waveOutPause_(*AudioOut\hwo) )
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure GetBufferBlocksize(*AudioOut.AudioOut)
    If Not *AudioOut
      ProcedureReturn -1
    EndIf
    
    ProcedureReturn *AudioOut\Buffer_Blocksize
  EndProcedure
  
  Procedure GetQueuedBlocks(*AudioOut.AudioOut)
    Protected Result.i
    
    If Not *AudioOut
      ProcedureReturn -1
    EndIf
    
    LockMutex(*AudioOut\Mutex)
    Result = *AudioOut\Queued_Blocks
    UnlockMutex(*AudioOut\Mutex)
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure GetQueuedData(*AudioOut.AudioOut)
    Protected Result.i
    
    If Not *AudioOut
      ProcedureReturn -1
    EndIf
    
    LockMutex(*AudioOut\Mutex)
    Result = *AudioOut\Queued_Data
    UnlockMutex(*AudioOut\Mutex)
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure Write_Data(*AudioOut.AudioOut, *Source, Amount.i)
    Protected Bytes_Read.i
    Protected Temp_Size.i
    Protected Found.i
    
    If Not *AudioOut
      ProcedureReturn #False
    EndIf
    
    LockMutex(*AudioOut\Mutex)
    
    LastElement(*AudioOut\Buffer())
    AddElement(*AudioOut\Buffer())
    
    *AudioOut\Buffer()\Buffer = AllocateMemory(Amount)
    *AudioOut\Buffer()\Size = Amount
    
    CopyMemory(*Source, *AudioOut\Buffer()\Buffer, Amount)
    
    *AudioOut\Queued_Data + Amount
    
    ; #### Try to find an empty waveform buffer.
    Repeat
      Found = #False
      ForEach *AudioOut\outHdr()
        If Not *AudioOut\outHdr()\dwUser
          If Not Write(*AudioOut, *AudioOut\outHdr())
            Break 2
          EndIf
          Found = #True
          Break
        EndIf
      Next
    Until Not Found
    
    UnlockMutex(*AudioOut\Mutex)
    
    ProcedureReturn #True
  EndProcedure
  
EndModule
