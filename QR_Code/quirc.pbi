;   Description: Recognizes QR codes and decodes the string they contain
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=76669
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; ISC License
; 
; quirc -- QR-code recognition library
; https://github.com/dlbeer/quirc
; Copyright (c) 2010-2012 Daniel Beer <dlbeer@gmail.com>
;
; Copyright (c) 2021 infratec (Converted to PB)
; 
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted, provided that the above
; copyright notice and this permission notice appear in all copies.
; 
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

; 2021-02-02 now it is a module to avoid naming conflicts
; 2021-02-01 optimimized DataSection for binary size of the executable
; 2021-01-31 modified ImageToGrayScaleBuffer() for images with alpha channel


DeclareModule Quirc
  Declare.s QRCodeDecode(Image.i)
EndDeclareModule


Module Quirc
  
  CompilerIf #PB_Compiler_IsMainFile
    EnableExplicit
  CompilerEndIf
  
  ; PB Help
  Structure AsciiArrayStructure
    v.a[0]
  EndStructure
  
  Structure UnicodeArrayStructure
    v.u[0]
  EndStructure
  
  Structure IntegerArrayStructure
    v.i[0]
  EndStructure
  
  Structure DoubleArrayStructure
    v.d[0]
  EndStructure
  
  
  ; This enum describes the various decoder errors which may occur.
  Enumeration
    #QUIRC_SUCCESS = 0
    #QUIRC_ERROR_INVALID_GRID_SIZE
    #QUIRC_ERROR_INVALID_VERSION
    #QUIRC_ERROR_FORMAT_ECC
    #QUIRC_ERROR_DATA_ECC
    #QUIRC_ERROR_UNKNOWN_DATA_TYPE
    #QUIRC_ERROR_DATA_OVERFLOW
    #QUIRC_ERROR_DATA_UNDERFLOW
  EndEnumeration
  
  
  ; Limits on the maximum size of QR-codes And their content.
  #QUIRC_MAX_VERSION = 40
  #QUIRC_MAX_GRID_SIZE = (#QUIRC_MAX_VERSION * 4 + 17)
  #QUIRC_MAX_BITMAP = (((#QUIRC_MAX_GRID_SIZE * #QUIRC_MAX_GRID_SIZE) + 7) / 8)
  #QUIRC_MAX_PAYLOAD = 8896
  
  ; QR-code ECC types.
  #QUIRC_ECC_LEVEL_M = 0
  #QUIRC_ECC_LEVEL_L = 1
  #QUIRC_ECC_LEVEL_H = 2
  #QUIRC_ECC_LEVEL_Q = 3
  
  ; QR-code Data types.
  #QUIRC_DATA_TYPE_NUMERIC = 1
  #QUIRC_DATA_TYPE_ALPHA = 2
  #QUIRC_DATA_TYPE_BYTE = 4
  #QUIRC_DATA_TYPE_KANJI = 8
  
  ; Common character encodings
  #QUIRC_ECI_ISO_8859_1 = 1
  #QUIRC_ECI_IBM437 = 2
  #QUIRC_ECI_ISO_8859_2 = 4
  #QUIRC_ECI_ISO_8859_3 = 5
  #QUIRC_ECI_ISO_8859_4 = 6
  #QUIRC_ECI_ISO_8859_5 = 7
  #QUIRC_ECI_ISO_8859_6 = 8
  #QUIRC_ECI_ISO_8859_7 = 9
  #QUIRC_ECI_ISO_8859_8 = 10
  #QUIRC_ECI_ISO_8859_9 = 11
  #QUIRC_ECI_WINDOWS_874 = 13
  #QUIRC_ECI_ISO_8859_13 = 15
  #QUIRC_ECI_ISO_8859_15 = 17
  #QUIRC_ECI_SHIFT_JIS = 20
  #QUIRC_ECI_UTF_8 = 26
  
  
  #QUIRC_PIXEL_WHITE = 0
  #QUIRC_PIXEL_BLACK = 1
  #QUIRC_PIXEL_REGION = 2
  
  CompilerIf Not Defined(QUIRC_MAX_REGIONS, #PB_Constant)
    #QUIRC_MAX_REGIONS = 254
  CompilerEndIf
  #QUIRC_MAX_CAPSTONES = 32
  #QUIRC_MAX_GRIDS = 8
  #QUIRC_PERSPECTIVE_PARAMS = 8
  
  #UINT8_MAX = $FF
  #UINT16_MAX = $FFFF
  #INT_MAX = $7FFF
  
  CompilerIf #QUIRC_MAX_REGIONS < #UINT8_MAX
    #QUIRC_PIXEL_ALIAS_IMAGE = #True
    Macro quirc_pixel_ptr
      Ascii
    EndMacro
    Macro quirc_pixel_type
      a
    EndMacro
    Macro quirc_pixel_array
      AsciiArrayStructure
    EndMacro
  CompilerElseIf #QUIRC_MAX_REGIONS < #UINT16_MAX
    #QUIRC_PIXEL_ALIAS_IMAGE = #False
    Macro quirc_pixel_ptr
      Unicode
    EndMacro
    Macro quirc_pixel_type
      u
    EndMacro
    Macro quirc_pixel_array
      UnicodeArrayStructure
    EndMacro
  CompilerElse
    CompilerError "QUIRC_MAX_REGIONS > 65534 is not supported"
  CompilerEndIf
  
  
  
  
  
  Structure quirc_point
    x.i
    y.i
  EndStructure
  
  
  ; PB Help
  Structure quirc_pointArrayStructure
    v.quirc_point[0]
  EndStructure
  
  
  ; This Structure is used To Return information about detected QR codes
  ; in the input image.
  Structure quirc_code
    ; The four corners of the QR-code, from top left, clockwise
    corners.quirc_point[4]
    
    ; The number of cells across in the QR-code. The cell bitmap
    ; is a bitmask giving the actual values of cells. If the cell
    ; at (x, y) is black, then the following bit is set:
    ;
    ;     cell_bitmap(i >> 3) & (1 << (i & 7))
    ;
    ; where i = (y * size) + x.
    size.i
    cell_bitmap.a[#QUIRC_MAX_BITMAP]
  EndStructure
  
  ; This Structure holds the decoded QR-code Data
  Structure quirc_data
    ; Various parameters of the QR-code. These can mostly be
    ; ignored If you only care about the Data.
    version.i
    ecc_level.i
    mask.i
    
    ; This field is the highest-valued Data type found in the QR
    ; code.
    data_type.i
    
    ; Data payload. For the Kanji datatype, payload is encoded As
    ; Shift-JIS. For all other datatypes, payload is ASCII text.
    payload.a[#QUIRC_MAX_PAYLOAD]
    payload_len.i
    
    ; ECI assignment number
    eci.l
  EndStructure
  
  
  Structure quirc_region
    seed.quirc_point
    count.i
    capstone.i
  EndStructure
  
  Structure quirc_capstone
    ring.i
    stone.i
    
    corners.quirc_point[4]
    center.quirc_point
    c.d[#QUIRC_PERSPECTIVE_PARAMS]
    
    qr_grid.i
  EndStructure
  
  Structure quirc_grid
    ; Capstone indices
    caps.i[3]
    
    ; Alignment pattern region And corner
    align_region.i
    align.quirc_point
    
    ; Timing pattern endpoints
    tpep.quirc_point[3]
    hscan.i
    vscan.i
    
    ; Grid size And perspective transform
    grid_size.i
    c.d[#QUIRC_PERSPECTIVE_PARAMS]
  EndStructure
  
  Structure quirc
    *image.Ascii
    *pixels.quirc_pixel_array
    w.i
    h.i
    
    num_regions.i
    regions.quirc_region[#QUIRC_MAX_REGIONS]
    
    num_capstones.i
    capstones.quirc_capstone[#QUIRC_MAX_CAPSTONES]
    
    num_grids.i
    grids.quirc_grid[#QUIRC_MAX_GRIDS]
  EndStructure
  
  
  
  ; QR-code version information database
  
  #QUIRC_MAX_VERSION = 40
  #QUIRC_MAX_ALIGNMENT = 7
  
  Structure quirc_rs_params
    bs.a  ; Small block size
    dw.a  ; Small data words
    ns.a  ; Number of small blocks
  EndStructure
  
  Structure quirc_version_info
    data_bytes.u
    apat.a[#QUIRC_MAX_ALIGNMENT]
    ecc.quirc_rs_params[4]
  EndStructure
  
  
  
  ; version_db.c
  
  DataSection
    quirc_version_db_0:
    Data.u 0
    Data.a 0, 0, 0, 0, 0, 0, 0
    Data.a 0, 0, 0
    Data.a 0, 0, 0
    Data.a 0, 0, 0
    Data.a 0, 0, 0
    
    quirc_version_db_1:
    Data.u 26
    Data.a 0, 0, 0, 0, 0, 0, 0
    Data.a 26, 16, 1
    Data.a 26, 19, 1
    Data.a 26, 9, 1
    Data.a 26, 13, 1
    
    quirc_version_db_2:
    Data.u 44
    Data.a 6, 18, 0, 0, 0, 0, 0
    Data.a 44, 28, 1
    Data.a 44, 34, 1
    Data.a 44, 16, 1
    Data.a 44, 22, 1
    
    quirc_version_db_3:
    Data.u 70
    Data.a 6, 22, 0, 0, 0, 0, 0
    Data.a 70, 44, 1
    Data.a 70, 55, 1
    Data.a 35, 13, 2
    Data.a 35, 17, 2
    
    quirc_version_db_4:
    Data.u 100
    Data.a 6, 26, 0, 0, 0, 0, 0
    Data.a 50, 32, 2
    Data.a 100, 80, 1
    Data.a 25, 9, 4
    Data.a 50, 24, 2
    
    quirc_version_db_5:
    Data.u 134
    Data.a 6, 30, 0, 0, 0, 0, 0
    Data.a 67, 43, 2
    Data.a 134, 108, 1
    Data.a 33, 11, 2
    Data.a 33, 15, 2
    
    quirc_version_db_6:
    Data.u 172
    Data.a 6, 34, 0, 0, 0, 0, 0
    Data.a 43, 27, 4
    Data.a 86, 68, 2
    Data.a 43, 15, 4
    Data.a 43, 19, 4
    
    quirc_version_db_7:
    Data.u 196
    Data.a 6, 22, 38, 0, 0, 0, 0
    Data.a 49, 31, 4
    Data.a 98, 78, 2
    Data.a 39, 13, 4
    Data.a 32, 14, 2
    
    quirc_version_db_8:
    Data.u 242
    Data.a 6, 24, 42, 0, 0, 0, 0
    Data.a 60, 38, 2
    Data.a 121, 97, 2
    Data.a 40, 14, 4
    Data.a 40, 18, 4
    
    quirc_version_db_9:
    Data.u 292
    Data.a 6, 22, 46, 0, 0, 0, 0
    Data.a 58, 36, 3
    Data.a 146, 116, 2
    Data.a 36, 12, 4
    Data.a 36, 16, 4
    
    quirc_version_db_10:
    Data.u 346
    Data.a 6, 28, 50, 0, 0, 0, 0
    Data.a 69, 43, 4
    Data.a 86, 68, 2
    Data.a 43, 15, 6
    Data.a 43, 19, 6
    
    quirc_version_db_11:
    Data.u 404
    Data.a 6, 30, 54, 0, 0, 0, 0
    Data.a 80, 50, 1
    Data.a 101, 81, 4
    Data.a 36, 12, 3
    Data.a 50, 22, 4
    
    quirc_version_db_12:
    Data.u 466
    Data.a 6, 32, 58, 0, 0, 0, 0
    Data.a 58, 36, 6
    Data.a 116, 92, 2
    Data.a 42, 14, 7
    Data.a 46, 20, 4
    
    quirc_version_db_13:
    Data.u 532
    Data.a 6, 34, 62, 0, 0, 0, 0
    Data.a 59, 37, 8
    Data.a 133, 107, 4
    Data.a 33, 11, 12
    Data.a 44, 20, 8
    
    quirc_version_db_14:
    Data.u 581
    Data.a 6, 26, 46, 66, 0, 0, 0
    Data.a 64, 40, 4
    Data.a 145, 115, 3
    Data.a 36, 12, 11
    Data.a 36, 16, 11
    
    quirc_version_db_15:
    Data.u 655
    Data.a 6, 26, 48, 70, 0, 0, 0
    Data.a 65, 41, 5
    Data.a 109, 87, 5
    Data.a 36, 12, 11
    Data.a 54, 24, 5
    
    quirc_version_db_16:
    Data.u 733
    Data.a 6, 26, 50, 74, 0, 0, 0
    Data.a 73, 45, 7
    Data.a 122, 98, 5
    Data.a 45, 15, 3
    Data.a 43, 19, 15
    
    quirc_version_db_17:
    Data.u 815
    Data.a 6, 30, 54, 78, 0, 0, 0
    Data.a 74, 46, 10
    Data.a 135, 107, 1
    Data.a 42, 14, 2
    Data.a 50, 22, 1
    
    quirc_version_db_18:
    Data.u 901
    Data.a 6, 30, 56, 82, 0, 0, 0
    Data.a 69, 43, 9
    Data.a 150, 120, 5
    Data.a 42, 14, 2
    Data.a 50, 22, 17
    
    quirc_version_db_19:
    Data.u 991
    Data.a 6, 30, 58, 86, 0, 0, 0
    Data.a 70, 44, 3
    Data.a 141, 113, 3
    Data.a 39, 13, 9
    Data.a 47, 21, 17
    
    quirc_version_db_20:
    Data.u 1085
    Data.a 6, 34, 62, 90, 0, 0, 0
    Data.a 67, 41, 3
    Data.a 135, 107, 3
    Data.a 43, 15, 15
    Data.a 54, 24, 15
    
    quirc_version_db_21:
    Data.u 1156
    Data.a 6, 28, 50, 72, 92, 0, 0
    Data.a 68, 42, 17
    Data.a 144, 116, 4
    Data.a 46, 16, 19
    Data.a 50, 22, 17
    
    quirc_version_db_22:
    Data.u 1258
    Data.a 6, 26, 50, 74, 98, 0, 0
    Data.a 74, 46, 17
    Data.a 139, 111, 2
    Data.a 37, 13, 34
    Data.a 54, 24, 7
    
    quirc_version_db_23:
    Data.u 1364
    Data.a 6, 30, 54, 78, 102, 0, 0
    Data.a 75, 47, 4
    Data.a 151, 121, 4
    Data.a 45, 15, 16
    Data.a 54, 24, 11
    
    quirc_version_db_24:
    Data.u 1474
    Data.a 6, 28, 54, 80, 106, 0, 0
    Data.a 73, 45, 6
    Data.a 147, 117, 6
    Data.a 46, 16, 30
    Data.a 54, 24, 11
    
    quirc_version_db_25:
    Data.u 1588
    Data.a 6, 32, 58, 84, 110, 0, 0
    Data.a 75, 47, 8
    Data.a 132, 106, 8
    Data.a 45, 15, 22
    Data.a 54, 24, 7
    
    quirc_version_db_26:
    Data.u 1706
    Data.a 6, 30, 58, 86, 114, 0, 0
    Data.a 74, 46, 19
    Data.a 142, 114, 10
    Data.a 46, 16, 33
    Data.a 50, 22, 28
    
    quirc_version_db_27:
    Data.u 1828
    Data.a 6, 34, 62, 90, 118, 0, 0
    Data.a 73, 45, 22
    Data.a 152, 122, 8
    Data.a 45, 15, 12
    Data.a 53, 23, 8
    
    quirc_version_db_28:
    Data.u 1921
    Data.a 6, 26, 50, 74, 98, 122, 0
    Data.a 73, 45, 3
    Data.a 147, 117, 3
    Data.a 45, 15, 11
    Data.a 54, 24, 4
    
    quirc_version_db_29:
    Data.u 2051
    Data.a 6, 30, 54, 78, 102, 126, 0
    Data.a 73, 45, 21
    Data.a 146, 116, 7
    Data.a 45, 15, 19
    Data.a 53, 23, 1
    
    quirc_version_db_30:
    Data.u 2185
    Data.a 6, 26, 52, 78, 104, 130, 0
    Data.a 75, 47, 19
    Data.a 145, 115, 5
    Data.a 45, 15, 23
    Data.a 54, 24, 15
    
    quirc_version_db_31:
    Data.u 2323
    Data.a 6, 30, 56, 82, 108, 134, 0
    Data.a 74, 46, 2
    Data.a 145, 115, 13
    Data.a 45, 15, 23
    Data.a 54, 24, 42
    
    quirc_version_db_32:
    Data.u 2465
    Data.a 6, 34, 60, 86, 112, 138, 0
    Data.a 74, 46, 10
    Data.a 145, 115, 17
    Data.a 45, 15, 19
    Data.a 54, 24, 10
    
    quirc_version_db_33:
    Data.u 2611
    Data.a 6, 30, 58, 86, 114, 142, 0
    Data.a 74, 46, 14
    Data.a 145, 115, 17
    Data.a 45, 15, 11
    Data.a 54, 24, 29
    
    quirc_version_db_34:
    Data.u 2761
    Data.a 6, 34, 62, 90, 118, 146, 0
    Data.a 74, 46, 14
    Data.a 145, 115, 13
    Data.a 46, 16, 59
    Data.a 54, 24, 44
    
    quirc_version_db_35:
    Data.u 2876
    Data.a 6, 30, 54, 78, 102, 126, 150
    Data.a 75, 47, 12
    Data.a 151, 121, 12
    Data.a 45, 15, 22
    Data.a 54, 24, 39
    
    quirc_version_db_36:
    Data.u 3034
    Data.a 6, 24, 50, 76, 102, 128, 154
    Data.a 75, 47, 6
    Data.a 151, 121, 6
    Data.a 45, 15, 2
    Data.a 54, 24, 46
    
    quirc_version_db_37:
    Data.u 3196
    Data.a 6, 28, 54, 80, 106, 132, 158
    Data.a 74, 46, 29
    Data.a 152, 122, 17
    Data.a 45, 15, 24
    Data.a 54, 24, 49
    
    quirc_version_db_38:
    Data.u 3362
    Data.a 6, 32, 58, 84, 110, 136, 162
    Data.a 74, 46, 13
    Data.a 152, 122, 4
    Data.a 45, 15, 42
    Data.a 54, 24, 48
    
    quirc_version_db_39:
    Data.u 3532
    Data.a 6, 26, 54, 82, 110, 138, 166
    Data.a 75, 47, 40
    Data.a 147, 117, 20
    Data.a 45, 15, 10
    Data.a 54, 24, 43
    
    quirc_version_db_40:
    Data.u 3706
    Data.a 6, 30, 58, 86, 114, 142, 170
    Data.a 75, 47, 18
    Data.a 148, 118, 19
    Data.a 45, 15, 20
    Data.a 54, 24, 34
  EndDataSection
  
  
  
  ; quirk.c
  
  Procedure.s quirc_version()
    ProcedureReturn "1.0"
  EndProcedure
  
  
  Procedure.i quirc_new()
    ProcedureReturn AllocateMemory(SizeOf(quirc))
  EndProcedure
  
  
  Procedure quirc_destroy(*q.quirc)
    
    FreeMemory(*q\image)
    ; q->pixels may alias q->image when their type representation is of the
    ;   same size, so we need To be careful here To avoid a double free
    If Not #QUIRC_PIXEL_ALIAS_IMAGE
      FreeMemory(*q\pixels)
    EndIf
    FreeMemory(*q)
  EndProcedure
  
  
  Procedure.i quirc_resize(*q.quirc, w.i, h.i)
    
    Protected olddim.i, newdim.i, min.i
    Protected *image.Ascii
    Protected *pixels.quirc_pixel_ptr
    
    
    ; XXX: w And h should be size_t (Or at least unsigned) As negatives
    ; values would Not make much sense. The downside is that it would Break
    ; both the API And ABI. Thus, at the moment, let's just do a sanity
    ; check.
    If w <= 0 Or h <= 0
      ProcedureReturn -1
    EndIf
    
    ; alloc a new buffer For q->image. We avoid realloc(3) because we want
    ; on failure To be leave `q` in a consistant, unmodified state.
    *image = AllocateMemory(w * h)
    If Not *image
      ProcedureReturn -1
    EndIf
    
    ; compute the "old" (i.e. currently allocated) And the "new"
    ; (i.e. requested) image dimensions
    olddim = *q\w * *q\h
    newdim = w * h
    If olddim < newdim
      min = olddim
    Else
      min = newdim
    EndIf
    
    ; copy the Data into the new buffer, avoiding (a) To Read beyond the
    ; old buffer when the new size is greater And (b) To write beyond the
    ; new buffer when the new size is smaller, hence the min computation.
    If *q\image
      CopyMemory(*q\image, *image, min)
    EndIf
    
    ; alloc a new buffer For q->pixels If needed
    If Not #QUIRC_PIXEL_ALIAS_IMAGE
      *pixels = AllocateMemory(newdim * SizeOf(quirc_pixel_ptr))
      If Not *pixels
        FreeMemory(*image)
        ProcedureReturn -1
      EndIf
    EndIf
    
    ; alloc succeeded, update `q` With the new size And buffers */
    *q\w = w
    *q\h = h
    If *q\image
      FreeMemory(*q\image)
    EndIf
    *q\image = *image
    If Not #QUIRC_PIXEL_ALIAS_IMAGE
      FreeMemory(*q\pixels)
      *q\pixels = *pixels
    EndIf
    
    ProcedureReturn 0
    
  EndProcedure
  
  
  Procedure.i quirc_count(*q.quirc)
    ProcedureReturn *q\num_grids
  EndProcedure
  
  
  Procedure.s quirc_strerror(err.i)
    
    Protected Error$
    
    
    Select err
      Case #QUIRC_SUCCESS : Error$ = "Success"
      Case #QUIRC_ERROR_INVALID_GRID_SIZE : Error$ = "Invalid grid size"
      Case #QUIRC_ERROR_INVALID_VERSION : Error$ = "Invalid version"
      Case #QUIRC_ERROR_FORMAT_ECC : Error$ = "Format data ECC failure"
      Case #QUIRC_ERROR_DATA_ECC : Error$ = "ECC failure"
      Case #QUIRC_ERROR_UNKNOWN_DATA_TYPE : Error$ = "Unknown data type"
      Case #QUIRC_ERROR_DATA_OVERFLOW : Error$ = "Data overflow"
      Case #QUIRC_ERROR_DATA_UNDERFLOW : Error$ = "Data underflow"
      Default : Error$ = "Unknown error"
    EndSelect
    
    ProcedureReturn Error$
    
  EndProcedure
  
  
  ; identify.c
  
  ; Linear algebra routines
  
  Procedure.i line_intersect(*p0.quirc_point, *p1.quirc_point, *q0.quirc_point, *q1.quirc_point, *r.quirc_point)
    
    Protected.i a, b, c, d, e, f, det
    
    
    ; (a, b) is perpendicular To line p
    a = -(*p1\y - *p0\y)
    b = *p1\x - *p0\x
    
    ; (c, d) is perpendicular To line q
    c = -(*q1\y - *q0\y)
    d = *q1\x - *q0\x
    
    ; e And f are dot products of the respective vectors With p And q
    e = a * *p1\x + b * *p1\y
    f = c * *q1\x + d * *q1\y
    
    ; Now we need To solve:
    ;     (a b) (rx)   (e)
    ;     (c d) (ry) = (f)
    ;
    ; We do this by inverting the matrix And applying it To (e, f):
    ;       ( d -b) (e)   (rx)
    ; 1/det (-c  a) (f) = (ry)
    ;
    det = (a * d) - (b * c)
    
    If Not det
      ProcedureReturn 0
    EndIf
    
    *r\x = (d * e - b * f) / det
    *r\y = (-c * e + a * f) / det
    
    ProcedureReturn 1
    
  EndProcedure
  
  
  Procedure perspective_setup(*c.DoubleArrayStructure, *rect.quirc_pointArrayStructure, w.d, h.d)
    
    Protected.d x0, y0, x1, y1, x2, y2, x3, y3, wden, hden
    
    
    x0 = *rect\v[0]\x
    y0 = *rect\v[0]\y
    x1 = *rect\v[1]\x
    y1 = *rect\v[1]\y
    x2 = *rect\v[2]\x
    y2 = *rect\v[2]\y
    x3 = *rect\v[3]\x
    y3 = *rect\v[3]\y
    
    wden = w * (x2*y3 - x3*y2 + (x3-x2)*y1 + x1*(y2-y3))
    hden = h * (x2*y3 + x1*(y2-y3) - x3*y2 + (x3-x2)*y1)
    
    *c\v[0] = (x1*(x2*y3-x3*y2) + x0*(-x2*y3+x3*y2+(x2-x3)*y1) +   x1*(x3-x2)*y0) / wden
    *c\v[1] = -(x0*(x2*y3+x1*(y2-y3)-x2*y1) - x1*x3*y2 + x2*x3*y1 + (x1*x3-x2*x3)*y0) / hden
    *c\v[2] = x0
    *c\v[3] = (y0*(x1*(y3-y2)-x2*y3+x3*y2) + y1*(x2*y3-x3*y2) + x0*y1*(y2-y3)) / wden
    *c\v[4] = (x0*(y1*y3-y2*y3) + x1*y2*y3 - x2*y1*y3 + y0*(x3*y2-x1*y2+(x2-x3)*y1)) / hden
    *c\v[5] = y0
    *c\v[6] = (x1*(y3-y2) + x0*(y2-y3) + (x2-x3)*y1 + (x3-x2)*y0) / wden
    *c\v[7] = (-x2*y3 + x1*y3 + x3*y2 + x0*(y1-y2) - x3*y1 + (x2-x1)*y0) /   hden
    
  EndProcedure
  
  
  Procedure perspective_map(*c.DoubleArrayStructure, u.d, v.d, *ret.quirc_point)
    
    Protected.d den, x, y
    
    
    den = *c\v[6]*u + *c\v[7]*v + 1.0
    x = (*c\v[0]*u + *c\v[1]*v + *c\v[2]) / den
    y = (*c\v[3]*u + *c\v[4]*v + *c\v[5]) / den
    
    *ret\x = Round(x, #PB_Round_Nearest)
    *ret\y = Round(y, #PB_Round_Nearest)
    
  EndProcedure
  
  
  Procedure perspective_unmap(*c.DoubleArrayStructure, *in.quirc_point, *u.Double, *v.Double)
    
    Protected.d x, y, den
    
    x = *in\x
    y = *in\y
    den = -*c\v[0] * *c\v[7] * y + *c\v[1] * *c\v[6] * y + (*c\v[3] * *c\v[7] - *c\v[4] * *c\v[6])*x + *c\v[0] * *c\v[4] - *c\v[1] * *c\v[3]
    
    *u\d = -(*c\v[1] * (y-*c\v[5]) - *c\v[2] * *c\v[7] * y + (*c\v[5] * *c\v[7] - *c\v[4]) * x + *c\v[2] * *c\v[4]) / den
    *v\d = (*c\v[0] * (y-*c\v[5]) - *c\v[2] * *c\v[6] * y + (*c\v[5] * *c\v[6] - *c\v[3]) * x + *c\v[2] * *c\v[3]) / den
    
  EndProcedure
  
  
  ; Span-based floodfill routine
  
  #FLOOD_FILL_MAX_DEPTH = 4096
  
  Prototype span_func_t(*user_data, y.i, left.i, right.i)
  
  Procedure flood_fill_seed(*q.quirc, x.i, y.i, from.i, To_.i, func.span_func_t, *user_data, depth.i)
    
    Protected.i left, right, i
    Protected *row.quirc_pixel_array
    
    
    left = x
    right = x
    *row = *q\pixels + y * *q\w
    
    If depth >= #FLOOD_FILL_MAX_DEPTH
      ProcedureReturn
    EndIf
    
    While left > 0 And *row\v[left - 1] = from
      left - 1
    Wend 
    
    While right < *q\w - 1 And *row\v[right + 1] = from
      right + 1
    Wend
    
    ; Fill the extent
    For i = left To right
      *row\v[i] = To_
    Next i
    
    If func
      func(*user_data, y, left, right)
    EndIf
    
    ; Seed new flood-fills
    If y > 0
      *row = *q\pixels + (y - 1) * *q\w
      
      For i = left To right
        If *row\v[i] = from
          flood_fill_seed(*q, i, y - 1, from, To_, func, *user_data, depth + 1)
        EndIf
      Next i
    EndIf
    
    If y < *q\h - 1
      *row = *q\pixels + (y + 1) * *q\w
      
      For i = left To right
        If *row\v[i] = from
          flood_fill_seed(*q, i, y + 1, from, To_, func, *user_data, depth + 1)
        EndIf
      Next i
    EndIf
    
  EndProcedure
  
  
  ; Adaptive thresholding
  
  Procedure.a otsu(*q.quirc)
    
    Protected.i numPixels, length, value, sum, i, sumb, q1, threshold, q2
    Protected.d max, m1, m2, m1m2, variance
    Protected Dim histogram.i(#UINT8_MAX)
    Protected *ptr.Ascii
    
    numPixels = *q\w * *q\h
    
    ; Calculate histogram
    
    *ptr = *q\image
    length = numPixels
    While length
      value = *ptr\a
      *ptr + 1
      histogram(value) + 1
      length - 1
    Wend
    
    ; Calculate weighted sum of histogram values
    For i = 0 To #UINT8_MAX
      sum + (i * histogram(i))
    Next i
    
    ; Compute threshold
    For i = 0 To #UINT8_MAX
      ; Weighted background
      q1 + histogram(i)
      If q1 = 0
        Continue
      EndIf
      
      ; Weighted foreground
      q2 = numPixels - q1
      If q2 = 0
        Break
      EndIf
      
      sumB + (i * histogram(i))
      m1 = sumB / q1
      m2 = (sum - sumB) / q2
      m1m2 = m1 - m2
      variance = m1m2 * m1m2 * q1 * q2
      If variance >= max
        threshold = i
        max = variance
      EndIf
    Next i
    
    ProcedureReturn threshold
    
  EndProcedure
  
  
  Procedure area_count(*user_data, y.i, left.i, right.i)
    
    Protected *ptr.quirc_region
    
    *ptr = *user_data
    *ptr\count + (right - left + 1)
    
  EndProcedure
  
  
  Procedure.i region_code(*q.quirc, x.i, y.i)
    
    Protected.i pixel, region
    Protected *box.quirc_region
    
    
    If x < 0 Or y < 0 Or x >= *q\w Or y >= *q\h
      ProcedureReturn -1
    EndIf
    
    pixel = *q\pixels\v[y * *q\w + x]
    
    If pixel >= #QUIRC_PIXEL_REGION
      ProcedureReturn pixel
    EndIf
    
    If pixel = #QUIRC_PIXEL_WHITE
      ProcedureReturn -1
    EndIf
    
    If *q\num_regions >= #QUIRC_MAX_REGIONS
      ProcedureReturn -1
    EndIf
    
    region = *q\num_regions
    *box = @*q\regions[*q\num_regions]
    *q\num_regions + 1
    
    FillMemory(*box, SizeOf(*box), 0)
    
    *box\seed\x = x
    *box\seed\y = y
    *box\capstone = -1
    
    flood_fill_seed(*q, x, y, pixel, region, @area_count(), *box, 0)
    
    ProcedureReturn region
    
  EndProcedure
  
  
  Structure polygon_score_data
    ref.quirc_point
    
    scores.i[4]
    corners.quirc_point[4]
  EndStructure
  
  
  Procedure find_one_corner(*user_data, y.i, left.i, right.i)
    
    Protected.i dy, i, dx, d
    Protected *psd.polygon_score_data
    Protected Dim xs.i(1)
    
    
    *psd = *user_data
    xs(0) = Left
    xs(1) = Right
    
    dy = y - *psd\ref\y
    
    For i = 0 To 1
      dx = xs(i) - *psd\ref\x
      d = dx * dx + dy * dy
      
      If d > *psd\scores[0]
        *psd\scores[0] = d
        *psd\corners[0]\x = xs(i)
        *psd\corners[0]\y = y
      EndIf
    Next i
    
  EndProcedure
  
  
  Procedure find_other_corners(*user_data, y.i, left.i, right.i)
    
    Protected.i i, up, j
    Protected *psd.polygon_score_data
    Protected Dim xs.i(1)
    Protected Dim scores.i(3)
    
    
    *psd = *user_data
    xs(0) = Left
    xs(1) = Right
    
    For i = 0 To 1
      up = xs(i) * *psd\ref\x + y * *psd\ref\y
      right = xs(i) * -*psd\ref\y + y * *psd\ref\x
      scores(0) = up
      scores(1) = right
      scores(2) = -up
      scores(3) = -right
      
      For j = 0 To 3
        If scores(j) > *psd\scores[j]
          *psd\scores[j] = scores(j)
          *psd\corners[j]\x = xs(i)
          *psd\corners[j]\y = y
        EndIf
      Next j
    Next i
    
  EndProcedure
  
  
  Procedure find_region_corners(*q.quirc, rcode.i, *ref.quirc_point, *corners.quirc_pointArrayStructure)
    
    Protected.i i
    Protected *region.quirc_region
    Protected psd.polygon_score_data
    
    
    *region = @*q\regions[rcode]
    
    ;psd\corners = *corners
    CopyMemory(@*corners\v[0], @psd\corners[0], SizeOf(psd\corners))
    
    CopyMemory(*ref, @psd\ref, SizeOf(psd\ref))
    psd\scores[0] = -1
    flood_fill_seed(*q, *region\seed\x, *region\seed\y, rcode, #QUIRC_PIXEL_BLACK, @find_one_corner(), @psd, 0)
    
    psd\ref\x = psd\corners[0]\x - psd\ref\x
    psd\ref\y = psd\corners[0]\y - psd\ref\y
    
    For i = 0 To 3
      CopyMemory(@*region\seed, @psd\corners[i], SizeOf(quirc_point))
    Next i
    
    i = *region\seed\x * psd\ref\x + *region\seed\y * psd\ref\y
    psd\scores[0] = i
    psd\scores[2] = -i
    i = *region\seed\x * -psd\ref\y + *region\seed\y * psd\ref\x
    psd\scores[1] = i
    psd\scores[3] = -i
    
    flood_fill_seed(*q, *region\seed\x, *region\seed\y, #QUIRC_PIXEL_BLACK, rcode, @find_other_corners(), @psd, 0)
    
    CopyMemory(@psd\corners[0], @*corners\v[0], SizeOf(psd\corners))
    
  EndProcedure
  
  
  Procedure record_capstone(*q.quirc, ring.i, stone.i)
    
    Protected.i cs_index
    Protected.quirc_region *stone_reg, *ring_reg
    Protected.quirc_capstone *capstone
    
    
    *stone_reg = @*q\regions[stone]
    *ring_reg = @*q\regions[ring]
    
    If *q\num_capstones >= #QUIRC_MAX_CAPSTONES
      ProcedureReturn
    EndIf
    
    cs_index = *q\num_capstones
    *capstone = @*q\capstones[*q\num_capstones]
    *q\num_capstones + 1
    
    FillMemory(*capstone, SizeOf(quirc_capstone), 0)
    
    *capstone\qr_grid = -1
    *capstone\ring = ring
    *capstone\stone = stone
    *stone_reg\capstone = cs_index
    *ring_reg\capstone = cs_index
    
    ; Find the corners of the ring
    find_region_corners(*q, ring, @*stone_reg\seed, @*capstone\corners)
    
    ; Set up the perspective transform And find the center
    perspective_setup(@*capstone\c, @*capstone\corners, 7.0, 7.0)
    perspective_map(@*capstone\c, 3.5, 3.5, @*capstone\center)
    
  EndProcedure
  
  
  Procedure test_capstone(*q.quirc, x.i, y.i, *pb.IntegerArrayStructure)
    
    Protected.i ring_right, stone, ring_left, ratio
    Protected.quirc_region *stone_reg, *ring_reg
    
    
    ring_right = region_code(*q, x - *pb\v[4], y)
    stone = region_code(*q, x - *pb\v[4] - *pb\v[3] - *pb\v[2], y)
    ring_left = region_code(*q, x - *pb\v[4] - *pb\v[3] - *pb\v[2] - *pb\v[1] - *pb\v[0], y)
    
    If ring_left < 0 Or ring_right < 0 Or stone < 0
      ProcedureReturn
    EndIf
    
    ; Left And ring of ring should be connected
    If ring_left <> ring_right
      ProcedureReturn
    EndIf
    
    ; Ring should be disconnected from stone
    If ring_left = stone
      ProcedureReturn
    EndIf
    
    *stone_reg = @*q\regions[stone]
    *ring_reg = @*q\regions[ring_left]
    
    ; Already detected
    If *stone_reg\capstone >= 0 Or *ring_reg\capstone >= 0
      ProcedureReturn
    EndIf
    
    ; Ratio should ideally be 37.5
    ratio = *stone_reg\count * 100 / *ring_reg\count
    If ratio < 10 Or ratio > 70
      ProcedureReturn
    EndIf
    
    record_capstone(*q, ring_left, stone)
    
  EndProcedure
  
  
  Procedure finder_scan(*q.quirc, y.i)
    
    Protected.i x, last_color, run_length, run_count, color, avg, err, i, ok
    Protected *row.quirc_pixel_array
    Protected *pb.IntegerArrayStructure
    Protected Dim check.i(4)
    
    
    *row = *q\pixels + y * *q\w
    
    *pb = AllocateMemory(5 * SizeOf(Integer))
    
    For x = 0 To *q\w - 1
      If *row\v[x]
        color = 1
      Else
        color = 0
      EndIf
      
      If x And color <> last_color
        ;memmove(pb, pb + 1, SizeOf(pb[0]) * 4)
        MoveMemory(*pb + SizeOf(Integer), *pb, SizeOf(Integer) * 4)
        *pb\v[4] = run_length
        run_length = 0
        run_count + 1
        
        If Not color And run_count >= 5
          check(0) = 1
          check(1) = 1
          check(2) = 3
          check(3) = 1
          check(4) = 1
          
          ok = 1
          
          avg = (*pb\v[0] + *pb\v[1] + *pb\v[3] + *pb\v[4]) / 4
          err = avg * 3 / 4
          
          For i = 0 To 4
            If *pb\v[i] < check(i) * avg - err Or *pb\v[i] > check(i) * avg + err
              ok = 0
            EndIf
          Next i
          
          If ok
            test_capstone(*q, x, y, *pb)
          EndIf
        EndIf
      EndIf
      
      run_length + 1
      last_color = color
    Next x
    
  EndProcedure
  
  
  Procedure find_alignment_pattern(*q.quirc, index.i)
    
    Protected.i size_estimate, step_size, dir, i, code
    Protected.d u, v
    Protected.quirc_grid *qr
    Protected.quirc_capstone *c0, *c2
    Protected.quirc_point a, b, c
    Protected.quirc_region *reg
    Protected Dim dx_map.i(3)
    Protected Dim dy_map.i(3)
    
    
    *qr = *q\grids[index]
    *c0 = *q\capstones[*qr\caps[0]]
    *c2 = *q\capstones[*qr\caps[2]]
    
    step_size = 1
    
    ; Grab our previous estimate of the alignment pattern corner
    CopyMemory(*qr\align, @b, SizeOf(quirc_point))
    
    ; Guess another two corners of the alignment pattern so that we
    ; can estimate its size.
    perspective_unmap(@*c0\c, @b, @u, @v)
    perspective_map(@*c0\c, u, v + 1.0, @a)
    perspective_unmap(@*c2\c, @b, @u, @v)
    perspective_map(@*c2\c, u + 1.0, v, @c)
    
    size_estimate = Abs((a\x - b\x) * -(c\y - b\y) + (a\y - b\y) * (c\x - b\x))
    
    ; Spiral outwards from the estimate point Until we find something
    ; roughly the right size. Don't look too far from the estimate
    ; point.
    
    dx_map(0) = 1
    dx_map(1) = 0
    dx_map(2) = -1
    dx_map(3) = 0
    
    dy_map(0) = 0
    dy_map(1) = -1
    dy_map(2) = 0
    dy_map(3) = 1
    
    While step_size * step_size < size_estimate * 100
      
      For i = 0 To step_size - 1
        code = region_code(*q, b\x, b\y)
        
        If code >= 0
          *reg = @*q\regions[code]
          
          If *reg\count >= size_estimate / 2 And *reg\count <= size_estimate * 2
            *qr\align_region = code
            ProcedureReturn
          EndIf
        EndIf
        
        b\x + dx_map(dir)
        b\y + dy_map(dir)
      Next i
      
      dir = (dir + 1) % 4
      If Not dir & 1
        step_size + 1
      EndIf
    Wend
    
  EndProcedure
  
  
  Procedure find_leftmost_to_line(*user_data, y.i, left.i, right.i)
    
    Protected.i i, d
    Protected *psd.polygon_score_data
    Protected Dim xs.i(1)
    
    
    *psd = *user_data
    xs(0) = left
    xs(1) = right
    
    For i = 0 To 1
      d = -*psd\ref\y * xs(i) + *psd\ref\x * y
      
      If d < *psd\scores[0]
        *psd\scores[0] = d
        *psd\corners[0]\x = xs(i)
        *psd\corners[0]\y = y
      EndIf
    Next i
    
  EndProcedure
  
  
  ; Do a Bresenham scan from one point To another And count the number
  ; of black/white transitions.
  Procedure.i timing_scan(*q.quirc, *p0.quirc_point, *p1.quirc_point)
    
    Protected.i n, d, x, y, dom_step, nondom_step, a, run_length, count, swap_, pixel, i
    Protected *dom.Integer, *nondom.Integer
    
    
    n = *p1\x - *p0\x
    d = *p1\y - *p0\y
    x = *p0\x
    y = *p0\y
    
    If *p0\x < 0 Or *p0\y < 0 Or *p0\x >= *q\w Or *p0\y >= *q\h
      ProcedureReturn -1
    EndIf
    
    If *p1\x < 0 Or *p1\y < 0 Or *p1\x >= *q\w Or *p1\y >= *q\h
      ProcedureReturn -1
    EndIf
    
    If Abs(n) > Abs(d)
      Swap_ = n
      
      n = d
      d = Swap_
      
      *dom = @x
      *nondom = @y
    Else
      *dom = @y
      *nondom = @x
    EndIf
    
    If n < 0
      n = -n
      nondom_step = -1
    Else
      nondom_step = 1
    EndIf
    
    If d < 0
      d = -d
      dom_step = -1
    Else
      dom_step = 1
    EndIf
    
    x = *p0\x
    y = *p0\y
    For i = 0 To d
      
      If y < 0 Or y >= *q\h Or x < 0 Or x >= *q\w
        Break;
      EndIf
      
      pixel = *q\pixels\v[y * *q\w + x]
      
      If pixel
        If run_length >= 2
          count + 1
        EndIf
        run_length = 0
      Else
        run_length + 1
      EndIf
      
      a + n
      *dom\i + dom_step
      If a >= d
        *nondom\i + nondom_step
        a - d
      EndIf
    Next i
    
    ProcedureReturn count
    
  EndProcedure
  
  
  ; Try the measure the timing pattern For a given QR code. This does
  ; Not require the Global perspective To have been set up, but it
  ; does require that the capstone corners have been set To their
  ; canonical rotation.
  ;
  ; For each capstone, we find a point in the middle of the ring band
  ; which is nearest the centre of the code. Using these points, we do
  ; a horizontal And a vertical timing scan.
  Procedure.i measure_timing_pattern(*q.quirc, index.i)
    
    Protected.i i, scan, ver, size
    Protected *qr.quirc_grid
    Protected *cap.quirc_capstone
    Protected Dim us.d(2)
    Protected Dim vs.d(2)
    
    
    *qr = @*q\grids[index]
    
    us(0) = 6.5
    us(1) = 6.5
    us(2) = 0.5
    
    vs(0) = 0.5
    vs(1) = 6.5
    vs(2) = 6.5
    
    For i = 0 To 2
      *cap = @*q\capstones[*qr\caps[i]]
      perspective_map(@*cap\c, us(i), vs(i), @*qr\tpep[i])
    Next i
    
    *qr\hscan = timing_scan(*q, @*qr\tpep[1], @*qr\tpep[2])
    *qr\vscan = timing_scan(*q, @*qr\tpep[1], @*qr\tpep[0])
    
    scan = *qr\hscan
    If *qr\vscan > scan
      scan = *qr\vscan
    EndIf
    
    ; If neither scan worked, we can't go any further.
    If scan < 0
      ProcedureReturn -1
    EndIf
    
    ; Choose the nearest allowable grid size
    size = scan * 2 + 13
    ver = (size - 15) / 4
    If ver > #QUIRC_MAX_VERSION
      ProcedureReturn -1
    EndIf
    
    *qr\grid_size = ver * 4 + 17
    
    ProcedureReturn 0
    
  EndProcedure
  
  
  ; Read a cell from a grid using the currently set perspective
  ; transform. Returns +/- 1 For black/white, 0 For cells which are
  ; out of image bounds.
  Procedure.i read_cell(*q.quirc, index.i, x.i, y.i)
    
    Protected *qr.quirc_grid, p.quirc_point
    
    
    *qr = @*q\grids[index]
    
    perspective_map(@*qr\c, x + 0.5, y + 0.5, @p)
    If p\y < 0 Or p\y >= *q\h Or p\x < 0 Or p\x >= *q\w
      ProcedureReturn 0
    EndIf
    
    If *q\pixels\v[p\y * *q\w + p\x]
      ProcedureReturn 1
    Else
      ProcedureReturn -1
    EndIf
    
  EndProcedure
  
  
  Procedure.i fitness_cell(*q.quirc, index.i, x.i, y.i)
    
    Protected.i score, u, v
    Protected *qr.quirc_grid
    Protected p.quirc_point
    Protected Dim offsets.d(2)
    
    
    *qr = @*q\grids[index]
    
    offsets(0) = 0.3
    offsets(1) = 0.5
    offsets(2) = 0.7
    
    For v = 0 To 2
      For u = 0 To 2
        
        perspective_map(@*qr\c, x + offsets(u), y + offsets(v), @p)
        If p\y < 0 Or p\y >= *q\h Or p\x < 0 Or p\x >= *q\w
          Continue
        EndIf
        
        If *q\pixels\v[p\y * *q\w + p\x]
          score + 1
        Else
          score - 1
        EndIf
      Next u
    Next v
    
    ProcedureReturn score
    
  EndProcedure
  
  
  Procedure.i fitness_ring(*q.quirc, index.i, cx.i, cy.i, radius.i)
    
    Protected.i i, score
    
    
    For i = 0 To radius * 2 - 1
      score + fitness_cell(*q, index, cx - radius + i, cy - radius)
      score + fitness_cell(*q, index, cx - radius, cy + radius - i)
      score + fitness_cell(*q, index, cx + radius, cy - radius + i)
      score + fitness_cell(*q, index, cx + radius - i, cy + radius)
    Next i
    
    ProcedureReturn score
    
  EndProcedure
  
  
  Procedure.i fitness_apat(*q.quirc, index.i, cx.i, cy.i)
    ProcedureReturn fitness_cell(*q, index, cx, cy) - fitness_ring(*q, index, cx, cy, 1) + fitness_ring(*q, index, cx, cy, 2)
  EndProcedure
  
  
  Procedure.i fitness_capstone(*q.quirc, index.i, x.i, y.i)
    
    x + 3
    y + 3
    
    ProcedureReturn fitness_cell(*q, index, x, y) + fitness_ring(*q, index, x, y, 1) - fitness_ring(*q, index, x, y, 2) + fitness_ring(*q, index, x, y, 3)
    
  EndProcedure
  
  
  ; Compute a fitness score For the currently configured perspective
  ; transform, using the features we expect To find by scanning the
  ; grid.
  Procedure.i fitness_all(*q.quirc, index.i)
    
    Protected.i version, score, i, j, ap_count, expect
    Protected *qr.quirc_grid
    Protected *info.quirc_version_info
    
    
    *qr = @*q\grids[index]
    version = (*qr\grid_size - 17) / 4
    *info = ?quirc_version_db_0 + version * SizeOf(quirc_version_info)
    
    ; Check the timing pattern
    For i = 0 To *qr\grid_size - 15
      If i & 1
        expect = 1
      Else
        expect = -1
      EndIf
      
      score + fitness_cell(*q, index, i + 7, 6) * expect
      score + fitness_cell(*q, index, 6, i + 7) * expect
    Next i
    
    ; Check capstones
    score + fitness_capstone(*q, index, 0, 0)
    score + fitness_capstone(*q, index, *qr\grid_size - 7, 0)
    score + fitness_capstone(*q, index, 0, *qr\grid_size - 7)
    
    If version < 0 Or version > #QUIRC_MAX_VERSION
      ProcedureReturn score
    EndIf
    
    ; Check alignment patterns
    ap_count = 0
    While (ap_count < #QUIRC_MAX_ALIGNMENT) And *info\apat[ap_count]
      ap_count + 1
    Wend
    
    For i = 1 To ap_count - 2
      score + fitness_apat(*q, index, 6, *info\apat[i])
      score + fitness_apat(*q, index, *info\apat[i], 6)
    Next i
    
    For i = 1 To ap_count - 1
      For j = 1 To ap_count - 1
        score + fitness_apat(*q, index, *info\apat[i], *info\apat[j])
      Next j
    Next i
    
    ProcedureReturn score
    
  EndProcedure
  
  
  Procedure jiggle_perspective(*q.quirc, index.i)
    
    Protected.i pass, i, best, j, test
    Protected.d old, step_, new
    Protected *qr.quirc_grid
    Protected Dim adjustments.d(7)
    
    
    *qr = @*q\grids[index]
    best = fitness_all(*q, index)
    
    For i = 0 To 7
      adjustments(i) = *qr\c[i] * 0.02
    Next i
    
    For pass = 0 To 4
      For i = 0 To 15
        j = i >> 1
        old = *qr\c[j]
        Step_ = adjustments(j)
        
        If i & 1
          new = old + Step_
        Else
          new = old - Step_
        EndIf
        
        *qr\c[j] = new
        test = fitness_all(*q, index)
        
        If test > best
          best = test
        Else
          *qr\c[j] = old
        EndIf
      Next i
      
      For i = 0 To 7
        adjustments(i) * 0.5
      Next i
    Next pass
    
  EndProcedure
  
  
  ; Once the capstones are in place And an alignment point has been
  ; chosen, we call this function To set up a grid-reading perspective
  ; transform.
  Procedure setup_qr_perspective(*q.quirc, index.i)
    
    Protected *qr.quirc_grid
    Protected *rect.quirc_pointArrayStructure
    
    
    *qr = @*q\grids[index]
    *rect = AllocateMemory(SizeOf(quirc_point) * 4)
    If *rect
      
      ; Set up the perspective Map For reading the grid
      CopyMemory(@*q\capstones[*qr\caps[1]]\corners[0], @*rect\v[0], SizeOf(quirc_point))
      CopyMemory(@*q\capstones[*qr\caps[2]]\corners[0], @*rect\v[1], SizeOf(quirc_point))
      CopyMemory(@*qr\align, @*rect\v[2], SizeOf(quirc_point))
      CopyMemory(@*q\capstones[*qr\caps[0]]\corners[0], @*rect\v[3], SizeOf(quirc_point))
      
      perspective_setup(@*qr\c, *rect, *qr\grid_size - 7, *qr\grid_size - 7)
      
      jiggle_perspective(*q, index)
      FreeMemory(*rect)
    EndIf
    
  EndProcedure
  
  
  ; Rotate the capstone With so that corner 0 is the leftmost With respect
  ; To the given reference line.
  Procedure rotate_capstone(*cap.quirc_capstone, *h0.quirc_point, *hd.quirc_point)
    
    Protected.i j, best, best_score, score
    Protected *p.quirc_point
    Protected Dim copy.quirc_point(3)
    
    
    best_score = #INT_MAX
    
    For j = 0 To 3
      *p = @*cap\corners[j]
      score = (*p\x - *h0\x) * -*hd\y +   (*p\y - *h0\y) * *hd\x
      
      If Not j Or score < best_score
        best = j
        best_score = score
      EndIf
    Next j
    
    ; Rotate the capstone
    For j = 0 To 3
      CopyMemory(@*cap\corners[(j + best) % 4], @copy(j), SizeOf(quirc_point))
    Next j
    CopyMemory(@copy(), *cap\corners, SizeOf(*cap\corners))
    perspective_setup(@*cap\c, @*cap\corners, 7.0, 7.0)
    
  EndProcedure
  
  
  Procedure record_qr_grid(*q.quirc, a.i, b.i, c.i)
    
    Protected.i i, qr_index, swap_
    Protected.quirc_point h0, hd
    Protected *qr.quirc_grid
    Protected *cap.quirc_capstone
    Protected psd.polygon_score_data
    Protected *reg.quirc_region
    
    
    If *q\num_grids >= #QUIRC_MAX_GRIDS
      ProcedureReturn
    EndIf
    
    ; Construct the hypotenuse line from A To C. B should be To
    ; the left of this line.
    CopyMemory(@*q\capstones[a]\center, @h0, SizeOf(h0))
    hd\x = *q\capstones[c]\center\x - *q\capstones[a]\center\x
    hd\y = *q\capstones[c]\center\y - *q\capstones[a]\center\y
    
    ; Make sure A-B-C is clockwise
    If (*q\capstones[b]\center\x - h0\x) * -hd\y + (*q\capstones[b]\center\y - h0\y) * hd\x > 0
      swap_ = a
      
      a = c
      c = swap_
      hd\x = -hd\x
      hd\y = -hd\y
    EndIf
    
    ; Record the grid And its components
    qr_index = *q\num_grids
    *qr = @*q\grids[*q\num_grids]
    *q\num_grids + 1
    
    FillMemory(*qr, SizeOf(quirc_grid), 0)
    *qr\caps[0] = a
    *qr\caps[1] = b
    *qr\caps[2] = c
    *qr\align_region = -1
    
    ; Rotate each capstone so that corner 0 is top-left With respect
    ; To the grid.
    For i = 0 To 2
      *cap = @*q\capstones[*qr\caps[i]]
      
      rotate_capstone(*cap, @h0, @hd)
      *cap\qr_grid = qr_index
    Next i
    
    ; Check the timing pattern. This doesn't require a perspective
    ; transform.
    If measure_timing_pattern(*q, qr_index) < 0
      ; We've been unable to complete setup for this grid. Undo what we've
      ; recorded And pretend it never happened.
      For i = 0 To 2
        *q\capstones[*qr\caps[i]]\qr_grid = -1
      Next i
      *q\num_grids - 1
      ProcedureReturn
    EndIf
    
    ; Make an estimate based For the alignment pattern based on extending
    ; lines from capstones A And C.
    If Not line_intersect(@*q\capstones[a]\corners[0], @*q\capstones[a]\corners[1], @*q\capstones[c]\corners[0], @*q\capstones[c]\corners[3], @*qr\align)
      ; We've been unable to complete setup for this grid. Undo what we've
      ; recorded And pretend it never happened.
      For i = 0 To 2
        *q\capstones[*qr\caps[i]]\qr_grid = -1
      Next i
      *q\num_grids - 1
      ProcedureReturn
    EndIf
    
    ; On V2+ grids, we should use the alignment pattern.
    If *qr\grid_size > 21
      ; Try To find the actual location of the alignment pattern.
      find_alignment_pattern(*q, qr_index)
      
      ; Find the point of the alignment pattern closest To the
      ; top-left of the QR grid.
      If *qr\align_region >= 0
        *reg = @*q\regions[*qr\align_region]
        
        ; Start from some point inside the alignment pattern
        CopyMemory(@*reg\seed, @*qr\align, SizeOf(*qr\align))
        
        CopyMemory(@hd, @psd\ref, SizeOf(psd\ref))
        ;psd\corners = @*qr\align
        CopyMemory(@*qr\align, @psd\corners, SizeOf(quirc_point))
        psd\scores[0] = -hd\y * *qr\align\x + hd\x * *qr\align\y
        
        flood_fill_seed(*q, *reg\seed\x, *reg\seed\y, *qr\align_region, #QUIRC_PIXEL_BLACK, #Null, #Null, 0)
        flood_fill_seed(*q, *reg\seed\x, *reg\seed\y, #QUIRC_PIXEL_BLACK, *qr\align_region, @find_leftmost_to_line(), @psd, 0)
      EndIf
    EndIf
    
    setup_qr_perspective(*q, qr_index)
    
  EndProcedure
  
  
  Structure neighbour
    index.i
    distance.d
  EndStructure
  
  
  Structure neighbour_list
    n.neighbour[#QUIRC_MAX_CAPSTONES]
    count.i
  EndStructure
  
  
  Procedure test_neighbours(*q.quirc, i.i, *hlist.neighbour_list, *vlist.neighbour_list)
    
    Protected.i j, k, best_h, best_v
    Protected.d best_score, score
    Protected.neighbour *hn, *vn
    
    
    best_h = -1
    best_v = -1
    
    ; Test each possible grouping
    For j = 0 To *hlist\count - 1
      For k = 0 To *vlist\count - 1
        *hn = @*hlist\n[j]
        *vn = @*vlist\n[k]
        score = Abs(1.0 - *hn\distance / *vn\distance)
        
        If score > 2.5
          Continue
        EndIf
        
        If best_h < 0 Or score < best_score
          best_h = *hn\index
          best_v = *vn\index
          best_score = score
        EndIf
      Next k
    Next j
    
    If best_h < 0 Or best_v < 0
      ProcedureReturn
    EndIf
    
    record_qr_grid(*q, best_h, i, best_v)
    
  EndProcedure
  
  
  Procedure test_grouping(*q.quirc, i.i)
    
    Protected.i j
    Protected.d u, v
    Protected.quirc_capstone *c1, *c2
    Protected.neighbour_list hlist, vlist
    Protected.neighbour *n
    
    
    *c1 = @*q\capstones[i]
    
    If *c1\qr_grid >= 0
      ProcedureReturn
    EndIf
    
    ; Look For potential neighbours by examining the relative gradients
    ; from this capstone To others.
    For j = 0 To *q\num_capstones - 1
      *c2 = @*q\capstones[j]
      
      If i = j Or *c2\qr_grid >= 0
        Continue
      EndIf
      
      perspective_unmap(@*c1\c, @*c2\center, @u, @v)
      
      u = Abs(u - 3.5)
      v = Abs(v - 3.5)
      
      If u < 0.2 * v
        *n = @hlist\n[hlist\count]
        hlist\count + 1
        
        *n\index = j
        *n\distance = v
      EndIf
      
      If v < 0.2 * u
        *n = @vlist\n[vlist\count]
        vlist\count + 1
        
        *n\index = j
        *n\distance = u
      EndIf
    Next j
    
    If Not (hlist\count And vlist\count)
      ProcedureReturn
    EndIf
    
    test_neighbours(*q, i, @hlist, @vlist)
    
  EndProcedure
  
  
  Procedure pixels_setup(*q.quirc, threshold.a)
    
    Protected.a value
    Protected.i length
    Protected *source.Ascii
    Protected *dest.quirc_pixel_array
    
    
    If #QUIRC_PIXEL_ALIAS_IMAGE
      *q\pixels = *q\image
    EndIf
    
    *source = *q\image
    *dest = *q\pixels
    length = *q\w * *q\h
    While length
      value = *source\a
      *source + 1
      If value < threshold
        *dest\v = #QUIRC_PIXEL_BLACK
      Else
        *dest\v = #QUIRC_PIXEL_WHITE
      EndIf
      *dest + SizeOf(quirc_pixel_ptr)
      length - 1
    Wend
    
  EndProcedure
  
  
  Procedure.i quirc_begin(*q.quirc, *w.Integer, *h.Integer)
    
    
    *q\num_regions = #QUIRC_PIXEL_REGION
    *q\num_capstones = 0
    *q\num_grids = 0
    
    If *w
      *w\i = *q\w
    EndIf
    
    If *h
      *h\i = *q\h
    EndIf
    
    ProcedureReturn *q\image
    
  EndProcedure
  
  
  Procedure quirc_end(*q.quirc)
    
    Protected.a threshold
    Protected.i i
    
    
    threshold = otsu(*q)
    pixels_setup(*q, threshold)
    
    For i = 0 To *q\h - 1
      finder_scan(*q, i)
    Next i
    
    For i = 0 To *q\num_capstones - 1
      test_grouping(*q, i)
    Next i
    
  EndProcedure
  
  
  Procedure quirc_extract(*q.quirc, index.i, *code.quirc_code)
    
    Protected.i y, i, x
    Protected *qr.quirc_grid
    
    
    *qr = @*q\grids[index]
    
    If index < 0 Or index > *q\num_grids
      ProcedureReturn
    EndIf
    
    FillMemory(*code, SizeOf(*code), 0)
    
    perspective_map(@*qr\c, 0.0, 0.0, @*code\corners[0])
    perspective_map(@*qr\c, *qr\grid_size, 0.0, @*code\corners[1])
    perspective_map(@*qr\c, *qr\grid_size, *qr\grid_size, @*code\corners[2])
    perspective_map(@*qr\c, 0.0, *qr\grid_size, @*code\corners[3])
    
    *code\size = *qr\grid_size
    
    For y = 0 To *qr\grid_size - 1
      For x = 0 To *qr\grid_size - 1
        If read_cell(*q, index, x, y) > 0
          *code\cell_bitmap[i >> 3] | (1 << (i & 7))
        EndIf
        i + 1
      Next x
    Next y
    
  EndProcedure
  
  
  ; decode.c
  
  #MAX_POLY = 64
  
  ; Galois fields
  
  Structure galois_field
    p.i
    *log.AsciiArrayStructure
    *exp.AsciiArrayStructure
  EndStructure
  
  
  DataSection
    gf16_exp:
    Data.a $01, $02, $04, $08, $03, $06, $0c, $0b, $05, $0a, $07, $0e, $0f, $0d, $09, $01
    gf16_log:
    Data.a $00, $0f, $01, $04, $02, $08, $05, $0a, $03, $0e, $09, $07, $06, $0d, $0b, $0c
    gf256_exp:
    Data.a $01, $02, $04, $08, $10, $20, $40, $80
    Data.a $1d, $3a, $74, $e8, $cd, $87, $13, $26
    Data.a $4c, $98, $2d, $5a, $b4, $75, $ea, $c9
    Data.a $8f, $03, $06, $0c, $18, $30, $60, $c0
    Data.a $9d, $27, $4e, $9c, $25, $4a, $94, $35
    Data.a $6a, $d4, $b5, $77, $ee, $c1, $9f, $23
    Data.a $46, $8c, $05, $0a, $14, $28, $50, $a0
    Data.a $5d, $ba, $69, $d2, $b9, $6f, $de, $a1
    Data.a $5f, $be, $61, $c2, $99, $2f, $5e, $bc
    Data.a $65, $ca, $89, $0f, $1e, $3c, $78, $f0
    Data.a $fd, $e7, $d3, $bb, $6b, $d6, $b1, $7f
    Data.a $fe, $e1, $df, $a3, $5b, $b6, $71, $e2
    Data.a $d9, $af, $43, $86, $11, $22, $44, $88
    Data.a $0d, $1a, $34, $68, $d0, $bd, $67, $ce
    Data.a $81, $1f, $3e, $7c, $f8, $ed, $c7, $93
    Data.a $3b, $76, $ec, $c5, $97, $33, $66, $cc
    Data.a $85, $17, $2e, $5c, $b8, $6d, $da, $a9
    Data.a $4f, $9e, $21, $42, $84, $15, $2a, $54
    Data.a $a8, $4d, $9a, $29, $52, $a4, $55, $aa
    Data.a $49, $92, $39, $72, $e4, $d5, $b7, $73
    Data.a $e6, $d1, $bf, $63, $c6, $91, $3f, $7e
    Data.a $fc, $e5, $d7, $b3, $7b, $f6, $f1, $ff
    Data.a $e3, $db, $ab, $4b, $96, $31, $62, $c4
    Data.a $95, $37, $6e, $dc, $a5, $57, $ae, $41
    Data.a $82, $19, $32, $64, $c8, $8d, $07, $0e
    Data.a $1c, $38, $70, $e0, $dd, $a7, $53, $a6
    Data.a $51, $a2, $59, $b2, $79, $f2, $f9, $ef
    Data.a $c3, $9b, $2b, $56, $ac, $45, $8a, $09
    Data.a $12, $24, $48, $90, $3d, $7a, $f4, $f5
    Data.a $f7, $f3, $fb, $eb, $cb, $8b, $0b, $16
    Data.a $2c, $58, $b0, $7d, $fa, $e9, $cf, $83
    Data.a $1b, $36, $6c, $d8, $ad, $47, $8e, $01
    gf256_log:
    Data.a $00, $ff, $01, $19, $02, $32, $1a, $c6
    Data.a $03, $df, $33, $ee, $1b, $68, $c7, $4b
    Data.a $04, $64, $e0, $0e, $34, $8d, $ef, $81
    Data.a $1c, $c1, $69, $f8, $c8, $08, $4c, $71
    Data.a $05, $8a, $65, $2f, $e1, $24, $0f, $21
    Data.a $35, $93, $8e, $da, $f0, $12, $82, $45
    Data.a $1d, $b5, $c2, $7d, $6a, $27, $f9, $b9
    Data.a $c9, $9a, $09, $78, $4d, $e4, $72, $a6
    Data.a $06, $bf, $8b, $62, $66, $dd, $30, $fd
    Data.a $e2, $98, $25, $b3, $10, $91, $22, $88
    Data.a $36, $d0, $94, $ce, $8f, $96, $db, $bd
    Data.a $f1, $d2, $13, $5c, $83, $38, $46, $40
    Data.a $1e, $42, $b6, $a3, $c3, $48, $7e, $6e
    Data.a $6b, $3a, $28, $54, $fa, $85, $ba, $3d
    Data.a $ca, $5e, $9b, $9f, $0a, $15, $79, $2b
    Data.a $4e, $d4, $e5, $ac, $73, $f3, $a7, $57
    Data.a $07, $70, $c0, $f7, $8c, $80, $63, $0d
    Data.a $67, $4a, $de, $ed, $31, $c5, $fe, $18
    Data.a $e3, $a5, $99, $77, $26, $b8, $b4, $7c
    Data.a $11, $44, $92, $d9, $23, $20, $89, $2e
    Data.a $37, $3f, $d1, $5b, $95, $bc, $cf, $cd
    Data.a $90, $87, $97, $b2, $dc, $fc, $be, $61
    Data.a $f2, $56, $d3, $ab, $14, $2a, $5d, $9e
    Data.a $84, $3c, $39, $53, $47, $6d, $41, $a2
    Data.a $1f, $2d, $43, $d8, $b7, $7b, $a4, $76
    Data.a $c4, $17, $49, $ec, $7f, $0c, $6f, $f6
    Data.a $6c, $a1, $3b, $52, $29, $9d, $55, $aa
    Data.a $fb, $60, $86, $b1, $bb, $cc, $3e, $5a
    Data.a $cb, $59, $5f, $b0, $9c, $a9, $a0, $51
    Data.a $0b, $f5, $16, $eb, $7a, $75, $2c, $d7
    Data.a $4f, $ae, $d5, $e9, $e6, $e7, $ad, $e8
    Data.a $74, $d6, $f4, $ea, $a8, $50, $58, $af
  EndDataSection
  
  
  Global gf16.galois_field
  gf16\p = 15
  gf16\exp = ?gf16_exp
  gf16\log = ?gf16_log
  
  Global gf256.galois_field
  gf256\p = 255
  gf256\exp = ?gf256_exp
  gf256\log = ?gf256_log
  
  ; Polynomial operations
  
  Procedure poly_add(*dst.AsciiArrayStructure, *src.AsciiArrayStructure, c.a, shift.i, *gf.galois_field)
    
    Protected.a v
    Protected.i i, log_c, p
    
    
    log_c = *gf\log\v[c]
    
    If Not c
      ProcedureReturn
    EndIf
    
    For i = 0 To #MAX_POLY - 1
      p = i + shift
      v = *src\v[i]
      
      If p < 0 Or p >= #MAX_POLY
        Continue
      EndIf
      
      If Not v
        Continue
      EndIf
      
      *dst\v[p] ! *gf\exp\v[(*gf\log\v[v] + log_c) % *gf\p]
    Next i
    
  EndProcedure
  
  
  Procedure.a poly_eval(*s.AsciiArrayStructure, x.a, *gf.galois_field)
    
    Protected.a sum, log_x, c
    Protected.i i
    
    
    log_x = *gf\log\v[x]
    
    If Not x
      ProcedureReturn *s\v[0]
    EndIf
    
    For i = 0 To #MAX_POLY - 1
      c = *s\v[i]
      
      If Not c
        Continue
      EndIf
      
      sum ! *gf\exp\v[(*gf\log\v[c] + log_x * i) % *gf\p]
    Next i
    
    ProcedureReturn sum
    
  EndProcedure
  
  
  ; Berlekamp-Massey algorithm For finding error locator polynomials.
  Procedure berlekamp_massey(*s.AsciiArrayStructure, N.i, *gf.galois_field, *sigma.AsciiArrayStructure)
    
    Protected.a b, d, mult
    Protected.i L, m, n_, i
    Protected.AsciiArrayStructure *C, *B, *T
    
    
    *C = AllocateMemory(#MAX_POLY)
    *B = AllocateMemory(#MAX_POLY)
    *T = AllocateMemory(#MAX_POLY)
    
    m = 1
    b = 1
    
    *B\v[0] = 1
    *C\v[0] = 1
    
    For n_ = 0 To N - 1
      d = *s\v[n_]
      
      For i = 1 To L
        If Not (*C\v[i] And *s\v[n_ - i])
          Continue
        EndIf
        d ! (*gf\exp\v[(*gf\log\v[*C\v[i]] + *gf\log\v[*s\v[n_ - i]]) % *gf\p])
      Next i
      
      mult = *gf\exp\v[(*gf\p - *gf\log\v[b] + *gf\log\v[d]) % *gf\p]
      
      If Not d
        m + 1
      ElseIf L * 2 <= n_
        CopyMemory(*C, *T, MemorySize(*T))
        poly_add(*C, *B, mult, m, *gf)
        CopyMemory(*T, *B, MemorySize(*B))
        L = n_ + 1 - L
        b = d
        m = 1
      Else
        poly_add(*C, *B, mult, m, *gf)
        m + 1
      EndIf
    Next n_
    
    CopyMemory(*C, *sigma, #MAX_POLY)
    
  EndProcedure
  
  
  ; Code stream error correction
  ;
  ; Generator polynomial For GF(2^8) is x^8 + x^4 + x^3 + x^2 + 1
  Procedure.i block_syndromes(*Data.AsciiArrayStructure, bs.i, npar.i, *s.AsciiArrayStructure)
    
    Protected.a c
    Protected.i nonzero, i, j
    Protected.AsciiArrayStructure *gf256_exp, *gf256_log
    
    
    *gf256_exp = ?gf256_exp
    *gf256_log = ?gf256_log
    FillMemory(*s, #MAX_POLY, 0)
    
    For i = 0 To npar - 1
      For j = 0 To bs - 1
        c = *Data\v[bs - j - 1]
        
        If Not c
          Continue
        EndIf
        
        *s\v[i] ! *gf256_exp\v[(*gf256_log\v[c] + i * j) % 255]
      Next j
      
      If *s\v[i]
        nonzero = 1
      EndIf
    Next i
    
    ProcedureReturn nonzero
    
  EndProcedure
  
  
  Procedure eloc_poly(*omega.AsciiArrayStructure, *s.AsciiArrayStructure, *sigma.AsciiArrayStructure, npar.i)
    
    Protected.a a, log_a, b
    Protected.i i, j
    Protected.AsciiArrayStructure *gf256_exp, *gf256_log
    
    
    *gf256_exp = ?gf256_exp
    *gf256_log = ?gf256_log
    FillMemory(*omega, #MAX_POLY, 0)
    
    For i = 0 To npar - 1
      a = *sigma\v[i]
      log_a = *gf256_log\v[a]
      
      If Not a
        Continue
      EndIf
      
      For j = 0 To #MAX_POLY - 2
        b = *s\v[j + 1]
        
        If i + j >= npar
          Break
        EndIf
        
        If Not b
          Continue
        EndIf
        
        *omega\v[i + j] ! *gf256_exp\v[(log_a + *gf256_log\v[b]) % 255]
      Next j
    Next i
    
  EndProcedure
  
  
  Procedure.i correct_block(*Data.AsciiArrayStructure, *ecc.quirc_rs_params)
    
    Protected.a xinv, sd_x, omega_x, error
    Protected.i npar, i
    Protected.AsciiArrayStructure *s, *sigma, *sigma_deriv, *omega, *gf256_exp, *gf256_log
    
    
    *gf256_exp = ?gf256_exp
    *gf256_log = ?gf256_log
    
    npar = *ecc\bs - *ecc\dw
    *s = AllocateMemory(#MAX_POLY)
    *sigma = AllocateMemory(#MAX_POLY)
    *sigma_deriv = AllocateMemory(#MAX_POLY)
    *omega = AllocateMemory(#MAX_POLY)
    
    ; Compute syndrome vector
    If Not block_syndromes(*Data, *ecc\bs, npar, *s)
      ProcedureReturn #QUIRC_SUCCESS
    EndIf
    
    berlekamp_massey(*s, npar, @gf256, *sigma)
    
    ; Compute derivative of sigma
    FillMemory(*sigma_deriv, #MAX_POLY, 0)
    For i = 0 To #MAX_POLY - 1 Step 2
      *sigma_deriv\v[i] = *sigma\v[i + 1]
    Next i
    
    ; Compute error evaluator polynomial
    eloc_poly(*omega, *s, *sigma, npar - 1)
    
    ; Find error locations And magnitudes
    For i = 0 To *ecc\bs - 1
      xinv = *gf256_exp\v[255 - i]
      
      If Not poly_eval(*sigma, xinv, @gf256)
        sd_x = poly_eval(*sigma_deriv, xinv, @gf256)
        omega_x = poly_eval(*omega, xinv, @gf256)
        error = *gf256_exp\v[(255 - *gf256_log\v[sd_x] + *gf256_log\v[omega_x]) % 255]
        
        *Data\v[*ecc\bs - i - 1] ! error
      EndIf
    Next i
    
    If block_syndromes(*Data, *ecc\bs, npar, *s)
      ProcedureReturn #QUIRC_ERROR_DATA_ECC
    EndIf
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  ; Format value error correction
  ;
  ; Generator polynomial For GF(2^4) is x^4 + x + 1
  
  #FORMAT_MAX_ERROR = 3
  #FORMAT_SYNDROMES = (#FORMAT_MAX_ERROR * 2)
  #FORMAT_BITS = 15
  
  Procedure.i format_syndromes(u.u, *s.AsciiArrayStructure)
    
    Protected.i i, nonzero, j
    Protected.AsciiArrayStructure *gf16_exp
    
    
    *gf16_exp = ?gf16_exp
    
    FillMemory(*s, #MAX_POLY, 0)
    
    For i = 0 To #FORMAT_SYNDROMES - 1
      *s\v[i] = 0
      For j = 0 To #FORMAT_BITS - 1
        If u & (1 << j)
          *s\v[i] ! *gf16_exp\v[((i + 1) * j) % 15]
        EndIf
      Next j
      
      If *s\v[i]
        nonzero = 1
      EndIf
    Next i
    
    ProcedureReturn nonzero
    
  EndProcedure
  
  
  Procedure.i correct_format(*f_ret.Unicode)
    
    Protected.u u
    Protected.i i
    Protected.AsciiArrayStructure *s, *sigma, *gf16_exp
    
    
    *gf16_exp = ?gf16_exp
    u = *f_ret\u
    
    *s = AllocateMemory(#MAX_POLY)
    
    ; Evaluate U (received codeword) at each of alpha_1 .. alpha_6
    ; To get S_1 .. S_6 (but we index them from 0).
    If Not format_syndromes(u, *s)
      FreeMemory(*s)
      ProcedureReturn #QUIRC_SUCCESS
    EndIf
    
    *sigma = AllocateMemory(#MAX_POLY)
    berlekamp_massey(*s, #FORMAT_SYNDROMES, @gf16, *sigma)
    
    ; Now, find the roots of the polynomial
    For i = 0 To 14
      If Not poly_eval(*sigma, *gf16_exp\v[15 - i], @gf16)
        u ! (1 << i)
      EndIf
    Next i
    
    If format_syndromes(u, *s)
      FreeMemory(*s)
      FreeMemory(*sigma)
      ProcedureReturn #QUIRC_ERROR_FORMAT_ECC
    EndIf
    
    *f_ret\u = u
    
    FreeMemory(*s)
    FreeMemory(*sigma)
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  ;- Decoder algorithm
  
  Structure datastream
    raw.a[#QUIRC_MAX_PAYLOAD]
    data_bits.i
    ptr.i
    
    Data_.a[#QUIRC_MAX_PAYLOAD]
  EndStructure
  
  
  Procedure.i grid_bit(*code.quirc_code, x.i, y.i)
    
    Protected.i p
    
    
    p = y * *code\size + x
    
    ProcedureReturn (*code\cell_bitmap[p >> 3] >> (p & 7)) & 1
    
  EndProcedure
  
  
  Procedure.i read_format(*code.quirc_code, *Data.quirc_data, which.i)
    
    Protected.u format, fdata
    Protected.i i, err
    Protected.AsciiArrayStructure *xs, *ys
    
    
    DataSection
      xs:
      Data.a 8, 8, 8, 8, 8, 8, 8, 8, 7, 5, 4, 3, 2, 1, 0
      ys:
      Data.a 0, 1, 2, 3, 4, 5, 7, 8, 8, 8, 8, 8, 8, 8, 8
    EndDataSection
    
    *xs = ?xs
    *ys = ?ys
    
    If which
      For i = 0 To 6
        format = (format << 1) | grid_bit(*code, 8, *code\size - 1 - i)
      Next i
      For i = 0 To 7
        format = (format << 1) | grid_bit(*code, *code\size - 8 + i, 8)
      Next i
    Else
      For i = 14 To 0 Step -1
        format = (format << 1) | grid_bit(*code, *xs\v[i], *ys\v[i])
      Next i
    EndIf
    
    format ! $5412
    
    err = correct_format(@format)
    If err
      ProcedureReturn err
    EndIf
    
    fdata = format >> 10
    *Data\ecc_level = fdata >> 3
    *Data\mask = fdata & 7
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure.i mask_bit(mask.i, i.i, j.i)
    
    Protected Result.i
    
    
    Select mask
      Case 0: Result = ((i + j) % 2)
      Case 1: Result = (i % 2)
      Case 2: Result = (j % 3)
      Case 3: Result = ((i + j) % 3)
      Case 4: Result = (((i / 2) + (j / 3)) % 2)
      Case 5: Result = ((i * j) % 2 + (i * j) % 3)
      Case 6: Result = (((i * j) % 2 + (i * j) % 3) % 2)
      Case 7: Result = (((i * j) % 3 + (i + j) % 2) % 2)
      Default : Result = 0
    EndSelect
    
    If mask <= 7
      If Result > 0
        Result = 0
      Else
        Result = 1
      EndIf
    EndIf
    
    ProcedureReturn Result
    
  EndProcedure
  
  
  Procedure.i reserved_cell(version.i, i.i, j.i)
    
    Protected.i size, ai, aj, a, p
    Protected *ver.quirc_version_info
    
    
    *ver = ?quirc_version_db_0 + version * SizeOf(quirc_version_info)
    size = version * 4 + 17
    ai = -1
    aj = -1
    
    ; Finder + format: top left
    If i < 9 And j < 9
      ProcedureReturn #True
    EndIf
    
    ; Finder + format: bottom left
    If i + 8 >= size And j < 9
      ProcedureReturn #True
    EndIf
    
    ; Finder + format: top right
    If i < 9 And j + 8 >= size
      ProcedureReturn #True
    EndIf
    
    ; Exclude timing patterns
    If i = 6 Or j = 6
      ProcedureReturn #True
    EndIf
    
    ; Exclude version info, If it exists. Version info sits adjacent To
    ; the top-right And bottom-left finders in three rows, bounded by
    ; the timing pattern.
    If version >= 7
      If i < 6 And j + 11 >= size
        ProcedureReturn #True
      EndIf
      If i + 11 >= size And j < 6
        ProcedureReturn #True
      EndIf
    EndIf
    
    ; Exclude alignment patterns
    While a < #QUIRC_MAX_ALIGNMENT And *ver\apat[a]
      p = *ver\apat[a]
      
      If Abs(p - i) < 3
        ai = a
      EndIf
      If Abs(p - j) < 3
        aj = a
      EndIf
      a + 1
    Wend
    
    If ai >= 0 And aj >= 0
      a - 1
      If ai > 0 And ai < a
        ProcedureReturn #True
      EndIf
      If aj > 0 And aj < a
        ProcedureReturn #True
      EndIf
      If aj = a And ai = a
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
    
  EndProcedure
  
  
  Procedure read_bit(*code.quirc_code, *Data.quirc_data, *ds.datastream, i.i, j.i)
    
    Protected.i bitpos, bytepos, v
    
    
    bitpos = *ds\data_bits & 7
    bytepos = *ds\data_bits >> 3
    v = grid_bit(*code, j, i)
    
    If mask_bit(*Data\mask, i, j)
      v ! 1
    EndIf
    
    If v
      *ds\raw[bytepos] | ($80 >> bitpos)
    EndIf
    
    *ds\data_bits + 1
    
  EndProcedure
  
  
  Procedure read_data(*code.quirc_code, *Data.quirc_data, *ds.datastream)
    
    Protected.i y, x, dir
    
    
    y = *code\size - 1
    x = *code\size - 1
    dir = -1
    
    While x > 0
      If x = 6
        x - 1
      EndIf
      
      If Not reserved_cell(*Data\version, y, x)
        read_bit(*code, *Data, *ds, y, x)
      EndIf
      
      If Not reserved_cell(*Data\version, y, x - 1)
        read_bit(*code, *Data, *ds, y, x - 1)
      EndIf
      
      y + dir
      If y < 0 Or y >= *code\size
        dir = -dir
        x - 2
        y + dir
      EndIf
    Wend
    
  EndProcedure
  
  
  Procedure.i codestream_ecc(*Data.quirc_data, *ds.datastream)
    
    Protected.i lb_count, bc, ecc_offset, dst_offset, i, num_ec, err, j
    Protected *ver.quirc_version_info
    Protected.quirc_rs_params *sb_ecc, lb_ecc, *ecc
    Protected.AsciiArrayStructure *dst
    
    
    *ver = ?quirc_version_db_0 + *Data\version * SizeOf(quirc_version_info)
    *sb_ecc = @*ver\ecc[*Data\ecc_level]
    lb_count = (*ver\data_bytes - *sb_ecc\bs * *sb_ecc\ns) / (*sb_ecc\bs + 1)
    bc = lb_count + *sb_ecc\ns
    ecc_offset = *sb_ecc\dw * bc + lb_count
    
    CopyMemory(*sb_ecc, @lb_ecc, SizeOf(lb_ecc))
    lb_ecc\dw + 1
    lb_ecc\bs + 1
    
    For i = 0 To bc - 1
      *dst = @*ds\Data_[0] + dst_offset
      If i < *sb_ecc\ns
        *ecc = *sb_ecc
      Else
        *ecc = @lb_ecc
      EndIf
      num_ec = *ecc\bs - *ecc\dw
      
      For j = 0 To *ecc\dw - 1
        *dst\v[j] = *ds\raw[j * bc + i]
      Next j
      For j = 0 To num_ec - 1
        *dst\v[*ecc\dw + j] = *ds\raw[ecc_offset + j * bc + i]
      Next j
      
      err = correct_block(*dst, *ecc)
      If err
        ProcedureReturn err
      EndIf
      
      dst_offset + *ecc\dw
    Next i
    
    *ds\data_bits = dst_offset * 8
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure.i bits_remaining(*ds.datastream)
    ProcedureReturn *ds\data_bits - *ds\ptr
  EndProcedure
  
  
  Procedure.i take_bits(*ds.datastream, len.i)
    
    Protected.a b
    Protected.i ret, bitpos
    
    
    While Len And (*ds\ptr < *ds\data_bits)
      b = *ds\Data_[*ds\ptr >> 3]
      bitpos = *ds\ptr & 7
      
      ret = ret << 1
      If (b << bitpos) & $80
        ret | 1
      EndIf
      
      *ds\ptr + 1
      len - 1
    Wend
    
    ProcedureReturn ret
    
  EndProcedure
  
  
  Procedure.i numeric_tuple(*Data.quirc_data, *ds.datastream, bits.i, digits.i)
    
    Protected.i tuple, i
    
    
    If bits_remaining(*ds) < bits
      ProcedureReturn -1
    EndIf
    
    tuple = take_bits(*ds, bits)
    
    For i = digits - 1 To 0 Step -1
      *Data\payload[*Data\payload_len + i] = tuple % 10 + '0'
      tuple / 10
    Next i
    
    *Data\payload_len + digits
    
    ProcedureReturn 0
    
  EndProcedure
  
  
  Procedure.i decode_numeric(*Data.quirc_data, *ds.datastream)
    
    Protected.i bits, count
    
    
    bits = 14
    
    If *Data\version < 10
      bits = 10
    ElseIf *Data\version < 27
      bits = 12
    EndIf
    
    count = take_bits(*ds, bits)
    If *Data\payload_len + count + 1 > #QUIRC_MAX_PAYLOAD
      ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
    EndIf
    
    While count >= 3
      If numeric_tuple(*Data, *ds, 10, 3) < 0
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      count - 3
    Wend
    
    If count >= 2
      If numeric_tuple(*Data, *ds, 7, 2) < 0
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      count - 2
    EndIf
    
    If count
      If numeric_tuple(*Data, *ds, 4, 1) < 0
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      count - 1
    EndIf
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  DataSection
    alpha_map:
    Data.a '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    Data.a 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    Data.a ' ', '$', '%', '*', '+', '-', '.', '/', ':'
  EndDataSection
  
  
  Procedure.i alpha_tuple(*Data.quirc_data, *ds.datastream, bits.i, digits.i)
    
    Protected.i tuple, i
    
    
    If bits_remaining(*ds) < bits
      ProcedureReturn -1
    EndIf
    
    tuple = take_bits(*ds, bits)
    
    For i = 0 To digits - 1
      *Data\payload[*Data\payload_len + digits - i - 1] = PeekA(?alpha_map + (tuple % 45))
      tuple / 45
    Next i
    
    *Data\payload_len + digits
    
    ProcedureReturn 0                   ;
    
  EndProcedure
  
  
  Procedure.i decode_alpha(*Data.quirc_data, *ds.datastream)
    
    Protected.i bits, count
    
    
    bits = 13
    
    If *Data\version < 10
      bits = 9
    ElseIf *Data\version < 27
      bits = 11
    EndIf
    
    count = take_bits(*ds, bits)
    If *Data\payload_len + count + 1 > #QUIRC_MAX_PAYLOAD
      ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
    EndIf
    
    While count >= 2
      If alpha_tuple(*Data, *ds, 11, 2) < 0
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      count - 2
    Wend
    
    If count
      If alpha_tuple(*Data, *ds, 6, 1) < 0
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      count - 1
    EndIf
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure.i decode_byte(*Data.quirc_data, *ds.datastream)
    
    Protected.i bits, count, i
    
    
    bits = 16
    
    If *Data\version < 10
      bits = 8
    EndIf
    
    count = take_bits(*ds, bits)
    If *Data\payload_len + count + 1 > #QUIRC_MAX_PAYLOAD
      ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
    EndIf
    If bits_remaining(*ds) < count * 8
      ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
    EndIf
    
    For i = 0 To count - 1
      *Data\payload[*Data\payload_len] = take_bits(*ds, 8)
      *Data\payload_len + 1
    Next i
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure.i decode_kanji(*Data.quirc_data, *ds.datastream)
    
    Protected.u sjw
    Protected.i bits, count, i, d, msB, lsB, intermediate
    
    
    bits = 12
    
    If *Data\version < 10
      bits = 8
    ElseIf *Data\version < 27
      bits = 10
    EndIf
    
    count = take_bits(*ds, bits)
    If *Data\payload_len + count * 2 + 1 > #QUIRC_MAX_PAYLOAD
      ProcedureReturn #QUIRC_ERROR_DATA_OVERFLOW
    EndIf
    If bits_remaining(*ds) < count * 13
      ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
    EndIf
    
    For i = 0 To count - 1
      d = take_bits(*ds, 13)
      msB = d / $c0
      lsB = d % $c0
      intermediate = (msB << 8) | lsB
      
      If intermediate + $8140 <= $9ffc
        ; bytes are in the range 0x8140 To 0x9FFC
        sjw = intermediate + $8140
      Else
        ; bytes are in the range 0xE040 To 0xEBBF
        sjw = intermediate + $c140
      EndIf
      
      *Data\payload[*Data\payload_len] = sjw >> 8
      *Data\payload_len + 1
      *Data\payload[*Data\payload_len] = sjw & $ff
      *Data\payload_len + 1
    Next i
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure.i decode_eci(*Data.quirc_data, *ds.datastream)
    
    If bits_remaining(*ds) < 8
      ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
    EndIf
    
    *Data\eci = take_bits(*ds, 8)
    
    If (*Data\eci & $c0) = $80
      If bits_remaining(*ds) < 8
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      
      *Data\eci = (*Data\eci << 8) | take_bits(*ds, 8)
    ElseIf (*Data\eci & $e0) = $c0
      If bits_remaining(*ds) < 16
        ProcedureReturn #QUIRC_ERROR_DATA_UNDERFLOW
      EndIf
      
      *Data\eci = (*Data\eci << 16) | take_bits(*ds, 16)
    EndIf
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure.i decode_payload(*Data.quirc_data, *ds.datastream)
    
    Protected.i err, type
    
    
    While bits_remaining(*ds) >= 4
      err = #QUIRC_SUCCESS
      type = take_bits(*ds, 4)
      
      Select type
        Case #QUIRC_DATA_TYPE_NUMERIC : err = decode_numeric(*Data, *ds)
        Case #QUIRC_DATA_TYPE_ALPHA : err = decode_alpha(*Data, *ds)
        Case #QUIRC_DATA_TYPE_BYTE : err = decode_byte(*Data, *ds)
        Case #QUIRC_DATA_TYPE_KANJI : err = decode_kanji(*Data, *ds)
        Case 7: err = decode_eci(*Data, *ds)
        Default
          ; Add nul terminator To all payloads
          If *Data\payload_len >= SizeOf(*Data\payload)
            *Data\payload_len - 1
          EndIf
          *Data\payload[*Data\payload_len] = 0
          
          ProcedureReturn #QUIRC_SUCCESS
      EndSelect
      
      If err
        ProcedureReturn err
      EndIf
      
      If Not (type & (type - 1)) And (type > *Data\data_type)
        *Data\data_type = type
      EndIf
    Wend
    ; Add nul terminator To all payloads
    If *Data\payload_len >= SizeOf(*Data\payload)
      *Data\payload_len - 1
    EndIf
    *Data\payload[*Data\payload_len] = 0
    
    ProcedureReturn #QUIRC_SUCCESS   
    
  EndProcedure
  
  
  Procedure.i quirc_decode(*code.quirc_code, *Data.quirc_data)
    
    Protected.i err
    Protected ds.datastream
    
    
    If (*code\size - 17) % 4
      ProcedureReturn #QUIRC_ERROR_INVALID_GRID_SIZE
    EndIf
    
    FillMemory(*Data, SizeOf(*data), 0)
    FillMemory(@ds, SizeOf(ds), 0)
    
    *Data\version = (*code\size - 17) / 4
    
    If *Data\version < 1 Or *Data\version > #QUIRC_MAX_VERSION
      ProcedureReturn #QUIRC_ERROR_INVALID_VERSION
    EndIf
    
    ; Read format information -- try both locations
    err = read_format(*code, *Data, 0)
    If err
      err = read_format(*code, *Data, 1)
      If err
        ProcedureReturn err
      EndIf
    EndIf
    
    read_data(*code, *Data, @ds)
    err = codestream_ecc(*Data, @ds)
    If err
      ProcedureReturn err
    EndIf
    
    err = decode_payload(*Data, @ds)
    If err
      ProcedureReturn err
    EndIf
    
    ProcedureReturn #QUIRC_SUCCESS
    
  EndProcedure
  
  
  Procedure quirc_flip(*code.quirc_code)
    
    Protected.i offset, y, x
    Protected flipped.quirc_code
    
    
    For y = 0 To *code\size - 1
      For x = 0 To *code\size - 1
        If grid_bit(*code, y, x)
          flipped\cell_bitmap[offset >> 3] | (1 << (offset & 7))
        EndIf
        offset + 1
      Next x
    Next y
    
    CopyMemory(@flipped\cell_bitmap, @*code\cell_bitmap, SizeOf(flipped\cell_bitmap))
    
  EndProcedure
  
  
  
  
  Procedure.i ImageToGrayScaleBuffer(Img.i)
    
    Structure rgba
      b.a
      g.a
      r.a
      a.a
    EndStructure
    
    
    Protected.i ImgWidth, ImgHeight, PixelBytes, LinePadBytes, X, Y
    Protected *Buffer, *BufferPos.Ascii, *ImgPos.rgba
    
    
    If IsImage(Img)
      
      If StartDrawing(ImageOutput(Img))
        
        ImgWidth = ImageWidth(Img)
        ImgHeight = ImageHeight(Img)
        
        *Buffer = AllocateMemory(ImgWidth * ImgHeight, #PB_Memory_NoClear)
        If *Buffer
          PixelBytes = 3
          *ImgPos = DrawingBuffer()
          
          If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_RGB : PixelBytes = 4 : EndIf
          If DrawingBufferPixelFormat() & #PB_PixelFormat_32Bits_BGR : PixelBytes = 4 : EndIf
          LinePadBytes = DrawingBufferPitch() - (ImgWidth * PixelBytes)
          
          Debug "PixelBytes: " + Str(PixelBytes)
          
          ImgWidth - 1
          ImgHeight - 1
          
          *BufferPos = *Buffer
          
          For Y = 0 To ImgHeight
            For X = 0 To ImgWidth
              ;Debug Hex(*ImgPos\a) + " " + Hex(*ImgPos\r) + " " + Hex(*ImgPos\g) + " " + Hex(*ImgPos\b)
              If PixelBytes = 3
                *BufferPos\a = (*ImgPos\r + *ImgPos\g  + *ImgPos\b) / 3
              Else
                ;*BufferPos\a = (*ImgPos\r + *ImgPos\g  + *ImgPos\b + *ImgPos\a) / 4
                If *ImgPos\a > 127
                  *BufferPos\a = (*ImgPos\r + *ImgPos\g  + *ImgPos\b) / 3
                Else
                  *BufferPos\a = $FF
                EndIf
              EndIf
              ;*BufferPos\a = 0.2990 * *ImgPos\r + 0.5870 * *ImgPos\g  + 0.1140 * *ImgPos\b ; TV
              ;*BufferPos\a = 0.2126 * *ImgPos\r + 0.7152 * *ImgPos\g  + 0.0722 * *ImgPos\b ; ITU-R BT.709 HDTV and CIE 1931 sRGB
              ;*BufferPos\a = 0.2627 * *ImgPos\r + 0.6780 * *ImgPos\g  + 0.0593 * *ImgPos\b ; ITU-R BT.2100 HDR
              *BufferPos + 1
              *ImgPos + PixelBytes
            Next X
            *ImgPos + LinePadBytes
          Next Y
          
        EndIf
        StopDrawing()
      EndIf
      
    EndIf
    
    ProcedureReturn *Buffer
    
  EndProcedure
  
  ;-Utils
  
  Procedure.s data_type_str(dt.i)
    
    Protected Result$
    
    
    Select dt
      Case #QUIRC_DATA_TYPE_NUMERIC : Result$ = "NUMERIC"
      Case #QUIRC_DATA_TYPE_ALPHA :   Result$ = "ALPHA"
      Case #QUIRC_DATA_TYPE_BYTE :    Result$ = "BYTE"
      Case #QUIRC_DATA_TYPE_KANJI :   Result$ = "KANJI"
      Default : Result$ = "unknown"
    EndSelect
    
    ProcedureReturn Result$
    
  EndProcedure
  
  
  
  Procedure dump_data(*Data.quirc_data)
    
    Debug "    Version: " + Str(*Data\version)
    Debug "    ECC level: " + Str(*Data\ecc_level)
    Debug "    Mask: " + Str(*Data\mask)
    Debug "    Data type: " + Str(*Data\data_type) + " (" + data_type_str(*Data\data_type) + ")"
    Debug "    Length: " + Str(*Data\payload_len)
    Debug "    Payload: " + PeekS(@*Data\payload[0], *Data\payload_len, #PB_Ascii)
    
    If *Data\eci
      Debug "    ECI: " + Str(*Data\eci)
    EndIf
    
  EndProcedure
  
  
  Procedure dump_cells(*code.quirc_code)
    
    Protected.i u, v, p
    Protected Line$
    
    
    Line$ = #LF$ + "    " + Str(*code\size) + " cells, corners:"
    For u = 0 To 3
      Line$ + " (" + Str(*code\corners[u]\x) + "," + Str(*code\corners[u]\y) + ")"
    Next u
    Debug Line$
    
    For v = 0 To *code\size - 1
      Line$ = "    "
      For u = 0 To *code\size - 1
        p = v * *code\size + u
        
        If *code\cell_bitmap[p >> 3] & (1 << (p & 7))
          Line$ + "[]"
        Else
          Line$ + "  "
        EndIf
      Next u
      Debug Line$
    Next v
    
  EndProcedure
  
  
  ;-for PureBasic
  
  
  
  
  Procedure.s QRCodeDecode(Image.i)
    
    Protected PayLoad$
    Protected.i width, height, count, i, err
    Protected *qr.quirc, *ImgBuffer
    Protected qcode.quirc_code, qdata.quirc_data
    
    
    
    If IsImage(Image)
      *ImgBuffer = ImageToGrayScaleBuffer(Image)
      If *ImgBuffer
        
        ;ShowMemoryViewer(*ImgBuffer, MemorySize(*ImgBuffer))
        
        *qr = quirc_new()
        If *qr
          If quirc_resize(*qr, ImageWidth(Image), ImageHeight(Image)) >= 0
            
            If quirc_begin(*qr, @width, @height)
              
              CopyMemory(*ImgBuffer, *qr\image, MemorySize(*ImgBuffer))
              
              quirc_end(*qr)
              
              count = quirc_count(*qr)
              For i = 0 To count - 1
                quirc_extract(*qr, i, @qcode)
                err = quirc_decode(@qcode, @qdata)
                If err = #QUIRC_ERROR_DATA_ECC
                  quirc_flip(@qcode)
                  err = quirc_decode(@qcode, @qData)
                EndIf
                
                dump_cells(@qcode)
                
                If err = #QUIRC_SUCCESS
                  dump_data(@qdata)
                  PayLoad$ = PeekS(@qData\payload[0], qData\payload_len, #PB_Ascii)
                Else
                  Debug quirc_strerror(err)
                EndIf
              Next i
              
            EndIf
            
            quirc_destroy(*qr)
          Else
            Debug "Was not able to resize quirc"
          EndIf
        Else
          Debug "Was not able to init quirc"
        EndIf
        FreeMemory(*ImgBuffer)
      EndIf
    EndIf
    
    ProcedureReturn PayLoad$
    
  EndProcedure
  
EndModule



;-Demo
CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  Define Filename$, Image.i, PayLoad$, WFactor.f, HFactor.f
  
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  
  Filename$ = OpenFileRequester("Choose an image with a QR-Code inside", "", "IMG|*.bmp;*.png;*.jpg", 0)
  If Filename$
    Image = LoadImage(#PB_Any, Filename$)
    If Image
      
      PayLoad$ = Quirc::QRCodeDecode(Image)
      If PayLoad$ = ""
        PayLoad$ = "No QR-Code detected!"
      EndIf
      
      WFactor = 1.0
      If ImageWidth(Image) > 800
        WFactor = 800 / ImageWidth(Image)
      EndIf
      
      HFactor = 1.0
      If ImageHeight(Image) > 600
        HFactor = 600 / ImageHeight(Image)
      EndIf
      
      If WFactor <> 1 Or HFactor <> 1
        If WFactor < HFactor
          ResizeImage(Image, ImageWidth(Image) * WFactor, ImageHeight(Image) * WFactor)
        Else
          ResizeImage(Image, ImageWidth(Image) * HFactor, ImageHeight(Image) * HFactor)
        EndIf
      EndIf
      
      OpenWindow(0, 0, 0, ImageWidth(Image), ImageHeight(Image) + 100, "QUIRC Demo", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
      ImageGadget(0, 0, 0, 0, 0, ImageID(Image))
      EditorGadget(1, 10, ImageHeight(Image) + 10, ImageWidth(Image) - 20, WindowHeight(0) - ImageHeight(Image) - 20)
      
      SetGadgetText(1, PayLoad$)
      
      Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
      
      FreeImage(Image)
    EndIf
  EndIf
  
CompilerEndIf
