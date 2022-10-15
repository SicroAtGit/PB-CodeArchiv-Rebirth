;   Description: Searches for unused identifiers
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2019-2020 Sicro
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

; Tool Settings:
; - Arguments: "%FILE" "%TEMPFILE"
; - Event:     Menu Or Shortcut

; TODO: Add support for modules

; ==========================================================================================================================
;- Inclusions of code files
; ==========================================================================================================================
XIncludeFile "../Lexer/PBLexer.pbi"
XIncludeFile "../Preprocessor/PBPreprocessor.pbi"

; ==========================================================================================================================
;- Compiler settings
; ==========================================================================================================================
EnableExplicit

; ==========================================================================================================================
;- Definition of constants
; ==========================================================================================================================
#Program_Name$ = "Search for unused identifiers"
#Window_Main   = 0
#Editor_Output = 0

; ==========================================================================================================================
;- Declaration of procedures
; ==========================================================================================================================
Declare IsNativeIdentifier(Map nativeIdentifiersMap(), identifier$)
Declare DoEvents()

; ==========================================================================================================================
;- Definition of variables and maps
; ==========================================================================================================================
Define   codeFilePath$, compilerFilePath$, identifier$, code$, tokenValue$
Define   *lexer
Define   lastTokenType, lastStringOffset, stringLength, isUnusedIdentifierFound
Define.f readStatusInPercent
Define   NewMap identifiersMap(), NewMap nativeIdentifiersMap()

; ==========================================================================================================================
;- Process program parameters
; ==========================================================================================================================
compilerFilePath$ = GetEnvironmentVariable("PB_TOOL_Compiler")
codeFilePath$     = ProgramParameter(0) ; "%FILE"
If codeFilePath$ = ""
  ; The code has not yet been saved
  ; Use the path of the auto-generated temp code file
  codeFilePath$ = ProgramParameter(1) ; "%TEMPFILE"
EndIf

; ==========================================================================================================================
;- Add native identifiers to the map
; ==========================================================================================================================
Restore NativeIdentifiers
Read$ identifier$
While identifier$ <> ""
  AddMapElement(nativeIdentifiersMap(), LCase(identifier$))
  Read$ identifier$
Wend

; ==========================================================================================================================
;- Open output window
; ==========================================================================================================================
If Not OpenWindow(#Window_Main, #PB_Ignore, #PB_Ignore, 500, 500, #Program_Name$, #PB_Window_SystemMenu |
                                                                                  #PB_Window_SizeGadget |
                                                                                  #PB_Window_MinimizeGadget |
                                                                                  #PB_Window_MaximizeGadget)
  MessageRequester(#Program_Name$, "The program window could not be created!", #PB_MessageRequester_Error)
  End
EndIf
EditorGadget(#Editor_Output, 0, 0, WindowWidth(#Window_Main), WindowHeight(#Window_Main), #PB_Editor_ReadOnly |
                                                                                          #PB_Editor_WordWrap)
AddGadgetItem(#Editor_Output, -1, "The first occurrence of an identifier is interpreted by the tool as the definition of " +
                                  "the identifier. Further occurrences of this identifier are interpreted as the use of " +
                                  "the identifier." + #CRLF$ + #CRLF$ +
                                  "The following identifiers occur only once in the code, therefore they are interpreted " +
                                  "as useless." + #CRLF$ +
                                  "___________" + #CRLF$)
DoEvents()

; ==========================================================================================================================
;- Read PB code file content into a string
; ==========================================================================================================================
AddGadgetItem(#Editor_Output, -1, "Reprocess code file and read the content of the result file ...")
DoEvents()
code$ = GetContentOfPreProcessedFile(codeFilePath$, compilerFilePath$)
stringLength = Len(code$)

; ==========================================================================================================================
;- Parse the PB code
; ==========================================================================================================================
*lexer = PBLexer::Create(@code$)
If *lexer = 0
  MessageRequester(#Program_Name$, "Lexer could not be created!", #PB_MessageRequester_Error)
  End
EndIf
AddGadgetItem(#Editor_Output, -1, "")
lastTokenType = PBLexer::#TokenType_Newline
While PBLexer::NextToken(*lexer)
  readStatusInPercent = (PBLexer::StringOffset(*lexer) - 1) * 100 / stringLength
  SetGadgetItemText(#Editor_Output, CountGadgetItems(#Editor_Output) - 1, "Analyze code ... " +
                                                                          StrF(readStatusInPercent, 2) + "%")
  If DoEvents() = #PB_Event_CloseWindow
    PBLexer::Free(*lexer)
    End
  EndIf
  Select PBLexer::TokenType(*lexer)
    Case PBLexer::#TokenType_Operator
      If PBLexer::TokenValue(*lexer) = "!"
        If lastTokenType = PBLexer::#TokenType_Newline
          ; Skip direct ASM
          While PBLexer::NextToken(*lexer)
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline
              Break
            EndIf
          Wend
        EndIf
      EndIf
    Case PBLexer::#TokenType_Identifier, PBLexer::#TokenType_Constant
      tokenValue$ = LCase(PBLexer::TokenValue(*lexer))
      lastStringOffset = PBLexer::StringOffset(*lexer)
      If PBLexer::NextToken(*lexer)
        If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_StringTypeSuffix
          tokenValue$ + "$"
        Else
          PBLexer::StringOffset(*lexer, lastStringOffset)
        EndIf
      EndIf
      If Not IsNativeIdentifier(nativeIdentifiersMap(), tokenValue$)
        identifiersMap(tokenValue$) + 1
      EndIf
    Case PBLexer::#TokenType_Keyword
      If LCase(PBLexer::TokenValue(*lexer)) = "macro"
        ; Skip macro blocks
        ; During pre-processing of codes, the PB Compiler does not remove the macro blocks after all macro calls have
        ; been resolved
        While PBLexer::NextToken(*lexer)
          If LCase(PBLexer::TokenValue(*lexer)) = "endmacro"
            Break
          EndIf
        Wend
      EndIf
  EndSelect
  lastTokenType = PBLexer::TokenType(*lexer)
Wend
PBLexer::Free(*lexer)

; ==========================================================================================================================
;- Output a list of all unused identifiers
; ==========================================================================================================================
AddGadgetItem(#Editor_Output, -1, "___________" + #CRLF$)
ForEach identifiersMap()
  If identifiersMap() = 1 ; The first occurrence is interpreted as the definition of the identifier.
                          ; The following occurrences are then the use of the identifier
    AddGadgetItem(#Editor_Output, -1, "=> " + MapKey(identifiersMap()))
    isUnusedIdentifierFound = #True
    DoEvents()
  EndIf
Next

If Not isUnusedIdentifierFound
  AddGadgetItem(#Editor_Output, -1, "No unused identifiers found :-)")
EndIf

Repeat
  Delay(1)
Until DoEvents() = #PB_Event_CloseWindow

; ==========================================================================================================================
;- Definition of procedures
; ==========================================================================================================================
Procedure IsNativeIdentifier(Map nativeIdentifiersMap(), identifier$)
  ; ------------------------------------------------------------------------------------------------------------------------
  ; Description:  | Checks whether the passed identifier is a native identifier
  ; ------------------------------------------------------------------------------------------------------------------------
  ; Parameter:    | nativeIdentifiersMap() -- Map that contains the native identifiers
  ;               |            identifier$ -- Identifier to check
  ; ------------------------------------------------------------------------------------------------------------------------
  ; Return value: | #True or #False
  ; ------------------------------------------------------------------------------------------------------------------------
  If Left(identifier$, 4) = "#pb_"
    ProcedureReturn #True
  Else
    ProcedureReturn Bool(FindMapElement(nativeIdentifiersMap(), identifier$))
  EndIf
EndProcedure

Procedure DoEvents()
  ; ------------------------------------------------------------------------------------------------------------------------
  ; Description:  | Processes the window events and resizes the gadgets when the main window is resized
  ; ------------------------------------------------------------------------------------------------------------------------
  ; Return value: | For the event "#PB_Event_CloseWindow" the event is returned, otherwise #False
  ; ------------------------------------------------------------------------------------------------------------------------
  Protected event
  Repeat
    event = WindowEvent()
    Select event
      Case #PB_Event_SizeWindow
        ResizeGadget(#Editor_Output, #PB_Ignore, #PB_Ignore, WindowWidth(#Window_Main), WindowHeight(#Window_Main))
      Case #PB_Event_CloseWindow
        ProcedureReturn event
    EndSelect
  Until event = #PB_Event_None
EndProcedure

; ==========================================================================================================================
;- Data section
; ==========================================================================================================================
DataSection
  NativeIdentifiers:
  ; pbcompiler --liststructures
  Data$ "GdkEventAny", "GError", "GdkEventProperty", "GtkFixedClass", "SCCharacterRange", "GdkDisplayClass", "GdkColormap"
  Data$ "GtkTreeSelectionClass", "GtkTreeModelSort", "SDL_Overlay", "GtkActionGroupClass", "GMarkupParser", "GtkRadioAction"
  Data$ "GtkEntry", "GtkAccelGroup", "GtkContainerClass", "GtkCListClass", "PangoAttribute", "GParamSpecUInt64"
  Data$ "GdkEventScroll", "GtkTextTagTableClass", "GParamSpecUInt", "GtkToggleToolButton", "PB_MeshVertex", "GtkActionEntry"
  Data$ "GtkRadioActionEntry", "GtkPropertyMark", "GdkRectangle", "SDL_ResizeEvent", "GtkCellRenderer", "GtkRadioToolButton"
  Data$ "GtkSocketClass", "GtkTreeItemClass", "GTypeInfo", "GtkFileChooserDialogClass", "GtkToolButtonClass", "String"
  Data$ "XML_Content", "GtkVPanedClass", "GtkMenuClass", "GtkTreeDragSourceIface", "Float", "GtkHScrollbar", "SDL_Color"
  Data$ "GtkNotebookClass", "GtkCTree", "GtkInputDialogClass", "GtkComboClass", "GtkActionGroup", "GParamSpecInt64"
  Data$ "GSourceFuncs", "GdkDragContext", "GtkTreeModelSortClass", "SDL_Palette", "GTypeInterface", "GtkCListColumn"
  Data$ "XML_ParsingStatus", "GtkCalendar", "GtkButtonBoxClass", "GtkItemFactoryClass", "XML_Expat_Version", "GtkTreeView"
  Data$ "GObject", "GtkToolButton", "GtkVScrollbarClass", "GtkViewportClass", "GdkPangoAttrStipple", "GdkWindowObjectClass"
  Data$ "GtkListClass", "GdkFont", "GdkSegment", "GtkMessageDialogClass", "GtkRulerMetric", "GtkArg_union"
  Data$ "GtkTooltipsClass", "SDL_JoyBallEvent", "SDL_SysWMinfo", "GtkInvisible", "GtkWidgetAuxInfo", "GtkTextView"
  Data$ "GtkSeparatorClass", "GArray", "GParamSpecDouble", "GDebugKey", "DragDataFormat", "GOptionEntry", "GtkAspectFrame"
  Data$ "GtkCheckButton", "GdkEventVisibility", "GtkAllocation", "PangoColor", "GInterfaceInfo", "GtkHScale", "GtkHBox"
  Data$ "SDL_VideoInfo", "GtkTextTagClass", "GdkGC", "SDL_AudioCVT", "GtkTextTag", "GtkToggleButtonClass"
  Data$ "GtkCellRendererPixbuf", "GSignalQuery", "Sint64", "GtkPixmapClass", "GdkEventButton", "GtkIMMulticontextClass"
  Data$ "GtkAccelGroupClass", "GdkEventSetting", "GdkDeviceAxis", "GtkMenuShellClass", "GtkEntryCompletionClass"
  Data$ "SDL_Surface", "GtkInvisibleClass", "GStaticPrivate", "GtkWindow", "GdkEventKey", "GtkCListDestInfo", "GDate"
  Data$ "GtkColorButton", "GtkComboBox", "GtkImageClass", "SDL_MouseMotionEvent", "GtkRcProperty", "GSignalInvocationHint"
  Data$ "SDL_QuitEvent", "GParamSpecUChar", "GtkAccelLabel", "SDL_UserEvent", "GdkImageClass", "SDL_JoyHatEvent"
  Data$ "GtkTextChildAnchorClass", "GtkArg", "GtkTextMark", "GtkTooltipsData", "GtkPanedClass", "XML_Encoding", "Long"
  Data$ "GtkCheckButtonClass", "GtkToolbarChild", "GtkCellRendererToggleClass", "GIOFuncs", "GtkLabelClass", "GStaticRWLock"
  Data$ "GtkAlignment", "SDL_MouseButtonEvent", "GtkToggleAction", "GEnumValue", "GtkArrowClass", "GtkCellText"
  Data$ "GtkVSeparator", "SCTextToFind", "GParamSpecString", "GtkIconFactory", "SDL_version", "GtkLabel", "GtkRuler"
  Data$ "GtkPreviewInfo", "GtkList", "GtkToolbar", "GTokenValue", "GtkTreeModelFilter", "GtkTextChildAnchor", "GtkBorder"
  Data$ "XML_Feature", "GtkTreeItem", "GEnumClass", "GtkCurve", "GTuples", "GtkFileChooserWidgetClass", "GtkTreeIter"
  Data$ "GIOChannel", "GtkCTreeRow", "GtkCalendarClass", "Unicode", "GdkScreenClass", "GtkTextTagTable", "GdkEventSelection"
  Data$ "GtkCTreeNode", "GtkIconFactoryClass", "GtkTreeStore", "GMemVTable", "SDL_keysym", "GThreadPool", "GtkMiscClass"
  Data$ "GtkPreviewClass", "GtkLayoutClass", "GtkWindowGroup", "GtkAction", "GtkComboBoxEntry", "SDL_SysWMEvent"
  Data$ "GtkHScrollbarClass", "GtkCellPixmap", "GtkVRuler", "GtkIMContextSimple", "GSystemThread", "GtkWidget"
  Data$ "GtkTextAttributes", "GtkTextIter", "GtkScrollbar", "GNode", "GtkColorSelectionDialogClass", "GtkToggleActionEntry"
  Data$ "GtkIMContextClass", "GtkIMContext", "GdkPixmapObjectClass", "GFlagsValue", "GtkExpanderClass", "GdkEventWindowState"
  Data$ "GParamSpecClass", "GtkTreeViewColumn", "GtkItemFactory", "GObjectConstructParam", "GtkToggleToolButtonClass"
  Data$ "GtkRequisition", "GtkSettingsValue", "GtkOptionMenu", "GtkListStoreClass", "GtkMenuShell", "GtkVButtonBoxClass"
  Data$ "GFlagsClass", "GtkNotebook", "GdkDeviceKey", "GtkHSeparator", "GtkRange", "GtkTearoffMenuItem", "GdkDevice"
  Data$ "GtkProgressBar", "GtkEventBoxClass", "GtkFileChooserDialog", "GdkPixmapObject", "GtkAdjustment", "GtkHRulerClass"
  Data$ "GTimeVal", "GObjectClass", "GtkTableRowCol", "GtkSettingsClass", "GtkSelectionData", "GdkTimeCoord"
  Data$ "GtkToolbarClass", "GtkCellEditableIface", "GParamSpecBoxed", "GtkMisc", "GtkPreview", "GtkVSeparatorClass"
  Data$ "GtkScale", "GParamSpecInt", "GtkImageMenuItem", "GtkEntryCompletion", "GtkFontSelectionClass", "GdkScreen"
  Data$ "GtkTreeViewColumnClass", "GdkEventMotion", "SDL_CD", "GtkItemClass", "Character", "GtkBindingEntry", "GdkImage"
  Data$ "GValueArray", "GtkRadioButton", "GdkEventExpose", "GdkEventNoExpose", "GtkItem", "GtkHPaned", "GdkColor"
  Data$ "GdkEventClient", "SDL_JoyButtonEvent", "GtkHScaleClass", "SDL_SysWMinfo_info_x11", "GtkImagePixbufData", "GtkImage"
  Data$ "Integer", "GtkFileFilterInfo", "GtkComboBoxEntryClass", "GParameter", "GtkIconThemeClass", "Byte"
  Data$ "GSourceCallbackFuncs", "GtkImageImageData", "GtkTextViewClass", "SDL_RWops", "GStaticMutex", "GtkProgressClass"
  Data$ "GtkTextClass", "GtkBindingSignal", "SDL_ActiveEvent", "GThread", "GtkSeparatorToolItem", "GtkTreeSortableIface"
  Data$ "GtkVScale", "SDL_RWops_unknown", "GtkCTreeClass", "GtkMenuEntry", "GtkFixed", "GString", "GtkFontButtonClass"
  Data$ "GtkUIManagerClass", "GtkSettings", "GSource", "GParamSpecTypeInfo", "GtkListItemClass", "Word", "GQueue"
  Data$ "GdkKeymap", "GtkTextBuffer", "GdkKeymapClass", "GtkTextBufferClass", "GtkAccelLabelClass", "GtkFrame"
  Data$ "SDL_ExposeEvent", "GtkCellRendererClass", "GtkImageIconSetData", "GtkTearoffMenuItemClass", "GtkItemFactoryEntry"
  Data$ "GtkBindingSet", "GtkUIManager", "GtkCell_pm", "GtkVButtonBox", "GdkPoint", "GtkContainer", "GtkCList", "GtkCell_pt"
  Data$ "GtkActionClass", "GtkRadioActionClass", "GtkGammaCurve", "GtkBin", "GtkProgress", "GtkText", "GtkWidgetShapeInfo"
  Data$ "GtkTargetList", "GtkBoxChild", "GtkBindingArg", "GtkCombo", "Ascii", "GTypeFundamentalInfo", "GtkFileSelection"
  Data$ "GtkTipsQuery", "GtkCListCellInfo", "GdkKeymapKey", "GtkCellRendererToggle", "GParamSpecLong", "GdkWindowObject"
  Data$ "SDL_SysWMinfo_info", "GParamSpec", "GtkRcStyle", "GtkImageStockData", "GtkHandleBox", "GtkSpinButtonClass", "GOnce"
  Data$ "GtkRadioMenuItemClass", "GdkEventDND", "GdkGCClass", "GtkImageAnimationData", "GtkHandleBoxClass"
  Data$ "GtkEditableClass", "GdkSpan", "GtkCheckMenuItemClass", "GtkTreeClass", "GtkColorButtonClass", "GStaticRecMutex"
  Data$ "SDL_CDtrack", "Quad", "GTypeQuery", "GtkWindowGroupClass", "GtkHButtonBoxClass", "GdkDragContextClass"
  Data$ "GdkDrawableClass", "GtkItemFactoryItem", "GtkPlugClass", "GtkTreeSelection", "GtkStyle", "PB_MeshFace"
  Data$ "GtkSeparatorMenuItem", "GtkTreeModelIface", "SCNotification", "GtkAccelGroupEntry", "GtkMenu", "GtkCell"
  Data$ "GtkCellRendererPixbufClass", "GtkEditable", "GCompletion", "GtkImagePixmapData", "GList", "GtkCurveClass"
  Data$ "SDL_AudioSpec", "GtkAdjustmentClass", "GdkWindowAttr", "GtkToolItemClass", "GPtrArray", "GtkDialogClass"
  Data$ "GtkSpinButton", "GtkAccelKey", "SDL_Event", "GtkRcStyleClass", "GtkVRulerClass", "GtkHSeparatorClass", "GdkGeometry"
  Data$ "GtkAspectFrameClass", "GTypePluginClass", "SCNotifyHeader", "GtkFileSelectionClass", "GtkTipsQueryClass"
  Data$ "GdkDisplayPointerHooks", "GtkSeparator", "GtkTargetPair", "GValue", "GtkHButtonBox", "GtkTable", "GtkMenuBar"
  Data$ "GdkRgbCmap", "GtkToggleButton", "GClosureNotifyData", "SDL_Rect", "GHookList", "GtkMenuItemClass"
  Data$ "GParamSpecValueArray", "GThreadFunctions", "GtkRadioMenuItem", "GtkProgressBarClass", "GTypeInstance"
  Data$ "GtkStatusbar", "GtkSeparatorToolItemClass", "GtkVScaleClass", "GtkCellRendererTextClass", "GSList", "GtkBoxClass"
  Data$ "GdkDrawable", "GtkPlug", "GtkTableChild", "GtkIconTheme", "GtkVBox", "GParamSpecFloat", "GtkCheckMenuItem"
  Data$ "GtkTree", "GtkPaned", "SDL_RWops_mem", "SCTextRange", "GdkPointerHooks", "GtkTargetEntry", "GtkCellWidget"
  Data$ "GtkViewport", "GtkHPanedClass", "GtkFrameClass", "GtkToolItem", "GtkDrawingAreaClass", "GTypeModule", "GtkListItem"
  Data$ "GtkButton", "GtkScrollbarClass", "GtkRadioToolButtonClass", "GdkEventProximity", "XML_cp", "GtkCListRow"
  Data$ "GtkHBoxClass", "Uint64", "GtkSizeGroupClass", "SDL_PixelFormat", "GtkScrolledWindow", "GdkPangoAttrEmbossed"
  Data$ "GtkFontButton", "GtkSeparatorMenuItemClass", "GtkMenuBarClass", "GtkVBoxClass", "GtkListStore", "GtkFixedChild"
  Data$ "GParamSpecBoolean", "GtkLayout", "GtkWindowClass", "GtkArrow", "GtkOldEditable", "GParamSpecULong"
  Data$ "GdkColormapClass", "GtkMessageDialog", "GtkInputDialog", "GtkStatusbarClass", "GScanner", "GScannerConfig"
  Data$ "GValue_union", "GParamSpecPointer", "GtkObject", "GTypeValueTable", "GCClosure", "GParamSpecObject", "GtkSizeGroup"
  Data$ "GParamSpecEnum", "GPollFD", "GtkVPaned", "GParamSpecUnichar", "GtkExpander", "GtkDialog", "GtkButtonClass"
  Data$ "GtkRadioButtonClass", "GtkStockItem", "GParamSpecParam", "GdkVisual", "SDL_KeyboardEvent", "GtkTextAppearance"
  Data$ "GtkColorSelectionClass", "GTrashStack", "GtkTreeViewClass", "GtkObjectClass", "GtkComboBoxClass", "GtkFontSelection"
  Data$ "GtkRulerClass", "GdkCursor", "GtkEntryClass", "GParamSpecFlags", "GtkOptionMenuClass", "GtkFontSelectionDialog"
  Data$ "GtkImageMenuItemClass", "GByteArray", "GtkOldEditableClass", "GtkCellPixText", "GtkTooltips", "GtkBinClass"
  Data$ "GtkCellRendererText", "GtkToggleActionClass", "SDL_RWops_stdio", "GtkTreeStoreClass", "XML_Memory_Handling_Suite"
  Data$ "GdkDisplay", "GtkPixmap", "GtkCellLayoutIface", "GdkDisplayManagerClass", "GtkTextMarkClass", "SDL_SysWMmsg"
  Data$ "GtkFileChooserWidget", "GtkTypeInfo", "GHook", "GTypeModuleClass", "GtkDrawingArea", "GdkEventCrossing"
  Data$ "GtkVScrollbar", "GtkEventBox", "GtkMenuItem", "Double", "GtkSocket", "GtkTreeModelFilterClass", "GtkWidgetClass"
  Data$ "GtkRangeClass", "SDL_Cursor", "GtkStyleClass", "GtkTableClass", "GtkScaleClass", "GtkBox", "TextRange"
  Data$ "GtkFontSelectionDialogClass", "GtkGammaCurveClass", "GtkAlignmentClass", "GtkIMMulticontext"
  Data$ "GtkScrolledWindowClass", "GtkColorSelection", "SDL_JoyAxisEvent", "GdkEventFocus", "GdkGCValues", "GtkHRuler"
  Data$ "GParamSpecOverride", "GtkColorSelectionDialog", "GClosure", "GtkTreeDragDestIface", "GTypeClass", "GParamSpecChar"
  Data$ "GtkIMContextSimpleClass", "GdkEventConfigure", "GtkButtonBox"
  ; pbcompiler --listfunctions
  Data$ "AbortFTPFile", "AbortHTTP", "Abs", "ACos", "ACosH", "Add3DArchive", "AddBillboard", "AddCipherBuffer", "AddDate"
  Data$ "AddElement", "AddEntityAnimationTime", "AddFingerprintBuffer", "AddGadgetColumn", "AddGadgetItem", "AddGadgetItem3D"
  Data$ "AddImageFrame", "AddJSONElement", "AddJSONMember", "AddKeyboardShortcut", "AddMailAttachment"
  Data$ "AddMailAttachmentData", "AddMailRecipient", "AddMapElement", "AddMaterialLayer", "AddMeshManualLOD"
  Data$ "AddNodeAnimationTime", "AddPackFile", "AddPackMemory", "AddPathArc", "AddPathBox", "AddPathCircle", "AddPathCurve"
  Data$ "AddPathEllipse", "AddPathLine", "AddPathSegments", "AddPathText", "AddSplinePoint", "AddStaticGeometryEntity"
  Data$ "AddStatusBarField", "AddSubEntity", "AddSubMesh", "AddSysTrayIcon", "AddTerrainTexture", "AddVehicleWheel"
  Data$ "AddVertexPoseReference", "AddWindowTimer", "AESDecoder", "AESEncoder", "AffectedDatabaseRows", "AllocateMemory"
  Data$ "AllocateStructure", "Alpha", "AlphaBlend", "AmbientColor", "AntialiasingMode", "ApplyEntityForce"
  Data$ "ApplyEntityImpulse", "ApplyEntityTorque", "ApplyEntityTorqueImpulse", "ApplyVehicleBrake", "ApplyVehicleForce"
  Data$ "ApplyVehicleSteering", "ArraySize", "Asc", "Ascii", "ASin", "ASinH", "ATan", "ATan2", "ATanH", "AttachEntityObject"
  Data$ "AttachNodeObject", "AttachRibbonEffect", "AudioCDLength", "AudioCDName", "AudioCDStatus", "AudioCDTrackLength"
  Data$ "AudioCDTracks", "AudioCDTrackSeconds", "AvailableProgramOutput", "AvailableSerialPortInput"
  Data$ "AvailableSerialPortOutput", "BackColor", "Base64Decoder", "Base64DecoderBuffer", "Base64Encoder"
  Data$ "Base64EncoderBuffer", "BeginVectorLayer", "BillboardGroupCommonDirection", "BillboardGroupCommonUpVector"
  Data$ "BillboardGroupID", "BillboardGroupMaterial", "BillboardGroupX", "BillboardGroupY", "BillboardGroupZ"
  Data$ "BillboardHeight", "BillboardLocate", "BillboardWidth", "BillboardX", "BillboardY", "BillboardZ", "Bin", "BindEvent"
  Data$ "BindGadgetEvent", "BindMenuEvent", "Blue", "BodyPick", "Box", "BoxedGradient", "BuildMeshLOD"
  Data$ "BuildMeshShadowVolume", "BuildMeshTangents", "BuildStaticGeometry", "BuildTerrain", "ButtonGadget", "ButtonGadget3D"
  Data$ "ButtonImageGadget", "CalendarGadget", "CallCFunction", "CallCFunctionFast", "CallFunction", "CallFunctionFast"
  Data$ "CameraBackColor", "CameraCustomParameter", "CameraDirection", "CameraDirectionX", "CameraDirectionY"
  Data$ "CameraDirectionZ", "CameraFixedYawAxis", "CameraFollow", "CameraFOV", "CameraID", "CameraLookAt", "CameraPitch"
  Data$ "CameraProjectionMode", "CameraProjectionX", "CameraProjectionY", "CameraRange", "CameraReflection"
  Data$ "CameraRenderMode", "CameraRoll", "CameraViewHeight", "CameraViewWidth", "CameraViewX", "CameraViewY", "CameraX"
  Data$ "CameraY", "CameraYaw", "CameraZ", "CanvasGadget", "CanvasOutput", "CanvasVectorOutput", "CatchImage", "CatchJSON"
  Data$ "CatchMusic", "CatchSound", "CatchSprite", "CatchXML", "CGIBuffer", "CGICookieName", "CGICookieValue"
  Data$ "CGIParameterData", "CGIParameterDataSize", "CGIParameterName", "CGIParameterType", "CGIParameterValue"
  Data$ "CGIVariable", "ChangeCurrentElement", "ChangeGamma", "ChangeSysTrayIcon", "CheckBoxGadget", "CheckBoxGadget3D"
  Data$ "CheckDatabaseNull", "CheckFilename", "CheckFTPConnection", "CheckObjectVisibility", "ChildXMLNode", "Chr", "Circle"
  Data$ "CircularGradient", "ClearBillboards", "ClearClipboard", "ClearConsole", "ClearDebugOutput", "ClearGadgetItems"
  Data$ "ClearGadgetItems3D", "ClearJSONElements", "ClearJSONMembers", "ClearList", "ClearMap", "ClearScreen", "ClearSpline"
  Data$ "ClearStructure", "ClipOutput", "ClipPath", "ClipSprite", "CloseConsole", "CloseCryptRandom", "CloseDatabase"
  Data$ "CloseDebugOutput", "CloseFile", "CloseFTP", "CloseGadgetList", "CloseGadgetList3D", "CloseHelp", "CloseLibrary"
  Data$ "CloseNetworkConnection", "CloseNetworkServer", "ClosePack", "ClosePath", "ClosePreferences", "CloseProgram"
  Data$ "CloseScreen", "CloseSerialPort", "CloseSubMenu", "CloseWindow", "CloseWindow3D", "ColorRequester", "ComboBoxGadget"
  Data$ "ComboBoxGadget3D", "CompareMemory", "CompareMemoryString", "ComposeJSON", "ComposeXML", "CompositorEffectParameter"
  Data$ "CompressMemory", "ComputerName", "ComputeSpline", "ConeTwistJoint", "ConicalGradient", "ConnectionID"
  Data$ "ConsoleColor", "ConsoleCursor", "ConsoleError", "ConsoleLocate", "ConsoleTitle", "ContainerGadget"
  Data$ "ContainerGadget3D", "ConvertCoordinateX", "ConvertCoordinateY", "ConvertLocalToWorldPosition"
  Data$ "ConvertWorldToLocalPosition", "CopyArray", "CopyDebugOutput", "CopyDirectory", "CopyEntity", "CopyFile", "CopyImage"
  Data$ "CopyLight", "CopyList", "CopyMap", "CopyMaterial", "CopyMemory", "CopyMemoryString", "CopyMesh", "CopySprite"
  Data$ "CopyStructure", "CopyTexture", "CopyXMLNode", "Cos", "CosH", "CountBillboards", "CountCGICookies"
  Data$ "CountCGIParameters", "CountCPUs", "CountGadgetItems", "CountGadgetItems3D", "CountLibraryFunctions"
  Data$ "CountMaterialLayers", "CountProgramParameters", "CountRegularExpressionGroups", "CountSplinePoints", "CountString"
  Data$ "CPUName", "CreateBillboardGroup", "CreateCamera", "CreateCapsule", "CreateCompositorEffect", "CreateCone"
  Data$ "CreateCube", "CreateCubeMapTexture", "CreateCylinder", "CreateDataMesh", "CreateDialog", "CreateDirectory"
  Data$ "CreateEntity", "CreateEntityBody", "CreateFile", "CreateFTPDirectory", "CreateIcoSphere", "CreateImage"
  Data$ "CreateImageMenu", "CreateJSON", "CreateLensFlareEffect", "CreateLight", "CreateLine3D", "CreateMail"
  Data$ "CreateMaterial", "CreateMenu", "CreateMesh", "CreateMutex", "CreateNetworkServer", "CreateNode"
  Data$ "CreateNodeAnimation", "CreateNodeAnimationKeyFrame", "CreatePack", "CreateParticleEmitter", "CreatePlane"
  Data$ "CreatePopupImageMenu", "CreatePopupMenu", "CreatePreferences", "CreateRegularExpression", "CreateRenderTexture"
  Data$ "CreateRibbonEffect", "CreateSemaphore", "CreateSphere", "CreateSpline", "CreateSprite", "CreateStaticGeometry"
  Data$ "CreateStatusBar", "CreateTerrain", "CreateTerrainBody", "CreateText3D", "CreateTexture", "CreateThread"
  Data$ "CreateToolBar", "CreateTorus", "CreateTube", "CreateVehicle", "CreateVehicleBody", "CreateVertexAnimation"
  Data$ "CreateVertexPoseKeyFrame", "CreateVertexTrack", "CreateWater", "CreateXML", "CreateXMLNode", "CryptRandom"
  Data$ "CryptRandomData", "CustomDashPath", "CustomFilterCallback", "CustomGradient", "DashPath", "DatabaseColumnIndex"
  Data$ "DatabaseColumnName", "DatabaseColumns", "DatabaseColumnSize", "DatabaseColumnType", "DatabaseDriverDescription"
  Data$ "DatabaseDriverName", "DatabaseError", "DatabaseID", "DatabaseQuery", "DatabaseUpdate", "Date", "DateGadget", "Day"
  Data$ "DayOfWeek", "DayOfYear", "DebuggerError", "DebuggerWarning", "DefaultPrinter", "DefineTerrainTile", "Degree"
  Data$ "Delay", "DeleteDirectory", "DeleteElement", "DeleteFile", "DeleteFTPDirectory", "DeleteFTPFile", "DeleteMapElement"
  Data$ "DeleteXMLNode", "DESFingerprint", "DesktopDepth", "DesktopFrequency", "DesktopHeight", "DesktopMouseX"
  Data$ "DesktopMouseY", "DesktopName", "DesktopResolutionX", "DesktopResolutionY", "DesktopScaledX", "DesktopScaledY"
  Data$ "DesktopUnscaledX", "DesktopUnscaledY", "DesktopWidth", "DesktopX", "DesktopY", "DetachEntityObject"
  Data$ "DetachNodeObject", "DetachRibbonEffect", "DialogError", "DialogGadget", "DialogID", "DialogWindow"
  Data$ "DirectoryEntryAttributes", "DirectoryEntryDate", "DirectoryEntryName", "DirectoryEntrySize", "DirectoryEntryType"
  Data$ "DisableEntityBody", "DisableGadget", "DisableGadget3D", "DisableLightShadows", "DisableMaterialLighting"
  Data$ "DisableMenuItem", "DisableParticleEmitter", "DisableToolBarButton", "DisableWindow", "DisableWindow3D"
  Data$ "DisplayPopupMenu", "DisplaySprite", "DisplayTransparentSprite", "DotPath", "DoubleClickTime", "DragFiles"
  Data$ "DragImage", "DragOSFormats", "DragPrivate", "DragText", "DrawAlphaImage", "DrawImage", "DrawingBuffer"
  Data$ "DrawingBufferPitch", "DrawingBufferPixelFormat", "DrawingFont", "DrawingMode", "DrawRotatedText", "DrawText"
  Data$ "DrawVectorImage", "DrawVectorParagraph", "DrawVectorText", "EditorGadget", "EditorGadget3D", "EjectAudioCD"
  Data$ "ElapsedMilliseconds", "Ellipse", "EllipticalGradient", "EnableGadgetDrop", "EnableGraphicalConsole"
  Data$ "EnableHingeJointAngularMotor", "EnableManualEntityBoneControl", "EnableWindowDrop", "EnableWorldCollisions"
  Data$ "EnableWorldPhysics", "EncodeImage", "EndVectorLayer", "Engine3DStatus", "EntityAngularFactor"
  Data$ "EntityAnimationBlendMode", "EntityAnimationStatus", "EntityBonePitch", "EntityBoneRoll", "EntityBoneX"
  Data$ "EntityBoneY", "EntityBoneYaw", "EntityBoneZ", "EntityBoundingBox", "EntityCollide", "EntityCubeMapTexture"
  Data$ "EntityCustomParameter", "EntityDirection", "EntityDirectionX", "EntityDirectionY", "EntityDirectionZ"
  Data$ "EntityFixedYawAxis", "EntityID", "EntityLinearFactor", "EntityLookAt", "EntityMesh", "EntityParentNode"
  Data$ "EntityPitch", "EntityRenderMode", "EntityRoll", "EntityVelocity", "EntityX", "EntityY", "EntityYaw", "EntityZ"
  Data$ "EnvironmentVariableName", "EnvironmentVariableValue", "Eof", "ErrorAddress", "ErrorCode", "ErrorFile", "ErrorLine"
  Data$ "ErrorMessage", "ErrorRegister", "ErrorTargetAddress", "EscapeString", "Event", "EventClient", "EventData"
  Data$ "EventDropAction", "EventDropBuffer", "EventDropFiles", "EventDropImage", "EventDropPrivate", "EventDropSize"
  Data$ "EventDropText", "EventDropType", "EventDropX", "EventDropY", "EventGadget", "EventGadget3D", "EventMenu"
  Data$ "EventServer", "EventTimer", "EventType", "EventType3D", "EventWindow", "EventWindow3D", "ExamineAssembly"
  Data$ "ExamineDatabaseDrivers", "ExamineDesktops", "ExamineDirectory", "ExamineEnvironmentVariables", "ExamineFTPDirectory"
  Data$ "ExamineIPAddresses", "ExamineJoystick", "ExamineJSONMembers", "ExamineKeyboard", "ExamineLibraryFunctions"
  Data$ "ExamineMouse", "ExaminePack", "ExaminePreferenceGroups", "ExaminePreferenceKeys", "ExamineRegularExpression"
  Data$ "ExamineScreenModes", "ExamineWorldCollisions", "ExamineXMLAttributes", "Exp", "ExplorerComboGadget"
  Data$ "ExplorerListGadget", "ExplorerTreeGadget", "ExportJSON", "ExportJSONSize", "ExportXML", "ExportXMLSize"
  Data$ "ExtractJSONArray", "ExtractJSONList", "ExtractJSONMap", "ExtractJSONStructure", "ExtractRegularExpression"
  Data$ "ExtractXMLArray", "ExtractXMLList", "ExtractXMLMap", "ExtractXMLStructure", "FetchEntityMaterial"
  Data$ "FetchOrientation", "FileBuffersSize", "FileFingerprint", "FileID", "FileSeek", "FileSize", "FillArea", "FillMemory"
  Data$ "FillPath", "FillVectorOutput", "FindMapElement", "FindString", "Fingerprint", "FinishCipher", "FinishDatabaseQuery"
  Data$ "FinishDirectory", "FinishFastCGIRequest", "FinishFingerprint", "FinishFTPDirectory", "FinishHTTP", "FinishMesh"
  Data$ "FirstDatabaseRow", "FirstElement", "FirstWorldCollisionEntity", "FlipBuffers", "FlipCoordinatesX"
  Data$ "FlipCoordinatesY", "FlushFileBuffers", "FlushPreferenceBuffers", "Fog", "FontID", "FontRequester", "FormatDate"
  Data$ "FormatNumber", "FormatXML", "FrameGadget", "FrameGadget3D", "FreeArray", "FreeBillboardGroup", "FreeCamera"
  Data$ "FreeDialog", "FreeEffect", "FreeEntity", "FreeEntityBody", "FreeEntityJoints", "FreeFont", "FreeGadget"
  Data$ "FreeGadget3D", "FreeImage", "FreeIP", "FreeJoint", "FreeJSON", "FreeLight", "FreeList", "FreeMail", "FreeMap"
  Data$ "FreeMaterial", "FreeMemory", "FreeMenu", "FreeMesh", "FreeMovie", "FreeMusic", "FreeMutex", "FreeNode"
  Data$ "FreeNodeAnimation", "FreeParticleEmitter", "FreeRegularExpression", "FreeSemaphore", "FreeSound", "FreeSound3D"
  Data$ "FreeSpline", "FreeSprite", "FreeStaticGeometry", "FreeStatusBar", "FreeStructure", "FreeTerrain", "FreeTerrainBody"
  Data$ "FreeText3D", "FreeTexture", "FreeToolBar", "FreeWater", "FreeXML", "FrontColor", "FTPDirectoryEntryAttributes"
  Data$ "FTPDirectoryEntryDate", "FTPDirectoryEntryName", "FTPDirectoryEntryRaw", "FTPDirectoryEntrySize"
  Data$ "FTPDirectoryEntryType", "FTPProgress", "GadgetHeight", "GadgetHeight3D", "GadgetID", "GadgetID3D", "GadgetItemID"
  Data$ "GadgetToolTip", "GadgetToolTip3D", "GadgetType", "GadgetType3D", "GadgetWidth", "GadgetWidth3D", "GadgetX"
  Data$ "GadgetX3D", "GadgetY", "GadgetY3D", "GenericJoint", "GetActiveGadget", "GetActiveGadget3D", "GetActiveWindow"
  Data$ "GetActiveWindow3D", "GetClientIP", "GetClientPort", "GetClipboardImage", "GetClipboardText", "GetCurrentDirectory"
  Data$ "GetDatabaseBlob", "GetDatabaseDouble", "GetDatabaseFloat", "GetDatabaseLong", "GetDatabaseQuad", "GetDatabaseString"
  Data$ "GetEntityAnimationLength", "GetEntityAnimationTime", "GetEntityAnimationWeight", "GetEntityAttribute"
  Data$ "GetEntityCollisionGroup", "GetEntityCollisionMask", "GetEnvironmentVariable", "GetExtensionPart"
  Data$ "GetFileAttributes", "GetFileDate", "GetFilePart", "GetFTPDirectory", "GetFunction", "GetGadgetAttribute"
  Data$ "GetGadgetAttribute3D", "GetGadgetColor", "GetGadgetData", "GetGadgetData3D", "GetGadgetFont"
  Data$ "GetGadgetItemAttribute", "GetGadgetItemColor", "GetGadgetItemData", "GetGadgetItemData3D", "GetGadgetItemState"
  Data$ "GetGadgetItemState3D", "GetGadgetItemText", "GetGadgetItemText3D", "GetGadgetState", "GetGadgetState3D"
  Data$ "GetGadgetText", "GetGadgetText3D", "GetHomeDirectory", "GetHTTPHeader", "GetImageFrame", "GetImageFrameDelay"
  Data$ "GetJointAttribute", "GetJSONBoolean", "GetJSONDouble", "GetJSONElement", "GetJSONFloat", "GetJSONInteger"
  Data$ "GetJSONMember", "GetJSONQuad", "GetJSONString", "GetLightColor", "GetMailAttribute", "GetMailBody"
  Data$ "GetMaterialAttribute", "GetMaterialColor", "GetMenuItemState", "GetMenuItemText", "GetMenuTitleText", "GetMeshData"
  Data$ "GetMusicPosition", "GetMusicRow", "GetNodeAnimationKeyFramePitch", "GetNodeAnimationKeyFrameRoll"
  Data$ "GetNodeAnimationKeyFrameTime", "GetNodeAnimationKeyFrameX", "GetNodeAnimationKeyFrameY"
  Data$ "GetNodeAnimationKeyFrameYaw", "GetNodeAnimationKeyFrameZ", "GetNodeAnimationLength", "GetNodeAnimationTime"
  Data$ "GetNodeAnimationWeight", "GetOriginX", "GetOriginY", "GetPathPart", "GetRuntimeDouble", "GetRuntimeInteger"
  Data$ "GetRuntimeString", "GetScriptMaterial", "GetScriptParticleEmitter", "GetScriptTexture", "GetSerialPortStatus"
  Data$ "GetSoundFrequency", "GetSoundPosition", "GetTemporaryDirectory", "GetTerrainTileHeightAtPoint"
  Data$ "GetTerrainTileLayerBlend", "GetToolBarButtonState", "GetURLPart", "GetUserDirectory", "GetVehicleAttribute", "GetW"
  Data$ "GetWindowColor", "GetWindowData", "GetWindowState", "GetWindowTitle", "GetWindowTitle3D", "GetX", "GetXMLAttribute"
  Data$ "GetXMLEncoding", "GetXMLNodeName", "GetXMLNodeOffset", "GetXMLNodeText", "GetXMLStandalone", "GetY", "GetZ"
  Data$ "GrabDrawingImage", "GrabImage", "GrabSprite", "GradientColor", "Green", "Hex", "HideBillboardGroup", "HideEffect"
  Data$ "HideEntity", "HideGadget", "HideGadget3D", "HideLight", "HideMenu", "HideParticleEmitter", "HideWindow"
  Data$ "HideWindow3D", "HingeJoint", "HingeJointMotorTarget", "Hostname", "Hour", "HTTPInfo", "HTTPMemory", "HTTPProgress"
  Data$ "HTTPProxy", "HTTPRequest", "HTTPRequestMemory", "HyperLinkGadget", "ImageDepth", "ImageFormat", "ImageFrameCount"
  Data$ "ImageGadget", "ImageGadget3D", "ImageHeight", "ImageID", "ImageOutput", "ImageVectorOutput", "ImageWidth"
  Data$ "Infinity", "InitAudioCD", "InitCGI", "InitEngine3D", "InitFastCGI", "InitializeStructure", "InitJoystick"
  Data$ "InitKeyboard", "InitMouse", "InitMovie", "InitNetwork", "InitScintilla", "InitSound", "InitSprite", "Inkey", "Input"
  Data$ "InputEvent3D", "InputRequester", "InsertElement", "InsertJSONArray", "InsertJSONList", "InsertJSONMap"
  Data$ "InsertJSONStructure", "InsertString", "InsertXMLArray", "InsertXMLList", "InsertXMLMap", "InsertXMLStructure"
  Data$ "InstructionAddress", "InstructionString", "Int", "IntQ", "IPAddressField", "IPAddressGadget", "IPString"
  Data$ "IsBillboardGroup", "IsCamera", "IsCipher", "IsDatabase", "IsDialog", "IsDirectory", "IsEffect", "IsEntity", "IsFile"
  Data$ "IsFingerprint", "IsFont", "IsFTP", "IsGadget", "IsGadget3D", "IsImage", "IsInfinity", "IsInsidePath"
  Data$ "IsInsideStroke", "IsJoint", "IsJSON", "IsLibrary", "IsLight", "IsMail", "IsMaterial", "IsMenu", "IsMesh", "IsMovie"
  Data$ "IsMusic", "IsNAN", "IsNode", "IsParticleEmitter", "IsPathEmpty", "IsProgram", "IsRegularExpression", "IsRuntime"
  Data$ "IsScreenActive", "IsSerialPort", "IsSound", "IsSound3D", "IsSprite", "IsStaticGeometry", "IsStatusBar"
  Data$ "IsSysTrayIcon", "IsText3D", "IsTexture", "IsThread", "IsToolBar", "IsWindow", "IsWindow3D", "IsXML", "JoystickAxisX"
  Data$ "JoystickAxisY", "JoystickAxisZ", "JoystickButton", "JoystickName", "JSONArraySize", "JSONErrorLine"
  Data$ "JSONErrorMessage", "JSONErrorPosition", "JSONMemberKey", "JSONMemberValue", "JSONObjectSize", "JSONType"
  Data$ "JSONValue", "KeyboardInkey", "KeyboardMode", "KeyboardPushed", "KeyboardReleased", "KillProgram", "KillThread"
  Data$ "LastElement", "LCase", "Left", "Len", "LensFlareEffectColor", "LibraryFunctionAddress", "LibraryFunctionName"
  Data$ "LibraryID", "LightAttenuation", "LightDirection", "LightDirectionX", "LightDirectionY", "LightDirectionZ", "LightID"
  Data$ "LightLookAt", "LightPitch", "LightRoll", "LightX", "LightY", "LightYaw", "LightZ", "Line", "LinearGradient"
  Data$ "LineXY", "ListIconGadget", "ListIndex", "ListSize", "ListViewGadget", "ListViewGadget3D", "LoadFont", "LoadImage"
  Data$ "LoadJSON", "LoadMesh", "LoadMovie", "LoadMusic", "LoadSound", "LoadSound3D", "LoadSprite", "LoadTexture"
  Data$ "LoadWorld", "LoadXML", "Loc", "LockMutex", "Lof", "Log", "Log10", "LSet", "LTrim", "MailProgress", "MainXMLNode"
  Data$ "MakeIPAddress", "MapKey", "MapSize", "MatchRegularExpression", "MaterialAnimation", "MaterialBlendingMode"
  Data$ "MaterialCullingMode", "MaterialFilteringMode", "MaterialFog", "MaterialID", "MaterialShadingMode"
  Data$ "MaterialShininess", "MaterialTextureAliases", "MemorySize", "MemoryStatus", "MemoryStringLength", "MenuBar"
  Data$ "MenuHeight", "MenuID", "MenuItem", "MenuTitle", "MergeLists", "MeshFace", "MeshID", "MeshIndex", "MeshIndexCount"
  Data$ "MeshPoseCount", "MeshPoseName", "MeshRadius", "MeshVertex", "MeshVertexColor", "MeshVertexCount", "MeshVertexNormal"
  Data$ "MeshVertexPosition", "MeshVertexTangent", "MeshVertexTextureCoordinate", "MessageRequester", "Mid", "Minute", "Mod"
  Data$ "Month", "MouseButton", "MouseDeltaX", "MouseDeltaY", "MouseLocate", "MousePick", "MouseRayCast", "MouseWheel"
  Data$ "MouseX", "MouseY", "MoveBillboard", "MoveBillboardGroup", "MoveCamera", "MoveElement", "MoveEntity"
  Data$ "MoveEntityBone", "MoveLight", "MoveMemory", "MoveNode", "MoveParticleEmitter", "MovePathCursor", "MoveText3D"
  Data$ "MoveXMLNode", "MovieAudio", "MovieHeight", "MovieInfo", "MovieLength", "MovieSeek", "MovieStatus", "MovieWidth"
  Data$ "MusicVolume", "NaN", "NetworkClientEvent", "NetworkServerEvent", "NewPrinterPage", "NewVectorPage"
  Data$ "NextDatabaseDriver", "NextDatabaseRow", "NextDirectoryEntry", "NextElement", "NextEnvironmentVariable"
  Data$ "NextFTPDirectoryEntry", "NextInstruction", "NextIPAddress", "NextJSONMember", "NextLibraryFunction"
  Data$ "NextMapElement", "NextPackEntry", "NextPreferenceGroup", "NextPreferenceKey", "NextRegularExpressionMatch"
  Data$ "NextScreenMode", "NextSelectedFileName", "NextWorldCollision", "NextXMLAttribute", "NextXMLNode"
  Data$ "NodeAnimationStatus", "NodeFixedYawAxis", "NodeID", "NodeLookAt", "NodePitch", "NodeRoll", "NodeX", "NodeY"
  Data$ "NodeYaw", "NodeZ", "NormalizeMesh", "NormalX", "NormalY", "NormalZ", "OnErrorCall", "OnErrorDefault", "OnErrorExit"
  Data$ "OnErrorGoto", "OpenConsole", "OpenCryptRandom", "OpenDatabase", "OpenDatabaseRequester", "OpenFile"
  Data$ "OpenFileRequester", "OpenFTP", "OpenGadgetList", "OpenGadgetList3D", "OpenGLGadget", "OpenHelp", "OpenLibrary"
  Data$ "OpenNetworkConnection", "OpenPack", "OpenPreferences", "OpenScreen", "OpenSerialPort", "OpenSubMenu", "OpenWindow"
  Data$ "OpenWindow3D", "OpenWindowedScreen", "OpenXMLDialog", "OptionGadget", "OptionGadget3D", "OSVersion", "OutputDepth"
  Data$ "OutputHeight", "OutputWidth", "PackEntryName", "PackEntrySize", "PackEntryType", "PanelGadget", "PanelGadget3D"
  Data$ "ParentXMLNode", "Parse3DScripts", "ParseDate", "ParseJSON", "ParseXML", "ParticleAcceleration", "ParticleAngle"
  Data$ "ParticleColorFader", "ParticleColorRange", "ParticleEmissionRate", "ParticleEmitterAngle"
  Data$ "ParticleEmitterDirection", "ParticleEmitterID", "ParticleEmitterX", "ParticleEmitterY", "ParticleEmitterZ"
  Data$ "ParticleMaterial", "ParticleScaleRate", "ParticleSize", "ParticleSpeedFactor", "ParticleTimeToLive"
  Data$ "ParticleVelocity", "PathBoundsHeight", "PathBoundsWidth", "PathBoundsX", "PathBoundsY", "PathCursorX", "PathCursorY"
  Data$ "PathLength", "PathPointAngle", "PathPointX", "PathPointY", "PathRequester", "PathSegments", "PauseAudioCD"
  Data$ "PauseMovie", "PauseSound", "PauseThread", "PdfVectorOutput", "PeekA", "PeekB", "PeekC", "PeekD", "PeekF", "PeekI"
  Data$ "PeekL", "PeekQ", "PeekS", "PeekU", "PeekW", "PickX", "PickY", "PickZ", "Pitch", "PlayAudioCD", "PlayMovie"
  Data$ "PlayMusic", "PlaySound", "PlaySound3D", "Plot", "Point", "PointJoint", "PointPick", "PokeA", "PokeB", "PokeC"
  Data$ "PokeD", "PokeF", "PokeI", "PokeL", "PokeQ", "PokeS", "PokeU", "PokeW", "PopListPosition", "PopMapPosition"
  Data$ "PostEvent", "Pow", "PreferenceComment", "PreferenceGroup", "PreferenceGroupName", "PreferenceKeyName"
  Data$ "PreferenceKeyValue", "PreviousDatabaseRow", "PreviousElement", "PreviousXMLNode", "Print", "PrinterOutput"
  Data$ "PrinterPageHeight", "PrinterPageWidth", "PrinterVectorOutput", "PrintN", "PrintRequester", "ProgramExitCode"
  Data$ "ProgramFilename", "ProgramID", "ProgramParameter", "ProgramRunning", "ProgressBarGadget", "ProgressBarGadget3D"
  Data$ "PurifierGranularity", "PushListPosition", "PushMapPosition", "Radian", "RaiseError", "Random", "RandomData"
  Data$ "RandomizeArray", "RandomizeList", "RandomSeed", "RawKey", "RayCast", "RayCollide", "RayPick", "ReadAsciiCharacter"
  Data$ "ReadByte", "ReadCGI", "ReadCharacter", "ReadConsoleData", "ReadData", "ReadDouble", "ReadFile", "ReadFloat"
  Data$ "ReadInteger", "ReadLong", "ReadPreferenceDouble", "ReadPreferenceFloat", "ReadPreferenceInteger"
  Data$ "ReadPreferenceLong", "ReadPreferenceQuad", "ReadPreferenceString", "ReadProgramData", "ReadProgramError"
  Data$ "ReadProgramString", "ReadQuad", "ReadSerialPortData", "ReadString", "ReadStringFormat", "ReadUnicodeCharacter"
  Data$ "ReadWord", "ReAllocateMemory", "ReceiveFTPFile", "ReceiveHTTPFile", "ReceiveHTTPMemory", "ReceiveNetworkData", "Red"
  Data$ "RefreshDialog", "RegisterFontFile", "RegularExpressionError", "RegularExpressionGroup"
  Data$ "RegularExpressionGroupLength", "RegularExpressionGroupPosition", "RegularExpressionMatchLength"
  Data$ "RegularExpressionMatchPosition", "RegularExpressionMatchString", "RegularExpressionNamedGroup"
  Data$ "RegularExpressionNamedGroupLength", "RegularExpressionNamedGroupPosition", "ReleaseMouse", "ReloadMaterial"
  Data$ "RemoveBillboard", "RemoveEnvironmentVariable", "RemoveGadgetColumn", "RemoveGadgetItem", "RemoveGadgetItem3D"
  Data$ "RemoveImageFrame", "RemoveJSONElement", "RemoveJSONMember", "RemoveKeyboardShortcut", "RemoveMailRecipient"
  Data$ "RemoveMaterialLayer", "RemovePreferenceGroup", "RemovePreferenceKey", "RemoveString", "RemoveSysTrayIcon"
  Data$ "RemoveWindowTimer", "RemoveXMLAttribute", "RenameFile", "RenameFTPFile", "RenderWorld", "ReplaceRegularExpression"
  Data$ "ReplaceString", "ResetCoordinates", "ResetGradientColors", "ResetList", "ResetMap", "ResetMaterial", "ResetPath"
  Data$ "ResetProfiler", "ResetStructure", "ResizeBillboard", "ResizeCamera", "ResizeGadget", "ResizeGadget3D", "ResizeImage"
  Data$ "ResizeJSONElements", "ResizeMovie", "ResizeParticleEmitter", "ResizeWindow", "ResizeWindow3D"
  Data$ "ResolveXMLAttributeName", "ResolveXMLNodeName", "RestoreVectorState", "ResumeAudioCD", "ResumeMovie", "ResumeSound"
  Data$ "ResumeThread", "ReverseString", "RGB", "RGBA", "RibbonEffectColor", "RibbonEffectWidth", "Right", "Roll"
  Data$ "RootXMLNode", "RotateBillboardGroup", "RotateCamera", "RotateCoordinates", "RotateEntity", "RotateEntityBone"
  Data$ "RotateLight", "RotateMaterial", "RotateNode", "RotateSprite", "Round", "RoundBox", "RSet", "RTrim", "RunProgram"
  Data$ "SaveDebugOutput", "SaveFileRequester", "SaveImage", "SaveJSON", "SaveMesh", "SaveRenderTexture", "SaveSprite"
  Data$ "SaveTerrain", "SaveVectorState", "SaveXML", "ScaleCoordinates", "ScaleEntity", "ScaleMaterial", "ScaleNode"
  Data$ "ScaleText3D", "ScintillaGadget", "ScintillaSendMessage", "ScreenDepth", "ScreenHeight", "ScreenID"
  Data$ "ScreenModeDepth", "ScreenModeHeight", "ScreenModeRefreshRate", "ScreenModeWidth", "ScreenOutput", "ScreenWidth"
  Data$ "ScrollAreaGadget", "ScrollAreaGadget3D", "ScrollBarGadget", "ScrollBarGadget3D", "ScrollMaterial", "Second"
  Data$ "SecondWorldCollisionEntity", "SelectedFilePattern", "SelectedFontColor", "SelectedFontName", "SelectedFontSize"
  Data$ "SelectedFontStyle", "SelectElement", "SendFTPFile", "SendMail", "SendNetworkData", "SendNetworkString"
  Data$ "SerialPortError", "SerialPortID", "SerialPortTimeouts", "ServerID", "SetActiveGadget", "SetActiveGadget3D"
  Data$ "SetActiveWindow", "SetActiveWindow3D", "SetClipboardImage", "SetClipboardText", "SetCurrentDirectory"
  Data$ "SetDatabaseBlob", "SetDatabaseDouble", "SetDatabaseFloat", "SetDatabaseLong", "SetDatabaseNull", "SetDatabaseQuad"
  Data$ "SetDatabaseString", "SetDragCallback", "SetDropCallback", "SetEntityAnimationLength", "SetEntityAnimationTime"
  Data$ "SetEntityAnimationWeight", "SetEntityAttribute", "SetEntityCollisionFilter", "SetEntityMaterial"
  Data$ "SetEnvironmentVariable", "SetFileAttributes", "SetFileDate", "SetFrameRate", "SetFTPDirectory", "SetGadgetAttribute"
  Data$ "SetGadgetAttribute3D", "SetGadgetColor", "SetGadgetData", "SetGadgetData3D", "SetGadgetFont"
  Data$ "SetGadgetItemAttribute", "SetGadgetItemColor", "SetGadgetItemData", "SetGadgetItemData3D", "SetGadgetItemImage"
  Data$ "SetGadgetItemState", "SetGadgetItemState3D", "SetGadgetItemText", "SetGadgetItemText3D", "SetGadgetState"
  Data$ "SetGadgetState3D", "SetGadgetText", "SetGadgetText3D", "SetGUITheme3D", "SetImageFrame", "SetImageFrameDelay"
  Data$ "SetJointAttribute", "SetJSONArray", "SetJSONBoolean", "SetJSONDouble", "SetJSONFloat", "SetJSONInteger"
  Data$ "SetJSONNull", "SetJSONObject", "SetJSONQuad", "SetJSONString", "SetLightColor", "SetMailAttribute", "SetMailBody"
  Data$ "SetMaterialAttribute", "SetMaterialColor", "SetMenuItemState", "SetMenuItemText", "SetMenuTitleText", "SetMeshData"
  Data$ "SetMeshMaterial", "SetMusicPosition", "SetNodeAnimationKeyFramePosition", "SetNodeAnimationKeyFrameRotation"
  Data$ "SetNodeAnimationKeyFrameScale", "SetNodeAnimationLength", "SetNodeAnimationTime", "SetNodeAnimationWeight"
  Data$ "SetOrientation", "SetOrigin", "SetRenderQueue", "SetRuntimeDouble", "SetRuntimeInteger", "SetRuntimeString"
  Data$ "SetSerialPortStatus", "SetSoundFrequency", "SetSoundPosition", "SetTerrainTileHeightAtPoint"
  Data$ "SetTerrainTileLayerBlend", "SetToolBarButtonState", "SetupTerrains", "SetURLPart", "SetVehicleAttribute"
  Data$ "SetWindowColor", "SetWindowData", "SetWindowState", "SetWindowTitle", "SetWindowTitle3D", "SetXMLAttribute"
  Data$ "SetXMLEncoding", "SetXMLNodeName", "SetXMLNodeOffset", "SetXMLNodeText", "SetXMLStandalone", "ShortcutGadget"
  Data$ "ShowAssemblyViewer", "ShowCallstack", "ShowDebugOutput", "ShowGUI", "ShowLibraryViewer", "ShowMemoryViewer"
  Data$ "ShowProfiler", "ShowVariableViewer", "ShowWatchlist", "Sign", "SignalSemaphore", "Sin", "SinH", "SkewCoordinates"
  Data$ "SkyBox", "SkyDome", "SliderJoint", "SmartWindowRefresh", "SortArray", "SortList", "SortStructuredArray"
  Data$ "SortStructuredList", "SoundCone3D", "SoundID3D", "SoundLength", "SoundListenerLocate", "SoundPan", "SoundRange3D"
  Data$ "SoundStatus", "SoundVolume", "SoundVolume3D", "Space", "SpinGadget", "SpinGadget3D", "SplinePointX", "SplinePointY"
  Data$ "SplinePointZ", "SplineX", "SplineY", "SplineZ", "SplitList", "SplitterGadget", "SpotLightRange"
  Data$ "SpriteBlendingMode", "SpriteCollision", "SpriteDepth", "SpriteHeight", "SpriteID", "SpriteOutput"
  Data$ "SpritePixelCollision", "SpriteQuality", "SpriteWidth", "Sqr", "StartAESCipher", "StartDrawing"
  Data$ "StartEntityAnimation", "StartFingerprint", "StartNodeAnimation", "StartPrinting", "StartProfiler"
  Data$ "StartVectorDrawing", "StatusBarHeight", "StatusBarID", "StatusBarImage", "StatusBarProgress", "StatusBarText"
  Data$ "StickyWindow", "StopAudioCD", "StopDrawing", "StopEntityAnimation", "StopMovie", "StopMusic", "StopNodeAnimation"
  Data$ "StopPrinting", "StopProfiler", "StopSound", "StopSound3D", "StopVectorDrawing", "Str", "StrD", "StrF"
  Data$ "StringByteLength", "StringField", "StringFingerprint", "StringGadget", "StringGadget3D", "StrokePath", "StrU"
  Data$ "SubMeshCount", "Sun", "SvgVectorOutput", "SwapElements", "SwitchCamera", "SysTrayIconToolTip", "Tan", "Bool"
  Data$ "Defined", "OffsetOf", "SizeOf", "TanH", "TerrainHeight", "TerrainLocate", "TerrainMousePick", "TerrainRenderMode"
  Data$ "TerrainTileHeightAtPosition", "TerrainTileLayerMapSize", "TerrainTilePointX", "TerrainTilePointY", "TerrainTileSize"
  Data$ "Text3DAlignment", "Text3DCaption", "Text3DColor", "Text3DID", "Text3DX", "Text3DY", "Text3DZ", "TextGadget"
  Data$ "TextGadget3D", "TextHeight", "TextureHeight", "TextureID", "TextureOutput", "TextureWidth", "TextWidth", "ThreadID"
  Data$ "ThreadPriority", "ToolBarButtonText", "ToolBarHeight", "ToolBarID", "ToolBarImageButton", "ToolBarSeparator"
  Data$ "ToolBarStandardButton", "ToolBarToolTip", "TrackBarGadget", "TransformMesh", "TransformSprite"
  Data$ "TranslateCoordinates", "TransparentSpriteColor", "TreeGadget", "TreeGadget3D", "Trim", "TruncateFile"
  Data$ "TryLockMutex", "TrySemaphore", "TypeOf", "Subsystem", "UCase", "UnbindEvent", "UnbindGadgetEvent", "UnbindMenuEvent"
  Data$ "UnclipOutput", "UncompressMemory", "UncompressPackFile", "UncompressPackMemory", "UnescapeString", "UnlockMutex"
  Data$ "UpdateEntityAnimation", "UpdateMesh", "UpdateMeshBoundingBox", "UpdateRenderTexture", "UpdateSplinePoint"
  Data$ "UpdateTerrain", "UpdateTerrainTileLayerBlend", "UpdateVertexPoseReference", "URLDecoder", "URLEncoder", "UseAudioCD"
  Data$ "UseBriefLZPacker", "UseCRC32Fingerprint", "UseFLACSoundDecoder", "UseGadgetList", "UseGIFImageDecoder"
  Data$ "UseJCALG1Packer", "UseJPEG2000ImageDecoder", "UseJPEG2000ImageEncoder", "UseJPEGImageDecoder", "UseJPEGImageEncoder"
  Data$ "UseLZMAPacker", "UseMD5Fingerprint", "UseMySQLDatabase", "UseODBCDatabase", "UseOGGSoundDecoder"
  Data$ "UsePNGImageDecoder", "UsePNGImageEncoder", "UsePostgreSQLDatabase", "UserName", "UseSHA1Fingerprint"
  Data$ "UseSHA2Fingerprint", "UseSHA3Fingerprint", "UseSQLiteDatabase", "UseTARPacker", "UseTGAImageDecoder"
  Data$ "UseTIFFImageDecoder", "UseZipPacker", "UTF8", "Val", "ValD", "ValF", "VectorFont", "VectorOutputHeight"
  Data$ "VectorOutputWidth", "VectorParagraphHeight", "VectorResolutionX", "VectorResolutionY"
  Data$ "VectorSourceCircularGradient", "VectorSourceColor", "VectorSourceGradientColor", "VectorSourceImage"
  Data$ "VectorSourceLinearGradient", "VectorTextHeight", "VectorTextWidth", "VectorUnit", "VertexPoseReferenceCount"
  Data$ "WaitFastCGIRequest", "WaitProgram", "WaitSemaphore", "WaitThread", "WaitWindowEvent", "WaterColor", "WaterHeight"
  Data$ "WebGadget", "WindowBounds", "WindowEvent", "WindowEvent3D", "WindowHeight", "WindowHeight3D", "WindowID"
  Data$ "WindowID3D", "WindowMouseX", "WindowMouseY", "WindowOutput", "WindowVectorOutput", "WindowWidth", "WindowWidth3D"
  Data$ "WindowX", "WindowX3D", "WindowY", "WindowY3D", "WorldCollisionAppliedImpulse", "WorldCollisionContact"
  Data$ "WorldCollisionNormal", "WorldDebug", "WorldGravity", "WorldShadows", "WriteAsciiCharacter", "WriteByte"
  Data$ "WriteCGIData", "WriteCGIFile", "WriteCGIHeader", "WriteCGIString", "WriteCGIStringN", "WriteCharacter"
  Data$ "WriteConsoleData", "WriteData", "WriteDouble", "WriteFloat", "WriteInteger", "WriteLong", "WritePreferenceDouble"
  Data$ "WritePreferenceFloat", "WritePreferenceInteger", "WritePreferenceLong", "WritePreferenceQuad"
  Data$ "WritePreferenceString", "WriteProgramData", "WriteProgramString", "WriteProgramStringN", "WriteQuad"
  Data$ "WriteSerialPortData", "WriteSerialPortString", "WriteString", "WriteStringFormat", "WriteStringN"
  Data$ "WriteUnicodeCharacter", "WriteWord", "XMLAttributeName", "XMLAttributeValue", "XMLChildCount", "XMLError"
  Data$ "XMLErrorLine", "XMLErrorPosition", "XMLNodeFromID", "XMLNodeFromPath", "XMLNodePath", "XMLNodeType", "XMLStatus"
  Data$ "Yaw", "Year", "ZoomSprite"
  ; Native object value types
  Data$ "a", "b", "c", "d", "f", "i", "l", "q", "s", "u", "w"
  ; Other native constants
  Data$ "#CRLF$", "#CRLF", "#CR$", "#CR", "#LF$", "#LF", "#TAB", "#TAB$", "#DQUOTE$", "#True", "#False", "#Null", "#Null$"
  Data$ "#LFCR", "#LFCR$"
  ; --
  Data$ ""
EndDataSection
