;   Description: A module with functions for sets
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=12&t=45787
;  French-Forum: 
;  German-Forum: 
;-----------------------------------------------------------------------------

; Version 1.75, 2018-12-27
; Purebasic 5.20 LTS or newer is required because of the module.
; Cross-platform, x86 and x64, Unicode compliant.

; The sets are implemented using PureBasic's maps. Like a map, a set is a
; collection with no duplicate elements, in which order has no significance
; (see e.g. <https://en.wikipedia.org/wiki/Set_(mathematics)>).
; The elements of the sets are strings, represented by the *keys* of the
; maps. The values of the map elements are ignored.
; A partition of a set 's' is a collection of non-empty disjoint subsets
; of 's' (blocks) whose union is 's'
; (see e.g. <https://en.wikipedia.org/wiki/Partition_of_a_set>).

; The data types used here are the structures 'Set' and 'Partition'.
; You can use the fields 'Label$' and 'Value' in both structures for your
; own purposes. Depending on your program, 'Value' could mean e.g. cost
; or weight or could be an ordinal number used for sorting the sets or
; partitions.
; If you want, you can add more fields to the structures for your needs.
; They will just be ignored by the routines of this module.

; ------------------------------------------------------------------------------
; MIT License
;
; Copyright (c) 2011, 2013, 2015, 2017-2018 Jürgen Lüthje <http://luethje.eu/>
; Copyright (c) 2015 for assembler code in procedure _Choose() Wilbert
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
; ------------------------------------------------------------------------------


DeclareModule Set
   EnableExplicit
   
   Structure Set
      Map Element.i()      ; * read only *
      NumElements.i        ; * read only *
      Label$
      Value.i
   EndStructure
   
   Structure Partition
      List Block.Set()     ; * read only *
      NumBlocks.i          ; * read only *
      Label$
      Value.i
   EndStructure
   
   #DontSort = -1
   
   ; for procedure NumberOf_PartitionsT()
   #All      = 1
   #SameSize = 2
   
   Macro Size (_set_)
      ; return the number of elements in _set_
      MapSize(_set_\Element())
   EndMacro
   
   Macro Clear (_set_)
      ClearMap(_set_\Element())
      _set_\NumElements = 0
      _set_\Label$ = ""
      _set_\Value = 0
   EndMacro
   
   Macro Copy (_source_, _dest_)
      ; copy set _source_ to _dest_
      CopyStructure(_source_, _dest_, Set::Set)
   EndMacro
   
   Macro AddElement (_set_, _x_, _caseSensitive_=#True)
      ; add element _x_ to _set_, if it is not there already
      If _caseSensitive_ = #True
         AddMapElement(_set_\Element(), _x_)
      Else
         AddMapElement(_set_\Element(), LCase(_x_))
      EndIf
      _set_\NumElements = Set::Size(_set_)
   EndMacro
   
   Macro RemoveElement (_set_, _x_, _caseSensitive_=#True)
      ; remove element _x_ from _set_, if it is there
      If _caseSensitive_ = #True
         DeleteMapElement(_set_\Element(), _x_)
      Else
         DeleteMapElement(_set_\Element(), LCase(_x_))
      EndIf
      _set_\NumElements = Set::Size(_set_)
   EndMacro
   
   Macro PartitionSize (_p_)
      ; return the number of blocks in _p_
      ListSize(_p_\Block())
   EndMacro
   
   Macro ClearPartition (_p_)
      ClearList(_p_\Block())
      _p_\NumBlocks = 0
      _p_\Label$ = ""
      _p_\Value = 0
   EndMacro
   
   ; -- data conversion to set or partition
   Declare.i FromString (source$, *result.Set, caseSensitive.i=#True, sepElm$=",", brackets$="{}")
   Declare.i FromList (List source$(), *result.Set, caseSensitive.i=#True)
   Declare.i FromArrayI (Array source.i(1), *result.Set, start.i=0, last.i=-1)
   Declare.i FromArrayS (Array source$(1), *result.Set, caseSensitive.i=#True, start.i=0, last.i=-1)
   Declare.i PartitionFromString (part$, *p.Partition, caseSensitive.i=#True, sepElm$=",", sepBlock$="} {")
   Declare.i FromPartition (*p.Partition, *result.Set)
   
   ; -- data conversion from set or partition
   Declare.i ToList (*a.Set, List result$(), sortByContent.i=#PB_Sort_Ascending)
   Declare.s ToString (*a.Set, sortByContent.i=#PB_Sort_Ascending, sepElm$=",", brackets$="{}")
   Declare.i PartitionToStringList (*p.Partition, List result$(), sortByContent.i=#PB_Sort_Ascending, sortBlocksBySize.i=#PB_Sort_Descending, sepElm$=",")
   Declare.s PartitionToString (*p.Partition, sortByContent.i=#PB_Sort_Ascending, sortBlocksBySize.i=#PB_Sort_Descending, sepElm$=",", sepBlock$="} {")
   
   ; -- save / load
   Declare.i Save (*a.Set, file$, flag.i=0)
   Declare.i Load (*a.Set, file$)
   
   ; -- basic operations
   Declare.i Union (*a.Set, *b.Set, *result.Set=#Null)
   Declare.i Intersection (*a.Set, *b.Set, *result.Set=#Null)
   Declare.i Difference (*a.Set, *b.Set, *result.Set=#Null)
   Declare.i SymmetricDifference (*a.Set, *b.Set, *result.Set=#Null)
   Declare.i CrossPartition (*a.Partition, *b.Partition, *result.Partition=#Null)
   
   ; -- check membership etc.
   Declare.i IsElement (*a.Set, x$, caseSensitive.i=#True)
   Declare.i IsSubset (*super.Set, *sub.Set)
   Declare.i IsProperSubset (*super.Set, *sub.Set)
   Declare.i IsEqual (*a.Set, *b.Set)
   Declare.d Similar (*a.Set, *b.Set)
   Declare.i CheckPartition (*p.Partition, *s.Set=#Null)
   Declare.i IsEqualPartition (*a.Partition, *b.Partition, ordered.i=#False)
   
   ; -- calculate basic numbers
   Declare.q NumberOf_Subsets  (n.l)
   Declare.q NumberOf_SubsetsK (n.l, k.l)
   Declare.q NumberOf_Partitions  (n.l, ordered.i=#False)
   Declare.q NumberOf_PartitionsK (n.l, k.l, ordered.i=#False)
   Declare.q NumberOf_PartitionsT (type$, ordered.i=#False)
   
   ; -- generate subsets of a given set
   Declare.i FirstSubset  (*s.Set, *sub.Set)
   Declare.i NextSubset   (*s.Set, *sub.Set)
   Declare.i FirstSubsetK (*s.Set, *sub.Set, k.l)
   Declare.i NextSubsetK  (*s.Set, *sub.Set)
   
   ; -- generate unordered partitions of a given set
   Declare.i FirstPartition  (*s.Set, *p.Partition)
   Declare.i NextPartition   (*s.Set, *p.Partition)
   Declare.i FirstPartitionK (*s.Set, *p.Partition, k.l)
   Declare.i NextPartitionK  (*s.Set, *p.Partition)
   Declare.i FirstPartitionT (*s.Set, *p.Partition, type$)
   Declare.i NextPartitionT  (*s.Set, *p.Partition)
EndDeclareModule


Module Set
   ;-===================================================================
   ; -- private fast custom sort
   
   Macro _Merge (_listA_, _listB_, _listResult_)
      ; -- merge two sorted linked lists
      ; in : _listA_, _listB_: partial lists which are already sorted (both lists are not empty)
      ;      _listResult_    : empty list
      ; out: _listResult_    : sorted list that contains all elements of _listA_ and _listB_
      
      ; -- merge both partial lists
      posnA = 0
      lastA = ListSize(_listA_) - 1
      MergeLists(_listA_, _listResult_)        ; Move _listA_ to _listResult_.
      LastElement(_listResult_)                ; Otherwise _listResult_ won't have a current element after MergeLists()!
      MergeLists(_listB_, _listResult_)        ; Append _listB_ to the end of _listResult_.
      
      *curB = NextElement(_listResult_)
      *curA = FirstElement(_listResult_)
      *successor = *curA
      
      ; -- rearrange the elements in the resulting list
      While posnA <= lastA And *curB <> #Null
         If IsInWrongOrder(*curA, *curB, SortMode) > 0
            ChangeCurrentElement(_listResult_, *curB)
            *nxtB = NextElement(_listResult_)
            ChangeCurrentElement(_listResult_, *curB)
            MoveElement(_listResult_, #PB_List_Before, *successor)
            *successor = NextElement(_listResult_)
            *curB = *nxtB
         Else
            ChangeCurrentElement(_listResult_, *curA)
            *successor = NextElement(_listResult_)
            *curA = *successor
            posnA + 1
         EndIf
      Wend
   EndMacro
   
   
   Macro _InsertionSort (_list_)
      FirstElement(_list_)
      While NextElement(_list_) <> #Null
         *curElement = @ _list_                     ; save pointer to current element
         *successor = *curElement
         *lastSortedElement = PreviousElement(_list_)
         *prevElement = *lastSortedElement
         While *prevElement <> #Null And IsInWrongOrder(*prevElement, *curElement, SortMode) > 0
            *successor = *prevElement
            *prevElement = PreviousElement(_list_)
         Wend
         
         ChangeCurrentElement(_list_, *curElement)
         If *successor <> *curElement
            MoveElement(_list_, #PB_List_Before, *successor)
            ChangeCurrentElement(_list_, *lastSortedElement)
         EndIf
      Wend
   EndMacro
   
   
   Macro _SortRange (_list_)
      ; -- select the part of the list that needs to be sorted
      If first = 0
         If last = -1 Or last = ListSize(_list_) - 1
            ; -- Sort all elements
            _SortS(_list_)
         ElseIf 0 < last And last < ListSize(_list_) - 1
            ; -- Sort leading part of the list
            SelectElement(_list_, last)
            SplitList (_list_, t(), #True)         ; Move the trailing part of _list_ to t().
            _SortS(_list_)                         ; Sort rest of _list_.
            MergeLists(t(), _list_)                ; Move the saved trailing part back to _list_.
         EndIf
         
      ElseIf 0 < first And first < ListSize(_list_) - 1
         If last = -1 Or last = ListSize(_list_) - 1
            ; -- Sort trailing part of the list
            SelectElement(_list_, first)
            SplitList (_list_, t())                ; Move the trailing part of _list_ to t().
            _SortS(t())                            ; Sort t().
            MergeLists(t(), _list_)                ; Move the sorted trailing part back to _list_.
         ElseIf 0 < last And last < ListSize(_list_) - 1
            ; -- Sort middle part of the list
            SelectElement(_list_, last)
            SplitList (_list_, t(), #True)         ; Move the trailing part of _list_ to t().
            SelectElement(_list_, first)
            SplitList (_list_, m())                ; Move the middle part of _list_ to m().
            _SortS(m())                            ; Sort m().
            MergeLists(m(), _list_)                ; Move the sorted middle part back to _list_.
            MergeLists(t(), _list_)                ; Move the saved trailing part back to _list_.
         EndIf
      EndIf
   EndMacro
   
   
   Prototype.i ProtoCompare (*a, *b, mode.i)
   Define IsInWrongOrder.ProtoCompare
   Define SortMode.i
   Define sInsertionSortMaxSize = 50
   
   Procedure _SortS (List x.s())
      Shared IsInWrongOrder, SortMode, sInsertionSortMaxSize
      Protected *successor
      Protected *curA, *curB, *nxtB, posnA, lastA              ; for _Merge()
      Protected *curElement, *lastSortedElement, *prevElement  ; for _InsertionSort()
      Protected NewList a.s()
      Protected NewList b.s()
      
      If ListSize(x()) <= 1
         ProcedureReturn
      EndIf
      
      If ListSize(x()) > sInsertionSortMaxSize
         SelectElement(x(), Int(ListSize(x())/2))
         SplitList (x(), b())           ; Move the second half of x() to b().
         MergeLists(x(), a())           ; Move the remaining first half of x() to a().
         
         _SortS(a())
         _SortS(b())
         _Merge(a(), b(), x())
         
      Else
         _InsertionSort(x())
      EndIf
   EndProcedure
   
   Procedure _CustomSortListS (List x.s(), *Compare, mode.i=0, first.i=0, last.i=-1)
      ; -- Main custom sort procedure:
      ;    Sort list x() according to the given comparison function
      ; in : x()     : List of strings to be sorted
      ;      *Compare: address of a custom comparison function of type 'ProtoCompare'
      ;      mode    : This value is just passed to the custom comparison function.
      ;      first   : index of first element to sort  (default: sort ... )
      ;      last    : index of last  element to sort  (... the whole list)
      ; out: x()     : sorted list
      Shared IsInWrongOrder, SortMode
      Protected NewList m.s()
      Protected NewList t.s()
      
      IsInWrongOrder = *Compare
      SortMode = mode
      _SortRange(x())
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   Macro _IsDigit (_char_)
      Bool('0' <= _char_ And _char_ <= '9')
   EndMacro
   
   Macro _ReturnResult (_a_, _b_)
      If (mode & #PB_Sort_Descending)
         ProcedureReturn Bool(_a_ < _b_)
      Else
         ProcedureReturn Bool(_a_ > _b_)
      EndIf
   EndMacro
   
   Procedure.i _CompareNatural (*a.String, *b.String, mode.i)
      ; -- _simple_ "natural" comparison
      ; in : *a, *b: pointers to strings to be compared
      ;      mode  : mode of comparison:
      ;              #PB_Sort_Ascending/#PB_Sort_Descending/#PB_Sort_NoCase
      ; out: return value: #True/#False
      Protected.i firstCharA, firstCharB, va, vb
      
      firstCharA = Asc(*a\s)
      firstCharB = Asc(*b\s)
      
      If _IsDigit(firstCharA) And _IsDigit(firstCharB)
         va = Val(*a\s)
         vb = Val(*b\s)
         If va <> vb
            _ReturnResult(va, vb)
         Else
            ; Different strings can represent the same number (as e.g. with "2" and "2.0").
            _ReturnResult(*a\s, *b\s)
         EndIf
      ElseIf (mode & #PB_Sort_NoCase)
         _ReturnResult(UCase(*a\s), UCase(*b\s))
      Else
         _ReturnResult(*a\s, *b\s)
      EndIf
   EndProcedure
   
   ;-===================================================================
   
   ; Since the public macro AddElement() has a higher priority than
   ; the built-in PB function AddElement(), the built-in function
   ; can't be used directly inside this module. The following private
   ; macro _AddListElement() does the same as the built-in function
   ; AddElement(), but works inside this module.
   Macro _AddListElement (_list_, PB_AddElement=AddElement)
      PB_AddElement(_list_)
   EndMacro
   
   ;--------------------------------------------------------------------
   
   Procedure.i FromString (source$, *result.Set, caseSensitive.i=#True, sepElm$=",", brackets$="{}")
      ; -- create a set from a string (skip duplicate elements)
      ; in : source$      : string that contains the elements
      ;      *result      : pointer to set which is to be created
      ;      caseSensitive: #True / #False
      ;      sepElm$      : string used for separating the elements (can be ""
      ;                     if each element is represented by 1 character)
      ;      brackets$    : two characters that might enclose the input string,
      ;                     and which will be stripped off
      ; out: *result     : pointer to generated set
      ;      return value: 1: success
      ;                    0: error
      ;                   -1: warning: There are one or more duplicate elements in 'source$'.
      Protected.i i, nElements, ret=1
      Protected element$
      
      If *result = #Null
         ProcedureReturn 0                 ; error
      EndIf
      
      If FindString(brackets$, Left(source$,1)) = 1 And FindString(brackets$, Right(source$,1)) = 2
         source$ = Mid(source$, 2, Len(source$)-2)
      EndIf
      
      Clear(*result)
      source$ = Trim(source$)
      If source$ = ""                      ; empty set
         ProcedureReturn 1                 ; is valid
      EndIf
      
      If sepElm$ = ""
         nElements = Len(source$)
         For i = 1 To nElements
            AddElement(*result, Mid(source$, i, 1), caseSensitive)
         Next
      Else
         nElements = CountString(source$, sepElm$) + 1
         For i = 1 To nElements
            element$ = Trim(StringField(source$, i, sepElm$))
            If element$ = ""
               ProcedureReturn 0           ; error
            EndIf
            AddElement(*result, element$, caseSensitive)
         Next
      EndIf
      
      If *result\NumElements <> nElements
         ret = -1                          ; warning
      EndIf
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.i FromList (List source$(), *result.Set, caseSensitive.i=#True)
      ; -- create a set from a list of strings (skip duplicate elements)
      ; in : source$()    : List that contains the elements
      ;      *result      : pointer to set which is to be created
      ;      caseSensitive: #True / #False
      ; out: *result     : pointer to generated set
      ;      return value: 1: success
      ;                    0: error
      ;                   -1: warning: There are one or more duplicate elements in 'source$()'.
      Protected ret.i=1
      
      If *result = #Null
         ProcedureReturn 0                           ; error
      EndIf
      
      Clear(*result)
      ForEach source$()
         AddElement(*result, Trim(source$()), caseSensitive)
      Next
      
      If *result\NumElements <> ListSize(source$())
         ret = -1                                    ; warning
      EndIf
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.i FromArrayI (Array source.i(1), *result.Set, start.i=0, last.i=-1)
      ; -- create a set from an integer array (skip duplicate elements)
      ; in : source(): array that contains the elements
      ;      *result : pointer to set which is to be created
      ;      start   : index of the first array element to use
      ;      last    : index of the last  array element to use
      ; out: *result     : pointer to generated set
      ;      return value: 1: success
      ;                    0: error
      ;                   -1: warning: There are one or more duplicate elements in 'source()'.
      Protected.i i, ret=1
      
      If *result = #Null Or start < 0
         ProcedureReturn 0                        ; error
      EndIf
      
      Clear(*result)
      If last = -1
         last = ArraySize(source())
      ElseIf last > ArraySize(source())
         ProcedureReturn 0                        ; error
      EndIf
      
      For i = start To last
         AddMapElement(*result\Element(), Str(source(i)))
      Next
      
      *result\NumElements = Size(*result)
      If *result\NumElements <> last - start + 1
         ret = -1                                 ; warning
      EndIf
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.i FromArrayS (Array source$(1), *result.Set, caseSensitive.i=#True, start.i=0, last.i=-1)
      ; -- create a set from a string array (skip duplicate elements)
      ; in : source$()    : array that contains the elements
      ;      *result      : pointer to set which is to be created
      ;      caseSensitive: #True / #False
      ;      start        : index of the first array element to use
      ;      last         : index of the last  array element to use
      ; out: *result     : pointer to generated set
      ;      return value: 1: success
      ;                    0: error
      ;                   -1: warning: There are one or more duplicate elements in 'source$()'.
      Protected.i i, ret=1
      
      If *result = #Null Or start < 0
         ProcedureReturn 0                        ; error
      EndIf
      
      Clear(*result)
      If last = -1
         last = ArraySize(source$())
      ElseIf last > ArraySize(source$())
         ProcedureReturn 0                        ; error
      EndIf
      
      For i = start To last
         AddElement(*result, Trim(source$(i)), caseSensitive)
      Next
      
      If *result\NumElements <> last - start + 1
         ret = -1                                 ; warning
      EndIf
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.i PartitionFromString (part$, *p.Partition, caseSensitive.i=#True, sepElm$=",", sepBlock$="} {")
      ; -- convert an appropriate string to a set partition
      ; in : part$        : string that represents a set partition
      ;      *p           : pointer to set partition which is to be created
      ;      caseSensitive: #True / #False
      ;      sepElm$      : string used for separating the elements (can be ""
      ;                     if each element is represented by 1 character)
      ;      sepBlock$    : string used for separating the blocks ("" -> error)
      ; out: *p           : pointer to generated set partition
      ;      return value: 1: success
      ;                    0: error
      ;                   -1: warning: There are duplicate elements at least in one block of 'part$'.
      Protected.i i, nBlocks, fs, ret, totalElements=0
      Protected block$, u.Set
      
      If *p = #Null Or sepBlock$ = ""
         ProcedureReturn 0                                      ; error
      EndIf
      
      ClearPartition(*p)
      
      If Trim(part$) = ""
         ProcedureReturn 1                                      ; an empty partition is valid
      EndIf
      
      If Len(sepBlock$) > 1
         part$ = LTrim(RTrim(part$, Left(sepBlock$,1)), Right(sepBlock$,1))
      EndIf
      
      nBlocks = CountString(part$, sepBlock$) + 1
      ret = 1
      
      For i = 1 To nBlocks
         block$ = Trim(StringField(part$, i, sepBlock$))
         If block$ = ""
            ProcedureReturn 0                                   ; error: empty blocks are not allowed
         EndIf
         
         _AddListElement(*p\Block())
         fs = FromString(block$, *p\Block(), caseSensitive, sepElm$)
         If fs = 0
            DeleteElement(*p\Block())
            ProcedureReturn 0                                   ; error
         ElseIf fs = -1
            ret = -1                                            ; warning
         EndIf
         
         totalElements + Size(*p\Block())
         If Union(u, *p\Block(), u) <> totalElements
            ProcedureReturn 0                                   ; error: 'part$' is not a set partition
         EndIf
      Next
      
      *p\NumBlocks = nBlocks
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.i FromPartition (*p.Partition, *result.Set)
      ; -- create a set from one of its partitions
      ; in : *p     : pointer to an existing set partition
      ;      *result: pointer to the set which is to be created
      ; out: *result     : pointer to generated set
      ;      return value: 1: success
      ;                    0: error
      Protected totalElements.i=0
      
      If *p = #Null Or *result = #Null
         ProcedureReturn 0              ; error
      EndIf
      
      Clear(*result)
      ForEach *p\Block()
         totalElements + Size(*p\Block())
         If Size(*p\Block()) = 0 Or Union(*result, *p\Block(), *result) <> totalElements
            ProcedureReturn 0           ; error: 'p' is not a set partition
         EndIf
      Next
      
      *result\Label$ = *p\Label$
      
      ProcedureReturn 1              ; success
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   Procedure.i ToList (*a.Set, List result$(), sortByContent.i=#PB_Sort_Ascending)
      ; -- convert a set to a list of strings
      ; in : *a           : pointer to a set
      ;      sortByContent: sort the elements in the created list by content
      ;                     (#PB_Sort_Ascending, #PB_Sort_Descending, or #DontSort),
      ;                     using the module's private custom sort procedure
      ; out: result$()   : list of the elements of the set
      ;      return value: 1: success
      ;                    0: error
      
      If *a = #Null
         ProcedureReturn 0                             ; error
      EndIf
      
      ClearList(result$())
      ForEach *a\Element()
         _AddListElement(result$())
         result$() = MapKey(*a\Element())
      Next
      
      If sortByContent = #PB_Sort_Ascending Or sortByContent = #PB_Sort_Descending
         _CustomSortListS(result$(), @ _CompareNatural(), sortByContent)
      EndIf
      
      ProcedureReturn 1                                ; success
   EndProcedure
   
   Procedure.s ToString (*a.Set, sortByContent.i=#PB_Sort_Ascending, sepElm$=",", brackets$="{}")
      ; -- convert a set to a string
      ; in : *a           : pointer to set which is to be converted
      ;      sortByContent: sort the elements in the created string by content
      ;                     (#PB_Sort_Ascending, #PB_Sort_Descending, or #DontSort),
      ;                     using the module's private custom sort procedure
      ;      sepElm$      : string used for separating the elements (can be ""
      ;                     if each element is represented by 1 character)
      ;      brackets$    : two characters that will enclose the generated string
      ; out: return value: string that contains the elements of the set,
      ;                    "" on error
      Protected ret$=""
      Protected NewList result$()
      
      If *a = #Null
         ProcedureReturn ""                            ; error
      EndIf
      
      If sortByContent = #PB_Sort_Ascending Or sortByContent = #PB_Sort_Descending
         ToList(*a, result$(), sortByContent)
         ForEach result$()
            ret$ + sepElm$ + result$()
         Next
      Else
         ForEach *a\Element()
            ret$ + sepElm$ + MapKey(*a\Element())
         Next
      EndIf
      
      ProcedureReturn Left(brackets$,1) + Mid(ret$, Len(sepElm$)+1) + Right(brackets$,1)
   EndProcedure
   
   Procedure.i PartitionToStringList (*p.Partition, List result$(), sortByContent.i=#PB_Sort_Ascending, sortBlocksBySize.i=#PB_Sort_Descending, sepElm$=",")
      ; -- convert a set partition to a list of strings
      ; in : *p              : pointer to a set partition
      ;      sortByContent   : sort the elements and the blocks in the created list by content
      ;                        (#PB_Sort_Ascending, #PB_Sort_Descending, or #DontSort),
      ;                        using the module's private custom sort procedure
      ;      sortBlocksBySize: sort the blocks in the created list by their number of elements
      ;                        (#PB_Sort_Ascending, #PB_Sort_Descending, or #DontSort)
      ;      sepElm$         : string used for separating the elements (can be ""
      ;                        if each element is represented by 1 character)
      ; out: result$()   : list of blocks of which the given set partition consists
      ;      return value: 1: success
      ;                    0: error
      Protected curSize, blockSize, first, last, *curElement
      
      If *p = #Null
         ProcedureReturn 0                             ; error
      EndIf
      
      ClearList(result$())
      If PartitionSize(*p) = 0
         ProcedureReturn 1                             ; success
      EndIf
      
      If sortBlocksBySize = #PB_Sort_Ascending Or sortBlocksBySize = #PB_Sort_Descending
         SortStructuredList(*p\Block(), sortBlocksBySize, OffsetOf(Set\NumElements), TypeOf(Set\NumElements))
      EndIf
      
      ForEach *p\Block()
         _AddListElement(result$())
         result$() = ToString(*p\Block(), sortByContent, sepElm$, "")
      Next
      
      If sortByContent = #PB_Sort_Ascending Or sortByContent = #PB_Sort_Descending
         If sortBlocksBySize = #PB_Sort_Ascending Or sortBlocksBySize = #PB_Sort_Descending
            ; -- Sort blocks of the same size by content.
            FirstElement(result$())
            If sepElm$ <> ""
               blockSize = CountString(result$(), sepElm$) + 1
            Else
               blockSize = Len(result$())
            EndIf
            first = 0
            last = first
            
            While NextElement(result$())
               If sepElm$ <> ""
                  curSize = CountString(result$(), sepElm$) + 1
               Else
                  curSize = Len(result$())
               EndIf
               
               If blockSize = curSize
                  last + 1
               ElseIf first < last
                  *curElement = @ result$()
                  _CustomSortListS(result$(), @ _CompareNatural(), sortByContent, first, last)
                  ChangeCurrentElement(result$(), *curElement)
                  blockSize = curSize
                  first = last + 1
                  last = first
               Else
                  blockSize = curSize
                  first + 1
                  last = first
               EndIf
            Wend
            
            If first < last
               _CustomSortListS(result$(), @ _CompareNatural(), sortByContent, first, last)
            EndIf
            
         Else
            _CustomSortListS(result$(), @ _CompareNatural(), sortByContent)
         EndIf
      EndIf
      
      ProcedureReturn 1                                ; success
   EndProcedure
   
   Procedure.s PartitionToString (*p.Partition, sortByContent.i=#PB_Sort_Ascending, sortBlocksBySize.i=#PB_Sort_Descending, sepElm$=",", sepBlock$="} {")
      ; -- convert a set partition to a string
      ; in : *p              : pointer to set partition which is to be converted
      ;      sortByContent   : sort the elements and the blocks in the created string by content
      ;                        (#PB_Sort_Ascending, #PB_Sort_Descending, or #DontSort),
      ;                        using the module's private custom sort procedure
      ;      sortBlocksBySize: sort the blocks in the created string by their number of elements
      ;                        (#PB_Sort_Ascending, #PB_Sort_Descending, or #DontSort)
      ;      sepElm$         : string used for separating the elements (can be ""
      ;                        if each element is represented by 1 character)
      ;      sepBlock$       : string used for separating the blocks ("" -> error)
      ; out: return value: string that contains the blocks of the set partition,
      ;                    "" on error
      Protected sepBlockLen.i=Len(sepBlock$), ret$=""
      Protected NewList result$()
      
      If *p = #Null Or sepBlockLen = 0
         ProcedureReturn ""                                       ; error
      EndIf
      
      If (sortByContent = #PB_Sort_Ascending Or sortByContent = #PB_Sort_Descending)  Or
         (sortBlocksBySize = #PB_Sort_Ascending Or sortBlocksBySize = #PB_Sort_Descending)
         PartitionToStringList(*p, result$(), sortByContent, sortBlocksBySize, sepElm$)
         ForEach result$()
            ret$ + sepBlock$ + result$()
         Next
      Else
         ForEach *p\Block()
            ret$ + sepBlock$ + ToString(*p\Block(), #DontSort, sepElm$, "")
         Next
      EndIf
      
      ret$ = Mid(ret$, sepBlockLen + 1)
      If ret$ <> "" And Len(sepBlock$) > 1
         ret$ = Right(sepBlock$,1) + ret$ + Left(sepBlock$,1)
      EndIf
      
      ProcedureReturn ret$
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   #SetExtension$ = ".set"
   
   Procedure.i Save (*a.Set, file$, flag.i=0)
      ; -- save a set to a JSON file (UTF-8 without BOM)
      ; in : *a   : pointer to set which is to be saved
      ;      file$: file name
      ;      flag : 0 or #PB_JSON_PrettyPrint
      ; out: return value: 1: success
      ;                    0: error
      Protected.i jn, ret=0
      
      If file$ <> "" And GetExtensionPart(file$) = ""
         file$ + #SetExtension$
      EndIf
      
      jn = CreateJSON(#PB_Any)
      If jn
         InsertJSONStructure(JSONValue(jn), *a, Set)
         If SaveJSON(jn, file$, flag)
            ret = 1
         EndIf
         FreeJSON(jn)
      EndIf
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.i Load (*a.Set, file$)
      ; -- load a set from an appropriate JSON file
      ; in : *a   : pointer to set which is to be loaded
      ;      file$: file name
      ; out: *a          : pointer to loaded set
      ;      return value: 1: success
      ;                    0: error
      Protected.i jn, ret=0
      
      If file$ <> "" And GetExtensionPart(file$) = ""
         file$ + #SetExtension$
      EndIf
      
      jn = LoadJSON(#PB_Any, file$)
      If jn
         ExtractJSONStructure(JSONValue(jn), *a, Set)
         FreeJSON(jn)
         ret = 1
      EndIf
      
      ProcedureReturn ret
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   Procedure.i Union (*a.Set, *b.Set, *result.Set=#Null)
      ; -- get all elements that are in 'a' OR 'b'
      ; in : *a, *b : pointers to sets
      ;      *result: pointer to resulting set (optional);
      ;               *result can be equal to *a. This is
      ;               especially useful for getting the
      ;               union of multiple sets in a loop
      ;               (see e.g. usage in procedures
      ;               PartitionFromString() and CheckPartition()).
      ; out: *result     : pointer to generated set (optional)
      ;      return value: number of elements in resulting union
      Protected nElements.i=Size(*a)
      
      If *result <> #Null
         If *result <> *a
            Copy(*a, *result)
            *result\Label$ = ""
            *result\Value = 0
         EndIf
         ForEach *b\Element()
            If FindMapElement(*a\Element(), MapKey(*b\Element())) = 0
               nElements + 1
               AddMapElement(*result\Element(), MapKey(*b\Element()), #PB_Map_NoElementCheck)
            EndIf
         Next
         *result\NumElements = nElements
      Else
         ForEach *b\Element()
            If FindMapElement(*a\Element(), MapKey(*b\Element())) = 0
               nElements + 1
            EndIf
         Next
      EndIf
      
      ProcedureReturn nElements
   EndProcedure
   
   Procedure.i Intersection (*a.Set, *b.Set, *result.Set=#Null)
      ; -- get all elements that are in both 'a' AND 'b'
      ; in : *a, *b : pointers to sets
      ;      *result: pointer to resulting set (optional);
      ;               *result can be equal to *a. This is
      ;               especially useful for getting the
      ;               intersection of multiple sets in a loop.
      ; out: *result     : pointer to generated set (optional)
      ;      return value: number of elements in resulting intersection
      Protected nElements.i=Size(*a)
      
      If *result <> #Null
         If *result <> *a
            Copy(*a, *result)
            *result\Label$ = ""
            *result\Value = 0
         EndIf
         ForEach *result\Element()
            If FindMapElement(*b\Element(), MapKey(*result\Element())) = 0
               nElements - 1
               DeleteMapElement(*result\Element())
            EndIf
         Next
         *result\NumElements = nElements
      Else
         ForEach *a\Element()
            If FindMapElement(*b\Element(), MapKey(*a\Element())) = 0
               nElements - 1
            EndIf
         Next
      EndIf
      
      ProcedureReturn nElements
   EndProcedure
   
   Procedure.i Difference (*a.Set, *b.Set, *result.Set=#Null)
      ; -- get all elements of 'a' that are NOT in 'b' (i.e. 'a'-'b')
      ; in : *a, *b : pointers to sets
      ;      *result: pointer to resulting set (optional);
      ;               *result can be equal to *a. This is
      ;               especially useful for getting the
      ;               difference of multiple sets in a loop.
      ; out: *result     : pointer to generated set (optional)
      ;      return value: number of elements in resulting difference
      Protected nElements.i=Size(*a)
      
      If *result <> #Null
         If *result <> *a
            Copy(*a, *result)
            *result\Label$ = ""
            *result\Value = 0
         EndIf
         ForEach *result\Element()
            If FindMapElement(*b\Element(), MapKey(*result\Element()))
               nElements - 1
               DeleteMapElement(*result\Element())
            EndIf
         Next
         *result\NumElements = nElements
      Else
         ForEach *a\Element()
            If FindMapElement(*b\Element(), MapKey(*a\Element()))
               nElements - 1
            EndIf
         Next
      EndIf
      
      ProcedureReturn nElements
   EndProcedure
   
   Procedure.i SymmetricDifference (*a.Set, *b.Set, *result.Set=#Null)
      ; -- get all elements either in 'a' or 'b' but not in both sets (XOR)
      ; in : *a, *b : pointers to sets
      ;      *result: pointer to resulting set (optional);
      ;               *result can be equal to *a. This is
      ;               especially useful for getting the
      ;               symmetric difference of multiple sets
      ;               in a loop.
      ; out: *result     : pointer to generated set (optional)
      ;      return value: number of elements in resulting symmetric difference
      Protected.Set da, db
      
      Difference(*a, *b, da)
      Difference(*b, *a, db)
      
      ProcedureReturn Union(da, db, *result)
   EndProcedure
   
   Procedure.i CrossPartition (*a.Partition, *b.Partition, *result.Partition=#Null)
      ; -- get the cross-partition of two partitions
      ; in : *a, *b : pointers to partitions of the same set
      ;      *result: pointer to resulting cross-partition (optional);
      ;               *result can be equal to *a (or *b). This
      ;               is especially useful for getting the
      ;               cross-partition of multiple partitions
      ;               in a loop.
      ; out: *result     : pointer to generated cross-partition (optional),
      ;                    which is a valid partition of the same set
      ;      return value: number of blocks in resulting cross-partition,
      ;                    -1 on error
      Protected temp.Set, c.Partition, nBlocks.i=0
      
      If FromPartition(*a, temp) = 0
         ProcedureReturn -1                   ; error: a is no partition at all
      EndIf
      If CheckPartition(*b, temp) = -1
         ProcedureReturn -1                   ; error: b is no partition of temp
      EndIf
      
      If *result <> #Null
         ForEach *a\Block()
            ForEach *b\Block()
               _AddListElement(c\Block())
               If Intersection(*a\Block(), *b\Block(), c\Block()) > 0
                  nBlocks + 1
               Else
                  DeleteElement(c\Block())    ; empty blocks are not allowed
               EndIf
            Next
         Next
         ClearPartition(*result)
         MergeLists(c\Block(), *result\Block())
         *result\NumBlocks = nBlocks
      Else
         ForEach *a\Block()
            ForEach *b\Block()
               If Intersection(*a\Block(), *b\Block()) > 0
                  nBlocks + 1
               EndIf
            Next
         Next
      EndIf
      
      ProcedureReturn nBlocks                 ; success
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   Procedure.i IsElement (*s.Set, x$, caseSensitive.i=#True)
      ; -- return #True if 'x$' is an element of set 's'
      ; in : *s: pointer to a set
      ;      x$: element which is to be checked
      ;      caseSensitive: #True / #False
      ; out: return value : #True / #False
      
      If caseSensitive = #True
         ProcedureReturn Bool(FindMapElement(*s\Element(), x$) <> 0)
      Else
         ProcedureReturn Bool(FindMapElement(*s\Element(), LCase(x$)) <> 0)
      EndIf
   EndProcedure
   
   Procedure.i IsSubset (*super.Set, *sub.Set)
      ; -- return #True if 'sub' is a subset of 'super'
      ; (the empty set is always a valid subset)
      ; in : *super, *sub: pointers to sets
      ; out: return value: #True / #False
      
      If *super = *sub
         ProcedureReturn #True
      EndIf
      
      If Size(*super) < Size(*sub)
         ProcedureReturn #False
      EndIf
      
      ForEach *sub\Element()
         If FindMapElement(*super\Element(), MapKey(*sub\Element())) = 0
            ProcedureReturn #False
         EndIf
      Next
      
      ProcedureReturn #True
   EndProcedure
   
   Procedure.i IsProperSubset (*super.Set, *sub.Set)
      ; -- return #True if 'sub' is a *proper* subset of 'super'
      ; (meaning there is at least one element of super that is not in sub)
      ; in : *super, *sub: pointers to sets
      ; out: return value: #True / #False
      
      If Size(*super) <= Size(*sub)
         ProcedureReturn #False
      Else
         ProcedureReturn IsSubset(*super, *sub)
      EndIf
   EndProcedure
   
   Procedure.i IsEqual (*a.Set, *b.Set)
      ; -- return #True if set 'a' is equal to set 'b'
      ; in : *a, *b      : pointers to sets
      ; out: return value: #True / #False
      
      If *a = *b
         ProcedureReturn #True
      EndIf
      
      If Size(*a) <> Size(*b)
         ProcedureReturn #False
      EndIf
      
      ForEach *b\Element()
         If FindMapElement(*a\Element(), MapKey(*b\Element())) = 0
            ProcedureReturn #False
         EndIf
      Next
      
      ProcedureReturn #True
   EndProcedure
   
   Procedure.d Similar (*a.Set, *b.Set)
      ; -- return the proportion of "a OR b" that is contained in "a AND b"
      ;    (Jaccard index)
      ; in : *a, *b      : pointers to sets
      ; out: return value: Rational number in the closed interval [0.0, 1.0]
      ;                    (0.0 -> both sets are completely different,
      ;                     1.0 -> both sets are equal)
      Protected sizeOfUnion.i
      
      If *a = *b
         ProcedureReturn 1.0
      EndIf
      
      sizeOfUnion = Union(*a, *b)
      
      If sizeOfUnion = 0       ; Two empty sets must be handled separately,
         ProcedureReturn 1.0   ; in order to avoid division by 0.
      Else
         ProcedureReturn Intersection(*a, *b) / sizeOfUnion
      EndIf
   EndProcedure
   
   Procedure.i CheckPartition (*p.Partition, *s.Set=#Null)
      ; -- check whether the list of sets in 'p' is a partition (of set 's')
      ; in : *p: pointer to a possible partition
      ;      *s: - If this is #Null, then the function checks whether 'p'
      ;            meets the general criteria for a partition (i.e.
      ;            whether all sets in 'p' are non-empty and disjoint).
      ;          - If this is a valid pointer to a set, then the function
      ;            checks whether 'p' is a partition of 's'.
      ; out: return value: number of elements in the set of which 'p' is a partition,
      ;                    or -1 if 'p' is no partition (of set 's')
      Protected u.Set, totalElements.i=0
      
      ForEach *p\Block()
         totalElements + Size(*p\Block())
         If Size(*p\Block()) = 0 Or Union(u, *p\Block(), u) <> totalElements
            ProcedureReturn -1
         EndIf
      Next
      
      If (*s = #Null) Or IsEqual(u, *s)
         ProcedureReturn totalElements
      Else
         ProcedureReturn -1
      EndIf
   EndProcedure
   
   Procedure.i IsEqualPartition (*a.Partition, *b.Partition, ordered.i=#False)
      ; -- return #True if partition 'a' is equal to partition 'b'
      ; in : *a, *b : pointers to partitions
      ;      ordered: Are the blocks in both partitions ordered?
      ;               (#True / #False)
      ; out: return value: #True / #False
      Protected i.i
      
      If *a = *b
         ProcedureReturn #True
      EndIf
      
      If PartitionSize(*a) <> PartitionSize(*b)
         ProcedureReturn #False
      EndIf
      
      If ordered = #False
         Protected Dim found.i(PartitionSize(*a))
         
         ForEach *a\Block()
            i = 1
            ForEach *b\Block()
               If found(i) = #False
                  If IsEqual(*a\Block(), *b\Block()) = #True
                     found(i) = #True
                     Break
                  EndIf
               EndIf
               i + 1
            Next
            If i > PartitionSize(*a)   ; if current element of *a\Block() was not found in *b\Block()
               ProcedureReturn #False
            EndIf
         Next
      Else
         FirstElement(*b\Block())
         ForEach *a\Block()
            If IsEqual(*a\Block(), *b\Block()) = #False
               ProcedureReturn #False
            EndIf
            NextElement(*b\Block())
         Next
      EndIf
      
      ProcedureReturn #True
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   Procedure.q _Choose (n.l, k.l)
      ; -- Binomial Coefficient, "n choose k":
      ; Number of combinations or subsets (unordered samples without
      ; repetition) of k elements from a set of n elements.
      ;
      ; / n \        n!
      ; |   |  =  ---------
      ; \ k /     k!*(n-k)!
      ;
      ; in : n: integer from the closed interval [0, 65]
      ;         (For n <= 65, this function returns correct results
      ;          for all allowed values of k.)
      ;      k: integer from the closed interval [0, n]
      ; out: return value: positive integer (not including 0),
      ;                    or -1 on error
      ;
      ; This extremely fast code was written by wilbert (except some
      ; tiny changes by me). Thank you very much!
      Protected result.q, fstc.w
      
      !mov edx, [p.v_n]
      !mov ecx, [p.v_k]
      !cmp ecx, 0
      !jl set.ll__choose_error            ; return -1 if k < 0
      !cmp edx, 65
      !jg set.ll__choose_error            ; return -1 if n > 65
      !sub edx, ecx
      !jc set.ll__choose_error            ; return -1 if n < k
      !cmp ecx, edx
      !cmova ecx, edx
      !and ecx, ecx
      !jz set.ll__choose_return1          ; return 1 if n = k
      !mov [p.v_k], ecx
      !mov edx, ecx
      ; set 80 bit precision
      !fstcw [p.v_fstc]
      !fldcw [set.ll__choose_fstc]
      ; main routine
      !fld1
      !fld1
      !fild dword [p.v_n]
      !set.ll__choose_loop0:
      !fmul st2, st0
      !fsub st0, st1
      !dec ecx
      !jnz set.ll__choose_loop0
      !fstp st0
      !fld1
      !fild dword [p.v_k]
      !set.ll__choose_loop1:
      !fmul st2, st0
      !fsub st0, st1
      !dec edx
      !jnz set.ll__choose_loop1
      !fstp st0
      !fstp st0
      !fdivp
      ; store result
      !fistp qword [p.v_result]
      ; restore fpu control word
      !fldcw [p.v_fstc]
      ProcedureReturn result
      !set.ll__choose_return1:
      ProcedureReturn 1
      !set.ll__choose_error:
      ProcedureReturn -1
      !set.ll__choose_fstc: dw 0x37f
   EndProcedure
   
   Procedure.q NumberOf_Subsets (n.l)
      ; -- return the number of subsets of a set with n elements
      ; in : n: number of elements in the set (0 <= n <= 62)
      ; out: return value: number of all subsets (> 0),
      ;                    -1 on error
      
      If 0 <= n And n <= 62
         ProcedureReturn 1 << n         ; 2^n
      Else
         ProcedureReturn -1             ; Illegal function call
      EndIf
   EndProcedure
   
   Procedure.q NumberOf_SubsetsK (n.l, k.l)
      ; -- return the number of subsets with k elements of a set with n elements
      ; in : n: number of elements in the set     (0 <= n <= 65)
      ;      k: number of elements in the subsets (0 <= k <= n)
      ; out: return value: number of subsets with k elements (> 0),
      ;                    -1 on error
      
      ProcedureReturn _Choose(n, k)
   EndProcedure
   
   ; -----------------------------------------------------
   
   Procedure.q _Factorial (n.i)
      ; -- number of permutations without repetition
      ; in : n: nonnegative integer (including 0);
      ;         For n <= 20, there will be no overflow.
      ; out: return value: positive integer > 0,
      ;                    or -1 on error
      Protected k.i, ret.q=1
      
      If n < 0 Or n > 20
         ProcedureReturn -1       ; error
      EndIf
      
      For k = 2 To n
         ret * k
      Next
      
      ProcedureReturn ret
   EndProcedure
   
   Procedure.q _Stirling2 (n.l, k.l)
      ; -- Stirling number of the second kind:
      ; Number of ways a set of n elements can be partitioned into
      ; k unordered non-empty disjoint subsets (blocks).
      ; in : n: integer from the closed interval [0, 25]
      ;         (For n <= 25, this function works for all values
      ;          of k without producing an overflow.)
      ;      k: integer >= 0
      ; out: return value: nonnegative integer (including 0)
      ;
      ; [after
      ;  Donald E. Knuth:
      ;  TAOCP, Vol. 1 (2012),
      ;  pp. 66-68]
      ;
      ;  see also <https://en.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind>
      ;
      ; Note: A recursive version is *much* slower.
      Protected.i col, r, prevRow=0, row=1
      
      If k = n
         ProcedureReturn 1
      ElseIf k = 0 Or k > n
         ProcedureReturn 0
      EndIf
      
      Protected Dim triangle.q(1, k)
      triangle(prevRow, 1) = 1
      triangle(row, 1) = 1
      
      For r = 2 To k
         Swap prevRow, row
         For col = 2 To r-1
            triangle(row, col) = triangle(prevRow, col-1) + col * triangle(prevRow, col)
         Next
         triangle(row, r) = 1
      Next
      
      For r = k+1 To n
         Swap prevRow, row
         For col = 2 To k
            triangle(row, col) = triangle(prevRow, col-1) + col * triangle(prevRow, col)
         Next
      Next
      
      ProcedureReturn triangle(row, k)
   EndProcedure
   
   ; -----------------------------------------------------
   
   Procedure.q _Bell (n.l)
      ; -- Bell number:
      ;    Number of all unordered partitions of a set with n elements
      ; in : integer from the closed interval [0, 25]
      ;      (For n <= 25, this function does not produce an overflow.)
      ; out: return value: positive integer (not including 0),
      ;                    or -1 on error
      ;
      ; The Bell numbers are generated here by using the "Bell triangle"
      ; (or "Peirce triangle"). This is considerably faster than calculating
      ; the sum of all concerning Stirling2 numbers.
      ;
      ; [after <http://en.wikipedia.org/wiki/Bell_number>, 2015-05-09]
      Protected.i col, r, prevRow=0, row=1
      
      If n < 0 Or n > 25
         ProcedureReturn -1           ; Illegal function call
      EndIf
      
      If n = 0
         ProcedureReturn 1
      EndIf
      
      Protected Dim triangle.q(1, n-1)
      triangle(row, 0) = 1
      
      For r = 1 To n-1
         Swap prevRow, row
         triangle(row, 0) = triangle(prevRow, r-1)
         For col = 1 To r
            triangle(row, col) = triangle(row, col-1) + triangle(prevRow, col-1)
         Next
      Next
      
      ProcedureReturn triangle(row, n-1)
   EndProcedure
   
   Procedure.q _OrderedBell (n.l)
      ; -- Number of all ordered partitions of a set with n elements
      ; in : integer from the closed interval [0, 18]
      ; out: return value: positive integer (not including 0),
      ;                    or -1 on error
      ;
      ; Ordered Bell number (= Fubini number)
      ; -------------------------------------
      ; Suppose there are n people in a race. Assuming no ties, there are n!
      ; possible orders they can ﬁnish in (strict orderings).
      ; If ties are allowed, this is called "weak orderings". _OrderedBell(n)
      ; gives the number of weak orderings on a set with n elements.
      ;
      ; Example: In a race of 3 people where ties are not allowed, there are 3! = 6
      ;          possible resulting rankings:
      ;           1) a < b < c
      ;           2) a < c < b
      ;           3) b < a < c
      ;           4) b < c < a
      ;           5) c < a < b
      ;           6) c < b < a
      ;
      ;          If ties are allowed, there are the following additional possibilities:
      ;           7) a < b = c
      ;           8) b < a = c
      ;           9) c < a = b
      ;          10) a = b < c
      ;          11) a = c < b
      ;          12) b = c < a
      ;          13) a = b = c
      ;
      ;          The number of weak orderings of 3 elements is
      ;          _OrderedBell(3) = 13.
      ;
      ; [see <https://en.wikipedia.org/wiki/Ordered_Bell_number>]
      Protected k.i, ret.q=0
      
      If 0 <= n And n <= 18
         For k = 0 To n
            ret + _Factorial(k) * _Stirling2(n, k)
         Next
         ProcedureReturn ret
      Else
         ProcedureReturn -1           ; error
      EndIf
   EndProcedure
   
   Procedure.q NumberOf_Partitions (n.l, ordered.i=#False)
      ; -- Number of all partitions of a set with n elements
      ; in : n      : number of elements in the set
      ;               - for ordered = #False: 0 <= n <= 25
      ;               - for ordered = #True : 0 <= n <= 18
      ;      ordered: Does the order of the blocks matter? (#True / #False)
      ; out: return value: positive integer (not including 0)
      ;                    - for ordered = #False: Bell number
      ;                    - for ordered = #True : Ordered Bell number
      ;                    - on error: -1
      
      If ordered = #False
         ProcedureReturn _Bell(n)
      Else
         ProcedureReturn _OrderedBell(n)
      EndIf
   EndProcedure
   
   ; -----------------------------------------------------
   
   Procedure.q NumberOf_PartitionsK (n.l, k.l, ordered.i=#False)
      ; -- Number of partitions with k blocks of a set with n elements
      ; in : n      : number of elements in the set
      ;               - for ordered = #False: 0 <= n <= 25
      ;               - for ordered = #True : 0 <= n <= 18
      ;      k      : number of blocks (0 <= k <= n)
      ;      ordered: Does the order of the blocks matter? (#True / #False)
      ; out: return value: nonnegative integer (including 0),
      ;                    or -1 on error
      ;
      ; Example 1: Number of ways to distribute 5 distinguishable balls to three
      ;            *unordered* boxes such that every box has at least one ball:
      ;            NumberOf_PartitionsK(5, 3) = 25
      ;
      ; Example 2: Number of ways to distribute 5 distinguishable balls to three
      ;            *ordered* boxes such that every box has at least one ball:
      ;            NumberOf_PartitionsK(5, 3, #True) = 150
      
      If ordered = #False And 0 <= k And k <= n And n <= 25
         ProcedureReturn _Stirling2(n, k)
      ElseIf 0 <= k And k <= n And n <= 18
         ProcedureReturn _Factorial(k) * _Stirling2(n, k)
      Else
         ProcedureReturn -1           ; error
      EndIf
   EndProcedure
   
   ; -----------------------------------------------------
   
   Procedure.q _Multinomial (Array k.i(1))
      ; -- Multinomial Coefficient:
      ;    number of permutations with repetition
      ;
      ; (k1+k2+...+kr)!
      ; ---------------
      ; k1!*k2!*...*kr!
      ;
      ; in : array with the numbers of elements in each group
      ; out: return value: positive integer > 0,
      ;                    or 0 on error
      ;
      ; Example: How many different five-digit numbers can be formed from
      ;          the digits 4,4,4,7,7?
      ;          Multinomial(3,2) = 10
      ;
      ;           1) 4 4 4 7 7
      ;           2) 4 4 7 4 7
      ;           3) 4 4 7 7 4
      ;           4) 4 7 4 4 7
      ;           5) 4 7 4 7 4
      ;           6) 4 7 7 4 4
      ;           7) 7 4 4 4 7
      ;           8) 7 4 4 7 4
      ;           9) 7 4 7 4 4
      ;          10) 7 7 4 4 4
      ;
      ; [after
      ;  <https://brilliant.org/wiki/multinomial-coefficients/>, 2018-10-19]
      Protected n.i, i.i, c.q, ret.q, last.i=ArraySize(k())-1
      
      n = k(last+1)
      For i = 0 To last
         n + k(i)
      Next
      
      ret = 1
      For i = 0 To last
         c = _Choose(n, k(i))
         If c = -1
            ProcedureReturn 0     ; error
         EndIf
         ret * c
         n - k(i)
      Next
      
      ProcedureReturn ret         ; success
   EndProcedure
   
   Procedure.q NumberOf_PartitionsT (type$, ordered.i=#False)
      ; -- Number of partitions of a given shape of fixed-size blocks
      ; in : type$  : string with the numbers of elements in each block
      ;               (integers >= 1, separated by ','), defining the shape
      ;               of the wanted partitions
      ;      ordered: #False   : The order of the blocks does not matter.
      ;               #SameSize: The order of blocks of the same size is taken into account.
      ;               #All     : The order of all blocks is taken into account.
      ; out: return value: positive integer > 0,
      ;                    or -1 on error
      ;
      ; Example 1: A cottage has three rooms: one 3-bed room, and two 2-bed rooms.
      ;            In how many ways can seven persons be assigned to the rooms,
      ;            a) if the 2-bed rooms are of equal quality
      ;               (so that it is not necessary to distinguish them)?
      ;               NumberOf_PartitionsT("3,2,2") = 105
      ;
      ;            b) if the 2-bed rooms are of different quality
      ;               (so that it makes sense to distinguish them)?
      ;               NumberOf_PartitionsT("3,2,2", #SameSize) = 210
      ;
      ; Example 2: Seven persons are to be split into three teams: One team
      ;            will have 3 members, and two teams will have 2 members.
      ;            In how many ways can this be done,
      ;            a) if all teams have the same task?
      ;               NumberOf_PartitionsT("3,2,2") = 105
      ;
      ;            b) if all teams have different tasks?
      ;               NumberOf_PartitionsT("3,2,2", #All) = 630
      ;
      ;               NOTE: This situation and therefore also the result is
      ;                     different from Example 1 b).
      ;                     Here the order of ALL 3 parts must be taken into
      ;                     account, not only the order of the parts that
      ;                     have the same size!
      Protected lastBlock.i, i.i, f.q, ret.q
      Protected NewMap numBlocks.i()
      
      If ordered <> #False And ordered <> #SameSize And ordered <> #All
         ProcedureReturn -1                  ; error
      EndIf
      
      If Trim(type$) = ""
         ProcedureReturn 1                   ; success
      EndIf
      
      lastBlock.i = CountString(type$, ",")
      Protected Dim blockSize$ (lastBlock)
      Protected Dim blockSize.i(lastBlock)
      
      For i = 0 To lastBlock
         blockSize$(i) = Trim(StringField(type$, i+1, ","))
         blockSize(i) = Val(blockSize$(i))
         If blockSize$(i) = "" Or blockSize(i) = Val(blockSize$(i)+"1") Or blockSize(i) < 1  ; if blockSize$(i) is not an integer >= 1
            ProcedureReturn -1                                                               ; error
         EndIf
      Next
      
      ret = _Multinomial(blockSize())
      If ret = 0
         ProcedureReturn -1                  ; error
      EndIf
      
      If ordered <> #SameSize
         ; count number of blocks of each size
         For i = 0 To lastBlock
            If FindMapElement(numBlocks(), blockSize$(i)) = 0
               AddMapElement (numBlocks(), blockSize$(i), #PB_Map_NoElementCheck)
               numBlocks() = 1
            Else
               numBlocks() + 1
            EndIf
         Next
         
         ForEach numBlocks()
            If numBlocks() > 1
               f = _Factorial(numBlocks())
               If f = -1
                  ProcedureReturn -1         ; error
               EndIf
               ret / f
            EndIf
         Next
         
         If ordered = #All
            ret * _Factorial(lastBlock+1)
         EndIf
      EndIf
      
      ProcedureReturn ret                    ; success
   EndProcedure
   
   ;--------------------------------------------------------------------
   
   ; This variable is shared with procedures FirstSubset()/NextSubset().
   Dim s_Bit.i(0)
   
   Procedure.i FirstSubset (*s.Set, *sub.Set)
      ; -- initialise Shared variable, and
      ;    return the first subset of 's'
      ;
      ; >> FirstSubset()/NextSubset() can generate all subsets
      ;    of a given set (until NextSubset() returns -1).
      ;
      ; in : *s  : pointer to the concerning set
      ; out: *sub: pointer to generated subset (= empty set)
      ;      Shared variable
      ;      return value: number of elements in 'sub' (= always 0)
      Shared s_Bit()
      
      Clear(*sub)
      
      If Size(*s) > 0
         Dim s_Bit(Size(*s)-1)
      EndIf
      
      ProcedureReturn 0
   EndProcedure
   
   Procedure.i NextSubset (*s.Set, *sub.Set)
      ; -- return the next subset of 's'
      ; in : *s  : pointer to the concerning set
      ;      Shared variable
      ; out: *sub: pointer to generated subset
      ;      Shared variable
      ;      return value: number of elements in 'sub',
      ;                    -1 means end of iteration
      Shared s_Bit()
      Protected.i i, bitSet=#False
      
      Clear(*sub)
      
      i = 0
      ForEach *s\Element()
         If bitSet = #False
            If s_Bit(i) = 1
               s_Bit(i) = 0
            Else
               s_Bit(i) = 1
               bitSet = #True
            EndIf
         EndIf
         
         If s_Bit(i) = 1
            AddMapElement(*sub\Element(), MapKey(*s\Element()), #PB_Map_NoElementCheck)
         EndIf
         i + 1
      Next
      
      *sub\NumElements = Size(*sub)
      
      If *sub\NumElements > 0
         ProcedureReturn *sub\NumElements
      Else
         ProcedureReturn -1
      EndIf
   EndProcedure
   
   ; -----------------------------------------------------
   
   Macro _ArrayToSet ()
      For i = sk_SubsetSize To 1 Step -1
         AddMapElement(*sub\Element(), *sk_MapKey(sk_Elm(i))\s, #PB_Map_NoElementCheck)
      Next
      *sub\NumElements = sk_SubsetSize
   EndMacro
   
   ; These variables are shared with procedures FirstSubsetK()/NextSubsetK().
   Define sk_SubsetSize.i, sk_Index.i
   Dim sk_Elm.i(0)
   Dim *sk_MapKey.String(0)
   
   Procedure.i FirstSubsetK (*s.Set, *sub.Set, k.l)
      ; -- initialise Shared variables, and
      ;    return the first subset of 's' with 'k' elements
      ;
      ; >> FirstSubsetK()/NextSubsetK() can generate all subsets with
      ;    'k' elements of a given set (until the return value is -1).
      ;
      ; in : *s: pointer to the concerning set
      ;      k : number of elements in one subset (0 <= k <= Size(*s))
      ; out: *sub: pointer to generated subset
      ;      Shared variables
      ;      return value: 1: continue iteration
      ;                   -1: end iteration
      ;
      ; [after
      ;  Donald E. Knuth:
      ;  TAOCP, Vol. 4A, Part 1 (2011).
      ;  Algorithm 7.2.1.3 T, p. 359]
      Shared sk_SubsetSize, sk_Index
      Shared sk_Elm(), *sk_MapKey.String()
      Protected i, n = Size(*s)
      
      Clear(*sub)
      
      If k < 0 Or k > n
         ProcedureReturn -1
      EndIf
      
      Dim sk_Elm.i(k+2)
      For i = 1 To k
         sk_Elm(i) = i - 1
      Next
      sk_Elm(k+1) = n
      sk_Elm(k+2) = 0
      
      sk_SubsetSize = k
      sk_Index = k
      
      If n > 0
         ; Store the pointer to each MapKey() of *s\Element() in an array.
         ; It works fine this way e.g. with PB 5.62 both x86 and x64 (tested on Windows).
         ; CAVE: This behaviour is not documented, so it might change in future PB versions!
         Dim *sk_MapKey.String(n-1)
         i = 0
         ForEach *s\Element()
            *sk_MapKey(i) = @ *s\Element() - SizeOf(Integer)
            i + 1
         Next
      EndIf
      
      _ArrayToSet()
      ProcedureReturn 1
   EndProcedure
   
   Procedure.i NextSubsetK (*s.Set, *sub.Set)
      ; -- return the next subset of 's' with 'k' elements
      ; in : *s: pointer to the concerning set
      ;      Shared variables
      ; out: *sub: pointer to generated subset
      ;      Shared variables
      ;      return value: 1: continue iteration
      ;                   -1: end iteration
      Shared sk_SubsetSize, sk_Index
      Shared sk_Elm(), *sk_MapKey.String()
      Protected i, x
      
      Clear(*sub)
      
      If sk_Index > 0
         x = sk_Index
         
      Else
         ; -- Easy case?
         If sk_Elm(1) + 1 < sk_Elm(2)
            sk_Elm(1) + 1
            _ArrayToSet()
            ProcedureReturn 1
         ElseIf sk_SubsetSize < 1
            ProcedureReturn -1
         Else
            sk_Index = 2
         EndIf
         
         ; -- Find sk_Index
         Repeat
            sk_Elm(sk_Index-1) = sk_Index - 2
            x = sk_Elm(sk_Index) + 1
            If x <> sk_Elm(sk_Index+1)
               Break
            EndIf
            sk_Index + 1
         ForEver
         
         ; -- Done?
         If sk_Index > sk_SubsetSize
            ProcedureReturn -1
         EndIf
      EndIf
      
      ; -- Increase sk_Elm(sk_Index)
      sk_Elm(sk_Index) = x
      sk_Index - 1
      
      If sk_SubsetSize < Size(*s)
         _ArrayToSet()
         ProcedureReturn 1
      Else
         ProcedureReturn -1
      EndIf
   EndProcedure
   
   ;--------------------------------------------------------------------
   ; ---------------------------------+
   ;                                  |
   ;  Restricted Growth String (RGS)  |
   ;  ------------------------------  |
   ;                                  |
   ;  E.g. RGS = 0012 means:          |
   ;     element 1 is in block 0,     |
   ;     element 2 is in block 0,     |
   ;     element 3 is in block 1,     |
   ;     element 4 is in block 2.     |
   ;                                  |
   ;  So the related partition is     |
   ;     12|3|4                       |
   ;                                  |
   ; ---------------------------------+
   
   Macro _RgsToPartition (_rgs_)
      i = 0
      ForEach *s\Element()
         SelectElement(*p\Block(), _rgs_(i))
         AddMapElement(*p\Block()\Element(), MapKey(*s\Element()), #PB_Map_NoElementCheck)
         *p\Block()\NumElements + 1
         i + 1
      Next
   EndMacro
   
   ; -----------------------------------------------------
   
   ; These variables are shared with procedures FirstPartition()/NextPartition().
   Dim p_Rgs.i(0)
   Dim p_Max.i(0)
   
   Procedure.i FirstPartition (*s.Set, *p.Partition)
      ; -- initialise Shared variables, and
      ;    return the first unordered partition of 's'
      ;
      ; >> FirstPartition()/NextPartition() can generate all unordered
      ;    partitions of a given set (until NextPartition() returns -1).
      ;
      ; in : *s: pointer to the concerning set
      ; out: *p: pointer to generated first partition
      ;      Shared variables
      ;      return value: number of blocks in 'p'
      ;
      ; [after
      ;  Michael Orlov:
      ;  Efﬁcient Generation of Set Partitions (2002).
      ;  <http://www.informatik.uni-ulm.de/ni/Lehre/WS03/DMM/Software/partitions.pdf>]
      Shared p_Rgs(), p_Max()
      
      ClearPartition(*p)
      
      If *s\NumElements > 0
         Dim p_Rgs(*s\NumElements-1)
         Dim p_Max(*s\NumElements-1)
         
         _AddListElement(*p\Block())
         Copy(*s, *p\Block())
         *p\NumBlocks = 1
      EndIf
      
      ProcedureReturn *p\NumBlocks
   EndProcedure
   
   Procedure.i NextPartition (*s.Set, *p.Partition)
      ; -- return the next unordered partition of 's'
      ; in : *s: pointer to the concerning set
      ;      Shared variables
      ; out: *p: pointer to generated partition
      ;      Shared variables
      ;      return value: number of blocks in 'p',
      ;                    -1 means end of iteration
      Shared p_Rgs(), p_Max()
      Protected.i i, j
      
      ClearPartition(*p)
      
      For i = *s\NumElements-1 To 1 Step -1
         If p_Rgs(i) <= p_Max(i-1)
            p_Rgs(i) + 1
            If p_Max(i) < p_Rgs(i)
               p_Max(i) = p_Rgs(i)
            EndIf
            For j = i+1 To *s\NumElements-1
               p_Rgs(j) = p_Rgs(0)
               p_Max(j) = p_Max(i)
            Next
            
            *p\NumBlocks = p_Max(*s\NumElements-1) - p_Max(0) + 1
            For i = 1 To *p\NumBlocks
               _AddListElement(*p\Block())
            Next
            _RgsToPartition(p_Rgs)
            ProcedureReturn *p\NumBlocks
         EndIf
      Next
      
      ProcedureReturn -1
   EndProcedure
   
   ; -----------------------------------------------------
   
   ; These variables are shared with procedures FirstPartitionK()/NextPartitionK().
   Dim pk_Rgs.i(0)
   Dim pk_Max.i(0)
   
   Procedure.i FirstPartitionK (*s.Set, *p.Partition, k.l)
      ; -- initialise Shared variables, and
      ;    return the first unordered partition of 's' with 'k' blocks
      ;
      ; >> FirstPartitionK()/NextPartitionK() can generate all unordered partitions
      ;    with 'k' blocks of a given set (until the return value is -1).
      ;
      ; in : *s: pointer to the concerning set
      ;      k : number of desired blocks (0 <= k <= Size(*s))
      ; out: *p: pointer to generated first partition
      ;      Shared variables
      ;      return value: 1: continue iteration
      ;                   -1: end iteration
      ;
      ; [after
      ;  Michael Orlov:
      ;  Efﬁcient Generation of Set Partitions (2002).
      ;  <http://www.informatik.uni-ulm.de/ni/Lehre/WS03/DMM/Software/partitions.pdf>]
      Shared pk_Rgs(), pk_Max()
      Protected.i i, rest
      
      ClearPartition(*p)
      
      If *s\NumElements > 0 And 1 <= k And k <= *s\NumElements
         Dim pk_Rgs.i(*s\NumElements-1)
         Dim pk_Max.i(*s\NumElements-1)
         
         rest = *s\NumElements - k
         For i = rest+1 To *s\NumElements-1
            pk_Rgs(i) = i - rest
            pk_Max(i) = pk_Rgs(i)
         Next
         
         *p\NumBlocks = k
         For i = 1 To *p\NumBlocks
            _AddListElement(*p\Block())
         Next
         _RgsToPartition(pk_Rgs)
         ProcedureReturn 1
         
      ElseIf *s\NumElements = 0 And k = 0
         ProcedureReturn 1
      EndIf
      
      ProcedureReturn -1
   EndProcedure
   
   Procedure.i NextPartitionK (*s.Set, *p.Partition)
      ; -- return the next unordered partition of 's' with 'k' blocks
      ; in : *s: pointer to the concerning set
      ;      Shared variables
      ; out: *p: pointer to generated partition
      ;      Shared variables
      ;      return value: 1: continue iteration
      ;                   -1: end iteration
      Shared pk_Rgs(), pk_Max()
      Protected.i nBlocks, last, i, j
      
      If *s\NumElements = 0
         ClearPartition(*p)
         ProcedureReturn -1
      EndIf
      
      nBlocks = pk_Max(*s\NumElements-1) - pk_Max(0) + 1
      
      For i = *s\NumElements-1 To 1 Step -1
         If pk_Rgs(i) < nBlocks - 1 And pk_Rgs(i) <= pk_Max(i-1)
            pk_Rgs(i) + 1
            If pk_Max(i) < pk_Rgs(i)
               pk_Max(i) = pk_Rgs(i)
            EndIf
            last = *s\NumElements - (nBlocks - pk_Max(i))
            For j = i+1 To last
               pk_Rgs(j) = 0
               pk_Max(j) = pk_Max(i)
            Next
            For j = *s\NumElements-(nBlocks-pk_Max(i))+1 To *s\NumElements-1
               pk_Rgs(j) = nBlocks - (*s\NumElements - j)
               pk_Max(j) = pk_Rgs(j)
            Next
            
            ForEach *p\Block()
               ClearMap(*p\Block()\Element())
               *p\Block()\NumElements = 0
            Next
            *p\NumBlocks = nBlocks
            _RgsToPartition(pk_Rgs)
            ProcedureReturn 1
         EndIf
      Next
      
      ClearPartition(*p)
      ProcedureReturn -1
   EndProcedure
   
   ; -----------------------------------------------------
   
   Macro _CheckPartitionType ()
      SortStructuredList(*p\Block(), #PB_Sort_Descending, OffsetOf(Set\NumElements), TypeOf(Set\NumElements))
      
      typeIsMatching = #True
      FirstElement(*p\Block())
      For i = 0 To pt_Last
         If *p\Block()\NumElements <> pt_BlockSize(i)
            typeIsMatching = #False
            Break
         EndIf
         NextElement(*p\Block())
      Next
      
      If typeIsMatching
         ProcedureReturn nxt
      EndIf
   EndMacro
   
   ; -----------------------------------------------------
   
   ; These variables are shared with procedures FirstPartitionT()/NextPartitionT().
   Define pt_Last.i
   Dim pt_BlockSize.i(0)
   
   Procedure.i FirstPartitionT (*s.Set, *p.Partition, type$)
      ; -- initialise Shared variables, and
      ;    return the first unordered partition of 's' of the shape 'type$'
      ;
      ; >> FirstPartitionT()/NextPartitionT() can generate all unordered partitions
      ;    of the shape 'type$' of a given set (until the return value is -1).
      ;
      ; in : *s   : pointer to the concerning set
      ;      type$: string with the numbers of elements in each block
      ;             (integers >= 1, separated by ','), defining the shape of the
      ;             wanted partitions (e.g. "2,2,1");
      ;             The sum of these numbers must equal the number of elements in 's'.
      ; out: *p: pointer to generated first partition
      ;      Shared variables
      ;      return value: 1: continue iteration
      ;                   -1: end iteration
      Shared pt_Last, pt_BlockSize()
      Protected.i typeIsMatching, i, nxt, numBlocks, nElements=0
      
      If Trim(type$) = ""
         numBlocks = 0
      Else
         numBlocks = CountString(type$, ",") + 1
      EndIf
      
      If numBlocks > 0
         Protected Dim blockSize$(numBlocks-1)
         Dim pt_BlockSize(numBlocks-1)
         
         For i = 0 To numBlocks-1
            blockSize$(i) = Trim(StringField(type$, i+1, ","))
            pt_BlockSize(i) = Val(blockSize$(i))
            If blockSize$(i) = "" Or pt_BlockSize(i) = Val(blockSize$(i)+"1") Or pt_BlockSize(i) < 1  ; if blockSize$(i) is not an integer >= 1
               ClearPartition(*p)
               ProcedureReturn -1                                                                     ; error
            EndIf
            nElements + pt_BlockSize(i)
         Next
      EndIf
      
      If nElements <> *s\NumElements
         ClearPartition(*p)
         ProcedureReturn -1           ; error
      EndIf
      
      SortArray(pt_BlockSize(), #PB_Sort_Descending)
      pt_Last = numBlocks - 2
      
      nxt = FirstPartitionK(*s, *p, numBlocks)
      While nxt <> -1
         _CheckPartitionType()
         nxt = NextPartitionK(*s, *p)
      Wend
      
      ProcedureReturn nxt
   EndProcedure
   
   Procedure.i NextPartitionT (*s.Set, *p.Partition)
      ; -- return the next unordered partition of 's' of the shape 'type$'
      ; in : *s: pointer to the concerning set
      ;      Shared variables
      ; out: *p: pointer to generated partition
      ;      Shared variables
      ;      return value: 1: continue iteration
      ;                   -1: end iteration
      Shared pt_Last, pt_BlockSize()
      Protected.i typeIsMatching, i, nxt
      
      nxt = NextPartitionK(*s, *p)
      While nxt <> -1
         _CheckPartitionType()
         nxt = NextPartitionK(*s, *p)
      Wend
      
      ProcedureReturn nxt
   EndProcedure
EndModule


CompilerIf #PB_Compiler_IsMainFile
   ;------------  Module demo  ------------
   ; >> In order to avoid naming conflicts, I recommend not to use
   ;    "UseModule Set", but the full qualified names of the public
   ;    identifiers in the module that start with "Set::".
   EnableExplicit
   
   Define.Set::Set fruits, more, result, sub
   Define n.i, k.i, nxt.i, s$
   
   Debug "===== Data conversion to and from sets, and basic operations ====="
   Debug ""
   
   Select Set::FromString("apple,orange,apple,pear,orange,banana,peach", fruits)
      Case 0
         Debug "Error in function FromString(). Program terminated."
         End
      Case -1
         Debug "Warning: The source string from which the set 'fruits' was generated contains one or more duplicate elements."
   EndSelect
   Debug "fruits = " + Set::ToString(fruits)
   
   Set::AddElement(fruits, "mango")
   Set::RemoveElement(fruits, "orange")
   Debug ~"\"mango\" added and \"orange\" removed."
   
   Debug ""
   Debug "---------------------------------------------------"
   
   Debug "fruits = " + Set::ToString(fruits)
   
   NewList source$()
   AddElement(source$()) : source$() = "apple"
   AddElement(source$()) : source$() = "mango"
   AddElement(source$()) : source$() = "lemon"
   Set::FromList(source$(), more)
   
   Debug "more   = " + Set::ToString(more)
   Debug ""
   
   Set::Union(fruits, more, result)
   Debug "fruits  ∪  more = " + Set::ToString(result)
   
   Set::Intersection(fruits, more, result)
   Debug "fruits  ∩  more = " + Set::ToString(result)
   
   Set::Difference(fruits, more, result)
   Debug "fruits  -  more = " + Set::ToString(result)
   
   Set::SymmetricDifference(fruits, more, result)
   Debug "fruits xor more = " + Set::ToString(result)
   Debug "---------------------------------------------------"
   Debug ""
   
   Define p1$, p2$
   Define.Set::Partition p1, p2, pCross
   Define.Set::Set main
   
   ; Two partitions of the same set:
   p1$ = "{1,2,3} {4,5,6} {7,8}"
   p2$ = "{1,2,4} {3,5,6,7,8}"
   Set::PartitionFromString(p1$, p1)
   Set::PartitionFromString(p2$, p2)
   
   If Set::FromPartition(p1, main) = 1
      Debug "From the following set of " + main\NumElements + " elements ..."
      Debug Set::ToString(main)
      Debug ""
      
      Debug "... these two partitions are given:"
      Debug p1$
      Debug p2$
      Debug ""
      
      k = Set::CrossPartition(p1, p2, pCross)
      If k > -1
         Debug "This is their cross-partition, consisting of " + k + " blocks:"
         Debug Set::PartitionToString(pCross)
      Else
         Debug "Error: 'p1' or 'p2' is not a set partition at all,"
         Debug "or 'p1' and 'p2' are not partitions of the same set."
      EndIf
   Else
      Debug "Error: 'p1' is not a set partition."
   EndIf
   
   Debug ""
   Debug "===== Check membership etc. ====="
   Debug ""
   
   Debug ~"IsElement(fruits, \"apple\")  = " + Set::IsElement(fruits, "apple")
   Debug ~"IsElement(fruits, \"orange\") = " + Set::IsElement(fruits, "orange")
   Debug ""
   
   Debug "IsSubset(fruits, fruits) = " + Set::IsSubset(fruits, fruits)
   Set::FromString("", sub)
   Debug "IsSubset(fruits, {}) = " + Set::IsSubset(fruits, sub)
   Set::FromString("apple,peach", sub)
   Debug "IsSubset(fruits, {apple,peach}) = " + Set::IsSubset(fruits, sub)
   Set::FromString("apple,peach,orange", sub)
   Debug "IsSubset(fruits, {apple,peach,orange}) = " + Set::IsSubset(fruits, sub)
   Debug ""
   
   Debug "IsProperSubset(fruits, fruits) = " + Set::IsProperSubset(fruits, fruits)
   Set::FromString("", sub)
   Debug "IsProperSubset(fruits, {}) = " + Set::IsProperSubset(fruits, sub)
   Set::FromString("apple,peach", sub)
   Debug "IsProperSubset(fruits, {apple,peach}) = " + Set::IsProperSubset(fruits, sub)
   Debug ""
   
   Debug "IsEqual(fruits, fruits) = " + Set::IsEqual(fruits, fruits)
   Debug "IsEqual(fruits, sub) = " + Set::IsEqual(fruits, sub)
   Debug ""
   
   Debug "Similar(fruits, fruits) = " + StrD(Set::Similar(fruits, fruits), 2)
   Debug "Similar(fruits, sub) = " + StrD(Set::Similar(fruits, sub), 2)
   Debug ""
   
   p1$ = "{apple,banana} {mango,peach} {pear}"
   Set::PartitionFromString(p1$, p1)
   Debug p1$
   s$ = "is "
   If Set::CheckPartition(p1, fruits) = -1
      s$ + "not "
   EndIf
   s$ + "a partition of the set"
   Debug s$
   Debug Set::ToString(fruits) + "."
   Debug ""
   
   p2$ = "{peach,mango} {pear} {apple,banana}"
   Set::PartitionFromString(p2$, p2)
   Debug "The unordered partitions"
   Debug p1$
   Debug"and"
   Debug p2$
   s$ = "are "
   If Set::IsEqualPartition(p1, p2) = #False
      s$ + "not "
   EndIf
   s$ + "equal."
   Debug s$
   
   Debug ""
   Debug "===== Calculate basic numbers ====="
   Debug ""
   
   n = 4
   Debug "Number of subsets of a set with " + n + " elements:"
   For k = 0 To n
      Debug "S(" + n + "," + k + ") =  " + Set::NumberOf_SubsetsK(n, k)
   Next
   Debug "sum    = " + Set::NumberOf_Subsets(n)
   Debug ""
   
   n = 4
   Debug "Number of unordered partitions of a set with " + n + " elements:"
   For k = 1 To n
      Debug "U(" + n + "," + k + ") =  " + Set::NumberOf_PartitionsK(n, k)
   Next
   Debug "sum    = " + Set::NumberOf_Partitions(n)
   Debug ""
   
   n = 4
   Debug "Number of ordered partitions of a set with " + n + " elements:"
   For k = 1 To n
      Debug "O(" + n + "," + k + ") = " + Set::NumberOf_PartitionsK(n, k, #True)
   Next
   Debug "sum    = " + Set::NumberOf_Partitions(n, #True)
   Debug ""
   
   Debug "Number of unordered partitions of a given type:"
   s$ = "2,2"
   Debug "TU([" + s$ + "])   =  " + Set::NumberOf_PartitionsT(s$)
   s$ = "2,1,1"
   Debug "TU([" + s$ + "]) =  "   + Set::NumberOf_PartitionsT(s$)
   s$ = "2,2,1"
   Debug "TU([" + s$ + "]) = "    + Set::NumberOf_PartitionsT(s$)
   
   Debug ""
   Debug "Number of partitions of a given type (order of blocks of the same size is taken into account):"
   s$ = "2,2"
   Debug "TS([" + s$ + "])   =  " + Set::NumberOf_PartitionsT(s$, Set::#SameSize)
   s$ = "2,1,1"
   Debug "TS([" + s$ + "]) = "    + Set::NumberOf_PartitionsT(s$, Set::#SameSize)
   s$ = "2,2,1"
   Debug "TS([" + s$ + "]) = "    + Set::NumberOf_PartitionsT(s$, Set::#SameSize)
   
   Debug ""
   Debug "Number of partitions of a given type (order of all blocks is taken into account):"
   s$ = "2,2"
   Debug "TA([" + s$ + "])   =  " + Set::NumberOf_PartitionsT(s$, Set::#All)
   s$ = "2,1,1"
   Debug "TA([" + s$ + "]) = "    + Set::NumberOf_PartitionsT(s$, Set::#All)
   s$ = "2,2,1"
   Debug "TA([" + s$ + "]) = "    + Set::NumberOf_PartitionsT(s$, Set::#All)
   
   Debug ""
   Debug "===== Generate subsets and unordered partitions ====="
   Debug ""
   
   Define count.i, type$
   Define demo.Set::Set, partition.Set::Partition
   
   Debug "* * *  Set #1  * * *"
   
   s$ = "{a,b,c}"
   Set::FromString(s$, demo)
   Debug s$
   Debug ""
   
   Debug "-- " + Set::NumberOf_Subsets(Set::Size(demo)) + " subsets:"
   count = 0
   ; Note: *Nested* calls of the same functions are not supported!
   k = Set::FirstSubset(demo, result)
   While k <> -1
      count + 1
      Debug Str(count) + ")  " + k + " elements: " + Set::ToString(result)
      k = Set::NextSubset(demo, result)
   Wend
   Debug ""
   
   k = 0
   Debug "-- " + Set::NumberOf_SubsetsK(Set::Size(demo), k) + " subsets with " + k + " elements:"
   count = 0
   ; Note: *Nested* calls of the same functions are not supported!
   nxt = Set::FirstSubsetK(demo, result, k)
   While nxt <> -1
      count + 1
      Debug Str(count) + ")" + Space(14) + Set::ToString(result)
      nxt = Set::NextSubsetK(demo, result)
   Wend
   Debug ""
   
   Debug "-- " + Set::NumberOf_Partitions(Set::Size(demo)) + " unordered partitions (long form):"
   count = 0
   ; Note: *Nested* calls of the same functions are not supported!
   k = Set::FirstPartition(demo, partition)
   While k <> -1
      count + 1
      Debug Str(count) + ")  " + k + " blocks: " + Set::PartitionToString(partition)
      k = Set::NextPartition(demo, partition)
   Wend
   Debug ""
   
   k = 2
   Debug "-- " + Set::NumberOf_PartitionsK(Set::Size(demo), k) + " unordered partitions with " + k + " blocks:"
   count = 0
   ; Note: *Nested* calls of the same functions are not supported!
   nxt = Set::FirstPartitionK(demo, partition, k)
   While nxt <> -1
      count + 1
      Debug Str(count) + ")" + Space(12) + Set::PartitionToString(partition)
      nxt = Set::NextPartitionK(demo, partition)
   Wend
   Debug ""
   
   type$ = "2,1"
   Debug "-- " + Set::NumberOf_PartitionsT(type$) + " unordered partitions of the shape '" + type$ + "':"
   count = 0
   ; Note: *Nested* calls of the same functions are not supported!
   nxt = Set::FirstPartitionT(demo, partition, type$)
   While nxt <> -1
      count + 1
      Debug Str(count) + ")" + Space(12) + Set::PartitionToString(partition)
      nxt = Set::NextPartitionT(demo, partition)
   Wend
   Debug ""
   
   
   Debug "* * *  Set #2  * * *"
   
   s$ = "{a,b,c,d}"
   Set::FromString(s$, demo)
   Debug s$
   Debug ""
   
   Debug "-- " + Set::NumberOf_Subsets(Set::Size(demo)) + " subsets:"
   count = 0
   k = Set::FirstSubset(demo, result)
   While k <> -1
      count + 1
      Debug RSet(Str(count),2) + ")  " + k + " elements: " + Set::ToString(result)
      k = Set::NextSubset(demo, result)
   Wend
   Debug ""
   
   k = 2
   Debug "-- " + Set::NumberOf_SubsetsK(Set::Size(demo), k) + " subsets with " + k + " elements:"
   count = 0
   nxt = Set::FirstSubsetK(demo, result, k)
   While nxt <> -1
      count + 1
      Debug Str(count) + ")" + Space(15) + Set::ToString(result)
      nxt = Set::NextSubsetK(demo, result)
   Wend
   Debug ""
   
   Debug "-- " + Set::NumberOf_Partitions(Set::Size(demo)) + " unordered partitions (short form):"
   count = 0
   k = Set::FirstPartition(demo, partition)
   While k <> -1
      count + 1
      Debug RSet(Str(count),2) + ")  " + k + " blocks: " + Set::PartitionToString(partition, #PB_Sort_Ascending, Set::#DontSort, "", "|")
      k = Set::NextPartition(demo, partition)
   Wend
   Debug ""
   
   k = 2
   Debug "-- " + Set::NumberOf_PartitionsK(Set::Size(demo), k) + " unordered partitions with " + k + " blocks:"
   count = 0
   nxt = Set::FirstPartitionK(demo, partition, k)
   While nxt <> -1
      count + 1
      Debug Str(count) + ")" + Space(13) + Set::PartitionToString(partition, #PB_Sort_Ascending, Set::#DontSort, "", "|")
      nxt = Set::NextPartitionK(demo, partition)
   Wend
   Debug ""
   
   type$ = "2,1,1"
   Debug "-- " + Set::NumberOf_PartitionsT(type$) + " unordered partitions of the shape '" + type$ + "':"
   count = 0
   nxt = Set::FirstPartitionT(demo, partition, type$)
   While nxt <> -1
      count + 1
      Debug Str(count) + ")" + Space(13) + Set::PartitionToString(partition, #PB_Sort_Ascending, #PB_Sort_Descending, "", "|")
      nxt = Set::NextPartitionT(demo, partition)
   Wend
   Debug ""
CompilerEndIf
