
XIncludeFile "Drawing3D.pbi" : UseModule Drawing3D


Enumeration
	#Window
	#Gadget
	#ListViewGadget
	#Image
	#Image3D
	#ButtonGadget
	#RealImage
	#Font
EndEnumeration


Procedure UpdateCanvasGadget(Gadget, Image.i=#Null)
	
	Static MouseX.i, MouseY.i, Distance.f = 700
	Protected X.i, Y.i, Z.i, N, W.i, R.i, Phi.i, Theta.i, R1.f, R2.f, Dim Y.f(40, 40), Dim Color.l(40, 40)
	Protected Time1.i, Time2.i, Color.i, CountPixel.i
	
	Time1 = ElapsedMilliseconds()
	
	If Image
		StartDrawing3D(ImageOutput(Image))
		Drawing3DBackground($00FFFFFF)
	Else
		StartDrawing3D(CanvasOutput(Gadget))
		Drawing3DBackground($FFFFFFFF)
		Distance * Pow(1.1, GetGadgetAttribute(Gadget, #PB_Canvas_WheelDelta))
		If GetGadgetAttribute(Gadget, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton  
			Drawing3DRotation(Radian(GetGadgetAttribute(Gadget, #PB_Canvas_MouseY)-MouseY)*15, Radian(GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)-MouseX)*15, 0, #PB_Relative)
		EndIf
		MouseY = GetGadgetAttribute(Gadget, #PB_Canvas_MouseY)
		MouseX = GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)
	EndIf
	
	Drawing3DPosition(0, 0, -Distance)
	
	Select GetGadgetState(#ListViewGadget)
			
		Case 0
			
			DrawPlane3D(0, 0, 0, 340, 200,  0,  0,  0, $80FF0000)
			DrawPlane3D(0, 0, 0, 340, 200, 90, 90,  0, $800000FF)
			DrawPlane3D(0, 0, 0, 340, 200, 90,  0, 90, $8000FF00)
			
		Case 1
			
			Drawing3DMode(#Drawing3D_Outline)
			DrawBox3D(0, 0, 0, 200, 200, 200, 0, 0, 0, $FF000000)
			Drawing3DMode(#Drawing3D_Default)
			
		Case 2
			
			Drawing3DLight(1, 0, 0, $FFFFFF00)
			Drawing3DLight(-1, 0, 0, $FF00FFFF)
			DrawBox3D(0, 0, 0, 200, 200, 200, 0, 0, 0, $FF000000)
			
		Case 3
			
			Drawing3DLight(0.5, 1, 1, $FFFFFFFF)
			DrawBox3D(0, 0, 0, 100, 200, 300, 0, 0, 0, $C000C060)
			DrawBox3D(0, 0, 0, 100, 200, 300, 30, 45, 15, $C08000C0)
			
		Case 4
			
			Drawing3DLight(0.5, 1, -1, $FFFFFFFF)
			DrawTriangle3D(-100, 100, 100, 100, 100, -100, 100, -100, 100, $FF00C000, $FFC00000, $FF0000C0)
			DrawTriangle3D(-100, 100, 100, 100, -100, 100, -100, -100, -100, $FF00C000, $FF0000C0, $FF00C0C0)
			DrawTriangle3D(-100, 100, 100, -100, -100, -100, 100, 100, -100, $FF00C000, $FF00C0C0, $FFC00000)
			DrawTriangle3D(100, -100, 100, 100, 100, -100, -100, -100, -100, $FF0000C0, $FFC00000, $FF00C0C0)
			DrawLine3D(90, -90, -90, -90, -90, 90, $FF00C000, $FFC00000)
			DrawLine3D(-90, -90, 90, -90, 90, -90, $FFC00000, $FF0000C0)
			DrawLine3D(-90, 90, -90, 90, -90, -90, $FF0000C0, $FF00C000)
			DrawLine3D(90, -90, -90, 90, 90, 90, $FF00C000, $FF00C0C0)
			DrawLine3D(-90, -90, 90, 90, 90, 90, $FFC00000, $FF00C0C0)
			DrawLine3D(-90, 90, -90, 90, 90, 90, $FF0000C0, $FF00C0C0)
			
		Case 5
			
			DrawImage3D(#Image3D, 0, 0, 0, 400, 400, 0, 0, 0)
			
		Case 6
			
			RandomSeed(1)
			DrawPlane3D(0, 0, 0, 200, 200, 90, 0, 0, $FF808080)
			For Y = -200 To 200
				For X = -200 To 200
					Z = Random(100)-50
					DrawPoint3D(X, Y, Z, $FF000000)
				Next
			Next
			
		Case 7
			
			Drawing3DLight(0.5, 1, 1, $80FFFFFF)
			Drawing3DMode(#Drawing3D_Default)
			DrawCylinder3D(0, 0, 0, 20, 200, 0, 0, 0, $FF800000, $FF008080)
			DrawCylinder3D(0, 0, 0, 20, 200, 0, 0, 90, $FF008000, $FF800080)
			DrawCylinder3D(0, 0, 0, 20, 200, 90, 0, 0, $FF000080, $FF808000)
			Drawing3DMode(#Drawing3D_Outline)
			DrawBox3D(0, 0, 0, 200, 200, 200, 0, 0, 0, $80000000)
			Drawing3DMode(#Drawing3D_Default)
			
		Case 8
			
			Drawing3DLight(0.5, 1, 1, $40FFFFFF)
			DrawBox3D(0, 0, 0, 100, 30, 30, 0, 0, 0, $FF404040)
			DrawBox3D(-75, 0, 0, 50, 30, 30, 0, 0, 0, $FF808000)
			DrawBox3D(75, 0, 0, 50, 30, 30, 0, 0, 0, $FF000080)
			RandomSeed(5)
			For N = 1 To 50
				Phi = Random(359)
				R = Random(100)+30
				For W = 0 To 359 Step 5
					R1 = (1-Cos(Radian(W)))*R
					R2 = (1-Cos(Radian(W+5)))*R
					DrawLine3D(-Sin(Radian(W))*R*2, R1*Sin(Radian(Phi)), R1*Cos(Radian(Phi)), -Sin(Radian(W+5))*R*2, R2*Sin(Radian(Phi)), R2*Cos(Radian(Phi)), RGBA(255*W/360, 255*(360-W)/360, 255*(360-W)/360, 192))
				Next
			Next
			
		Case 9
			
			Drawing3DLight(0.5, 1, 1, $20FFFFFF)
			For Z = -20 To 20
				For X = -20 To 20
					Y(X+20,Z+20) = Exp(-X*X/100-Z*Z/100)*(X+Z/4)/5
					If Y(X+20,Z+20) < 0
						Color(X+20,Z+20) = RGBA(0, 128+128*Y(X+20,Z+20), -255*Y(X+20,Z+20), 255)
					Else
						Color(X+20,Z+20) = RGBA(255*Y(X+20,Z+20), 128+128*Y(X+20,Z+20), 0, 255)
					EndIf
					Y(X+20,Z+20) * 200
				Next
			Next
			For Z = -20 To 19
				For X = -20 To 19
					DrawTriangle3D(X*10, Y(X+20,Z+20), Z*10, (X+1)*10, Y(X+21,Z+20), Z*10, X*10, Y(X+20,Z+21), (Z+1)*10, Color(X+20,Z+20), Color(X+21,Z+20), Color(X+20,Z+21))
					DrawTriangle3D((X+1)*10, Y(X+21,Z+21), (Z+1)*10, X*10, Y(X+20,Z+21), (Z+1)*10, (X+1)*10, Y(X+21,Z+20), Z*10, Color(X+21,Z+21), Color(X+20,Z+21), Color(X+21,Z+20))
				Next
			Next
			
		Case 10
			
			Color = $FF000000
			Drawing3DLight(Cos(Radian(120)), Sin(Radian(120)), 1, $FFC08000)
			Drawing3DLight(1, 0, 1, $FF00C080)
			Drawing3DLight(Cos(Radian(240)), Sin(Radian(240)), 1, $FF8000C0)
			
			Protected Phi1.f, Phi2.f, Phi3.f, Phi4.f, Theta1.f, Theta2.f
			
			DrawTriangle3D( 162,    0,  100,    0, -100,  162,    0,  100,  162, $C0404040)
			DrawTriangle3D( 162,    0,  100,    0,  100,  162,  100,  162,    0, $C0404040)
			DrawTriangle3D( 162,    0,  100,  100,  162,    0,  162,    0, -100, $C0404040)
			DrawTriangle3D( 162,    0,  100,  162,    0, -100,  100, -162   , 0, $C0404040)
			DrawTriangle3D( 162,    0,  100,  100, -162,    0,    0, -100,  162, $C0404040)
			
			DrawTriangle3D(-162,    0, -100,    0, -100, -162,    0,  100, -162, $C0404040)
			DrawTriangle3D(-162,    0, -100,    0,  100, -162, -100,  162,    0, $C0404040)
			DrawTriangle3D(-162,    0, -100, -100,  162,    0, -162,    0,  100, $C0404040)
			DrawTriangle3D(-162,    0, -100, -162,    0,  100, -100, -162,    0, $C0404040)
			DrawTriangle3D(-162,    0, -100, -100, -162,    0,    0, -100, -162, $C0404040)
			
			DrawTriangle3D(   0, -100,  162, -162,    0,  100,    0,  100,  162, $C0404040)
			DrawTriangle3D(   0,  100,  162, -100,  162,    0,  100,  162,    0, $C0404040)
			DrawTriangle3D( 100,  162,    0,    0,  100, -162,  162,    0, -100, $C0404040)
			DrawTriangle3D( 162,    0, -100,    0, -100, -162,  100, -162,    0, $C0404040)
			DrawTriangle3D( 100, -162,    0, -100, -162,    0,    0, -100,  162, $C0404040)
			
			DrawTriangle3D(   0, -100, -162,  162,    0, -100,    0,  100, -162, $C0404040)
			DrawTriangle3D(   0,  100, -162,  100,  162,    0, -100,  162,    0, $C0404040)
			DrawTriangle3D(-100,  162,    0,    0,  100,  162, -162,    0,  100, $C0404040)
			DrawTriangle3D(-162,    0,  100,    0, -100,  162, -100, -162,    0, $C0404040)
			DrawTriangle3D(-100, -162,    0,  100, -162,    0,    0, -100, -162, $C0404040)
			
			Drawing3DMode(#Drawing3D_Outline)
			
			DrawTriangle3D( 162,    0,  100,    0, -100,  162,    0,  100,  162, $FF000000)
			DrawTriangle3D( 162,    0,  100,    0,  100,  162,  100,  162,    0, $FF000000)
			DrawTriangle3D( 162,    0,  100,  100,  162,    0,  162,    0, -100, $FF000000)
			DrawTriangle3D( 162,    0,  100,  162,    0, -100,  100, -162   , 0, $FF000000)
			DrawTriangle3D( 162,    0,  100,  100, -162,    0,    0, -100,  162, $FF000000)
			
			DrawTriangle3D(-162,    0, -100,    0, -100, -162,    0,  100, -162, $FF000000)
			DrawTriangle3D(-162,    0, -100,    0,  100, -162, -100,  162,    0, $FF000000)
			DrawTriangle3D(-162,    0, -100, -100,  162,    0, -162,    0,  100, $FF000000)
			DrawTriangle3D(-162,    0, -100, -162,    0,  100, -100, -162,    0, $FF000000)
			DrawTriangle3D(-162,    0, -100, -100, -162,    0,    0, -100, -162, $FF000000)
			
			DrawTriangle3D(   0, -100,  162, -162,    0,  100,    0,  100,  162, $FF000000)
			DrawTriangle3D(   0,  100,  162, -100,  162,    0,  100,  162,    0, $FF000000)
			DrawTriangle3D( 100,  162,    0,    0,  100, -162,  162,    0, -100, $FF000000)
			DrawTriangle3D( 162,    0, -100,    0, -100, -162,  100, -162,    0, $FF000000)
			DrawTriangle3D( 100, -162,    0, -100, -162,    0,    0, -100,  162, $FF000000)
			
			DrawTriangle3D(   0, -100, -162,  162,    0, -100,    0,  100, -162, $FF000000)
			DrawTriangle3D(   0,  100, -162,  100,  162,    0, -100,  162,    0, $FF000000)
			DrawTriangle3D(-100,  162,    0,    0,  100,  162, -162,    0,  100, $FF000000)
			DrawTriangle3D(-162,    0,  100,    0, -100,  162, -100, -162,    0, $FF000000)
			DrawTriangle3D(-100, -162,    0,  100, -162,    0,    0, -100, -162, $FF000000)
			
			Drawing3DMode(#Drawing3D_Default)
			
		Case 11
			
			Color = $FF000000
			Drawing3DLight(Cos(Radian(120)), Sin(Radian(120)), 1, $FFC08000)
			Drawing3DLight(1, 0, 1, $FF00C080)
			Drawing3DLight(Cos(Radian(240)), Sin(Radian(240)), 1, $FF8000C0)
			For Phi = 0 To 359 Step 5
				For R = -50 To 49 Step 5
					Phi1.f = Radian(Phi)
					Phi2.f = Radian(Phi+5)
					R1.f = R
					R2.f = R+5
					DrawTriangle3D(	Cos(Phi1)*(100+R1*Cos(Phi1/2)), Sin(Phi1)*(100+R1*Cos(Phi1/2)), Sin(Phi1/2)*R1,
													Cos(Phi2)*(100+R1*Cos(Phi2/2)), Sin(Phi2)*(100+R1*Cos(Phi2/2)), Sin(Phi2/2)*R1,
													Cos(Phi2)*(100+R2*Cos(Phi2/2)), Sin(Phi2)*(100+R2*Cos(Phi2/2)), Sin(Phi2/2)*R2, Color)
					DrawTriangle3D(	Cos(Phi1)*(100+R1*Cos(Phi1/2)), Sin(Phi1)*(100+R1*Cos(Phi1/2)), Sin(Phi1/2)*R1,
													Cos(Phi1)*(100+R2*Cos(Phi1/2)), Sin(Phi1)*(100+R2*Cos(Phi1/2)), Sin(Phi1/2)*R2,
													Cos(Phi2)*(100+R2*Cos(Phi2/2)), Sin(Phi2)*(100+R2*Cos(Phi2/2)), Sin(Phi2/2)*R2, Color)
				Next
			Next
			
		Case 12
			
			DrawingFont(FontID(#Font))
			DrawBox3D(0, 0, 0, 400, 5, 5, 0, 0, 0, $40FF8000)
			DrawBox3D(0, 0, 0, 5, 400, 5, 0, 0, 0, $4000E070)
			DrawBox3D(0, 0, 0, 5, 5, 400, 0, 0, 0, $408000FF)
			DrawText3D(100, 20, 0, 0, 0, 0, "X-Achse", $80FF8000)
			DrawText3D(-100, -20, 0, 0, 0, 180, "X-Achse", $80FF8000)
			DrawText3D(0, 100, 20, 90, 90, 0, "Y-Achse", $8000E070)
			DrawText3D(0, -100, -20, 90, 90, 180, "Y-Achse", $8000E070)
			DrawText3D(20, 0, 100, -90, 0, -90, "Z-Achse", $808000FF)
			DrawText3D(-20, 0, -100, -90, 0, 90, "Z-Achse", $808000FF)
			
	EndSelect
	StopDrawing3D()
	
	Time2 = ElapsedMilliseconds()
	SetWindowTitle(#Window, "Renderzeit: "+Str((Time2-Time1))+" ms")
	
EndProcedure



UsePNGImageDecoder()
UsePNGImageEncoder()

CatchImage(#Image, ?Image)
CreateImage3D(#Image3D, #Image)
LoadFont(#Font, "Verdana", 24, #PB_Font_Bold)

OpenWindow(#Window, 0, 0, 900, 600, "", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
CanvasGadget(#Gadget, 10, 10, 580, 580, #PB_Canvas_Border|#PB_Canvas_Keyboard)
FrameGadget(#PB_Any, 600, 10, 290, 290, "Szenenauswahl")
ListViewGadget(#ListViewGadget, 610, 30, 270, 260)
	AddGadgetItem(#ListViewGadget, -1, "Drei sich durchdringende Flhen")
	AddGadgetItem(#ListViewGadget, -1, "W?rfel aus Linien")
	AddGadgetItem(#ListViewGadget, -1, "Belichteter W?rfel")
	AddGadgetItem(#ListViewGadget, -1, "Zwei durchdringende Quader")
	AddGadgetItem(#ListViewGadget, -1, "Tetraeder mit verschiedenen Eckfarben")
	AddGadgetItem(#ListViewGadget, -1, "Texturflhe")
	AddGadgetItem(#ListViewGadget, -1, "Punkte")
	AddGadgetItem(#ListViewGadget, -1, "Zylinder")
	AddGadgetItem(#ListViewGadget, -1, "Anwendungsbeispiel: Magnet & Feldlinien")
	AddGadgetItem(#ListViewGadget, -1, "Anwendungsbeispiel: 3D-Funktion")
	AddGadgetItem(#ListViewGadget, -1, "Anwendungsbeispiel: Ikosaeder")
	AddGadgetItem(#ListViewGadget, -1, "Anwendungsbeispiel: Mius")
	AddGadgetItem(#ListViewGadget, -1, "Anwendungsbeispiel: Text3D")
SetGadgetState(#ListViewGadget, 11)
TextGadget(#PB_Any, 610, 310, 290, 20, "Left mouse to rotate the scene")
Drawing3DRotation(30, 30, 90)
UpdateCanvasGadget(#Gadget)


ButtonGadget(#ButtonGadget, 610, 350, 190, 30, "Save real 32Bit-Image")

Define FileName.s

Repeat
	
	Select WaitWindowEvent()
			
		Case #PB_Event_CloseWindow
			End
			
		Case #PB_Event_Gadget
			Select EventGadget()
				Case #Gadget, #ListViewGadget
					UpdateCanvasGadget(#Gadget)
				Case #ButtonGadget
					CreateImage(#RealImage, 600, 600, 32, #PB_Image_Transparent)
					UpdateCanvasGadget(#Gadget, #RealImage)
					FileName = SaveFileRequester("Save", "", "*.png|*.PNG", 1)
					If FileName
						If LCase(GetExtensionPart(FileName)) <> "png" : FileName + ".png" : EndIf
						SaveImage(#RealImage, FileName, #PB_ImagePlugin_PNG)
					EndIf
			EndSelect
			
	EndSelect
	
ForEver


DataSection
	Image:
	IncludeBinary "Image.png"
EndDataSection
