;   Description: Provides many functions to create PDF files
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=72031
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=31241
; -----------------------------------------------------------------------------

;/ ============================
;/ =     pbPDF-Module.pbi     =
;/ ============================
;/
;/ [ PB V5.7x / All OS ]
;/
;/  © 2019 Thorsten1867 (12/2018)
;/ ( based on 'PurePDF' by LuckyLuke / ABBKlaus / normeus )
;/

;{ ===== MIT License =====
;
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

; Last Update: 20.02.2019

; [20.02.2019] Added:   AddGotoLabel() / AddGotoAction() / TextField() / ButtonField() / ChoiceField() 
; [20.02.2019] Changed: Internal structure completely revised and adapted to the structure of PDF documents.


; ----- Description -----
; - PNG / JPEG / JPEG2000 support
; - Compression with internal PB packer library
; - Embedding fonts (TTF) for all OS
; - Unicode support
; - Encryption (Passwords & Permissions)
; - PDF forms (AcroForms)

;{ ===== Module Commands ===== 

  ; ----- Basic Commands -----

  ; PDF::Create()                      - Create PDF document.
  ; PDF::AddPage()                     - Adds a (new) page to the document.
  ; PDF::BookMark()                    - Add bookmark
  ; PDF::Cell()                        - Prints a cell (rectangular area) with optional borders, background color and character string.
  ; PDF::DividingLine()                - Draws a line with the specified width.
  ; PDF::GetFontSize()                 - Get current fontsize (#Point/#Unit)
  ; PDF::GetMargin()                   - Get left, top, right or cell margin.
  ; PDF::GetMultiCellLines()           - Get the last value of newlines for pdf_MultiCell()
  ; PDF::GetPageHeight()               - Get current height of page.
  ; PDF::GetPageNumber()               - Returns the current page number.
  ; PDF::GetPageWidth()                - Get current width of page. 
  ; PDF::GetPosX()                     - Returns the abscissa of the current position.
  ; PDF::GetPosY()                     - Returns the ordinate of the current position.
  ; PDF::GetStringWidth()              - Get width of a string in the current font.
  ; PDF::Image()                       - Puts an image in the page.
  ; PDF::Ln()                          - Performs a line break.
  ; PDF::MultiCell()                   - This method allows printing text with line breaks.
  ; PDF::MultiCellList()               - Add multicell with list elements
  ; PDF::PlaceText()                   - Place text at x, y position.  
  ; PDF::Rotate()                      - Perform a rotation around a given center.
  ; PDF::Save()                        - Save PDF under file name
  ; PDF::SetAutoPageBreak()            - Set auto page break mode and triggering margin.
  ; PDF::SetColorRGB()                 - Set RGB color for text, draw and fill  (#TextColor / #DrawColor / #FillColor).
  ; PDF::SetDashedLine()               - Set a dash pattern and draw dashed lines or rectangles.
  ; PDF::SetFont()                     - Sets the font used to print character strings.
  ; PDF::SetFontSize()                 - Defines the size of the current font.
  ; PDF::SetPageNumbering()            - Set page numbering in footer #True/#False.
  ; PDF::SetInfo()                     - Defines author, titel, subject, creator and associated keywords ('keyword1 keyword2 ...') of the document
  ; PDF::SetLineThickness()            - Defines the line thickness.
  ; PDF::SetMargin()                   - Set left, top, right or cell margin.
  ; PDF::SetPageMargins()              - Set left, top and right page margins.
  ; PDF::SetPosXY()                    - Defines the abscissa and ordinate of the current position.
  ; PDF::SetPosX()                     - Defines the abscissa of the current position. 
  ; PDF::SetPosY()                     - Moves the current abscissa back to the left margin and sets the ordinate.
  ; PDF::SubWrite()                    - Write superscripted or supscripted
  ; PDF::TruncateCell()                - Prints a Cell, if text is too large it will be truncated
  ; PDF::Write()                       - This method prints text from the current position.
  
  ; ----- Advanced Commands -----
  
  ; PDF::EmbedFile()                   - Embeds a file into the pdf.
  ; PDF::EmbedFont()                   - Embeds a font into the pdf and returns the font name.
  ; PDF::EmbedJavaScript()             - Add JavaScript
  ; PDF::EmbedJavaScriptFile()         - Include JavaScript file
  ; PDF::EnableFooter()                - Enable/disable Footer (procedure)
  ; PDF::EnableHeader()                - Enable/disable Header (procedure)
  ; PDF::EnableTOCNums()               - Enable/disable adding page numbers to table of contents
  ; PDF::AddEntryTOC()                 - Add TOC entry
  ; PDF::EscapeText()                  - Format a text string (=> masked string).
  ; PDF::GetErrorCode()                - Return the error code.
  ; PDF::GetErrorMessage()             - Return the error message.    
  ; PDF::GetNumbering()                - Return if numbering is #True/#False. Usefull for TOC functions
  ; PDF::GetObjectNum()                - Get object number
  ; PDF::GetScaleFactor()              - Get scale factor for used unit.
  ; PDF::GetWordSpacing()              - Get word spacing.  
  ; PDF::ImageMemory()                 - Puts an image (Memory) in the page.
  ; PDF::InsertTOC()                   - Insert table of contents.
  ; PDF::Link()                        - Puts a link on a rectangular area of the page.
  ; PDF::SetAliasTotalPages()          - Defines an alias for the total number of pages.
  ; PDF::SetColorCMYK()                - Set CMYK color for text, draw and fill (#TextColor / #DrawColor / #FillColor).
  ; PDF::SetEncryption()               - Enable encryption and set passworts and permission
  ; PDF::SetFooterProcedure()          - Set footer procedure.
  ; PDF::SetHeaderProcedure()          - Set header procedure.
  ; PDF::SetOpenAction()               - Set page and zoom for opening the document
  ; PDF::SetPageCompression()          - Enable/disable compression for pages
  ; PDF::SetPageLayout()               - Define display mode for pages in the viewer
  ; PDF::SetPageMode()                 - Define mode and appearance of the viewer (e.g. fullscreen mode)
  ; PDF::SetViewerPreferences()        - Set viewer preferences
  ; PDF::SetWordSpacing()              - Set word spacing. 
  
  ; ----- AcroForms [#Enable_AcroFormCommands] ------
  
  ; PDF::ButtonField()                 - Button field (PushButton / CheckBox / RadioButton)
  ; PDF::ChoiceField()                 - Choice field (Scrolling List / ComboBox / editable ComboBox)
  ; PDF::TextField()                   - Text field   (single line/ multiline)
  
  ; ----- Annotations & Actions [#Enable_Annotations] -----
  
  ; PDF::AddFileLink()                 - Defines the page and position for embedded file annotations. (#GraphIcon/#PaperClipIcon/#PushPinIcon/#TagIcon)
  ; PDF::AddGotoAction()               - Goto page and position in the document
  ; PDF::AddGotoLabel()                - Set Label to be able to jump to this position
  ; PDF::AddLaunchAction()             - Defines the page and position for a launch action. (#OpenAction/#PrintAction)
  ; PDF::AddLinkURL)                   - Defines the page and position a link points to and returns its identifier.
  ; PDF::AddTextNote()                 - Defines the page and position for text annotations. ( #CommentIcon/#KeyIcon/#NoteIcon/#HelpIcon/#NewParagraphIcon/#ParagraphIcon/#InsertIcon )
  
  ; ----- Drawing Commands [#Enable_DrawingCommands] -----
  
  ; PDF::DrawCircle()                  - Draws a circle
  ; PDF::DrawEllipse()                 - Draws a ellipse
  ; PDF::DrawGrid()                    - Draws a light blue grid on the page for testing purposes
  ; PDF::DrawLine()                    - Draws a single line between two points.
  ; PDF::DrawRectangle()               - Draws a rectangle.
  ; PDF::DrawRoundedRectangle()        - Draws a rounded rectangle.
  ; PDF::DrawSector()                  - Draws the sector of a circle.
  ; PDF::DrawTriangle()                - Draws a triangle
  
  ; PDF::SetLineCap()                  - Sets the line cap style
  ; PDF::SetLineCorner()               - Sets the line join style.
  
  ; PDF::PathArc()                     - Draws a cubic Bezier curve to the current path.
  ; PDF::PathBegin()                   - Begins a new path at the coordinates (x, y).
  ; PDF::PathEnd()                     - Closes the current path and draws a line from the current point to the starting point.
  ; PDF::PathLine()                    - Draws a line from the current point to (x, y).
  ; PDF::PathRect()                    - Draws a rectangle to the current path with upper-left corner (x, y) and dimensions (w, h). 
  
  ; ----- Transformation [#Enable_TransformCommands] -----
  
  ; PDF::StartTransform()              - Use this before calling any transformation. (Scale, Skew, Mirror, Translate)
  ; PDF::StopTransform()               - Restore the normal painting And placing behaviour As it was before calling pdf_StartTransform(). 
  ; PDF::MirrorHorizontal()            - Alias for scaling -100% in x direction. (Transform)
  ; PDF::MirrorVertical()              - Alias For scaling -100% in y direction. (Transform)
  ; PDF::ScaleHorizontal()             - Scaling horizontal        (Transform)
  ; PDF::ScaleVertical()               - Scaling vertical          (Transform)
  ; PDF::Scale()                       - Scaling                   (Transform)
  ; PDF::SkewHorizontal()              - Skewing -> angle x        (Transform)
  ; PDF::SkewVertical()                - Skewing -> angle y        (Transform)
  ; PDF::Translate()                   - Translate -> right/bottom (Transform)
  ; PDF::TranslateHorizontal()         - Translate -> right        (Transform)
  ; PDF::TranslateVertical()           - Translate -> bottom       (Transform)
  
;} ===========================

;- ===========================================================================
;-   DeclareModule
;- ===========================================================================

DeclareModule PDF
  
  #Enable_AcroFormCommands  = #True
  #Enable_Annotations       = #True
  #Enable_DrawingCommands   = #True
  #Enable_TransformCommands = #True
  
  ; ===== Country specific adjustments ==================
  #DefaultLanguage          = "DE" ; DE / AT / GB / US / FR / ES / IT
  #DefaultTimeZoneOffset    = 1
  #DefaultDecimalPoint      = ","
  #DefaultUnit              = "mm"
  #DefaultPageFormat        = "595.28,841.89" ; #Format_A4
  ; =====================================================   
  
  ;{ ===== Constants =====
  #Bullet$ = "•"
  #NoLink = -1
  ;{ ----- AcroForms:   TextField() / ChoiceField() -----
  #Form_CheckBox          = 0
  #Form_SingleLine        = 0
  #Form_ReadOnly          = 1
  #Form_Required          = 1<<1
  #Form_NoExport          = 1<<2
  #Form_MultiLine         = 1<<12
  #Form_Password          = 1<<13
  #Form_NoToggleToOff     = 1<<14
  #Form_RadioButton       = 1<<15
  #Form_PushButton        = 1<<16
  #Form_ComboBox          = 1<<17
  #Form_Edit              = 1<<18
  #Form_Sort              = 1<<19
  #Form_FileSelect        = 1<<20
  #Form_MultiSelect       = 1<<21
  #Form_DoNotSpellCheck   = 1<<22
  #Form_DoNotScroll       = 1<<23
  #Form_Comb              = 1<<24
  #Form_RichText          = 1<<25
  #Form_RadioInUnison     = 1<<25
  #Form_CommitOnSelChange = 1<<26
  ;}
  ;{ ----- Action:      AddLaunchAction() ----
  #OpenAction  = "open"
  #PrintAction = "print"
  ;}  
  ;{ ----- Align:       Cell() / MultiCell() / MultiCellList() / TruncateCell() -----
  #RightAlign      = "R"
  #LeftAlign       = "L"
  #ForcedJustified = "FJ"
  #Justified       = "J"
  #CenterAlign     = "C"
  ;}
  ;{ ----- Annotation:  AddTextNote() -----
  EnumerationBinary 
  #InvisibleFlag
  #HiddenFlag
  #PrintFlag
  #NoZoomFlag
  #NoRotateFlag
  #NoViewFlag
  #ReadOnlyFlag
  #LockedFlag
  #ToggleNoViewFlag
  EndEnumeration ;}  
  ;{ ----- CellBorder:  Cell() / MultiCell() / MultiCellList() / TruncateCell() -----
  #Border       = #True
  #LeftBorder   = -1
  #TopBorder    = -2
  #RightBorder  = -4
  #BottomBorder = -8
  ;}  
  ;{ ----- Color:       SetColor()
  Enumeration 1
    #TextColor
    #DrawColor
    #FillColor
  EndEnumeration
  ;}  
  ;{ ----- DrawStyle:   DrawSector() / DrawRectangle() / DrawRoundedRectangle()  -----
  #DrawOnly     = "D"
  #FillOnly     = "F"
  #DrawAndFill  = "DF"
  ;}  
  ;{ ----- Fonts:       EmbedFont() ------
  #FixedPitch  = 1     ; Bit 1
  #Serif       = 1<<1  ; Bit 2
  #Symbolic    = 1<<2  ; Bit 3
  #Script      = 1<<3  ; Bit 4
  #Unicode     = 1<<4  ; (pbPDF)
  #NonSymbolic = 1<<5  ; Bit 6
  #Italic      = 1<<6  ; Bit 7
  #AllCap      = 1<<16 ; Bit 17
  #SmallCap    = 1<<17 ; Bit 18
  #ForceBold   = 1<<18 ; Bit 19
  ;}
  ;{ ----- FontSize:    GetFontSize() ------
  #Point = 1
  #Unit  = 2
  ;}  
  ;{ ----- Icons:       AddFileLink() -----
  #GraphIcon     = "Graph"
  #PaperClipIcon = "Paperclip"
  #PushPinIcon   = "PushPin"
  #TagIcon       = "Tag"
  ;}
  ;{ ----- Icons:       AddTextNote() -----
  #CommentIcon      = "Comment"
  #KeyIcon          = "Key"
  #NoteIcon         = "Note"
  #HelpIcon         = "Help"
  #NewParagraphIcon = "NewParagraph"
  #ParagraphIcon    = "Paragraph"
  #Insert           = "Insert"
  ;}  
  ;{ ----- Image:       ImageMemory() ----
  Enumeration 1
    #Image_PNG
    #Image_JPEG
    #Image_JPEG2000
  EndEnumeration
  ;}  
  ;{ ----- Info:        SetInfo() -----
  Enumeration 1
    #Author
    #Titel
    #Subject
    #Keywords
    #Creator
  EndEnumeration
  ;}  
  ;{ ----- LineStyle:   SetLineCap() / SetLineCorner() -----
  #ButtCap       = "0"
  #RoundCap      = "1"
  #SquareCap     = "2"
  #LaceCorner    = "0"
  #CurvedCorner  = "1"
  #BeveledCorner = "2"
  ;}  
  ;{ ----- Ln:          Cell() / TruncateCell() -----
  #Right    = 0
  #NextLine = 1
  #Below    = 2
  ;}  
  ;{ ----- Locales      SetLocales() -----
  Enumeration 1
    #Language
    #TimeZoneOffset
    #DecimalPoint
  EndEnumeration
  ;}  
  ;{ ----- Margins      SetMargin() -----
  Enumeration 1
    #TopMargin
    #LeftMargin
    #RightMargin
    #CellMargin
  EndEnumeration  
  ;}  
  ;{ ----- Orientation: Create() / AddPage() -----
  #Portrait  = "P"
  #Landscape = "L"
  ;}  
  ;{ ----- PageFormat:  Create() / AddPage() -----
  #Format_4A0       = "4767.87,6740.79"
  #Format_2A0       = "3370.39,4767.87"
  #Format_A0        = "2383.94,3370.39"
  #Format_A1        = "1683.78,2383.94"
  #Format_A2        = "1190.55,1683.78"
  #Format_A3        = "841.89,1190.55"
  #Format_A4        = "595.28,841.89"     
  #Format_A5        = "419.53,595.28"
  #Format_A6        = "297.64,419.53"
  #Format_A7        = "209.76,297.64"
  #Format_A8        = "147.40,209.76"
  #Format_A9        = "104.88,147.40"
  #Format_A10       = "73.70,104.88"
  #Format_B0        = "2834.65,4008.19"
  #Format_B1        = "2004.09,2834.65"
  #Format_B2        = "1417.32,2004.09"
  #Format_B3        = "1000.63,1417.32"
  #Format_B4        = "708.66,1000.63"
  #Format_B5        = "498.90,708.66"
  #Format_B6        = "354.33,498.90"
  #Format_B7        = "249.45,354.33"
  #Format_B8        = "175.75,249.45"
  #Format_B9        = "124.72,175.75"
  #Format_B10       = "87.87,124.72"
  #Format_C0        = "2599.37,3676.54"
  #Format_C1        = "1836.85,2599.37"
  #Format_C2        = "1298.27,1836.85"
  #Format_C3        = "918.43,1298.27"
  #Format_C4        = "649.13,918.43"
  #Format_C5        = "459.21,649.13"
  #Format_C6        = "323.15,459.21"
  #Format_C7        = "229.61,323.15"
  #Format_C8        = "161.57,229.61"
  #Format_C9        = "113.39,161.57"
  #Format_C10       = "79.37,113.39"
  #Format_RA0       = "2437.80,3458.27"
  #Format_RA1       = "1729.13,2437.80"
  #Format_RA2       = "1218.90,1729.13"
  #Format_RA3       = "864.57,1218.90"
  #Format_RA4       = "609.45,864.57"
  #Format_SRA0      = "2551.18,3628.35)"
  #Format_SRA1      = "1814.17,2551.18"
  #Format_SRA2      = "1275.59,1814.17"
  #Format_SRA3      = "907.09,1275.59"
  #Format_SRA4      = "637.80,907.09"
  #Format_Letter    = "612.00,792.00"
  #Format_Legal     = "612.00,1008.00"
  #Format_Executive = "521.86,756.00"
  #Format_Folio     = "612.00,936.00"
  ;}  
  ;{ ----- PageLayout:  SetPageLayout() -----
  #SinglePage     = "/SinglePage"     ; Display one page at time
  #Continuous     = "/OneColumn"      ; Display the pages in on column
  #TwoColumn      = "/TwoColumnLeft"  ; Display the pages in two columns, with odd-numbered pages on the left
  #TwoColumnRight = "/TwoColumnRight" ; Display the pages in two columns, with odd-numbered pages on the right
  #TwoPages       = "/TwoPageLeft"    ; Display the pages two at a time, with odd-numbered pages on the left
  #TwoPagesRight  = "/TwoPageRight"   ; Display the pages two at a time, with odd-numbered pages on the right
  ;}
  ;{ ----- PageMode:    SetPageMode() -----
  #None            = "/UseNone"        ; Neither document outline nor thumbnail images visible
  #Outlines        = "/UseOutlines"    ; Document outline visible
  #Thumbs          = "/UseThumbs"      ; Thumbnail images visible
  #FullScreen      = "/FullScreen"     ; Full-screen mode, with no menue bar or windows controls visible 
  #OptionalContent = "/UseOC"          ; Optional content group panel visible
  #Attachments     = "/UseAttachments" ; Attachments panel visible
  ;} 
  ;{ ----- Permission:  SetEncryption() -----
  #PrintAccess  = 1<<2  ; Bit  3 (Bit 1 = Pos 0)
  #ModifyAccess = 1<<3  ; Bit  4
  #CopyAccess   = 1<<4  ; Bit  5
  #AddAccess    = 1<<5  ; Bit  6
  #Bit7         = 1<<6  ; always 1
  #Bit8         = 1<<7  ; always 1
  #FormAccess   = 1<<8  ; Bit  9
  #Extract      = 1<<9  ; Bit 10
  #Assemble     = 1<<10 ; Bit 11
  #DigitalCopy  = 1<<11 ; Bit 12
  #Permission   = $FFFFF0C0 ; Default (Bit 1-2 = 0 / Bit 7-8 = 1 / Bit 13-32 = 1)
  ;}
  ;{ ----- Preferences: SetViewerPreferences() -----
  EnumerationBinary
    #HideToolbar
    #HideMenubar
    #HideWinUI
    #FitWindow
    #CenterWindow
    #DisplayTitle
  EndEnumeration
  ;}  
  ;{ ----- Zoom: SetOpenAction() -----
  #PageTop   = "PageTop"
  #FullPage  = "FullPage"
  #PageWidth = "PageWidth"
  ;}

  ;} =====================
  
  Declare   AddPage(ID.i, Orientation.s="", Format.s="")
  Declare   AddEntryTOC(ID.i, Text.s, Level.i=0)
  Declare   BookMark(ID.i, Titel.s, SubLevel.i=#False, Y.f=#PB_Default, Page.i=#PB_Default)
  Declare   Cell(ID.i, Text.s, Width.f=#PB_Default, Height.f=#PB_Default, Border.i=#False, Ln.i=#Right, Align.s="", Fill.i=#False, Label.s="", Link.i=#NoLink)
  Declare   Close(ID.i, FileName.s)
  Declare.i Create(ID.i, Orientation.s="P", Unit.s="", Format.s="")
  Declare   DividingLine(ID.i, X.f=#PB_Default, Y.f=#PB_Default, Width.f=#PB_Default)
  Declare.i EmbedFile(ID.i, Filename.s, Description.s="")
  Declare.s EmbedFont(ID.i, Filename.s, Family.s="", Style.s="", Flags.i=#False)
  Declare   EmbedJavaScript(ID.i, Script.s, Name.s="EmbeddedJS")
  Declare.i EmbedJavaScriptFile(ID.i, FileName.s, Name.s="EmbeddedJS")
  Declare   EnableFooter(ID.i, Flag.i=#True)
  Declare   EnableHeader(ID.i, Flag.i=#True)
  Declare   EnableTOCNums(ID.i, Flag.i=#True)
  Declare.i GetErrorCode(ID.i)
  Declare.s GetErrorMessage(ID.i)
  Declare.f GetFontSize(ID.i, Type.i=#Point)
  Declare.f GetMargin(ID.i, Type.i)
  Declare.i GetMultiCellLines(ID.i)
  Declare.i GetNumbering(ID.i, TOC.i=#False)
  Declare.i GetObjectNum(ID.i)
  Declare.f GetPageHeight(ID.i)
  Declare.i GetPageNumber(ID.i, TOC.i=#False)
  Declare.f GetPageWidth(ID.i)
  Declare.f GetPosX(ID.i)
  Declare.f GetPosY(ID.i)
  Declare.f GetScaleFactor(ID.i)
  Declare.f GetStringWidth(ID.i, String.s)
  Declare.f GetWordSpacing(ID.i)
  Declare   Image(ID.i, FileName.s, X.f=#PB_Default, Y.f=#PB_Default, Width.f=#PB_Default, Height.f=#PB_Default, Link.i=#NoLink)
  Declare   ImageMemory(ID.i, ImageName.s, *Memory, Size.i, Format.i, X.f=#PB_Default, Y.f=#PB_Default, Width.f=#PB_Default, Height.f=#PB_Default, Link.i=#NoLink)
  Declare   InsertTOC(ID.i, Page.i=1, Label.s="", LabelFontSize.i=20, EntryFontSize.i=10, FontFamily.s="Times")
  Declare   Ln(ID.i, Height.f=#PB_Default)
  Declare.s MultiCell(ID.i, Text.s, Width.f, Height.f, Border.i=#False, Align.s="", Fill.i=#False, Indent.i=0, maxLine.i=0)
  Declare   MultiCellList(ID.i, Text.s, Width.f, Height.f, Border.i=0, Align.s="J", Fill.i=#False, Char.s=#Bullet$)
  Declare   PlaceText(ID.i, Text.s, X.f=#PB_Default, Y.f=#PB_Default)
  Declare   Rotate(ID.i, Angle.f, X.f=#PB_Default, Y.f=#PB_Default)
  Declare   Save(ID.i, FileName.s)
  Declare   SetAliasTotalPages(ID.i, Alias.s="{tp}")
  Declare   SetAutoPageBreak(ID.i, Flag.i, Margin.f=0)
  Declare   SetColorRGB(ID.i, ColorTyp.i, Red.f, Green.f=#PB_Default, Blue.f=#PB_Default)
  Declare   SetColorCMYK(ID.i, ColorTyp.i, Cyan.f, Magenta.f, Yellow.f, Black.f)
  Declare   SetDashedLine(ID.i, DashLength.i, DashSpacing.i)
  Declare   SetEncryption(ID.i, User.s, Owner.s="", Permission.q=#False)
  Declare   SetFont(ID.i, Family.s="", Style.s="", Size.i=#PB_Default)
  Declare   SetFontSize(ID.i, Size.i)
  Declare   SetPageLayout(ID.i, Mode.s=#SinglePage)
  Declare   SetPageNumbering(ID.i, Flag.i)
  Declare   SetInfo(ID.i, Type.i, Value.s)
  Declare   SetLineCap(ID.i, Style.s)
  Declare   SetLineCorner(ID.i, Style.s)
  Declare   SetLineThickness(ID.i, Width.f)
  Declare   SetLocales(ID.i, Type.i, Value.s)
  Declare   SetMargin(ID.i, Type.i, Value.i)
  Declare   SetOpenAction(ID.i, Zoom.s="", Page.i=1)
  Declare   SetPageMargins(ID.i, LeftMargin.f, TopMargin.f, RightMargin.f=#PB_Default)
  Declare   SetPageMode(ID.i, Mode.s=#None)
  Declare   SetPageCompression(ID.i, Flag.i=#True)
  Declare   SetPosXY(ID.i, X.f, Y.f)
  Declare   SetPosX(ID.i, X.f)
  Declare   SetPosY(ID.i, Y.f, ResetX.i=#True)
  Declare   SetFooterProcedure(ID.i, *ProcAddress, *StructAddress=#Null)
  Declare   SetHeaderProcedure(ID.i, *ProcAddress, *StructAddress=#Null)
  Declare   SetViewerPreferences(ID.i, Flags.i)
  Declare   SetWordSpacing(ID.i, WordSpacing.f)
  Declare   SubWrite(ID.i, Text.s, Height.f=#PB_Default, SubFontSize.i=12, SubOffSet.f=0, Label.s="", Link.i=#NoLink)
  Declare.s EscapeText(ID.i, Text.s)
  Declare.s TruncateCell(ID.i, Text.s, Width.f=#PB_Default, Height.f=#PB_Default, Border.i=#False, Ln.i=#Right, Align.s=#LeftAlign, Fill.i=#False, TruncText.s="...", Label.s="", Link.i=#NoLink)
  Declare   Write(ID.i, Text.s, Height.f=#PB_Default, Label.s="", Link.i=#NoLink)
  
  CompilerIf #Enable_AcroFormCommands
    Declare   ButtonField(ID.i, Titel.s, State.i=#False, Flags.i=#False, Width.f=#PB_Default, Height.f=#PB_Default, Ln.i=#Right)
    Declare   ChoiceField(ID.i, Titel.s, Value.s, Options.s, Index.i=#PB_Default, Flags.i=#False, Width.f=#PB_Default, Height.f=#PB_Default, Ln.i=#NextLine)
    Declare   TextField(ID.i, Titel.s, Text.s, Flags.i=#False, Width.f=#PB_Default, Height.f=#PB_Default, Border.i=#False, Ln.i=#Right, Align.s="", Fill.i=#False)
  CompilerEndIf
  
  CompilerIf #Enable_Annotations
    Declare.i AddFileLink(ID.i, EmbedID.i, Title.s="", Description.s="", Icon.s=#PushPinIcon, IconW.f=6, IconH.f=8, X.f=#PB_Default)
    Declare.i AddGotoAction(ID.i, Page.i=#PB_Default, PosY.i=#PB_Default)
    Declare   AddGotoLabel(ID.i, Label.s)
    Declare.i AddLaunchAction(ID.i, FileName.s, Y.f=#PB_Default, Action.s=#OpenAction)
    Declare.i AddLinkURL(ID.i, URL.s="")
    Declare.i AddTextNote(ID.i, Title.s, Content.s, Icon.s=#NoteIcon, Y.f=#PB_Default)
    Declare   LinkArea(ID.i, X.f, Y.f, Width.f, Height.f, Label.s="", Link.i=#NoLink)
  CompilerEndIf
  
  CompilerIf #Enable_DrawingCommands
    Declare   DrawCircle(ID.i, X.f, Y.f, Radius.f, Style.s=#DrawOnly)
    Declare   DrawEllipse(ID.i, X.f, Y.f, xRadius.f, yRadius.f, Style.s=#DrawOnly)
    Declare   DrawGrid(ID.i, Spacing=#PB_Default)
    Declare   DrawLine(ID.i, X1.f, Y1.f, X2.f, Y2.f)
    Declare   DrawRectangle(ID.i, X.f, Y.f, Width.f, Height.f, Style.s=#DrawOnly)
    Declare   DrawRoundedRectangle(ID.i, X.f, Y.f, Width.f, Height.f, Radius.f, Style.s=#DrawOnly) 
    Declare   DrawSector(ID.i, X.f, Y.f, Radius.f, startAngle.f, endAngle.f, Style.s=#DrawAndFill, Clockwise.i=#True, originAngle.f=90) 
    Declare   DrawTriangle(ID.i, X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f, Style.s=#DrawOnly)
    Declare   PathArc(ID.i, X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f)
    Declare   PathBegin(ID.i, X.f, Y.f)
    Declare   PathEnd(ID.i, Style.s=#DrawOnly)
    Declare   PathLine(ID.i, X.f, Y.f)
  CompilerEndIf
  
  CompilerIf #Enable_TransformCommands
    Declare   MirrorHorizontal(ID.i, X.f=#PB_Default)
    Declare   MirrorVertical(ID.i, Y.f=#PB_Default)
    Declare   ScaleHorizontal(ID.i, Factor.f=100, X.f=#PB_Default, Y.f=#PB_Default)
    Declare   ScaleVertical(ID.i, Factor.f=100, X.f=#PB_Default, Y.f=#PB_Default)
    Declare   Scale(ID.i,  Factor.f=100, X.f=#PB_Default, Y.f=#PB_Default)
    Declare   SkewHorizontal(ID.i, Angle.i, X.f=#PB_Default, Y.f=#PB_Default)
    Declare   SkewVertical(ID.i, Angle.i, X.f=#PB_Default, Y.f=#PB_Default)
    Declare   StartTransform(ID.i)
    Declare   StopTransform(ID.i)
    Declare   Translate(ID.i, moveX.f, moveY.f)
    Declare   TranslateHorizontal(ID.i, moveX.f)
    Declare   TranslateVertical(ID.i, moveY.f)
  CompilerEndIf
  
EndDeclareModule

Module PDF
  
  #Version = "2.0"
  
  EnableExplicit
  
  UseZipPacker()
  UseMD5Fingerprint()

;- ===========================================================================
;-   Module - Constants
;- ===========================================================================  
  
  ;{ ___ Diverse ___
  #Header  = "%PDF-1.6"
  #Comment = "%âãÏÓ"
  #File = 0
  #Error  = -1
  #Owner = 1
  #User  = 2
  CompilerIf #PB_Compiler_Processor=#PB_Processor_x86
    #pbPDF_Version = "pbPDF V" + #Version + " for PureBasic X86"
  CompilerElse
    #pbPDF_Version = "pbPDF V" + #Version + " for PureBasic X64"
  CompilerEndIf
  ;}
  
  ;{ ___ objNew_() ___
  Enumeration 1
    #objAcroForm
    #objBookmark
    #objFile
    #objFont
    #objImage
    #objJavaScript
    #objPage
    #objPageContent
    #objNames
    #objOutlines
  EndEnumeration ;}
  
  ;{ ___ objOut-Flags ___
  EnumerationBinary 
    #objUTF16
    #objHexStrg
    #objStrgArray
    #objText
    #objMemory
    #objCompress
  EndEnumeration ;}
  
  ;{ ___ RC4() ___
  EnumerationBinary 
    #HexKey
    #HexStrg
    #Memory
    #Ascii
    #Hex
    #Escape
    #Array
  EndEnumeration
  ;}

  ;{ ___ Annotations ___
  Enumeration 1
    #Annot_File
    #Annot_GoTo
    #Annot_Launch
    #Annot_Text
    #Annot_URL
  EndEnumeration
  ;}
  
  ;{ ___ Fonts ___
  #FONTSUP = -100
  #FONTSUT = 50
  #FONT_TIMES         = "Times-Roman"
  #FONT_TIMESI        = "Times-Italic"
  #FONT_TIMESB        = "Times-Bold"
  #FONT_TIMESBI       = "Times-BoldItalic"
  #FONT_HELVETICA     = "Helvetica"
  #FONT_HELVETICAB    = "Helvetica-Bold"
  #FONT_HELVETICAI    = "Helvetica-Oblique"
  #FONT_HELVETICABI   = "Helvetica-BoldOblique"
  #FONT_COURIER       = "Courier"
  #FONT_COURIERB      = "Courier-Bold"
  #FONT_COURIERI      = "Courier-Oblique"
  #FONT_COURIERBI     = "Courier-BoldOblique"
  #FONT_SYMBOL        = "Symbol"
  #FONT_ZAPFDINGBATS  = "ZapfDingbats"
  
  Enumeration 1
    #Font_Default
    #Font_Internal
    #Font_Embed
  EndEnumeration
  ;}
  
  ;{ ___ TTF-Flags ___
  #TTF_Unembeddable = 2
  #TTF_ReadOnly     = 4
  #TTF_Embeddable   = 8
  #TTF_NoSubsetting = 256
  #TTF_OnlyBitmap   = 512
  ;}
  
  ;{ ___ Errors ___
  Enumeration 1 
    #ERROR_ALPHA_CHANNEL_PNG_NOT_SUPPORTED
    #ERROR_PROBLEM_READING_IMAGE_FILE_IN_MEMORY
    #ERROR_NOT_A_JPEG_FILE
    #ERROR_INCORRECT_PNG_FILE
    #ERROR_NOT_A_JPEG_OR_PNG_FILE
    ; --------------------------------------
    #ERROR_FILE_CREATE
    #ERROR_FILE_READ
    #ERROR_COMPRESSION_FAILED
    #ERROR_TTF_UNEMBEDDABLE
    #ERROR_TTF_ONLYBITMAP
    #ERROR_TTF_NOSUBSETTING
  EndEnumeration ;}
  
;- ============================================================================
;-   Module - Structures
;- ============================================================================  
  
  ;{ ___ Internal Structures ___
  Structure Memory_Structure          ;{ -> Internal *
    *Memory
    Size.i
    Length.i
    Flag.i
  EndStructure ;}
  
  Structure Image_Header_Structure    ;{ -> Internal *
    Signature.s
    Width.q
    Height.q
    ColorSpace.w
    BitDepth.w
    Compression.w
    Prediktor.w
    Interlacing.w
    *PalPtr
    PalSize.i
    DataSize.i
    *Memory
    Size.i
  EndStructure ;}
  
  Structure TTF_Block_Structure       ;{ -> Internal *
    *Pos
    Size.q
  EndStructure ;}
  
  Structure TTF_Segment_Structure     ;{ -> Internal *
    EndCode.i
    StartCode.i
    Delta.i
    Offset.i
  EndStructure ;}
  
  Structure TTF_Header_BBox_Structure ;{ -> Internal *
    X1.w
    X2.w
    Y1.w
    Y2.w
  EndStructure ;}
  
  Structure TTF_Header_Structure      ;{ -> Internal *
    Signature.s
    Name.s
    Encoding.i
    BBox.TTF_Header_BBox_Structure
    Ascent.i
    Descent.i
    CapHeight.i
    FixedWidth.q
    MissingWidth.i
    BevelInteger.w
    BevelFraction.i
    ItalicAngle.f
    Skala.i
    StemV.i
    Map CharWidth.i()
    *CIDToGIDMap
    Flag.i
  EndStructure ;}
  ;} _______________________________
  
  ;{ ___ PDF Document Structures ___
  Structure PDF_Catalog_Open_Structure      ;{ PDF()\Catalog\OpenAction\...
    Page.i
    Zoom.s
  EndStructure ;}
  
  Structure PDF_Catalog_Structure           ;{ PDF()\Catalog\...
    objPages.s 
    objAcroForm.s
    objOutlines.s
    objNames.s
    OpenAction.PDF_Catalog_Open_Structure
  EndStructure ;}  
  
  Structure PDF_Names_Limit_Structure       ;{ PDF()\Names\LimitEF\..
    First.s
    Last.s
  EndStructure ;}
  
  Structure PDF_Names_Structure             ;{ PDF()\Names\...    [-> Catalog]
    Dests.s
    AP.s
    JavaScript.s
    LimitJS.PDF_Names_Limit_Structure
    EmbeddedFiles.s
    LimitEF.PDF_Names_Limit_Structure
  EndStructure ;}
  
  Structure PDF_Outlines_Structure          ;{ PDF()\Outlines\... [-> Catalog]
    First.s
    Last.s
    Count.i
  EndStructure ;}
  
  Structure PDF_Trailer_Structure           ;{ PDF()\Trailer\...
    Size.i
    Root.s
    Info.s
    Encrypt.s
    ID.s
  EndStructure ;}
  
  Structure PDF_XRef_Structure              ;{ PDF()\XRef\...
    objCount.i
    List Entry.s()
  EndStructure ;}
  
  Structure PDF_Object_Dictionary_Structure ;{ PDF()\Object()\Dictionary()\...
    sStrg.s
    String.s
    eStrg.s
    Size.i
    Flags.i
  EndStructure ;}
  
  Structure PDF_Object_Stream_Structure     ;{ PDF()\Object()\Stream\...
    *Memory
    Size.i
    Flag.i
  EndStructure ;}
  
  Structure PDF_Object_Structure            ;{ PDF()\Object(objNum)\...
    ByteOffset.i
    Type.i
    Parent.s
    String.s
    Stream.PDF_Object_Stream_Structure
    List Dictionary.PDF_Object_Dictionary_Structure()
    Flags.i
  EndStructure ;}
  ;} _______________________________
  
  ;{ ___ Other Structures ___
  Structure PDF_Annots_Structure     ;{ PDF()\Annots()\...
    Type.i
    ; ----------
    URL.s    ; AddLinkURL
    FileID.i ; AddFileLink
    File.s   ; AddLaunchAction
    Action.s ; AddLaunchAction
    ; ----------
    Titel.s
    Content.s
    Icon.s
    ; ----------
    X.f
    Y.f
    Width.f
    Height.f
    Page.i
    Dest.i
    objPage.s
    objDest.s
    Flags.i  ; Annotation Flags (Bit positions: 1 = Invisible / 2 = Hidden / 3 = Print / 4 = NoZoom / 5 = NoRotate / 6 = NoView / 7 = ReadOnly / 8 = Locked / 9 = ToggleNoView)
  EndStructure ;}
  
  Structure PDF_Bookmark_Structure   ;{ PDF()\objBookmark(SubLevel)\...
    Object.s
    First.s
    Last.s
    Count.i
  EndStructure ;}
  
  Structure PDF_Color_Structure      ;{ PDF()\Color\...
    Draw.s
    Fill.s
    Text.s
    Flag.i
  EndStructure ;}
  
  Structure PDF_Document_Structure   ;{ PDF()\Document\... 
    Height.f
    Width.f
    ptHeight.f
    ptWidth.f
    Orientation.s
  EndStructure    ;}  
  
  Structure PDF_Embed_Structure      ;{ PDF()\objFonts()\... | PDF()\objFiles()\... | PDF()\objJavaScript()\...
    Object.s
    Name.s
  EndStructure ;}  
  
  Structure PDF_Encryption_Structure ;{ PDF()\Encryption\...
    objNum.i
    genNum.i   ; 2 Byte (low order)
    oEntryHex.s
    uEntryHex.s
    eKeyHex.s
  EndStructure ;}  
  
  Structure PDF_Font_Structure       ;{ PDF()\Font\...
    Number.i
    Family.s
    Style.s
    SizePt.i
    Size.f
    Underline.i
    Unicode.i
  EndStructure ;}  

  Structure PDF_FontMap_Structure    ;{ PDF()\Fonts(FontKey)\...
    Number.i
    Name.s
    Style.s
    Encoding.i
    Flags.i
    Unicode.i
    Map CharWidth.i()
  EndStructure ;}  
  
  Structure PDF_Footer_Structure     ;{ PDF()\Footer\... 
    *ProcPtr
    *StrucPtr
    Numbering.i
    PageBreak.i
    Flag.i
  EndStructure ;}
  
  Structure PDF_Header_Structure     ;{ PDF()\Header\...
    *ProcPtr
    *StrucPtr
    PageBreak.i
    Flag.i    ; #True / #False
  EndStructure;}  
  
  Structure PDF_Image_Structure      ;{ PDF()\objImages(FileName)\... | PDF()\objFonts()\... | PDF()\objFiles()\... | PDF()\objJavaScript()\...
    Number.i
    Object.s
    File.s
  EndStructure ;}
  
  Structure PDF_Labels_Structure     ;{ PDF()\Labels(label)\...
    Idx.i
    objAnnot.s
    objPage.s
    ptWidth.f
    ptHeight.f
  EndStructure ;}
  
  Structure PDF_Local_Structure       ;{ PDF()\Local\...
    Language.s       ; #DefaultLanguage
    TimeZoneOffset.i ; vpdfTimeZoneOffset
    DecimalPoint.s   ; vLocalDecimal
  EndStructure ;}  
  
  Structure PDF_Margin_Structure      ;{ PDF()\Margin\...
    Left.f
    Top.f
    Right.f
    Cell.f
  EndStructure ;}  
  
  Structure PDF_Page_Structure        ;{ PDF()\Page\...
    X.f
    Y.f
    Height.f
    Width.f
    ptHeight.f
    ptWidth.f
    Orientation.s
    Angle.f
    LastHeight.f
    AliasTotalNum.s  ; [alias for the total number of pages]
    TOCNum.i         ; [TOC page number]
  EndStructure       ;}
  
  Structure PDF_Pages_Structure       ;{ PDF()\Pages()\...  [-> Catalog]
    objNum.s
    objContent.s
    ptWidth.f
    ptHeight.f
    Orientation.s
    Flag.i
  EndStructure ;}
  
  Structure PDF_PageAnnots_Structure ;{ PDF()\PageAnnots(objNum)\...
    List Annot.s()
  EndStructure ;}
  
  Structure PDF_PageBreak_Structure   ;{ PDF()\PageBreak\...
    Auto.i
    Margin.f
    Trigger.f
  EndStructure ;}
  
  Structure PDF_TOC_Structure         ;{ PDF()\TOC()\...
    Level.i
    Page.i
    Text.s
  EndStructure ;}
  ;} _______________________________
  
  Structure PDF_Structure ;{ PDF(ID)\...

    ; _____ Current Numbers/Counter _____
    
    imgNum.i         ; current image number
    pageNum.i        ; current page number
    objNum.i         ; current object number
    
    ; _____ Current Objects _____
    
    objPage.s
    objPageContent.s   
    Map objBookmark.PDF_Bookmark_Structure()
    
    ; _____ PDF Document Structures _____
    
    Catalog.PDF_Catalog_Structure    ; [-> Trailer: /Root]
    Names.PDF_Names_Structure        ; [-> Catalog: /Names]
    Outlines.PDF_Outlines_Structure  ; [-> Catalog: /Outlines]
    Trailer.PDF_Trailer_Structure
    XRef.PDF_XRef_Structure
    
    Map Object.PDF_Object_Structure()
    
    ; _____ PDF Objects _____
    
    objResources.s   ; Ressources Object (e.g. Fonts)
    objToUnicode.s
    
    List objAcroForms.s()
    List objFiles.PDF_Embed_Structure()      ; [-> Names:     /EmbeddedFiles]
    List objFonts.PDF_Embed_Structure()      ; [-> Resources: /Font]
    List objJavaScript.PDF_Embed_Structure() ; [-> Names:     /JavaScript]
    
    Map  objImages.PDF_Image_Structure()     ; [-> Resources: /XObject]
    
    ; _____ Data for PDF creation _____
    
    CompressPages.i
    Encryption.i
    Error.i
    LineWidth.f
    MultiCellNewLines.i
    Numbering.i
    ReplacePageNums.i
    ScaleFactor.f
    WordSpacing.f
    
    Color.PDF_Color_Structure
    Document.PDF_Document_Structure
    Encrypt.PDF_Encryption_Structure
    Footer.PDF_Footer_Structure
    Font.PDF_Font_Structure
    Header.PDF_Header_Structure
    Local.PDF_Local_Structure
    Margin.PDF_Margin_Structure
    Page.PDF_Page_Structure
    PageBreak.PDF_PageBreak_Structure
    
    List Annots.PDF_Annots_Structure()
    List Pages.PDF_Pages_Structure()       ; [-> Catalog:   /Pages]      (0 = PageTree)
    List TOC.PDF_TOC_Structure()
    
    Map Fonts.PDF_FontMap_Structure()
    Map Labels.PDF_Labels_Structure()
    Map PageAnnots.PDF_PageAnnots_Structure()
    
  EndStructure ;}
  
  Global NewMap PDF.PDF_Structure()
  
;- ============================================================================
;-   Module - Internal
;- ============================================================================
  
  Declare AddPage_(Orientation.s="",Format.s="")
  
  Procedure Octal(Decimal.i)
    Define.i Exponent, Octal
    While Decimal
      Octal + Decimal % 8 * Pow(10, Exponent)
      Decimal / 8
      Exponent + 1
    Wend
    ProcedureReturn Octal
  EndProcedure 

  Procedure GetUTF8Map(Map ucChar.u())
    Define.i c
    
    For c=32 To 255
      Select c
        Case 128
          ucChar(Str(c)) = $20AC
        Case 130
          ucChar(Str(c)) = $201A
        Case 131
          ucChar(Str(c)) = $0192      
        Case 132
          ucChar(Str(c)) = $201E
        Case 133
          ucChar(Str(c)) = $2026
        Case 134
          ucChar(Str(c)) = $2020   
        Case 135
          ucChar(Str(c)) = $2021
        Case 136
          ucChar(Str(c)) = $02C6
        Case 137
          ucChar(Str(c)) = $2030    
        Case 138
          ucChar(Str(c)) = $0160
        Case 139
          ucChar(Str(c)) = $2039
        Case 140
          ucChar(Str(c)) = $0152
        Case 142
          ucChar(Str(c)) = $017D
        Case 145
          ucChar(Str(c)) = $2018
        Case 146
          ucChar(Str(c)) = $2019
        Case 147
          ucChar(Str(c)) = $201C
        Case 148
          ucChar(Str(c)) = $201D
        Case 149
          ucChar(Str(c)) = $2022
        Case 150
          ucChar(Str(c)) = $2013
        Case 151
          ucChar(Str(c)) = $2014
        Case 152
          ucChar(Str(c)) = $02DC
        Case 153
          ucChar(Str(c)) = $2122
        Case 154
          ucChar(Str(c)) = $0161
        Case 155
          ucChar(Str(c)) = $203A
        Case 156
          ucChar(Str(c)) = $0153
        Case 158
          ucChar(Str(c)) = $017E       
        Case 159
          ucChar(Str(c)) = $0178
      Default
        ucChar(Str(c)) = c
      EndSelect
    Next
  
  EndProcedure  
  
  ;- ----- Integer & BigEndian ------------
  
  Procedure.i EndianW(val.w)
    ProcedureReturn (val>>8&$FF) | (val<<8&$FF00)
  EndProcedure
 
  Procedure.q EndianL(val.l)
    ProcedureReturn (val>>24&$FF) | (val>>8&$FF00) | (val<<8&$FF0000) | (val<<24&$FF000000)
  EndProcedure
  
  Procedure.q EndianQ(val.q)
    ProcedureReturn (EndianL(val>>32)&$FFFFFFFF) | (EndianL(val&$FFFFFFFF)<<32)
 EndProcedure

  Procedure.w uint8(Value.b)
    
    ProcedureReturn Value & $FF
    
  EndProcedure
  
  Procedure.b int8(Value.b)

    ProcedureReturn Value & $FF
    
  EndProcedure
  
  Procedure.i uint16(Value.w, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>8&$FF) | (Value<<8&$FF00)
    Else
      ProcedureReturn Value & $FFFF
    EndIf
    
  EndProcedure
  
  Procedure.w int16(Value.w, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>8&$FF) | (Value<<8&$FF00)
    Else
      ProcedureReturn Value
    EndIf
    
  EndProcedure
  
  Procedure.q uint32(Value.i, BigEndian.i=#True)
  
    If BigEndian
      ProcedureReturn (Value>>24&$FF) | (Value>>8&$FF00) | (Value<<8&$FF0000) | (Value<<24&$FF000000)
    Else
      ProcedureReturn Value & $FFFFFFFF
    EndIf
    
  EndProcedure
  
  Procedure.s PeekUTF16(*MemPtr, MemSize.i)
    Define c.i, String.s
    
    For c=1 To Int(MemSize / 2)
      String + Chr(uint16(PeekU(*MemPtr)))
      *MemPtr + 2
    Next
    
    ProcedureReturn String
  EndProcedure
  
  ;- ----- Compression --------------------
  
  Procedure CompressMemory_(*Memory, *Compress.Memory_Structure)
    Define.i Size, targetLen, compressLen, Result = #False
    Define.s objStrg
    Define   *Target
    
    Size      = MemorySize(*Memory)
    targetLen = Size + 13 + (Int(Size / 100))
    
    *Target = AllocateMemory(targetLen)
    If *Target
      compressLen = CompressMemory(*Memory, Size, *Target, targetLen, #PB_PackerPlugin_Zip)
      If compressLen
        *Compress\Memory = *Target
        *Compress\Size   = compressLen
        FreeMemory(*Memory)
        Result = #True
      Else
        FreeMemory(*Target)
      EndIf
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure CompressFile_(File.s, *Compress.Memory_Structure)
    Define.i targetLen, compressLen, Result = #False
    Define *Source, *Target
    
    If ReadFile(#File, File)
      *Compress\Length = Lof(#File)
      targetLen  = *Compress\Length + 13 + (Int(*Compress\Length / 100))
      *Source = AllocateMemory(*Compress\Length)
      If *Source
        If ReadData(#File, *Source, *Compress\Length)
          *Target = AllocateMemory(targetLen)
          If *Target
            compressLen = CompressMemory(*Source, *Compress\Length, *Target, targetLen, #PB_PackerPlugin_Zip)
            If compressLen
              *Compress\Memory = *Target
              *Compress\Size   = compressLen
              *Compress\Flag   = #objCompress
              Result = #True
            Else
              PDF()\Error = #ERROR_COMPRESSION_FAILED
              Result = #False
            EndIf
          EndIf
        EndIf
        FreeMemory(*Source)
      EndIf
      CloseFile(#File)
    Else
      PDF()\Error = #ERROR_FILE_READ
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  ;- ----- Memory -------------------------
  
  Procedure.i ReplaceInPageStream(objPageContent.s, Search.s, Replace.s) ; [*]
    Define.i Size, i, s, Found, fSize, rSize, sSize
    Define *Memory, *MemPtr
    
    If FindMapElement(PDF()\Object(), objPageContent)
      
      rSize = Len(Replace)
      sSize = Len(Search)
      
      Size = PDF()\Object()\Stream\Size + (rSize - sSize)
      
      *Memory = AllocateMemory(Size + 2)
      If *Memory
        
        *MemPtr = PDF()\Object()\Stream\Memory
        
        ;{ Search String
        For i=1 To Size - sSize + 1
          
          If PeekA(*MemPtr) = Asc(Left(Search, 1))
            
            Found = #True
            
            For s=1 To sSize - 1
              If PeekA(*MemPtr + s) <> Asc(Mid(Search, s+1, 1))
                Found = #False
                Break
              EndIf
            Next
            
            If Found 
              fSize = i - 1
              Break 
            EndIf
            
          EndIf
          
          *MemPtr + 1
        Next ;}
        
        If Found
          
          *MemPtr = PDF()\Object()\Stream\Memory
          
          If fSize
            CopyMemory(*MemPtr, *Memory, fSize)
            *MemPtr + fSize
          EndIf
          *MemPtr + sSize
          
          PokeS(*Memory + fSize, Replace, rSize, #PB_Ascii)
          
          CopyMemory(*MemPtr, *Memory + fSize + rSize, Size - fSize - rSize)
          
          FreeMemory(PDF()\Object()\Stream\Memory)
          
          PDF()\Object()\Stream\Memory = *Memory
          PDF()\Object()\Stream\Size   = Size
          
        Else
          FreeMemory(*Memory)
        EndIf
        
      EndIf
     
    EndIf  

    ProcedureReturn Found
  EndProcedure
  
  Procedure   HexStrg2Memory(HexStrg.s, sStrg.s, eStrg.s, *String.Memory_Structure)
    Define.i i, Size, strgSize, sSize, eSize
    Define.s strgArray
    Define   *MemPtr
    
    Debug sStrg + " / " + estrg
    
    sSize = Len(sStrg)
    eSize = Len(eStrg)
    
    If CountString(HexStrg, " ") ;{ Text Array
      
      strgSize     = (Len(HexStrg) - 1) / 2
      *String\Size = strgSize + sSize + eSize + 5 ; "() ()"
      
      *String\Memory = AllocateMemory(*String\Size + 2)
      If *String\Memory
        
        *MemPtr = *String\Memory
        
        If sStrg
          PokeS(*MemPtr, sStrg, sSize, #PB_Ascii)
          *MemPtr + sSize
        EndIf
        
        strgArray = StringField(HexStrg, 1, " ")
        For i=0 To (Len(strgArray) / 2) - 1
          PokeA(*MemPtr, Val("$" + Mid(strgArray, (i*2) + 1, 2)))
          *MemPtr + 1
        Next
        
        strgArray = StringField(HexStrg, 2, " ")
        For i=0 To (Len(strgArray) / 2) - 1
          PokeA(*MemPtr, Val("$" + Mid(strgArray, (i*2) + 1, 2)))
          *MemPtr + 1
        Next
        
        If eStrg
          PokeS(*MemPtr, eStrg, eSize, #PB_Ascii)
          *MemPtr + eSize
        EndIf
        
      EndIf
      ;}
    Else                         ;{ String
      
      strgSize     = Len(HexStrg) / 2
      *String\Size = strgSize + sSize + eSize
      
      *String\Memory = AllocateMemory(*String\Size + 2)
      If *String\Memory
        
        *MemPtr = *String\Memory
        
        If sStrg
          PokeS(*MemPtr, sStrg, sSize, #PB_Ascii)
          *MemPtr + sSize
        EndIf
        
        For i=0 To StrgSize - 1
          PokeA(*MemPtr, Val("$" + Mid(HexStrg, (i*2) + 1, 2)))
          *MemPtr + 1
        Next
        
        If eStrg
          PokeS(*MemPtr, eStrg, eSize, #PB_Ascii)
          *MemPtr + eSize
        EndIf
        
      EndIf
      ;}
    EndIf
    
  EndProcedure  
  
  ;- ----- Strings ---------------------------  
  
  Procedure.s EscapeString_(String.s)
    Define Char.c, i.i, Result$=""
    
    ;{ ----- PDF Escape Characters ---------------
    ; PDF Reference Version 1.6 - Chapter 3.1.1 (Table 3.1)
    ;
    ; \n       | LINE FEED          ($0A / LF)
    ; \r       | CARRIAGE Return    ($0D / CR) 
    ; \t       | HORIZONTAL TAB     ($09 / HT)
    ; \b       | BACKSPACE          ($08 / BS)
    ; \f       | FORM FEED          ($0C / FF)
    ; \(       | LEFT PARENTHESIS   ($28)
    ; \)       | RIGHT PARENTHESIS  ($29)
    ; \\       | REVERSE SOLIDUS    ($5C / Backslash)
    ; \ddd     | Character code ddd (octal)
    ;} ------------------------------------------

    For i=1 To Len(String)
      Char = Asc(Mid(String, i, 1))
      Select Char
        Case 8 ; BS
          Result$ + "\b"
        Case 9 ; TAB
          Result$ + "\t"
        Case 10 ; LF
          Result$ + "\n"
        Case 12 ; FF
          Result$ + "\f"
        Case 13 ; CR
          Result$ + "\r"
        Case 92
          Result$ + "\\"
        Case 40
          Result$ + "\("
        Case 41
          Result$ + "\)"
        Case 128 To 511
          Result$ + "\" + Octal(Char)
        Default
          Result$ + Chr(Char)
      EndSelect
    Next
    
    ProcedureReturn Result$
  EndProcedure
  
  Procedure.s EscapeHexStrg_(HexStrg.s)
    Define Char.s, i.i, Result$=""
    
    ;{ ----- PDF Escape Characters ---------------
    ; PDF Reference Version 1.6 - Chapter 3.1.1 (Table 3.1)
    ;
    ; \n       | LINE FEED          ($0A / LF)
    ; \r       | CARRIAGE Return    ($0D / CR) 
    ; \t       | HORIZONTAL TAB     ($09 / HT)
    ; \b       | BACKSPACE          ($08 / BS)
    ; \f       | FORM FEED          ($0C / FF)
    ; \(       | LEFT PARENTHESIS   ($28)
    ; \)       | RIGHT PARENTHESIS  ($29)
    ; \\       | REVERSE SOLIDUS    ($5C / Backslash)
    ; \ddd     | Character code ddd (octal)
    ;} ------------------------------------------

    For i=1 To Len(HexStrg) Step 2
      Char = Mid(HexStrg, i, 2)
      Select Char
        Case "08"  ; BS
          Result$ + "5C62" ; "\b"
        Case "09" ; TAB
          Result$ + "5C74" ; "\t"
        Case "0A" ; LF
          Result$ + "5C6E" ; "\n"
        Case "0C" ; FF
          Result$ + "5C66" ; "\f"
        Case "0D" ; CR
          Result$ + "5C72" ; "\r"
        Case "5C"
          Result$ + "5C5C" ; "\\"
        Case "28"
          Result$ + "5C28" ; "\("
        Case "29"
          Result$ + "5C29" ; "\)"
        Default
          Result$ + Char
      EndSelect
    Next
    
    ProcedureReturn Result$
  EndProcedure
  
  Procedure.d GetStringWidth_(String.s, Scale.i=#True)
    Define i.i, Width.i, Char.s, vReturn.d

    For i = 1 To Len(String)
      
      Char = Mid(String, i, 1)
      If Asc(Char) > 255
        Width + 600 ; for Unicode characters
      Else
        Width + PDF()\Fonts()\CharWidth(Char)
      EndIf
      
    Next
    
    If Scale
      ProcedureReturn (Width * PDF()\Font\Size) / 1000
    Else
      ProcedureReturn Width
    EndIf

  EndProcedure   
  
  Procedure.s strF_(Value.f, NbDecimals.i)
   
    If PDF()\Local\DecimalPoint = "."
      ProcedureReturn StrF(Value, NbDecimals)
    Else
      ProcedureReturn ReplaceString(StrF(Value, NbDecimals), PDF()\Local\DecimalPoint, ".")
    EndIf

  EndProcedure
  
  ;- ----- Encryption -----------------------
  
  Procedure.s PAD(String.s)
    Define.i i
    Define.s HEX$, PAD$ = "28BF4E5E4E758A4164004E56FFFA01082E2E00B6D0683E802F0CA9FE6453697A"
    
    If String <> ""
      For i=1 To Len(String)
        HEX$ + RSet(Hex(Asc(Mid(String, i, 1)), #PB_Ascii), 2, "0")
      Next
      ProcedureReturn Left(HEX$ + PAD$, 64)
    Else
      ProcedureReturn PAD$
    EndIf
    
  EndProcedure
  
  Procedure.s MD5(HexStrg.s)
    Define MD5$, MemSize.i, i.i
    Define *Memory
    
    MemSize = Len(HexStrg) / 2
    
    *Memory = AllocateMemory(MemSize)
    If *Memory
      For i=0 To MemSize - 1
        PokeA(*Memory + i, Val("$" + Mid(HexStrg, (i*2)+1, 2)))
      Next
      MD5$ = Fingerprint(*Memory, MemSize, #PB_Cipher_MD5)
      FreeMemory(*Memory)
    EndIf
    
    ProcedureReturn MD5$
  EndProcedure
  
  Procedure.s RC4(String.s, Key.s, Flags.i=#False)
    ; https://en.wikipedia.org/wiki/RC4
    Define.i i, j, n, KeyLen, StrgLen
    Define.a RNum
    Define.s RC4$
    
    StrgLen = Len(String)
    KeyLen  = Len(Key)
    
    Dim s.a(255)
    Dim k.a(KeyLen)
    
    If Flags & #HexKey
      KeyLen = KeyLen / 2
      For i=0 To KeyLen - 1
        k(i) = Val("$"+Mid(Key, (i*2)+1, 2))
      Next
    Else
      For i=0 To KeyLen - 1
        k(i) = Asc(Mid(Key, i+1, 1))
      Next
    EndIf
    
    For i=0 To 255 : s(i) = i : Next
    
    j = 0
    For i = 0 To 255
      j = (j + s(i) + k(i % KeyLen)) % 256
      Swap s(i), s(j)
    Next
    
    i = 0 : j = 0
    
    If Flags & #HexStrg
      For n=0 To (StrgLen / 2) - 1
        i = (i + 1) % 256
        j = (j + s(i)) % 256
        Swap s(i), s(j)
        RNum = s((s(i)+s(j)) % 256)
        If Flags & #Ascii
          RC4$ + Chr(RNum ! Val("$"+Mid(String, (n*2)+1, 2)))
        Else
          RC4$ + RSet(Hex(RNum ! Val("$"+Mid(String, (n*2)+1, 2)), #PB_Ascii), 2, "0")
        EndIf
      Next
    Else
      For n=0 To StrgLen-1
        i = (i + 1) % 256
        j = (j + s(i)) % 256
        Swap s(i), s(j)
        RNum = s((s(i)+s(j)) % 256)
        If Flags & #Ascii
          RC4$ + Chr(RNum ! Asc(Mid(String, n+1, 1)))
        Else
          RC4$ + RSet(Hex(RNum ! Asc(Mid(String, n+1, 1)), #PB_Ascii), 2, "0")
        EndIf
      Next
    EndIf
    
    ProcedureReturn RC4$
  EndProcedure
  
  Procedure.s PEntry(Flags.q)
    Define.i i
    Define.s HexNum$, LowHex$
    
    If Flags < 0 : Flags & $FFFFFFFF : EndIf
    
    HexNum$ = RSet(Hex(Flags, #PB_Long), 8, "0")
    
    For i=7 To 1 Step -2
      LowHex$ + Mid(HexNum$, i, 2)
    Next
    
    ProcedureReturn LowHex$
  EndProcedure
  
  Procedure   GeneratePasswords_(User.s, Owner.s, Permission.q)
    ; PDF Reference Version 1.6 - Chapter 3.5.2
    Define.i i, c
    Define.s HexKey$, HexPad$, Hex$, MD5$, RC4$, iKey$
    
    ;{ ----- Owner Password (Algorithm 3.3) ------
    ; >> Create an RC4 encryption key
    HexPad$ = PAD(Owner)
    MD5$    = MD5(HexPad$)
    For i=1 To 50
      MD5$ = MD5(MD5$)
    Next
    HexKey$ = MD5$ ; 16 Byte (Lenght: 128 / 8)
    ; >> Create value of O entry in the encryption dictionary
    HexPad$ = PAD(User)
    RC4$    = RC4(HexPad$, HexKey$, #HexStrg|#HexKey)
    ; >> XOR between each byte of key and the single-byte value of iteration counter (1-19)
    Dim Key.a(16)
    For c=0 To 15 : Key(c+1) = Val("$" + Mid(HexKey$, (c*2)+1, 2)) : Next
    For i=1 To 19
      iKey$ = ""
      For c=1 To 16
        iKey$ + RSet(Hex(Key(c) ! i, #PB_Ascii), 2, "0")
      Next
      RC4$ = RC4(RC4$, iKey$, #HexStrg|#HexKey) 
    Next
    PDF()\Encrypt\oEntryHex = RC4$
    ;}
    
    ;{ ----- Encryption Key (Algorithm 3.2) ------
    Hex$ = HexPad$
    Hex$ + PDF()\Encrypt\oEntryHex
    Hex$ + PEntry(Permission)
    Hex$ + PDF()\Trailer\ID
    MD5$ = MD5(Hex$)
    For i=1 To 50
      MD5$ = MD5(MD5$)
    Next
    PDF()\Encrypt\eKeyHex = MD5$ ; 16 Byte (Lenght: 128 Bit / 8)
    ;}
    
    ;{ ----- User Password  (Algorithm 3.5) ------
    Hex$ = PAD("") +  PDF()\Trailer\ID
    MD5$ = MD5(Hex$)
    RC4$ = RC4(MD5$, PDF()\Encrypt\eKeyHex, #HexStrg|#HexKey)
    For c=0 To 15 : Key(c+1) = Val("$" + Mid(PDF()\Encrypt\eKeyHex, (c*2)+1, 2)) : Next
    For i=1 To 19
      iKey$ = ""
      For c=1 To 16
        iKey$ + RSet(Hex(Key(c) ! i, #PB_Ascii), 2, "0")
      Next
      RC4$ = RC4(RC4$, iKey$, #HexStrg|#HexKey) 
    Next
    
    For i=1 To 16 : RC4$ + "00" : Next
    PDF()\Encrypt\uEntryHex = RC4$ ;+ Left(Hex$, 32)
    ;}

  EndProcedure
  
  Procedure.s objNumHex(objNum.i, genNum.w)
    Define i.i, LowHex$, HexNum$
    
    HexNum$ = Right(RSet(Hex(objNum, #PB_Long), 8, "0"), 6)
    For i=5 To 1 Step -2
      LowHex$ + Mid(HexNum$, i, 2)
    Next
    
    HexNum$ = RSet(Hex(genNum, #PB_Word), 4, "0")
    For i=3 To 1 Step -2
      LowHex$ + Mid(HexNum$, i, 2)
    Next
  
    ProcedureReturn LowHex$
  EndProcedure
  
  Procedure   RC4Mem(HexKey.s, *Memory, MemSize.i) 
    ; https://en.wikipedia.org/wiki/RC4
    Define.i i, j, n, KeyLen
    Define.a RNum, Byte.a
    
    KeyLen  = Len(HexKey) / 2
    
    Dim s.a(255)
    Dim k.a(KeyLen)
    
    For i=0 To 255 : s(i) = i : Next
    
    For i=0 To KeyLen - 1
      k(i) = Val("$" + Mid(HexKey, (i*2)+1, 2))
    Next
    
    j = 0
    For i = 0 To 255
      j = (j + s(i) + k(i % KeyLen)) % 256
      Swap s(i), s(j)
    Next
    
    i = 0 : j = 0
    
    If *Memory
      For n=0 To MemSize-1
        i = (i + 1) % 256
        j = (j + s(i)) % 256
        Swap s(i), s(j)
        RNum = s((s(i)+s(j)) % 256)
        Byte = RNum ! PeekA(*Memory + n)
        PokeA(*Memory + n, Byte)
      Next
    EndIf
    
  EndProcedure
  
  Procedure   EncryptMem_(objNum.i, genNum.i, *Memory, Size.i)
    ; PDF Reference Version 1.6 - Chapter 3.5.1
    Define EncryptKey.s, Hex$
    
    ; Encryption of data (Algorithm 3.1)
    Hex$ = PDF()\Encrypt\eKeyHex + objNumHex(objNum, genNum)
    EncryptKey = MD5(Hex$) ; 16 Byte (128 Bit / 8)
    
    RC4Mem(EncryptKey, *Memory, Size)
    
  EndProcedure
  
  Procedure.s Encrypt_(objNum.i, genNum.i, String.s, Flag.i=#False)
    ; PDF Reference Version 1.6 - Chapter 3.5.1
    Define EncryptKey.s, Hex$, RC4$, Result$
    
    ; Encryption of data (Algorithm 3.1)
    Hex$ = PDF()\Encrypt\eKeyHex + objNumHex(objNum, genNum)
    EncryptKey = MD5(Hex$) ; 16 Byte (128 Bit / 8)
    
    If Flag
      
      RC4$ = RC4(StringField(String, 1, "|"), EncryptKey, #HexKey)
      Result$ = EscapeHexStrg_(RC4$)
      
      RC4$ = RC4(StringField(String, 2, "|"), EncryptKey, #HexKey)
      Result$ + " " + EscapeHexStrg_(RC4$)
      
    Else
      
      RC4$ = RC4(String, EncryptKey, #HexKey)
      Result$ = EscapeHexStrg_(RC4$)
      
    EndIf
    
    ProcedureReturn Result$
  EndProcedure
  
  ;- ---- Objects ---------------------------
  
  Procedure.s strObj_(objNum.i)
    ProcedureReturn Str(objNum) + " 0 R"
  EndProcedure
  
  Procedure.i intObj_(objNum.s)
    ProcedureReturn Val(StringField(objNum, 1, " "))
  EndProcedure
  
  
  Procedure.i objNew_(Type.i=#False, Name.s="") ; [*]
    
    PDF()\objNum + 1 ; (no object 0)
    
    If AddMapElement(PDF()\Object(), strObj_(PDF()\objNum))
      
      PDF()\Object()\Type = Type
      
      Select Type
        Case #objAcroForm    ;{ AcroForm Object    
          If AddElement(PDF()\objAcroForms())
            PDF()\objAcroForms() = strObj_(PDF()\objNum)
          EndIf ;}
        Case #objBookmark    ;{ Bookmark Object
          If PDF()\OutLines\First = "" : PDF()\OutLines\First = strObj_(PDF()\objNum) : EndIf
          PDF()\OutLines\Last = strObj_(PDF()\objNum)
          PDF()\OutLines\Count + 1
          ;}
        Case #objFile        ;{ Embedded File Object
          If AddElement(PDF()\objFiles())
            PDF()\objFiles()\Object = strObj_(PDF()\objNum)
            PDF()\objFiles()\Name   = Name ; FileName
            If PDF()\Names\LimitEF\First = "" : PDF()\Names\LimitEF\First = GetFilePart(Name) : EndIf
            PDF()\Names\LimitEF\Last = GetFilePart(Name)
            ProcedureReturn ListIndex(PDF()\objFiles())
          EndIf ;}
        Case #objFont        ;{ (Embedded) Font Object
          If AddElement(PDF()\objFonts()) 
            PDF()\objFonts()\Object = strObj_(PDF()\objNum)
            PDF()\objFonts()\Name   = Name ; FontName
            ProcedureReturn ListIndex(PDF()\objFonts())
          EndIf ;}
        Case #objImage       ;{ Image Object
          If AddMapElement(PDF()\objImages(), GetFilePart(Name))
            PDF()\imgNum + 1
            PDF()\objImages()\Number = PDF()\imgNum
            PDF()\objImages()\Object = strObj_(PDF()\objNum)
            PDF()\objImages()\File   = Name ; FileName
          EndIf ;}
        Case #objJavaScript  ;{ Embedded JavaScript Object
          If AddElement(PDF()\objJavaScript())
            PDF()\objJavaScript()\Object = strObj_(PDF()\objNum)
            PDF()\objJavaScript()\Name   = Name
            If PDF()\Names\LimitJS\First = "" : PDF()\Names\LimitJS\First = Name : EndIf
            PDF()\Names\LimitJS\Last = Name
            ProcedureReturn ListIndex(PDF()\objJavaScript())
          EndIf ;}
        Case #objNames       ;{ Names Object
          PDF()\Catalog\objNames    = strObj_(PDF()\objNum)
          ;}
        Case #objOutlines    ;{ Outlines Object
          PDF()\Catalog\objOutlines = strObj_(PDF()\objNum)
          ;}
        Case #objPage        ;{ Page Object
          If AddElement(PDF()\Pages()) ; (Element 0 = PageTree)
            PDF()\objPage             = strObj_(PDF()\objNum)
            PDF()\Pages()\objNum      = PDF()\objPage
            PDF()\Pages()\ptWidth     = PDF()\Page\ptWidth
            PDF()\Pages()\ptHeight    = PDF()\Page\ptHeight
            PDF()\Pages()\Orientation = PDF()\Page\Orientation
            ProcedureReturn ListIndex(PDF()\Pages())
          EndIf ;}
        Case #objPageContent ;{ Page Content Object
          PDF()\objPageContent = strObj_(PDF()\objNum)
          If ListIndex(PDF()\Pages()) > 0
            PDF()\Pages()\objContent = PDF()\objPageContent
          EndIf ;}
      EndSelect
      
    EndIf
    
  EndProcedure  
  
  Procedure   objOutAP_(Stream.s, Flags.i=#False, objAP.s="")
    Define.i Size
    Define  *Stream, Compress.Memory_Structure
    
    If objAP = "" : objAP = strObj_(PDF()\objNum) : EndIf
    
    If FindMapElement(PDF()\Object(), objAP)
      
      Size = Len(Stream)
      
      *Stream = AllocateMemory(Size + 2)
      If *Stream
        
        PokeS(*Stream, Stream, Size, #PB_Ascii)
        
        If Flags & #objCompress
          If CompressMemory_(*Stream, @Compress)
            PDF()\Object()\Stream\Memory = Compress\Memory
            PDF()\Object()\Stream\Size   = Compress\Size
            PDF()\Object()\Stream\Flag   = Flags
          Else
            PDF()\Object()\Stream\Memory = *Stream
            PDF()\Object()\Stream\Size   = Size
            PDF()\Object()\Stream\Flag   = Flags & ~#objCompress
          EndIf
        Else
          PDF()\Object()\Stream\Memory = *Stream
          PDF()\Object()\Stream\Size   = Size
          PDF()\Object()\Stream\Flag   = Flags
        EndIf

      EndIf
      
    EndIf  
    
  EndProcedure
  
  Procedure   objOutDictionary_(String.s, startStrg.s="", endStrg.s="", Flags.i=#False, objDict.s="")
    
    If objDict = "" : objDict = strObj_(PDF()\objNum) : EndIf
    
    If FindMapElement(PDF()\Object(), objDict)
      
      If AddElement(PDF()\Object()\Dictionary())
        PDF()\Object()\Dictionary()\sStrg  = startStrg
        PDF()\Object()\Dictionary()\String = String
        PDF()\Object()\Dictionary()\eStrg  = endStrg
        PDF()\Object()\Dictionary()\Flags  = Flags
      EndIf
      
    EndIf
    
  EndProcedure
 
  Procedure   objOutPage_(String.s, startStrg.s="", endStrg.s="", Flags.i=#False, objPageContent.s="")
    ; Write to page content stream
    Define.i c, strgLen, startLen, endLen, Size
    Define *Memory, *MemPtr
    
    If objPageContent = "" : objPageContent = PDF()\objPageContent : EndIf
    
    If FindMapElement(PDF()\Object(), objPageContent)
      
      If Flags & #objUTF16  ;{ Write UTF-16 string
        
        If Right(endStrg, 1) <> #LF$ : endStrg + #LF$ : EndIf
        
        strgLen  = Len(String) * 2 + 2 ; 2 Byte for UTF-16
        startLen = Len(startStrg)
        endLen   = Len(endStrg)
        Size     = PDF()\Object()\Stream\Size + strgLen + startLen + endLen
        
        *Memory = AllocateMemory(Size + 2)
        If *Memory And Size
          
          *MemPtr = *Memory
          
          If PDF()\Object()\Stream\Memory And PDF()\Object()\Stream\Size
            CopyMemory(PDF()\Object()\Stream\Memory, *Memory, PDF()\Object()\Stream\Size)
            *MemPtr + PDF()\Object()\Stream\Size
            FreeMemory(PDF()\Object()\Stream\Memory)
          EndIf
          
          PokeS(*MemPtr, startStrg, startLen, #PB_Ascii)
          *MemPtr + startLen
          
          PokeU(*MemPtr, EndianW($FEFF))
          *MemPtr + 2
          For c=1 To Len(String)
            PokeU(*MemPtr, EndianW(Asc(Mid(String, c, 1))))
            *MemPtr + 2
          Next
          
          PokeS(*MemPtr, endStrg, endLen, #PB_Ascii)
          *MemPtr + endLen
          
          PDF()\Object()\Stream\Memory = *Memory
          PDF()\Object()\Stream\Size   = Size
          PDF()\Object()\Stream\Flag   = #objPage       
        EndIf
        ;}
      Else                  ;{ Write Ascii content
        
        String  = startStrg + String + endStrg
        If Right(String, 1) <> #LF$ : String + #LF$ : EndIf
        strgLen = Len(String)
        Size = PDF()\Object()\Stream\Size + strgLen
        
        *Memory = AllocateMemory(Size + 2)
        If *Memory
          
          *MemPtr = *Memory
          
          If PDF()\Object()\Stream\Memory
            CopyMemory(PDF()\Object()\Stream\Memory, *Memory, PDF()\Object()\Stream\Size)
            *MemPtr + PDF()\Object()\Stream\Size
            FreeMemory(PDF()\Object()\Stream\Memory)
          EndIf
          
          PokeS(*MemPtr, String, strgLen, #PB_Ascii)
          
          PDF()\Object()\Stream\Memory = *Memory
          PDF()\Object()\Stream\Size   = Size
          PDF()\Object()\Stream\Flag   = #objPage 
        EndIf
        ;}
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure   objOutStream_(*Stream, Size.i, Flag.i=#False, objStream.s="")
    
    If objStream = "" : objStream = strObj_(PDF()\objNum) : EndIf
    
    If FindMapElement(PDF()\Object(), objStream)
      
      PDF()\Object()\Stream\Memory = *Stream
      PDF()\Object()\Stream\Size   = Size
      PDF()\Object()\Stream\Flag   = Flag
     
    EndIf
    
  EndProcedure
  
  Procedure   objOutStrg_(String.s, Flags.i=#False, objOut.s="")
    
    If objOut = "" : objOut = strObj_(PDF()\objNum) : EndIf
    
    If FindMapElement(PDF()\Object(), objOut)
      
      PDF()\Object()\String = String
      PDF()\Object()\Flags  = Flags
      
    EndIf
    
  EndProcedure
  
  ;- ----- Annotations -----------------------------------
  
  CompilerIf #Enable_Annotations
    
    Procedure   AddAnnot_(LinkID.i, X.f, Y.f, Width.f, Height.f)
      ; PDF Reference Version 1.6 - Chapter 8.4 - 8.5
      Define.f aX, aY, aWidth, aHeight, ptY, ptWidth, ptHeight
      Define.s objFile, objParent, objStrg
      
      If SelectElement(PDF()\Annots(), LinkID)
        
        ;{ --- #PB_Default ---
        If PDF()\Annots()\X = #PB_Default : PDF()\Annots()\X = X : EndIf
        If PDF()\Annots()\Y = #PB_Default : PDF()\Annots()\Y = Y : EndIf
        
        If PDF()\Annots()\Width  = #PB_Default : PDF()\Annots()\Width  = Width  : EndIf
        If PDF()\Annots()\Height = #PB_Default : PDF()\Annots()\Height = Height : EndIf
        
        If PDF()\Annots()\Page   = #False : PDF()\Annots()\Page = PDF()\pageNum : EndIf
        ;}
        
        PDF()\Annots()\objPage = PDF()\objPage
        
        ;{ Scaled X / Y / Width / Height
        If PDF()\Page\Orientation = "P" 
          aX = PDF()\Annots()\X * PDF()\ScaleFactor
          aY = PDF()\Page\ptHeight - (PDF()\Annots()\Y * PDF()\ScaleFactor)
        Else
          aX = PDF()\Annots()\X * PDF()\ScaleFactor
          aY = PDF()\Page\ptWidth - (PDF()\Annots()\Y * PDF()\ScaleFactor)
        EndIf
        aWidth   = PDF()\Annots()\Width  * PDF()\ScaleFactor
        aHeight  = PDF()\Annots()\Height * PDF()\ScaleFactor
        ptY      = Y   * PDF()\ScaleFactor
        ptWidth  = Width  * PDF()\ScaleFactor
        ptHeight = Height * PDF()\ScaleFactor
        ;}
        
        If AddElement(PDF()\PageAnnots(PDF()\objPage)\Annot())
         
          objNew_()
          
          PDF()\PageAnnots(PDF()\objPage)\Annot() = strObj_(PDF()\objNum)
          
          Select PDF()\Annots()\Type
            Case #Annot_File   ;{ Add link to embedded file
              ; PDF Reference Version 1.6 - Chapter 8.4 (Table 8.16)
              If SelectElement(PDF()\objFiles(), PDF()\Annots()\FileID)
                objStrg = "/Type /Annot /Subtype /FileAttachment" + #LF$
                objStrg + "/Rect [" + strF_(aX + ptWidth, 2) + " " + strF_(aY, 2) + " " + strF_(aX + ptWidth + aWidth, 2) + " " + strF_(aY - aHeight, 2) + "]" + #LF$
                objStrg + "/FS " + PDF()\objFiles()\Object + #LF$
                objStrg + "/Name /" + PDF()\Annots()\Icon  + #LF$
                objOutDictionary_(objStrg, #LF$) 
                objOutDictionary_(PDF()\Annots()\Titel, "/T (", ")" + #LF$, #objText)
                objOutDictionary_(PDF()\Annots()\Content, "/Contents (", ")" + #LF$, #objText)
              EndIf ;}              
            Case #Annot_Launch ;{ Add launch action
              ; PDF Reference Version 1.6 - Chapter 8.5 (Table 8.44)
              objStrg = "/Type /Annot /Subtype /Link" + #LF$
              objStrg + "/Rect [" + strF_(aX, 2) + " " + strF_(aY, 2) + " " + strF_(aX + aWidth, 2) + " " + strF_(aY - aHeight, 2) + "]" + #LF$
              objStrg + "/Border [0 0 0]" + #LF$
              objStrg + "/A << /Type /Action /S /Launch /F << /Type /Filespec "
              objOutDictionary_(objStrg, #LF$)
              objOutDictionary_(PDF()\Annots()\File, "/F (", ") ", #objText)
              objOutDictionary_(PDF()\Annots()\File, "/F (", ") >> ", #objText)
              objOutDictionary_(PDF()\Annots()\Action, "/O (", ") >>" + #LF$, #objText)
              ;}
            Case #Annot_Text   ;{ Add text annotation
              ; PDF Reference Version 1.6 - Chapter 8.4 (Table 8.16)
              objStrg = "/Type /Annot /Subtype /Text" + #LF$
              objStrg + "/Rect [" + strF_(aX + ptWidth, 2) + " " + strF_(aY, 2) + " " + strF_(aX + ptWidth + aWidth, 2) + " " + strF_(aY - aHeight, 2) + "]" + #LF$
              objStrg + "/Name /" + PDF()\Annots()\Icon  + #LF$
              objOutDictionary_(objStrg, #LF$)
              objOutDictionary_(PDF()\Annots()\Titel, "/T (", ")" + #LF$, #objText)
              objOutDictionary_(PDF()\Annots()\Content, "/Contents (", ")" + #LF$, #objText)
              ;}              
            Case #Annot_URL    ;{ Add link to URL
              ; PDF Reference Version 1.6 - Chapter 8.4 (Table 8.16)
              objStrg = "/Type /Annot /Subtype /Link" + #LF$
              objStrg + "/Rect [" + strF_(aX, 2) + " " + strF_(aY, 2) + " " + strF_(aX + aWidth, 2) + " " + strF_(aY - aHeight, 2) + "]" + #LF$
              objStrg + "/Border [0 0 0]" + #LF$
              objOutDictionary_(objStrg, #LF$)
              objOutDictionary_(PDF()\Annots()\URL, "/A << /S /URI /URI (", ") >>" + #LF$, #objText)
              ;}
            Case #Annot_GoTo   ;{ Add link to destination
              ; PDF Reference Version 1.6 - Chapter 8.4 (Table 8.16)
              objStrg = "/Type /Annot /Subtype /Link" + #LF$
              objStrg + "/Rect [" + strF_(aX, 2) + " " + strF_(aY, 2) + " " + strF_(aX + aWidth, 2) + " " + strF_(aY - aHeight, 2) + "]"
              If aY > 0
                objStrg + "/Dest [" + PDF()\Annots()\objDest + " /XYZ 0 " + Str(aY) + " 0]" + #LF$
              Else
                objStrg + "/Dest [" + PDF()\Annots()\objDest + "]" + #LF$
              EndIf
              objOutDictionary_(objStrg, #LF$)
              ;}
          EndSelect
        
        EndIf
      
      EndIf
      
    EndProcedure  
    
    Procedure   AddLabelLink_(Label.s, X.f, Y.f, Width.f, Height.f)
      ; PDF Reference Version 1.6 - Chapter 8.5 (Table 8.44)
      Define.f ptX, ptY, ptWidth, ptHeight
      Define.s objStrg
      
      If PDF()\Page\Orientation = "P" 
        ptX = X * PDF()\ScaleFactor
        ptY = PDF()\Page\ptHeight - (Y * PDF()\ScaleFactor)
      Else
        ptX = X * PDF()\ScaleFactor
        ptY = PDF()\Page\ptWidth  - (Y * PDF()\ScaleFactor)
      EndIf
      ptWidth  = Width  * PDF()\ScaleFactor
      ptHeight = Height * PDF()\ScaleFactor
      
      objNew_()
      PDF()\Labels(Label)\objAnnot = strObj_(PDF()\objNum)
      PDF()\Labels(Label)\objPage  = PDF()\objPage
      objStrg = "/Type /Annot /Subtype /Link" + #LF$
      objStrg + "/Rect [" + strF_(ptX, 2) + " " + strF_(ptY, 2) + " " + strF_(ptX + ptWidth, 2) + " " + strF_(ptY - ptHeight, 2) + "]"+ #LF$
      objOutDictionary_(objStrg, #LF$)
      
    EndProcedure  
    
  CompilerEndIf
 
  ;- ----- Images -------------------------------------------
  
  Procedure HeaderJPG_(*Memory, Size.i, *Header.Image_Header_Structure)
    Define.i Marker, BlockLen, Result
    Define *MemPtr
    
    If *Memory And Size
      
      *Header\Memory = *Memory
      *Header\Size   = Size
      
      *MemPtr = *Memory
      
      Repeat
        Marker = uint16(PeekW(*MemPtr))
        *MemPtr + 2
        Select Marker
          Case $FFD8 ; "Start of Image"
            *Header\Signature = Hex(Marker)
          Case $FFC0 To $FFC3, $FFC5 To $FFC7, $FFC9 To $FFCB, $FFCD To $FFCF
            ; $FFC0 Baseline DCT / $FFC1 Extended sequential DCT / $FFC2 Progressive DCT
            BlockLen   = uint16(PeekW(*MemPtr))
            *MemPtr + 2
            *Header\BitDepth    = uint8(PeekB(*MemPtr))
            *Header\Height      = uint16(PeekW(*MemPtr + 1))
            *Header\Width       = uint16(PeekW(*MemPtr + 3))
            *Header\ColorSpace  = uint8(PeekB(*MemPtr  + 5))
            *MemPtr + BlockLen
            Result = #True
          Case $FFDA          ; Image data
            Break
          Case $FFD0 To $FFD7, $FFD9 ; Markers only
            Continue
          Default
            BlockLen = uint16(PeekW(*MemPtr))
            *MemPtr + BlockLen
        EndSelect
        
      Until *MemPtr >= *Memory + Size

    Else
      PDF()\Error = #ERROR_PROBLEM_READING_IMAGE_FILE_IN_MEMORY
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure HeaderPNG_(*Memory, Size.i, *Header.Image_Header_Structure)
    Define.i BlockLen, CRC, Result
    Define.s BlockTyp
    Define *MemPtr
    
    If *Memory And Size
      
      *MemPtr = *Memory
      
      *Header\Signature = Hex(EndianQ(PeekQ(*MemPtr)), #PB_Quad)
      *MemPtr + 8
      
      Repeat
        BlockLen = uint32(PeekL(*MemPtr))
        *MemPtr + 4
        BlockTyp = PeekS(*MemPtr, 4, #PB_Ascii)
        
        *MemPtr + 4
        
        Select BlockTyp
          Case "IHDR"
            *Header\Width       = uint32(PeekL(*MemPtr))
            *Header\Height      = uint32(PeekL(*MemPtr + 4))
            *Header\BitDepth    = uint8(PeekB(*MemPtr  + 8))
            *Header\ColorSpace  = uint8(PeekB(*MemPtr  + 9))
            *Header\Compression = uint8(PeekB(*MemPtr  + 10))
            *Header\Prediktor   = uint8(PeekB(*MemPtr  + 11))
            *Header\Interlacing = uint8(PeekB(*MemPtr  + 12))
            Result = #True
          Case "PLTE"
            *Header\PalSize = BlockLen
            *Header\PalPtr  = AllocateMemory(BlockLen)
            If *Header\PalPtr
              CopyMemory(*MemPtr, *Header\PalPtr, BlockLen)
            EndIf
          Case "IDAT"
            *Header\Size    = BlockLen
            *Header\Memory  = AllocateMemory(BlockLen)
            If *Header\Memory : CopyMemory(*MemPtr, *Header\Memory, BlockLen) : EndIf
            FreeMemory(*Memory)
            Break
        EndSelect
        *MemPtr + BlockLen
        CRC = uint32(PeekL(*MemPtr))
        *MemPtr + 4
      Until BlockTyp = "IEND" Or *MemPtr >= *Memory + Size 
    Else
      PDF()\Error = #ERROR_PROBLEM_READING_IMAGE_FILE_IN_MEMORY
    EndIf
    
    ProcedureReturn Result
  EndProcedure  
  
  Procedure HeaderJP2_(*Memory, Size.i, *Header.Image_Header_Structure)
    Define.i ChunkSize, Meth, NC, Result
    Define.s ChunkType
    Define *MemPtr
    
    If *Memory And Size
      
      *Header\Memory = *Memory
      *Header\Size   = Size
      
      *MemPtr = *Memory
      
      ; --- Signature (Type) ---
      ChunkSize = uint32(PeekL(*MemPtr))
      *MemPtr + 4
      *Header\Signature = PeekS(*MemPtr, 4, #PB_Ascii)
      *MemPtr + (ChunkSize - 4)
      
      Repeat
        
        ChunkSize = uint32(PeekL(*MemPtr))       : *MemPtr + 4
        ChunkType = PeekS(*MemPtr, 4, #PB_Ascii) : *MemPtr + 4
        
        If ChunkSize <= 0 : Break : EndIf
        
        Select ChunkType
          Case "ihdr" ;{ Image header
            *Header\Height = uint32(PeekL(*MemPtr))     : *MemPtr + 4
            *Header\Width  = uint32(PeekL(*MemPtr))     : *MemPtr + 4
            NC = uint16(PeekW(*MemPtr))                 : *MemPtr + 2
            *Header\BitDepth = uint8(PeekB(*MemPtr))    : *MemPtr + 1
            If *Header\BitDepth <> 255 : *Header\BitDepth + 1 : EndIf
            *Header\Compression = uint8(PeekB(*MemPtr))
            *MemPtr + (ChunkSize - 19)
            Result = #True
            ;}
          Case "bpcc" ;{ Bits per component box
            *Header\BitDepth=  uint8(PeekB(*MemPtr)) + 1
            *MemPtr + (ChunkSize - 8)
            ;}
          Case "colr" ;{ Colour specification
            Meth = uint8(PeekB(*MemPtr))                ; METH: 1 = Enumerated colourspace / 2 = Restricted ICC profile
            *MemPtr + 3
            *Header\ColorSpace = uint32(PeekL(*MemPtr)) ; 0: Bi-level / 3: YCbCr(2) / 14: CIELab / 16: sRGB / 17: Greyscale / 18: sRGB YCC
            *MemPtr + (ChunkSize - 11)
            ;}
          Default
            *MemPtr + ChunkSize
        EndSelect
        
      Until *MemPtr >= *Memory + Size

    Else
      PDF()\Error = #ERROR_PROBLEM_READING_IMAGE_FILE_IN_MEMORY
    EndIf
    
    ProcedureReturn Result
  EndProcedure  

  Procedure Image_(FileName.s, *Memory, Size.i, Format.i, X.f, Y.f, Width.f=#False, Height.f=#False, Link.i=#NoLink)
    Define Header.Image_Header_Structure
    Define.s Filter, ColorSpace, Parms, objPalette, objStrg
    
    If *Memory And Size
      
      If FindMapElement(PDF()\objImages(), GetFilePart(FileName)) = #False

        ; Read image file header
        Select Format
          Case #Image_PNG      ;{ PNG-Image
            If HeaderPNG_(*Memory, Size, @Header)
              Filter = "FlateDecode"
              Select Header\ColorSpace
                Case 0
                  ColorSpace = "DeviceGray"
                  Parms     = "/DecodeParms <</Predictor 15 /Colors 1 /BitsPerComponent " + Str(Header\BitDepth) + " /Columns " + Str(Header\Width) + ">>"  
                Case 2
                  ColorSpace = "DeviceRGB" 
                  Parms     = "/DecodeParms <</Predictor 15 /Colors 3 /BitsPerComponent " + Str(Header\BitDepth) + " /Columns " + Str(Header\Width) + ">>"          
                Case 3
                  ColorSpace = "Indexed"
                  Parms     = "/DecodeParms <</Predictor 15 /Colors 1 /BitsPerComponent " + Str(Header\BitDepth) + " /Columns " + Str(Header\Width) + ">>"          
                Default
                  PDF()\Error = #ERROR_ALPHA_CHANNEL_PNG_NOT_SUPPORTED
                  ProcedureReturn #False
              EndSelect
              If ColorSpace = "Indexed"
                objNew_()
                objPalette = strObj_(PDF()\objNum)
                objOutDictionary_("/Length " + Str(Header\PalSize))
                objOutStream_(Header\PalPtr, Header\PalSize) 
              EndIf
            Else
              PDF()\Error = #ERROR_INCORRECT_PNG_FILE
              ProcedureReturn #False
            EndIf ;}
          Case #Image_JPEG     ;{ JPEG-Image
            If HeaderJPG_(*Memory, Size, @Header)
              Filter = "DCTDecode"
              Select Header\ColorSpace
                Case 1
                  ColorSpace = "DeviceGray"
                Case 3
                  ColorSpace = "DeviceRGB"           
                Default:
                  ColorSpace = "DeviceCMYK"               
              EndSelect
            Else
              PDF()\Error = #ERROR_NOT_A_JPEG_FILE
              ProcedureReturn #False
            EndIf ;}
          Case #Image_JPEG2000 ;{ JEPEG200-Image
            If HeaderJP2_(*Memory, Size, @Header)
              Filter = "JPXDecode"
              ; 0: Bi-level / 3: YCbCr(2) / 14: CIELab / 16: sRGB / 17: Greyscale / 18: sRGB YCC
              Select Header\ColorSpace
                Case 17
                  ColorSpace = "DeviceGray" 
                Case 16, 18
                  ColorSpace = "DeviceRGB"
                Default
                  ColorSpace = "" ; use color space specifications in the JPEG2000 data
              EndSelect
            Else
              PDF()\Error = #ERROR_NOT_A_JPEG_FILE
              ProcedureReturn #False
            EndIf ;}
        EndSelect
  
        objNew_(#objImage, FileName)
        objStrg = "/Type /XObject /Subtype /Image" + #LF$
        objStrg + "/Width "  + Str(Header\Width) + #LF$ + "/Height " + Str(Header\Height) + #LF$
        If ColorSpace = "Indexed"
          objStrg + "/ColorSpace [/Indexed /DeviceRGB " + Str(Header\PalSize / 3 - 1) + " " + objPalette + "]" + #LF$          
        ElseIf ColorSpace <> " " ; no ColorSpace for JP2 
          objStrg + "/ColorSpace /" + ColorSpace + #LF$
          If ColorSpace = "DeviceCMYK"
            objStrg + "/Decode [1 0 1 0 1 0 1 0]" + #LF$
          EndIf
        EndIf
        objStrg + "/BitsPerComponent " + Str(Header\BitDepth) + #LF$
        objStrg + "/Filter /" + Filter + #LF$
        If Parms <> "" : objStrg + Parms + #LF$ : EndIf
        objStrg + "/Length "+Str(Header\Size) + #LF$
        objOutDictionary_(objStrg, #LF$)
        objOutStream_(Header\Memory, Header\Size)
 
      EndIf

      ; ===== Automatic width and height calculation if needed
      
      If Width = 0 And Height = 0 ;{ Put image at 72 dpi
        Width  = Header\Width  / PDF()\ScaleFactor
        Height = Header\Height / PDF()\ScaleFactor
        ;}
      EndIf
      
      If Width  = 0 : Width  = Height * Header\Width  / Header\Height : EndIf
      If Height = 0 : Height = Width  * Header\Height / Header\Width  : EndIf
  
      objOutPage_("q " + strF_(Width * PDF()\ScaleFactor, 2) + " 0 0 " + strF_(Height * PDF()\ScaleFactor, 2) + " " + strF_(X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (Y + Height)) * PDF()\ScaleFactor, 2) + " cm /I" + Str(PDF()\objImages()\Number) + " Do Q")
      
      CompilerIf #Enable_Annotations
        If Link > #NoLink : AddAnnot_(Link, X, Y, Width, Height) : EndIf
      CompilerEndIf
      
    EndIf
    
  EndProcedure
  
  ;- ----- Graphic ----------------------------
  
  CompilerIf #Enable_DrawingCommands

    Procedure Arc_(X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f) ; [!]
      
      objOutPage_(strF_(X1 * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y1) * PDF()\ScaleFactor, 2) + " " + strF_(X2 * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y2) * PDF()\ScaleFactor, 2) + " " + strF_(X3 * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y3) * PDF()\ScaleFactor, 2) + " c")
      
    EndProcedure  
  
    Procedure PathBegin_(X.f, Y.f)                     ; [!]
      
      objOutPage_(strF_(X * PDF()\ScaleFactor, 2) + " " + strF_(((PDF()\Page\Height - Y)) * PDF()\ScaleFactor, 2) + " m")
      
    EndProcedure
    
    Procedure PathEnd_(Style.s="")                     ; [!]
      
      Select Style
        Case #DrawOnly
          objOutPage_("s")          ; Close and stroke the path
        Case #DrawAndFill
          objOutPage_("b")          ; Close, fill, and then stroke the path
        Case #FillOnly
          objOutPage_("f")          ; Fill the path
        Case ""
          objOutPage_("S")          ; Stroke the path
        Default
          objOutPage_(Style)
      EndSelect
      
    EndProcedure

    Procedure PathLine_(X.f, Y.f)                      ; [!]
      
      objOutPage_(strF_(X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y) * PDF()\ScaleFactor, 2) + " l")
      
    EndProcedure
  
    Procedure Ellipse_(X.f, Y.f, RadiusX.f, RadiusY.f, Style.s)   ; ipdf_Ellipse(x.f, y.f, rx.f, ry.f, Style$)
      Define.f lX, lY
      
      lX = 4 / 3 * (Sqr(2) - 1) * RadiusX
      lY = 4 / 3 * (Sqr(2) - 1) * RadiusY
      
      PathBegin_(X + RadiusX, y)
      Arc_(X + RadiusX, Y - lY, X + lX, Y - RadiusY, X, Y - RadiusY)
      Arc_(X - lX, Y - RadiusY, X - RadiusX, Y - lY, X - RadiusX, Y)
      Arc_(X - RadiusX, Y + lY, X - lX, Y + RadiusY, X, Y + RadiusY)
      Arc_(X + lX, Y + RadiusY, X + RadiusX, Y + lY, X + RadiusX, Y)
      PathEnd_(Style)
      
    EndProcedure
    
    Procedure Circle_(X.f, Y.f, Radius.f, Style.s) 
      Define.f lX, lY
      
      lX = 4 / 3 * (Sqr(2) - 1) * Radius
      lY = 4 / 3 * (Sqr(2) - 1) * Radius
      
      PathBegin_(X + Radius, y)
      Arc_(X + Radius, Y - lY, X + lX, Y - Radius, X, Y - Radius)
      Arc_(X - lX, Y - Radius, X - Radius, Y - lY, X - Radius, Y)
      Arc_(X - Radius, Y + lY, X - lX, Y + Radius, X, Y + Radius)
      Arc_(X + lX, Y + Radius, X + Radius, Y + lY, X + Radius, Y)
      PathEnd_(Style)
      
    EndProcedure
    
    Procedure Rectangle_(X.f, Y.f, Width.f, Height.f, Style.s="") ; ipdf_Rect(x.f,y.f,w.f,h.f,Style$="")
      
      objOutPage_(strF_(X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y) * PDF()\ScaleFactor, 2) + " " + strF_(Width * PDF()\ScaleFactor, 2) + " " + strF_(-Height * PDF()\ScaleFactor, 2) + " re")
      Select Style
        Case #FillOnly
          objOutPage_("f")
        Case #DrawAndFill
          objOutPage_("B")
        Default
          objOutPage_("S")
      EndSelect
      
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_TransformCommands
    
    Procedure Transform_(p1.f, p2.f, p3.f, p4.f, p5.f, p6.f) ; [!]
      objOutPage_(strF_(p1, 3) + " " + strF_(p2, 3) + " " + strF_(p3, 3) + " " + strF_(p4, 3) + " " + strF_(p5, 3) + " " + strF_(p6, 3) + " cm")  
    EndProcedure

    Procedure Scale_(SX.f, SY.f, X.f, Y.f) ; [!]
      
      If X = #PB_Default : X = PDF()\Page\X : EndIf  
      If Y = #PB_Default : Y = PDF()\Page\Y : EndIf
      
      If X = 0 Or Y = 0    
        ProcedureReturn #PB_Default
      EndIf
      
      Y = (PDF()\Page\Height - Y) * PDF()\ScaleFactor
      X = X * PDF()\ScaleFactor
      
    	; Calculate elements of transformation matrix
    	SX / 100
    	SY / 100 
    	
      ; Scale the coordinate system
    	Transform_(SX, 0, 0, SY, X * (1 - SX), Y * (1 - SY))
    	
    EndProcedure 
  
    Procedure Skew_(AngleX.f, AngleY.f, X.f, Y.f) ; [!]
      Define.f p2, p3 
      
      If X = #PB_Default : X = PDF()\Page\X : EndIf 
      If Y = #PB_Default : Y = PDF()\Page\Y : EndIf
      
      If AngleX <= -90 Or AngleX >= 90 Or AngleY <= -90 Or AngleY >= 90   
        ProcedureReturn #False
      EndIf
      
      Y = (PDF()\Page\Height - Y) * PDF()\ScaleFactor
      X = X * PDF()\ScaleFactor
      
    	; Calculate elements of transformation matrix 
    	p2 = Tan(AngleY * #PI / 180)
    	p3 = Tan(AngleX * #PI / 180)
    	
    	Transform_(1, p2, p3, 1, -Y * p3, -X * p2) ; Scale the coordinate system
    	
    EndProcedure
    
  CompilerEndIf
   
  ;- ----- Fonts ----------------------------

  Procedure FileHeaderTTF_(FileName.s,*Font.TTF_Header_Structure)
    Define.i i, utf, HeaderID, Result, Position, Length, Size, Number
    Define.i Skala, Encoding, Blocks, maxGID, NumGID, GID
    Define.s ID, psName$, osName$, UTF$
    Define *Memory, *MemoryPtr, *BlockPtr, *StartPos
    NewMap  Block.TTF_Block_Structure()
    NewMap  ucChar.i()
    
    If ReadFile(#File, FileName)
      
      Size = Lof(#File)
      
      *Memory = AllocateMemory(Size)
      If *Memory
        
        If ReadData(HeaderID, *Memory, Size)
          
          *MemoryPtr = *Memory
          
          *Font\Signature = Hex(uint32(PeekL(*MemoryPtr)))
          *MemoryPtr + 4
          
          If *Font\Signature = "10000"
            
            ;{ Read: Block Directory
            Blocks    = uint16(PeekW(*MemoryPtr))        : *MemoryPtr + 8
            For i=1 To Blocks
              ID  = PeekS(*MemoryPtr, 4, #PB_Ascii)      : *MemoryPtr + 8
              If AddMapElement(Block(), ID)
                Block()\Pos  = uint32(PeekL(*MemoryPtr)) : *MemoryPtr + 4
                Block()\Size = uint32(PeekL(*MemoryPtr)) : *MemoryPtr + 4
              EndIf
            Next ;}
            
            If FindMapElement(Block(), "name") ;{ Block: "name"
              *BlockPtr  = *Memory + Block()\Pos
              *MemoryPtr = *BlockPtr + 2
              Number     = uint16(PeekW(*MemoryPtr)) : *MemoryPtr + 2
              *StartPos  = *BlockPtr + uint16(PeekW(*MemoryPtr)) : *MemoryPtr + 2
              For i=1 To Number
                If uint16(PeekW(*MemoryPtr)) = 3       ; platform
                  Length = uint16(PeekW(*MemoryPtr + 8))
                  Position = uint16(PeekW(*MemoryPtr + 10))
                  Select uint16(PeekW(*MemoryPtr + 6)) ; typ
                    Case 4                             ; OS-specific name
                      If uint16(PeekW(*MemoryPtr + 4)) = $409 ; language
                        osName$ = PeekUTF16(*StartPos + Position, Length)
                      EndIf
                    Case 6 ; PostScript name
                      psName$ = PeekUTF16(*StartPos + Position, Length)
                  EndSelect
                EndIf
                *MemoryPtr + 12
              Next
              
              If psName$ 
                *Font\Name = psName$
              Else
                *Font\Name = osName$
              EndIf
              ;}
            EndIf
            
            If FindMapElement(Block(), "head") ;{ Block: "head" [/FontBBox]
              *BlockPtr  = *Memory + Block()\Pos
              Skala = uint16(PeekW(*BlockPtr + 18))
              *Font\Skala = Skala
              *Font\BBox\X1 = Round((int16(PeekW(*BlockPtr + 36)) * 1000) / Skala, #PB_Round_Nearest)
              *Font\BBox\Y1 = Round((int16(PeekW(*BlockPtr + 38)) * 1000) / Skala, #PB_Round_Nearest)
              *Font\BBox\X2 = Round((int16(PeekW(*BlockPtr + 40)) * 1000) / Skala, #PB_Round_Nearest)
              *Font\BBox\Y2 = Round((int16(PeekW(*BlockPtr + 42)) * 1000) / Skala, #PB_Round_Nearest)
              ;}
            EndIf
            
            If FindMapElement(Block(), "OS/2") ;{ Block: "OS/2"
              *BlockPtr = *Memory + Block()\Pos
              *Font\Flag    = Round((int16(PeekW(*BlockPtr +  8)) * 1000) / Skala, #PB_Round_Nearest)
              *Font\Ascent  = Round((int16(PeekW(*BlockPtr + 68)) * 1000) / Skala, #PB_Round_Nearest)
              *Font\Descent = Round((int16(PeekW(*BlockPtr + 70)) * 1000) / Skala, #PB_Round_Nearest)
              If uint16(PeekW(*BlockPtr)) >= 2 ; block format version 
                *Font\CapHeight = Round((int16(PeekW(*BlockPtr + 88)) * 1000) / Skala, #PB_Round_Nearest)
              Else
                *Font\CapHeight = *Font\Ascent
              EndIf
              ;}
            EndIf
            
            If FindMapElement(Block(), "post") ;{ Block: "post"
              ; Bevel = BevelFraction / 65536 + BevelInteger
              *BlockPtr = *Memory + Block()\Pos
              *Font\BevelInteger   = int16(PeekW(*BlockPtr + 4))
              *Font\BevelFraction  = uint16(PeekW(*BlockPtr + 6))
              *Font\FixedWidth     = uint32(PeekL(*BlockPtr + 12))
              *Font\ItalicAngle    = (*Font\BevelFraction / 65536) + *Font\BevelInteger
              ;}
            EndIf
            
            If FindMapElement(Block(), "cmap") ;{ Block: "cmap"
              *BlockPtr = *Memory + Block()\Pos
              
              Number     = uint16(PeekW(*BlockPtr + 2))
              *MemoryPtr = *BlockPtr + 4
              
              ;{ ----- Search subblock -----
              For i=1 To Number 
                If uint16(PeekW(*MemoryPtr)) = 3 ; Plattform
                  Encoding = uint16(PeekW(*MemoryPtr + 2))
                  If Encoding = 0 Or Encoding = 1
                    *StartPos  = *BlockPtr + uint32(PeekL(*MemoryPtr + 4))
                    *Font\Encoding = Encoding
                    Break
                  EndIf
                EndIf
                *MemoryPtr + 8
              Next ;}
              
              ;{ ----- Segment Lists -----
              *MemoryPtr = *StartPos
              If uint16(PeekW(*MemoryPtr)) = 4 ; Format
                Length = uint16(PeekW(*MemoryPtr + 6)) ; List lenght (byte)
                *MemoryPtr + 14
                Number = Length / 2
                Dim Segment.TTF_Segment_Structure(Number - 1)
                For i=0 To Number - 1
                  Segment(i)\EndCode = uint16(PeekW(*MemoryPtr))
                  *MemoryPtr + 2
                Next
                *MemoryPtr + 2
                For i=0 To Number - 1
                  Segment(i)\StartCode = uint16(PeekW(*MemoryPtr))
                  *MemoryPtr + 2
                Next
                For i=0 To Number - 1
                  Segment(i)\Delta = uint16(PeekW(*MemoryPtr))
                  *MemoryPtr + 2
                Next
                For i=0 To Number - 1
                  Segment(i)\Offset = uint16(PeekW(*MemoryPtr))
                  *MemoryPtr + 2
                Next
              EndIf ;}
              
              ;{ ----- Determine GID -----
              *Font\CIDToGIDMap = AllocateMemory(131072)
              
              *MemoryPtr = *Font\CIDToGIDMap
              
              For utf=0 To 65535 ; Unicode
              
                For i=0 To Number - 1
                  If Segment(i)\EndCode >= utf
                    UTF$ = Str(utf)
                    If Segment(i)\StartCode > utf    ;{ StartCode > UC
                      ucChar(UTF$) = 0
                      Break ;}
                    Else
                      If Segment(i)\Offset = 0       ;{ Offset = 0
                        If Segment(i)\Delta = 0
                          ucChar(UTF$) = utf
                          Break
                        Else
                          ucChar(UTF$) = utf + Segment(i)\Delta
                          ucChar(UTF$) = ucChar(UTF$) % 65536
                          Break
                        EndIf ;}
                      Else                           ;{ Offset <> 0
                        Position = 16 + (Length * 3) + (i * 2) + Segment(i)\Offset + ((utf - Segment(i)\StartCode) * 2)
                        ucChar(UTF$) = uint16(PeekW(*StartPos + Position))
                        Break ;}
                      EndIf
                    EndIf
                  EndIf
                Next
                
                If *MemoryPtr
                  PokeW(*MemoryPtr, int16(ucChar(UTF$)))
                  *MemoryPtr + 2
                EndIf
                
              Next ;}
              
              ;}
            EndIf
            
            If FindMapElement(Block(), "hhea") ;{ Block: "hhea"
              *BlockPtr = *Memory + Block()\Pos
              NumGID = uint16(PeekW(*BlockPtr + 34)) ; Number of GIDs with explicitly listed character width
              maxGID = NumGID - 1                    ; First GID = 0
              ;}
            EndIf
            
            If FindMapElement(Block(), "hmtx") ;{ Block: "hmtx"
              *BlockPtr = *Memory + Block()\Pos
  
              Dim CharW.i(maxGID)
              
              For i=0 To maxGID ;{ GID widths
                CharW(i) = uint16(PeekW(*BlockPtr))
                *BlockPtr + 4 ;}
              Next
              
              *Font\MissingWidth = Round((CharW(0)  * 1000) / Skala, #PB_Round_Nearest)
              
              ForEach ucChar()
                If ucChar() > 0
                  UTF$ = MapKey(ucChar())
                  If ucChar() > maxGID
                    *Font\CharWidth(UTF$) = Round((CharW(maxGID)   * 1000) / Skala, #PB_Round_Nearest)
                  Else
                    *Font\CharWidth(UTF$) = Round((CharW(ucChar()) * 1000) / Skala, #PB_Round_Nearest)
                  EndIf
                EndIf
              Next
              ;}
            EndIf
            
            Result = #True
            
          EndIf 
        EndIf
        
        FreeMemory(*Memory)
      EndIf
      
      CloseFile(#File)
    Else
      PDF()\Error = #ERROR_FILE_READ
    EndIf
    
    ProcedureReturn Result
  EndProcedure 
  
  Procedure AddFontData_(FontName.s, Style.s, FontKey.s)
    Define.i vCharWidth, vFont, j
    Define.s objStrg

    If AddMapElement(PDF()\Fonts(), FontKey)
      
      PDF()\Fonts()\Number = MapSize(PDF()\Fonts())
      PDF()\Fonts()\Style  = Style
      
      ;{ --- Internal Fonts ---
      Select UCase(FontName + Style)
        Case "COURIER"
          PDF()\Fonts()\Name     = #FONT_COURIER
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Default
        Case "COURIERB"
          PDF()\Fonts()\Name     = #FONT_COURIERB
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Default
        Case "COURIERI"
          PDF()\Fonts()\Name     = #FONT_COURIERI
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Default
        Case "COURIERBI"
          PDF()\Fonts()\Name     = #FONT_COURIERBI
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Default                  
        Case "HELVETICA"  
          PDF()\Fonts()\Name     = #FONT_HELVETICA
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore Helvetica                      
        Case "HELVETICAB"  
          PDF()\Fonts()\Name     = #FONT_HELVETICAB
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore HelveticaB
        Case "HELVETICAI"  
          PDF()\Fonts()\Name     = #FONT_HELVETICAI
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore HelveticaI     
        Case "HELVETICABI"  
          PDF()\Fonts()\Name     = #FONT_HELVETICABI
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore HelveticaBI 
        Case "ZAPFDINGBATS"  
          PDF()\Fonts()\Name     = #FONT_ZAPFDINGBATS
          PDF()\Fonts()\Encoding = 0
          vFont = #Font_Internal
          Restore Zapfdingbats   
        Case "TIMES"  
          PDF()\Fonts()\Name     = #FONT_TIMES
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore Times
        Case "TIMESI"  
          PDF()\Fonts()\Name     = #FONT_TIMESI
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore TimesI    
        Case "TIMESBI"  
          PDF()\Fonts()\Name     = #FONT_TIMESBI
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore TimesBI      
        Case "TIMESB"  
          PDF()\Fonts()\Name     = #FONT_TIMESB
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Internal
          Restore TimesB   
        Case "SYMBOL"  
          PDF()\Fonts()\Name     = #FONT_SYMBOL
          PDF()\Fonts()\Encoding = 0
          vFont = #Font_Internal
          Restore Symbol
        Default
          PDF()\Fonts()\Name     = #FONT_COURIER
          PDF()\Fonts()\Encoding = 1
          vFont = #Font_Default
      EndSelect ;}
      
      Select vFont
        Case #Font_Default  ; Courier
          For j = 0 To 255
            PDF()\Fonts()\CharWidth(Chr(j)) = 600
          Next
        Case #Font_Internal ; Helvetica / Times / Symbol / ZapfDingBats
          For j = 0 To 255
            Read.w vCharWidth
            PDF()\Fonts()\CharWidth(Chr(j)) = vCharWidth
          Next
      EndSelect
      
      objNew_(#objFont, PDF()\Fonts()\Name)
      objStrg = "/Type /Font /Subtype /Type1 /BaseFont /" + PDF()\Fonts()\Name
      If PDF()\Fonts()\Encoding
        objStrg + " /Encoding /WinAnsiEncoding"
      EndIf
      objOutDictionary_(objStrg)
      
      ProcedureReturn #True
    EndIf  
 
  EndProcedure    
    
  Procedure SetFontSize_(Size.i)
    
    If PDF()\Font\SizePt <> Size
      
      PDF()\Font\SizePt = Size
      PDF()\Font\Size   = Size / PDF()\ScaleFactor
      
      If PDF()\pageNum > 0
        objOutPage_("BT /F" + Str(PDF()\Fonts()\Number) + " " + strF_(PDF()\Font\SizePt, 2) + " Tf ET")  
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure SetFont_(Family.s, Style.s, Size.i)
    Define.s vFontKey
    
    ; Select a font, size given in points
    Family = Trim(Family)
    If Family = "" : Family = PDF()\Font\Family : EndIf
    
    Select UCase(Family)
      Case "ARIAL"
        Family = "HELVETICA"
      Case "TIMES-ROMAN"
        Family = "TIMES"
      Case "SYMBOL"
        Style = ""
      Case "ZAPFDINGBATS"
        Style = ""  
    EndSelect
    
    Style = Trim(UCase(Style))
    If FindString(Style, "U", 1) > 0
      PDF()\Font\Underline = #True
      Style = ReplaceString(Style, "U", "")
    Else
      PDF()\Font\Underline = #False
    EndIf
    
    If Style = "IB" : Style = "BI" : EndIf
    If Size  = 0    : Size  = PDF()\Font\SizePt : EndIf
    
    If UCase(PDF()\Font\Family) <> UCase(Family) Or PDF()\Font\Style <> Style Or PDF()\Font\SizePt <> Size
      
      vFontKey = UCase(RSet(Style, 3, "_") + Family) ; BI_+Fontname

      If FindMapElement(PDF()\Fonts(), vFontKey) = #False
        AddFontData_(Family, Style, vFontKey)
      EndIf
      
      If FindMapElement(PDF()\Fonts(), vFontKey)
        
        PDF()\Font\Number  = PDF()\Fonts()\Number
        PDF()\Font\Family  = Family
        PDF()\Font\Style   = Style
        PDF()\Font\SizePt  = Size
        PDF()\Font\Size    = Size / PDF()\ScaleFactor
        PDF()\Font\Unicode = PDF()\Fonts()\Unicode
        
        If PDF()\pageNum > 0
          objOutPage_("BT /F" + Str(PDF()\Fonts()\Number) + " " + strF_(PDF()\Font\SizePt, 2) + " Tf ET")
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure

  ;- ----- Color ----------------------------
  
  Procedure   SetDrawColor_(Red.f, Green.f, Blue.f)
    
    If (Green = 0 And Blue = 0) Or Green = #PB_Default
      PDF()\Color\Draw = strF_(Red / 255, 3) + " G"
    Else
      PDF()\Color\Draw = strF_(Red / 255, 3) + " " + strF_(Green / 255, 3) + " " + strF_(Blue / 255, 3) + " RG"
    EndIf
    
    If PDF()\pageNum > 0 : objOutPage_(PDF()\Color\Draw) : EndIf
    
  EndProcedure   
  
  Procedure   SetFrontColor_(Red.f, Green.f, Blue.f)
    
    If (Green = 0 And Blue = 0) Or Green = #PB_Default
      PDF()\Color\Text = strF_(Red / 255, 3) + " g"
    Else
      PDF()\Color\Text = strF_(Red / 255, 3) + " " + strF_(Green / 255, 3) + " " + strF_(Blue / 255, 3) + " rg"
    EndIf
    
    If PDF()\Color\Fill <> PDF()\Color\Text : PDF()\Color\Flag = #True : EndIf
    
  EndProcedure
  
  ;- ----- Position -------------------------
  
  Procedure   SetX_(X.f)
    
    If X >= 0
      PDF()\Page\X = X
    Else
      PDF()\Page\X = PDF()\Page\Width + X
    EndIf
    
  EndProcedure  
  
  Procedure   SetY_(Y.f, ResetX.i=#True)
    
    If ResetX : PDF()\Page\X = PDF()\Margin\Left : EndIf
    
    If Y >= 0
      PDF()\Page\Y = Y
    Else
      PDF()\Page\Y = PDF()\Page\Height + Y
    EndIf
    
  EndProcedure  
  
  Procedure   SetXY_(X.f, Y.f)
    
    SetY_(Y) ; must be first !
    SetX_(X) ; second
    
  EndProcedure
  
  ;- ----- Apearance Stream --------------
  
  Procedure.s FontAP_(Family.s, Style.s, Size.i)
    Define.s vFontKey
    
    Family = Trim(Family)
    Select UCase(Family)
      Case "ARIAL"
        Family = "HELVETICA"
      Case "TIMES-ROMAN"
        Family = "TIMES"
      Case "SYMBOL"
        Style = ""
      Case "ZAPFDINGBATS"
        Style = ""  
    EndSelect
    
    If Style = "IB" : Style = "BI" : EndIf
    
    vFontKey = UCase(RSet(Style, 3, "_") + Family) ; BI_+Fontname
    If FindMapElement(PDF()\Fonts(), vFontKey) = #False
      AddFontData_(Family, Style, vFontKey)
    EndIf
    
    If FindMapElement(PDF()\Fonts(), vFontKey)
    
      If PDF()\pageNum > 0
        ProcedureReturn "/F" + Str(PDF()\Fonts()\Number) + " " + strF_(Size, 2) + " Tf" + #LF$
      EndIf
      
    EndIf
    
  EndProcedure    

  ;- ----- Page Stream -------------------------------------------   
  
  Procedure   Line_(X1.f, Y1.f, X2.f, Y2.f)
    objOutPage_(strF_(X1 * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y1) * PDF()\ScaleFactor, 2) + " m " + strF_(x2 * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y2) * PDF()\ScaleFactor, 2) + " l S")
  EndProcedure
  
  Procedure   LineWidth_(Width.f)
    
    PDF()\LineWidth = Width
    
    If PDF()\pageNum > 0 
      objOutPage_(strF_(Width * PDF()\ScaleFactor, 2) + " w")
    EndIf    
    
  EndProcedure  
  
  Procedure.s Underline_(X.f, Y.f, Text.s)
    Protected vWidth.f

    vWidth = GetStringWidth_(Text) + (PDF()\WordSpacing * CountString(Text, " "))
    
    ; Take fontstyle into account Bold = Line is double in height
    If CountString(PDF()\Font\Style, "B")
      ProcedureReturn strF_(X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (Y - #FONTSUP / 1000 * PDF()\Font\Size)) * PDF()\ScaleFactor, 2) + " " + strF_(vWidth * PDF()\ScaleFactor, 2) + " " + strF_((-#FONTSUT / 1000 * PDF()\Font\SizePt) * 2, 2) + " re f"
    Else
      ProcedureReturn strF_(X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (Y - #FONTSUP / 1000 * PDF()\Font\Size)) * PDF()\ScaleFactor, 2) + " " + strF_(vWidth * PDF()\ScaleFactor, 2) + " " + strF_( -#FONTSUT / 1000 * PDF()\Font\SizePt, 2) + " re f"
    EndIf
    
  EndProcedure  
  
  Procedure   Ln_(Height.f)
    
    PDF()\Page\X = PDF()\Margin\Left
    
    If Height = #PB_Default
      PDF()\Page\Y + PDF()\Page\LastHeight
    Else
      PDF()\Page\Y + Height
    EndIf
    
  EndProcedure  
  
  Procedure   Cell_(Width.f, Height.f = 0, Text.s="", Border.i=#False, Ln.i=#Right, Align.s="", Fill.i=#False, Link.i=#NoLink, Label.s="")
    Define.i txtLen, PageX, PageY, TextX
    Define.f WordSpace, StrgWidth, maxWidth, wLink
    Define.s sStrg, eStrg, Stream$
    Define   Stream.Memory_Structure
    
    If Height = #PB_Default : Height = PDF()\Font\Size : EndIf
   
    ;Text   = RTrim(RTrim(Text, #LF$), #CR$)
    txtLen = Len(Text)
    
    ;{ Automatic page Break 
    If PDF()\Page\Y + Height > PDF()\PageBreak\Trigger And PDF()\Footer\PageBreak And PDF()\PageBreak\Auto = #True
     
      PageX = PDF()\Page\X
      
      WordSpace = PDF()\WordSpacing
      If WordSpace > 0 
        PDF()\WordSpacing = 0
        objOutPage_("0 Tw")
      EndIf
      
      AddPage_(PDF()\Page\Orientation) 
      
      PDF()\Page\X = PageX
      
      If WordSpace > 0
        PDF()\WordSpacing = WordSpace
        objOutPage_(strF_(WordSpace * PDF()\ScaleFactor, 3) + " Tw")
      EndIf 
      
    EndIf ;}
    
    If Width = 0 Or Width = #PB_Default
      Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
    EndIf

    If Fill = #True Or Border = #True ;{ Fill / Border
      sStrg + strF_(PDF()\Page\X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - PDF()\Page\Y) * PDF()\ScaleFactor, 2) + " " + strF_(Width * PDF()\ScaleFactor, 2) + " " + strF_(-Height * PDF()\ScaleFactor, 2) + " re "
      If Fill = #True
        If Border = #True
          sStrg + "B "
        Else
          sStrg + "f "
        EndIf
      Else
        sStrg + "S "
      EndIf ;}
    EndIf
    
    ;{ #LeftBorder / #TopBorder / #RightBorder / #BottomBorder
    If Border < 0 

      PageX = PDF()\Page\X
      PageY = PDF()\Page\Y
      
      If -Border & -#LeftBorder
        sStrg + strF_(PageX * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - PageY) * PDF()\ScaleFactor, 2) + " m " + strF_(PageX * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (PageY + Height)) * PDF()\ScaleFactor, 2) + " l S "
      EndIf

      If -Border & -#TopBorder
        sStrg + strF_(PageX * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - PageY) * PDF()\ScaleFactor, 2) + " m " + strF_((PageX + Width) * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - PageY) * PDF()\ScaleFactor, 2) + " l S "
      EndIf
      
      If -Border & -#RightBorder
        sStrg + strF_((PageX + Width) * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - PageY) * PDF()\ScaleFactor, 2) + " m " + strF_((PageX + Width) * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (PageY + Height)) * PDF()\ScaleFactor, 2) + " l S "
      EndIf
      
      If -Border & -#BottomBorder
        sStrg + strF_(PageX * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (PageY + Height)) * PDF()\ScaleFactor, 2) + " m " + strF_((PageX + Width) * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - (PageY + Height)) * PDF()\ScaleFactor, 2) + " l S "
      EndIf
      
    EndIf ;}
    
    If txtLen
      
      StrgWidth = GetStringWidth_(Text)
      
      ;{ Align
      Select Align
        Case #RightAlign
          TextX = Width - PDF()\Margin\Cell - StrgWidth
        Case #CenterAlign
          TextX = (Width - StrgWidth) / 2
        Case #ForcedJustified
          maxWidth = Width - (2 * PDF()\Margin\Cell)   
          PDF()\WordSpacing = (maxWidth - StrgWidth)   
          If CountString(Text, " ") > 0
            PDF()\WordSpacing = PDF()\WordSpacing / CountString(Text, " ")              
          EndIf
          objOutPage_(strF_(PDF()\WordSpacing * PDF()\ScaleFactor, 3) + " Tw")
          TextX = PDF()\Margin\Cell
        Default
          TextX = PDF()\Margin\Cell
      EndSelect ;}
      
      If PDF()\Color\Flag = #True
        sStrg + "q " + PDF()\Color\Text + " "
      EndIf

      sStrg + "BT " + strF_((PDF()\Page\X + TextX) * PDF()\ScaleFactor, 2) + " " + strF_(((PDF()\Page\Height - (PDF()\Page\Y + 0.5 * Height + 0.3 * PDF()\Font\Size)) * PDF()\ScaleFactor), 2) + " Td ("
      eStrg + ") Tj ET"
      
      If PDF()\Font\Underline = #True
        eStrg + " "
        eStrg + Underline_(PDF()\Page\X + TextX, PDF()\Page\Y + 0.5 * Height + 0.3 * PDF()\Font\Size, Text)
      EndIf
      
      If PDF()\Color\Flag = #True : eStrg + " Q" : EndIf  
      
      If Align = #ForcedJustified
        wLink = maxWidth
      Else
        wLink = StrgWidth
      EndIf
      
      CompilerIf #Enable_Annotations
        
        If Link > #NoLink
          
          AddAnnot_(Link, PDF()\Page\X + TextX, PDF()\Page\Y + 0.5 * Height - 0.5 * PDF()\Font\Size, wlink, PDF()\Font\Size)
          
        ElseIf Label
          
          AddLabelLink_(Label, PDF()\Page\X + TextX, PDF()\Page\Y + 0.5 * Height - 0.5 * PDF()\Font\Size, wlink, PDF()\Font\Size)
          
        EndIf
        
      CompilerEndIf
      
    EndIf
    
    If PDF()\Font\Unicode
      objOutPage_(Text, sStrg, eStrg + #LF$, #objUTF16)
    Else
      objOutPage_(EscapeString_(Text), sStrg, eStrg + #LF$)
    EndIf
    
    If Align = #ForcedJustified
      objOutPage_("0 Tw" + #LF$)
      PDF()\WordSpacing = 0
    EndIf
    
    PDF()\Page\LastHeight = Height
    
    If Ln > 0 ; Go To Next line
      PDF()\Page\Y = PDF()\Page\Y + Height
      If Ln = #NextLine : PDF()\Page\X = PDF()\Margin\Left : EndIf  
    Else
      PDF()\Page\X = PDF()\Page\X + Width
    EndIf
    
  EndProcedure
  
  Procedure.s MultiCell_(Width.f, Height.f, Text.s, Border.i=0, Align.s="", Fill.i=#False, Indent.f=0, maxLine.i=0)
    Define.f wFirst, wOther, maxWidth, wMaxFirst, wMaxOther, saveX
    Define.i txtLen, First, bFlag, bFlag2, Seperator, i, j, LastSpaceW, strgWidth, SpaceNum, newLines
    Define.s Char$
    
    PDF()\MultiCellNewLines = 0
    
    ; Output text with automatic Or explicit line breaks
    
    If Width = 0 : Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X : EndIf
    
    wFirst    = Width - Indent
    wOther    = Width
    wMaxFirst = (wFirst - 2 * PDF()\Margin\Cell) * 1000 / PDF()\Font\Size
    wMaxOther = (wOther - 2 * PDF()\Margin\Cell) * 1000 / PDF()\Font\Size

    txtLen  = Len(RTrim(RTrim(Text, #CR$), #LF$))
    
    bFlag = 0
    If Border <> #False ;{ Border
      If Border = #True
        Border = #LeftBorder + #RightBorder + #TopBorder + #BottomBorder
        bFlag  = #LeftBorder + #RightBorder + #TopBorder
        bFlag2 = #LeftBorder + #RightBorder
      Else 
        bFlag2 = #False
        If -Border & -#LeftBorder  : bFlag2 + #LeftBorder  : EndIf 
        If -Border & -#RightBorder : bFlag2 + #RightBorder : EndIf 
        If -Border & -#TopBorder   : bFlag2 + #TopBorder   : EndIf 
        bFlag = bFlag2 
      EndIf ;}
    EndIf
    
    i = 1 
    j = 0
    
    newLines  = 1
    SpaceNum  = 0 
    Seperator = -1
    strgWidth = 0 
    
    Char$      = ""
    First     = #True
    
    While i < txtLen
      
      Char$ = Mid(Text, i, 1) ; Get Next character
      
      If Char$ = #LF$         ;{ Explicit line Break 
        
        If PDF()\WordSpacing > 0
          PDF()\WordSpacing = 0
          objOutPage_("0 Tw")
        EndIf
        
        Cell_(Width, Height, Mid(Text, j, i-j), bFlag, 2, Align, Fill)
        
        j = i
        i + 1
        
        Seperator = -1
        SpaceNum  = 0
        strgWidth = 0
        
        newLines + 1
        
        If newLines = 2 And Border <> 0 : bFlag = bFlag2 : EndIf
        
        Continue
        ;}
      EndIf
      
      If Char$ = " "          ;{ Space
        Seperator  = i
        LastSpaceW = strgWidth
        SpaceNum   + 1
        ;}
      EndIf
      
      strgWidth + GetStringWidth_(Char$, #False)
      
      If First = #True
        maxWidth  = wMaxFirst
        Width = wFirst
      Else
        maxWidth  = wMaxOther
        Width = wOther
      EndIf
      
      If strgWidth > maxWidth ;{ Automatic line Break 
        
        If Seperator = -1 ;{ No seperator
          
          If i = j : i + 1 : EndIf  
          
          If PDF()\WordSpacing > 0 
            PDF()\WordSpacing = 0 
            objOutPage_("0 Tw") 
          EndIf 
          
          saveX = PDF()\Page\X
          
          If First = #True And Indent > 0
            SetX_(PDF()\Page\X + Indent) 
            First = #False 
          EndIf
          
          Cell_(Width, Height, Mid(Text, j, i-j), bFlag, 2, Align, Fill)  
          
          If j = 0 : i + 1 : EndIf ; >> If the first word is too long start on next character 
          ;}
        Else              ;{ Seperator
          
          If Align = "J" ;{ Justify
            
            If SpaceNum > 1 
              PDF()\WordSpacing = (maxWidth - LastSpaceW) / 1000 * PDF()\Font\Size / (SpaceNum - 1) 
            Else 
              PDF()\WordSpacing = 0 
            EndIf
            
            objOutPage_(strF_(PDF()\WordSpacing * PDF()\ScaleFactor, 3) + " Tw") 
            ;}
          EndIf
          
          saveX = PDF()\Page\X
          
          If First = #True And Indent > 0
            SetX_(PDF()\Page\X + Indent) 
            First = #False 
          EndIf
          
          Cell_(Width, Height, Mid(Text, j, Seperator - j), bFlag, 2, Align, Fill)
          
          If First = #False : SetX_(saveX) : EndIf 
          
          i = Seperator + 1 
          ;}
        EndIf

        j = i
        Seperator = -1
        strgWidth = 0
        SpaceNum  = 0
        newLines  + 1
        
        If Border <> 0 And newLines = 2 : bFlag = bFlag2 : EndIf
        
        If maxLine > 0 And newLines > maxLine
          
          PDF()\MultiCellNewLines = newLines - 1
          
          ProcedureReturn Right(Text, Len(Text) - i)
        EndIf
        ;}
      Else
        i + 1 
      EndIf
      
    Wend  
    
    ; Last chunk 
    If PDF()\WordSpacing > 0
      PDF()\WordSpacing = 0 
      objOutPage_("0 Tw"); 
    EndIf
    
    If -Border & -#BottomBorder And Border <> 0
      bFlag + #BottomBorder 
    EndIf
    
    Cell_(Width, Height, Mid(Text, j, i - j + 1), bFlag, 2, Align, Fill)
    
    PDF()\Page\X = PDF()\Margin\Left
    
    PDF()\MultiCellNewLines = newLines
    
    ProcedureReturn ""
  EndProcedure

  Procedure   Write_(Height.f, Text.s, Link.i=#NoLink, Label.s="")
    Define.i i, j, txtLen, Seperator, nl
    Define.f Width, maxWidth, StrgWidth
    Define.s Char$
    
    If Height = #PB_Default : Height = PDF()\Font\Size : EndIf
    
    Width    = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
    maxWidth = (Width - (2 * PDF()\Margin\Cell)) * 1000 / PDF()\Font\Size
    
    txtLen    = Len(Text)
    Seperator = -1
    StrgWidth =  0
    i  = 1
    j  = 1
    nl = 1
    
    While i <= txtLen ; Get Next character
      
      Char$ = Mid(Text, i, 1)
      
      If Char$ = #LF$ ;{ Explicit line Break
        
        Cell_(Width, Height, Mid(Text, j, i-j), 0, 2, "", 0, Link, Label)
        
        StrgWidth = 0
        Seperator = -1
        i = i + 1
        j = i
        
        If nl = 1
          PDF()\Page\X = PDF()\Margin\Left
          Width    = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
          maxWidth = (Width - 2 * PDF()\Margin\Cell) * 1000 / PDF()\Font\Size
        EndIf
        
        nl = nl + 1
        
        Continue ;}
      EndIf
      
      If Char$ = " "
        Seperator = i
      EndIf
      
      StrgWidth + GetStringWidth_(Char$, #False)
      If StrgWidth > maxWidth

        ;{ Automatic line Break
        If Seperator = -1
          
          If PDF()\Page\X > PDF()\Margin\Left  ; Move To Next line
            PDF()\Page\X = PDF()\Margin\Left
            PDF()\Page\Y = PDF()\Page\Y + Height
            Width    = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
            maxWidth = (Width - 2 * PDF()\Margin\Cell) * 1000 / PDF()\Font\Size
            i  + 1
            nl + 1
            Continue
          EndIf
          
          If i = j : i + 1 : EndIf 
          
          Cell_(Width, Height, Mid(Text, j, i-j), 0, 2, "", 0, Link, Label)  
          
        Else
          
          Cell_(Width, Height, Mid(Text, j, Seperator - j), 0, 2, "", 0, Link, Label)  
          i = Seperator + 1
          
        EndIf ;}
        
        StrgWidth =  0
        Seperator = -1
        j = i
        
        If nl = 1
          PDF()\Page\X = PDF()\Margin\Left
          Width    = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
          maxWidth = (Width - 2 * PDF()\Margin\Cell) * 1000 / PDF()\Font\Size
        EndIf
        
        nl + 1
        
      Else
        
        i + 1
        
      EndIf
      
    Wend
    
    
    If i <> j ; Last chunk
      Cell_(StrgWidth / 1000 * PDF()\Font\Size, Height, Mid(Text, j), 0, 0, "", 0, Link, Label)         
    EndIf
    
  EndProcedure  
  
  
  Procedure   AddPage_(Orientation.s="", Format.s="")
    Define.s objStrg, FontFamiliy, FontStyle, DrawColor, FillColor, TextColor
    Define.i ColorFlag, FontSize, Underline
    Define.f LineWidth, ptWidth, ptHeight
    
    If Orientation = "" : Orientation = PDF()\Document\Orientation : EndIf
    PDF()\Page\Orientation = Left(UCase(Orientation), 1)
    
    ;{ Close previous page
    If PDF()\pageNum > 0
      
      ;{ Reset Rotation
      If PDF()\Page\Angle
        PDF()\Page\Angle = 0
        objOutPage_("Q" + #LF$)
  	  EndIf ;}
     
  	  ;{ Footer Procedure
      If PDF()\Footer\Flag And PDF()\Footer\ProcPtr
        
        PDF()\Footer\PageBreak = #False
        
        ;{ Backup Font & Colors & LineWidth
        FontFamiliy = PDF()\Font\Family
        FontStyle   = PDF()\Font\Style
        Underline   = PDF()\Font\Underline
        FontSize    = PDF()\Font\SizePt
        DrawColor   = PDF()\Color\Draw
        FillColor   = PDF()\Color\Fill
        TextColor   = PDF()\Color\Text
        ColorFlag   = PDF()\Color\Flag
        LineWidth   = PDF()\LineWidth
        ;}
        
        ;{ Call Footer Procedure
        If PDF()\Footer\StrucPtr <> #Null
          CallFunctionFast(PDF()\Footer\ProcPtr, PDF()\Footer\StrucPtr)
        Else
          CallFunctionFast(PDF()\Footer\ProcPtr)
        EndIf ;}
        
        ;{ Restore Font & Colors & LineWidth
        PDF()\LineWidth   = LineWidth
        PDF()\Color\Draw  = DrawColor
        PDF()\Color\Fill  = FillColor
        PDF()\Color\Text  = TextColor
        PDF()\Color\Flag  = ColorFlag
        PDF()\Font\Family = FontFamiliy
        PDF()\Font\Style  = FontStyle
        PDF()\Font\SizePt = FontSize
        PDF()\Font\Underline = Underline
        ;}
        
        PDF()\Footer\PageBreak = #True
        
      ElseIf PDF()\Footer\Numbering
        
        PDF()\Footer\PageBreak = #False 
        
        SetY_(-15)
        SetFont_("Arial", "BI", 9)
        Cell_(0, 10, "{p}", 0, 0, #CenterAlign)
        
        PDF()\Footer\PageBreak = #True
        
      EndIf ;}
     
    EndIf ;}
    
    PDF()\pageNum = objNew_(#objPage) ; New Page Object
    
    ; --- Page defaults ---
    PDF()\Page\X = PDF()\Margin\Left
    PDF()\Page\Y = PDF()\Margin\Right
    
    PDF()\Font\Family = ""
    
    If Trim(Format) ;{ Change page format
      ptWidth  = ValF(StringField(Format, 1, ","))
      ptHeight = ValF(StringField(Format, 2, ","))
      If PDF()\Page\Orientation = "L"
        PDF()\Page\ptWidth  = ptHeight
        PDF()\Page\ptHeight = ptWidth
      Else
        PDF()\Page\ptWidth  = ptWidth
        PDF()\Page\ptHeight = ptHeight
      EndIf 
      ;}
    Else            ;{ Document page format
      If PDF()\Page\Orientation = "L"
        PDF()\Page\ptWidth  = PDF()\Document\ptHeight
        PDF()\Page\ptHeight = PDF()\Document\ptWidth
      Else
        PDF()\Page\ptWidth  = PDF()\Document\ptWidth
        PDF()\Page\ptHeight = PDF()\Document\ptHeight
      EndIf 
      ;}
    EndIf
    PDF()\Page\Width  = PDF()\Page\ptWidth  / PDF()\ScaleFactor
    PDF()\Page\Height = PDF()\Page\ptHeight / PDF()\ScaleFactor
    
    objNew_(#objPageContent) ; New Page Content Object
    
    ;{ Write Page Dictionary
    objStrg = #LF$
    objStrg + "/Type /Page" + #LF$
    objStrg + "/Parent " + PDF()\Catalog\objPages + #LF$
    objStrg + "/MediaBox [0 0 " + strF_(PDF()\Page\ptWidth, 2) + " " + strF_(PDF()\Page\ptHeight, 2) + "]" + #LF$
    objStrg + "/Resources " + PDF()\objResources   + #LF$
    objStrg + "/Contents "  + PDF()\objPageContent + #LF$
    ; /Annots can only be added at the end
    objOutDictionary_(objStrg, "", "", #False, PDF()\objPage)
    ;}
    
    ;{ Write Page Content Defaults
    objStrg = "2 J" + #LF$
    objStrg + strF_(PDF()\LineWidth * PDF()\ScaleFactor, 2) + " w" + #LF$
    If PDF()\Color\Draw <> "0 G" :  objStrg + PDF()\Color\Draw + #LF$ : EndIf  
    If PDF()\Color\Fill <> "0 g" :  objStrg + PDF()\Color\Fill + #LF$ : EndIf
    objOutPage_(objStrg)
    If Trim(PDF()\Font\Family) <> ""
      SetFont_(PDF()\Font\Family, FontStyle, FontSize)
    EndIf
    ;}

    ;{ Page header
    If PDF()\Header\Flag And PDF()\Header\ProcPtr
      
      ;{ Backup Font & Colors & LineWidth
      FontStyle = PDF()\Font\Style
      If PDF()\Font\Underline = #True : FontStyle + "U" : EndIf
      FontSize  = PDF()\Font\SizePt
      DrawColor = PDF()\Color\Draw
      FillColor = PDF()\Color\Fill
      TextColor = PDF()\Color\Text
      ColorFlag = PDF()\Color\Flag
      LineWidth = PDF()\LineWidth
      ;}
   
      ;{ Call Header Procedure
      If PDF()\Header\StrucPtr <> #Null
        CallFunctionFast(PDF()\Header\ProcPtr, PDF()\Header\StrucPtr)
      Else
        CallFunctionFast(PDF()\Header\ProcPtr)
      EndIf ;}
    
      ;{ Restore Font & Colors & LineWidth
      If PDF()\LineWidth <> LineWidth
        PDF()\LineWidth = LineWidth
        objOutPage_(strF_(LineWidth * PDF()\ScaleFactor, 2) + " w")
      EndIf
      
      If PDF()\Font\Family <> ""
        SetFont_(PDF()\Font\Family, FontStyle, FontSize)
      EndIf
      
      If PDF()\Color\Draw <> DrawColor
        PDF()\Color\Draw = DrawColor
        objOutPage_(DrawColor)
      EndIf
      
      If PDF()\Color\Fill <> FillColor 
        PDF()\Color\Fill = FillColor
        objOutPage_(FillColor)
      EndIf
      
      PDF()\Color\Text = TextColor
      PDF()\Color\Flag = ColorFlag
      ;}
      
    EndIf ;}
    
    If PDF()\Numbering = #True : PDF()\Page\TOCNum + 1 : EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  ;- ----- Create PDF ---------------------------------------

  Procedure CompleteObjects_()
    Define.i TotalNum, PageNum, ptY
    Define.s objStrg, objPage
    
    ;{ _____ Annotations _____
    If MapSize(PDF()\Labels()) > 0 ;{ Annotation labels
      
      ForEach PDF()\Labels()
        
        If SelectElement(PDF()\Annots(), PDF()\Labels()\Idx)
          
          objPage = PDF()\Labels()\objPage
          If AddElement(PDF()\PageAnnots(objPage)\Annot())
            PDF()\PageAnnots(objPage)\Annot() = PDF()\Labels()\objAnnot
          EndIf 
          
          Select PDF()\Annots()\Type
            Case #Annot_GoTo
              If PDF()\Annots()\Y > 0
                ptY = PDF()\Labels()\ptHeight - (PDF()\Annots()\Y * PDF()\ScaleFactor)
                objOutDictionary_("/Dest [" + PDF()\Annots()\objDest + " /XYZ 0 " + Str(ptY) + " 0]", "", #LF$, #False, PDF()\Labels()\objAnnot)
              Else
                objOutDictionary_("/Dest [" + PDF()\Annots()\objDest + "]", "", #LF$, #False, PDF()\Labels()\objAnnot)
              EndIf
          EndSelect
        
        EndIf
        
      Next
      ;} 
    EndIf 
    
    ForEach PDF()\PageAnnots()
      
      objPage = MapKey(PDF()\PageAnnots())
      If ListSize(PDF()\PageAnnots()\Annot())
        objStrg = "/Annots ["
        ForEach PDF()\PageAnnots()\Annot()
          objStrg + PDF()\PageAnnots()\Annot() + "  "
        Next
        objOutDictionary_(Trim(objStrg), "", "]" + #LF$, #False, objPage)
      EndIf
      
    Next ;}
    
    ;{ _____ AcroForms _____
    If ListSize(PDF()\objAcroForms()) > 0
      objNew_()
      PDF()\Catalog\objAcroForm = strObj_(PDF()\objNum)
      objStrg = #LF$
      objStrg + "/NeedAppearances true" + #LF$
      objStrg + "/Fields ["
      ForEach PDF()\objAcroForms()
        objStrg + PDF()\objAcroForms() + " "
      Next
      objOutDictionary_(Trim(objStrg) + "]" + #LF$)
    EndIf ;}
    
    ;{ _____ BookMarks ___
    ForEach PDF()\objBookmark()
      objStrg = ""
      If PDF()\objBookmark()\Count
        objStrg + "/First " + PDF()\objBookmark()\First + #LF$
        objStrg + "/Last "  + PDF()\objBookmark()\Last + #LF$
      EndIf
      objStrg + "/Count " + Str(PDF()\objBookmark()\Count) + #LF$
      objOutDictionary_(objStrg, "", "", #False, PDF()\objBookmark()\Object)
    Next
    
    ; --- Outlines Object ---
    If PDF()\Outlines\Count
      objStrg + "/First " + PDF()\Outlines\First + #LF$
      objStrg + "/Last "  + PDF()\Outlines\Last  + #LF$ 
      objStrg + "/Count " + Str(PDF()\Outlines\Count) + #LF$       
      objOutDictionary_(objStrg, "", "", #False, PDF()\Catalog\objOutlines)
    EndIf
    ;}
    
    ;{ _____ Replace page numbers _____
    If PDF()\ReplacePageNums 
      TotalNum = ListSize(PDF()\Pages()) - 1
      ForEach PDF()\Pages()
        PageNum = ListIndex(PDF()\Pages())
        If PageNum
          ReplaceInPageStream(PDF()\Pages()\objContent, "{p}", Str(PageNum))
          If PDF()\Page\AliasTotalNum <> ""
            ReplaceInPageStream(PDF()\Pages()\objContent, PDF()\Page\AliasTotalNum, Str(TotalNum))
          EndIf
        EndIf
      Next 
    EndIf
    ;}
    
    ;{ _____ PageTree _____
    objStrg = "/Kids ["
    ForEach PDF()\Pages()
      If ListIndex(PDF()\Pages()) > 0
        objStrg + PDF()\Pages()\objNum + " "
      EndIf 
    Next
    objStrg = RTrim(objStrg) + "]" + #LF$
    objStrg + "/Count " + Str(ListSize(PDF()\Pages())-1) + #LF$
    objOutDictionary_(objStrg, "", "", #False, PDF()\Catalog\objPages)
    ;}
    
    ;{ _____ Embeded Files _____
    If ListSize(PDF()\objFiles()) > 0
      ; --- Names Object ---
      objNew_()
      PDF()\Names\EmbeddedFiles = strObj_(PDF()\objNum)
      objOutDictionary_("/Names [ ", #LF$)
      ForEach PDF()\objFiles()
        objOutDictionary_(PDF()\objFiles()\Name, "(", ") " + PDF()\objFiles()\Object + " ", #objText)
      Next
      objStrg = "]" + #LF$
      ;objStrg + "/Limits [ " + PDF()\Names\LimitEF\First + " " +PDF()\Names\LimitEF\Last + " ]" + #LF$
      objOutDictionary_(objStrg)
      ; --- Catalog Object ---
      objOutDictionary_("/EmbeddedFiles " + PDF()\Names\EmbeddedFiles, "", " ", #False, PDF()\Catalog\objNames)
    EndIf ;}
    
    ;{ _____ Embeded JavaScript _____
    If ListSize(PDF()\objJavaScript()) > 0
      ; --- Names Object ---
      objNew_()
      PDF()\Names\JavaScript = strObj_(PDF()\objNum)
      objOutDictionary_("/Names [ ", #LF$)
      ForEach PDF()\objJavaScript()
        objOutDictionary_(PDF()\objJavaScript()\Name, "(", ") " + PDF()\objJavaScript()\Object + " ", #objText)
      Next
      objStrg = "]" + #LF$
      ;objStrg + "/Limits [ " + PDF()\Names\LimitEF\First + " " +PDF()\Names\LimitEF\Last + " ]" + #LF$
      objOutDictionary_(objStrg)
      ; --- Catalog Object ---
      objOutDictionary_("/JavaScript " + PDF()\Names\JavaScript, "", " ", #False, PDF()\Catalog\objNames)
    EndIf ;}
    
    ;{ _____ Fonts _____
    If ListSize(PDF()\objFonts()) > 0
      objStrg = "/Font <<"
      ForEach PDF()\objFonts()
        objStrg + "/F" + Str(ListIndex(PDF()\objFonts()) + 1) + " " + PDF()\objFonts()\Object + " "
      Next
      objOutDictionary_(Trim(objStrg), "", ">>" + #LF$, #False, PDF()\objResources)
    EndIf ;}
    
    ;{ _____ Images _____
    If MapSize(PDF()\objImages()) > 0
      objStrg = "/XObject <<"
      ForEach PDF()\objImages()
        objStrg + "/I" + Str(PDF()\objImages()\Number) + " " + PDF()\objImages()\Object + " "
      Next
      objOutDictionary_(Trim(objStrg), "", ">>" + #LF$, #False, PDF()\objResources)
    EndIf ;}
    
    ;{ _____ OpenAction _____
    If PDF()\Catalog\OpenAction\Page
      If SelectElement(PDF()\Pages(), PDF()\Catalog\OpenAction\Page)
        Select PDF()\Catalog\OpenAction\Zoom
          Case #PageTop
            objOutDictionary_("/OpenAction [" + PDF()\Pages()\objNum + " /FitH]", "", #LF$, #False, PDF()\Trailer\Root)
          Case #FullPage
            objOutDictionary_("/OpenAction [" + PDF()\Pages()\objNum + " /Fit]",  "", #LF$, #False, PDF()\Trailer\Root)
          Case #PageWidth
            objOutDictionary_("/OpenAction [" + PDF()\Pages()\objNum + " /FitH]", "", #LF$, #False, PDF()\Trailer\Root)
          Default:
            objOutDictionary_("/OpenAction [" + PDF()\Pages()\objNum + " /XYZ 0 0 " + PDF()\Catalog\OpenAction\Zoom + "]", "", #LF$, #False, PDF()\Trailer\Root)
        EndSelect 
      EndIf
    EndIf
    ;}
    
    ;{ _____ Catalog _____
    objStrg = ""
    If PDF()\Catalog\objAcroForm : objStrg + "/AcroForm " + PDF()\Catalog\objAcroForm + #LF$ : EndIf
    If PDF()\Catalog\objOutlines : objStrg + "/Outlines " + PDF()\Catalog\objOutlines + #LF$ : EndIf 
    If PDF()\Catalog\objNames    : objStrg + "/Names "    + PDF()\Catalog\objNames    + #LF$ : EndIf
    If objStrg : objOutDictionary_(objStrg, "", "", #False, PDF()\Trailer\Root) : EndIf
    ;}
    
  EndProcedure
  
  Procedure WritePDF_(FileName.s)
    Define.i i, obj, Size, sLen, eLen, ByteOffset
    Define.s startXRef, objPDF, objStrg, RC4
    Define   *MemPtr, Compress.Memory_Structure, String.Memory_Structure
    
    PDF()\Trailer\Size = MapSize(PDF()\Object()) + 1 ; Number of objects + 1
    
    If CreateFile(#File, FileName, #PB_Ascii)
      
      WriteStringFormat(#File, #PB_Ascii)

      ;{ _____ Header _____
      WriteString(#File, #Header  + #LF$, #PB_Ascii)              ; PDF version number (8 Byte)
      WriteString(#File, #Comment + #LF$, #PB_Ascii)              ; Four characters whose ASCII values are greater than 127 (=> contains binary data)
      ByteOffset = Len(#Header + #Comment) + 2
      ;}
      
      ;{ _____ Objects _____
      ForEach PDF()\Object()
        
        objPDF = MapKey(PDF()\Object())
        
        PDF()\Object()\ByteOffset = ByteOffset
        
        objStrg = ReplaceString(objPDF, "R", "obj") + #LF$  ; e.g. "1 0 obj"
        
        WriteString(#File, objStrg, #PB_Ascii)
        ByteOffset + Len(objStrg)
        
        Select PDF()\Object()\Type
          Case #objPageContent ;{ Write page content object
            
            ;{ --- Prepare the stream ---
            If PDF()\CompressPages
              If CompressMemory_(PDF()\Object()\Stream\Memory, @Compress)
                PDF()\Object()\Stream\Memory = Compress\Memory
                PDF()\Object()\Stream\Size   = Compress\Size
              Else
                PDF()\Error = #ERROR_COMPRESSION_FAILED
              EndIf
            EndIf 
            
            If PDF()\Encryption
              EncryptMem_(intObj_(objPDF), 0, PDF()\Object()\Stream\Memory, PDF()\Object()\Stream\Size)
            EndIf ;} 
            
            ;{ --- Write Dictionary ---
            If PDF()\CompressPages
              objStrg = "<</Filter /FlateDecode /Length " + Str(PDF()\Object()\Stream\Size) + ">>" + #LF$
            Else
              objStrg = "<</Length " + Str(PDF()\Object()\Stream\Size) + ">>" + #LF$
            EndIf
            WriteString(#File, objStrg, #PB_Ascii)
            ByteOffset + Len(objStrg)
            ;}
            
            ;{ --- Write Stream ---
            If PDF()\Object()\Stream\Memory And PDF()\Object()\Stream\Size
              WriteString(#File, "stream" + #LF$, #PB_Ascii)
              ByteOffset + 7
              If PeekA(PDF()\Object()\Stream\Memory + PDF()\Object()\Stream\Size - 1) = #LF : PDF()\Object()\Stream\Size - 1 : EndIf
              WriteData(#File, PDF()\Object()\Stream\Memory, PDF()\Object()\Stream\Size)
              FreeMemory(PDF()\Object()\Stream\Memory)
              ByteOffset + PDF()\Object()\Stream\Size
              WriteString(#File, #LF$ + "endstream" + #LF$, #PB_Ascii)
              ByteOffset + 11
            EndIf ;}
            
            ;}
          Default              ;{ Write other objects
            
            ;{ --- Write String ---
            If PDF()\Object()\String
              
              WriteString(#File, PDF()\Object()\String, #PB_Ascii)
              ByteOffset + Len(PDF()\Object()\String)
              
            EndIf ;}
            
            ;{ --- Write Dictionary ---
            If ListSize(PDF()\Object()\Dictionary()) > 0
              
              WriteString(#File, "<<", #PB_Ascii)
              ByteOffset + 2
              
              ForEach PDF()\Object()\Dictionary()
                
                If PDF()\Object()\Dictionary()\Flags & #objText        ;{ Entry with text
                  
                  If PDF()\Encryption
                    If CountString(PDF()\Object()\Dictionary()\String, "|") = 1
                      RC4 = Encrypt_(intObj_(objPDF), 0, PDF()\Object()\Dictionary()\String, #True)
                    Else
                      RC4 = Encrypt_(intObj_(objPDF), 0, PDF()\Object()\Dictionary()\String)
                    EndIf
                    HexStrg2Memory(RC4, PDF()\Object()\Dictionary()\sStrg, PDF()\Object()\Dictionary()\eStrg, @String)
                    If String\Memory
                      WriteData(#File, String\Memory, String\Size)
                      FreeMemory(String\Memory)
                      ByteOffset + String\Size
                    EndIf
                  Else
                    objStrg = PDF()\Object()\Dictionary()\sStrg
                    objStrg + EscapeString_(PDF()\Object()\Dictionary()\String)
                    objStrg + PDF()\Object()\Dictionary()\eStrg
                    WriteString(#File, objStrg, #PB_Ascii)
                    ByteOffset + Len(objStrg)
                  EndIf
                  ;}
                ElseIf PDF()\Object()\Dictionary()\Flags & #objHexStrg ;{ Entry with hexadecimal string
                  
                  HexStrg2Memory(PDF()\Object()\Dictionary()\String, PDF()\Object()\Dictionary()\sStrg, PDF()\Object()\Dictionary()\eStrg, @String)
                  If String\Memory
                    WriteData(#File, String\Memory, String\Size)
                    FreeMemory(String\Memory)
                    ByteOffset + String\Size
                  EndIf
                  ;}
                Else                                                   ;{ Other entries
                  
                  objStrg = PDF()\Object()\Dictionary()\sStrg
                  objStrg + PDF()\Object()\Dictionary()\String
                  objStrg + PDF()\Object()\Dictionary()\eStrg
                  WriteString(#File, objStrg, #PB_Ascii)
                  ByteOffset + Len(objStrg)
                  ;}
                EndIf
                
              Next
              
              WriteString(#File, ">>" + #LF$, #PB_Ascii)
              ByteOffset + 3
              
            EndIf ;}
            
            ;{ --- Write Stream ---
            If PDF()\Object()\Stream\Memory And  PDF()\Object()\Stream\Size
              WriteString(#File, "stream" + #LF$, #PB_Ascii)
              ByteOffset + 7
              WriteData(#File, PDF()\Object()\Stream\Memory, PDF()\Object()\Stream\Size)
              FreeMemory(PDF()\Object()\Stream\Memory)
              ByteOffset + PDF()\Object()\Stream\Size
              WriteString(#File, #LF$ + "endstream" + #LF$, #PB_Ascii)
              ByteOffset + 11
            EndIf ;}
            
            ;}
        EndSelect
        
        WriteString(#File, "endobj" + #LF$, #PB_Ascii)
        ByteOffset + 7
        
      Next ;}
      
      ;{ _____ Cross-Reference Table _____
      StartXRef = Str(ByteOffset)
      WriteString(#File, "xref" + #LF$, #PB_Ascii)
      WriteString(#File, "0 " + Str(PDF()\Trailer\Size) + #LF$, #PB_Ascii)                                      ; Number of lines in cross-reference table
      WriteString(#File, "0000000000 65535 f" + #LF$, #PB_Ascii)                                                ; Object 0
      For obj=1 To MapSize(PDF()\Object())
        objPDF = strObj_(obj)
        WriteString(#File, RSet(Str(PDF()\Object(objPDF)\ByteOffset), 10, "0") + " 00000 n " + #LF$, #PB_Ascii) ; Byte offset of all objects
      Next
      ;}
      
      ;{ _____ Trailer _____
      WriteString(#File, "trailer" + #LF$, #PB_Ascii)
      WriteString(#File, "<<" + #LF$, #PB_Ascii)
      WriteString(#File, "/Size " + Str(PDF()\Trailer\Size) + #LF$, #PB_Ascii)                                     ; Number of objects + 1
      WriteString(#File, "/Root " + PDF()\Trailer\Root + #LF$, #PB_Ascii)                                          ; Object with document catalog
      WriteString(#File, "/Info " + PDF()\Trailer\Info + #LF$, #PB_Ascii)                                          ; Object with document-level metadata
      If PDF()\Trailer\Encrypt : WriteString(#File, "/Encrypt " + PDF()\Trailer\Encrypt + #LF$, #PB_Ascii) : EndIf ; Object with encryption data
      WriteString(#File, "/ID [<" + PDF()\Trailer\ID + "> <" + PDF()\Trailer\ID + ">]" + #LF$, #PB_Ascii)          ; Unique ID of document
      WriteString(#File, ">>" + #LF$, #PB_Ascii)
      WriteString(#File, "startxref" + #LF$, #PB_Ascii)
      WriteString(#File, startXRef   + #LF$, #PB_Ascii)                                                            ; Byte offset of the start of cross-reference table
      WriteString(#File, "%%EOF" + #LF$, #PB_Ascii)                                                                ; End of PDF file
      ;}
      
      CloseFile(#File)
    Else
      PDF()\Error = #ERROR_FILE_CREATE
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================

  Procedure.i GetErrorCode(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\Error
    EndIf
    
  EndProcedure  
  
  Procedure.s GetErrorMessage(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select PDF()\Error
        Case #ERROR_ALPHA_CHANNEL_PNG_NOT_SUPPORTED
          ProcedureReturn "Alpha channel PNG not supported."
        Case #ERROR_PROBLEM_READING_IMAGE_FILE_IN_MEMORY
          ProcedureReturn "Problem reading image file in memory."
        Case #ERROR_NOT_A_JPEG_FILE
          ProcedureReturn "Not a JPEG file."
        Case #ERROR_INCORRECT_PNG_FILE
          ProcedureReturn "Incorrect PNG file."
        Case #ERROR_NOT_A_JPEG_OR_PNG_FILE
          ProcedureReturn "Not a JPEG or PNG file."
          ; ----------------------------------------
        Case #ERROR_FILE_CREATE
          ProcedureReturn "The file could not be created."
        Case #ERROR_FILE_READ
          ProcedureReturn "The file could not be read."
        Case #ERROR_TTF_UNEMBEDDABLE
          ProcedureReturn "Font may not be embedded in PDF according to license."
        Case #ERROR_TTF_ONLYBITMAP
          ProcedureReturn "Font may only be embedded as bitmap font."
        Case #ERROR_TTF_NOSUBSETTING
          ProcedureReturn "Font may not be embedded as subsetting."
        Case #ERROR_COMPRESSION_FAILED
          ProcedureReturn "File compression failed"
        Default
          ProcedureReturn ""
      EndSelect
      
    EndIf  

  EndProcedure 
  
  Procedure.f GetFontSize(ID.i, Type.i=#Point)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select Type
        Case #Point
          ProcedureReturn PDF()\Font\SizePt
        Case #Unit
          ProcedureReturn PDF()\Font\Size
      EndSelect

    EndIf
    
  EndProcedure 
  
  Procedure.f GetMargin(ID.i, Type.i)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select Type
        Case #LeftMargin
          ProcedureReturn PDF()\Margin\Left
        Case #TopMargin
          ProcedureReturn PDF()\Margin\Top
        Case #RightMargin
          ProcedureReturn PDF()\Margin\Right
        Case #CellMargin
          ProcedureReturn PDF()\Margin\Cell
      EndSelect      
      
    EndIf
    
  EndProcedure  
  
  Procedure.i GetMultiCellLines(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\MultiCellNewLines
    EndIf
    
  EndProcedure    
  
  Procedure.i GetNumbering(ID.i, TOC.i=#False)
    
    If FindMapElement(PDF(), Str(ID))
      
      If TOC
        ProcedureReturn PDF()\Numbering
      Else
        ProcedureReturn PDF()\Footer\Numbering
      EndIf
      
    EndIf    
    
  EndProcedure  
  
  Procedure.i GetObjectNum(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\objNum
    EndIf
    
  EndProcedure

  Procedure.f GetPageHeight(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\Page\Height
    EndIf  

  EndProcedure   
  
  Procedure.i GetPageNumber(ID.i, TOC.i=#False) 
    
    If FindMapElement(PDF(), Str(ID))
      
      If TOC
        ProcedureReturn PDF()\Page\TOCNum
      Else
        ProcedureReturn PDF()\pageNum
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure.f GetPageWidth(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\Page\Width
    EndIf  

  EndProcedure  
  
  Procedure.f GetPosX(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\Page\X
    EndIf  
    
  EndProcedure
  
  Procedure.f GetPosY(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\Page\Y
    EndIf
    
  EndProcedure
    
  Procedure.f GetScaleFactor(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\ScaleFactor
    EndIf
    
  EndProcedure  
  
  Procedure.f GetStringWidth(ID.i, String.s)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn GetStringWidth_(String)
    EndIf    
    
  EndProcedure
  
  Procedure.f GetWordSpacing(ID.i)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn PDF()\WordSpacing
    EndIf
    
  EndProcedure
  
  ;- ----------------------------------------
  
  Procedure SetAliasTotalPages(ID.i, Alias.s="{tp}")                                     
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\Page\AliasTotalNum = Alias
      PDF()\ReplacePageNums = #True
    EndIf
    
  EndProcedure
  
  Procedure SetAutoPageBreak(ID.i, Flag.i, Margin.f=0)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\PageBreak\Auto    = Flag
      PDF()\PageBreak\Margin  = Margin
      PDF()\PageBreak\Trigger = PDF()\Page\Height - Margin
    EndIf
    
  EndProcedure

  Procedure SetColorRGB(ID.i, ColorTyp.i, Red.f, Green.f=#PB_Default, Blue.f=#PB_Default)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select ColorTyp
        Case #TextColor
          SetFrontColor_(Red, Green, Blue)
        Case #DrawColor
          SetDrawColor_(Red, Green, Blue)
        Case #FillColor
          If (Green = 0 And Blue = 0) Or Green = #PB_Default
            PDF()\Color\Fill = strF_(Red / 255, 3) + " g"
          Else
            PDF()\Color\Fill = strF_(Red / 255, 3) + " " + strF_(Green / 255, 3) + " " + strF_(Blue / 255, 3) + " rg"
          EndIf
          If PDF()\Color\Fill <> PDF()\Color\Text : PDF()\Color\Flag = #True : EndIf
          If PDF()\pageNum > 0 
            objOutPage_(PDF()\Color\Fill)
          EndIf
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure SetColorCMYK(ID.i, ColorTyp.i, Cyan.f, Magenta.f, Yellow.f, Black.f)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select ColorTyp
        Case #TextColor
          PDF()\Color\Text = strF_(Cyan, 2) + " " + strF_(Magenta, 2) + " " + strF_(Yellow, 2) + " " + strF_(Black, 2) + " " + " k"
          If PDF()\Color\Fill <> PDF()\Color\Text : PDF()\Color\Flag = #True : EndIf
        Case #DrawColor
          PDF()\Color\Draw = strF_(Cyan, 2) + " " + strF_(Magenta, 2) + " " + strF_(Yellow, 2) + " " + strF_(Black, 2) + " " + " K"
          If PDF()\pageNum > 0 : objOutPage_(PDF()\Color\Draw) : EndIf
        Case #FillColor
          PDF()\Color\Fill = strF_(Cyan, 2) + " " + strF_(Magenta, 2) + " " + strF_(Yellow, 2) + " " + strF_(Black, 2) + " " + " k"
          If PDF()\Color\Fill <> PDF()\Color\Text  : PDF()\Color\Flag = #True : EndIf
          If PDF()\pageNum > 0 : objOutPage_(PDF()\Color\Fill) : EndIf
      EndSelect
      
    EndIf
    
  EndProcedure

  Procedure SetDashedLine(ID.i, DashLength.i, DashSpacing.i)                                              
    
    If FindMapElement(PDF(), Str(ID))
      
      If DashLength And DashSpacing
        objOutPage_("[" + strF_(DashLength * PDF()\ScaleFactor, 3) + " " + strF_(DashSpacing * PDF()\ScaleFactor, 3) + "] 0 d")
      Else
        objOutPage_("[] 0 d")
      EndIf
      
    EndIf
    
  EndProcedure
  
  Procedure SetEncryption(ID.i, User.s, Owner.s="", Permission.q=#False)
    Define PEntry.l, objStrg.s
    
    If FindMapElement(PDF(), Str(ID))
      
      PDF()\Encryption = #True
      
      If Owner = "" : Owner = User : EndIf
      Permission = Permission | #Permission

      GeneratePasswords_(User, Owner, Permission)
      
      objNew_()
      PDF()\Trailer\Encrypt = strObj_(PDF()\objNum)
      PEntry = Permission
      objStrg = "/V 2 /R 3 /Filter /Standard /Length 128" + #LF$
      objStrg + "/P " + Str(PEntry) + #LF$
      objOutDictionary_(objStrg, #LF$)
      objOutDictionary_(EscapeHexStrg_(PDF()\Encrypt\oEntryHex), "/O (", ")" + #LF$, #HexStrg)
      objOutDictionary_(EscapeHexStrg_(PDF()\Encrypt\uEntryHex), "/U (", ")" + #LF$, #HexStrg)

    EndIf
    
  EndProcedure  
  
  Procedure SetFont(ID.i, Family.s="", Style.s="", Size.i=#PB_Default)
    
    If FindMapElement(PDF(), Str(ID))
      If Size = #PB_Default : Size = 0 : EndIf
      SetFont_(Family, Style, Size)
    EndIf
    
  EndProcedure
  
  Procedure SetFontSize(ID.i, Size.i)                                             
    
    If FindMapElement(PDF(), Str(ID))
      SetFontSize_(Size)
    EndIf
    
  EndProcedure   
  
  Procedure SetFooterProcedure(ID.i, *ProcAddress, *StructAddress=#Null)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\Footer\ProcPtr  = *ProcAddress
      PDF()\Footer\StrucPtr = *StructAddress 
    EndIf
    
  EndProcedure   
  
  Procedure SetHeaderProcedure(ID.i, *ProcAddress, *StructAddress=#Null)
    
    If FindMapElement(PDF(), Str(ID))
      
      PDF()\Header\ProcPtr  = *ProcAddress
      PDF()\Header\StrucPtr = *StructAddress
      
    EndIf
  
  EndProcedure    
  
  Procedure SetInfo(ID.i, Type.i, Value.s)
    ; PDF Reference Version 1.6 - Chapter 10.2.1 (Table 10.2)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select Type
        Case #Author
          objOutDictionary_(EscapeString(Value), "/Author (",   ")" + #LF$, #objText, PDF()\Trailer\Info)
        Case #Titel
          objOutDictionary_(EscapeString(Value), "/Title (",    ")" + #LF$, #objText, PDF()\Trailer\Info)
        Case #Subject
          objOutDictionary_(EscapeString(Value), "/Subject (",  ")" + #LF$, #objText, PDF()\Trailer\Info)
        Case #Keywords
          objOutDictionary_(EscapeString(Value), "/Keywords (", ")" + #LF$, #objText, PDF()\Trailer\Info)
        Case #Creator 
          objOutDictionary_(EscapeString(Value), "/Creator (",  ")" + #LF$, #objText, PDF()\Trailer\Info)
      EndSelect   
      
    EndIf
    
  EndProcedure  
  
  Procedure SetLineCap(ID.i, Style.s)
    
    If FindMapElement(PDF(), Str(ID))
      objOutPage_(Style + " J")
    EndIf
    
  EndProcedure
  
  Procedure SetLineCorner(ID.i, Style.s) 
    
    If FindMapElement(PDF(), Str(ID))
      objOutPage_(Style + " j")
    EndIf
    
  EndProcedure
  
  Procedure SetLineThickness(ID.i, Width.f)
    
    If FindMapElement(PDF(), Str(ID))
      LineWidth_(Width) 
    EndIf
    
  EndProcedure 
  
  Procedure SetLocales(ID.i, Type.i, Value.s)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select Type
        Case #Language
          PDF()\Local\Language          = Value
        Case #DecimalPoint
          PDF()\Local\DecimalPoint      = Value
        Case #TimeZoneOffset
          PDF()\Local\TimeZoneOffset    = Val(Value)
      EndSelect

    EndIf
    
  EndProcedure
  
  Procedure SetMargin(ID.i, Type.i, Value.i)
    
    If FindMapElement(PDF(), Str(ID))
      
      Select Type
        Case #LeftMargin
          PDF()\Margin\Left  = Value
          If PDF()\pageNum > 0 And PDF()\Page\X < PDF()\Margin\Left
            PDF()\Page\X = PDF()\Margin\Left
          EndIf
        Case #TopMargin
          PDF()\Margin\Top   = Value
        Case #RightMargin
          PDF()\Margin\Right = Value
        Case #CellMargin
          PDF()\Margin\Cell  = Value
      EndSelect
      
    EndIf
    
  EndProcedure
  
  Procedure SetOpenAction(ID.i, Zoom.s="", Page.i=1)
    
    If FindMapElement(PDF(), Str(ID))
      
      If Zoom = "" : Zoom = #PageWidth : EndIf
      
      PDF()\Catalog\OpenAction\Page = Page
      PDF()\Catalog\OpenAction\Zoom = RTrim(Zoom, "%")
      
    EndIf
    
  EndProcedure  
  
  Procedure SetPageCompression(ID.i, Flag.i=#True)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\CompressPages = Flag
    EndIf
    
  EndProcedure
  
  Procedure SetPageLayout(ID.i, Mode.s=#SinglePage)
    ; PDF Reference Version 1.6 - Chapter 3.6.1 (Table 3.2.5)
    
    If FindMapElement(PDF(), Str(ID))
      objOutDictionary_("/PageLayout " + Mode, "", "", #False, PDF()\Trailer\Root)
    EndIf
    
  EndProcedure  
  
  Procedure SetPageMargins(ID.i, LeftMargin.f, TopMargin.f, RightMargin.f=#PB_Default)
    
    If FindMapElement(PDF(), Str(ID))
      
      PDF()\Margin\Left = LeftMargin
      PDF()\Margin\Top  = TopMargin
      If RightMargin = #PB_Default
        PDF()\Margin\Right = LeftMargin
      Else
        PDF()\Margin\Right = RightMargin
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure SetPageMode(ID.i, Mode.s=#None)
    ; PDF Reference Version 1.6 - Chapter 3.6.1 (Table 3.2.5)
    
    If FindMapElement(PDF(), Str(ID))
      objOutDictionary_("/PageMode " + Mode, "", "", #False, PDF()\Trailer\Root)
    EndIf
    
  EndProcedure
  
  Procedure SetPageNumbering(ID.i, Flag.i)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\Footer\Numbering = Flag
      If Flag = #True : PDF()\ReplacePageNums = #True : EndIf
    EndIf
   
  EndProcedure   
  
  Procedure SetPosXY(ID.i, X.f, Y.f)
    
    If FindMapElement(PDF(), Str(ID))
      SetXY_(X, Y)
    EndIf
    
  EndProcedure  
  
  Procedure SetPosX(ID.i, X.f)
    
    If FindMapElement(PDF(), Str(ID))
      SetX_(X)
    EndIf
    
  EndProcedure  
  
  Procedure SetPosY(ID.i, Y.f, ResetX.i=#True)
    
    If FindMapElement(PDF(), Str(ID))
      SetY_(Y, ResetX)
    EndIf
    
  EndProcedure 
  
  Procedure SetViewerPreferences(ID.i, Flags.i)
    ; PDF Reference Version 1.6 - Chapter 8.1 (Table 8.1)
    Define.s objStrg
    
    If FindMapElement(PDF(), Str(ID))
      
      objStrg = "/ViewerPreferences <<"
      If Flags & #HideToolbar  : objStrg + "/HideToolbar true "     : EndIf
      If Flags & #HideMenubar  : objStrg + "/HideMenubar true "     : EndIf
      If Flags & #HideWinUI    : objStrg + "/HideWindowUI true "    : EndIf
      If Flags & #FitWindow    : objStrg + "/FitWindow true "       : EndIf
      If Flags & #CenterWindow : objStrg + "/CenterWindow true "    : EndIf
      If Flags & #DisplayTitle : objStrg + "/DisplayDocTitle true " : EndIf
      objStrg = Trim(objStrg) + ">>" + #LF$
      objOutDictionary_(objStrg, "", "", #False, PDF()\Trailer\Root)
      
    EndIf
    
  EndProcedure
  
  Procedure SetWordSpacing(ID.i, WordSpacing.f)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\WordSpacing = WordSpacing
    EndIf
    
  EndProcedure 
  
  ;- ----- AcroForms ---------------------
  
  CompilerIf #Enable_AcroFormCommands
    
    Procedure   ButtonField(ID.i, Titel.s, State.i=#False, Flags.i=#False, Width.f=#PB_Default, Height.f=#PB_Default, Ln.i=#Right)
      ; PDF Reference Version 1.6 - Chapter 8.6.3
      Define.i pageX
      Define.f ptX, ptY, ptWidth, ptHeight
      Define.s objStrg, Stream, objOn, State$
      
      ; Flags: #Form_PushButton / #Form_RadioButton
      
      If FindMapElement(PDF(), Str(ID))
        
        If Height = #PB_Default : Height = PDF()\Font\Size : EndIf
        
        If Width = #PB_Default
          Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
        EndIf
        
        If State : State$ = "/Yes" : Else : State$ = "/Off" : EndIf
        
        ;{ ___ Automatic page Break ___ 
        If PDF()\Page\Y + Height > PDF()\PageBreak\Trigger And PDF()\Footer\PageBreak And PDF()\PageBreak\Auto = #True
          pageX = PDF()\Page\X
          AddPage_(PDF()\Page\Orientation) 
          PDF()\Page\X = pageX
        EndIf ;}
        
        ;{ ___ Scaling ___
        If PDF()\Pages()\Orientation = "P" 
          ptX = PDF()\Page\X * PDF()\ScaleFactor
          ptY = PDF()\Document\ptHeight - (PDF()\Page\Y * PDF()\ScaleFactor)
        Else
          ptX = PDF()\Page\X * PDF()\ScaleFactor
          ptY = PDF()\Document\ptWidth  - (PDF()\Page\Y * PDF()\ScaleFactor)
        EndIf
        ptWidth   = Width  * PDF()\ScaleFactor
        ptHeight  = Height * PDF()\ScaleFactor
        ;}
        
        objNew_(#objAcroForm)
        objStrg = "/Type /Annot /Subtype /Widget" + #LF$
        objStrg + "/Rect [" + strF_(ptX, 2) + " " + strF_(ptY, 2) + " " + strF_(ptX + ptWidth, 2) + " " + strF_(ptY - ptHeight, 2) + "]" + #LF$
        objStrg + "/F 4" + #LF$
        objStrg + "/P " + PDF()\objPage + #LF$
        objStrg + "/FT /Btn" + #LF$
        If Flags : objStrg + " /Ff " + Str(Flags) + #LF$ : EndIf
        objStrg + "/MK << /BC [0.24 0.24 0.24] >>" + #LF$
        objStrg + "/V "  + State$ + #LF$
        objStrg + "/AS " + State$ + #LF$
        objOutDictionary_(objStrg, #LF$)
        objOutDictionary_(EscapeString_(Titel), "/T (", ")" + #LF$, #objText)
        
        If AddElement(PDF()\PageAnnots(PDF()\objPage)\Annot())
          PDF()\PageAnnots(PDF()\objPage)\Annot() = strObj_(PDF()\objNum)
        EndIf
     
        PDF()\Page\LastHeight = Height
        
        If Ln > 0 ; Go To Next line
          PDF()\Page\Y = PDF()\Page\Y + Height
          If Ln = #NextLine : PDF()\Page\X = PDF()\Margin\Left : EndIf  
        Else
          PDF()\Page\X = PDF()\Page\X + Width
        EndIf

      EndIf 
      
    EndProcedure
    
    Procedure   ChoiceField(ID.i, Titel.s, Value.s, Options.s, Index.i=#PB_Default, Flags.i=#False, Width.f=#PB_Default, Height.f=#PB_Default, Ln.i=#NextLine)
      ; PDF Reference Version 1.6 - Chapter 8.6.3
      Define.i i, PageX
      Define.f ptX, ptY, ptWidth, ptHeight
      Define.s objStrg
      
      ; Flags: 
      
      If FindMapElement(PDF(), Str(ID))
        
        If Height = #PB_Default : Height = PDF()\Font\Size : EndIf
        
        If Width = #PB_Default
          Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
        EndIf
        
        Value  = RTrim(RTrim(Value, #LF$), #CR$)
        
        ;{ Automatic page Break 
        If PDF()\Page\Y + Height > PDF()\PageBreak\Trigger And PDF()\Footer\PageBreak And PDF()\PageBreak\Auto = #True
          PageX = PDF()\Page\X
          AddPage_(PDF()\Page\Orientation) 
          PDF()\Page\X = PageX
        EndIf ;}
        
        ;{ Scaling
        If PDF()\Pages()\Orientation = "P" 
          ptX = PDF()\Page\X * PDF()\ScaleFactor
          ptY = PDF()\Document\ptHeight - (PDF()\Page\Y * PDF()\ScaleFactor)
        Else
          ptX = PDF()\Page\X * PDF()\ScaleFactor
          ptY = PDF()\Document\ptWidth  - (PDF()\Page\Y * PDF()\ScaleFactor)
        EndIf
        ptWidth   = Width  * PDF()\ScaleFactor
        ptHeight  = Height * PDF()\ScaleFactor
        ;}
        
        objNew_(#objAcroForm)
        objStrg = "/Type /Annot /Subtype /Widget" + #LF$
        objStrg + "/Rect [" + strF_(ptX, 2) + " " + strF_(ptY, 2) + " " + strF_(ptX + ptWidth, 2) + " " + strF_(ptY - ptHeight, 2) + "]" + #LF$
        objStrg + "/F 4" + #LF$
        objStrg + "/P "  + PDF()\objPage + #LF$
        objStrg + "/FT /Ch" + #LF$
        If Flags : objStrg + " /Ff " + Str(Flags) + #LF$ : EndIf
        objStrg + "/MK << /BC [0.24 0.24 0.24] >>" + #LF$
        objStrg + "/V ()" + #LF$
        objOutDictionary_(objStrg, #LF$)
        objOutDictionary_(EscapeString_(Titel), "/T (", ")" + #LF$, #objText)
        objOutDictionary_(EscapeString_(Value), "/DV (", ")" + #LF$, #objText)
        objStrg = "/F" + Str(PDF()\Font\Number) + " " + Str(PDF()\Font\SizePt) + " Tf"
        If PDF()\Color\Text : objStrg + " " + PDF()\Color\Text : EndIf
        objOutDictionary_(objStrg, "/DA (", ")" + #LF$, #objText)
        If Options
          If Index <> #PB_Default
            objOutDictionary_("/I [" + Str(Index) + "]" + #LF$)
          EndIf
          objOutDictionary_("/Opt [ ")
          For i=1 To CountString(Options, " ") + 1
            objOutDictionary_(StringField(Options, i, " "), "(", ") ", #objText)
          Next
          objOutDictionary_("]" + #LF$)
        EndIf        
        
        If AddElement(PDF()\PageAnnots(PDF()\objPage)\Annot())
          PDF()\PageAnnots(PDF()\objPage)\Annot() = strObj_(PDF()\objNum)
        EndIf
        
        PDF()\Page\LastHeight = Height
        
        If Ln > 0 ; Go To Next line
          PDF()\Page\Y = PDF()\Page\Y + Height
          If Ln = #NextLine : PDF()\Page\X = PDF()\Margin\Left : EndIf  
        Else
          PDF()\Page\X = PDF()\Page\X + Width
        EndIf
       
      EndIf 
      
    EndProcedure

    Procedure   TextField(ID.i, Titel.s, Text.s, Flags.i=#False, Width.f=#PB_Default, Height.f=#PB_Default, Border.i=#False, Ln.i=#Right, Align.s="", Fill.i=#False)
      ; PDF Reference Version 1.6 - Chapter 8.6.3
      Define.i pageX
      Define.f ptX, ptY, ptWidth, ptHeight
      Define.s objStrg, objStream, objAP
      
      If FindMapElement(PDF(), Str(ID))
        
        If Height = #PB_Default : Height = PDF()\Font\Size : EndIf
        
        If Width = #PB_Default
          Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
        EndIf
        
        Text   = RTrim(RTrim(Text, #LF$), #CR$)
        
        ;{ Automatic page Break 
        If PDF()\Page\Y + Height > PDF()\PageBreak\Trigger And PDF()\Footer\PageBreak And PDF()\PageBreak\Auto = #True
          pageX = PDF()\Page\X
          AddPage_(PDF()\Page\Orientation) 
          PDF()\Page\X = pageX
        EndIf ;}
        
        ;{ Scaling
        If PDF()\Pages()\Orientation = "P" 
          ptX = PDF()\Page\X * PDF()\ScaleFactor
          ptY = PDF()\Page\ptHeight - (PDF()\Page\Y * PDF()\ScaleFactor)
        Else
          ptX = PDF()\Page\X * PDF()\ScaleFactor
          ptY = PDF()\Page\ptWidth  - (PDF()\Page\Y * PDF()\ScaleFactor)
        EndIf
        ptWidth   = Width  * PDF()\ScaleFactor
        ptHeight  = Height * PDF()\ScaleFactor
        ;}
        
        objNew_(#objAcroForm)
        objStrg = "/Type /Annot /Subtype /Widget" + #LF$
        objStrg + "/Rect [" + strF_(ptX, 2) + " " + strF_(ptY, 2) + " " + strF_(ptX + ptWidth, 2) + " " + strF_(ptY - ptHeight, 2) + "]" + #LF$
        objStrg + "/F 4" + #LF$
        objStrg + "/P "  + PDF()\objPage + #LF$
        objStrg + "/FT /Tx" + #LF$
        If Flags : objStrg + "/Ff " + Str(Flags) + #LF$ : EndIf
        Select Align
          Case #RightAlign
            objStrg + "/Q 2" + #LF$
          Case #CenterAlign
            objStrg + "/Q 1" + #LF$
          Default
            objStrg + "/Q 0" + #LF$
        EndSelect
        objStrg + "/MK << " 
        If Border : objStrg + "/BC [0.24 0.24 0.24] " : EndIf 
        If Fill   : objStrg + "/BG [0.99 0.99 0.99] " : EndIf
        objStrg + ">>" + #LF$
        objStrg + "/V ()" + #LF$
        objOutDictionary_(objStrg, #LF$)
        objOutDictionary_(EscapeString_(Titel), "/T (", ")" + #LF$, #objText)
        objOutDictionary_(EscapeString_(Text), "/TU (", ")" + #LF$, #objText)
        objStrg = "/F" + Str(PDF()\Font\Number) + " " + Str(PDF()\Font\SizePt) + " Tf"
        If PDF()\Color\Text : objStrg + " " + PDF()\Color\Text : EndIf
        objOutDictionary_(objStrg, "/DA (", ")" + #LF$, #objText)

        If AddElement(PDF()\PageAnnots(PDF()\objPage)\Annot())
          PDF()\PageAnnots(PDF()\objPage)\Annot() = strObj_(PDF()\objNum)
        EndIf
        
        PDF()\Page\LastHeight = Height
        
        If Ln > 0 ; Go To Next line
          PDF()\Page\Y = PDF()\Page\Y + Height
          If Ln = #NextLine : PDF()\Page\X = PDF()\Margin\Left : EndIf  
        Else
          PDF()\Page\X = PDF()\Page\X + Width
        EndIf
      
      EndIf 
      
    EndProcedure
    
  CompilerEndIf
  
  ;- ----- Annotations / Actions ----------
  
  CompilerIf #Enable_Annotations
    
    Procedure.i AddFileLink(ID.i, EmbedID.i, Title.s="", Description.s="", Icon.s=#PushPinIcon, IconW.f=6, IconH.f=8, X.f=#PB_Default)      
      ; Icon: #GraphIcon / #PaperClipIcon / #PushPinIcon / #TagIcon
      
      If EmbedID < 0 : ProcedureReturn #False : EndIf 
      
      If FindMapElement(PDF(), Str(ID))
        
        If AddElement(PDF()\Annots())
          PDF()\Annots()\Type    = #Annot_File
          PDF()\Annots()\FileID  = EmbedID
          PDF()\Annots()\Titel   = Title
          PDF()\Annots()\Content = Description
          PDF()\Annots()\Icon    = Icon
          PDF()\Annots()\X       = X
          PDF()\Annots()\Y       = #PB_Default
          PDF()\Annots()\Width   = IconW
          PDF()\Annots()\Height  = IconH
          ProcedureReturn ListIndex(PDF()\Annots())
        EndIf
        
      EndIf
  
    EndProcedure
  
    Procedure.i AddGotoAction(ID.i, Page.i=#PB_Default, PosY.i=#PB_Default)
      
      If FindMapElement(PDF(), Str(ID))
        
        If Page = #PB_Default : Page = PDF()\pageNum : EndIf
        If PosY = #PB_Default : PosY = PDF()\Page\Y  : EndIf
        
        If AddElement(PDF()\Annots())
          PDF()\Annots()\Type    = #Annot_GoTo
          PDF()\Annots()\Dest    = Page
          PDF()\Annots()\X       = #PB_Default
          PDF()\Annots()\Y       = PosY
          PDF()\Annots()\Width   = #PB_Default
          PDF()\Annots()\Height  = #PB_Default
          PDF()\Annots()\objDest = PDF()\objPage
          ProcedureReturn ListIndex(PDF()\Annots())
        EndIf
        
      EndIf
      
    EndProcedure
  
    Procedure   AddGotoLabel(ID.i, Label.s)
      
      If FindMapElement(PDF(), Str(ID))
        
        If Label
          If AddElement(PDF()\Annots())
            PDF()\Annots()\Type          = #Annot_GoTo
            PDF()\Annots()\Dest          = PDF()\pageNum
            PDF()\Annots()\X             = #PB_Default
            PDF()\Annots()\Y             = PDF()\Page\Y
            PDF()\Annots()\Width         = #PB_Default
            PDF()\Annots()\Height        = #PB_Default
            PDF()\Annots()\objDest       = PDF()\objPage
            PDF()\Labels(Label)\ptHeight = PDF()\Page\ptHeight
            PDF()\Labels(Label)\ptWidth  = PDF()\Page\ptWidth
            PDF()\Labels(Label)\Idx      = ListIndex(PDF()\Annots())
          EndIf
        EndIf
        
      EndIf
      
    EndProcedure
  
    Procedure.i AddLaunchAction(ID.i, FileName.s, Y.f=#PB_Default, Action.s=#OpenAction)
      
      If FindMapElement(PDF(), Str(ID))
        
        If AddElement(PDF()\Annots())
          PDF()\Annots()\Type   = #Annot_Launch
          PDF()\Annots()\File   = FileName
          PDF()\Annots()\Action = Action
          PDF()\Annots()\X      = #PB_Default
          PDF()\Annots()\Y      = Y
          PDF()\Annots()\Width  = #PB_Default
          PDF()\Annots()\Height = #PB_Default
          ProcedureReturn ListIndex(PDF()\Annots())
        EndIf  
        
      EndIf
      
    EndProcedure
   
    Procedure.i AddLinkURL(ID.i, URL.s="")
      
      If FindMapElement(PDF(), Str(ID))
        
        If AddElement(PDF()\Annots())
          PDF()\Annots()\Type   = #Annot_URL
          PDF()\Annots()\URL    = URL
          PDF()\Annots()\X      = #PB_Default
          PDF()\Annots()\Y      = #PB_Default
          PDF()\Annots()\Width  = #PB_Default
          PDF()\Annots()\Height = #PB_Default
          ProcedureReturn ListIndex(PDF()\Annots())
        EndIf
        
      EndIf
      
    EndProcedure
  
    Procedure.i AddTextNote(ID.i, Title.s, Content.s, Icon.s=#NoteIcon, Y.f=#PB_Default)
      ; Icon:  #CommentIcon / #KeyIcon / #NoteIcon / #HelpIcon / #NewParagraphIcon / #ParagraphIcon / #InsertIcon
      If FindMapElement(PDF(), Str(ID))
        
        If AddElement(PDF()\Annots())
          PDF()\Annots()\Type    = #Annot_Text
          PDF()\Annots()\Titel   = Title
          PDF()\Annots()\Content = Content
          PDF()\Annots()\Icon    = Icon
          PDF()\Annots()\X       = #PB_Default
          PDF()\Annots()\Y       = Y
          PDF()\Annots()\Width   = 16
          PDF()\Annots()\Height  = 16
          ProcedureReturn ListIndex(PDF()\Annots())
        EndIf  
          
      EndIf 
  
    EndProcedure
    
    Procedure   LinkArea(ID.i, X.f, Y.f, Width.f, Height.f, Label.s="", Link.i=#NoLink)
    
      If FindMapElement(PDF(), Str(ID))
        
        If Link > #NoLink
          AddAnnot_(Link, X, Y, Width, Height)
        ElseIf Label
          AddLabelLink_(Label, X, Y, Width, Height)
        EndIf
        
      EndIf
      
    EndProcedure
    
  CompilerEndIf
  
  ;- ----- Drawing Commands -----------
  
  CompilerIf #Enable_DrawingCommands
  
    Procedure   PathArc(ID.i, X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Arc_(X1, Y1, X2, Y2, X3, Y3)
      EndIf
        
    EndProcedure  
  
    Procedure   PathBegin(ID.i, X.f, Y.f)              ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        PathBegin_(X, Y)
      EndIf  
        
    EndProcedure  
  
    Procedure   PathEnd(ID.i, Style.s=#DrawOnly)       ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        PathEnd_(Style)
      EndIf  
        
    EndProcedure   
  
    Procedure   PathLine(ID.i, X.f, Y.f)               ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        PathLine_(X,Y)
      EndIf
      
    EndProcedure  
  
    Procedure   DrawCircle(ID.i, X.f, Y.f, Radius.f, Style.s=#DrawOnly)              ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Ellipse_(X, Y, Radius, Radius, Style)
      EndIf
      
    EndProcedure

    Procedure   DrawEllipse(ID.i, X.f, Y.f, xRadius.f, yRadius.f, Style.s=#DrawOnly) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Ellipse_(X, Y, xRadius, yRadius, Style)
      EndIf
      
    EndProcedure  
  
    Procedure   DrawGrid(ID.i, Spacing=#PB_Default)    ; [*]                                                                                               ; Grid(sizemm=-1)
      Define.i i, X, Y, Width, Height, rMargin, gridSize
      Define.s Text$
      
      If FindMapElement(PDF(), Str(ID))
        
        Width   = PDF()\Page\Width
        Height  = PDF()\Page\Height
        rMargin = Width - PDF()\Margin\Right
        
        PDF()\PageBreak\Auto    = #False
        PDF()\PageBreak\Margin  = 0
        PDF()\PageBreak\Trigger = PDF()\Page\Height
    
        X = PDF()\Page\X
        Y = PDF()\Page\Y
    
        If gridSize = 0 And Spacing = #PB_Default
          gridSize = 5 ; default 5mm
          Spacing   = 5
        EndIf
      
        If Spacing > 0 And Spacing < 100 
          gridSize = Spacing 
        Else
          gridSize = 100
        EndIf
        
        SetDrawColor_(204, 255, 255)
        LineWidth_(0.25)
        
        For i = 0 To Width 
          Line_(i, 0, i, Height)
          i = i + gridSize - 1
        Next
      
        For i = 0 To Height 
          Line_(0, i, Width, i)
          i = i + gridSize - 1
        Next
        
        SetFont_("Arial", "I", 9)
        SetFrontColor_(204, 204, 204)
        
        For i = 20 To Height -20 Step 20
          SetXY_(1, i - 3)
          Write_(5, Str(i))
        Next
        
        For i = 20 To rMargin - 20 Step 20
          SetXY_(i - 1, 1)
          Write_(3, Str(i))   
        Next
        SetXY_(X, Y)
        
        SetFrontColor_(0, 0, 0)
        SetDrawColor_(0, 0, 0)
        
      EndIf
      
    EndProcedure
  
    Procedure   DrawLine(ID.i, X1.f, Y1.f, X2.f, Y2.f) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Line_(X1, Y1, X2, Y2)
      EndIf
      
    EndProcedure  
  
    Procedure   DrawRectangle(ID.i, X.f, Y.f, Width.f, Height.f, Style.s=#DrawOnly)                  ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Rectangle_(X, Y, Width, Height, Style)
      EndIf
      
    EndProcedure  
  
    Procedure   DrawRoundedRectangle(ID.i, X.f, Y.f, Width.f, Height.f, Radius.f, Style.s=#DrawOnly) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        
        PathBegin_(X, Y + Radius)
        Arc_(X, Y + (Radius / 2), X + (Radius/2),Y, X + Radius, Y)
        PathLine_(X + Width - Radius, Y)
        Arc_(X + Width - (Radius / 2), Y, X + Width, Y + (Radius / 2), X + Width, Y + Radius)
        PathLine_(X + Width, Y + Height - Radius)
        Arc_(X + Width,Y + Height - (Radius / 2), X + Width - (Radius /2 ), Y + Height, X + Width - Radius, Y + Height)
        PathLine_(X + Radius,Y + Height)
        Arc_(X + (Radius / 2), Y + Height, X, Y + Height - (Radius / 2), X, Y + Height - Radius)
        PathEnd_(Style)
        
      EndIf  
      
    EndProcedure   
  
    Procedure   DrawSector(ID.i, X.f, Y.f, Radius.f, startAngle.f, endAngle.f, Style.s=#DrawAndFill, Clockwise.i=#True, originAngle.f=90) ; [*]
      Define.f radiusX, radiusY, sAngle, eAngle, ArcX, ArcY, Degree
      
      If FindMapElement(PDF(), Str(ID))
        
        radiusX = Radius
        radiusY = Radius
      
        If Clockwise = #True
          Degree     = endAngle
          endAngle   = originAngle - startAngle
          startAngle = originAngle - Degree
        Else
          endAngle   = endAngle   + originAngle
          startAngle = startAngle + originAngle
        EndIf
      
        startAngle = Mod(startAngle, 360) + 360
        endAngle   = Mod(endAngle,   360) + 360
        
        If startAngle > endAngle : endAngle = endAngle + 360 : EndIf
        
        eAngle = endAngle   / 360 * 2 * #PI
        sAngle = startAngle / 360 * 2 * #PI
        
        Degree = eAngle - sAngle
      
        If Degree = 0 : Degree = 2 * #PI : EndIf
        
        If Sin(Degree / 2) 
          ArcX = 4 / 3 * (1 - Cos(Degree / 2)) / Sin(Degree / 2) * radiusX
          ArcY = 4 / 3 * (1 - Cos(Degree / 2)) / Sin(Degree / 2) * radiusY
        EndIf
        
        PathBegin_(X, Y)                                                ; first put the center
        PathLine_(X + radiusX * Cos(sAngle), Y - radiusY * Sin(sAngle)) ; put the first point
      
        If Degree < (#PI / 2)    ; draw the arc
          
          Arc_(X + radiusX * Cos(sAngle) + ArcX * Cos(#PI / 2 + sAngle), Y - radiusY * Sin(sAngle) - ArcY * Sin(#PI / 2 + sAngle), X + radiusX * Cos(eAngle) + ArcX * Cos(eAngle - #PI / 2), Y - radiusY * Sin(eAngle) - ArcY * Sin(eAngle - #PI / 2), X + radiusX * Cos(eAngle), Y - radiusY * Sin(eAngle))
          
        Else
        
          eAngle = sAngle + Degree / 4
          
          ArcX = 4 / 3 * (1 - Cos(Degree / 8)) / Sin(Degree / 8) * radiusX
          ArcY = 4 / 3 * (1 - Cos(Degree / 8)) / Sin(Degree / 8) * radiusY
          Arc_(X + radiusX * Cos(sAngle) + ArcX * Cos(#PI / 2 + sAngle), Y - radiusY * Sin(sAngle) - ArcY * Sin(#PI / 2 + sAngle), X + radiusX * Cos(eAngle) + ArcX * Cos(eAngle - #PI / 2), Y - radiusY * Sin(eAngle) - ArcY * Sin(eAngle - #PI / 2), X + radiusX * Cos(eAngle), Y - radiusY * Sin(eAngle))
          
          sAngle = eAngle
          eAngle = sAngle + Degree / 4
          Arc_(X + radiusX * Cos(sAngle) + ArcX * Cos(#PI / 2 + sAngle), Y - radiusY * Sin(sAngle) - ArcY * Sin(#PI / 2 + sAngle), X + radiusX * Cos(eAngle) + ArcX * Cos(eAngle - #PI / 2), Y - radiusY * Sin(eAngle) - ArcY * Sin(eAngle - #PI / 2), X + radiusX * Cos(eAngle), Y - radiusY * Sin(eAngle))
          
          sAngle = eAngle
          eAngle = sAngle + Degree / 4
          Arc_(X + radiusX * Cos(sAngle) + ArcX * Cos(#PI / 2 + sAngle), Y - radiusY * Sin(sAngle) - ArcY * Sin(#PI / 2 + sAngle), X + radiusX * Cos(eAngle) + ArcX * Cos(eAngle - #PI / 2), Y - radiusY * Sin(eAngle) - ArcY * Sin(eAngle - #PI / 2), X + radiusX * Cos(eAngle), Y - radiusY * Sin(eAngle))
          
          sAngle = eAngle
          eAngle = sAngle + Degree / 4
          Arc_(X + radiusX * Cos(sAngle) + ArcX * Cos(#PI / 2 + sAngle), Y - radiusY * Sin(sAngle) - ArcY * Sin(#PI / 2 + sAngle), X + radiusX * Cos(eAngle) + ArcX * Cos(eAngle - #PI / 2), Y - radiusY * Sin(eAngle) - ArcY * Sin(eAngle - #PI / 2), X + radiusX * Cos(eAngle), Y - radiusY * Sin(eAngle))
          
        EndIf  
        
        PathEnd_(Style)          ; terminate drawing
        
      EndIf
      
    EndProcedure
  
    Procedure   DrawTriangle(ID.i, X1.f, Y1.f, X2.f, Y2.f, X3.f, Y3.f, Style.s=#DrawOnly)            ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        
        PathBegin_(X1, Y1)
        PathLine_(X2, Y2)
        PathLine_(X3, Y3)
        PathEnd_(Style)
        
      EndIf
      
    EndProcedure    
  
  CompilerEndIf
  
  ;- ----- Transform Commands ----------
  
  CompilerIf #Enable_TransformCommands
    
    Procedure   MirrorHorizontal(ID.i, X.f=#PB_Default) ; [*]                                                
    
      If FindMapElement(PDF(), Str(ID))
        Scale_(-100, 100, X, #PB_Default)
      EndIf
      
    EndProcedure
  
    Procedure   MirrorVertical(ID.i, Y.f=#PB_Default)   ; [*]                                             
      
      If FindMapElement(PDF(), Str(ID))
        Scale_(100, -100, #PB_Default, Y)
      EndIf
      
    EndProcedure  
    
    Procedure   ScaleHorizontal(ID.i, Factor.f=100, X.f=#PB_Default, Y.f=#PB_Default) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Scale_(Factor, 100, X, Y)
      EndIf  
        
    EndProcedure
    
    Procedure   ScaleVertical(ID.i, Factor.f=100, X.f=#PB_Default, Y.f=#PB_Default)   ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Scale_(100, Factor, X, Y)
      EndIf  
        
    EndProcedure
  
    Procedure   Scale(ID.i, Factor.f=100, X.f=#PB_Default, Y.f=#PB_Default)           ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Scale_(Factor, Factor, X, Y)
      EndIf  
   
    EndProcedure
    
    Procedure   SkewHorizontal(ID.i, Angle.i, X.f=#PB_Default, Y.f=#PB_Default)       ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Skew_(Angle, 0, X, Y)
      EndIf 
      
    EndProcedure
  
    Procedure   SkewVertical(ID.i, Angle.i, X.f=#PB_Default, Y.f=#PB_Default)         ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Skew_(0, Angle, X, Y)
      EndIf 
      
    EndProcedure    
    
    Procedure   StartTransform(ID.i) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        objOutPage_("q")
      EndIf
      
    EndProcedure
  
    Procedure   StopTransform(ID.i)  ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        objOutPage_("Q")
      EndIf
      
    EndProcedure  
  
    Procedure   Translate(ID.i, moveX.f, moveY.f)  ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Transform_(1, 0, 0, 1, moveX, moveY)
      EndIf
      
    EndProcedure
    
    Procedure   TranslateHorizontal(ID.i, moveX.f) ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Transform_(1, 0, 0, 1, moveX, 0)
      EndIf
      
    EndProcedure
    
    Procedure   TranslateVertical(ID.i, moveY.f)   ; [*]
      
      If FindMapElement(PDF(), Str(ID))
        Transform_(1, 0, 0, 1, 0, moveY)
      EndIf
      
    EndProcedure    
  
  CompilerEndIf
 
  ;- ----------------------------------------
  
  Procedure   AddPage(ID.i, Orientation.s="", Format.s="")             ; [*]
    
    If  FindMapElement(PDF(), Str(ID))
      
      If AddPage_(Orientation, Format)
        ProcedureReturn #True
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure   AddEntryTOC(ID.i, Text.s, Level.i=0) 
    
    If FindMapElement(PDF(), Str(ID))
      
      If AddElement(PDF()\TOC())
        PDF()\TOC()\Text  = Text
        PDF()\TOC()\Level = Level
        PDF()\TOC()\Page  = PDF()\pageNum  
      EndIf
      
    EndIf
    
  EndProcedure  

  Procedure   BookMark(ID.i, Titel.s, SubLevel.i=#False, Y.f=#PB_Default, Page.i=#PB_Default)
    Define.s objStrg, objLastStrg, objLast, Level$, Parent$, SubLevel$
    
    If FindMapElement(PDF(), Str(ID))
      
      If Y    = #PB_Default : Y    = PDF()\Page\Y : EndIf 
      If Page = #PB_Default : Page = PDF()\pageNum : EndIf
      
      If PDF()\Catalog\objOutlines = "" ;{ Create Outlines Object
        objNew_(#objOutlines)
        objOutDictionary_("/Type /Outlines" + #LF$, #LF$)
        ;}
      EndIf
      
      Level$    = Str(SubLevel)
      SubLevel$ = Str(SubLevel + 1)
      Parent$   = Str(SubLevel - 1)
      
      objLast = PDF()\objBookmark(Level$)\Object
      
      objNew_(#objBookmark)
      
      PDF()\objBookmark(Level$)\Object = strObj_(PDF()\objNum)
      
      objOutDictionary_(Titel, #LF$ + "/Title (", ")" + #LF$, #objText)
      
      If SubLevel
        
        objStrg = "/Parent " + PDF()\objBookmark(Parent$)\Object + #LF$
        
        If PDF()\objBookmark(Parent$)\First = "" : PDF()\objBookmark(Parent$)\First = strObj_(PDF()\objNum) : EndIf
        
        PDF()\objBookmark(Parent$)\Last = strObj_(PDF()\objNum)
        PDF()\objBookmark(Parent$)\Count + 1
        
      Else
        
        objStrg = "/Parent " + PDF()\Catalog\objOutlines + #LF$
        
      EndIf

      If objLast ;{ Complete previous object
        
        objStrg + "/Prev " + objLast + #LF$
        
        ; Previous Bookmark (same level)
        objLastStrg = "/Next " + strObj_(PDF()\objNum) + #LF$
        
        If PDF()\objBookmark(Level$)\Count > 0
          objLastStrg + "/First " + PDF()\objBookmark(Level$)\First + #LF$
          objLastStrg + "/Last "  + PDF()\objBookmark(Level$)\Last  + #LF$
          objLastStrg + "/Count " + Str(PDF()\objBookmark(Level$)\Count) + #LF$
          PDF()\objBookmark(Level$)\Count = 0
          PDF()\objBookmark(Level$)\First = ""
          PDF()\objBookmark(Level$)\Last  = ""
          DeleteMapElement(PDF()\objBookmark(), SubLevel$)
        EndIf
        
        objOutDictionary_(objLastStrg, "", "", #False, objLast)
        ;}
      EndIf
      
      If SelectElement(PDF()\Pages(), Page)
        objStrg + "/Dest [" + PDF()\Pages()\objNum + " /XYZ 0 " + strF_((PDF()\Page\Height - Y) * PDF()\ScaleFactor, 2) + " 0]" + #LF$
      EndIf
      
      objOutDictionary_(objStrg)

    EndIf
    
  EndProcedure
  
  Procedure   Cell(ID.i, Text.s, Width.f=#PB_Default, Height.f=#PB_Default, Border.i=#False, Ln.i=#Right, Align.s="", Fill.i=#False, Label.s="", Link.i=#NoLink) ; [*]
    
    If FindMapElement(PDF(), Str(ID))
      Cell_(Width, Height, Text, Border, Ln, Align, Fill, Link, Label)
    EndIf  
  
  EndProcedure
  
  Procedure   Close(ID.i, FileName.s) 
    If FindMapElement(PDF(), Str(ID))
      
      If PDF()\pageNum = 0 : AddPage_() : EndIf

      ;{ Close last page
      If PDF()\Page\Angle
        PDF()\Page\Angle = 0
    		objOutPage_("Q" + #LF$)
    	EndIf
    	
      If PDF()\Footer\Flag And PDF()\Footer\ProcPtr
        PDF()\Footer\PageBreak = #False
        If PDF()\Footer\StrucPtr <> #Null
          CallCFunctionFast(PDF()\Footer\ProcPtr, PDF()\Footer\StrucPtr)
        Else
          CallCFunctionFast(PDF()\Footer\ProcPtr)
        EndIf
        PDF()\Footer\PageBreak = #True
      ElseIf PDF()\Footer\Numbering
        PDF()\Footer\PageBreak = #False 
        SetY_(-15)
        SetFont_("Arial", "BI", 9)
        Cell_(0, 10, "{p}", 0, 0, #CenterAlign)
        PDF()\Footer\PageBreak = #True
      EndIf ;}
      
      CompleteObjects_()
      
      WritePDF_(FileName)
      
      DeleteMapElement(PDF())
      
    EndIf
    
  EndProcedure
  
  Procedure   DividingLine(ID.i, X.f=#PB_Default, Y.f=#PB_Default, Width.f=#PB_Default) ; [*]
    
    If FindMapElement(PDF(), Str(ID))
      
      If X = #PB_Default : X = PDF()\Page\X : EndIf
      If Y = #PB_Default : Y = PDF()\Page\Y : EndIf
      If Width = #PB_Default : Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X : EndIf
      
      Line_(X, Y, Width - X, Y)
      
    EndIf
    
  EndProcedure   
  
  Procedure.i EmbedFile(ID.i, Filename.s, Description.s="") ; [*]
    ; PDF Reference Version 1.6 - Chapter 3.10
    Define.i FileNum
    Define.s objFile, objStrg
    Define Compress.Memory_Structure
    
    If CompressFile_(Filename, @Compress)
      
      objNew_()
      objFile = strObj_(PDF()\objNum)
      objStrg = "/Type /EmbeddedFile"  + #LF$
      objStrg + "/Filter /FlateDecode" + #LF$
      objStrg + "/Length " + Str(Compress\Size) + #LF$
      objStrg + "/Params <<"+ "/Size " + Str(FileSize(Filename)) + " "
      objOutDictionary_(objStrg, #LF$)
      objOutDictionary_(FormatDate("D:%yyyy%mm%dd%hh%ii%ssZ", GetFileDate(Filename, #PB_Date_Created)),  "/CreationDate (", ") ", #objText)
      objOutDictionary_(FormatDate("D:%yyyy%mm%dd%hh%ii%ssZ", GetFileDate(Filename, #PB_Date_Modified)), "/ModDate (", ")>>"   + #LF$, #objText)
      objOutStream_(Compress\Memory, Compress\Size, #objCompress)
      
      FileNum = objNew_(#objFile, Filename)
      objStrg = "/Type /Filespec" + #LF$
      objStrg + "/EF <</F " + objFile + ">>" + #LF$
      objOutDictionary_(objStrg, #LF$)
      If Description : objOutDictionary_(Description, "/Desc (", ")" + #LF$, #objText) : EndIf
      objOutDictionary_(GetFilePart(Filename), "/F (", ")" + #LF$, #objText)
      
      If PDF()\Catalog\objNames = "" : objNew_(#objNames) : EndIf ; => PDF()\Catalog\objNames
      
    Else
      ProcedureReturn #False
    EndIf
    
    ProcedureReturn FileNum
  EndProcedure  
  
  Procedure.s EmbedFont(ID.i, Filename.s, Family.s="", Style.s="", Flags.i=#False)
    ; PDF Reference Version 1.6 - Chapter 5.8
    Define.i i, UTF, Length
    Define.s objEmbed, objCharW, objFontDesc, objCIDMap, objDescFonts, objStrg
    Define.s Error1, Error2, Error3, FontKey, Titel, FontName
    Define   Font.TTF_Header_Structure, Compress.Memory_Structure
    Define   *Memory
    
    If FindMapElement(PDF(), Str(ID))
      
      Style = Trim(UCase(Style))
      If FindString(Style, "U", 1) > 0 : Style = ReplaceString(Style, "U", "") : EndIf
      If Style = "IB" : Style = "BI" : EndIf
      
      If FileHeaderTTF_(FileName, @Font)
        
        If Family = "" : Family = Font\Name : EndIf
        
        FontKey = UCase(RSet(Style, 3, "_") + Family) ; BI_+Fontname
        
        If AddMapElement(PDF()\Fonts(), FontKey)
          
          If Font\StemV = 0 : Font\StemV = 70 : EndIf
          
          PDF()\Fonts()\Number    = MapSize(PDF()\Fonts())
          PDF()\Fonts()\Name      = Font\Name
          PDF()\Fonts()\Style     = Style
          PDF()\Fonts()\Encoding  = Font\Encoding
          If Flags & #Unicode
            PDF()\Fonts()\Unicode = #True
            Flags = Flags & ~#Unicode
          EndIf
          PDF()\Fonts()\Flags = Flags
          
          ;PDF()\Fonts()\FixedWidth   = Font\FixedWidth

          ForEach Font\CharWidth()
            UTF = Val(MapKey(Font\CharWidth()))
            PDF()\Fonts()\CharWidth(Chr(UTF)) = Font\CharWidth()
          Next
          
          If CompressFile_(Filename, @Compress)
            
            FontName = ReplaceString(PDF()\Fonts()\Name, " ", "#20")
            
            ;{ --- Embed Font ---
            objNew_()
            objEmbed = strObj_(PDF()\objNum)
            objOutDictionary_("/Filter /FlateDecode /Length " + Str(Compress\Size) + " /Length1 " + Str(Compress\Length))
            objOutStream_(Compress\Memory, Compress\Size, #objCompress)
            ;}
            
            ;{ --- Font Descriptor ---
            objNew_()
            objFontDesc = strObj_(PDF()\objNum)
            objStrg = #LF$
            objStrg + "/Type /FontDescriptor"     + #LF$
            objStrg + "/FontName /"    + FontName + #LF$
            objStrg + "/Ascent "       + Str(Font\Ascent)    + #LF$
            objStrg + "/Descent "      + Str(Font\Descent)   + #LF$
            objStrg + "/CapHeight "    + Str(Font\CapHeight) + #LF$
            ;{ Font flags :
            ; Bit-Position   Name
            ;  1     1       FixedPitch
            ;  2     2       Serif
            ;  3     4       Symbolic
            ;  4     8       Script
            ;  6    32       Nonsymbolic
            ;  7    64       Italic
            ; 17 65536       AllCap
            ; 18 131072      SmallCap
            ; 19 262144      ForceBold
            ;}
            objStrg + "/Flags "        + Str(Font\Flag)      + #LF$
            objStrg + "/FontBBox ["    + Str(Font\BBox\X1) + " " + Str(Font\BBox\Y1) + " " + Str(Font\BBox\X2) + " " + Str(Font\BBox\Y2) + "]" + #LF$
            objStrg + "/ItalicAngle "  + strF_(Font\ItalicAngle, 2) + #LF$
            objStrg + "/StemV "        + Str(Font\StemV) + #LF$
            objStrg + "/MissingWidth " + Str(Font\MissingWidth) + #LF$
            objStrg + "/FontFile2 "    + objEmbed + #LF$
            objOutDictionary_(objStrg)
            ;}
            
            If PDF()\Fonts()\Unicode     ;{ Unicode Font
              
              If Font\CIDToGIDMap        ;{ Compress CIDToGIDMap Stream
                If CompressMemory_(Font\CIDToGIDMap, @Compress)
                  objNew_()
                  objCIDMap = strObj_(PDF()\objNum)
                  objOutDictionary_("/Filter /FlateDecode /Length " + Str(Compress\Size) + " /Length1 131072")
                  objOutStream_(Compress\Memory, Compress\Size, #objCompress)                  
                EndIf ;}
              EndIf
              
              If PDF()\objToUnicode = "" ;{ ToUnicode Stream
                
                objNew_()
                PDF()\objToUnicode = strObj_(PDF()\objNum)
                objStrg = #LF$
                objStrg + "/CIDInit /ProcSet findresource begin" + #LF$ + "12 dict begin" + #LF$ + "begincmap" + #LF$
                objStrg + "/CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def" + #LF$
                objStrg + "/CMapName /Adobe-Identity-UCS def" + #LF$
                objStrg + "/CMapType 2 def" + #LF$
                objStrg + "1 begincodespacerange" + #LF$ + "<0000> <FFFF>" + #LF$ + "endcodespacerange" + #LF$
                objStrg + "100 beginbfrange" + #LF$     
                objStrg + "<0000> <00FF> <0000>" + #LF$ + "<0100> <01FF> <0100>" + #LF$ + "<0200> <02FF> <0200>" + #LF$ + "<0300> <03FF> <0300>" + #LF$ + "<0400> <04FF> <0400>" + #LF$
                objStrg + "<0500> <05FF> <0500>" + #LF$ + "<0600> <06FF> <0600>" + #LF$ + "<0700> <07FF> <0700>" + #LF$ + "<0800> <08FF> <0800>" + #LF$ + "<0900> <09FF> <0900>" + #LF$
                objStrg + "<0A00> <0AFF> <0A00>" + #LF$ + "<0B00> <0BFF> <0B00>" + #LF$ + "<0C00> <0CFF> <0C00>" + #LF$ + "<0D00> <0DFF> <0D00>" + #LF$ + "<0E00> <0EFF> <0E00>" + #LF$
                objStrg + "<0F00> <0FFF> <0F00>" + #LF$ + "<1000> <10FF> <1000>" + #LF$ + "<1100> <11FF> <1100>" + #LF$ + "<1200> <12FF> <1200>" + #LF$ + "<1300> <13FF> <1300>" + #LF$              
                objStrg + "<1400> <14FF> <1400>" + #LF$ + "<1500> <15FF> <1500>" + #LF$ + "<1600> <16FF> <1600>" + #LF$ + "<1700> <17FF> <1700>" + #LF$ + "<1800> <18FF> <1800>" + #LF$
                objStrg + "<1900> <19FF> <1900>" + #LF$ + "<1A00> <1AFF> <1A00>" + #LF$ + "<1B00> <1BFF> <1B00>" + #LF$ + "<1C00> <1CFF> <1C00>" + #LF$ + "<1D00> <1DFF> <1D00>" + #LF$    
                objStrg + "<1E00> <1EFF> <1E00>" + #LF$ + "<1F00> <1FFF> <1F00>" + #LF$ + "<2000> <20FF> <2000>" + #LF$ + "<2100> <21FF> <2100>" + #LF$ + "<2200> <22FF> <2200>" + #LF$
                objStrg + "<2300> <23FF> <2300>" + #LF$ + "<2400> <24FF> <2400>" + #LF$ + "<2500> <25FF> <2500>" + #LF$ + "<2600> <26FF> <2600>" + #LF$ + "<2700> <27FF> <2700>" + #LF$
                objStrg + "<2800> <28FF> <2800>" + #LF$ + "<2900> <29FF> <2900>" + #LF$ + "<2A00> <2AFF> <2A00>" + #LF$ + "<2B00> <2BFF> <2B00>" + #LF$ + "<2C00> <2CFF> <2C00>" + #LF$                
                objStrg + "<2D00> <2DFF> <2D00>" + #LF$ + "<2E00> <2EFF> <2E00>" + #LF$ + "<2F00> <2FFF> <2F00>" + #LF$ + "<3000> <30FF> <3000>" + #LF$ + "<3100> <31FF> <3100>" + #LF$
                objStrg + "<3200> <32FF> <3200>" + #LF$ + "<3300> <33FF> <3300>" + #LF$ + "<3400> <34FF> <3400>" + #LF$ + "<3500> <35FF> <3500>" + #LF$ + "<3600> <36FF> <3600>" + #LF$              
                objStrg + "<3700> <37FF> <3700>" + #LF$ + "<3800> <38FF> <3800>" + #LF$ + "<3900> <39FF> <3900>" + #LF$ + "<3A00> <3AFF> <3A00>" + #LF$ + "<3B00> <3BFF> <3B00>" + #LF$  
                objStrg + "<3C00> <3CFF> <3C00>" + #LF$ + "<3D00> <3DFF> <3D00>" + #LF$ + "<3E00> <3EFF> <3E00>" + #LF$ + "<3F00> <3FFF> <3F00>" + #LF$ + "<4000> <40FF> <4000>" + #LF$
                objStrg + "<4100> <41FF> <4100>" + #LF$ + "<4200> <42FF> <4200>" + #LF$ + "<4300> <43FF> <4300>" + #LF$ + "<4400> <44FF> <4400>" + #LF$ + "<4500> <45FF> <4500>" + #LF$
                objStrg + "<4600> <46FF> <4600>" + #LF$ + "<4700> <47FF> <4700>" + #LF$ + "<4800> <48FF> <4800>" + #LF$ + "<4900> <49FF> <4900>" + #LF$ + "<4A00> <4AFF> <4A00>" + #LF$     
                objStrg + "<4B00> <4BFF> <4B00>" + #LF$ + "<4C00> <4CFF> <4C00>" + #LF$ + "<4D00> <4DFF> <4D00>" + #LF$ + "<4E00> <4EFF> <4E00>" + #LF$ + "<4F00> <4FFF> <4F00>" + #LF$
                objStrg + "<5000> <50FF> <5000>" + #LF$ + "<5100> <51FF> <5100>" + #LF$ + "<5200> <52FF> <5200>" + #LF$ + "<5300> <53FF> <5300>" + #LF$ + "<5400> <54FF> <5400>" + #LF$
                objStrg + "<5500> <55FF> <5500>" + #LF$ + "<5600> <56FF> <5600>" + #LF$ + "<5700> <57FF> <5700>" + #LF$ + "<5800> <58FF> <5800>" + #LF$ + "<5900> <59FF> <5900>" + #LF$             
                objStrg + "<5A00> <5AFF> <5A00>" + #LF$ + "<5B00> <5BFF> <5B00>" + #LF$ + "<5C00> <5CFF> <5C00>" + #LF$ + "<5D00> <5DFF> <5D00>" + #LF$ + "<5E00> <5EFF> <5E00>" + #LF$
                objStrg + "<5F00> <5FFF> <5F00>" + #LF$ + "<6000> <60FF> <6000>" + #LF$ + "<6100> <61FF> <6100>" + #LF$ + "<6200> <62FF> <6200>" + #LF$ + "<6300> <63FF> <6300>" + #LF$              
                objStrg + "endbfrange" + #LF$  
                objStrg + "100 beginbfrange" + #LF$
                objStrg + "<6400> <64FF> <6400>" + #LF$ + "<6500> <65FF> <6500>" + #LF$ + "<6600> <66FF> <6600>" + #LF$ + "<6700> <67FF> <6700>" + #LF$ + "<6800> <68FF> <6800>" + #LF$
                objStrg + "<6900> <69FF> <6900>" + #LF$ + "<6A00> <6AFF> <6A00>" + #LF$ + "<6B00> <6BFF> <6B00>" + #LF$ + "<6C00> <6CFF> <6C00>" + #LF$ + "<6D00> <6DFF> <6D00>" + #LF$
                objStrg + "<6E00> <6EFF> <6E00>" + #LF$ + "<6F00> <6FFF> <6F00>" + #LF$ + "<7000> <70FF> <7000>" + #LF$ + "<7100> <71FF> <7100>" + #LF$ + "<7200> <72FF> <7200>" + #LF$
                objStrg + "<7300> <73FF> <7300>" + #LF$ + "<7400> <74FF> <7400>" + #LF$ + "<7500> <75FF> <7500>" + #LF$ + "<7600> <76FF> <7600>" + #LF$ + "<7700> <77FF> <7700>" + #LF$
                objStrg + "<7800> <78FF> <7800>" + #LF$ + "<7900> <79FF> <7900>" + #LF$ + "<7A00> <7AFF> <7A00>" + #LF$ + "<7B00> <7BFF> <7B00>" + #LF$ + "<7C00> <7CFF> <7C00>" + #LF$
                objStrg + "<7D00> <7DFF> <7D00>" + #LF$ + "<7E00> <7EFF> <7E00>" + #LF$ + "<7F00> <7FFF> <7F00>" + #LF$ + "<8000> <80FF> <8000>" + #LF$ + "<8100> <81FF> <8100>" + #LF$     
                objStrg + "<8200> <82FF> <8200>" + #LF$ + "<8300> <83FF> <8300>" + #LF$ + "<8400> <84FF> <8400>" + #LF$ + "<8500> <85FF> <8500>" + #LF$ + "<8600> <86FF> <8600>" + #LF$  
                objStrg + "<8700> <87FF> <8700>" + #LF$ + "<8800> <88FF> <8800>" + #LF$ + "<8900> <89FF> <8900>" + #LF$ + "<8A00> <8AFF> <8A00>" + #LF$ + "<8B00> <8BFF> <8B00>" + #LF$  
                objStrg + "<8C00> <8CFF> <8C00>" + #LF$ + "<8D00> <8DFF> <8D00>" + #LF$ + "<8E00> <8EFF> <8E00>" + #LF$ + "<8F00> <8FFF> <8F00>" + #LF$ + "<9000> <90FF> <9000>" + #LF$  
                objStrg + "<9100> <91FF> <9100>" + #LF$ + "<9200> <92FF> <9200>" + #LF$ + "<9300> <93FF> <9300>" + #LF$ + "<9400> <94FF> <9400>" + #LF$ + "<9500> <95FF> <9500>" + #LF$                
                objStrg + "<9600> <96FF> <9600>" + #LF$ + "<9700> <97FF> <9700>" + #LF$ + "<9800> <98FF> <9800>" + #LF$ + "<9900> <99FF> <9900>" + #LF$ + "<9A00> <9AFF> <9A00>" + #LF$    
                objStrg + "<9B00> <9BFF> <9B00>" + #LF$ + "<9C00> <9CFF> <9C00>" + #LF$ + "<9D00> <9DFF> <9D00>" + #LF$ + "<9E00> <9EFF> <9E00>" + #LF$ + "<9F00> <9FFF> <9F00>" + #LF$
                objStrg + "<A000> <A0FF> <A000>" + #LF$ + "<A100> <A1FF> <A100>" + #LF$ + "<A200> <A2FF> <A200>" + #LF$ + "<A300> <A3FF> <A300>" + #LF$ + "<A400> <A4FF> <A400>" + #LF$
                objStrg + "<A500> <A5FF> <A500>" + #LF$ + "<A600> <A6FF> <A600>" + #LF$ + "<A700> <A7FF> <A700>" + #LF$ + "<A800> <A8FF> <A800>" + #LF$ + "<A900> <A9FF> <A900>" + #LF$                
                objStrg + "<AA00> <AAFF> <AA00>" + #LF$ + "<AB00> <ABFF> <AB00>" + #LF$ + "<AC00> <ACFF> <AC00>" + #LF$ + "<AD00> <ADFF> <AD00>" + #LF$ + "<AE00> <AEFF> <AE00>" + #LF$  
                objStrg + "<AF00> <AFFF> <AF00>" + #LF$ + "<B000> <B0FF> <B000>" + #LF$ + "<B100> <B1FF> <B100>" + #LF$ + "<B200> <B2FF> <B200>" + #LF$ + "<B300> <B3FF> <B300>" + #LF$
                objStrg + "<B400> <B4FF> <B400>" + #LF$ + "<B500> <B5FF> <B500>" + #LF$ + "<B600> <B6FF> <B600>" + #LF$ + "<B700> <B7FF> <B700>" + #LF$ + "<B800> <B8FF> <B800>" + #LF$
                objStrg + "<B900> <B9FF> <B900>" + #LF$ + "<BA00> <BAFF> <BA00>" + #LF$ + "<BB00> <BBFF> <BB00>" + #LF$ + "<BC00> <BCFF> <BC00>" + #LF$ + "<BD00> <BDFF> <BD00>" + #LF$
                objStrg + "<BE00> <BEFF> <BE00>" + #LF$ + "<BF00> <BFFF> <BF00>" + #LF$ + "<C000> <C0FF> <C000>" + #LF$ + "<C100> <C1FF> <C100>" + #LF$ + "<C200> <C2FF> <C200>" + #LF$
                objStrg + "<C300> <C3FF> <C300>" + #LF$ + "<C400> <C4FF> <C400>" + #LF$ + "<C500> <C5FF> <C500>" + #LF$ + "<C600> <C6FF> <C600>" + #LF$ + "<C700> <C7FF> <C700>" + #LF$
                objStrg + "endbfrange" + #LF$
                objStrg + "56 beginbfrange" + #LF$
                objStrg + "<C800> <C8FF> <C800>" + #LF$ + "<C900> <C9FF> <C900>" + #LF$ + "<CA00> <CAFF> <CA00>" + #LF$ + "<CB00> <CBFF> <CB00>" + #LF$ + "<CC00> <CCFF> <CC00>" + #LF$
                objStrg + "<CD00> <CDFF> <CD00>" + #LF$ + "<CE00> <CEFF> <CE00>" + #LF$ + "<CF00> <CFFF> <CF00>" + #LF$ + "<D000> <D0FF> <D000>" + #LF$ + "<D100> <D1FF> <D100>" + #LF$
                objStrg + "<D200> <D2FF> <D200>" + #LF$ + "<D300> <D3FF> <D300>" + #LF$ + "<D400> <D4FF> <D400>" + #LF$ + "<D500> <D5FF> <D500>" + #LF$ + "<D600> <D6FF> <D600>" + #LF$      
                objStrg + "<D700> <D7FF> <D700>" + #LF$ + "<D800> <D8FF> <D800>" + #LF$ + "<D900> <D9FF> <D900>" + #LF$ + "<DA00> <DAFF> <DA00>" + #LF$ + "<DB00> <DBFF> <DB00>" + #LF$
                objStrg + "<DC00> <DCFF> <DC00>" + #LF$ + "<DD00> <DDFF> <DD00>" + #LF$ + "<DE00> <DEFF> <DE00>" + #LF$ + "<DF00> <DFFF> <DF00>" + #LF$ + "<E000> <E0FF> <E000>" + #LF$
                objStrg + "<E100> <E1FF> <E100>" + #LF$ + "<E200> <E2FF> <E200>" + #LF$ + "<E300> <E3FF> <E300>" + #LF$ + "<E400> <E4FF> <E400>" + #LF$ + "<E500> <E5FF> <E500>" + #LF$
                objStrg + "<E600> <E6FF> <E600>" + #LF$ + "<E700> <E7FF> <E700>" + #LF$ + "<E800> <E8FF> <E800>" + #LF$ + "<E900> <E9FF> <E900>" + #LF$ + "<EA00> <EAFF> <EA00>" + #LF$              
                objStrg + "<EB00> <EBFF> <EB00>" + #LF$ + "<EC00> <ECFF> <EC00>" + #LF$ + "<ED00> <EDFF> <ED00>" + #LF$ + "<EE00> <EEFF> <EE00>" + #LF$ + "<EF00> <EFFF> <EF00>" + #LF$  
                objStrg + "<F000> <F0FF> <F000>" + #LF$ + "<F100> <F1FF> <F100>" + #LF$ + "<F200> <F2FF> <F200>" + #LF$ + "<F300> <F3FF> <F300>" + #LF$ + "<F400> <F4FF> <F400>" + #LF$  
                objStrg + "<F500> <F5FF> <F500>" + #LF$ + "<F600> <F6FF> <F600>" + #LF$ + "<F700> <F7FF> <F700>" + #LF$ + "<F800> <F8FF> <F800>" + #LF$ + "<F900> <F9FF> <F900>" + #LF$
                objStrg + "<FA00> <FAFF> <FA00>" + #LF$ + "<FB00> <FBFF> <FB00>" + #LF$ + "<FC00> <FCFF> <FC00>" + #LF$ + "<FD00> <FDFF> <FD00>" + #LF$ + "<FE00> <FEFF> <FE00>" + #LF$
                objStrg + "<FF00> <FFFF> <FF00>" + #LF$              
                objStrg + "endbfrange" + #LF$
                objStrg + "endcmap" + #LF$
                objStrg + "CMapName currentdict /CMap defineresource pop" + #LF$
                objStrg + "end" + #LF$ + "end" + #LF$
                Length  = Len(objStrg)
                
                *Memory = AllocateMemory(Length + 2)
                If *Memory
                  PokeS(*Memory, objStrg, Length, #PB_Ascii)
                  If CompressMemory_(*Memory, @Compress)
                    objOutDictionary_("/Filter /FlateDecode /Length " + Str(Compress\Size) + " /Length1 " + Length)
                    objOutStream_(Compress\Memory, Compress\Size, #objCompress)
                  Else
                    objOutDictionary_("/Length " + Str(Length))
                    objOutStream_(*Memory, Length)
                  EndIf
                EndIf
                ;}
              EndIf
              
              ; --- CharWidths ---
              objNew_()
              objCharW = strObj_(PDF()\objNum)
              objStrg = #LF$
              objStrg + "/Type /Font /Subtype /CIDFontType2" + #LF$
              objStrg + "/BaseFont /"+ FontName + #LF$
              objStrg + "/CIDSystemInfo <</Registry (Adobe) /Ordering (UCS) /Supplement 0>>" + #LF$
              objStrg + "/FontDescriptor " + objFontDesc + #LF$
              objStrg + "/CIDToGIDMap "    + objCIDMap   + #LF$
              objOutDictionary_(objStrg)
              objStrg = ""
              For i=0 To 65535
                If FindMapElement(PDF()\Fonts()\CharWidth(), Chr(i))
                  objStrg + Str(i) + " [" + Str(PDF()\Fonts()\CharWidth(Chr(i))) + "] "
                EndIf
              Next              
              objOutDictionary_("/W [" + objStrg + "]" + #LF$)
              ; --- Font ---
              objNew_(#objFont, Font\Name)
              objStrg = #LF$
              objStrg + "/Type /Font /Subtype /Type0" + #LF$
              objStrg + "/BaseFont /" + FontName + "-UCS"      + #LF$
              objStrg + "/Encoding /Identity-H"  + #LF$
              objStrg + "/DescendantFonts [" + objCharW + "]" + #LF$
              objStrg + "/ToUnicode " + PDF()\objToUnicode + #LF$
              objOutDictionary_(objStrg)
              ;}
            Else                         ;{ ASCII
              ; --- CharWidths ---
              objNew_()
              objCharW = strObj_(PDF()\objNum)
              objStrg = "["
              For i=0 To 255
                objStrg + StrU(PDF()\Fonts()\CharWidth(Chr(i))) + " "
              Next
              objStrg + "]"
              objOutStrg_(objStrg)
              ; --- Font ---
              objNew_(#objFont, Font\Name)
              objStrg = #LF$
              objStrg + "/Type /Font /Subtype /TrueType" + #LF$
              objStrg + "/BaseFont /" + FontName + #LF$
              If Font\Encoding : objStrg + " /Encoding /WinAnsiEncoding" + #LF$  : EndIf
              objStrg + "/Name /F" + Str(PDF()\Fonts()\Number) + #LF$
              objStrg + "/FirstChar 0 /LastChar 255" + #LF$
              objStrg + "/Widths " + objCharW + #LF$
              objStrg + "/FontDescriptor " + objFontDesc + #LF$
              objOutDictionary_(objStrg)            
              ;}
            EndIf
            
          EndIf

          Select PDF()\Local\Language    ;{ Titel & Messages
            Case "DE", "AT"
              Titel = "Zeichensatz einbetten"
              Error1 = "Schriftart darf auf Grund der Lizenz nicht in PDF eingebettet werden."
              Error2 = "Die Schrift darf nur als Bitmap-Schrift eingebettet werden."
              Error3 = "Die Schriftart darf nicht als Subsetting eingebettet werden."
            Case "FR"
              Titel  = "Intégrer le jeu de caractères"
              Error1 = "La police peut ne pas être incorporée dans le PDF en raison de la licence."
              Error2 = "La police ne peut être intégrée que sous forme de police bitmap."
              Error3 = "La police ne doit pas être intégrée en tant que sous-ensemble."
            Case "ES"
              Titel  = "Incrustar juego de caracteres"
              Error1 = "La fuente no puede estar incrustada en PDF debido a la licencia."
              Error2 = "La fuente sólo se puede incrustar como fuente de mapa de bits."
              Error3 = "La fuente no debe ser incrustada como un subconjunto."
            Case "IT"
              Titel  = "Incorporare il set di caratteri"
              Error1 = "Il carattere potrebbe non essere incorporato nel PDF a causa della licenza."
              Error2 = "Il font può essere incorporato solo come font bitmap."
              Error3 = "Il font non deve essere incorporato come sottoinsieme."
            Default
              Titel  = "Embed character set"
              Error1 = "Font may not be embedded in PDF according to license."
              Error2 = "Font may only be embedded as bitmap font."
              Error3 = "Font may not be embedded as subsetting."
          EndSelect ;}        
          
          If Font\Flag & #TTF_Unembeddable
            PDF()\Error = #ERROR_TTF_UNEMBEDDABLE
            MessageRequester(Titel, Error1 ,#PB_MessageRequester_Warning)
          ElseIf Font\Flag & #TTF_OnlyBitmap
            PDF()\Error = #ERROR_TTF_ONLYBITMAP
            MessageRequester(Titel, Error2 ,#PB_MessageRequester_Warning)
          ElseIf Font\Flag & #TTF_NoSubsetting
            PDF()\Error = #ERROR_TTF_NOSUBSETTING
            MessageRequester(Titel, Error3 ,#PB_MessageRequester_Warning)
          EndIf
          
          ProcedureReturn Font\Name
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.i EmbedJavaScript(ID.i, Script.s, Name.s="EmbeddedJS")
    ; PDF Reference Version 1.6 - Chapter 8.6.4 (Table 8.86)
    Define.i JSNum
    Define.s objJavaScript
    
    If FindMapElement(PDF(), Str(ID))
      
      JSNum = objNew_(#objJavaScript, Name)
      objJavaScript = strObj_(PDF()\objNum)
      objOutDictionary_(EscapeString_(Script), "/S /JavaScript /JS (", ")", #objText)
      
      If PDF()\Names\JavaScript = "" ;{ Create objects, if it is the first entry
        objNew_()
        PDF()\Names\JavaScript = strObj_(PDF()\objNum)             ; <</Names [(name1) obj1 0 R (name2) obj2 0 R]>>
        ;} 
      EndIf

      If PDF()\Catalog\objNames = "" : objNew_(#objNames) : EndIf  ; => PDF()\Catalog\objNames
      
      ProcedureReturn JSNum
    EndIf

  EndProcedure
  
  Procedure.i EmbedJavaScriptFile(ID.i, FileName.s, Name.s="EmbeddedJS") ; TODO: Stream
    ; PDF Reference Version 1.6 - Chapter 8.6.4 (Table 8.86)
    Define.s objJavaScript, Script
    
    If FindMapElement(PDF(), Str(ID))
      
      If ReadFile(#File, FileName)
        
        While Eof(#File) = #False
          Script + ReadString(#File) + #LF$
        Wend
        
        CloseFile(#File)
        
        objNew_()
        objJavaScript = strObj_(PDF()\objNum)
        objOutDictionary_(EscapeString_(Script), "/S /JavaScript /JS (", ")", #objText)
        
        If PDF()\Names\JavaScript = "" ;{ Create objects, if it is the first entry
          objNew_()
          PDF()\Names\JavaScript = strObj_(PDF()\objNum) ; <</Names [(name1) obj1 0 R (name2) obj2 0 R]>>
          ;} 
        EndIf
        
        If PDF()\Catalog\objNames = "" : objNew_(#objNames) : EndIf  ; => PDF()\Catalog\objNames
        
        ProcedureReturn #True
      Else
        PDF()\Error = #ERROR_FILE_READ
      EndIf
      
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure   EnableFooter(ID.i, Flag.i=#True)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\Footer\Flag = Flag
    EndIf
    
  EndProcedure
  
  Procedure   EnableHeader(ID.i, Flag.i=#True)
    
    If FindMapElement(PDF(), Str(ID))
      PDF()\Header\Flag = Flag
    EndIf
    
  EndProcedure
  
  Procedure   EnableTOCNums(ID.i, Flag.i=#True)
    
    If FindMapElement(PDF(), Str(ID))
      
      If Flag
        PDF()\Numbering        = #True
        PDF()\Footer\Numbering = #True 
      Else
        PDF()\Numbering  = #False
      EndIf
      
    EndIf
    
  EndProcedure  
  
  Procedure.s EscapeText(ID.i, Text.s)
    
    If FindMapElement(PDF(), Str(ID))
      ProcedureReturn "(" + EscapeString_(Text) + ")"
    EndIf
    
  EndProcedure 
  
  Procedure   Image(ID.i, FileName.s, X.f=#PB_Default, Y.f=#PB_Default, Width.f=#PB_Default, Height.f=#PB_Default, Link.i=#NoLink)
    Define.i FileLen, Size
    Define   *Memory
 
    If FindMapElement(PDF(), Str(ID))
      
      If X = #PB_Default      : X = PDF()\Page\X  : EndIf
      If Y = #PB_Default      : Y = PDF()\Page\Y  : EndIf
      If Width  = #PB_Default : Width  = 0        : EndIf
      If Height = #PB_Default : Height = 0        : EndIf
      
      If ReadFile(#File, FileName) ;{ Read image file
        FileLen = Lof(#File)
        *Memory = AllocateMemory(FileLen)
        If *Memory
          Size = ReadData(#File, *Memory, FileLen)
        EndIf
        CloseFile(#File)
      EndIf ;}
 
      If *Memory And Size
        Select LCase(GetExtensionPart(FileName))
          Case "png"
            Image_(GetFilePart(FileName), *Memory, Size, #Image_PNG, X, Y, Width, Height, Link)
          Case "jpg", "jpeg", "jfif", "jif", "jpe" 
            Image_(GetFilePart(FileName), *Memory, Size, #Image_JPEG, X, Y, Width, Height, Link)
          Case "jp2", "jpc", "j2k", "jpm", "jpx", "jpg2", "jpeg2000"
            Image_(GetFilePart(FileName), *Memory, Size, #Image_JPEG2000, X, Y, Width, Height, Link)
          Default
            FreeMemory(*Memory)
            PDF()\Error = #ERROR_NOT_A_JPEG_OR_PNG_FILE
            ProcedureReturn #False
        EndSelect
      EndIf
    
    EndIf 

  EndProcedure
  
  Procedure   ImageMemory(ID.i, ImageName.s, *Memory, Size.i, Format.i, X.f=#PB_Default, Y.f=#PB_Default, Width.f=#PB_Default, Height.f=#PB_Default, Link.i=#NoLink)
    
    If FindMapElement(PDF(), Str(ID))
      
      If X = #PB_Default      : X = PDF()\Page\X  : EndIf
      If Y = #PB_Default      : Y = PDF()\Page\Y  : EndIf
      If Width  = #PB_Default : Width  = 0        : EndIf
      If Height = #PB_Default : Height = 0        : EndIf
      
      Image_(ImageName, *Memory, Size, Format, X, Y, Width, Height, Link)
      
    EndIf
    
  EndProcedure
    
  Procedure   InsertTOC(ID.i, Page.i=1, Label.s="", LabelFontSize.i=20, EntryFontSize.i=10, FontFamily.s="Times")
    Define.i StartTOC, Level, strgWidth, i, j, Num, NumTOC
    Define.f Width, Height, PageCellSize
    Define.s Style$, String$, Page$
    Define *Page
    
    PDF()\Numbering = #False
    
    If Label = ""
      Select PDF()\Local\Language
        Case "DE", "AT"
          Label = "Inhaltsverzeichnis"
        Case "FR"
          Label = "Table des matières"
        Case "ES"
          Label = "Table des matières"
        Case "IT"
          Label = "Indice di contenuto"
        Default
          Label = "Table of Contents"
      EndSelect
    EndIf
    
  	AddPage_()
  	
  	StartTOC = PDF()\pageNum
  	
  	SetFont_(FontFamily, "B", LabelFontSize)
    Cell_(0, 5, Label, 0, 1, #CenterAlign)
    Ln_(10)
  	
    ForEach PDF()\TOC()
      
      ;{ level indentation
      Level = PDF()\TOC()\Level
    	If Level > 0
  	    Width = Level * 8
  	    Cell_(Width, 0)
  	  EndIf ;}
  	  
    	If Level = 0 : Style$ = "B" : Else : Style$ = "" : EndIf
    	
    	SetFont_(FontFamily, Style$, EntryFontSize)
    	
    	String$   = PDF()\TOC()\Text
    	strgWidth = GetStringWidth_(String$)

  	  Height = PDF()\Font\Size + 2
  	  
    	Cell_(strgWidth + 2, Height, String$)
  	  
     	; Filling dots
    	SetFont_(FontFamily, "", EntryFontSize)
    	
    	Page$        = Str(PDF()\TOC()\Page)
    	PageCellSize = GetStringWidth_(Page$) + 2
    	
  		Width = PDF()\Page\Width - PDF()\Margin\Left - PDF()\Margin\Right - PageCellSize - (Level * 8) - (strgWidth + 2)
   		Cell_(Width , PDF()\Font\Size + 2, LSet("", Int(Width / GetStringWidth_(".")), "."), 0, 0, "R")
   	  
      ; Page Number
   		Cell_(PageCellSize , PDF()\Font\Size + 2 , Page$, 0, 1, "R")
   		
  	Next
    
  	*Page = SelectElement(PDF()\Pages(), Page)
  	If SelectElement(PDF()\Pages(), PDF()\pageNum)
  	  If *Page
  	    MoveElement(PDF()\Pages(), #PB_List_Before, *Page)
  	  EndIf
  	EndIf
 
  EndProcedure

  Procedure   Ln(ID.i, Height.f=#PB_Default)                          ; [*]
    
    If FindMapElement(PDF(), Str(ID))
      
      Ln_(Height)
      
    EndIf
    
  EndProcedure    
  
  Procedure.s MultiCell(ID.i, Text.s, Width.f, Height.f, Border.i=#False, Align.s="", Fill.i=#False, Indent.i=0, maxLine.i=0) ; [*]
    
    If FindMapElement(PDF(), Str(ID))
      
      ProcedureReturn MultiCell_(Width, Height, Text, Border, Align, Fill, Indent, maxLine) 
      
    EndIf
    
  EndProcedure
  
  Procedure   MultiCellList(ID.i, Text.s, Width.f, Height.f, Border.i=#False, Align.s="J", Fill.i=#False, Char.s=#Bullet$)    ; [*]
    Define.f CharWidth, LastX
    
    If FindMapElement(PDF(), Str(ID))
      
      CharWidth = GetStringWidth_(Char) + PDF()\Margin\Cell * 2           ; Get bullet width including margins
      LastX     = PDF()\Page\X                                            ; Save X
  
      Cell_(CharWidth, Height, Char, #False, #Right, "", Fill)            ; Output bullet
      MultiCell_(Width - CharWidth, Height, Text, Border, Align, Fill, 0) ; Output text
      
      SetX_(LastX) ; Restore X 
      
    EndIf
    
  EndProcedure
  
  Procedure   PlaceText(ID.i, Text.s, X.f=#PB_Default, Y.f=#PB_Default)            ; [*]
    Define.s sStrg, eStrg
    Define.i i, txtLen
    Define   Stream.Memory_Structure
    
    If FindMapElement(PDF(), Str(ID))
      
      If X = #PB_Default : X = PDF()\Page\X  : EndIf
      If Y = #PB_Default : Y = PDF()\Page\Y  : EndIf
      
      If Len(Text) = 0
        ProcedureReturn #False
      EndIf
      
      If PDF()\Color\Flag = #True : sStrg = "q " + PDF()\Color\Text + " " : EndIf
      
      sStrg + "BT " + strF_(X * PDF()\ScaleFactor, 2) + " " + strF_((PDF()\Page\Height - Y) * PDF()\ScaleFactor, 2) + " Td ("
      eStrg + ") Tj ET"
      
      If PDF()\Font\Underline = #True : eStrg + " " + Underline_(X, Y, Text) : EndIf
      
      If PDF()\Color\Flag = #True : eStrg + " Q" : EndIf
      
      If PDF()\Font\Unicode
        objOutPage_(Text, sStrg, eStrg + #LF$, #objUTF16)
      Else
        objOutPage_(EscapeString_(Text), sStrg, eStrg + #LF$)
      EndIf

    EndIf
    
  EndProcedure        
  
  Procedure   Rotate(ID.i, Angle.f, X.f=#PB_Default, Y.f=#PB_Default) ; [*]
    Define.f c, s, cx, cy
    Define.s objStrg = ""
    
    If FindMapElement(PDF(), Str(ID))
      
      If X = #PB_Default : X = PDF()\Page\X : EndIf 
      If Y = #PB_Default : Y = PDF()\Page\Y : EndIf
      
      If PDF()\Page\Angle : objOutPage_("Q" + #LF$) : EndIf
      
      PDF()\Page\Angle = Angle 
      
      If Angle <> 0
        
        Angle = Angle * #PI / 180
        
        c  = Cos(Angle)
        s  = Sin(Angle)
        
        cx = X * PDF()\ScaleFactor
        cy = (PDF()\Page\Height - Y) * PDF()\ScaleFactor
        
        objStrg + "q" + #LF$
        objStrg + strF_(c, 5) + " " + strF_(s, 5) + " " + strF_(-s, 5) + " " + strF_(c, 5) + " " + strF_(cx, 2) + " " + strF_(cy, 2) + " cm" + #LF$
        objStrg + "1 0 0 1 " + strF_(-cx, 2) + " " + strF_(-cy, 2) + " cm" + #LF$
        objOutPage_(objStrg)
        
      EndIf
      
    EndIf
    
  EndProcedure   
  
  Procedure   Save(ID.i, FileName.s)
    
    Close(ID, FileName)
    
  EndProcedure  
  
  Procedure   SubWrite(ID.i, Text.s, Height.f=#PB_Default, SubFontSize.i=12, SubOffSet.f=0, Label.s="", Link.i=#NoLink)
    Define prevFontSize.i, subX.f, subY.f
    
    If FindMapElement(PDF(), Str(ID))
      
      prevFontSize = PDF()\Font\SizePt
  	  
    	SetFontSize_(SubFontSize)
    	
    	SubOffSet = (((SubFontSize - prevFontSize) / PDF()\ScaleFactor) * 0.3) + (SubOffSet / PDF()\ScaleFactor)
    	
    	subX = PDF()\Page\X
    	subY = PDF()\Page\Y
    
    	SetY_(subY - SubOffSet)
    	SetX_(subX)
    	
      Write_(Height, Text, Link, Label)
      
    	subX = PDF()\Page\X
    	subY = PDF()\Page\Y
    	SetY_(subY + SubOffSet)
    	SetX_(subX)
      
    	SetFontSize_(prevFontSize)
    	
    EndIf
  
  EndProcedure      
  
  Procedure.s TruncateCell(ID.i, Text.s, Width.f=#PB_Default, Height.f=#PB_Default, Border.i=#False, Ln.i=#Right, Align.s=#LeftAlign, Fill.i=#False, TruncText.s="...", Label.s="", Link.i=#NoLink)
    Define maxWidth.f, truncLen.i, newText$
    
    If FindMapElement(PDF(), Str(ID))
      
      If Width = 0 Or Width = #PB_Default
        Width = PDF()\Page\Width - PDF()\Margin\Right - PDF()\Page\X
      EndIf
    
      maxWidth = Width - (2 * PDF()\Margin\Cell)
    
      If GetStringWidth_(Text) <= maxWidth
        
        Cell_(Width, Height, Text, Border, Ln, Align, Fill, Link, Label)
        
      Else
        
        truncLen = Len(Text)
        
        Repeat 
          newText$ = Left(Text, truncLen) + TruncText
          If GetStringWidth_(newText$) <= maxWidth : Break : EndIf
          truncLen - 1
        Until truncLen < 0
        
        If truncLen < 1
          newText$ = ""
        Else
          Cell_(Width, Height, newText$, Border, Ln, Align, Fill, Link, Label)
          ProcedureReturn Right(Text, Len(Text) - truncLen)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn ""
  EndProcedure    
  
  Procedure   Write(ID.i, Text.s, Height.f=#PB_Default, Label.s="", Link.i=#NoLink)
    
    If FindMapElement(PDF(), Str(ID))
      
      Write_(Height, Text, Link, Label)
      
    EndIf
    
  EndProcedure  
  
  ;- ----- Basic Commands -----------------
  
  Procedure.i Create(ID.i, Orientation.s="P", Unit.s="", Format.s="")  ; [*]
    Define objRes.i
    
    If ID = #PB_Any
      ID = 1 : While FindMapElement(PDF(), Str(ID)) : ID + 1 : Wend
    EndIf
    
    If AddMapElement(PDF(), Str(ID))
      
      PDF()\Local\Language          = #DefaultLanguage
      PDF()\Local\TimeZoneOffset    = #DefaultTimeZoneOffset
      PDF()\Local\DecimalPoint      = #DefaultDecimalPoint
      
      If Orientation = "" : Orientation = "P"           : EndIf
      If Unit        = "" : Unit = #DefaultUnit         : EndIf
      If Format      = "" : Format = #DefaultPageFormat : EndIf
      
      PDF()\pageNum     = 0
      PDF()\Page\TOCNum = 1 ; ?
      PDF()\Error       = #False
      
     ;{ Scale factor
      Select Unit
        Case "pt"
          PDF()\ScaleFactor = 1
        Case "mm"
          PDF()\ScaleFactor = 72 / 25.4
        Case "cm"
          PDF()\ScaleFactor = 72 / 2.54
        Case "in"
          PDF()\ScaleFactor = 72
        Default
          PDF()\ScaleFactor = 72 / 25.4
      EndSelect ;}
      
      ;{ Font
      PDF()\Font\Family = ""
      PDF()\Font\Style  = ""
      PDF()\Font\SizePt = 12
      ;}
      
      ;{ Colors
      PDF()\Color\Draw = "0 G"
      PDF()\Color\Fill = "0 g"
      PDF()\Color\Text = "0 g"
      ;}
      
      ;{ Document page format
      PDF()\Document\ptWidth     = ValF(StringField(Format, 1, ","))
      PDF()\Document\ptHeight    = ValF(StringField(Format, 2, ","))  
      PDF()\Document\Width       = PDF()\Document\ptWidth  / PDF()\ScaleFactor
      PDF()\Document\Height      = PDF()\Document\ptHeight / PDF()\ScaleFactor
      PDF()\Document\Orientation = Left(UCase(Orientation), 1)
      ;}

      ;{ Default page format & orientation
      PDF()\Page\Orientation = PDF()\Document\Orientation
      If PDF()\Page\Orientation = "L"
        PDF()\Page\ptWidth  = PDF()\Document\ptHeight
        PDF()\Page\ptHeight = PDF()\Document\ptWidth
      Else
        PDF()\Page\ptWidth  = PDF()\Document\ptWidth
        PDF()\Page\ptHeight = PDF()\Document\ptHeight
      EndIf
      PDF()\Page\Width  = PDF()\Page\ptWidth  / PDF()\ScaleFactor
      PDF()\Page\Height = PDF()\Page\ptHeight / PDF()\ScaleFactor
      ;}
      
      PDF()\LineWidth = 0.567 / PDF()\ScaleFactor    ; Line width (0.2 mm)
      
      ;{ Margins
      PDF()\Margin\Left  = 28.35 / PDF()\ScaleFactor ; Page margins (1 cm)
      PDF()\Margin\Right = PDF()\Margin\Left
      PDF()\Margin\Top   = PDF()\Margin\Left
      PDF()\Margin\Cell  = PDF()\Margin\Left / 10    ; Interior cell margin (1 mm)
      ;}
      
      PDF()\PageBreak\Auto    = #True
      PDF()\PageBreak\Margin  = PDF()\Margin\Left * 2
      PDF()\PageBreak\Trigger = PDF()\Page\Height - PDF()\PageBreak\Margin
      
      ; ----- Begin document -----

      ; Pages (PageTree)
      objNew_(#objPage)
      PDF()\Catalog\objPages = strObj_(PDF()\objNum) ; 1 0 obj   
      objOutDictionary_("/Type /Pages", #LF$, #LF$)
      
      ; Info
      objNew_()
      PDF()\Trailer\Info = strObj_(PDF()\objNum)
      objOutDictionary_(Trim(#pbPDF_Version), #LF$ + "/Producer (", ")" + #LF$, #objText)
      objOutDictionary_("D:" + FormatDate("%yyyy%mm%dd%hh%ii%ss", Date()), "/CreationDate (", ")" + #LF$, #objText)
      
      ; Root (Catalog)
      objNew_()
      objOutDictionary_("/Type /Catalog" + #LF$ + "/Pages " + PDF()\Catalog\objPages, #LF$, #LF$)
      PDF()\Trailer\Root = strObj_(PDF()\objNum)
      PDF()\Trailer\ID   = StringFingerprint(Str(Date()), #PB_Cipher_MD5, #False, #PB_Ascii)
      PDF()\Catalog\OpenAction\Page = 1
      PDF()\Catalog\OpenAction\Zoom = #PageTop
      
      ; Resources
      objNew_()
      PDF()\objResources = strObj_(PDF()\objNum)
      objOutDictionary_("/ProcSet [/PDF /Text /ImageB /ImageC /ImageI]", #LF$, #LF$)

      ; --------------------------

      ProcedureReturn ID
    EndIf
    
  EndProcedure

  ;{ ===== Basic Fonts - DataSection =====
  DataSection
    
    Zapfdingbats:
      Data.w    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
      Data.w    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 278, 974, 961, 974
      Data.w  980, 719, 789, 790, 791, 690, 960, 939, 549, 855, 911, 933, 911, 945, 974, 755, 846, 762
      Data.w  761, 571, 677, 763, 760, 759, 754, 494, 552, 537, 577, 692, 786, 788, 788, 790, 793, 794
      Data.w  816, 823, 789, 841, 823, 833, 816, 831, 923, 744, 723, 749, 790, 792, 695, 776, 768, 792
      Data.w  759, 707, 708, 682, 701, 826, 815, 789, 789, 707, 687, 696, 689, 786, 787, 713, 791, 785
      Data.w  791, 873, 761, 762, 762, 759, 759, 892, 892, 788, 784, 438, 138, 277, 415, 392, 392, 668
      Data.w  668,   0, 390, 390, 317, 317, 276, 276, 509, 509, 410, 410, 234, 234, 334, 334,   0,   0
      Data.w    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 732
      Data.w  544, 544, 910, 667, 760, 760, 776, 595, 694, 626, 788, 788, 788, 788, 788, 788, 788, 788
      Data.w  788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788
      Data.w  788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 788, 894, 838,1016, 458
      Data.w  748, 924, 748, 918, 927, 928, 928, 834, 873, 828, 924, 924, 917, 930, 931, 463, 883, 836
      Data.w  836, 867, 867, 696, 696, 874,   0, 874, 760, 946, 771, 865, 771, 888, 967, 888, 831, 873
      Data.w  927, 970, 918,   0
      
    Helvetica:
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 355, 556
      Data.w  556, 889, 667, 191, 333, 333, 389, 584, 278, 333, 278, 278, 556, 556, 556, 556, 556, 556
      Data.w  556, 556, 556, 556, 278, 278, 584, 584, 584, 556,1015, 667, 667, 722, 722, 667, 611, 778
      Data.w  722, 278, 500, 667, 556, 833, 722, 778, 667, 778, 722, 667, 611, 722, 667, 944, 667, 667
      Data.w  611, 278, 278, 278, 469, 556, 333, 556, 556, 500, 556, 556, 278, 556, 556, 222, 222, 500
      Data.w  222, 833, 556, 556, 556, 556, 333, 500, 278, 556, 500, 722, 500, 500, 500, 334, 260, 334
      Data.w  584, 350, 556, 350, 222, 556, 333,1000, 556, 556, 333,1000, 667, 333,1000, 350, 611, 350
      Data.w  350, 222, 222, 333, 333, 350, 556,1000, 333,1000, 500, 333, 944, 350, 500, 667, 278, 333
      Data.w  556, 556, 556, 556, 260, 556, 333, 737, 370, 556, 584, 333, 737, 333, 400, 584, 333, 333
      Data.w  333, 556, 537, 278, 333, 333, 365, 556, 834, 834, 834, 611, 667, 667, 667, 667, 667, 667
      Data.w 1000, 722, 667, 667, 667, 667, 278, 278, 278, 278, 722, 722, 778, 778, 778, 778, 778, 584
      Data.w  778, 722, 722, 722, 722, 667, 667, 611, 556, 556, 556, 556, 556, 556, 889, 500, 556, 556
      Data.w  556, 556, 278, 278, 278, 278, 556, 556, 556, 556, 556, 556, 556, 584, 611, 556, 556, 556
      Data.w  556, 500, 556, 500
      
    HelveticaB:
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 333, 474, 556
      Data.w  556, 889, 722, 238, 333, 333, 389, 584, 278, 333, 278, 278, 556, 556, 556, 556, 556, 556
      Data.w  556, 556, 556, 556, 333, 333, 584, 584, 584, 611, 975, 722, 722, 722, 722, 667, 611, 778
      Data.w  722, 278, 556, 722, 611, 833, 722, 778, 667, 778, 722, 667, 611, 722, 667, 944, 667, 667
      Data.w  611, 333, 278, 333, 584, 556, 333, 556, 611, 556, 611, 556, 333, 611, 611, 278, 278, 556
      Data.w  278, 889, 611, 611, 611, 611, 389, 556, 333, 611, 556, 778, 556, 556, 500, 389, 280, 389
      Data.w  584, 350, 556, 350, 278, 556, 500,1000, 556, 556, 333,1000, 667, 333,1000, 350, 611, 350
      Data.w  350, 278, 278, 500, 500, 350, 556,1000, 333,1000, 556, 333, 944, 350, 500, 667, 278, 333
      Data.w  556, 556, 556, 556, 280, 556, 333, 737, 370, 556, 584, 333, 737, 333, 400, 584, 333, 333
      Data.w  333, 611, 556, 278, 333, 333, 365, 556, 834, 834, 834, 611, 722, 722, 722, 722, 722, 722
      Data.w 1000, 722, 667, 667, 667, 667, 278, 278, 278, 278, 722, 722, 778, 778, 778, 778, 778, 584
      Data.w  778, 722, 722, 722, 722, 667, 667, 611, 556, 556, 556, 556, 556, 556, 889, 556, 556, 556
      Data.w  556, 556, 278, 278, 278, 278, 611, 611, 611, 611, 611, 611, 611, 584, 611, 611, 611, 611
      Data.w  611, 556, 611, 556
      
    HelveticaI:
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 355, 556
      Data.w  556, 889, 667, 191, 333, 333, 389, 584, 278, 333, 278, 278, 556, 556, 556, 556, 556, 556
      Data.w  556, 556, 556, 556, 278, 278, 584, 584, 584, 556,1015, 667, 667, 722, 722, 667, 611, 778
      Data.w  722, 278, 500, 667, 556, 833, 722, 778, 667, 778, 722, 667, 611, 722, 667, 944, 677, 677
      Data.w  611, 278, 278, 278, 469, 556, 333, 556, 556, 500, 556, 556, 278, 556, 556, 222, 222, 500
      Data.w  222, 833, 556, 556, 556, 556, 333, 500, 278, 556, 500, 722, 500, 500, 500, 334, 260, 334
      Data.w  584, 350, 556, 350, 222, 556, 333,1000, 556, 556, 333,1000, 667, 333,1000, 350, 611, 350
      Data.w  350, 222, 222, 333, 333, 350, 556,1000, 333,1000, 500, 333, 944, 350, 500, 667, 278, 333
      Data.w  556, 556, 556, 556, 260, 556, 333, 737, 370, 556, 584, 333, 737, 333, 400, 584, 333, 333
      Data.w  333, 556, 537, 278, 333, 333, 365, 556, 834, 834, 834, 611, 667, 667, 667, 667, 667, 667
      Data.w 1000, 722, 667, 667, 667, 667, 278, 278, 278, 278, 722, 722, 778, 778, 778, 778, 778, 584
      Data.w  778, 722, 722, 722, 722, 667, 667, 611, 556, 556, 556, 556, 556, 556, 889, 500, 556, 556
      Data.w  556, 556, 278, 278, 278, 278, 556, 556, 556, 556, 556, 556, 556, 584, 611, 556, 556, 556
      Data.w  556, 500, 556, 500
      
    HelveticaBI:
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278
      Data.w  278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 333, 474, 556
      Data.w  556, 889, 722, 238, 333, 333, 389, 584, 278, 333, 278, 278, 556, 556, 556, 556, 556, 556
      Data.w  556, 556, 556, 556, 333, 333, 584, 584, 584, 611, 975, 722, 722, 722, 722, 667, 611, 778
      Data.w  722, 278, 556, 722, 611, 833, 722, 778, 667, 778, 722, 667, 611, 722, 667, 944, 667, 667
      Data.w  611, 333, 278, 333, 584, 556, 333, 556, 611, 556, 611, 556, 333, 611, 611, 278, 278, 556
      Data.w  278, 889, 611, 611, 611, 611, 389, 556, 333, 611, 556, 778, 556, 556, 500, 389, 280, 389
      Data.w  584, 350, 556, 350, 278, 556, 500,1000, 556, 556, 333,1000, 667, 333,1000, 350, 611, 350
      Data.w  350, 278, 278, 500, 500, 350, 556,1000, 333,1000, 556, 333, 944, 350, 500, 667, 278, 333
      Data.w  556, 556, 556, 556, 280, 556, 333, 737, 370, 556, 584, 333, 737, 333, 400, 584, 333, 333
      Data.w  333, 611, 556, 278, 333, 333, 365, 556, 834, 834, 834, 611, 722, 722, 722, 722, 722, 722
      Data.w 1000, 722, 667, 667, 667, 667, 278, 278, 278, 278, 722, 722, 778, 778, 778, 778, 778, 584
      Data.w  778, 722, 722, 722, 722, 667, 667, 611, 556, 556, 556, 556, 556, 556, 889, 556, 556, 556
      Data.w  556, 556, 278, 278, 278, 278, 611, 611, 611, 611, 611, 611, 611, 584, 611, 611, 611, 611
      Data.w  611, 556, 611, 556
      
    Times:
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 333, 408, 500
      Data.w  500, 833, 778, 180, 333, 333, 500, 564, 250, 333, 250, 278, 500, 500, 500, 500, 500, 500
      Data.w  500, 500, 500, 500, 278, 278, 564, 564, 564, 444, 921, 722, 667, 667, 722, 611, 556, 722
      Data.w  722, 333, 389, 722, 611, 889, 722, 722, 556, 722, 667, 556, 611, 722, 722, 944, 722, 722
      Data.w  611, 333, 278, 333, 469, 500, 333, 444, 500, 444, 500, 444, 333, 500, 500, 278, 278, 500
      Data.w  278, 778, 500, 500, 500, 500, 333, 389, 278, 500, 500, 722, 500, 500, 444, 480, 200, 480
      Data.w  541, 350, 500, 350, 333, 500, 444,1000, 500, 500, 333,1000, 556, 333, 889, 350, 611, 350
      Data.w  350, 333, 333, 444, 444, 350, 500,1000, 333, 980, 389, 333, 722, 350, 444, 722, 250, 333
      Data.w  500, 500, 500, 500, 200, 500, 333, 760, 276, 500, 564, 333, 760, 333, 400, 564, 300, 300
      Data.w  333, 500, 453, 250, 333, 300, 310, 500, 750, 750, 750, 444, 722, 722, 722, 722, 722, 722
      Data.w  889, 667, 611, 611, 611, 611, 333, 333, 333, 333, 722, 722, 722, 722, 722, 722, 722, 564
      Data.w  722, 722, 722, 722, 722, 722, 556, 500, 444, 444, 444, 444, 444, 444, 667, 444, 444, 444
      Data.w  444, 444, 278, 278, 278, 278, 500, 500, 500, 500, 500, 500, 500, 564, 500, 500, 500, 500
      Data.w  500, 500, 500, 500
      
    TimesB:
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 333, 555, 500
      Data.w  500,1000, 833, 278, 333, 333, 500, 570, 250, 333, 250, 278, 500, 500, 500, 500, 500, 500
      Data.w  500, 500, 500, 500, 333, 333, 570, 570, 570, 500, 930, 722, 667, 722, 722, 667, 611, 778
      Data.w  778, 389, 500, 778, 667, 944, 722, 778, 611, 778, 722, 556, 667, 722, 722,1000, 722, 722
      Data.w  667, 333, 278, 333, 581, 500, 333, 500, 556, 444, 556, 444, 333, 500, 556, 278, 333, 556
      Data.w  278, 833, 556, 500, 556, 556, 444, 389, 333, 556, 500, 722, 500, 500, 444, 394, 220, 394
      Data.w  520, 350, 500, 350, 333, 500, 500,1000, 500, 500, 333,1000, 556, 333,1000, 350, 667, 350
      Data.w  350, 333, 333, 500, 500, 350, 500,1000, 333,1000, 389, 333, 722, 350, 444, 722, 250, 333
      Data.w  500, 500, 500, 500, 220, 500, 333, 747, 300, 500, 570, 333, 747, 333, 400, 570, 300, 300
      Data.w  333, 556, 540, 250, 333, 300, 330, 500, 750, 750, 750, 500, 722, 722, 722, 722, 722, 722
      Data.w 1000, 722, 667, 667, 667, 667, 389, 389, 389, 389, 722, 722, 778, 778, 778, 778, 778, 570
      Data.w  778, 722, 722, 722, 722, 722, 611, 556, 500, 500, 500, 500, 500, 500, 722, 444, 444, 444
      Data.w  444, 444, 278, 278, 278, 278, 500, 556, 500, 500, 500, 500, 500, 570, 500, 556, 556, 556
      Data.w  556, 500, 556, 500 
      
    TimesI:
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 333, 420, 500
      Data.w  500, 833, 778, 214, 333, 333, 500, 675, 250, 333, 250, 278, 500, 500, 500, 500, 500, 500
      Data.w  500, 500, 500, 500, 333, 333, 675, 675, 675, 500, 920, 611, 611, 667, 722, 611, 611, 722
      Data.w  722, 333, 444, 667, 556, 833, 667, 722, 611, 722, 611, 500, 556, 722, 611, 833, 611, 556
      Data.w  556, 389, 278, 389, 422, 500, 333, 500, 500, 444, 500, 444, 278, 500, 500, 278, 278, 444
      Data.w  278, 722, 500, 500, 500, 500, 389, 389, 278, 500, 444, 667, 444, 444, 389, 400, 275, 400
      Data.w  541, 350, 500, 350, 333, 500, 556, 889, 500, 500, 333,1000, 500, 333, 944, 350, 556, 350
      Data.w  350, 333, 333, 556, 556, 350, 500, 889, 333, 980, 389, 333, 667, 350, 389, 556, 250, 389
      Data.w  500, 500, 500, 500, 275, 500, 333, 760, 276, 500, 675, 333, 760, 333, 400, 675, 300, 300
      Data.w  333, 500, 523, 250, 333, 300, 310, 500, 750, 750, 750, 500, 611, 611, 611, 611, 611, 611
      Data.w  889, 667, 611, 611, 611, 611, 333, 333, 333, 333, 722, 667, 722, 722, 722, 722, 722, 675
      Data.w  722, 722, 722, 722, 722, 556, 611, 500, 500, 500, 500, 500, 500, 500, 667, 444, 444, 444
      Data.w  444, 444, 278, 278, 278, 278, 500, 500, 500, 500, 500, 500, 500, 675, 500, 500, 500, 500
      Data.w  500, 444, 500, 444
      
    TimesBI:
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 389, 555, 500
      Data.w  500, 833, 778, 278, 333, 333, 500, 570, 250, 333, 250, 278, 500, 500, 500, 500, 500, 500
      Data.w  500, 500, 500, 500, 333, 333, 570, 570, 570, 500, 832, 667, 667, 667, 722, 667, 667, 722
      Data.w  778, 389, 500, 667, 611, 889, 722, 722, 611, 722, 667, 556, 611, 722, 667, 889, 667, 611
      Data.w  611, 333, 278, 333, 570, 500, 333, 500, 500, 444, 500, 444, 333, 500, 556, 278, 278, 500
      Data.w  278, 778, 556, 500, 500, 500, 389, 389, 278, 556, 444, 667, 500, 444, 389, 348, 220, 348
      Data.w  570, 350, 500, 350, 333, 500, 500,1000, 500, 500, 333,1000, 556, 333, 944, 350, 611, 350
      Data.w  350, 333, 333, 500, 500, 350, 500,1000, 333,1000, 389, 333, 722, 350, 389, 611, 250, 389
      Data.w  500, 500, 500, 500, 220, 500, 333, 747, 266, 500, 606, 333, 747, 333, 400, 570, 300, 300
      Data.w  333, 576, 500, 250, 333, 300, 300, 500, 750, 750, 750, 500, 667, 667, 667, 667, 667, 667
      Data.w  944, 667, 667, 667, 667, 667, 389, 389, 389, 389, 722, 722, 722, 722, 722, 722, 722, 570
      Data.w  722, 722, 722, 722, 722, 611, 611, 500, 500, 500, 500, 500, 500, 500, 722, 444, 444, 444
      Data.w  444, 444, 278, 278, 278, 278, 500, 556, 500, 500, 500, 500, 500, 570, 500, 556, 556, 556
      Data.w  556, 444, 500, 444
      
    Symbol:
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250
      Data.w  250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 333, 713, 500
      Data.w  549, 833, 778, 439, 333, 333, 500, 549, 250, 549, 250, 278, 500, 500, 500, 500, 500, 500
      Data.w  500, 500, 500, 500, 278, 278, 549, 549, 549, 444, 549, 722, 667, 722, 612, 611, 763, 603
      Data.w  722, 333, 631, 722, 686, 889, 722, 722, 768, 741, 556, 592, 611, 690, 439, 768, 645, 795
      Data.w  611, 333, 863, 333, 658, 500, 500, 631, 549, 549, 494, 439, 521, 411, 603, 329, 603, 549
      Data.w  549, 576, 521, 549, 549, 521, 549, 603, 439, 576, 713, 686, 493, 686, 494, 480, 200, 480
      Data.w  549,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
      Data.w    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 750, 620
      Data.w  247, 549, 167, 713, 500, 753, 753, 753, 753,1042, 987, 603, 987, 603, 400, 549, 411, 549
      Data.w  549, 713, 494, 460, 549, 549, 549, 549,1000, 603,1000, 658, 823, 686, 795, 987, 768, 768
      Data.w  823, 768, 768, 713, 713, 713, 713, 713, 713, 713, 768, 713, 790, 790, 890, 823, 549, 250
      Data.w  713, 603, 603,1042, 987, 603, 987, 603, 494, 329, 790, 790, 786, 713, 384, 384, 384, 384
      Data.w  384, 384, 494, 494, 494, 494,   0, 329, 274, 686, 686, 686, 384, 384, 384, 384, 384, 384
      Data.w  494, 494, 494,   0
      
  EndDataSection
  ;} =========================================
  
EndModule

;- ===== Examples ============

CompilerIf #PB_Compiler_IsMainFile
  
  #PDF = 1
  
  Define File$ = "pbPDF-Examples.pdf"
  Define.f circleX, circleY, Radius
  Define.i n, i
  Define.s Text = "This is bulleted text. The text is indented and the bullet appears at the first line only."
  
  ; ----- Example Footer -----
  
  Procedure Footer()
    PDF::SetPosY(#PDF, -15)
    PDF::SetFont(#PDF, "Arial", "BI", 9)
    PDF::Cell(#PDF, "Page {p} / {tp}", #PB_Default, 10, 0, 0, PDF::#CenterAlign)
  EndProcedure

  ; ----- Example Table ----- 
  
  Global Dim title.s(4), Dim width.w(4)
  title(0) = "Country" : title(1) = "Capital" : title(2) = "Area (sq km)" : title(3) = "Pop. (thousands)"
  width(0) = 40        : width(1) = 35        : width(2) = 40             : width(3) = 45
  
  Procedure BasicTable()
    Protected tData.s, i, j, Fill, Link
    
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 255, 0, 0)
    PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
    PDF::SetColorRGB(#PDF, PDF::#DrawColor, 128, 0, 0)
    PDF::SetLineThickness(#PDF, 0.3)
    PDF::SetFont(#PDF, "", "B", 11)
    
    For i = 0 To 3
      PDF::Cell(#PDF, title(i), Width(i), 7, #True, 0, PDF::#CenterAlign, #True)
    Next
    
    PDF::Ln(#PDF)
    
    Restore BeginData
    
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 224, 235, 255)
    PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
    PDF::SetFont(#PDF, "")
    
    Fill = #True
    
    For j=1 To 8
      
      Read.s tData
        PDF::Cell(#PDF, tData, Width(0), 6, PDF::#RightBorder + PDF::#LeftBorder, 0, PDF::#LeftAlign,  Fill)
      Read.s tData
        PDF::Cell(#PDF, tData, Width(1), 6, PDF::#RightBorder + PDF::#LeftBorder, 0, PDF::#LeftAlign,  Fill)
      Read.s tData
        PDF::Cell(#PDF, tData, Width(2), 6, PDF::#RightBorder + PDF::#LeftBorder, 0, PDF::#RightAlign, Fill)
      Read.s tData
        If Val(tData) > 10000
          PDF::SetColorRGB(#PDF, PDF::#TextColor, 0, 0, 255)
          Link = PDF::AddLinkURL(#PDF, "www.purebasic.com")
          PDF::SetFont(#PDF, "Arial", "U")
        Else
          Link = -1
        EndIf  
        PDF::Cell(#PDF, tData, Width(3), 6, PDF::#RightBorder + PDF::#LeftBorder, 0, PDF::#RightAlign, Fill, "", Link)
        PDF::Ln(#PDF)
        
      Fill = ~Fill 
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
      PDF::SetFont(#PDF, "Arial")
      
    Next
    
    For i = 0 To 3
      PDF::Cell(#PDF, "", Width(i), 7, PDF::#TopBorder)
    Next 
    
  EndProcedure
  
  ; ========== Create PDF ==========
  
  PDF::SetFooterProcedure(#PDF, @Footer())
  ;PDF::SetAliasTotalPages(#PDF, "{tp}")
  
  If PDF::Create(#PDF)
    
    ;PDF::SetPageCompression(#PDF, #True)
    ;PDF::SetEncryption(#PDF, "Test", "pbPDF")
    
    PDF::EnableFooter(#PDF, #True)

    PDF::SetPageNumbering(#PDF, #True)
    
    ;{ ----- Example: Hello World ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Hello")
    PDF::SetFont(#PDF, "Arial","B", 16)
    PDF::Cell(#PDF, "Hello World!", 40, 10, #True, PDF::#Right, "", #False, "HelloLabel") 
    ;}
    
    ;{ ----- Example: TruncateCell() ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: TruncateCell()", 0, 0)
    PDF::SetFont(#PDF, "Arial", "", 11)
    PDF::Cell(#PDF, "That is a long text to test it.", 35, 6, #True, PDF::#NextLine) 
    PDF::TruncateCell(#PDF, "That is a long text to test it.", 35, 6, #True, PDF::#NextLine) 
    PDF::Ln(#PDF, 5) 
    PDF::Cell(#PDF, "That is a long text to test it.", 43, 6, #True, PDF::#NextLine) 
    PDF::TruncateCell(#PDF, "That is a long text to test it.", 43, 6, #True, PDF::#NextLine) 
    ;}
    
    ;{ ----- Example: Bulleted Text ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Bulleted Text", 0, 0)
    PDF::SetFont(#PDF, "Times", "", 12)
    For n=1 To  3 : PDF::MultiCellList(#PDF, Text + " " + Text, 90, 6, #False, PDF::#Justified, #False) : Next
    For n=1 To  2 : PDF::MultiCellList(#PDF, Text + " " + Text, 90, 6, #False, PDF::#Justified, #False, "-") : Next  
    PDF::SetPosXY(#PDF, 90 + 10 * 2, 10)
    For n=1 To 10 : PDF::MultiCellList(#PDF, Text, 90, 6, #False, PDF::#Justified, #False, Str(n)+")") : Next
    ;}
    
    ;{ ----- Example: Table ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Table", 0, 0)
    PDF::SetFont(#PDF, "Arial","",14)
    BasicTable()
    ;}
    
    ;{ ----- Example: MaxLine -----
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: MaxLine", 0, 0)
    For i = 1 To 18
      Text$ + "all work and no play makes jack a dull boy "
    Next
    PDF::DrawRectangle(#PDF, 20, 20, 100, 100)
    PDF::DrawRectangle(#PDF, 80, 20,  40,  40)
    PDF::DrawRectangle(#PDF, 20, 80,  40,  40)
    PDF::SetPosXY(#PDF, 20, 20)
    PDF::SetFont(#PDF, "Helvetica", "", 10)
    Text$ = PDF::MultiCell(#PDF, Text$,  60, 5, #False, PDF::#Justified, 0, 0, 8)
    Text$ = PDF::MultiCell(#PDF, Text$, 100, 5, #False, PDF::#Justified, 0, 0, 4)
    PDF::SetPosX(#PDF, 60)
    Text$ = PDF::MultiCell(#PDF, Text$,  60, 5, #False, PDF::#Justified, 0, 0, 8)
    ;}
    
    ;{ ----- Example: RoundRectangle ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: RoundRectangle", 0, 0)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 120, 120, 255)
    PDF::DrawRoundedRectangle(#PDF, 20,  20, 150, 50, 25, PDF::#DrawAndFill)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 120, 255, 120)
    PDF::DrawRoundedRectangle(#PDF, 20,  80, 150, 50,  5, PDF::#DrawAndFill)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 255, 120, 120)
    PDF::DrawRoundedRectangle(#PDF, 20, 140, 150, 50, 10, PDF::#DrawAndFill)
    ;}
    
    ;{ ----- Example: Geometric Shapes ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Geometric Shapes", 0, 0)
    PDF::DrawEllipse(#PDF, 100, 50, 30, 20)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 255, 255, 0)
    PDF::DrawCircle(#PDF, 110, 47, 7, PDF::#FillOnly)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 255, 120, 120)
    PDF::DrawTriangle(#PDF, 20, 120, 120, 120, 20, 220, PDF::#DrawAndFill)
    PDF::DrawRectangle(#PDF, 100, 190, 80, 60)
    ;}    
    
    ;{ ----- Example: Sector -----
    circleX = 105 : circleY = 55 : Radius = 40
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Sector", 0, 0)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 120, 120, 255)
    PDF::DrawSector(#PDF, circleX, circleY, Radius,  20, 120)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 120, 255, 120)
    PDF::DrawSector(#PDF, circleX, circleY, Radius, 120, 250)
    PDF::SetColorRGB(#PDF, PDF::#FillColor, 255, 120, 120)
    PDF::DrawSector(#PDF, circleX, circleY, Radius, 250,  20)
    ;}
    
    ;{ ----- Example: Rotating Text ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Rotating Text", 0, 0)
    PDF::AddGotoLabel(#PDF, "HelloLabel")
    PDF::SetFont(#PDF, "Arial", "", 40)
    PDF::Rotate(#PDF, 45, 100, 60) 
    PDF::PlaceText(#PDF, "Hello!", 100, 60) 
    PDF::Rotate(#PDF, 0)
    ;} 
    
    ;{ ----- Example: Grid ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Grid", 0, 0)
    PDF::DrawGrid(#PDF)
    ;}
    
    CompilerIf PDF::#Enable_DrawingCommands
      ;{ ----- Example: Dash -----
      PDF::AddPage(#PDF)
      PDF::BookMark(#PDF, "Example: Dash")
      PDF::SetLineThickness(#PDF, 0.1)
      PDF::SetDashedLine(#PDF, 5, 5); //5mm on, 5mm off
      PDF::DrawLine(#PDF, 20, 20, 189, 20)
      PDF::SetLineThickness(#PDF, 0.5)
      PDF::DrawLine(#PDF, 20, 25, 189, 25)
      PDF::SetLineThickness(#PDF, 0.8)
      PDF::SetDashedLine(#PDF, 4, 2); //4mm on, 2mm off
      PDF::DrawRectangle(#PDF, 20, 30, 169, 20)
      PDF::SetDashedLine(#PDF, 0,0); //restore no dash
      PDF::DrawLine(#PDF, 20, 55, 189, 55)
      ;}
    CompilerEndIf    
    
    CompilerIf PDF::#Enable_TransformCommands And PDF::#Enable_DrawingCommands
      
      ;  ----- Example: Transform ----- 
      PDF::AddPage(#PDF)
      PDF::BookMark(#PDF, "Example: Transform")
      PDF::SetFont(#PDF, "Arial", "", 12)
    
      ; ----- Scaling -----
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 200)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 200)
      PDF::DrawRectangle(#PDF, 50, 20, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Scale", 50, 19)
      ; Scale by 150% centered by (50, 30) which is the lower left corner of the rectangle
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 0)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
      PDF::StartTransform(#PDF)
      PDF::Scale(#PDF, 150, 50, 30)
      PDF::DrawRectangle(#PDF, 50, 20, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Scale", 50, 19)
      PDF::StopTransform(#PDF)

      ; --..- Translation -..--
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 200)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 200)
      PDF::DrawRectangle(#PDF, 125, 20, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF,"Translate", 125, 19)
      ; Translate 20 to the right, 15 to the bottom
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 0)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
      PDF::StartTransform(#PDF)
      PDF::Translate(#PDF, 20, 15)
      PDF::DrawRectangle(#PDF, 125, 20, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Translate", 125, 19)
      PDF::StopTransform(#PDF)

      ; ----- Rotation -----
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 200)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 200)
      PDF::DrawRectangle(#PDF, 50, 50, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Rotate", 50, 49)
      ; Rotate 20 degrees counter-clockwise centered by (50, 60) which is the lower left corner of the rectangle
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 0)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
      PDF::StartTransform(#PDF)
      PDF::Rotate(#PDF, 20, 50, 60)
      PDF::DrawRectangle(#PDF, 50, 50, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Rotate", 50, 49)
      PDF::StopTransform(#PDF)

      ; ----- Skewing -----
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 200)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 200)
      PDF::DrawRectangle(#PDF, 125, 50, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Skew", 125, 49)
      ; Skew 30 degrees along the x-axis centered by (125,60) which is the lower left corner of the rectangle
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 0)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
      PDF::StartTransform(#PDF)
      PDF::SkewHorizontal(#PDF, 30, 125, 60)
      PDF::DrawRectangle(#PDF, 125, 50, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "Skew", 125, 49)
      PDF::StopTransform(#PDF)

      ; ----- Mirroring vertically -----
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 200)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 200)
      PDF::DrawRectangle(#PDF, 125, 80, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "MirrorV", 125, 79)
      ; Mrror vertically with axis of reflection at y-position 90 (bottom side of the rectangle)
      PDF::SetColorRGB(#PDF, PDF::#DrawColor, 0)
      PDF::SetColorRGB(#PDF, PDF::#TextColor, 0)
      PDF::StartTransform(#PDF)
      PDF::MirrorVertical(#PDF, 90)
      PDF::DrawRectangle(#PDF, 125, 80, 40, 10, PDF::#DrawOnly)
      PDF::PlaceText(#PDF, "MirrorV", 125, 79)
      PDF::StopTransform(#PDF)
 
    CompilerEndIf   
    
    ;{ ----- Example: Subwrite ----- 
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Subwrite")
    PDF::SetFont(#PDF, "Arial", "B", 12)
    
    PDF::Write(#PDF, "Hello World!", 5)
    PDF::SetPosX(#PDF, 100)
    PDF::Write(#PDF, "This is standard text." + #CR$, 5)
    PDF::Ln(#PDF, 12)
    
    PDF::SubWrite(#PDF, "H", 10, 33)
    PDF::Write(#PDF, "ello World!", 10)
    PDF::SetPosX(#PDF, 100)
    PDF::Write(#PDF, "This is text with a capital first letter." + #CR$, 10)
    PDF::Ln(#PDF, 12)
    
    PDF::SubWrite(#PDF, "Y", 5, 7)
    PDF::Write(#PDF, "ou can also begin the sentence with a small letter. And word wrap also works if the line is too long!", 5)
    PDF::SetPosX(#PDF, 100)
    PDF::Write(#PDF, "This is text with a small first letter." + #CR$, 5)
    PDF::Ln(#PDF, 12)
    
    PDF::Write(#PDF, "The world has a lot of km", 5)
    PDF::SubWrite(#PDF, "2", 5, 6, 4)
    PDF::SetPosX(#PDF, 100)
    PDF::Write(#PDF, "This is text with a superscripted letter." + #CR$, 5)
    PDF::Ln(#PDF, 12)
    
    PDF::Write(#PDF, "The world has a lot of H", 5)
    PDF::SubWrite(#PDF, "2", 5, 6, -3)
    PDF::Write(#PDF, "O", 5)
    PDF::SetPosX(#PDF, 100)
    PDF::Write(#PDF, "This is text with a subscripted letter." + #CR$, 5)
    ;}    
    
    ;{ ----- Example: Table of Contents -----
    PDF::AddPage(#PDF)
    PDF::BookMark(#PDF, "Example: Table of Contents", #False, #PB_Default, 14)
    PDF::SetFont(#PDF, "Times","", 12)
    PDF::EnableTOCNums(#PDF, #True)
    PDF::AddEntryTOC(#PDF, "TOC 1 ")
    PDF::Cell(#PDF, "TOC 1 ", 0, 5, #False, PDF::#NextLine, PDF::#LeftAlign)
    PDF::AddEntryTOC(#PDF, "TOC 1.1 ", 1)
    PDF::Cell(#PDF, "TOC 1.1", 0, 5, #False, PDF::#NextLine, PDF::#LeftAlign)
    PDF::AddEntryTOC(#PDF, "TOC 2 ")
    For i=3 To 10
      PDF::Cell(#PDF, "TOC " + Str(i), 0, 5, #False, PDF::#NextLine, PDF::#LeftAlign)
    	PDF::AddEntryTOC(#PDF, "TOC " + Str(i) + " ")
    Next
    PDF::EnableTOCNums(#PDF, #False)
    PDF::InsertTOC(#PDF, 14)
    ;}
    
    PDF::Close(#PDF, File$)
    
    RunProgram(File$)
  EndIf
  
  DataSection
    begindata:
      Data.s "Austria","Vienna","83859","8075"
      Data.s "Belgium","Brussels","30518","10192"
      Data.s "Denmark","Copenhagen","43094","5295"
      Data.s "Finland","Helsinki","304529","5147"
      Data.s "France","Paris","543965","58728"
      Data.s "Germany","Berlin","357022","82057"
      Data.s "Greece","Athens","131625","10511"
      Data.s "Ireland","Dublin","70723","3694"
  EndDataSection

CompilerEndIf 

;- ========================
