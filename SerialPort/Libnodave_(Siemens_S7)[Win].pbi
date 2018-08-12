;   Description: Part of Libnodave, a free communication libray for Siemens S7 200/300/400 
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=25179
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 mk-soft
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

;http://libnodave.sourceforge.net/ 

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf

;-TOP
;
;/ Libnodave Include File for PureBasic V4.xx and higher
;/ Libnodave Version 0.8.4.6
;
;/ PureBasic Version 1.0 by Andreas Schweitzer
;
;/ PureBasic Version 2.0 by Michael Kastner (mk-soft)
;
; Part of Libnodave, a free communication libray For Siemens S7 200/300/400 via
; the MPI adapter 6ES7 972-0CA22-0XAC
; or  MPI adapter 6ES7 972-0CA23-0XAC
; or  TS  adapter 6ES7 972-0CA33-0XAC
; or  MPI adapter 6ES7 972-0CA11-0XAC,
; IBH/MHJ-NetLink or CPs 243, 343 and 443
; or VIPA Speed7 with builtin ethernet support.
;
; (C) Thomas Hergenhahn (thomas.hergenhahn@web.de) 2005
;
; Libnodave is free software; you can redistribute it and/or modify
; it under the terms of the GNU Library General Public License as published by
; the Free Software Foundation; either version 2, or (at your option)
; any later version.
;
; Libnodave is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU Library General Public License
; along with Libnodave; see the file COPYING.  If not, write to
; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;
;

EnableExplicit

;-Konstanten

; Protocol types to be used with newInterface:
#daveProtoMPI           = 0    ; MPI for S7 300/400
#daveProtoMPI2          = 1    ; MPI for S7 300/400, "Andrew's version"
#daveProtoMPI3          = 2    ; MPI For S7 300/400, Step 7 Version, Not yet implemented
#daveProtoPPI           = 10   ; PPI for S7 200
#daveProtoAS511         = 20   ; S5 via programming Interface
#daveProtoS7online      = 50   ; S7 using Siemens libraries & drivers for transport
#daveProtoISOTCP        = 122  ; ISO over TCP
#daveProtoISOTCP243     = 123  ; ISO over TCP with CP243
#daveProtoMPI_IBH       = 223  ; MPI with IBH NetLink MPI to ethernet gateway
#daveProtoPPI_IBH       = 224  ; PPI with IBH NetLink PPI to ethernet gateway
#daveProtoUserTransport = 255  ; Libnodave will pass the PDUs of S7 Communication to user defined call back functions.

; ProfiBus speed constants:
#daveSpeed9k    = 0
#daveSpeed19k   = 1
#daveSpeed187k  = 2
#daveSpeed500k  = 3
#daveSpeed1500k = 4
#daveSpeed45k   = 5
#daveSpeed93k   = 6

; S7 specific constants:
#daveBlockType_OB  = "8"
#daveBlockType_DB  = "A"
#daveBlockType_SDB = "B"
#daveBlockType_FC  = "C"
#daveBlockType_SFC = "D"
#daveBlockType_FB  = "E"
#daveBlockType_SFB = "F"

; Use these constants for parameter "area" in daveReadBytes and daveWriteBytes
#daveSysInfo       = $3  ; System info of 200 family
#daveSysFlags      = $5  ; System flags of 200 family
#daveAnaIn         = $6  ; analog inputs of 200 family
#daveAnaOut        = $7  ; analog outputs of 200 family
#daveP             = $80 ; direct access to peripheral adresses
#daveInputs        = $81
#daveOutputs       = $82
#daveFlags         = $83
#daveMerker        = $83
#daveDB            = $84 ; data blocks
#daveDI            = $85 ; instance data blocks
#daveV             = $87 ; don't know what it is
#daveCounter       = 28  ; S7 counters
#daveTimer         = 29  ; S7 timers
#daveCounter200    = 30  ; IEC counters (200 family)
#daveTimer200      = 31  ; IEC timers (200 family)

#daveOrderCodeSize = 21 ; Length of order code (MLFB number)

; Library specific:
;
; Result codes. Genarally, 0 means ok,
; >0 are results (also errors) reported by the PLC
; <0 means error reported by library code.
;
#daveResOK                       = 0     ; means all ok
#daveResNoPeripheralAtAddress    = 1     ; CPU tells there is no peripheral at address
#daveResMultipleBitsNotSupported = 6     ; CPU tells it does not support to read a bit block with a
                                         ; length other than 1 bit.
#daveResItemNotAvailable200      = 3     ; means a a piece of data is not available in the CPU, e.g.
                                         ; when trying to read a non existing DB or bit bloc of length<>1
                                         ; This code seems to be specific to 200 family.
#daveResItemNotAvailable         = 10    ; means a a piece of data is not available in the CPU, e.g.
                                         ; when trying to read a non existing DB
#daveAddressOutOfRange           = 5     ; means the data address is beyond the CPUs address range
#daveWriteDataSizeMismatch       = 7     ; means the write data size doesn't fit item size
#daveResCannotEvaluatePDU        = -123
#daveResCPUNoData                = -124
#daveUnknownError                = -125
#daveEmptyResultError            = -126
#daveEmptyResultSetError         = -127
#daveResUnexpectedFunc           = -128
#daveResUnknownDataUnitSize      = -129
#daveResShortPacket              = -1024
#daveResTimeout                  = -1025

; Max number of bytes in a single message.
#daveMaxRawLen = 2048

; Some definitions for debugging:
#daveDebugRawRead        = $1     ; Show the single bytes received
#daveDebugSpecialChars   = $2     ; Show when special chars are read
#daveDebugRawWrite       = $4     ; Show the single bytes written
#daveDebugListReachables = $8     ; Show the steps when determine devices in MPI net
#daveDebugInitAdapter    = $10    ; Show the steps when Initilizing the MPI adapter
#daveDebugConnect        = $20    ; Show the steps when connecting a PLC
#daveDebugPacket         = $40
#daveDebugByte           = $80
#daveDebugCompare        = $100
#daveDebugExchange       = $200
#daveDebugPDU            = $400   ; debug PDU handling
#daveDebugUpload         = $800   ; debug PDU loading program blocks from PLC
#daveDebugMPI            = $1000
#daveDebugPrintErrors    = $2000  ; Print error messages
#daveDebugPassive        = $4000
#daveDebugErrorReporting = $8000
#daveDebugOpen           = $8000
#daveDebugAll            = $1FFFF

; ***************************************************************************************

;-Import Lib

; Import-File created by Lib2PBImport
; Libname: libnodave.lib
; created: 2012/02/01  11:30

Import "libnodave.lib"
  daveAnalyze(a.l) As "___daveAnalyze@4"
  daveAnalyzePPI(a.l,b.l) As "___daveAnalyzePPI@8"
  daveAddData(a.l,b.l,c.l) As "__daveAddData@12"
  daveAddParam(a.l,b.l,c.l) As "__daveAddParam@12"
  daveAddUserData(a.l,b.l,c.l) As "__daveAddUserData@12"
  daveAddValue(a.l,b.l,c.l) As "__daveAddValue@12"
  daveConnectPLCAS511(a.l) As "__daveConnectPLCAS511@4"
  daveConnectPLCMPI1(a.l) As "__daveConnectPLCMPI1@4"
  daveConnectPLCMPI2(a.l) As "__daveConnectPLCMPI2@4"
  daveConnectPLCMPI3(a.l) As "__daveConnectPLCMPI3@4"
  daveConnectPLCNLpro(a.l) As "__daveConnectPLCNLpro@4"
  daveConnectPLCPPI(a.l) As "__daveConnectPLCPPI@4"
  daveConnectPLCS7online(a.l) As "__daveConnectPLCS7online@4"
  daveConnectPLCTCP(a.l) As "__daveConnectPLCTCP@4"
  daveConnectPLC_IBH(a.l) As "__daveConnectPLC_IBH@4"
  daveConstructBadReadResponse(a.l) As "__daveConstructBadReadResponse@4"
  daveConstructDoUpload(a.l,b.l) As "__daveConstructDoUpload@8"
  daveConstructEndUpload(a.l,b.l) As "__daveConstructEndUpload@8"
  daveConstructReadResponse(a.l) As "__daveConstructReadResponse@4"
  daveConstructUpload(a.l,b.l,c.l) As "__daveConstructUpload@12"
  daveConstructWriteResponse(a.l) As "__daveConstructWriteResponse@4"
  daveDisconnectAdapterMPI3(a.l) As "__daveDisconnectAdapterMPI3@4"
  daveDisconnectAdapterMPI(a.l) As "__daveDisconnectAdapterMPI@4"
  daveDisconnectAdapterNLpro(a.l) As "__daveDisconnectAdapterNLpro@4"
  daveDisconnectPLCAS511(a.l) As "__daveDisconnectPLCAS511@4"
  daveDisconnectPLCMPI3(a.l) As "__daveDisconnectPLCMPI3@4"
  daveDisconnectPLCMPI(a.l) As "__daveDisconnectPLCMPI@4"
  daveDisconnectPLCNLpro(a.l) As "__daveDisconnectPLCNLpro@4"
  daveDisconnectPLC_IBH(a.l) As "__daveDisconnectPLC_IBH@4"
  daveDump(a.l,b.l,c.l) As "__daveDump@12"
  daveDumpPDU(a.l) As "__daveDumpPDU@4"
  daveExchange(a.l,b.l) As "__daveExchange@8"
  daveExchangeAS511(a.l,b.l,c.l,d.l,e.l) As "__daveExchangeAS511@20"
  daveExchangeIBH(a.l,b.l) As "__daveExchangeIBH@8"
  daveExchangeMPI3(a.l,b.l) As "__daveExchangeMPI3@8"
  daveExchangeMPI(a.l,b.l) As "__daveExchangeMPI@8"
  daveExchangeNLpro(a.l,b.l) As "__daveExchangeNLpro@8"
  daveExchangePPI(a.l,b.l) As "__daveExchangePPI@8"
  daveExchangePPI_IBH(a.l,b.l) As "__daveExchangePPI_IBH@8"
  daveExchangeS7online(a.l,b.l) As "__daveExchangeS7online@8"
  daveExchangeTCP(a.l,b.l) As "__daveExchangeTCP@8"
  daveFakeExchangeAS511(a.l,b.l) As "__daveFakeExchangeAS511@8"
  daveGetAck(a.l) As "__daveGetAck@4"
  daveGetResponseISO_TCP(a.l) As "__daveGetResponseISO_TCP@4"
  daveGetResponseMPI3(a.l) As "__daveGetResponseMPI3@4"
  daveGetResponseMPI(a.l) As "__daveGetResponseMPI@4"
  daveGetResponseMPI_IBH(a.l) As "__daveGetResponseMPI_IBH@4"
  daveGetResponseNLpro(a.l) As "__daveGetResponseNLpro@4"
  daveGetResponsePPI(a.l) As "__daveGetResponsePPI@4"
  daveGetResponsePPI_IBH(a.l) As "__daveGetResponsePPI_IBH@4"
  daveGetResponseS7online(a.l) As "__daveGetResponseS7online@4"
  daveHandleRead(a.l,b.l) As "__daveHandleRead@8"
  daveHandleWrite(a.l,b.l) As "__daveHandleWrite@8"
  daveIncMessageNumber(a.l) As "__daveIncMessageNumber@4"
  daveInitAdapterMPI1(a.l) As "__daveInitAdapterMPI1@4"
  daveInitAdapterMPI2(a.l) As "__daveInitAdapterMPI2@4"
  daveInitAdapterMPI3(a.l) As "__daveInitAdapterMPI3@4"
  daveInitAdapterNLpro(a.l) As "__daveInitAdapterNLpro@4"
  daveInitPDUheader(a.l,b.l) As "__daveInitPDUheader@8"
  daveInitStepIBH(a.l,b.l,c.l,d.l,e.l,f.l) As "__daveInitStepIBH@24"
  daveInitStepNLpro(a.l,b.l,c.l,d.l,e.l,f.l) As "__daveInitStepNLpro@24"
  daveIsS5BlockArea(a.l) As "__daveIsS5BlockArea@4"
  daveListReachablePartnersDummy(a.l,b.l) As "__daveListReachablePartnersDummy@8"
  daveListReachablePartnersMPI3(a.l,b.l) As "__daveListReachablePartnersMPI3@8"
  daveListReachablePartnersMPI(a.l,b.l) As "__daveListReachablePartnersMPI@8"
  daveListReachablePartnersMPI_IBH(a.l,b.l) As "__daveListReachablePartnersMPI_IBH@8"
  daveListReachablePartnersNLpro(a.l,b.l) As "__daveListReachablePartnersNLpro@8"
  daveListReachablePartnersS7online(a.l,b.l) As "__daveListReachablePartnersS7online@8"
  daveMemcmp(a.l,b.l,c.l) As "__daveMemcmp@12"
  daveNegPDUlengthRequest(a.l,b.l) As "__daveNegPDUlengthRequest@8"
  davePackPDU(a.l,b.l) As "__davePackPDU@8"
  davePackPDU_PPI(a.l,b.l) As "__davePackPDU_PPI@8"
  daveReadChars2(a.l,b.l,c.l) As "__daveReadChars2@12"
  daveReadIBHPacket(a.l,b.l) As "__daveReadIBHPacket@8"
  daveReadISOPacket(a.l,b.l) As "__daveReadISOPacket@8"
  daveReadMPI2(a.l,b.l) As "__daveReadMPI2@8"
  daveReadMPI(a.l,b.l) As "__daveReadMPI@8"
  daveReadMPINLpro(a.l,b.l) As "__daveReadMPINLpro@8"
  daveReadOne(a.l,b.l) As "__daveReadOne@8"
  daveReadS5BlockAddress(a.l,b.l,c.l,d.l) As "__daveReadS5BlockAddress@16"
  daveReadSingle(a.l) As "__daveReadSingle@4"
  daveReturnOkDummy2(a.l) As "__daveReturnOkDummy2@4"
  daveReturnOkDummy(a.l) As "__daveReturnOkDummy@4"
  daveSCP_send(a.l,b.l) As "__daveSCP_send@8"
  daveSendAck(a.l,b.l) As "__daveSendAck@8"
  daveSendDialog2(a.l,b.l) As "__daveSendDialog2@8"
  daveSendDialogNLpro(a.l,b.l) As "__daveSendDialogNLpro@8"
  daveSendIBHNetAck(a.l) As "__daveSendIBHNetAck@4"
  daveSendIBHNetAckPPI(a.l) As "__daveSendIBHNetAckPPI@4"
  daveSendIt(a.l,b.l,c.l) As "__daveSendIt@12"
  daveSendLength(a.l,b.l) As "__daveSendLength@8"
  daveSendMPIAck2(a.l) As "__daveSendMPIAck2@4"
  daveSendMPIAck_IBH(a.l) As "__daveSendMPIAck_IBH@4"
  daveSendMessageMPI3(a.l,b.l) As "__daveSendMessageMPI3@8"
  daveSendMessageMPI(a.l,b.l) As "__daveSendMessageMPI@8"
  daveSendMessageMPI_IBH(a.l,b.l) As "__daveSendMessageMPI_IBH@8"
  daveSendMessageNLpro(a.l,b.l) As "__daveSendMessageNLpro@8"
  daveSendMessageS7online(a.l,b.l) As "__daveSendMessageS7online@8"
  daveSendRequestData(a.l,b.l) As "__daveSendRequestData@8"
  daveSendSingle(a.l,b.l) As "__daveSendSingle@8"
  daveSendWithCRC(a.l,b.l,c.l) As "__daveSendWithCRC@12"
  daveSendWithPrefix2(a.l,b.l) As "__daveSendWithPrefix2@8"
  daveSendWithPrefix2NLpro(a.l,b.l) As "__daveSendWithPrefix2NLpro@8"
  daveSendWithPrefix31(a.l,b.l,c.l) As "__daveSendWithPrefix31@12"
  daveSendWithPrefix(a.l,b.l,c.l) As "__daveSendWithPrefix@12"
  daveSendWithPrefixNLpro(a.l,b.l,c.l) As "__daveSendWithPrefixNLpro@12"
  daveSetupReceivedPDU(a.l,b.l) As "__daveSetupReceivedPDU@8"
  daveTestPGReadResult(a.l) As "__daveTestPGReadResult@4"
  daveTestReadResult(a.l) As "__daveTestReadResult@4"
  daveTestResultData(a.l) As "__daveTestResultData@4"
  daveTestWriteResult(a.l) As "__daveTestWriteResult@4"
  daveWriteIBH(a.l,b.l,c.l) As "__daveWriteIBH@12"
  closePort(a.l) As "_closePort@4"
  closeS7online(a.l) As "_closeS7online@4"
  closeSocket(a.l) As "_closeSocket@4"
  daveAddBitVarToReadRequest(a.l,b.l,c.l,d.l,e.l) As "_daveAddBitVarToReadRequest@20"
  daveAddBitVarToWriteRequest(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveAddBitVarToWriteRequest@24"
  daveAddToReadRequest(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveAddToReadRequest@24"
  daveAddVarToReadRequest(a.l,b.l,c.l,d.l,e.l) As "_daveAddVarToReadRequest@20"
  daveAddVarToWriteRequest(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveAddVarToWriteRequest@24"
  daveAreaName(a.l) As "_daveAreaName@4"
  daveBlockName(a.l) As "_daveBlockName@4"
  daveBuildAndSendPDU(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveBuildAndSendPDU@24"
  daveClrBit(a.l,b.l,c.l,d.l,e.l) As "_daveClrBit@20"
  daveConnectPLC(a.l) As "_daveConnectPLC@4"
  daveCopyRAMtoROM(a.l) As "_daveCopyRAMtoROM@4"
  daveDisconnectAdapter(a.l) As "_daveDisconnectAdapter@4"
  daveDisconnectPLC(a.l) As "_daveDisconnectPLC@4"
  daveExecReadRequest(a.l,b.l,c.l) As "_daveExecReadRequest@12"
  daveExecWriteRequest(a.l,b.l,c.l) As "_daveExecWriteRequest@12"
  daveForce200(a.l,b.l,c.l,d.l) As "_daveForce200@16"
  daveForceDisconnectIBH(a.l,b.l,c.l,d.l) As "_daveForceDisconnectIBH@16"
  daveFree(a.l) As "_daveFree@4"
  daveFreeResults(a.l) As "_daveFreeResults@4"
  daveFromBCD(a.l) As "_daveFromBCD@4"
  daveGetAnswLen(a.l) As "_daveGetAnswLen@4"
  daveGetBlockInfo(a.l,b.l,c.l,d.l) As "_daveGetBlockInfo@16"
  daveGetCounterValue(a.l) As "_daveGetCounterValue@4"
  daveGetCounterValueAt(a.l,b.l) As "_daveGetCounterValueAt@8"
  daveGetDebug() As "_daveGetDebug@0"
  daveGetErrorOfResult(a.l,b.l) As "_daveGetErrorOfResult@8"
  daveGetFloat(a.l) As "_daveGetFloat@4"
  daveGetFloatAt(a.l,b.l) As "_daveGetFloatAt@8"
  daveGetFloatfrom(a.l) As "_daveGetFloatfrom@4"
  daveGetKG(a.l) As "_daveGetKG@4"
  daveGetKGAt(a.l,b.l) As "_daveGetKGAt@8"
  daveGetMPIAdr(a.l) As "_daveGetMPIAdr@4"
  daveGetMaxPDULen(a.l) As "_daveGetMaxPDULen@4"
  daveGetName(a.l) As "_daveGetName@4"
  daveGetOrderCode(a.l,b.l) As "_daveGetOrderCode@8"
  daveGetPDUerror(a.l) As "_daveGetPDUerror@4"
  daveGetProgramBlock(a.l,b.l,c.l,d.l,e.l) As "_daveGetProgramBlock@20"
  daveGetResponse(a.l) As "_daveGetResponse@4"
  daveGetS16(a.l) As "_daveGetS16@4"
  daveGetS16At(a.l,b.l) As "_daveGetS16At@8"
  daveGetS16from(a.l) As "_daveGetS16from@4"
  daveGetS32(a.l) As "_daveGetS32@4"
  daveGetS32At(a.l,b.l) As "_daveGetS32At@8"
  daveGetS32from(a.l) As "_daveGetS32from@4"
  daveGetS5ProgramBlock(a.l,b.l,c.l,d.l,e.l) As "_daveGetS5ProgramBlock@20"
  daveGetS8(a.l) As "_daveGetS8@4"
  daveGetS8At(a.l,b.l) As "_daveGetS8At@8"
  daveGetS8from(a.l) As "_daveGetS8from@4"
  daveGetSeconds(a.l) As "_daveGetSeconds@4"
  daveGetSecondsAt(a.l,b.l) As "_daveGetSecondsAt@8"
  daveGetTimeout(a.l) As "_daveGetTimeout@4"
  daveGetU16(a.l) As "_daveGetU16@4"
  daveGetU16At(a.l,b.l) As "_daveGetU16At@8"
  daveGetU16from(a.l) As "_daveGetU16from@4"
  daveGetU32(a.l) As "_daveGetU32@4"
  daveGetU32At(a.l,b.l) As "_daveGetU32At@8"
  daveGetU32from(a.l) As "_daveGetU32from@4"
  daveGetU8(a.l) As "_daveGetU8@4"
  daveGetU8At(a.l,b.l) As "_daveGetU8At@8"
  daveGetU8from(a.l) As "_daveGetU8from@4"
  daveInitAdapter(a.l) As "_daveInitAdapter@4"
  daveListBlocks(a.l,b.l) As "_daveListBlocks@8"
  daveListBlocksOfType(a.l,b.l,c.l) As "_daveListBlocksOfType@12"
  daveListReachablePartners(a.l,b.l) As "_daveListReachablePartners@8"
  daveNewConnection(a.l,b.l,c.l,d.l) As "_daveNewConnection@16"
  daveNewInterface(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveNewInterface@24"
  daveNewPDU() As "_daveNewPDU@0"
  daveNewResultSet() As "_daveNewResultSet@0"
  davePascalNewInterface(a.l,b.l,c.l,d.l,e.l) As "_davePascalNewInterface@20"
  davePrepareReadRequest(a.l,b.l) As "_davePrepareReadRequest@8"
  davePrepareWriteRequest(a.l,b.l) As "_davePrepareWriteRequest@8"
  davePut16(a.l,b.l) As "_davePut16@8"
  davePut16At(a.l,b.l,c.l) As "_davePut16At@12"
  davePut32(a.l,b.l) As "_davePut32@8"
  davePut32At(a.l,b.l,c.l) As "_davePut32At@12"
  davePut8(a.l,b.l) As "_davePut8@8"
  davePut8At(a.l,b.l,c.l) As "_davePut8At@12"
  davePutFloat(a.l,b.l) As "_davePutFloat@8"
  davePutFloatAt(a.l,b.l,c.l) As "_davePutFloatAt@12"
  daveReadBits(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveReadBits@24"
  daveReadBytes(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveReadBytes@24"
  daveReadManyBytes(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveReadManyBytes@24"
  daveReadPLCTime(a.l) As "_daveReadPLCTime@4"
  daveReadS5Bytes(a.l,b.l,c.l,d.l,e.l) As "_daveReadS5Bytes@20"
  daveReadSZL(a.l,b.l,c.l,d.l,e.l) As "_daveReadSZL@20"
  daveResetIBH(a.l) As "_daveResetIBH@4"
  daveSendMessage(a.l,b.l) As "_daveSendMessage@8"
  daveSetBit(a.l,b.l,c.l,d.l,e.l) As "_daveSetBit@20"
  daveSetDebug(a.l) As "_daveSetDebug@4"
  daveSetPLCTime(a.l,b.l) As "_daveSetPLCTime@8"
  daveSetPLCTimeToSystime(a.l) As "_daveSetPLCTimeToSystime@4"
  daveSetTimeout(a.l,b.l) As "_daveSetTimeout@8"
  daveStart(a.l) As "_daveStart@4"
  daveStartS5(a.l) As "_daveStartS5@4"
  daveStop(a.l) As "_daveStop@4"
  daveStopS5(a.l) As "_daveStopS5@4"
  daveStrerror(a.l) As "_daveStrerror@4"
  daveStringCopy(a.l,b.l) As "_daveStringCopy@8"
  daveSwapIed_16(a.l) As "_daveSwapIed_16@4"
  daveSwapIed_32(a.l) As "_daveSwapIed_32@4"
  daveToBCD(a.l) As "_daveToBCD@4"
  daveToKG(a.l) As "_daveToKG@4"
  daveToPLCfloat(a.l) As "_daveToPLCfloat@4"
  daveUseResult(a.l,b.l,c.l) As "_daveUseResult@12"
  daveWriteBits(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveWriteBits@24"
  daveWriteBytes(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveWriteBytes@24"
  daveWriteManyBytes(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveWriteManyBytes@24"
  daveWriteS5Bytes(a.l,b.l,c.l,d.l,e.l,f.l) As "_daveWriteS5Bytes@24"
  doUpload(a.l,b.l,c.l,d.l,e.l) As "_doUpload@20"
  endUpload(a.l,b.l) As "_endUpload@8"
  initUpload(a.l,b.l,c.l,d.l) As "_initUpload@16"
  openS7online(a.l,b.l) As "_openS7online@8"
  openSocket(a.l,b.l) As "_openSocket@8"
  setPort(a.l,b.l,c.l) As "_setPort@12"
  stdread(a.l,b.l,c.l) As "_stdread@12"
  stdwrite(a.l,b.l,c.l) As "_stdwrite@12"
  toPLCfloat(a.l) As "_toPLCfloat@4"
EndImport

; ***************************************************************************************

;-Strukturen

; Struktur zum ablegen der Verbindungsdaten

Structure udtS7Connection
  *Socket
  *Interface
  *Connection
  MPI.i
  Rack.i
  Slot.i
EndStructure

; Struktur für Arrays

Structure udtArray
  StructureUnion
    bVal.b[0]
    wVal.w[0]
    lVal.l[0]
    iVal.i[0]
    fVal.f[0]
  EndStructureUnion
EndStructure

; Struktur S7-String

Structure udtS7String
  max.a
  len.a
  ch.a[254]
EndStructure

; struktur S7-Date

Structure udtS7Date
  year.b
  month.b
  day.b
  hour.b
  minute.b
  second.b
  msb.b
  lsb.b
EndStructure

; ***************************************************************************************

Procedure BSWAP32(value.l)
  !mov eax, dword [p.v_value]
  !bswap eax
  ProcedureReturn
EndProcedure

Procedure.w BSWAP16(value.w)
  !xor eax,eax
  !mov ax, word [p.v_value]
  !rol ax, 8
  ProcedureReturn
EndProcedure

; ***************************************************************************************

Procedure BcdToByte(value)
  
  Protected bVal.i
  
  bVal = (value & $F)
  value >> 4
  bVal + (value & $F * 10)
  
  ProcedureReturn bVal
  
EndProcedure

Procedure ByteToBcd(value)
  
  Protected bcdVal, zVal
  
  bcdVal = (value / 10)
  value % 10
  bcdVal << 4
  bcdVal | value
  
  ProcedureReturn bcdVal
  
EndProcedure

; ***************************************************************************************

Procedure.s GetErrorText(ErrorNumber.i)
  
  Protected *Buffer, len, text.s
  
  ; Windows Errortext
  len = FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER|#FORMAT_MESSAGE_FROM_SYSTEM,0,ErrorNumber,0,@*Buffer,0,0)
  If len
    text = PeekS(*Buffer, len - 2)
    LocalFree_(*Buffer)
    ProcedureReturn text
  Else
    ProcedureReturn "Errorcode: " + Hex(ErrorNumber)
  EndIf
  
  ProcedureReturn text
  
EndProcedure

; ***************************************************************************************

Procedure.s S7_GetErrorText(ErrorNumber.i)
  
  Protected *result, text.s
  
  ; Libnodave Errortext
  *result = daveStrerror(ErrorNumber)
  text = PeekS(*result, #PB_Any, #PB_Ascii)
  
  ProcedureReturn text
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Open socket ok

Procedure S7_OpenSocket(IPAdress.s, *hSocket.integer, port = 102)
  
  Protected result.i
  
  Dim intern.b(20)
  
  PokeS(@intern(), IPAdress, #PB_Any, #PB_Ascii)
  
  result = openSocket(port, @intern())
  If result
    *hSocket\i = result
    ProcedureReturn 0
  Else
    result = GetLastError_()
    ProcedureReturn result
  EndIf
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Close socket ok

Procedure S7_CloseSocket(hSocket)
  
  Protected result.i
  
  result = closePort(hSocket)
  If result
    ProcedureReturn 0
  Else
    result = GetLastError_()
    ProcedureReturn result
  EndIf
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Open socket ok

Procedure S7_OpenS7Online(hWnd, Accesspoint.s, *hSocket.integer)
  
  Protected result.i
  
  Dim intern.b(40)
  
  PokeS(@intern(), Accesspoint, #PB_Any, #PB_Ascii)
  
  result = openS7online(@intern(), hWnd)
  If result = 0
    *hSocket\i = result
    ProcedureReturn 0
  Else
    result = #ERROR_NOT_CONNECTED
    ProcedureReturn result
  EndIf
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Close s7online ok ; nodave errorcode

Procedure S7_CloseS7Online(hS7Online)
  
  Protected result.i
  
  result = closeS7online(hS7Online)
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Connection ok

Procedure S7_Connect(*Connection.udtS7Connection, hSocket.i, MPI.i, Rack.i, Slot.i, Protokoll.i = #daveProtoISOTCP, Speed.i = #daveSpeed187k)
  
  Protected result.i, Ordercode.s
  
  Repeat
    If *Connection = 0
      result = #ERROR_INVALID_ADDRESS
      Break
    EndIf
    With *Connection
      \Socket = hSocket
      ; Create Interface
      result = daveNewInterface(\Socket, \Socket, @"IF1", 0, Protokoll, Speed)
      If result
        \Interface = result
      Else
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      ; Init Adapter
      result = daveInitAdapter(\Interface)
      If result = 0
        ; Init Ok 
      Else
        daveDisconnectAdapter(\Interface)
        daveFree(\Interface)
        \Interface = 0   
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      ; Create Connection
      result = daveNewConnection(\Interface, MPI, Rack, Slot)
      If result
        \Connection = result
        \MPI = MPI
        \Rack = Rack
        \Slot = Slot
      Else
        daveDisconnectAdapter(\Interface)
        daveFree(\Interface)
        \Interface = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      ; Open Connection
      result = daveConnectPLC(\Connection)
      If result = 0
        result = 0
      Else
        daveDisconnectPLC(\Connection)
        daveFree(\Connection)
        \Connection = 0
        daveDisconnectAdapter(\Interface)
        daveFree(\Interface)
        \Interface = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; Result = Disconnect adapter

Procedure S7_Disconnect(*Connection.udtS7Connection)
  
  Protected result
  
  With *Connection
    If \Connection
      daveDisconnectPLC(\Connection)
      daveFree(\Connection)
      \Connection = 0
    EndIf
    If \Interface
      result = daveDisconnectAdapter(\Interface)
      daveFree(\Interface)
      \Interface = 0
    EndIf
    
  EndWith
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; Result = String ordercode

Procedure.s S7_GetOrderCode(*Connection.udtS7Connection)
  
  Protected result, Ordercode.s
  
  Dim intern.b(#daveOrderCodeSize + 2)
  
  With *Connection
    If \Connection
      Ordercode.s = Space(#daveOrderCodeSize + 1)
      result = daveGetOrderCode(\Connection, @intern())
      If result
        ProcedureReturn ""
      Else
        Ordercode = PeekS(@intern(), #PB_Any, #PB_Ascii)
        ProcedureReturn Ordercode
      EndIf
    Else
      ProcedureReturn ""
    EndIf
  EndWith
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Read bytes ok

Procedure S7_ReadBytes(*Connection.udtS7Connection, area, DB, start, bytecount, *buffer)
  
  Protected result, *intern, *offset, bytelen, count, rest, startadress
  
  Repeat
    
    With *Connection
      
      If \Connection = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      *intern = AllocateMemory(240)
      If *intern = 0
        result = #ERROR_NOT_ENOUGH_MEMORY
        Break
      EndIf
      *offset = *buffer
      count = 0
      If bytecount <= 208
        bytelen = bytecount
      Else
        bytelen = 208
      EndIf
      Repeat
        startadress = start + count
        result = daveReadBytes(\Connection, area, DB, startadress, bytelen, *intern)
        If result = 0
          CopyMemory(*intern, *offset, bytelen)
          FillMemory(*intern, 240, 0, #PB_Long)
          *offset + 208
          count + 208
          rest = bytecount - count
          If rest <= 0
            Break
          ElseIf rest < 208
            bytelen = rest
          EndIf
        Else
          result = #ERROR_INVALID_ADDRESS
          Break
        EndIf
      ForEver
      FreeMemory(*intern)
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure


; ***************************************************************************************

; Result = 0 : Write bytes ok

Procedure S7_WriteBytes(*Connection.udtS7Connection, area, DB, start, bytecount, *buffer)
  
  Protected result, *intern, *offset, bytelen, count, rest, startadress
  
  Repeat
    
    With *Connection
      
      If \Connection = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      *offset = *buffer
      count = 0
      If bytecount <= 208
        bytelen = bytecount
      Else
        bytelen = 208
      EndIf
      Repeat
        startadress = start + count
        result = daveWriteBytes(\Connection, area, DB, startadress, bytelen, *offset)
        If result = 0
          *offset + 208
          count + 208
          rest = bytecount - count
          If rest <= 0
            Break
          ElseIf rest < 208
            bytelen = rest
          EndIf
        Else
          result = #ERROR_INVALID_ADDRESS
          Break
        EndIf
      ForEver
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Read words ok

Procedure S7_ReadWords(*Connection.udtS7Connection, area, DB, start, wordcount, *buffer)
  
  Protected result, *intern.udtArray, *offset.udtArray, bytecount, bytelen, count, rest, startadress, index
  
  Repeat
    
    With *Connection
      
      If \Connection = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      *intern = AllocateMemory(240)
      If *intern = 0
        result = #ERROR_NOT_ENOUGH_MEMORY
        Break
      EndIf
      *offset = *buffer
      count = 0
      bytecount = wordcount * 2
      If bytecount <= 208
        bytelen = bytecount
      Else
        bytelen = 208
      EndIf
      Repeat
        startadress = start + count
        result = daveReadBytes(\Connection, area, DB, startadress, bytelen, *intern)
        If result = 0
          For index = 0 To (bytelen / 2 - 1)
            *offset\wVal[index] = BSWAP16(*intern\wVal[index])
          Next
          FillMemory(*intern, 240, 0, #PB_Long)
          *offset + 208
          count + 208
          rest = bytecount - count
          If rest <= 0
            Break
          ElseIf rest < 208
            bytelen = rest
          EndIf
        Else
          result = #ERROR_INVALID_ADDRESS
          Break
        EndIf
      ForEver
      FreeMemory(*intern)
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure


; ***************************************************************************************

; Result = 0 : Write word ok

Procedure S7_WriteWords(*Connection.udtS7Connection, area, DB, start, wordcount, *buffer)
  
  Protected result, *intern.udtArray, *offset.udtArray, bytecount, bytelen, count, rest, startadress, index
  
  Repeat
    
    With *Connection
      
      If \Connection = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      *intern = AllocateMemory(240)
      If *intern = 0
        result = #ERROR_NOT_ENOUGH_MEMORY
        Break
      EndIf
      *offset = *buffer
      count = 0
      bytecount = wordcount * 2
      If bytecount <= 208
        bytelen = bytecount
      Else
        bytelen = 208
      EndIf
      Repeat
        startadress = start + count
        For index = 0 To (bytelen / 2 - 1)
          *intern\wVal[index] = BSWAP16(*offset\wVal[index])
        Next
        result = daveWriteBytes(\Connection, area, DB, startadress, bytelen, *intern)
        If result = 0
          *offset + 208
          count + 208
          rest = bytecount - count
          If rest <= 0
            Break
          ElseIf rest < 208
            bytelen = rest
          EndIf
        Else
          result = #ERROR_INVALID_ADDRESS
          Break
        EndIf
      ForEver
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Read longs ok

Procedure S7_ReadLongs(*Connection.udtS7Connection, area, DB, start, longcount, *buffer)
  
  Protected result, *intern.udtArray, *offset.udtArray, bytecount, bytelen, count, rest, startadress, index
  
  Repeat
    
    With *Connection
      
      If \Connection = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      *intern = AllocateMemory(240)
      If *intern = 0
        result = #ERROR_NOT_ENOUGH_MEMORY
        Break
      EndIf
      *offset = *buffer
      count = 0
      bytecount = longcount * 4
      If bytecount <= 208
        bytelen = bytecount
      Else
        bytelen = 208
      EndIf
      Repeat
        startadress = start + count
        result = daveReadBytes(\Connection, area, DB, startadress, bytelen, *intern)
        If result = 0
          For index = 0 To (bytelen / 4 - 1)
            *offset\lVal[index] = BSWAP32(*intern\lVal[index])
          Next
          FillMemory(*intern, 240, 0, #PB_Long)
          *offset + 208
          count + 208
          rest = bytecount - count
          If rest <= 0
            Break
          ElseIf rest < 208
            bytelen = rest
          EndIf
        Else
          result = #ERROR_INVALID_ADDRESS
          Break
        EndIf
      ForEver
      FreeMemory(*intern)
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure


; ***************************************************************************************

; Result = 0 : Write long ok

Procedure S7_WriteLongs(*Connection.udtS7Connection, area, DB, start, longcount, *buffer)
  
  Protected result, *intern.udtArray, *offset.udtArray, bytecount, bytelen, count, rest, startadress, index
  
  Repeat
    
    With *Connection
      
      If \Connection = 0
        result = #ERROR_NOT_CONNECTED
        Break
      EndIf
      *intern = AllocateMemory(240)
      If *intern = 0
        result = #ERROR_NOT_ENOUGH_MEMORY
        Break
      EndIf
      *offset = *buffer
      count = 0
      bytecount = longcount * 4
      If bytecount <= 208
        bytelen = bytecount
      Else
        bytelen = 208
      EndIf
      Repeat
        startadress = start + count
        For index = 0 To (bytelen / 4 - 1)
          *intern\lVal[index] = BSWAP32(*offset\lVal[index])
        Next
        result = daveWriteBytes(\Connection, area, DB, startadress, bytelen, *intern)
        If result = 0
          *offset + 208
          count + 208
          rest = bytecount - count
          If rest <= 0
            Break
          ElseIf rest < 208
            bytelen = rest
          EndIf
        Else
          result = #ERROR_INVALID_ADDRESS
          Break
        EndIf
      ForEver
    EndWith
    
  Until #True
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; result = text; *result can be null

Procedure.s S7_ReadString(*Connection.udtS7Connection, area, DB, start, *result.integer)
  
  Protected bytelen, result, text.s, intern.udtS7String
  
  bytelen = 2
  result = S7_ReadBytes(*Connection, area, DB, start, 2, @intern)
  If result
    If *result
      *result\i = result
    EndIf
    ProcedureReturn ""
  EndIf
  
  bytelen = intern\len + 2
  result = S7_ReadBytes(*Connection, area, DB, start, bytelen, @intern)
  If *result
    *result\i = result
  EndIf
  If result
    ProcedureReturn ""
  EndIf
  
  text = PeekS(@intern\ch, intern\len, #PB_Ascii)
  
  ProcedureReturn text
  
EndProcedure

; ***************************************************************************************

; result = 0 : Ok

Procedure S7_WriteString(*Connection.udtS7Connection, area, DB, start, text.s)
  
  Protected bytelen, result, len, intern.udtS7String
  
  bytelen = 2
  result = S7_ReadBytes(*Connection, area, DB, start, 2, @intern)
  If result
    ProcedureReturn result
  EndIf
  
  If intern\max = 0 Or intern\max = 255
    ProcedureReturn #ERROR_INVALID_DATA
  EndIf
  
  If intern\len > intern\max
    ProcedureReturn #ERROR_INVALID_DATA
  EndIf
  
  len = Len(text)
  If len > intern\max
    len = intern\max
  EndIf
  intern\len = len
  PokeS(@intern\ch, text, len, #PB_Ascii)
  bytelen = intern\max + 2
  result = S7_WriteBytes(*Connection, area, DB, start, bytelen, @intern)
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************

; result = PD-Date ; *result can be null

Procedure S7_ReadDate(*Connection.udtS7Connection, area, DB, start, *result.integer)
  
  Protected bytelen, result, intern.udtS7date
  Protected year, month, day, hour, minute, second, msecond, dayofweek
  Protected pbdate
  
  bytelen = 8
  result = S7_ReadBytes(*Connection, area, DB, start, bytelen, @intern)
  If *result
    *result\i = result
  EndIf
  If result
    ProcedureReturn 0
  EndIf
  
  With intern
    year = BcdToByte(\year)
    If year < 90
      year + 2000
    Else
      year + 1900
    EndIf
    month = BcdToByte(\month)
    day = BcdToByte(\day)
    hour = BcdToByte(\hour)
    minute = BcdToByte(\minute)
    second = BcdToByte(\second)
    pbdate = Date(year, month, day, hour, minute, second)
  EndWith
  
  ProcedureReturn pbdate
  
EndProcedure

; ***************************************************************************************

; Result = 0 : Ok

Procedure S7_WriteDate(*Connection.udtS7Connection, area, DB, start, pbdate)
  
  Protected bytelen, result, intern.udtS7date
  Protected year, month, day, hour, minute, second, msecond, dayofweek
  
  
  year = Year(pbdate)
  If year < 2000
    year - 1900
  Else
    year - 2000
  EndIf
  month = Month(pbdate)
  day = Day(pbdate)
  hour = Hour(pbdate)
  minute = Minute(pbdate)
  second = Second(pbdate)
  dayofweek = DayOfWeek(pbdate) + 1
  With intern
    \year = ByteToBcd(year)
    \month = ByteToBcd(month)
    \day = ByteToBcd(day)
    \hour = ByteToBcd(hour)
    \minute = ByteToBcd(minute)
    \second = ByteToBcd(second)
    \msb = 0
    \lsb = dayofweek
  EndWith
  bytelen = 8
  result = S7_WriteBytes(*Connection, area, DB, start, bytelen, @intern)
  
  ProcedureReturn result
  
EndProcedure

; ***************************************************************************************
;- Example
CompilerIf #PB_Compiler_IsMainFile
  CompilerIf #True;true=Example 1, false Example 2
                  ;-TOP
                  ; Test 1
    
    
    ;XIncludeFile "libnodave2.pbi"
    
    Define r1, hSocket
    
    ; Netzwerkport öffnen
    Debug "Netzwerkport öffnen"
    r1 = S7_OpenSocket("192.168.1.10", @hSocket) ; Immer Adresse "@" auf Variable angeben
    Debug GetErrorText(r1)
    Delay (500)
    
    ; Verbindungsdatenvariable anlegen (Struktur)
    Define CPU_AG1.udtS7Connection
    
    ; Verbindung aufbauen
    Debug "Verbindung aufbauen..."
    r1 = S7_Connect(CPU_AG1, hSocket, 0, 0, 2)
    Debug GetErrorText(r1)
    Delay (500)
    
    ; CPU Bestellnummer
    Debug "Bestenummer lesen..."
    Debug "Ordercode: " + S7_GetOrderCode(CPU_AG1)
    
    Define text.s
    Debug "String lesen..."
    text = S7_ReadString(CPU_AG1, #daveDB, 20, 0, @r1)
    Debug Str(Len(text)) + " - " + text
    Debug GetErrorText(r1)
    
    Debug "String lesen..."
    text = S7_ReadString(CPU_AG1, #daveDB, 20, 64, @r1)
    Debug Str(Len(text)) + " - " + text
    Debug GetErrorText(r1)
    
    Debug "String schreiben..."
    r1 = S7_WriteString(CPU_AG1, #daveDB, 20, 32, "Hallo Welt012345678901234567890123456789")
    Debug GetErrorText(r1)
    
    Debug "String schreiben..."
    r1 = S7_WriteString(CPU_AG1, #daveDB, 20, 96, "Hallo Welt")
    Debug GetErrorText(r1)
    
    ; Verbindung abbauen
    Debug "Verbindung abbauen..."
    r1 = S7_Disconnect(CPU_AG1)
    Debug GetErrorText(r1)
    Delay (500)
    
    ; Netzwerkport schliessen
    Debug "Netzwerkport schliessen"
    r1 = S7_CloseSocket(hSocket)
    Debug GetErrorText(r1)
    Delay (500)
  CompilerElse
    ;-TOP
    ; Test 1
    
    Procedure DoEvent()
      While WindowEvent() : Wend
    EndProcedure
    
    Define hWnd
    hWnd = OpenWindow(0, 20,20,300,200,"Test S7Online")
    DoEvent()
    
    ;XIncludeFile "libnodave2.pbi"
    
    Define r1, hS7Online
    
    ; S7Online öffnen
    Debug "S7Online öffnen"
    r1 = S7_OpenS7Online(hwnd, "S7ONLINE", @hS7Online) ; Immer Adresse "@" auf Variable angeben
    DoEvent()
    Debug GetErrorText(r1)
    DoEvent()
    If r1
      End
    EndIf
    ; Verbindungsdatenvariable anlegen (Struktur)
    Define CPU_AG1.udtS7Connection
    
    ; Verbindung aufbauen
    Debug "Verbindung aufbauen..."
    r1 = S7_Connect(CPU_AG1, hS7Online, 2, 0, 2, #daveProtoS7online)
    Debug GetErrorText(r1)
    DoEvent()
    
    ; CPU Bestellnummer
    Debug "Bestenummer lesen..."
    Debug "Ordercode: " + S7_GetOrderCode(CPU_AG1)
    
    ; Datenblock lesen
    Debug "Datenblock Merkerbytes 0..599 lesen..."
    Dim Daten.b(1000)
    r1 = S7_ReadBytes(CPU_AG1, #daveFlags, 0, 0, 600, @Daten()) ; Immer Adresse "@" auf Daten angeben
    Debug GetErrorText(r1)
    Debug "Merkerbyte 4 = " + Str(daten(4))
    
    
    ; Verbindung abbauen
    Debug "Verbindung abbauen..."
    r1 = S7_Disconnect(CPU_AG1)
    Debug GetErrorText(r1)
    DoEvent()
    
    ; Netzwerkport schliessen
    Debug "S7Online schliessen"
    r1 = S7_CloseS7Online(hS7Online)
    Debug S7_GetErrorText(r1)
    DoEvent()
  CompilerEndIf
CompilerEndIf
