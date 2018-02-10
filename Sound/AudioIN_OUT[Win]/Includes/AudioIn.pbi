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
; Original version by Chimorin (Bananenfreak)
;   See: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28447
; 
; ##################################################### Documentation ###############################################
; 
; #### AudioIN ####
; 
; Enable Threadsafe!
; 
; Working OSes:
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
;   - Check if "Threadsafe" is enabled
; 
; - V1.006 (06.11.2014)
;   - Check arguments of Initialize()
; 
; ##################################################### Check #######################################################

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Threadsafe isn't enabled"
CompilerEndIf

; ##################################################### Begin #######################################################

DeclareModule AudioIn
  EnableExplicit
  
  ; ##################################################### Constants #################################################
  
  #Version = 1006
  
  ; ##################################################### Structures ################################################
  
  ; ##################################################### Variables #################################################
  
  Global NewList Device.WAVEINCAPS()
  
  ; ##################################################### Declares ##################################################
  
  Declare.s GetError()                                  ; Returns the error-message of the last error
  Declare   GetDevices()                                ; Refreshes the list of devices ( AudioIn::Device() )
  Declare   Initialize(DeviceID.i, Samplerate.i, Channels.i, Bits.i, *CallBack=#Null, Buffer_Blocksize.i=512, Buffer_Blocks.i=8) ; Initializes a new input. It returns a handle to the instance
  Declare   Deinitialize(*AudioIn)                      ; Deinitializes the instance
  Declare   Start(*AudioIn)                             ; Starts recording
  Declare   Stop(*AudioIn)                              ; Stops recording
  Declare   GetAvailableData(*AudioIn)                  ; Returns the amount of available data
  Declare   Read_Data(*AudioIn, *Destination, Amount.i) ; Reads a specific amount of data and writes it at the given *Destination. The result of the function is the actual amount of read data.
  
EndDeclareModule


Module AudioIn
  
  ; ##################################################### Includes/UseModules #######################################
  
  ; ##################################################### Prototypes ################################################
  
  Prototype   External_CallBack(*AudioIn)
  
  ; ##################################################### Constants #################################################
  
  ; ##################################################### Structures ################################################
  
  Structure AudioIn_Buffer
    *Buffer
    Size.i
    
    Position.i
  EndStructure
  
  Structure AudioIn
    uDeviceID.i
    hwi.i
    
    Mutex.i
    Semaphore.i
    
    List inHdr.WAVEHDR()
    
    List Buffer.AudioIn_Buffer()
    Available_Data.i
    
    External_CallBack.External_CallBack
  EndStructure
  
  ; ##################################################### Variables #################################################
  
  Threaded Last_Error.i
  
  ; ##################################################### Procedures ################################################
  
  Procedure.s GetError() ; Returns the last error-message.
    Protected Text.s
    
    Text = Space(#MAXERRORLENGTH)
    waveInGetErrorText_(Last_Error, Text, #MAXERRORLENGTH)
    
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
  
  Procedure GetDevices() ; Lists all the available input-devices
    Protected.i i, Devices
    
    ; #### Get amount of available input-devices
    Devices = waveInGetNumDevs_()
    
    ClearList(Device())
    
    For i = 0 To Devices - 1
      AddElement(Device())
      waveInGetDevCaps_(i, Device(), SizeOf(WAVEINCAPS))
    Next
    
  EndProcedure
  
  Procedure CallBack(*hwi, uMsg.i, *AudioIn.AudioIn, *dwParam1, *dwParam2)
    Protected *wvhdr.WAVEHDR
    
    Select uMsg
      Case #WIM_DATA ; #### A new block of data is available, add it to the *AudioIn\Block() queue.
        *wvhdr = *dwParam1
        
        ; #### All that stuff should be packed into its own thread. It's not safe to call system-stuff in this callback.
        ; #### See: http://msdn.microsoft.com/en-us/library/dd743869%28v=vs.85%29.aspx
        
        LockMutex(*AudioIn\Mutex)
        
        If *wvhdr\lpData And *wvhdr\dwBufferLength > 0
          LastElement(*AudioIn\Buffer())
          AddElement(*AudioIn\Buffer())
          *AudioIn\Buffer()\Buffer = AllocateMemory(*wvhdr\dwBufferLength)
          *AudioIn\Buffer()\Size = *wvhdr\dwBufferLength
          CopyMemory(*wvhdr\lpData, *AudioIn\Buffer()\Buffer, *wvhdr\dwBufferLength)
          
          *AudioIn\Available_Data + *wvhdr\dwBufferLength
        EndIf
        
        ;SignalSemaphore(*AudioIn\Semaphore)
        
        UnlockMutex(*AudioIn\Mutex)
        
        waveInAddBuffer_(*hwi, *wvhdr, SizeOf(WAVEHDR))
        
        If *AudioIn\External_CallBack
          *AudioIn\External_CallBack(*AudioIn)
        EndIf
        
      Case #WIM_OPEN
        
      Case #WIM_CLOSE
        
    EndSelect
  EndProcedure
  
  Procedure Initialize(DeviceID.i, Samplerate.i, Channels.i, Bits.i, *CallBack=#Null, Buffer_Blocksize.i=512, Buffer_Blocks.i=8) ; To use the windows wavemapper set uDeviceID = #WAVE_MAPPER
    Protected wfx.WAVEFORMATEX ; wfx.WAVEFORMATEX identifies the desired format for recording waveform-audio data.
    Protected *AudioIn.AudioIn = AllocateStructure(AudioIn)
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
    
    If Error( waveInOpen_(@*AudioIn\hwi, DeviceID, wfx, @CallBack(), *AudioIn, #CALLBACK_FUNCTION | #WAVE_FORMAT_DIRECT) ) ; The waveInOpen function opens the given waveform-audio input device for recording.
      FreeStructure(*AudioIn)
      ProcedureReturn #Null
    EndIf
    
    ; #### Create a specific amount of buffers
    For i = 1 To Buffer_Blocks
      AddElement(*AudioIn\inHdr())
      
      *AudioIn\inHdr()\lpData = AllocateMemory(Buffer_Blocksize)
      *AudioIn\inHdr()\dwBufferLength = Buffer_Blocksize
      
      waveInPrepareHeader_(*AudioIn\hwi, *AudioIn\inHdr(), SizeOf(WAVEHDR))
      waveInAddBuffer_(*AudioIn\hwi, *AudioIn\inHdr(), SizeOf(WAVEHDR))
    Next
    
    *AudioIn\Mutex = CreateMutex()
    *AudioIn\Semaphore = CreateSemaphore()
    
    *AudioIn\External_CallBack = *CallBack
    
    ProcedureReturn *AudioIn
  EndProcedure
  
  Procedure Deinitialize(*AudioIn.AudioIn)  ; Deinitialize the instance.
    If Not *AudioIn
      ProcedureReturn #False
    EndIf
    
    ;waveInReset_(*AudioIn\hwi)
    waveInStop_(*AudioIn\hwi)
    
    ForEach *AudioIn\inHdr()
      waveInUnprepareHeader_(*AudioIn\hwi, *AudioIn\inHdr(), SizeOf(WAVEHDR))
      FreeMemory(*AudioIn\inHdr()\lpData)
    Next
    
    waveInClose_(*AudioIn\hwi)
    
    ForEach *AudioIn\Buffer()
      FreeMemory(*AudioIn\Buffer()\Buffer)
    Next
    
    FreeMutex(*AudioIn\Mutex)
    FreeSemaphore(*AudioIn\Semaphore)
    
    FreeStructure(*AudioIn)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure Start(*AudioIn.AudioIn)
    If Not *AudioIn
      ProcedureReturn #False
    EndIf
    
    If Error( waveInStart_(*AudioIn\hwi) )
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure Stop(*AudioIn.AudioIn)
    If Not *AudioIn
      ProcedureReturn #False
    EndIf
    
    If Error( waveInStop_(*AudioIn\hwi) )
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure GetAvailableData(*AudioIn.AudioIn)
    Protected Available_Data.i
    
    If Not *AudioIn
      ProcedureReturn -1
    EndIf
    
    LockMutex(*AudioIn\Mutex)
    Available_Data = *AudioIn\Available_Data
    UnlockMutex(*AudioIn\Mutex)
    
    ProcedureReturn Available_Data
  EndProcedure
  
  Procedure Read_Data(*AudioIn.AudioIn, *Destination, Amount.i)
    Protected Bytes_Read.i
    Protected Temp_Size.i
    
    If Not *AudioIn
      ProcedureReturn -1
    EndIf
    
    ;If TrySemaphore(*AudioIn\Semaphore)
      LockMutex(*AudioIn\Mutex)
      
      While (Amount > 0 And FirstElement(*AudioIn\Buffer()))
        Temp_Size = *AudioIn\Buffer()\Size - *AudioIn\Buffer()\Position
        If Temp_Size > Amount
          Temp_Size = Amount
        EndIf
        
        CopyMemory(*AudioIn\Buffer()\Buffer + *AudioIn\Buffer()\Position, *Destination, Temp_Size)
        
        *AudioIn\Buffer()\Position + Temp_Size
        If *AudioIn\Buffer()\Position >= *AudioIn\Buffer()\Size
          FreeMemory(*AudioIn\Buffer()\Buffer)
          DeleteElement(*AudioIn\Buffer())
        EndIf
        
        Bytes_Read + Temp_Size
        *Destination + Temp_Size
        Amount - Temp_Size
        *AudioIn\Available_Data - Temp_Size
      Wend
      
      UnlockMutex(*AudioIn\Mutex)
    ;EndIf
    
    ProcedureReturn Bytes_Read
  EndProcedure
  
EndModule
