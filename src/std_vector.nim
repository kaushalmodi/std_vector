when defined(c) or defined(js) or defined(objc):
  {.error: "This library needs to be compiled with the cpp backend.".}

import std/[strformat]

{.push header: "<vector>".}

# https://forum.nim-lang.org/t/3401
type
  Vector*[T] {.importcpp: "std::vector".} = object
  # https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-objects
  VectorIter*[T] {.importcpp: "std::vector<'0>::iterator".} = object
  VectorConstIter*[T] {.importcpp: "std::vector<'0>::const_iterator".} = object
  SizeType* = uint

converter VectorIterToVectorConstIter*[T](x: VectorIter[T]): VectorConstIter[T] {.importcpp: "#".}
  ## Implicitly convert mutable C++ iterator to immutable C++ iterator.

# https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-procs
proc newVector*[T](): Vector[T] {.importcpp: "std::vector<'*0>()", constructor.}
# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc newVector*[T](size: SizeType): Vector[T] {.importcpp: "std::vector<'*0>(#)", constructor.}

# https://en.cppreference.com/w/cpp/container/vector/size
proc len*(v: Vector): SizeType {.importcpp: "#.size()".}
  ## Return the number of elements in the Vector.
  ##
  ## This has an alias proc ``size``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[int]()
  ##    doAssert v.size() == 0
  ##
  ##    v.add(100)
  ##    v.add(200)
  ##    doAssert v.len() == 2

# https://en.cppreference.com/w/cpp/container/vector/empty
proc empty*(v: Vector): bool {.importcpp: "empty".}
  ## Check if the Vector is empty i.e. has zero elements.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[int]()
  ##    doAssert v.empty()
  ##
  ##    v.add(100)
  ##    doAssert not v.empty()

# https://en.cppreference.com/w/cpp/container/vector/push_back
proc add*[T](v: var Vector[T], elem: T){.importcpp: "#.push_back(#)".}
  ## Append a new element to the end of the Vector.
  ##
  ## This has an alias proc ``pushBack``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[int]()
  ##    doAssert v.len() == 0
  ##
  ##    v.add(100)
  ##    v.pushBack(200)
  ##    doAssert v.len() == 2

# http://www.cplusplus.com/reference/vector/vector/pop_back/
proc popBack*[T](v: var Vector[T]) {.importcpp: "pop_back".}
  ## Remove the last element of the Vector.
  ## This proc does not return anything.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[int]()
  ##    doAssert v.len() == 0
  ##
  ##    v.add(100)
  ##    doAssert v.len() == 1
  ##
  ##    v.popBack()
  ##    doAssert v.len() == 0

# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc `[]`*[T](v: Vector[T], idx: SizeType): var T {.importcpp: "#[#]".}
  ## Return the reference to ``v[idx]``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[char]()
  ##    v.add('a')
  ##    v.add('b')
  ##    v.add('c')
  ##
  ##    v[1] = 'z'
  ##    doAssert v[0] == 'a'
  ##    doAssert v[1] == 'z'
  ##    doAssert v[2] == 'c'

# https://en.cppreference.com/w/cpp/container/vector/front
proc first*[T](v: Vector[T]): var T {.importcpp: "front".}
  ## Return the reference to the first element of the Vector.
  ##
  ## This has an alias proc ``front``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[int]()
  ##
  ##    v.add(100)
  ##    v.add(200)
  ##    doAssert v.first() == 100
  ##
  ##    v.first() = 300
  ##    doAssert v.first() == 300
  ##    doAssert v.first() == v.front()

# http://www.cplusplus.com/reference/vector/vector/back/
proc last*[T](v: Vector[T]): var T {.importcpp: "back".}
  ## Return the reference to the last element of the Vector.
  ##
  ## This has an alias proc ``back``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = newVector[int]()
  ##
  ##    v.add(100)
  ##    v.add(200)
  ##    doAssert v.last() == 200
  ##
  ##    v.last() = 300
  ##    doAssert v.last() == 300
  ##    doAssert v.last() == v.back()

# https://en.cppreference.com/w/cpp/container/vector/assign
proc assign*[T](v: var Vector[T], num: SizeType, val: T) {.importcpp: "#.assign(@)".}
  ## Return a Vector with ``num`` elements assigned to the specified value ``val``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v: Vector[float]
  ##
  ##    v.assign(5, 1.0)
  ##    doAssert v.toSeq() == @[1.0, 1.0, 1.0, 1.0, 1.0]
  ##
  ##    v.assign(2, 2.3)
  ##    doAssert v.toSeq() == @[2.3, 2.3]

# https://github.com/BigEpsilon/nim-cppstl/blob/de045c27dbbcf193081de5ea2b62f50751bf24fc/src/cppstl/vector.nim#L171
# https://en.cppreference.com/w/cpp/container/vector/operator_cmp
# Relational operators
proc `==`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# == #".}
  ## Return ``true`` if the contents of lhs and rhs are equal, that is,
  ## they have the same number of elements and each element in lhs compares
  ## equal with the element in rhs at the same position.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @[1, 2, 3].toVector()
  ##      v2 = v1
  ##    doAssert v1 == v2

proc `!=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# != #".}
  ## Return ``true`` if the contents of lhs and rhs are not equal, that is,
  ## either they do not have the same number of elements, or one of the elements
  ## in lhs does not compare equal with the element in rhs at the same position.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @[1, 2, 3].toVector()
  ##    var
  ##      v2 = v1
  ##      v3 = v1
  ##    v2.add(4)
  ##    doAssert v2 != v1
  ##
  ##    v3[0] = 100
  ##    doAssert v3 != v1

proc `<`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# < #".}
  ## Return ``true`` if ``a`` is `lexicographically <https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare>`_
  ## less than ``b``.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @[1, 2, 3].toVector()
  ##    var
  ##      v2 = v1
  ##    doAssert not (v1 < v2)
  ##
  ##    v2.add(4)
  ##    doAssert v1 < v2
  ##
  ##    v2[2] = 0
  ##    doAssert v2 < v1

proc `<=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# <= #".}
  ## Return ``true`` if ``a`` is `lexicographically <https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare>`_
  ## less than or equal to ``b``.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @[1, 2, 3].toVector()
  ##    var
  ##      v2 = v1
  ##    doAssert v1 <= v2
  ##
  ##    v2.add(4)
  ##    doAssert v1 <= v2
  ##
  ##    v2[2] = 0
  ##    doAssert v2 <= v1

proc `>`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# > #".}
  ## Return ``true`` if ``a`` is `lexicographically <https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare>`_
  ## greater than ``b``.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @[1, 2, 3].toVector()
  ##    var
  ##      v2 = v1
  ##    doAssert not (v2 > v1)
  ##
  ##    v2.add(4)
  ##    doAssert v2 > v1
  ##
  ##    v2[2] = 0
  ##    doAssert v1 > v2

proc `>=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# >= #".}
  ## Return ``true`` if ``a`` is `lexicographically <https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare>`_
  ## greater than or equal to ``b``.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @[1, 2, 3].toVector()
  ##    var
  ##      v2 = v1
  ##    doAssert v2 >= v1
  ##
  ##    v2.add(4)
  ##    doAssert v2 >= v1
  ##
  ##    v2[2] = 0
  ##    doAssert v1 >= v2

# https://github.com/BigEpsilon/nim-cppstl/blob/master/src/cppstl/private/utils.nim
# Iterator Arithmetic
proc `+`*[T: VectorIter|VectorConstIter](iter: T, offset: int): T {.importcpp: "# + #"}
  ## Return an updated iterator pointing to the input iterator plus the specified ``offset``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @[1.0, 2.0, 3.0].toVector()
  ##
  ##    discard v.insert(v.cBegin()+1, 1.5)
  ##    doAssert v.toSeq() == @[1.0, 1.5, 2.0, 3.0]
  ##
  ##    discard v.insert(v.begin()+3, 2.5)
  ##    doAssert v.toSeq() == @[1.0, 1.5, 2.0, 2.5, 3.0]

proc `-`*[T: VectorIter|VectorConstIter](iter: T, offset: int): T {.importcpp: "# - #"}
  ## Return an updated iterator pointing to the input iterator minus the specified ``offset``.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @[1.0, 2.0, 3.0].toVector()
  ##
  ##    discard v.insert(v.cEnd()-1, 2.5)
  ##    doAssert v.toSeq() == @[1.0, 2.0, 2.5, 3.0]
  ##
  ##    discard v.insert(v.`end`()-3, 1.5)
  ##    doAssert v.toSeq() == @[1.0, 1.5, 2.0, 2.5, 3.0]

# http://www.cplusplus.com/reference/vector/vector/begin/
proc begin*[T](v: Vector[T]): VectorIter[T] {.importcpp: "begin".}
  ## Return a mutable C++ iterator pointing to the beginning position of the Vector.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @[1, 2, 3].toVector()
  ##    discard v.insert(v.begin(), 100)
  ##    doAssert v.toSeq() == @[100, 1, 2, 3]

proc cBegin*[T](v: Vector[T]): VectorConstIter[T] {.importcpp: "cbegin".}
  ## Return an immutable C++ iterator pointing to the beginning position of the Vector.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @[1, 2, 3].toVector()
  ##    discard v.insert(v.cBegin(), 100)
  ##    doAssert v.toSeq() == @[100, 1, 2, 3]

# http://www.cplusplus.com/reference/vector/vector/end/
proc `end`*[T](v: Vector[T]): VectorIter[T] {.importcpp: "end".}
  ## Return a mutable C++ iterator pointing to *after* the end position of the Vector.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @[1, 2, 3].toVector()
  ##    discard v.insert(v.`end`(), 100)
  ##    doAssert v.toSeq() == @[1, 2, 3, 100]

proc cEnd*[T](v: Vector[T]): VectorConstIter[T] {.importcpp: "cend".}
  ## Return an immutable C++ iterator pointing to *after* the end position of the Vector.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @[1, 2, 3].toVector()
  ##    discard v.insert(v.cEnd(), 100)
  ##    doAssert v.toSeq() == @[1, 2, 3, 100]

proc insert*[T](v: var Vector[T], pos: VectorConstIter[T], val: T): VectorIter[T] {.importcpp: "insert".}
  ## Insert an element before the specified position.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @['a', 'b'].toVector()
  ##    discard v.insert(v.cBegin(), 'c')
  ##    doAssert v.toSeq() == @['c', 'a', 'b']

proc insert*[T](v: var Vector[T], pos: VectorConstIter[T], count: SizeType, val: T): VectorIter[T] {.importcpp: "insert".}
  ## Insert ``count`` copies of element  before the specified position.
  ##
  ## .. code-block::
  ##    :test:
  ##    var
  ##      v = @['a', 'b'].toVector()
  ##    discard v.insert(v.cBegin(), 3, 'c')
  ##    doAssert v.toSeq() == @['c', 'c', 'c', 'a', 'b']

proc insert*[T](v: var Vector[T], pos, first, last: VectorConstIter[T]): VectorIter[T] {.importcpp: "insert".}
  ## Insert elements from range ``first`` ..< ``last`` before the specified position.
  ##
  ## .. code-block::
  ##    :test:
  ##    let
  ##      v1 = @['a', 'b'].toVector()
  ##    var
  ##      v2: Vector[char]
  ##    discard v2.insert(v2.cBegin(), v1.cBegin(), v1.cEnd())
  ##    doAssert v2.toSeq() == @['a', 'b']

{.pop.} # {.push header: "<vector>".}


# Aliases

proc size*(v: Vector): SizeType {.inline.} =
  ## Alias for `len proc <#len,Vector>`_.
  v.len()

proc pushBack*[T](v: var Vector[T]; elem: T) {.inline.} =
  ## Alias for `add proc <#add,Vector[T],T>`_.
  v.add(elem)

proc front*[T](v: Vector[T]): T {.inline.} =
  ## Alias for `first proc <#first,Vector[T]>`_.
  v.first()

proc back*[T](v: Vector[T]): T {.inline.} =
  ## Alias for `last proc <#last,Vector[T]>`_.
  v.last()


# Other procs

proc `[]=`*[T](v: var Vector[T], idx: SizeType, val: T) {.inline.} =
  ## Set the value at ``v[idx]`` to the specified value ``val``.
  runnableExamples:
    var
      v = newVector[int](2)
    doAssert v.toSeq() == @[0, 0]

    v[0] = -1
    doAssert v.toSeq() == @[-1, 0]
  #
  # v[idx] = val # <-- This will not work because that will result in recursive calls of `[]=`.
  # So first get the elem using `[]`, then get its addr and then deref it.
  (unsafeAddr v[idx])[] = val


# Iterators

iterator items*[T](v: Vector[T]): T=
  ## Iterate over all the elements in Vector ``v``.
  runnableExamples:
    var
      v: Vector[int]
      sum: int

    v.assign(3, 5)

    for elem in v:
      sum += elem
    doAssert sum == 15
  #
  for idx in 0.SizeType ..< v.len():
    yield v[idx]

iterator pairs*[T](v: Vector[T]): (SizeType, T) =
  ## Iterate over ``(index, value)`` for all the elements in Vector ``v``.
  runnableExamples:
    var
      v: Vector[int]
      sum: int

    v.assign(3, 5)

    for idx, elem in v:
      sum += idx.int + elem
    doAssert sum == 18
  #
  for idx in 0.SizeType ..< v.len():
    yield (idx, v[idx])

# To and from seq
proc toSeq*[T](v: Vector[T]): seq[T] =
  ## Convert a Vector to a sequence.
  runnableExamples:
    var
      v: Vector[char]
    v.assign(3, 'k')

    doAssert v.toSeq() == @['k', 'k', 'k']
  #
  for elem in v:
    result.add(elem)

proc toVector*[T](s: openArray[T]): Vector[T] =
  ## Convert an array/sequence to a Vector.
  runnableExamples:
    let
      s = @[1, 2, 3]
      a = [1, 2, 3]

    doAssert s.toVector().toSeq() == s
    doAssert a.toVector().toSeq() == s
  #
  for elem in s:
    result.add(elem)

# Display the content of a Vector
# https://github.com/BigEpsilon/nim-cppstl/blob/de045c27dbbcf193081de5ea2b62f50751bf24fc/src/cppstl/vector.nim#L197
proc `$`*[T](v: Vector[T]): string {.noinit.} =
  ## The ``$`` operator for Vector type variables.
  ## This is used internally when calling ``echo`` on a Vector type variable.
  runnableExamples:
    var
      v = newVector[int]()
    doAssert $v == "v[]"

    v.add(100)
    v.add(200)
    doAssert $v == "v[100, 200]"
  #
  if v.empty():
    result = "v[]"
  else:
    result = "v["
    for idx in 0.SizeType ..< v.size()-1:
      result.add($v[idx] & ", ")
    result.add($v.last() & "]")

when isMainModule:
  import std/[unittest, sequtils]

  suite "constructor, size/len, empty":
    setup:
      var
        v1 = newVector[int]()
        v2 = newVector[int](10)

    test "size/len":
      check v1.size() == 0.SizeType
      check v2.len() == 10.SizeType

    test "empty":
      check v1.empty() == true
      check v2.empty() == false

  suite "push, pop":
    setup:
      var
        v = newVector[int]()

    test "push/add, pop, front/first, back/last":
      v.pushBack(100)
      check v.len() == 1.SizeType

      v.add(200)
      check v.len() == 2.SizeType

      v.popBack()
      check v.len() == 1.SizeType

      v.add(300)
      v.add(400)
      v.add(500)

      for idx in 0.SizeType ..< v.len():
        echo &"  v[{idx}] = {v[idx]}"

      check v.len() == 4.SizeType

      check v.first() == 100
      v.first() = 1
      check v.front() == 1

      check v.last() == 500
      v.last() = 5
      check v.back() == 5

  suite "iterators, $":
    setup:
      var
        v = newVector[cstring]()

      v.add("hi")
      v.add("there")
      v.add("bye")

      echo "Testing items iterator:"
      for elem in v:
        echo &" {elem}"
      echo ""

      echo "Testing pairs iterator:"
      for idx, elem in v:
        echo &" v[{idx}] = {elem}"

    test "$":
      check $v == "v[hi, there, bye]"

  suite "converting to/from a Vector/mutable sequence":
    setup:
      var
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
        v: Vector[float]

    test "mut seq -> mut Vector -> mut seq":
      v = s.toVector()
      check v.toSeq() == s


  suite "converting from an immutable sequence":
    setup:
      let
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
      var
        v: Vector[float]

    test "immut seq -> mut Vector -> mut seq":
      v = s.toVector()
      check v.toSeq() == s

  suite "converting array -> Vector -> sequence":
    setup:
      let
        a = [1.1, 2.2, 3.3, 4.4, 5.5]
        v = a.toVector()
        s = a.toSeq()

    test "immut array -> immut vector -> immut seq":
      check v.toSeq() == s

  suite "assign":
    setup:
      var
        v: Vector[char]

    test "assign":
      check v.len() == 0

      v.assign(4, '.')
      check v.toSeq() == @['.', '.', '.', '.']

      v.assign(2, 'a')
      check v.toSeq() == @['a', 'a']

  suite "set an element value":
    setup:
      var
        v = newVector[int](5)

    test "[]=":
      v[1] = 100
      v[3] = 300
      check v.toSeq() == @[0, 100, 0, 300, 0]

  suite "relational operators":
    setup:
      let
        v1 = @[1, 2, 3].toVector()

    test "==, <=, >=":
      let
        v2 = v1
      check v1 == v2
      check v1 <= v2
      check v1 >= v2

    test ">, >=":
      let
        v2 = @[1, 2, 4].toVector()
      check v2 > v1
      check v2 >= v1

    test ">, unequal vector lengths":
      let
        v2 = @[1, 2, 4].toVector()
        v3 = @[1, 2, 3, 0].toVector()
      check v3 > v1
      check v2 > v3

    test "<, <=":
      let
        v2 = @[1, 2, 4].toVector()
      check v1 < v2
      check v1 <= v2

    test "<, unequal vector lengths":
      let
        v2 = @[1, 2, 4].toVector()
        v3 = @[1, 2, 3, 0].toVector()
      check v1 < v3
      check v3 < v2

  suite "(c)begin, (c)end, insert":
    setup:
      var
        v = @[1, 2, 3].toVector()

    test "insert elem at the beginning":
      discard v.insert(v.cBegin(), 9)
      check v == @[9, 1, 2, 3].toVector()

      # Below, using .begin() instead of .cBegin() also
      # works.. because of the VectorIterToVectorConstIter converter.
      discard v.insert(v.begin(), 10)
      check v == @[10, 9, 1, 2, 3].toVector()

    test "insert elem at the end":
      discard v.insert(v.cEnd(), 9)
      check v == @[1, 2, 3, 9].toVector()

      # Below, using .`end`() instead of .cEnd() also
      # works.. because of the VectorIterToVectorConstIter converter.
      discard v.insert(v.`end`(), 10)
      check v == @[1, 2, 3, 9, 10].toVector()

    test "insert copies of a val":
      discard v.insert(v.cEnd(), 3, 111)
      check v == @[1, 2, 3, 111, 111, 111].toVector()

    test "insert elements from a Vector range":
      # Below copies the whole vector and appends to itself at the end.
      discard v.insert(v.cEnd(), v.cBegin(), v.cEnd())
      check v == @[1, 2, 3, 1, 2, 3].toVector()

      # Below is a long-winded way to copy one Vector to another.
      var
        v2: Vector[int]
      discard v2.insert(v2.cEnd(), v.cBegin(), v.cEnd())
      check v2 == v

  suite "iterator arithmetic":
    setup:
      var
        v = @[1, 2, 3].toVector()

    test "insert elem after the first element":
      discard v.insert(v.cBegin()+1, 9)
      check v == @[1, 9, 2, 3].toVector()

    test "insert elem before the last element":
      discard v.insert(v.cEnd()-1, 9)
      check v == @[1, 2, 9, 3].toVector()
