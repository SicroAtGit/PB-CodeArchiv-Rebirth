;   Description: Open browser and send a POST data with the browser
;            OS: Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29328
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 NicTheQuick
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

CompilerIf #PB_Compiler_OS=#PB_OS_MacOS
  CompilerError "Windows&Linux Only!"
CompilerEndIf


EnableExplicit

DeclareModule BrowserPost
  EnableExplicit
  
  Declare.i openURL(actionUrl.s, Map postData.s(), title.s = "", nojsUrl.s = "", nojsInfo.s = "", keyLength.i = 64)
  
  Declare.i removeTempFiles(deltaTime.i = -1)
EndDeclareModule

Module BrowserPost
  EnableExplicit
  
  Structure TFiles
    time.i
    file.s
  EndStructure
  
  Global NewList tFiles.TFiles()
  Global tfilesLock.i = CreateMutex()
  
  ; Konvertiert text.s zu Unicode, verschlüsselt die Rohdaten mit dem Schlüssel und
  ; konvertiert die Daten zu einem Hex-String.
  Procedure.s convert2Hex(text.s, *key, keyLength.i, *length.Integer = 0)
    Protected dataSize.i = StringByteLength(text, #PB_Unicode) + SizeOf(Unicode)
    Protected *buffer = AllocateMemory(dataSize)
    PokeS(*buffer, text, -1, #PB_Unicode)
    
    Protected hex.s = "", *i.Unicode = *buffer, *k.Unicode = *key
    
    While *i\u
      hex + RSet(Hex(*i\u ! *k\u, #PB_Unicode), 4, "0")
      *i + SizeOf(Unicode)
      *k + SizeOf(Unicode)
      If (*k - *key) >= keyLength
        *k - keyLength
      EndIf
    Wend
    
    FreeMemory(*buffer)
    
    If *length
      *length\i = dataSize - SizeOf(Unicode)
    EndIf
    
    ProcedureReturn hex
  EndProcedure
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; ts-soft: http://www.purebasic.fr/german/viewtopic.php?p=282092#p282092
    Procedure.s FindAssociatedProgram(File.s)
      Protected Result.s = Space(#MAX_PATH)
      Protected Error
      
      Error = FindExecutable_(@File, 0, @Result)
      If Error <= 32
        ProcedureReturn ""
      EndIf
      ProcedureReturn Result
    EndProcedure
  CompilerElse
    Procedure.s FindAssociatedProgram(File.s)
      ProcedureReturn "x-www-browser"
    EndProcedure
  CompilerEndIf
  
  Procedure openURL(actionUrl.s, Map postData.s(), title.s = "", nojsUrl.s = "", nojsInfo.s = "", keyLength.i = 64)
    If Not (keyLength % 2 = 0)
      ProcedureReturn #False
    EndIf
    
    ; Erzeuge Schlüssel
    Protected *key = AllocateMemory(keyLength)
    If Not *key
      ProcedureReturn #False
    EndIf
    
    If Not OpenCryptRandom()
      ProcedureReturn #False
    EndIf
    CryptRandomData(*key, keyLength)
    
    Protected i.i, hexKey.s = ""
    For i = 0 To keyLength - 1 Step 2
      hexKey + RSet(Hex(PeekU(*key + i), #PB_Unicode), 4, "0")
    Next
    
    ; Wandle Post Data in JSON-String um.
    Protected json.i = CreateJSON(#PB_Any)
    Protected jsonData.i = SetJSONObject(JSONValue(json))
    ForEach postData()
      SetJSONString(AddJSONMember(jsonData, MapKey(postData())), postData())
    Next
    Protected jsonStr.s = ComposeJSON(json)
    FreeJSON(json)
    
    ; Wandle JSON-String in Hex-String um.
    Protected jsonLength.i, jsonHex.s = convert2Hex(jsonStr, *key, keyLength, @jsonLength)
    ; Wandle Länge des JSON-String in HEX um.
    Protected.s hexLength = RSet(Hex(jsonLength * 2, #PB_Long), 8, "0")
    
    ; Gib Schlüssel wieder frei
    FillMemory(*key, keyLength, 0)
    FreeMemory(*key)
    
    ; Erstelle Mark of the Web
    Protected motw.s = GetURLPart(actionUrl, #PB_URL_Protocol) + "://" + GetURLPart(actionUrl, #PB_URL_Site)
    
    ; Lies HTML-Template aus Datasection aus.
    Protected template.s = PeekS(?template_begin, -1, #PB_UTF8)
    
    ; Ersetze Variablen in Template.
    template = ReplaceString(template, "%MOTW%", "(" + RSet(Str(Len(motw)), 4, "0") + ")" + motw)
    template = ReplaceString(template, "%TITLE%", title)
    template = ReplaceString(template, "%ACTION%", actionUrl)
    template = ReplaceString(template, "%POSTDATA%", jsonHex)
    template = ReplaceString(template, "%NOJSACTION%", nojsUrl)
    template = ReplaceString(template, "%NOJSINFO%", nojsinfo)
    
    ; Suche zufälligen nicht existenten Dateinamen im temporären Verzeichnis
    Repeat
      Protected tempFile.s = GetTemporaryDirectory() + "_post" + Hex(Random(2147483647), #PB_Long) + "-" + Hex(Random(2147483647), #PB_Long) + ".html"
    Until FileSize(tempFile) = -1
    
    ; Schreibe Template in Datei
    Protected fileId.i = CreateFile(#PB_Any, tempFile)
    If Not fileId
      ProcedureReturn #False
    EndIf
    WriteString(fileId, template, #PB_UTF8)
    CloseFile(fileId)
    LockMutex(tfilesLock)
    If AddElement(tFiles())
      tFiles()\file = tempFile
      tfiles()\time = Date()
    EndIf
    UnlockMutex(tfilesLock)
    
    ; Suche Standardprogramm zum Öffnen von HTML-Dateien.
    Protected browser.s = FindAssociatedProgram(tempFile)
    If browser = ""
      ProcedureReturn #False
    EndIf
    
    ; Setze URL für den Browser zusammen
    Protected call.s = ~"\"file://" + tempFile + "#" + hexLength + hexKey + #DQUOTE$
    
    ProcedureReturn RunProgram(browser, call, "")
    
    DataSection
      template_begin:
      Data.q $4F44213C20202020,$7468204550595443,$2020200A0D3E6C6D,$6173202D2D213C20,$6D6F726620646576
      Data.q $4F4D253D6C727520,$D3E2D2D20255754,$74683C202020200A,$2020200A0D3E6C6D,$D3E646165683C20
      Data.q $202020202020200A,$68206174656D3C20,$697571652D707474,$65746E6F43223D76,$22657079542D746E
      Data.q $746E65746E6F6320,$682F74786574223D,$616863203B6C6D74,$6674753D74657372,$20200A0D3E22382D
      Data.q $733C202020202020,$7974207470697263,$74786574223D6570,$7263736176616A2F,$200A0D3E22747069
      Data.q $2020202020202020,$636E756628202020,$202928206E6F6974,$20202020200A0D7B,$2020202020202020
      Data.q $2065737522202020,$3B22746369727473,$2020202020200A0D,$2020202020202020,$6974636E75662020
      Data.q $7972636564206E6F,$6B28617461447470,$61746164202C7965,$2020200A0D7B2029,$2020202020202020
      Data.q $2020202020202020,$79656B2820666920,$65646E75203D3D20,$7C7C2064656E6966,$3D3D206174616420
      Data.q $6E696665646E7520,$6B28207C7C206465,$74676E656C2E7965,$2120293420252068,$207C7C2030203D3D
      Data.q $656C2E6174616428,$342025206874676E,$2030203D3D212029,$6C2E79656B207C7C,$203C206874676E65
      Data.q $200A0D7B20293231,$2020202020202020,$2020202020202020,$7220202020202020,$756E206E72757465
      Data.q $2020200A0D3B6C6C,$2020202020202020,$2020202020202020,$202020200A0D7D20,$2020202020202020
      Data.q $2072617620202020,$676E654C61746164,$726170203D206874,$656B28746E496573,$286563696C732E79
      Data.q $31202C2938202C30,$2020200A0D3B2936,$2020202020202020,$2066692020202020,$6E654C6174616428
      Data.q $203D3D2120687467,$6E656C2E61746164,$A0D7B2029687467,$2020202020202020,$2020202020202020
      Data.q $7275746572202020,$D3B6C6C756E206E,$202020202020200A,$2020202020202020,$202020200A0D7D20
      Data.q $2020202020202020,$2079656B20202020,$75732E79656B203D,$3B29382872747362,$202020200A0D0A0D
      Data.q $2020202020202020,$2020202020202020,$203D206A20726176,$3D2074756F202C30,$20200A0D3B272720
      Data.q $2020202020202020,$2020202020202020,$762820726F662020,$30203D2069207261,$203D3D212069203B
      Data.q $6E656C2E61746164,$2B2069203B687467,$A0D7B202934203D,$2020202020202020,$2020202020202020
      Data.q $2020202020202020,$53203D2B2074756F,$72662E676E697274,$6F43726168436D6F,$6573726170286564
      Data.q $2E79656B28746E49,$2C6A286563696C73,$2C2934202B206A20,$70205E2029363120,$28746E4965737261
      Data.q $696C732E61746164,$2069202C69286563,$3631202C2934202B,$2020200A0D3B2929,$2020202020202020
      Data.q $2020202020202020,$2B206A28203D206A,$656B202520293420,$6874676E656C2E79,$20202020200A0D3B
      Data.q $2020202020202020,$7D20202020202020,$2020202020200A0D,$2020202020202020,$6572202020202020
      Data.q $74756F206E727574,$20202020200A0D3B,$2020202020202020,$20200A0D7D202020,$2020202020202020
      Data.q $7566202020202020,$67206E6F6974636E,$200A0D7B2029286F,$2020202020202020,$2020202020202020
      Data.q $6820726176202020,$3D2079654B687361,$2E776F646E697720,$6E6F697461636F6C,$75732E687361682E
      Data.q $3B29312872747362,$2020202020200A0D,$2020202020202020,$6977202020202020,$636F6C2E776F646E
      Data.q $61682E6E6F697461,$3B2727203D206873,$2020202020200A0D,$2020202020202020,$6176202020202020
      Data.q $737475706E692072,$6D75636F64203D20,$457465672E746E65,$4273746E656D656C,$642728656D614E79
      Data.q $5D305B2927617461,$20202020200A0D3B,$2020202020202020,$6A20726176202020,$3D207274536E6F73
      Data.q $7470797263656420,$7361682861746144,$6E69202C79654B68,$7465672E73747570,$7475626972747441
      Data.q $2D74736F70272865,$3B29292761746164,$2020202020200A0D,$2020202020202020,$656D75636F642020
      Data.q $696D6275732E746E,$65722E74736F5074,$6C69684365766F6D,$737475706E692864,$202020200A0D3B29
      Data.q $2020202020202020,$2820666920202020,$207274536E6F736A,$296C6C756E203D3D,$202020200A0D7B20
      Data.q $2020202020202020,$7220202020202020,$A0D3B6E72757465,$2020202020202020,$2020202020202020
      Data.q $20202020200A0D7D,$2020202020202020,$6A20726176202020,$3D206A624F6E6F73,$61702E4E4F534A20
      Data.q $6E6F736A28657372,$200A0D3B29727453,$2020202020202020,$6620202020202020,$207261762820726F
      Data.q $6A206E692079656B,$20296A624F6E6F73,$20202020200A0D7B,$2020202020202020,$6669202020202020
      Data.q $624F6E6F736A2820,$6E774F7361682E6A,$79747265706F7250,$7B20292979656B28,$2020202020200A0D
      Data.q $2020202020202020,$2020202020202020,$6464696820726176,$207475706E496E65,$656D75636F64203D
      Data.q $74616572632E746E,$746E656D656C4565,$227475706E692228,$202020200A0D3B29,$2020202020202020
      Data.q $2020202020202020,$6E65646469682020,$65732E7475706E49,$7562697274744174,$6570797422286574
      Data.q $6464696822202C22,$200A0D3B29226E65,$2020202020202020,$2020202020202020,$6469682020202020
      Data.q $7475706E496E6564,$727474417465732E,$6E22286574756269,$656B202C22656D61,$2020200A0D3B2979
      Data.q $2020202020202020,$2020202020202020,$6564646968202020,$732E7475706E496E,$6269727474417465
      Data.q $6C61762228657475,$6F736A202C226575,$79656B5B6A624F6E,$2020200A0D3B295D,$2020202020202020
      Data.q $2020202020202020,$6D75636F64202020,$6D6275732E746E65,$612E74736F507469,$696843646E657070
      Data.q $656464696828646C,$3B297475706E496E,$2020202020200A0D,$2020202020202020,$A0D7D2020202020
      Data.q $2020202020202020,$2020202020202020,$20202020200A0D7D,$2020202020202020,$6D75636F64202020
      Data.q $6D6275732E746E65,$732E74736F507469,$3B292874696D6275,$2020202020200A0D,$7D20202020202020
      Data.q $2020202020200A0D,$2020202020202020,$776F646E69772020,$2064616F6C6E6F2E,$200A0D3B6F67203D
      Data.q $2020202020202020,$3B2928297D202020,$2020202020200A0D,$697263732F3C2020,$2020200A0D3E7470
      Data.q $69743C2020202020,$544954253E656C74,$7469742F3C25454C,$2020200A0D3E656C,$3E646165682F3C20
      Data.q $623C202020200A0D,$20200A0D3E79646F,$206D726F663C2020,$6D627573223D6469,$202274736F507469
      Data.q $7573223D656D616E,$74736F5074696D62,$6E6F697463612022,$4F4954434125223D,$6874656D2022254E
      Data.q $74736F70223D646F,$202020200A0D3E22,$706E693C20202020,$3D65707974207475,$226E656464696822
      Data.q $64223D656D616E20,$6C61762022617461,$6F702022223D6575,$3D617461642D7473,$414454534F502522
      Data.q $200A0D3E22254154,$3C20202020202020,$7470697263736F6E,$20202020200A0D3E,$3C20202020202020
      Data.q $73616C6320766964,$65746E6563223D73,$2020200A0D3E2272,$2020202020202020,$656D3C2020202020
      Data.q $6D223D6469206174,$726665722D617465,$7474682022687365,$3D76697571652D70,$6873657266657222
      Data.q $6E65746E6F632022,$4C52553B32223D74,$4341534A4F4E253D,$D3E22254E4F4954,$202020202020200A
      Data.q $2020202020202020,$4A4F4E253E703C20,$2F3C254F464E4953,$202020200A0D3E70,$2020202020202020
      Data.q $6820613C20202020,$4F4E25223D666572,$4E4F49544341534A,$3C6B6E694C3E2225,$2020200A0D3E612F
      Data.q $2020202020202020,$D3E7669642F3C20,$202020202020200A,$7263736F6E2F3C20,$20200A0D3E747069
      Data.q $6D726F662F3C2020,$3C202020200A0D3E,$A0D3E79646F622F,$74682F3C20202020,4090989
      Data.u 0
      
    EndDataSection
  EndProcedure
  
  Procedure.i removeTempFiles(deltaTime.i = -1)
    If deltaTime < 0
      ProcedureReturn ListSize(tFiles())
    EndIf
    LockMutex(tfilesLock)
    ResetList(tFiles())
    While NextElement(tFiles())
      If tFiles()\time + deltaTime <= Date()
        DeleteFile(tFiles()\file)
        DeleteElement(tFiles())
      EndIf
    Wend
    UnlockMutex(tfilesLock)
    
    ProcedureReturn ListSize(tFiles())
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  NewMap postData.s()
  
  postData("__ac_name") = "admin"
  postData("__ac_password") = "herein"
  postData("form.submitted") = "1"
  postData("pwd_empty") = "0"
  postData("js_enabled") = "0"
  
  BrowserPost::openURL("http://freakscorner.de/test.php?bla=normales+GET", postData(), "Bastelkeller Weiterleitung", "http://freakscorner.de/", "Da in ihrem Browser Skripte deaktiviert wurden, können die Daten nicht automatisch übertragen werden.")
  
  Delay(5000)
  BrowserPost::removeTempFiles(0)
CompilerEndIf
