;   Description: Triangulations-Algorithmus from s-hull.org
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27647
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 NicTheQuick
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

EnableExplicit

#WIDTH = 1600
#HEIGHT = 1000

; If the bug mentioned at http://www.purebasic.fr/english/viewtopic.php?f=23&t=57961
; was solved, set this do #False
#BUG = #True

;-- START OF TRIANGULATION STRUCTURES AND FUNCTIONS

DeclareModule Triangulation
  #PRECISION = #PB_Float ;oder #PB_Double
  #MAKE_DELAUNAY = #True
  
  #DEBUG = #False
  
  CompilerIf #PRECISION = #PB_Float
    Macro prec
      f
    EndMacro
    #EPSILON = 0.00001
  CompilerElseIf #PRECISION = #PB_Double
    Macro prec
      d
    EndMacro
    #EPSILON = 0.00000001
  CompilerElse
    CompilerError "Precision not supported."
  CompilerEndIf
  
  Structure Point2D
    x.prec
    y.prec
  EndStructure
  
  Structure Vector2D Extends Point2D
  EndStructure
  
  ; Eine Kante merkt sich seine Endpunkte und die maximal zwei Dreicke, zu denen sie gehört
  Structure Edge2D
    *p.Point2DPC[2]
    *t.Triangle2D[2]
    mark.i
  EndStructure
  
  ; Ein Punkt merkt sich natürlich seine Koordinaten und die Kanten und Dreiecken, zu denen er gehört.
  Structure Point2DPC Extends Point2D
    List *edges.Edge2D()
  EndStructure
  
  ; Ein Dreieck merkt sich seine drei Eckpunkte und seine drei Kanten
  Structure Triangle2D
    *p.Point2DPC[3]
    *e.Edge2D[3]
  EndStructure
  
  
  
  Structure Point2DDiff
    *p.Point2D
    diff.prec
  EndStructure
  
  Structure ConvexHullPoint2D
    *p.Point2DPC
    used.i
  EndStructure
  
  Structure CircumCircle
    center.Point2D
    radius.prec
  EndStructure
  
  Structure Triangulation
    n.i
    time.i
    Array points.Point2DPC(1)
    List edges.Edge2D()
    List triangles.Triangle2D()
    List convexHull.ConvexHullPoint2D()
  EndStructure
  
  Declare clearTriangulation(*pc.Triangulation)
  Declare getCircumCircle(*a.Point2D, *b.Point2D, *c.Point2D, *cc.CircumCircle)
  Declare.i getPoint(*pc.Triangulation, x.prec, y.prec)
  Declare setPoint(*pc.Triangulation, i.i, x.prec, y.prec)
  Declare.i isRightHand(*a.Point2D, *b.Point2D, *c.Point2D)
  Declare.i isEdgeDelaunay(*edge.Edge2D)
  Declare.i isTriangleDelaunay(*triangle.Triangle2D)
  Declare triangulate(*pc.Triangulation, seed.i = 0)
EndDeclareModule

Module Triangulation
  
  Procedure clearTriangulation(*pc.Triangulation) ;correct
    Protected i.i
    
    ClearList(*pc\triangles())
    ClearList(*pc\edges())
    ClearList(*pc\convexHull())
    
    For i = 0 To *pc\n - 1
      ClearList(*pc\points(i)\edges())
    Next
  EndProcedure
  
  Procedure.i getPoint(*pc.Triangulation, x.prec, y.prec) ;correct
    Protected i.i, diffSq.prec = Infinity(), actualDiffSq.prec
    Protected nearest.i = -1
    
    With *pc
      For i = 0 To \n - 1
        actualDiffSq = Pow(\points(i)\x - x, 2) + Pow(\points(i)\y - y, 2)
        If (actualDiffSq < diffSq)
          nearest = i
          diffSq = actualDiffSq
        EndIf
      Next
    EndWith
    
    ProcedureReturn nearest   
  EndProcedure
  
  Procedure setPoint(*pc.Triangulation, i.i, x.prec, y.prec) ;correct
    If (i >= 0 And i < *pc\n)
      *pc\points(i)\x = x
      *pc\points(i)\y = y
    EndIf
  EndProcedure
  
  Procedure getCircumCircle(*a.Point2D, *b.Point2D, *c.Point2D, *cc.CircumCircle) ;correct
    Protected i.i
    
    For i = 0 To 1
      Protected m.Point2D
      m\x = 0.5 * (*b\x - *c\x)
      m\y = 0.5 * (*b\y - *c\y)
      Protected v1.Vector2D
      v1\x = *b\x - *a\x
      v1\y = *b\y - *a\y
      Protected v2.Vector2D
      v2\x = *c\x - *a\x
      v2\y = *c\y - *a\y
      
      Protected lambda.prec = NaN()
      Protected t.prec = v2\y * v1\x - v1\y * v2\x
      
      If (Abs(t) > #EPSILON)
        lambda = (v2\x * m\x + v2\y * m\y) / t
        Break
      EndIf
      Swap *a, *b
    Next
    
    *cc\center\x = lambda * v1\y + 0.5 * (*a\x + *b\x)
    *cc\center\y = - lambda * v1\x + 0.5 * (*a\y + *b\y)
    *cc\radius = Sqr(Pow(*cc\center\x - *a\x, 2) + Pow(*cc\center\y - *a\y, 2))
  EndProcedure
  
  Procedure.i isRightHand(*a.Point2D, *b.Point2D, *c.Point2D) ;correct
    Protected ab.Vector2D, bc.Vector2D
    
    ab\x = *b\x - *a\x
    ab\y = *b\y - *a\y
    bc\x = *c\x - *b\x
    bc\y = *c\y - *b\y
    
    Protected z.prec = ab\x * bc\y - ab\y * bc\x
    ProcedureReturn Bool(z < 0.0)
  EndProcedure
  
  Procedure orderRightHand(*a.Point2D, *p_b.Integer, *p_c.Integer) ;correct
    If (Not isRightHand(*a, *p_b\i, *p_c\i))
      Swap *p_b\i, *p_c\i
    EndIf
  EndProcedure
  
  Procedure.i addEdge(*pc.Triangulation, *a.Point2DPC, *b.Point2DPC) ;correct
                                                                     ;Zwei identische Punkte ergeben keine Linie
    If (*a = *b)
      ProcedureReturn #False
    EndIf
    
    ;Existiert bereits eine Linie mit diesen beiden Punkten?
    ForEach *a\edges()
      If (*a\edges()\p[0] = *b Or *a\edges()\p[1] = *b)
        ProcedureReturn *a\edges()
      EndIf
    Next
    
    ;Füge die Linie hinzu und speichere ihre Referenz in den Punkten
    If AddElement(*pc\edges())
      *pc\edges()\p[0] = *a
      *pc\edges()\p[1] = *b
      *pc\edges()\t[0] = 0
      *pc\edges()\t[1] = 0
      AddElement(*a\edges())
      *a\edges() = @*pc\edges()
      AddElement(*b\edges())
      *b\edges() = @*pc\edges()
      
      ProcedureReturn @*pc\edges()
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i addTriangle(*pc.Triangulation, *a.Point2DPC, *b.Point2DPC, *c.Point2DPC) ;correct
                                                                                       ;Zwei identische Punkte ergeben kein Dreieck
    If (*a = *b Or *b = *c Or *a = *c)
      ProcedureReturn #False
    EndIf
    
    ;Make sure the triangle's points are ordered in right hand order
    orderRightHand(*a, @*b, @*c)
    
    Protected Dim *l.Edge2D(2)
    *l(0) = addEdge(*pc, *a, *b)
    *l(1) = addEdge(*pc, *b, *c)
    *l(2) = addEdge(*pc, *c, *a)
    
    ;Prüfe, ob die drei Linien zufällig schon ein Dreieck bilden.
    ;Falls ja, dann gib einfach das zurück.
    Protected j.i, k.i, *triangle.Triangle2D, used.i
    For j = 0 To 1
      used = 0
      *triangle = *l(0)\t[j]
      If (*triangle)
        For k = 0 To 1
          used + Bool(*l(1)\t[k] = *triangle)
          used + Bool(*l(2)\t[k] = *triangle)
        Next
        If (used = 2)
          Debug "Doppeltes Dreieck?"
          ProcedureReturn *triangle
        EndIf
      EndIf
    Next
    
    If (AddElement(*pc\triangles()))
      With *pc\triangles()
        For j = 0 To 2
          \e[j] = *l(j)
          \e[j]\t[Bool(\e[j]\t[0])] = @*pc\triangles()
        Next
        \p[0] = *a
        \p[1] = *b
        \p[2] = *c
      EndWith
      ProcedureReturn @*pc\triangles()
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i isEdgeDelaunay(*edge.Edge2D) ;correct
    Protected cc.CircumCircle, i.i, j.i, *p.Point2D
    
    With *edge
      If (\t[1])
        For i = 0 To 1   ;Iterate over adjacent triangles
          getCircumCircle(\t[i]\p[0], \t[i]\p[1], \t[i]\p[2], @cc)
          
          For j = 0 To 2   ;Iterate over points of other triangle
            *p = \t[1 - i]\p[j]
            If (*p <> \p[0] And *p <> \p[1]) ;Is the actual point not belonging to the actual edge?
                                             ; Is this point from the other triangle within the circum circle of the actual triangle?
              If (Pow(*p\x - cc\center\x, 2) + Pow(*p\y - cc\center\y, 2) - cc\radius * cc\radius < #EPSILON)
                ProcedureReturn #False
              EndIf
            EndIf
          Next
        Next
      EndIf
    EndWith
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i isTriangleDelaunay(*triangle.Triangle2D) ;correct
    Protected cc.CircumCircle, i.i, j.i, k.i, *edge.Edge2D, *p.Point2D
    
    For k = 0 To 2
      If (Not isEdgeDelaunay(*triangle\e[k]))
        ProcedureReturn #False
      EndIf
    Next
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure makeDelaunay(*pc.Triangulation) ;correct
    Protected NewList *ndEdges.Edge2D()
    Protected cc.CircumCircle, *p.Point2D
    Protected Dim p_i.i(1) ;p_i(x) : Index to point of triangle x which not belongs to the actual edge
    Protected i.i, j.i, doFlip.i
    Protected *actualEdge.Edge2D, *newEdge.Edge2D
    
    ForEach *pc\edges()
      If (*pc\edges()\t[1] And (Not isEdgeDelaunay(*pc\edges())))
        If (AddElement(*ndEdges()))
          *ndEdges() = @*pc\edges()
        EndIf
        *pc\edges()\mark = #True
      Else
        *pc\edges()\mark = #False
      EndIf
    Next
    
    While FirstElement(*ndEdges())
      *actualEdge = *ndEdges()
      DeleteElement(*ndEdges())
      With *actualEdge
        \mark = #False
        doFlip = #False
        
        For i = 0 To 1   ;Iterate over adjacent triangles
          getCircumCircle(\t[i]\p[0], \t[i]\p[1], \t[i]\p[2], @cc)
          
          For j = 0 To 2   ;Iterate over points of other triangle
            *p = \t[1 - i]\p[j]
            If (*p <> \p[0] And *p <> \p[1]) ;Is the actual point not belonging to the actual edge?
                                             ; Is this point from the other triangle within the circum circle of the actual triangle?
              If (Pow(*p\x - cc\center\x, 2) + Pow(*p\y - cc\center\y, 2) - cc\radius * cc\radius < #EPSILON)
                p_i(1 - i) = j
                doFlip = #True
              EndIf
            EndIf
          Next
        Next
        
        If (doFlip)
          CompilerIf #DEBUG
            Protected error.i = #False
            ;Be sure p_i is correct
            For i = 0 To 1
              If (\t[i]\p[p_i(i)] = \p[0] Or \t[i]\p[p_i(i)] = \p[1])
                Debug "p_i(" + i + ") ist nicht korrekt! (Points) [" + \t[i] + "]"
                error = #True
              EndIf
              If (\t[i]\e[(p_i(i) + 1) % 3] <> *actualEdge)
                Debug "p_i(" + i + ") ist nicht korrekt! (Edges) [" + \t[i] + "]"
                error = #True
              EndIf
              If (Not isRightHand(\t[i]\p[0], \t[i]\p[1], \t[i]\p[2]))
                Debug "Triangle " + i + " is not in the right order! [" + \t[i] + "]"
                error = #True
              EndIf
            Next
            If (error)
              Debug "Error on " + *actualEdge
              ProcedureReturn #False
            EndIf
            Debug "flip on " + *actualEdge + " with [" + \t[0] + "] and [" + \t[1] + "]"
          CompilerEndIf
          
          ;Delete Edge from Points-Array
          For i = 0 To 1
            ForEach \p[i]\edges()
              If (\p[i]\edges() = *actualEdge)
                DeleteElement(\p[i]\edges())
                Break
              EndIf
            Next
          Next
          
          ;Swap points to create new triangles.
          ;This loop runs without error if the triangle's points are ordered in right hand order
          ;and the edge's order correlates to the points.
          For i = 0 To 1
            ;Give actual edge the new coordinates
            \p[i] = \t[i]\p[p_i(i)]
            
            ;Make the edge known to the point
            AddElement(\p[i]\edges())
            \p[i]\edges() = *actualEdge
            
            ;Change third point of triangle i to first point of triangle 1 - i
            \t[i]\p[(p_i(i) + 2) % 3] = \t[1 - i]\p[p_i(1 - i)]
            
            ;Change second edge of triangle i to third edge of triangle 1 - i
            \t[i]\e[(p_i(i) + 1) % 3] = \t[1 - i]\e[(p_i(1 - i) + 2) % 3]
            
            ;Correct neighbours of new second edge of triangle i
            Protected *e.Edge2D
            *e = \t[i]\e[(p_i(i) + 1) % 3]
            For j = 0 To 1
              If (*e\t[j] = \t[1 - i])
                *e\t[j] = \t[i]
              EndIf
            Next
          Next
          
          For i = 0 To 1
            ;Change third edge of triangle i to actual edge
            \t[i]\e[(p_i(i) + 2) % 3] = *actualEdge
          Next
          
          CompilerIf #DEBUG
            If (addEdge(*pc, \t[0]\p[p_i(0)], \t[1]\p[p_i(1)]) <> *actualEdge)
              Debug "actualEdge problem!"
            EndIf
            
            For i = 0 To 1
              If (Not isRightHand(\t[i]\p[0], \t[i]\p[1], \t[i]\p[2]))
                Debug "Triangle " + i + " is no more in the right order!"
              EndIf
            Next
          CompilerEndIf
          
          ;Edge is now Delauney. Add adjacent Edges to List.
          LastElement(*ndEdges())
          For i = 0 To 1
            For j = 0 To 1
              *newEdge = \t[i]\e[(p_i(i) + j) % 3]
              If ((Not *newEdge\mark) And *newEdge\t[1])
                If (AddElement(*ndEdges()))
                  *ndEdges() = *newEdge
                  *newEdge\mark = #True
                EndIf
              EndIf
            Next
          Next
        EndIf
      EndWith
    Wend
    
  EndProcedure
  
  Procedure triangulate(*pc.Triangulation, seed.i = 0) ;correct
    Protected Dim sortedPoints.Point2DDiff(*pc\n - 1)
    Protected i.i
    
    With *pc
      \time = ElapsedMilliseconds()
      If (\n < 3)
        ProcedureReturn #False
      EndIf
      
      ;1. Select a seed point x_0 from x_i.
      If (seed < 0 Or seed >= \n)
        ProcedureReturn #False
      EndIf
      Protected *x0.Point2DPC = @\points(seed)
      
      clearTriangulation(*pc)
      
      ;2. Sort according to |x_i - x_0|^2.
      For i = 0 To \n - 1
        sortedPoints(i)\p = @\points(i)
        sortedPoints(i)\diff = Pow(*x0\x - \points(i)\x, 2) + Pow(*x0\y - \points(i)\y, 2)
      Next
      SortStructuredArray(sortedPoints(), #PB_Sort_Ascending, OffsetOf(Point2DDiff\diff), #PRECISION)
      
      ;3. Find the point x_j closest to x_0.
      Protected *xj.Point2DPC = sortedPoints(1)\p
      
      ;4. Find the point x_k that creates the smallest circum-circle
      ;   with x_0 and x_j and record the center of the circum-circle C.
      Protected bestIndex.i
      Protected C.CircumCircle, bestC.CircumCircle
      bestC\radius = Infinity()
      For i = 2 To \n - 1
        getCircumCircle(*x0, *xj, sortedPoints(i)\p, @C)
        If (C\radius < bestC\radius)
          bestIndex = i
          bestC = C
        EndIf
      Next
      
      ;5. Resort the remaining points according to |x_i - C|^2 to
      ;   give points s_i.
      If (bestIndex <> 2)
        Swap sortedPoints(2)\p, sortedPoints(bestIndex)\p
      EndIf
      For i = 3 To \n - 1
        sortedPoints(i)\diff = Pow(bestC\center\x - sortedPoints(i)\p\x, 2) + Pow(bestC\center\y - sortedPoints(i)\p\y, 2)
      Next
      SortStructuredArray(sortedPoints(), #PB_Sort_Ascending, OffsetOf(Point2DDiff\diff), #PRECISION, 3, \n - 1)
      
      ;6. Order point x_0, x_j, x_k to give a right handed system.
      ;   This is the initial seed convex hull.
      Protected *xk.Point2DPC = sortedPoints(2)\p
      orderRightHand(*x0, @*xk, @*xj)
      
      ;7. Sequentially add the points s_i to the prppagating 2D convex
      ;   hull that is seeded with the triangle formed from x_0, x_j, x_k.
      ;   As a new point is added the facets of the 2D-hull that are visible
      ;   to it form new triangles.
      addTriangle(*pc, *x0, *xk, *xj)
      ClearList(\convexHull())
      AddElement(\convexHull()) : \convexHull()\p = *x0
      AddElement(\convexHull()) : \convexHull()\p = *xk
      AddElement(\convexHull()) : \convexHull()\p = *xj
      
      Protected *p.Point2D, *last.ConvexHullPoint2D, alreadyAdded.i, convexHullSize.i, j.i
      For i = 3 To \n - 1
        *p = sortedPoints(i)\p
        
        alreadyAdded = #False
        convexHullSize = ListSize(\convexHull())
        FirstElement(\convexHull())
        *last = @\convexHull()
        NextElement(\convexHull())
        For j = 0 To convexHullSize - 1
          If (isRightHand(*last\p, *p, \convexHull()\p))
            addTriangle(*pc, *last\p, *p, \convexHull()\p)
            \convexHull()\used + 1
            *last\used + 1
            
            If (Not alreadyAdded)
              InsertElement(\convexHull())
              \convexHull()\p = *p
              NextElement(\convexHull())
              convexHullSize + 1
              alreadyAdded = #True
            EndIf
          EndIf
          *last = @\convexHull()
          If (Not NextElement(\convexHull()))
            FirstElement(\convexHull())
          EndIf
        Next
        
        ForEach \convexHull()
          If (\convexHull()\used = 2)
            DeleteElement(\convexHull(), 1)
          Else
            \convexHull()\used = 0
          EndIf
        Next
        
      Next
      
      ;8. A non-overlapping triangulation of the set of points is created.
      ;   (This is an extremely fast method for creating an non-overlapping
      ;   triangualtion of a 2D point set).
      
      ;9: Adjacent pairs of triangles of this triangulation must be 'flipped'
      ;   to create a Delaunay triangulation from the initial non-overlapping
      ;   triangulation.
      CompilerIf #MAKE_DELAUNAY
        makeDelaunay(*pc)
      CompilerEndIf
      
      
      \time = ElapsedMilliseconds() - \time
    EndWith
    
  EndProcedure
  
EndModule

;-- END OF TRIANGULATION FUNCTIONS



;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Structure Window
    id.i
    width.i
    height.i
    title.s
    
    canvasId.i
    *pc.Triangulation::Triangulation
    clicked.i
    leftDown.i
    rightDown.i
  EndStructure
  
  #MAX_INTEGER = 1 << (SizeOf(Integer) * 8 - 1) - 1
  #MIN_INTEGER = ~#MAX_INTEGER
  
  
  
  ;Erstellt zufällige Punkte
  Procedure CreateRandomizedPointCloud(*pc.Triangulation::Triangulation, n.i, minX.d = 0.0, minY.d = 0.0, maxX.d = 1.0, maxY.d = 1.0)
    Protected i.i
    
    With *pc
      Triangulation::clearTriangulation(*pc)
      \n = n
      ReDim \points(\n - 1)
      
      For i = 0 To \n - 1
        \points(i)\x = (Random(#MAX_INTEGER) * (maxX - minX)) / #MAX_INTEGER + minX
        \points(i)\y = (Random(#MAX_INTEGER) * (maxY - minY)) / #MAX_INTEGER + minY
      Next
    EndWith
  EndProcedure
  
  Procedure DrawPoints(*main.Window)
    Protected i.i
    
    With *main\pc
      If StartDrawing(CanvasOutput(*main\canvasId))
        DrawingMode(#PB_2DDrawing_Default)
        
        Box(0, 0, GadgetWidth(*main\canvasId), GadgetHeight(*main\canvasId), $ffffff)
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Protected cc.Triangulation::CircumCircle, color.i
        color = $cfcfff
        ForEach \triangles()
          Triangulation::getCircumCircle(\triangles()\p[0], \triangles()\p[1], \triangles()\p[2], @cc)
          If (Triangulation::isTriangleDelaunay(@\triangles()))
            color = $cfffcf
          Else
            color = $cfcfff
          EndIf
          Circle(cc\center\x, cc\center\y, cc\radius, color)
        Next
        
        ForEach \edges()
          CompilerIf #BUG
            Protected.Triangulation::Point2D *p0, *p1
            *p0 = \edges()\p[0]
            *p1 = \edges()\p[1]
            LineXY(*p0\x, *p0\y, *p1\x, *p1\y, $7f7f7f)
          CompilerElse
            LineXY(\edges()\p[0]\x, \edges()\p[0]\y, \edges()\p[1]\x, \edges()\p[1]\y, $7f7f7f)
          CompilerEndIf
        Next
        
        DrawingMode(#PB_2DDrawing_Transparent)
        For i = 0 To \n - 1
          Circle(\points(i)\x, \points(i)\y, 1, $000000)
          ;Plot(\points(i)\x, \points(i)\y, $000000)
        Next
        
        Protected ConvexHullSize.i = ListSize(\convexHull())
        If (ConvexHullSize > 2)
          Protected *last.Triangulation::ConvexHullPoint2D = 0
          LastElement(\convexHull())
          *last = @\convexHull()
          
          i = 0
          ForEach \convexHull()
            LineXY(*last\p\x, *last\p\y, \convexHull()\p\x, \convexHull()\p\y, $0000ff)
            DrawText((*last\p\x + \convexHull()\p\x) / 2, (*last\p\y + \convexHull()\p\y) / 2, Str(i), 0)
            i + 1
            *last =  @\convexHull()
          Next
        EndIf
        
        DrawingMode(#PB_2DDrawing_Default)
        DrawText(0, 0, " Points: " + Str(\n) + "  " +
                       "Edges: " + Str(ListSize(\edges())) + "  " +
                       "Triangles: " + Str(ListSize(\triangles())) + "  " +
                       "Time: " + Str(\time) + " ms ", $0000ff, $ffffff)
        StopDrawing()
      EndIf
    EndWith
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure CanvasEvent()
    Protected x.i, y.i, gadgetId.i, *main.Window, seed.i
    
    gadgetId = EventGadget()
    *main = GetGadgetData(gadgetId)
    
    With *main
      x = GetGadgetAttribute(\canvasId, #PB_Canvas_MouseX)
      y = GetGadgetAttribute(\canvasId, #PB_Canvas_MouseY)
      
      Select (EventType())
        Case #PB_EventType_LeftButtonDown
          \leftDown = #True
          \clicked = Triangulation::getPoint(\pc, x, y)
          
        Case #PB_EventType_RightButtonDown
          \rightDown = #True
          Triangulation::triangulate(\pc, Triangulation::getPoint(\pc, x, y))
          DrawPoints(*main)
          
        Case #PB_EventType_MouseMove
          If (\leftDown)
            Triangulation::setPoint(\pc, \clicked, x, y)
          EndIf
          If (\rightDown)
            If (\clicked >= 0)
              seed = \clicked
            Else
              seed = Triangulation::getPoint(\pc, x, y)
            EndIf
            Triangulation::triangulate(\pc, seed)
          EndIf
          DrawPoints(*main)
          
        Case #PB_EventType_LeftButtonUp
          \leftDown = #False
          \clicked = -1
          
        Case #PB_EventType_RightButtonUp
          \rightDown = #False
          \clicked = -1
      EndSelect
    EndWith
  EndProcedure
  
  Procedure CreateMainWindow(*main.Window)
    With *main
      \id = OpenWindow(#PB_Any, 0, 0, \width, \height, \title, #PB_Window_MinimizeGadget | #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
      If (Not \id) : ProcedureReturn #False : EndIf
      
      \canvasId = CanvasGadget(#PB_Any, 0, 0, \width, \height)
      \clicked = -1
      SetGadgetData(\canvasId, *main)
      If (Not \canvasId)
        CloseWindow(\id)
        ProcedureReturn #False
      EndIf
      
      BindGadgetEvent(\canvasId, @CanvasEvent())
      
      ProcedureReturn \id
    EndWith
  EndProcedure
  
  Define.Triangulation::Triangulation pc
  
  CreateRandomizedPointCloud(@pc, 10, 0, 0, #WIDTH - 1, #HEIGHT - 1)
  
  Define.Window main
  main\width = #WIDTH
  main\height = #HEIGHT
  main\title = "Triangulation Test"
  main\pc = @pc
  
  CreateMainWindow(@main)
  
  DrawPoints(@main)
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
CompilerEndIf
