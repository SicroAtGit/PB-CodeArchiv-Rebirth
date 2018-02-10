
DeclareModule Drawing3D
	
	;- Constants
	
	; Ignore a color parameter
	#Drawing3D_Ignore = -$100000000
	
		
	Enumeration
		#Drawing3D_Default   = %000
		#Drawing3D_Outline   = %001
		#Drawing3D_FrontOnly = %010
	EndEnumeration
	
	;- Functions
	
	Declare.i Image3DID(Image3D.i)
	Declare.i FreeImage3D(Image3D.i)
	Declare CreateImage3D(Image3D.i, Image.i=#PB_Default, Width.i=0, Height.i=0)
	
	Declare StartDrawing3D(Output.i, FieldOfView.f=75)
	Declare StopDrawing3D()
	
	Declare Drawing3DMode(Mode.i)
	Declare Drawing3DPosition(X.f, Y.f, Z.f, Mode.i=#PB_Absolute)
	Declare Drawing3DRotation(RotationX.f, RotationY.f, RotationZ.f, Mode.i=#PB_Absolute)
	Declare Drawing3DBackground(Color.l=$FF000000)
	Declare Drawing3DStyle(Mode.i, Parameter1.f, Parameter2.f)
	Declare Drawing3DLight(DirectionX.f, DirectionY.f, DirectionZ.f, Color.l)
	
	Declare DrawPoint3D(X.f, Y.f, Z.f, Color.q)
	Declare DrawLine3D(X1.f, Y1.f, Z1.f, X2.f, Y2.f, Z2.f, Color1.q, Color2.q=#Drawing3D_Ignore)
	Declare DrawTriangle3D(X1.f, Y1.f, Z1.f, X2.f, Y2.f, Z2.f, X3.f, Y3.f, Z3.f, Color1.q, Color2.q=#Drawing3D_Ignore, Color3.q=#Drawing3D_Ignore)
	Declare DrawPlane3D(X.f, Y.f, Z.f, Width.f, Height.f, RotationX.f, RotationY.f, RotationZ.f, Color1.q, Color2.q=#Drawing3D_Ignore, Color3.q=#Drawing3D_Ignore, Color4.q=#Drawing3D_Ignore)
	Declare DrawDisk3D(X.f, Y.f, Z.f, Radius.f, RotationX.f, RotationY.f, RotationZ.f, Color.q)
	Declare DrawBox3D(X.f, Y.f, Z.f, Width.f, Height.f, Depth.f, RotationX.f, RotationY.f, RotationZ.f, Color.q)
	Declare DrawCylinder3D(X.f, Y.f, Z.f, Radius.f, Height.f, RotationX.f, RotationY.f, RotationZ.f, Color1.q, Color2.q=#Drawing3D_Ignore, Detail.i=36)
	Declare DrawImage3D(Image3D.i, X.f, Y.f, Z.f, Width.f, Height.f, RotationX.f=0, RotationY.f=0, RotationZ.f=0)
	Declare DrawTranformedImage3D(Image3D.i, X1.f, Y1.f, Z1.f, X2.f, Y2.f, Z2.f, X3.f, Y3.f, Z3.f, X4.f, Y4.f, Z4.f)
	Declare DrawText3D(X.f, Y.f, Z.f, RotationX.f, RotationY.f, RotationZ.f, Text.s, Color.i)

EndDeclareModule




Module Drawing3D


EnableExplicit



#Drawing3D_Inv255 = 1.0 / 255
#Drawing3D_Inv255255 = 1.0 / 255 / 255
#Drawing3D_SSE = #True
#Drawing3D_PixelListSize = $10000

;- Structures

Structure Color4
	Alpha.f               ; Intensität [0.0, 1.0]
	Blue.f                ; Blau [0.0, Intensität]
	Green.f               ; Gr?n [0.0, Intensität]
	Red.f                 ; Rot [0.0, Intensität]
EndStructure

Structure Vector4
	W.f                   ; {0,1} order 1/Z
	X.f                   ; X-Koordinate
	Y.f                   ; Y-Koordinate
	Z.f                   ; Z-Koordinate
EndStructure

Structure Drawing3D_Vertex Extends Vector4
	Color.Color4 ; Farbe
EndStructure

Structure Matrix4
	A11.f : A21.f : A31.f : A41.f ; Matrixkomponenten
	A12.f : A22.f : A32.f : A42.f ;  Matrix = {Vektor1, Vektor2, Vektor3, Vektor4}
	A13.f : A23.f : A33.f : A43.f ;  Vektor = {X, Y, Z, W}
	A14.f : A24.f : A34.f : A44.f
EndStructure


Structure Drawing3D_Pixel
	Color.Color4          ; Farbe
	Distance.f                     ; Abstand zur Camera (negativ)
	*PreviousPixel.Drawing3D_Pixel ; Pixel der dahinter liegt
EndStructure


Structure Drawing3D_Point
	Vertex.Drawing3D_Vertex
EndStructure

Structure Drawing3D_Line
	Vertex.Drawing3D_Vertex[2]
EndStructure

Structure Drawing3D_Triangle
	Vertex.Drawing3D_Vertex[3]
EndStructure

Structure Drawing3D_Box
	Vertex.Drawing3D_Vertex[8]
EndStructure

Structure Drawing3D_Plane
	Vertex.Drawing3D_Vertex[4]
EndStructure

Structure Drawing3D_Disk
	Vertex.Drawing3D_Vertex[4]
EndStructure

Structure Drawing3D_Cylinder
	Vertex.Drawing3D_Vertex[6]
EndStructure

Structure Drawing3D_Light
	Direction.Vector4
	Color.Color4
EndStructure

Structure Drawing3D_Cluster
	Type.i
	Position.Vector4
	Orientation.Matrix4
	List		Triangle.Drawing3D_Triangle()
	List		*Cluster.Drawing3D_Cluster()
EndStructure

Structure Drawing3D_Object
	StructureUnion
		Type.i
; 		Cluster.Drawing3D_Cluster
; 		Line.Drawing3D_Line
; 		Triangle.Drawing3D_Triangle
	EndStructureUnion
EndStructure

Structure Drawing3D_Image
	Number.i
	Array Pixel.Color4(0,0)
	Width.i
	Height.i
EndStructure

Structure Drawing3D_PixelList
	Pixel.Drawing3D_Pixel[#Drawing3D_PixelListSize]           ; Liste aller zu zeichnenden Pixel
EndStructure

Structure Drawing3DInclude
	CurrentColor.Color4[3]
	Array		*PixelIndex.Drawing3D_Pixel(0, 0) ; Index der Pixel f?r schnelleren Zugriff
	List		PixelList.Drawing3D_PixelList()           ; Liste aller zu zeichnenden Pixel
	CurrentPixelIndex.i
	List		Cluster.Drawing3D_Cluster()
	List		Light.Drawing3D_Light()           ; Liste aller Lichtquellen
	*CurrentCluster.Drawing3D_Cluster
	Orientation.Matrix4              ; Orientierung der Szene
	Position.Vector4                 ; Position der Kamera
	Background.Color4                ; Hintergrundfarbe
	MainCluster.Drawing3D_Cluster
	MaxX.i
	MaxY.i
	CenterX.i
	CenterY.i
	Distance.f
	*CurrentImage3D.Drawing3D_Image
	List		Image3D.Drawing3D_Image()
	Array		*Image3DID.Drawing3D_Image(0)
	Mode.i
EndStructure


Global Drawing3DInclude.Drawing3DInclude



;- Private: General



Procedure.f Min(Value1.f, Value2.f, Value3.f=1e1000)
	
	If Value3 < Value2
		If Value3 < Value1
			ProcedureReturn Value3
		Else
			ProcedureReturn Value1
		EndIf
	ElseIf Value2 < Value1
		ProcedureReturn Value2
	Else
		ProcedureReturn Value1
	EndIf
	
EndProcedure


Procedure.f Max(Value1.f, Value2.f, Value3.f=-1e1000)
	
	If Value3 > Value2
		If Value3 > Value1
			ProcedureReturn Value3
		Else
			ProcedureReturn Value1
		EndIf
	ElseIf Value2 > Value1
		ProcedureReturn Value2
	Else
		ProcedureReturn Value1
	EndIf
	
EndProcedure



;- Private: Color



; Wandelt eine 32-Bit Farbe in eine 4-Float-Farbe um.
Procedure.i SetColor(*Use.Color4, Color.l)
	
	Protected Factor.f = Alpha(Color) * #Drawing3D_Inv255255
	
	*Use\Alpha = 255 * Factor
	*Use\Red   = Red(Color) * Factor
	*Use\Green = Green(Color) * Factor
	*Use\Blue  = Blue(Color) * Factor
	
	ProcedureReturn *Use
	
EndProcedure


; Wandelt eine 4-Float-Farbe in eine 32-Bit Farbe um.
Procedure.l GetColor(*Source.Color4)
	
	Protected Factor.f, Alpha.i, Red.i, Green.i, Blue.i
	
	If *Source\Alpha
		Factor = 255.0/*Source\Alpha
		Alpha  = *Source\Alpha*255
		Red    = *Source\Red*Factor
		Green  = *Source\Green*Factor
		Blue   = *Source\Blue*Factor
		ProcedureReturn Red | Green<<8 | Blue<<16 | Alpha<<24
	Else
		ProcedureReturn $00000000
	EndIf
	
EndProcedure


; Blendet die Source-Farbe auf die Use-Farbe drauf.
Procedure BlendColor(*Use.Color4, *Source.Color4)
	
	CompilerIf #Drawing3D_SSE
		
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			! MOV    rax, [p.p_Use]
			! MOV    rdx, [p.p_Source]
			! MOVUPS xmm0, [rax]
			! MOVUPS xmm1, [rdx]
			! MOVUPS xmm2, [drawing3d.ll_blendcolor_packedfloatwith1]
			! MOVAPS xmm3, xmm1
			! SHUFPS xmm3, xmm3, 00000000b
			! SUBPS  xmm2, xmm3
			! MULPS  xmm0, xmm2
			! ADDPS  xmm0, xmm1
			! MOVUPS [rax], xmm0
		CompilerElse
			! MOV    eax, [p.p_Use]
			! MOV    edx, [p.p_Source]
			! MOVUPS xmm0, [eax]
			! MOVUPS xmm1, [edx]
			! MOVUPS xmm2, [drawing3d.ll_blendcolor_packedfloatwith1]
			! MOVAPS xmm3, xmm1
			! SHUFPS xmm3, xmm3, 00000000b
			! SUBPS  xmm2, xmm3
			! MULPS  xmm0, xmm2
			! ADDPS  xmm0, xmm1
			! MOVUPS [eax], xmm0
		CompilerEndIf
		
		ProcedureReturn
		
		DataSection
			PackedFloatWith1: : Data.f 1.0, 1.0, 1.0, 1.0
		EndDataSection
		
	CompilerElse
		
		Protected InvAlpha.f = 1.0 - *Source\Alpha
		
		*Use\Red   * InvAlpha + *Source\Red
		*Use\Green * InvAlpha + *Source\Green
		*Use\Blue  * InvAlpha + *Source\Blue
		*Use\Alpha * InvAlpha + *Source\Alpha
		
		ProcedureReturn *Use
		
	CompilerEndIf
	
EndProcedure


Procedure.i NormalizeColor(*Use.Color4)
	
	Protected Max.f = Max(*Use\Red, *Use\Green, *Use\Blue)
	
	If Max > 1
		*Use\Red / Max
		*Use\Green / Max
		*Use\Blue / Max
	EndIf
	
	*Use\Red * *Use\Alpha
	*Use\Green * *Use\Alpha
	*Use\Blue * *Use\Alpha
	
	ProcedureReturn *Use
	
EndProcedure


; Mischt eine Farbe aus bis zu drei verschiedenen Eckfarben
Procedure.i ColorMix(*Color.Color4, Factor1.f=1.0, Factor2.f=0.0, Factor3.f=0.0)
	
	CompilerIf #Drawing3D_SSE
		
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			! MOV    rax, [p.p_Color]
			! MOV    rdx, drawing3d.v_Drawing3DInclude
			! MOVUPS xmm1, [rdx+0]
			! MOVUPS xmm2, [rdx+16]
			! MOVUPS xmm3, [rdx+32]
			! MOVSS  xmm4, [p.v_Factor1]
			! MOVSS  xmm5, [p.v_Factor2]
			! MOVSS  xmm6, [p.v_Factor3]
			! SHUFPS xmm4, xmm4, 000000000b
			! SHUFPS xmm5, xmm5, 000000000b
			! SHUFPS xmm6, xmm6, 000000000b
			! MULPS  xmm1, xmm4
			! MULPS  xmm2, xmm5
			! MULPS  xmm3, xmm6
			! ADDPS  xmm1, xmm2
			! ADDPS  xmm1, xmm3
			! MOVUPS [rax], xmm1
		CompilerElse
			! MOV    eax, [p.p_Color]
			! MOV    edx, drawing3d.v_Drawing3DInclude
			! MOVUPS xmm1, [edx+0]
			! MOVUPS xmm2, [edx+16]
			! MOVUPS xmm3, [edx+32]
			! MOVSS  xmm4, [p.v_Factor1]
			! MOVSS  xmm5, [p.v_Factor2]
			! MOVSS  xmm6, [p.v_Factor3]
			! SHUFPS xmm4, xmm4, 000000000b
			! SHUFPS xmm5, xmm5, 000000000b
			! SHUFPS xmm6, xmm6, 000000000b
			! MULPS  xmm1, xmm4
			! MULPS  xmm2, xmm5
			! MULPS  xmm3, xmm6
			! ADDPS  xmm1, xmm2
			! ADDPS  xmm1, xmm3
			! MOVUPS [eax], xmm1
		CompilerEndIf
		
		ProcedureReturn
		
	CompilerElse
		
		Protected *C1.Color4 = Drawing3DInclude\CurrentColor[0]
		Protected *C2.Color4 = Drawing3DInclude\CurrentColor[1]
		Protected *C3.Color4 = Drawing3DInclude\CurrentColor[2]
		*Color\Alpha = *C1\Alpha*Factor1 + *C2\Alpha*Factor2 + *C3\Alpha*Factor3
		*Color\Red   = *C1\Red  *Factor1 + *C2\Red  *Factor2 + *C3\Red  *Factor3
		*Color\Green = *C1\Green*Factor1 + *C2\Green*Factor2 + *C3\Green*Factor3
		*Color\Blue  = *C1\Blue *Factor1 + *C2\Blue *Factor2 + *C3\Blue *Factor3
		
		ProcedureReturn *Color
		
	CompilerEndIf
	
EndProcedure


Procedure.i ImageColor(*Color.Color4, X.f, Y.f)
	Protected *Image3D.Drawing3D_Image = Drawing3DInclude\CurrentImage3D
	Protected Null.Color4
	Protected FX.f = Mod(X**Image3D\Width+0.5, 1.0)
	Protected FY.f = Mod(Y**Image3D\Height+0.5, 1.0)
	Protected PixelX0.i = X * (*Image3D\Width+2)  - 1.5 - FX
	Protected PixelY0.i = Y * (*Image3D\Height+2) - 1.5 - FY
	Protected PixelX1.i = X * (*Image3D\Width+2)  - 0.5 - FX
	Protected PixelY1.i = Y * (*Image3D\Height+2) - 0.5 - FY
; 	If PixelX0 < 0 : PixelX0 = 0 : EndIf
; 	If PixelY0 < 0 : PixelY0 = 0 : EndIf
; 	If PixelX1 > *Image3D\Width-1 : PixelX1 = *Image3D\Width-1 : EndIf
; 	If PixelY1 > *Image3D\Height-1 : PixelY1 = *Image3D\Height-1 : EndIf
; 	Protected *C00.Color4 = *Image3D\Pixel(PixelX0, PixelY0)
; 	Protected *C10.Color4 = *Image3D\Pixel(PixelX1, PixelY0)
; 	Protected *C01.Color4 = *Image3D\Pixel(PixelX0, PixelY1)
; 	Protected *C11.Color4 = *Image3D\Pixel(PixelX1, PixelY1)
	Protected.Color4 *C00 = @Null, *C10 = @Null, *C01 = @Null, *C11 = @Null
	If PixelX0 >= 0 And PixelX0 < *Image3D\Width And PixelY0 >= 0 And PixelY0 < *Image3D\Height : *C00 = *Image3D\Pixel(PixelX0, PixelY0) : EndIf
	If PixelX1 >= 0 And PixelX1 < *Image3D\Width And PixelY0 >= 0 And PixelY0 < *Image3D\Height : *C10 = *Image3D\Pixel(PixelX1, PixelY0) : EndIf
	If PixelX0 >= 0 And PixelX0 < *Image3D\Width And PixelY1 >= 0 And PixelY1 < *Image3D\Height : *C01 = *Image3D\Pixel(PixelX0, PixelY1) : EndIf
	If PixelX1 >= 0 And PixelX1 < *Image3D\Width And PixelY1 >= 0 And PixelY1 < *Image3D\Height : *C11 = *Image3D\Pixel(PixelX1, PixelY1) : EndIf
	*Color\Alpha = *C00\Alpha*(1-FX)*(1-FY) + *C10\Alpha*(FX)*(1-FY) + *C01\Alpha*(1-FX)*(FY) + *C11\Alpha*(FX)*(FY)
	*Color\Red   = *C00\Red  *(1-FX)*(1-FY) + *C10\Red  *(FX)*(1-FY) + *C01\Red  *(1-FX)*(FY) + *C11\Red  *(FX)*(FY)
	*Color\Green = *C00\Green*(1-FX)*(1-FY) + *C10\Green*(FX)*(1-FY) + *C01\Green*(1-FX)*(FY) + *C11\Green*(FX)*(FY)
	*Color\Blue  = *C00\Blue *(1-FX)*(1-FY) + *C10\Blue *(FX)*(1-FY) + *C01\Blue *(1-FX)*(FY) + *C11\Blue *(FX)*(FY)
EndProcedure



;- Private: Math


Procedure.i V4_Set(*Out.Vector4, X.f=0.0, Y.f=0.0, Z.f=0.0, W.f=0.0)
	*Out\X = X
	*Out\Y = Y
	*Out\Z = Z
	*Out\W = W
	ProcedureReturn *Out
EndProcedure


Procedure.i V4_Add(*InOut.Vector4, *In.Vector4)
	CompilerIf #Drawing3D_SSE
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			! MOV rax, [p.p_InOut]
			! MOV rdx, [p.p_In]
			! MOVUPS xmm0, [rax]
			! MOVUPS xmm1, [rdx]
			! ADDPS  xmm0, xmm1
			! MOVUPS [rax], xmm0
		CompilerElse
			! MOV eax, [p.p_InOut]
			! MOV edx, [p.p_In]
			! MOVUPS xmm0, [eax]
			! MOVUPS xmm1, [edx]
			! ADDPS  xmm0, xmm1
			! MOVUPS [eax], xmm0
		CompilerEndIf
		ProcedureReturn
	CompilerElse
		*InOut\X + *In\X
		*InOut\Y + *In\Y
		*InOut\Z + *In\Z
		*InOut\W + *In\W
		ProcedureReturn *InOut
	CompilerEndIf
EndProcedure


Procedure.i V4_Subtract(*InOut.Vector4, *In.Vector4)
	CompilerIf #Drawing3D_SSE
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			! MOV rax, [p.p_InOut]
			! MOV rdx, [p.p_In]
			! MOVUPS xmm0, [rax]
			! MOVUPS xmm1, [rdx]
			! SUBPS  xmm0, xmm1
			! MOVUPS [rax], xmm0
		CompilerElse
			! MOV eax, [p.p_InOut]
			! MOV edx, [p.p_In]
			! MOVUPS xmm0, [eax]
			! MOVUPS xmm1, [edx]
			! SUBPS  xmm0, xmm1
			! MOVUPS [eax], xmm0
		CompilerEndIf
		ProcedureReturn
	CompilerElse
		*InOut\X - *In\X
		*InOut\Y - *In\Y
		*InOut\Z - *In\Z
		*InOut\W - *In\W
		ProcedureReturn *InOut
	CompilerEndIf
EndProcedure


Procedure.f V4_Length(*In.Vector4)
	ProcedureReturn Sqr( *In\X * *In\X + *In\Y * *In\Y + *In\Z * *In\Z )
EndProcedure


Procedure.i V4_Normalize(*InOut.Vector4)
	Protected Length.f = V4_Length(*InOut)
	If Length
		Length = 1.0 / Length
		*InOut\X * Length
		*InOut\Y * Length
		*InOut\Z * Length
	EndIf
	ProcedureReturn *InOut
EndProcedure


Procedure.i V4_Copy(*Out.Vector4, *In.Vector4)
	CompilerIf #Drawing3D_SSE
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			! MOV rax, [p.p_Out]
			! MOV rdx, [p.p_In]
			! MOVUPS xmm0, [rdx]
			! MOVUPS [rax], xmm0
		CompilerElse
			! MOV eax, [p.p_Out]
			! MOV edx, [p.p_In]
			! MOVUPS xmm0, [edx]
			! MOVUPS [eax], xmm0
		CompilerEndIf
		ProcedureReturn
	CompilerElse
		*Out\X = *In\X
		*Out\Y = *In\Y
		*Out\Z = *In\Z
		*Out\W = *In\W
		ProcedureReturn *Out
	CompilerEndIf
EndProcedure


Procedure.i V4_Crossing(*Out.Vector4, *In1.Vector4, *In2.Vector4)
	CompilerIf #Drawing3D_SSE
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			! MOV rax, [p.p_Out]
			! MOV rcx, [p.p_In1]
			! MOV rdx, [p.p_In2]
			! MOVUPS xmm0, [rcx]
			! MOVUPS xmm1, [rdx]
			! MOVAPS xmm2, xmm0
			! MOVAPS xmm3, xmm1
			! SHUFPS xmm0, xmm0, 01111000b
			! SHUFPS xmm1, xmm1, 10011100b
			! SHUFPS xmm2, xmm2, 10011100b
			! SHUFPS xmm3, xmm3, 01111000b
			! MULPS  xmm0, xmm1
			! MULPS  xmm2, xmm3
			! SUBPS  xmm0, xmm2
			! MOVUPS [rax], xmm0
		CompilerElse
			! MOV eax, [p.p_Out]
			! MOV ecx, [p.p_In1]
			! MOV edx, [p.p_In2]
			! MOVUPS xmm0, [ecx]
			! MOVUPS xmm1, [edx]
			! MOVAPS xmm2, xmm0
			! MOVAPS xmm3, xmm1
			! SHUFPS xmm0, xmm0, 01111000b
			! SHUFPS xmm1, xmm1, 10011100b
			! SHUFPS xmm2, xmm2, 10011100b
			! SHUFPS xmm3, xmm3, 01111000b
			! MULPS  xmm0, xmm1
			! MULPS  xmm2, xmm3
			! SUBPS  xmm0, xmm2
			! MOVUPS [eax], xmm0
		CompilerEndIf
		ProcedureReturn
	CompilerElse
		*Out\X = *In1\Y * *In2\Z - *In1\Z * *In2\Y
		*Out\Y = *In1\Z * *In2\X - *In1\X * *In2\Z
		*Out\Z = *In1\X * *In2\Y - *In1\Y * *In2\X
		*Out\W = 0
		ProcedureReturn *Out
	CompilerEndIf
EndProcedure


Procedure.f V4_Scalar(*In1.Vector4, *In2.Vector4)
	ProcedureReturn *In1\X * *In2\X + *In1\Y * *In2\Y + *In1\Z * *In2\Z
EndProcedure


Procedure.i V4_Multiply(*InOut.Vector4, *In.Matrix4)
	CompilerIf #Drawing3D_SSE
		CompilerIf SizeOf(Integer) = SizeOf(Quad)
			!MOV     rax, [p.p_v4fTarget]
			!MOV     rdx, [p.p_m4fSource]
			!MOVUPS  xmm0, [rax]
			!MOVAPS  xmm1, xmm0
			!MOVAPS  xmm2, xmm0
			!MOVAPS  xmm3, xmm0
			!MOVUPS  xmm4, [rdx+00]
			!MOVUPS  xmm5, [rdx+16]
			!MOVUPS  xmm6, [rdx+32]
			!MOVUPS  xmm7, [rdx+48]
			!SHUFPS  xmm0, xmm0, 0
			!SHUFPS  xmm1, xmm1, 85
			!SHUFPS  xmm2, xmm2, 170
			!SHUFPS  xmm3, xmm3, 255
			!MULPS   xmm0, xmm4
			!MULPS   xmm1, xmm5
			!MULPS   xmm2, xmm6
			!MULPS   xmm3, xmm7
			!ADDPS   xmm0, xmm1
			!ADDPS   xmm0, xmm2
			!ADDPS   xmm0, xmm3
			!MOVUPS  [rax], xmm0
		CompilerElse
			!MOV     eax, [p.p_v4fTarget]
			!MOV     edx, [p.p_m4fSource]
			!MOVUPS  xmm0, [eax]
			!MOVAPS  xmm1, xmm0
			!MOVAPS  xmm2, xmm0
			!MOVAPS  xmm3, xmm0
			!MOVUPS  xmm4, [edx+00]
			!MOVUPS  xmm5, [edx+16]
			!MOVUPS  xmm6, [edx+32]
			!MOVUPS  xmm7, [edx+48]
			!SHUFPS  xmm0, xmm0, 0
			!SHUFPS  xmm1, xmm1, 85
			!SHUFPS  xmm2, xmm2, 170
			!SHUFPS  xmm3, xmm3, 255
			!MULPS   xmm0, xmm4
			!MULPS   xmm1, xmm5
			!MULPS   xmm2, xmm6
			!MULPS   xmm3, xmm7
			!ADDPS   xmm0, xmm1
			!ADDPS   xmm0, xmm2
			!ADDPS   xmm0, xmm3
			!MOVUPS  [eax], xmm0
		CompilerEndIf
		ProcedureReturn
	CompilerEndIf
EndProcedure


Procedure.i Drawing3D_Rotate(*Use.Vector4, *Source.Matrix4)
	Protected Vector.Vector4 
	V4_Copy(Vector, *Use)
	*Use\X = Vector\X**Source\A11 + Vector\Y**Source\A12 + Vector\Z**Source\A13
	*Use\Y = Vector\X**Source\A21 + Vector\Y**Source\A22 + Vector\Z**Source\A23
	*Use\Z = Vector\X**Source\A31 + Vector\Y**Source\A32 + Vector\Z**Source\A33
	ProcedureReturn *Use
EndProcedure

Procedure.i Drawing3D_Orientation(*Use.Matrix4, RotationX.f, RotationY.f, RotationZ.f)
	Protected CosZ.f = Cos(RotationZ), CosY.f = Cos(RotationY), CosX.f = Cos(RotationX)
	Protected SinZ.f = Sin(RotationZ), SinY.f = Sin(RotationY), SinX.f = Sin(RotationX)
	*Use\A11 =  CosY*CosZ                : *Use\A12 = -CosY*SinZ                : *Use\A13 =  SinY
	*Use\A21 =  SinX*SinY*CosZ+CosX*SinZ : *Use\A22 = -SinX*SinY*SinZ+CosX*CosZ : *Use\A23 = -SinX*CosY
	*Use\A31 = -CosX*SinY*CosZ+SinX*SinZ : *Use\A32 =  CosX*SinY*SinZ+SinX*CosZ : *Use\A33 =  CosX*CosY
	ProcedureReturn *Use
EndProcedure

Procedure.i Drawing3D_Multiply(*Use.Matrix4, *Source.Matrix4)
	Protected Matrix.Matrix4
	CopyMemory(*Use, @Matrix, SizeOf(Matrix4)) 
	With *Use
		\A11 = Matrix\A11 * *Source\A11 + Matrix\A12 * *Source\A21 + Matrix\A13 * *Source\A31
		\A12 = Matrix\A11 * *Source\A12 + Matrix\A12 * *Source\A22 + Matrix\A13 * *Source\A32
		\A13 = Matrix\A11 * *Source\A13 + Matrix\A12 * *Source\A23 + Matrix\A13 * *Source\A33
		\A21 = Matrix\A21 * *Source\A11 + Matrix\A22 * *Source\A21 + Matrix\A23 * *Source\A31
		\A22 = Matrix\A21 * *Source\A12 + Matrix\A22 * *Source\A22 + Matrix\A23 * *Source\A32
		\A23 = Matrix\A21 * *Source\A13 + Matrix\A22 * *Source\A23 + Matrix\A23 * *Source\A33
		\A31 = Matrix\A31 * *Source\A11 + Matrix\A32 * *Source\A21 + Matrix\A33 * *Source\A31
		\A32 = Matrix\A31 * *Source\A12 + Matrix\A32 * *Source\A22 + Matrix\A33 * *Source\A32
		\A33 = Matrix\A31 * *Source\A13 + Matrix\A32 * *Source\A23 + Matrix\A33 * *Source\A33
	EndWith
	ProcedureReturn *Use
EndProcedure

Procedure.i Drawing3D_Projection(*Use.Vector4, *Source.Vector4)
	If *Source\Z
		*Use\W = 1 / *Source\Z
		*Use\X = - *Source\X * Drawing3DInclude\Distance * *Use\W + Drawing3DInclude\CenterX
		*Use\Y =   *Source\Y * Drawing3DInclude\Distance * *Use\W + Drawing3DInclude\CenterY
	EndIf
	ProcedureReturn *Use
EndProcedure





;- Private: Rendering


Procedure Drawing3D_AddPixel(X.i, Y.i, Distance.f)
	
	Protected *Pixel.Drawing3D_Pixel, *OldPixel.Drawing3D_Pixel
	
	;Debug Str(ListSize(Drawing3DInclude\PixelList()))+" - "+Str(Drawing3DInclude\CurrentPixelIndex)
	
	If Distance < 0
		If Drawing3DInclude\CurrentPixelIndex => #Drawing3D_PixelListSize
			If Not NextElement(Drawing3DInclude\PixelList())
				AddElement(Drawing3DInclude\PixelList())
			EndIf
			Drawing3DInclude\CurrentPixelIndex = 0
		EndIf
		*Pixel = Drawing3DInclude\PixelList()\Pixel[Drawing3DInclude\CurrentPixelIndex] : Drawing3DInclude\CurrentPixelIndex + 1
		*OldPixel = Drawing3DInclude\PixelIndex(X, Y)
		If *OldPixel
			If Distance >= *OldPixel\Distance
				*Pixel\PreviousPixel = *OldPixel
				Drawing3DInclude\PixelIndex(X, Y) = *Pixel
			Else
				While *OldPixel\PreviousPixel And *OldPixel\PreviousPixel\Distance > Distance
					*OldPixel = *OldPixel\PreviousPixel
				Wend
				*Pixel\PreviousPixel = *OldPixel\PreviousPixel
				*OldPixel\PreviousPixel = *Pixel
			EndIf
		Else
			Drawing3DInclude\PixelIndex(X, Y) = *Pixel
			*Pixel\PreviousPixel = 0
		EndIf
		*Pixel\Distance = Distance
	EndIf
	
	ProcedureReturn *Pixel
	
EndProcedure


; Rendert einen einzelnen Punkt (mit Kantenglättung)
Procedure Drawing3D_DrawPoint(*Vertex.Drawing3D_Vertex)
	
	Protected Projection.Vector4, Distance.f
	Protected X.i, Y.i
	Protected Visible.f
	Protected *Pixel.Drawing3D_Pixel
	
	Drawing3D_Projection(Projection, *Vertex)
	
	Drawing3DInclude\CurrentColor[0] = *Vertex\Color
	X = Projection\X
	Y = Projection\Y
	If X >= 0 And X <= Drawing3DInclude\MaxX And Y >= 0 And Y <= Drawing3DInclude\MaxX
		*Pixel = Drawing3D_AddPixel(X, Y, *Vertex\Z)
		If *Pixel
			ColorMix(*Pixel\Color, 1.0)
		EndIf
	EndIf
		
; 	Protected XA.i = Max(Projection\X-1, 0)
; 	Protected XB.i = Min(Projection\X+1, Drawing3DInclude\MaxX)
; 	Protected YA.i = Max(Projection\Y-1, 0)
; 	Protected YB.i = Min(Projection\Y+1, Drawing3DInclude\MaxY)
; 	For Y = YA To YB
; 		For X = XA To XB
; 			Visible = 1 - Sqr((X-Projection\X)*(X-Projection\X)+(Y-Projection\Y)*(Y-Projection\Y))
; 			If Visible > 0
; 				*Pixel = V4_AddPixel(X, Y, *Vertex\Z)
; 				If *Pixel
; 					Color4Mix1(*Pixel\Color, Visible)
; 					;Color4Mix(*Pixel\Color, Visible, 0, 0)
; 				EndIf
; 			EndIf
; 		Next
; 	Next
	
EndProcedure




Procedure Drawing3D_DrawTriangle(*Vertex0.Drawing3D_Vertex, *Vertex1.Drawing3D_Vertex, *Vertex2.Drawing3D_Vertex, Texture.i=0)
	
	Protected Triangle.Drawing3D_Triangle
	Protected LightFactor.f, N.i
	
	With Triangle
	
	Drawing3D_Projection(\Vertex[0], *Vertex0) : \Vertex[0]\Color = *Vertex0\Color
	Drawing3D_Projection(\Vertex[1], *Vertex1) : \Vertex[1]\Color = *Vertex1\Color
	Drawing3D_Projection(\Vertex[2], *Vertex2) : \Vertex[2]\Color = *Vertex2\Color
	
	Protected X.i, Y.i
	Protected DX21.f = \Vertex[2]\X-\Vertex[1]\X, DY21.f = \Vertex[2]\Y-\Vertex[1]\Y
	Protected DX02.f = \Vertex[0]\X-\Vertex[2]\X, DY02.f = \Vertex[0]\Y-\Vertex[2]\Y
	Protected DX10.f = \Vertex[1]\X-\Vertex[0]\X, DY10.f = \Vertex[1]\Y-\Vertex[0]\Y
	Protected L1.f, L2.f, L3.f
	
	Protected XA.i = Max(Min(\Vertex[0]\X, \Vertex[1]\X, \Vertex[2]\X), 0)
	Protected XB.i = Min(Max(\Vertex[0]\X, \Vertex[1]\X, \Vertex[2]\X), Drawing3DInclude\MaxX)
	Protected YA.i = Max(Min(\Vertex[0]\Y, \Vertex[1]\Y, \Vertex[2]\Y), 0)
	Protected YB.i = Min(Max(\Vertex[0]\Y, \Vertex[1]\Y, \Vertex[2]\Y), Drawing3DInclude\MaxY)
	
	Protected *Pixel.Drawing3D_Pixel, *OldPixel.Drawing3D_Pixel, Color.Color4, Norm.Vector4, V1.Vector4, V2.Vector4
	
	Protected T.f = 1.0 / (-DY21*DX02 + DX21*DY02)
	Protected Distance.f, Brightness.f, Q1.f, Q2.f
	Protected Visible.f
	
	If Drawing3DInclude\Mode & #Drawing3D_FrontOnly And T < 0 : ProcedureReturn 0 : EndIf
	
	If Texture = 0
		For N = 0 To 2
			\Vertex[N]\Color\Red / \Vertex[N]\Color\Alpha
			\Vertex[N]\Color\Green / \Vertex[N]\Color\Alpha
			\Vertex[N]\Color\Blue / \Vertex[N]\Color\Alpha
			V4_Copy(V1, *Vertex1) : V4_Subtract(V1, *Vertex0)
			V4_Copy(V2, *Vertex2) : V4_Subtract(V2, *Vertex0)
			V4_Normalize(V4_Crossing(Norm, V2, V1))
			ForEach Drawing3DInclude\Light()
				LightFactor = V4_Scalar(Norm, Drawing3DInclude\Light()\Direction)*Sign(T)
				If LightFactor > 0
					\Vertex[N]\Color\Red   + LightFactor*Drawing3DInclude\Light()\Color\Red
					\Vertex[N]\Color\Green + LightFactor*Drawing3DInclude\Light()\Color\Green
					\Vertex[N]\Color\Blue  + LightFactor*Drawing3DInclude\Light()\Color\Blue
				EndIf
			Next
			NormalizeColor(\Vertex[N]\Color)
			Drawing3DInclude\CurrentColor[N] = \Vertex[N]\Color
		Next
	EndIf
	
	For Y = YA To YB
		Q1 = DX21*(Y-\Vertex[2]\Y)
		Q2 = DX02*(Y-\Vertex[2]\Y)
		*Pixel = #Null
		For X = XA To XB
			L1 = ( -DY21*(X-\Vertex[2]\X) + Q1 ) * T
			L2 = ( -DY02*(X-\Vertex[2]\X) + Q2 ) * T
			L3 = 1.0 - L1 - L2
			If L1 >= 0.0 And L2 >= 0.0 And L3 >= 0.0
				Distance = 1.0 / ( L1*\Vertex[0]\W + L2*\Vertex[1]\W + L3*\Vertex[2]\W )
				*Pixel = Drawing3D_AddPixel(X, Y, Distance)
				If *Pixel
					If Drawing3DInclude\CurrentImage3D
						If Texture = 1
							ImageColor(*Pixel\Color, L2*\Vertex[1]\W*Distance, L3*\Vertex[2]\W*Distance)
						Else
							ImageColor(*Pixel\Color, 1.0-L2*\Vertex[1]\W*Distance, 1.0-L3*\Vertex[2]\W*Distance)
						EndIf
					Else
						ColorMix(*Pixel\Color, L1*\Vertex[0]\W*Distance, L2*\Vertex[1]\W*Distance, L3*\Vertex[2]\W*Distance)
					EndIf
				EndIf
			ElseIf *Pixel
				Break
			EndIf
		Next
	Next
	
	EndWith
	
EndProcedure



Procedure Drawing3D_DrawDisk(*Vertex0.Drawing3D_Vertex, *Vertex1.Drawing3D_Vertex, *Vertex2.Drawing3D_Vertex, *Vertex3.Drawing3D_Vertex, SquareRadius.f)
	
	Protected Disk.Drawing3D_Disk
	Protected LightFactor.f, N.i, Vector.Vector4, SquareDifference.f
	
	With Disk
	
	Drawing3D_Projection(\Vertex[0], *Vertex0) : \Vertex[0]\Color = *Vertex0\Color
	Drawing3D_Projection(\Vertex[1], *Vertex1) : \Vertex[1]\Color = *Vertex1\Color
	Drawing3D_Projection(\Vertex[2], *Vertex2) : \Vertex[2]\Color = *Vertex2\Color
	
	Protected X.i, Y.i
	Protected DX21.f = \Vertex[2]\X-\Vertex[1]\X, DY21.f = \Vertex[2]\Y-\Vertex[1]\Y
	Protected DX02.f = \Vertex[0]\X-\Vertex[2]\X, DY02.f = \Vertex[0]\Y-\Vertex[2]\Y
	Protected DX10.f = \Vertex[1]\X-\Vertex[0]\X, DY10.f = \Vertex[1]\Y-\Vertex[0]\Y
	Protected L1.f, L2.f, L3.f
	
	Protected XA.i = Max(Min(\Vertex[0]\X, \Vertex[1]\X, \Vertex[2]\X), 0)
	Protected XB.i = Min(Max(\Vertex[0]\X, \Vertex[1]\X, \Vertex[2]\X), Drawing3DInclude\MaxX)
	Protected YA.i = Max(Min(\Vertex[0]\Y, \Vertex[1]\Y, \Vertex[2]\Y), 0)
	Protected YB.i = Min(Max(\Vertex[0]\Y, \Vertex[1]\Y, \Vertex[2]\Y), Drawing3DInclude\MaxY)
	
	Protected *Pixel.Drawing3D_Pixel, *OldPixel.Drawing3D_Pixel, Color.Color4, Norm.Vector4, V1.Vector4, V2.Vector4
	
	Protected T.f = 1.0 / (-DY21*DX02 + DX21*DY02)
	Protected Distance.f, Brightness.f, Q1.f, Q2.f
	Protected Visible.f
	
	If Drawing3DInclude\Mode & #Drawing3D_FrontOnly And T < 0 : ProcedureReturn 0 : EndIf
	
		For N = 0 To 2
			\Vertex[N]\Color\Red / \Vertex[N]\Color\Alpha
			\Vertex[N]\Color\Green / \Vertex[N]\Color\Alpha
			\Vertex[N]\Color\Blue / \Vertex[N]\Color\Alpha
			V4_Copy(V1, *Vertex1) : V4_Subtract(V1, *Vertex0)
			V4_Copy(V2, *Vertex2) : V4_Subtract(V2, *Vertex0)
			V4_Normalize(V4_Crossing(Norm, V2, V1))
			ForEach Drawing3DInclude\Light()
				LightFactor = V4_Scalar(Norm, Drawing3DInclude\Light()\Direction)*Sign(T)
				If LightFactor > 0
					\Vertex[N]\Color\Red   + LightFactor*Drawing3DInclude\Light()\Color\Red
					\Vertex[N]\Color\Green + LightFactor*Drawing3DInclude\Light()\Color\Green
					\Vertex[N]\Color\Blue  + LightFactor*Drawing3DInclude\Light()\Color\Blue
				EndIf
			Next
			NormalizeColor(\Vertex[N]\Color)
			Drawing3DInclude\CurrentColor[N] = \Vertex[N]\Color
		Next
	
	For Y = YA To YB
		Q1 = DX21*(Y-\Vertex[2]\Y)
		Q2 = DX02*(Y-\Vertex[2]\Y)
		For X = XA To XB
			L1 = ( -DY21*(X-\Vertex[2]\X) + Q1 ) * T
			L2 = ( -DY02*(X-\Vertex[2]\X) + Q2 ) * T
			L3 = 1.0 - L1 - L2
			Distance = 1.0 / ( L1*\Vertex[0]\W + L2*\Vertex[1]\W + L3*\Vertex[2]\W )
			Vector\Z = Distance
			Vector\X = -(X-Drawing3DInclude\CenterX)*Vector\Z/Drawing3DInclude\Distance
			Vector\Y = (Y-Drawing3DInclude\CenterY)*Vector\Z/Drawing3DInclude\Distance
			SquareDifference = (Vector\X-*Vertex3\X)*(Vector\X-*Vertex3\X) + (Vector\Y-*Vertex3\Y)*(Vector\Y-*Vertex3\Y) + (Vector\Z-*Vertex3\Z)*(Vector\Z-*Vertex3\Z)
			If SquareDifference < SquareRadius
				*Pixel = Drawing3D_AddPixel(X, Y, Distance)
				If *Pixel
					ColorMix(*Pixel\Color, L1*\Vertex[0]\W*Distance, L2*\Vertex[1]\W*Distance, L3*\Vertex[2]\W*Distance)
				EndIf
			EndIf
		Next
	Next
	
	EndWith
	
EndProcedure



Procedure Drawing3D_DrawLine(*Vertex0.Drawing3D_Vertex, *Vertex1.Drawing3D_Vertex)
	
	Protected Line.Drawing3D_Line, Distance.f
	Protected X.i, Y.i, I.i, Length.f, InvLength.f, Position.f
	Protected Visible.f, Increase.f, Q.Vector4, R.Vector4, Cross.Vector4
	Protected *Pixel.Drawing3D_Pixel
	
	With Line
		
		Drawing3D_Projection(\Vertex[0], *Vertex0) : \Vertex[0]\Color = *Vertex0\Color
		Drawing3D_Projection(\Vertex[1], *Vertex1) : \Vertex[1]\Color = *Vertex1\Color
		Protected XA.i = Max(Min(\Vertex[0]\X, \Vertex[1]\X)-1, 0)
		Protected XB.i = Min(Max(\Vertex[0]\X, \Vertex[1]\X)+1, Drawing3DInclude\MaxX)
		Protected YA.i = Max(Min(\Vertex[0]\Y, \Vertex[1]\Y)-1, 0)
		Protected YB.i = Min(Max(\Vertex[0]\Y, \Vertex[1]\Y)+1, Drawing3DInclude\MaxY)
		V4_Copy(R, \Vertex[1])
		V4_Subtract(R, \Vertex[0])
		Length = V4_Length(R)
		InvLength = 1.0/Length
		Drawing3DInclude\CurrentColor[0] = \Vertex[0]\Color
		Drawing3DInclude\CurrentColor[1] = \Vertex[1]\Color
		
		; Horizontal
		If Abs(XB-XA) >= Abs(YB-YA)
			Increase = (\Vertex[1]\Y-\Vertex[0]\Y) / (\Vertex[1]\X-\Vertex[0]\X)
			For X = XA To XB
				For I = -0 To 0
					Y = \Vertex[0]\Y + (X-\Vertex[0]\X)*Increase + I
					If Y < YA : Continue : EndIf
					If Y > YB : Break : EndIf
					V4_Set(Q, X, Y, 0)
					V4_Subtract(Q, \Vertex[0])
					V4_Crossing(Cross, Q, R)
					Position = V4_Scalar(Q, R) / Length
					Visible = 1; - V4_Length(Cross) / Length
					If Position >= 0 And Position <= Length And Visible > 0
						Distance = 1.0 / ( (1-Position*InvLength)*\Vertex[0]\W + (Position*InvLength)*\Vertex[1]\W )
						*Pixel = Drawing3D_AddPixel(X, Y, Distance)
						If *Pixel
							ColorMix(*Pixel\Color, (1-Position/Length)*\Vertex[0]\W*Distance*Visible, (Position/Length)*\Vertex[1]\W*Distance*Visible)
						EndIf
					EndIf
				Next
			Next
		; Vertikal
		Else
			Increase = (\Vertex[1]\X-\Vertex[0]\X) /  (\Vertex[1]\Y-\Vertex[0]\Y)
			For Y = YA To YB
				For I = -0 To 0
					X = \Vertex[0]\X + (Y-\Vertex[0]\Y)*Increase + I
					If X < XA : Continue : EndIf
					If X > XB : Break : EndIf
					V4_Set(Q, X, Y, 0)
					V4_Subtract(Q, \Vertex[0])
					V4_Crossing(Cross, Q, R)
					Position = V4_Scalar(Q, R) / Length
					Visible = 1; - V4_Length(Cross) / Length
					If Position >= 0 And Position <= Length And Visible > 0
						Distance = 1.0 / ( (1-Position*InvLength)*\Vertex[0]\W + (Position*InvLength)*\Vertex[1]\W )
						*Pixel = Drawing3D_AddPixel(X, Y, Distance)
						If *Pixel
							ColorMix(*Pixel\Color, (1-Position/Length)*\Vertex[0]\W*Distance*Visible, (Position/Length)*\Vertex[1]\W*Distance*Visible)
						EndIf
					EndIf
				Next
			Next
		EndIf
; 		For Y = YA To YB
; 			*Pixel = #Null
; 			For X = XA To XB
; 				Vector4(Q, X, Y, 0)
; 				V4_Subtract(Q, \Vertex[0])
; 				V4_Cross(Cross, Q, R)
; 				Position = V4_Scalar(Q, R) / Length
; 				Visible = 1 - V4_Length(Cross) / Length
; 				If Position >= 0 And Position <= Length And Visible > 0
; 					Distance = 1.0 / ( (1-Position/Length)*\Vertex[0]\InvZ + (Position/Length)*\Vertex[1]\InvZ )
; 					*Pixel = V4_AddPixel(X, Y, Distance)
; 					If *Pixel
; 						Color4Mix(*Pixel\Color, (1-Position/Length)*\Vertex[0]\InvZ*Distance*Visible, (Position/Length)*\Vertex[1]\InvZ*Distance*Visible, 0)
; 					EndIf
; 				EndIf
; 				If *Pixel And Visible < -1
; 					Break
; 				EndIf
; 			Next
; 		Next
		
	EndWith
	
EndProcedure


Procedure.i DrawText3D_CustomFilter(X.i, Y.i, Source.i, Destination.i)
	
	SetColor(Drawing3DInclude\CurrentImage3D\Pixel(X, Y), Source)
	
	ProcedureReturn Destination
	
EndProcedure






;- Cluster (unfertig)

Procedure.i CreateCluster3D()
	Protected *Cluster.Drawing3D_Cluster = AddElement(Drawing3DInclude\Cluster())
	Drawing3DInclude\CurrentCluster = *Cluster
	ProcedureReturn *Cluster
EndProcedure

Procedure CloseCluster3D()
EndProcedure

Procedure DrawCluster3D(*Cluster.Drawing3D_Cluster, X.f, Y.f, Z.f, Pitch.f=0.0, Yaw.f=0.0, Roll.f=0.0)
EndProcedure





;- Image3D



Procedure.i Image3DID(Image3D.i)
	
	If Image3D & ~$FFFF
		ProcedureReturn Image3D
	Else
		ProcedureReturn Drawing3DInclude\Image3DID(Image3D)
	EndIf
	
EndProcedure



Procedure.i FreeImage3D(Image3D.i)
	
	Protected *Image3D.Drawing3D_Image = Image3DID(Image3D)
	
	With *Image3D
		
		If Not \Number & ~$FFFF
			Drawing3DInclude\Image3DID(\Number) = #Null
		EndIf
		
		ChangeCurrentElement(Drawing3DInclude\Image3D(), *Image3D)
		DeleteElement(Drawing3DInclude\Image3D())
		
	EndWith
	
EndProcedure



Procedure CreateImage3D(Image3D.i, Image.i=#PB_Default, Width.i=0, Height.i=0)
	
	Protected *Image3D.Drawing3D_Image
	Protected X.i, Y.i
	
	If Image3D = #PB_Any
		*Image3D = AddElement(Drawing3DInclude\Image3D())
		*Image3D\Number = *Image3D
	ElseIf Not Image3D & ~$FFFF
		*Image3D = AddElement(Drawing3DInclude\Image3D())
		*Image3D\Number = Image3D
		If ArraySize(Drawing3DInclude\Image3DID()) < Image3D 
			ReDim Drawing3DInclude\Image3DID(Image3D)
		ElseIf Drawing3DInclude\Image3DID(Image3D)
			FreeImage3D(Drawing3DInclude\Image3DID(Image3D))
		EndIf
		Drawing3DInclude\Image3DID(Image3D) = *Image3D
	Else
		ProcedureReturn #Null
	EndIf
	
	With *Image3D
		If Image = #PB_Default
			\Width  = Width
			\Height = Height
			Dim \Pixel(\Width-1, \Height-1)
		Else
			\Width  = ImageWidth(Image)
			\Height = ImageHeight(Image)
			Dim \Pixel(\Width-1, \Height-1)
			If StartDrawing(ImageOutput(Image))
				DrawingMode(#PB_2DDrawing_AllChannels)
				Select ImageDepth(Image, #PB_Image_InternalDepth)
					Case 24
						For Y = \Height-1 To 0 Step -1
							For X = \Width-1 To 0 Step -1
								SetColor(\Pixel(X, Y), Point(X, Y)|$FF000000)
							Next
						Next
					Case 32
						For Y = \Height-1 To 0 Step -1
							For X = \Width-1 To 0 Step -1
								SetColor(\Pixel(X, Y), Point(X, Y))
							Next
						Next
				EndSelect
				StopDrawing()
			EndIf
		EndIf
		ProcedureReturn *Image3D
	EndWith
	
EndProcedure

















;- Drawing
; 			Define n
; 			For n = 1 To 1000000
; 				;AddElement(Drawing3DInclude\Pixel())
; 			Next


; Öffnet eine Drawing3D-Umgebung für die Drawing3D-Befehle
Procedure.i StartDrawing3D(Output.i, FieldOfView.f=75)
	
	With Drawing3DInclude
		
		If StartDrawing(Output)
			
			\MaxX     = OutputWidth()-1
			\MaxY     = OutputHeight()-1
			\CenterX  = OutputWidth()/2
			\CenterY  = OutputHeight()/2
			\Distance = OutputHeight()/Tan(Radian(FieldOfView)*0.5)
			V4_Set(Drawing3DInclude\Position, 0, 0, \Distance)
			
			If ArraySize(\PixelIndex(), 1) <> \MaxX Or ArraySize(\PixelIndex(), 2) <> \MaxY 
				Dim \PixelIndex(\MaxX, \MaxY)
			Else
				FillMemory(@\PixelIndex(0,0), SizeOf(Integer)*(\MaxX+1)*(\MaxY+1), 0, #PB_Integer)
			EndIf
			;ClearList(\PixelList())
			;AddElement(\PixelList())
			If ListSize(\PixelList()) = 0
				AddElement(\PixelList())
			Else
				FirstElement(\PixelList())
			EndIf
			Drawing3DInclude\CurrentPixelIndex = 0
			
			ClearList(\Light())
			ClearStructure(\MainCluster, Drawing3D_Cluster)
			
			ProcedureReturn #True
			
		EndIf
		
	EndWith
	
EndProcedure



; Schließ eine Drawing3D-Umgebung und rendert die Szene
Procedure StopDrawing3D()
	
	Protected *Pixel.Drawing3D_Pixel, *PreviousPixel.Drawing3D_Pixel
	Protected Color.Color4
	Protected X.i, Y.i
	
	;DrawingMode(#PB_2DDrawing_AllChannels)
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	
	For Y = 0 To Drawing3DInclude\MaxY
		For X = 0 To Drawing3DInclude\MaxX
			*Pixel = Drawing3DInclude\PixelIndex(X, Y)
			If *Pixel
				While *Pixel\PreviousPixel
					BlendColor(*Pixel\PreviousPixel\Color, *Pixel\Color)
					*Pixel = *Pixel\PreviousPixel
				Wend
				;Color = Drawing3DInclude\Background
				;Plot(X, Y, GetColor(BlendColor(Color, *Pixel)))
				Plot(X, Y, GetColor(*Pixel\Color))
			EndIf
		Next
	Next
	
	StopDrawing()
	
EndProcedure



; Ändert den Zeichenmodus
Procedure Drawing3DMode(Mode.i)
	
	Drawing3DInclude\Mode = Mode
	
EndProcedure




; Definiert oder ändert die Position der Szene
Procedure Drawing3DPosition(X.f, Y.f, Z.f, Mode.i=#PB_Absolute)
	
	Protected Vector.Vector4
	
	If Mode = #PB_Relative
		V4_Set(Vector, -X, -Y, -Z)
		V4_Add(Drawing3DInclude\Position, Vector)
	Else
		V4_Set(Drawing3DInclude\Position, -X, -Y, -Z)
	EndIf
	
EndProcedure



; Definiert oder ändert die Orientierung der Szene
Procedure Drawing3DRotation(RotationX.f, RotationY.f, RotationZ.f, Mode.i=#PB_Absolute)
	
	Protected Rotation.Matrix4
	
	If Mode = #PB_Relative
		Drawing3D_Orientation(Rotation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
		Drawing3D_Multiply(Rotation, Drawing3DInclude\Orientation)
		Drawing3DInclude\Orientation = Rotation
	Else
		Drawing3D_Orientation(Drawing3DInclude\Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	EndIf
	
EndProcedure



; Setzt den Szenenhintergrund
Procedure Drawing3DBackground(Color.l=$FF000000)
	
	Box(0, 0, OutputWidth(), OutputHeight(), Color)
	SetColor(Drawing3DInclude\Background, Color)
	
EndProcedure



; Setzt den Szenenhintergrund
Procedure Drawing3DStyle(Mode.i, Parameter1.f, Parameter2.f)
	
	
	
EndProcedure



; Setzt ein Licht in die Szene
Procedure Drawing3DLight(DirectionX.f, DirectionY.f, DirectionZ.f, Color.l)
	
	Protected *Light.Drawing3D_Light = AddElement(Drawing3DInclude\Light())
	
	With *Light
		V4_Set(\Direction, DirectionX, DirectionY, DirectionZ)
		V4_Normalize(\Direction)
		SetColor(\Color, Color)
	EndWith
	
	ProcedureReturn *Light
	
EndProcedure



; Zeichnet einen Punkt in die Szene
Procedure DrawPoint3D(X.f, Y.f, Z.f, Color.q)
	
	Protected Vertex.Drawing3D_Vertex
	
	V4_Set(Vertex, X, Y, Z)
	SetColor(Vertex\Color, Color)
	Drawing3D_Rotate(Vertex, Drawing3DInclude\Orientation)
	V4_Subtract(Vertex, Drawing3DInclude\Position)
	Drawing3D_DrawPoint(Vertex)
	
EndProcedure



; Zeichnet eine Linie in die Szene
Procedure DrawLine3D(X1.f, Y1.f, Z1.f, X2.f, Y2.f, Z2.f, Color1.q, Color2.q=#Drawing3D_Ignore)
	
	Protected Line.Drawing3D_Line
	
	V4_Set(Line\Vertex[0], X1, Y1, Z1)
	V4_Set(Line\Vertex[1], X2, Y2, Z2)
	SetColor(Line\Vertex[0]\Color, Color1)
	If Color2 = #Drawing3D_Ignore
		SetColor(Line\Vertex[1]\Color, Color1)
	Else
		SetColor(Line\Vertex[1]\Color, Color2)
	EndIf
	Drawing3D_Rotate(Line\Vertex[0], Drawing3DInclude\Orientation)
	V4_Subtract(Line\Vertex[0], Drawing3DInclude\Position)
	Drawing3D_Rotate(Line\Vertex[1], Drawing3DInclude\Orientation)
	V4_Subtract(Line\Vertex[1], Drawing3DInclude\Position)
	Drawing3D_DrawLine(Line\Vertex[0], Line\Vertex[1])
	
EndProcedure



; Zeichnet ein Dreieck in die Szene
Procedure DrawTriangle3D(X1.f, Y1.f, Z1.f, X2.f, Y2.f, Z2.f, X3.f, Y3.f, Z3.f, Color1.q, Color2.q=#Drawing3D_Ignore, Color3.q=#Drawing3D_Ignore)
	
	Protected Triangle.Drawing3D_Triangle
	
	V4_Set(Triangle\Vertex[0], X1, Y1, Z1)
	V4_Set(Triangle\Vertex[1], X2, Y2, Z2)
	V4_Set(Triangle\Vertex[2], X3, Y3, Z3)
	SetColor(Triangle\Vertex[0]\Color, Color1)
	If Color2 = #Drawing3D_Ignore
		SetColor(Triangle\Vertex[1]\Color, Color1)
	Else
		SetColor(Triangle\Vertex[1]\Color, Color2)
	EndIf
	If Color3 = #Drawing3D_Ignore
		SetColor(Triangle\Vertex[2]\Color, Color1)
	Else
		SetColor(Triangle\Vertex[2]\Color, Color3)
	EndIf
	Drawing3D_Rotate(Triangle\Vertex[0], Drawing3DInclude\Orientation)
	V4_Subtract(Triangle\Vertex[0], Drawing3DInclude\Position)
	Drawing3D_Rotate(Triangle\Vertex[1], Drawing3DInclude\Orientation)
	V4_Subtract(Triangle\Vertex[1], Drawing3DInclude\Position)
	Drawing3D_Rotate(Triangle\Vertex[2], Drawing3DInclude\Orientation)
	V4_Subtract(Triangle\Vertex[2], Drawing3DInclude\Position)
	
	If Drawing3DInclude\Mode & #Drawing3D_Outline
		Drawing3D_DrawLine(Triangle\Vertex[0], Triangle\Vertex[1])
		Drawing3D_DrawLine(Triangle\Vertex[1], Triangle\Vertex[2])
		Drawing3D_DrawLine(Triangle\Vertex[2], Triangle\Vertex[0])
	Else
		Drawing3D_DrawTriangle(Triangle\Vertex[0], Triangle\Vertex[1], Triangle\Vertex[2])
	EndIf
	
EndProcedure



; Zeichnet eine Ebene in die Szene
Procedure DrawPlane3D(X.f, Y.f, Z.f, Width.f, Height.f, RotationX.f, RotationY.f, RotationZ.f, Color1.q, Color2.q=#Drawing3D_Ignore, Color3.q=#Drawing3D_Ignore, Color4.q=#Drawing3D_Ignore)
	
	Protected Plane.Drawing3D_Plane
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected N.i
	
	V4_Set(Vertex, X, Y, Z)
	V4_Set(Plane\Vertex[0], -Width*0.5,  Height*0.5, 0)
	V4_Set(Plane\Vertex[1],  Width*0.5,  Height*0.5, 0)
	V4_Set(Plane\Vertex[2], -Width*0.5, -Height*0.5, 0)
	V4_Set(Plane\Vertex[3],  Width*0.5, -Height*0.5, 0)
	SetColor(Plane\Vertex[0]\Color, Color1)
	If Color2 = #Drawing3D_Ignore
		SetColor(Plane\Vertex[1]\Color, Color1)
	Else
		SetColor(Plane\Vertex[1]\Color, Color2)
	EndIf
	If Color3 = #Drawing3D_Ignore
		SetColor(Plane\Vertex[2]\Color, Color1)
	Else
		SetColor(Plane\Vertex[2]\Color, Color3)
	EndIf
	If Color4 = #Drawing3D_Ignore
		SetColor(Plane\Vertex[3]\Color, Color1)
	Else
		SetColor(Plane\Vertex[3]\Color, Color4)
	EndIf
	Drawing3D_Orientation(Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	For N = 0 To 3
		Drawing3D_Rotate(Plane\Vertex[N], Orientation)
		V4_Add(Plane\Vertex[N], Vertex)
		Drawing3D_Rotate(Plane\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Plane\Vertex[N], Drawing3DInclude\Position)
	Next
	
	If Drawing3DInclude\Mode & #Drawing3D_Outline
		Drawing3D_DrawLine(Plane\Vertex[0], Plane\Vertex[1])
		Drawing3D_DrawLine(Plane\Vertex[1], Plane\Vertex[3])
		Drawing3D_DrawLine(Plane\Vertex[3], Plane\Vertex[2])
		Drawing3D_DrawLine(Plane\Vertex[2], Plane\Vertex[0])
	Else
		Drawing3D_DrawTriangle(Plane\Vertex[0], Plane\Vertex[1], Plane\Vertex[2])
		Drawing3D_DrawTriangle(Plane\Vertex[3], Plane\Vertex[2], Plane\Vertex[1])
	EndIf
EndProcedure



; Zeichnet eine Ebene in die Szene
Procedure DrawDisk3D(X.f, Y.f, Z.f, Radius.f, RotationX.f, RotationY.f, RotationZ.f, Color.q)
	
	Protected Disk.Drawing3D_Disk
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected N.i
	
	V4_Set(Vertex, X, Y, Z)
	V4_Set(Disk\Vertex[0], 0, Radius*Sqr(2), 0)
	V4_Set(Disk\Vertex[1], -Radius*(1+Sqr(2)), -Radius, 0)
	V4_Set(Disk\Vertex[2], Radius*(1+Sqr(2)), -Radius, 0)
	V4_Set(Disk\Vertex[3], 0, 0, 0)
	SetColor(Disk\Vertex[0]\Color, Color)
	SetColor(Disk\Vertex[1]\Color, Color)
	SetColor(Disk\Vertex[2]\Color, Color)
	SetColor(Disk\Vertex[3]\Color, Color)
	Drawing3D_Orientation(Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	For N = 0 To 3
		Drawing3D_Rotate(Disk\Vertex[N], Orientation)
		V4_Add(Disk\Vertex[N], Vertex)
		Drawing3D_Rotate(Disk\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Disk\Vertex[N], Drawing3DInclude\Position)
	Next
	
	If Drawing3DInclude\Mode & #Drawing3D_Outline
	Else
		Drawing3D_DrawDisk(Disk\Vertex[0], Disk\Vertex[1], Disk\Vertex[2], Disk\Vertex[3], Radius*Radius)
	EndIf
EndProcedure



; Zeichnet einen Quader in die Szene
Procedure DrawBox3D(X.f, Y.f, Z.f, Width.f, Height.f, Depth.f, RotationX.f, RotationY.f, RotationZ.f, Color.q)
	
	Protected Box.Drawing3D_Box
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected N.i
	
	V4_Set(Vertex, X, Y, Z)
	V4_Set(Box\Vertex[0], -Width*0.5,  Height*0.5,  Depth*0.5)
	V4_Set(Box\Vertex[1],  Width*0.5,  Height*0.5,  Depth*0.5)
	V4_Set(Box\Vertex[2], -Width*0.5, -Height*0.5,  Depth*0.5)
	V4_Set(Box\Vertex[3],  Width*0.5, -Height*0.5,  Depth*0.5)
	V4_Set(Box\Vertex[4], -Width*0.5,  Height*0.5, -Depth*0.5)
	V4_Set(Box\Vertex[5],  Width*0.5,  Height*0.5, -Depth*0.5)
	V4_Set(Box\Vertex[6], -Width*0.5, -Height*0.5, -Depth*0.5)
	V4_Set(Box\Vertex[7],  Width*0.5, -Height*0.5, -Depth*0.5)
	Drawing3D_Orientation(Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	For N = 0 To 7
		SetColor(Box\Vertex[N]\Color, Color)
		Drawing3D_Rotate(Box\Vertex[N], Orientation)
		V4_Add(Box\Vertex[N], Vertex)
		Drawing3D_Rotate(Box\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Box\Vertex[N], Drawing3DInclude\Position)
	Next
	
	If Drawing3DInclude\Mode & #Drawing3D_Outline
		Drawing3D_DrawLine(Box\Vertex[0], Box\Vertex[1])
		Drawing3D_DrawLine(Box\Vertex[2], Box\Vertex[3])
		Drawing3D_DrawLine(Box\Vertex[4], Box\Vertex[5])
		Drawing3D_DrawLine(Box\Vertex[6], Box\Vertex[7])
		Drawing3D_DrawLine(Box\Vertex[0], Box\Vertex[2])
		Drawing3D_DrawLine(Box\Vertex[1], Box\Vertex[3])
		Drawing3D_DrawLine(Box\Vertex[4], Box\Vertex[6])
		Drawing3D_DrawLine(Box\Vertex[5], Box\Vertex[7])
		Drawing3D_DrawLine(Box\Vertex[0], Box\Vertex[4])
		Drawing3D_DrawLine(Box\Vertex[1], Box\Vertex[5])
		Drawing3D_DrawLine(Box\Vertex[2], Box\Vertex[6])
		Drawing3D_DrawLine(Box\Vertex[3], Box\Vertex[7])
	Else
		Drawing3D_DrawTriangle(Box\Vertex[0], Box\Vertex[1], Box\Vertex[2])
		Drawing3D_DrawTriangle(Box\Vertex[3], Box\Vertex[2], Box\Vertex[1])
		Drawing3D_DrawTriangle(Box\Vertex[5], Box\Vertex[4], Box\Vertex[7])
		Drawing3D_DrawTriangle(Box\Vertex[6], Box\Vertex[7], Box\Vertex[4])
		Drawing3D_DrawTriangle(Box\Vertex[1], Box\Vertex[5], Box\Vertex[3])
		Drawing3D_DrawTriangle(Box\Vertex[7], Box\Vertex[3], Box\Vertex[5])
		Drawing3D_DrawTriangle(Box\Vertex[4], Box\Vertex[0], Box\Vertex[6])
		Drawing3D_DrawTriangle(Box\Vertex[2], Box\Vertex[6], Box\Vertex[0])
		Drawing3D_DrawTriangle(Box\Vertex[4], Box\Vertex[5], Box\Vertex[0])
		Drawing3D_DrawTriangle(Box\Vertex[1], Box\Vertex[0], Box\Vertex[5])
		Drawing3D_DrawTriangle(Box\Vertex[2], Box\Vertex[3], Box\Vertex[6])
		Drawing3D_DrawTriangle(Box\Vertex[7], Box\Vertex[6], Box\Vertex[3])
	EndIf
	
EndProcedure



; Zeichnet einen Zylinder in die Szene
Procedure DrawCylinder3D(X.f, Y.f, Z.f, Radius.f, Height.f, RotationX.f, RotationY.f, RotationZ.f, Color1.q, Color2.q=#Drawing3D_Ignore, Detail.i=36)
	
	Protected Cylinder.Drawing3D_Cylinder
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected N.i, I.i
	
	V4_Set(Vertex, X, Y, Z)
	Drawing3D_Orientation(Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	
	If Color2 = #Drawing3D_Ignore
		Color2 = Color1
	EndIf
	V4_Set(Cylinder\Vertex[4], 0,  Height*0.5, 0)
	V4_Set(Cylinder\Vertex[5], 0, -Height*0.5, 0)
	V4_Set(Cylinder\Vertex[0], Radius,  Height*0.5, 0)
	V4_Set(Cylinder\Vertex[1], Radius, -Height*0.5, 0)
	SetColor(Cylinder\Vertex[0]\Color, Color1)
	SetColor(Cylinder\Vertex[1]\Color, Color2)
	SetColor(Cylinder\Vertex[2]\Color, Color1)
	SetColor(Cylinder\Vertex[3]\Color, Color2)
	SetColor(Cylinder\Vertex[4]\Color, Color1)
	SetColor(Cylinder\Vertex[5]\Color, Color2)
	For N = 0 To 1
		Drawing3D_Rotate(Cylinder\Vertex[N], Orientation)
		V4_Add(Cylinder\Vertex[N], Vertex)
		Drawing3D_Rotate(Cylinder\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Cylinder\Vertex[N], Drawing3DInclude\Position)
	Next
	For N = 4 To 5
		Drawing3D_Rotate(Cylinder\Vertex[N], Orientation)
		V4_Add(Cylinder\Vertex[N], Vertex)
		Drawing3D_Rotate(Cylinder\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Cylinder\Vertex[N], Drawing3DInclude\Position)
	Next
	For I = 1 To Detail
		V4_Set(Cylinder\Vertex[2], Cos(#PI*2*I/Detail)*Radius, Height*0.5, Sin(#PI*2*I/Detail)*Radius)
		V4_Set(Cylinder\Vertex[3], Cylinder\Vertex[2]\X, -Height*0.5, Cylinder\Vertex[2]\Z)
		For N = 2 To 3
			Drawing3D_Rotate(Cylinder\Vertex[N], Orientation)
			V4_Add(Cylinder\Vertex[N], Vertex)
			Drawing3D_Rotate(Cylinder\Vertex[N], Drawing3DInclude\Orientation)
			V4_Subtract(Cylinder\Vertex[N], Drawing3DInclude\Position)
		Next
		Drawing3D_DrawTriangle(Cylinder\Vertex[0], Cylinder\Vertex[1], Cylinder\Vertex[2])
		Drawing3D_DrawTriangle(Cylinder\Vertex[3], Cylinder\Vertex[2], Cylinder\Vertex[1])
		Drawing3D_DrawTriangle(Cylinder\Vertex[0], Cylinder\Vertex[2], Cylinder\Vertex[4])
		Drawing3D_DrawTriangle(Cylinder\Vertex[1], Cylinder\Vertex[3], Cylinder\Vertex[5])
		Cylinder\Vertex[0] = Cylinder\Vertex[2]
		Cylinder\Vertex[1] = Cylinder\Vertex[3]
	Next
	
EndProcedure



; Zeichnet ein Bild (Image3D) in die Szene
Procedure DrawImage3D(Image3D.i, X.f, Y.f, Z.f, Width.f, Height.f, RotationX.f=0, RotationY.f=0, RotationZ.f=0)
	
	Protected Plane.Drawing3D_Plane
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected N.i
	
	Drawing3DInclude\CurrentImage3D = Image3DID(Image3D)
	
	V4_Set(Vertex, X, Y, Z)
	V4_Set(Plane\Vertex[0], -Width*0.5,  Height*0.5, 0)
	V4_Set(Plane\Vertex[1],  Width*0.5,  Height*0.5, 0)
	V4_Set(Plane\Vertex[2], -Width*0.5, -Height*0.5, 0)
	V4_Set(Plane\Vertex[3],  Width*0.5, -Height*0.5, 0)
	Drawing3D_Orientation(Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	For N = 0 To 3
		Drawing3D_Rotate(Plane\Vertex[N], Orientation)
		V4_Add(Plane\Vertex[N], Vertex)
		Drawing3D_Rotate(Plane\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Plane\Vertex[N], Drawing3DInclude\Position)
	Next
	
	Drawing3D_DrawTriangle(Plane\Vertex[0], Plane\Vertex[1], Plane\Vertex[2], 1)
	Drawing3D_DrawTriangle(Plane\Vertex[3], Plane\Vertex[2], Plane\Vertex[1], -1)
	
	Drawing3DInclude\CurrentImage3D = #Null
	
EndProcedure



; Zeichnet ein verzerrtes Bild (Image3D) in die Szene
Procedure DrawTranformedImage3D(Image3D.i, X1.f, Y1.f, Z1.f, X2.f, Y2.f, Z2.f, X3.f, Y3.f, Z3.f, X4.f, Y4.f, Z4.f)
	
	Protected Plane.Drawing3D_Plane
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected N.i
	
	Drawing3DInclude\CurrentImage3D = Image3DID(Image3D)
	
	V4_Set(Plane\Vertex[0], X1, Y1, Z1)
	V4_Set(Plane\Vertex[1], X2, Y2, Z2)
	V4_Set(Plane\Vertex[2], X3, Y3, Z3)
	V4_Set(Plane\Vertex[3], X4, Y4, Z4)
	For N = 0 To 3
		Drawing3D_Rotate(Plane\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Plane\Vertex[N], Drawing3DInclude\Position)
	Next
	
	Drawing3D_DrawTriangle(Plane\Vertex[0], Plane\Vertex[1], Plane\Vertex[2], 1)
	Drawing3D_DrawTriangle(Plane\Vertex[3], Plane\Vertex[2], Plane\Vertex[1], -1)
	
	Drawing3DInclude\CurrentImage3D = #Null
	
EndProcedure



Procedure DrawText3D(X.f, Y.f, Z.f, RotationX.f, RotationY.f, RotationZ.f, Text.s, Color.i)
	
	Protected Plane.Drawing3D_Plane
	Protected Width.i = TextWidth(Text)
	Protected Height.i = TextHeight(Text)
	Protected Orientation.Matrix4, Vertex.Vector4
	Protected Image3D.i = CreateImage3D(#PB_Any, #PB_Default, Width, Height)
	Protected N.i
	
	Drawing3DInclude\CurrentImage3D = Image3D
	DrawingMode(#PB_2DDrawing_CustomFilter)
	CustomFilterCallback(@DrawText3D_CustomFilter())
	DrawText(0, 0, Text, Color)
	
	V4_Set(Vertex, X, Y, Z)
	V4_Set(Plane\Vertex[0], -Width*0.5,  Height*0.5, 0)
	V4_Set(Plane\Vertex[1],  Width*0.5,  Height*0.5, 0)
	V4_Set(Plane\Vertex[2], -Width*0.5, -Height*0.5, 0)
	V4_Set(Plane\Vertex[3],  Width*0.5, -Height*0.5, 0)
	Drawing3D_Orientation(Orientation, Radian(RotationX), Radian(RotationY), Radian(RotationZ))
	For N = 0 To 3
		Drawing3D_Rotate(Plane\Vertex[N], Orientation)
		V4_Add(Plane\Vertex[N], Vertex)
		Drawing3D_Rotate(Plane\Vertex[N], Drawing3DInclude\Orientation)
		V4_Subtract(Plane\Vertex[N], Drawing3DInclude\Position)
	Next
	
	Drawing3D_DrawTriangle(Plane\Vertex[0], Plane\Vertex[1], Plane\Vertex[2], 1)
	Drawing3D_DrawTriangle(Plane\Vertex[3], Plane\Vertex[2], Plane\Vertex[1], -1)
	
	FreeImage3D(Image3D)
	Drawing3DInclude\CurrentImage3D = #Null
	
EndProcedure



Drawing3D_Orientation(Drawing3DInclude\Orientation, 0, 0, 0)

EndModule
