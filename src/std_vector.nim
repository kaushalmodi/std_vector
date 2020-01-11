import std/[strformat]

{.push header: "<vector>".}

# https://forum.nim-lang.org/t/3401
type
  Vector*[T] {.importcpp: "std::vector".} = object
  # https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-objects
  VectorIterator*[T] {.importcpp: "std::vector<'0>::iterator".} = object

# https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-procs
proc newVector*[T](): Vector[T] {.importcpp: "std::vector<'*0>()", constructor.}
# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc newVector*[T](size: int): Vector[T] {.importcpp: "std::vector<'*0>(#)", constructor.}

# http://www.cplusplus.com/reference/vector/vector/size/
proc size*(v: Vector): int {.importcpp: "#.size()".}
proc len*(v: Vector): int {.importcpp: "#.size()".}

# https://en.cppreference.com/w/cpp/container/vector/empty
proc empty*(v: Vector): bool {.importcpp: "empty".}

# https://github.com/nim-lang/Nim/issues/9685#issue-379682147
# http://www.cplusplus.com/reference/vector/vector/push_back/
proc pushBack*[T](v: var Vector[T]; elem: T) {.importcpp: "#.push_back(#)".}
proc add*[T](v: var Vector[T], elem: T){.importcpp: "#.push_back(#)".}
# http://www.cplusplus.com/reference/vector/vector/pop_back/
proc popBack*[T](v: var Vector[T]) {.importcpp: "pop_back".}

# https://en.cppreference.com/w/cpp/container/vector/front
proc front*[T](v: Vector[T]): T {.importcpp: "front".}
proc first*[T](v: Vector[T]): T {.importcpp: "front".}

# http://www.cplusplus.com/reference/vector/vector/back/
proc back*[T](v: Vector[T]): T {.importcpp: "back".}
proc last*[T](v: Vector[T]): T {.importcpp: "back".}

# http://www.cplusplus.com/reference/vector/vector/begin/
proc begin*[T](v: Vector[T]): VectorIterator[T] {.importcpp: "begin".}
proc beginPtr*[T](v: Vector[T]): ptr T {.importcpp: "begin".}

# http://www.cplusplus.com/reference/vector/vector/end/
proc `end`*[T](v: Vector[T]): VectorIterator[T] {.importcpp: "end".}
proc endPtr*[T](v: Vector[T]): ptr T {.importcpp: "end".}

# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc `[]`*[T](v: Vector[T], idx: int): T {.importcpp: "#[#]".}
proc `[]`*[T](v: var Vector[T], idx: int): var T {.importcpp: "#[#]".}

# https://en.cppreference.com/w/cpp/container/vector/assign
proc assign*[T](v: var Vector[T], idx: int, val: T) {.importcpp: "#.assign(@)".}

# https://github.com/BigEpsilon/nim-cppstl/blob/de045c27dbbcf193081de5ea2b62f50751bf24fc/src/cppstl/vector.nim#L171
# Relational operators
proc `==`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# == #".}
proc `!=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# != #".}
proc `<`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# < #".}
proc `<=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# <= #".}
proc `>`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# > #".}
proc `>=`*[T](a: Vector[T], b: Vector[T]): bool {.importcpp: "# >= #".}

{.pop.} # {.push header: "<vector>".}


proc `[]=`*[T](v: var Vector[T], idx: int, val: T) {.inline.} =
  # v[idx] = val # <-- This will not work because that will result in recursive calls of `[]=`.
  # So first get the elem using `[]`, then get its addr and then deref it.
  (unsafeAddr v[idx])[] = val

# Iterators
iterator items*[T](v: Vector[T]): T=
  for idx in 0 ..< v.len():
    yield v[idx]

iterator pairs*[T](v: Vector[T]): (int, T) =
  for idx in 0 ..< v.len():
    yield (idx, v[idx])

# To and from seq
proc toSeq*[T](v: Vector[T]): seq[T] =
  ## Convert a Vector to a sequence.
  for elem in v:
    result.add(elem)

proc toVector*[T](s: openArray[T]): Vector[T] =
  ## Convert an array/sequence to a Vector.
  for elem in s:
    result.add(elem)

# Display the content of a Vector
# https://github.com/BigEpsilon/nim-cppstl/blob/de045c27dbbcf193081de5ea2b62f50751bf24fc/src/cppstl/vector.nim#L197
proc `$`*[T](v: Vector[T]): string {.noinit.} =
  if v.empty():
    result = "v[]"
  else:
    result = "v["
    for idx in 0 ..< v.size()-1:
      result.add($v[idx] & ", ")
    result.add($v.last() & "]")

when isMainModule:
  import std/[unittest, sequtils]

  # TODO How to use the VectorIterator now?
  # dummy code follows:
  # for vElem in <VectorIterator var>:
  #   echo vElem

  suite "constructor, size, empty":
    setup:
      var
        v1 = newVector[int]()
        v2 = newVector[int](10)

    test "constructor without size specification":
      check v1.size() == 0

    test "constructor with size specification":
      check v2.len() == 10

    test "empty":
      check v1.empty() == true
      check v2.empty() == false

  suite "push, pop":
    setup:
      var
        v = newVector[int]()

    test "push/add, pop, front/first, back/last":
      v.pushBack(100)
      check v.size() == 1

      v.add(200)
      check v.size() == 2

      v.popBack()
      check v.size() == 1

      v.add(300)
      v.add(400)
      v.add(500)

      for idx in 0 ..< v.len():
        echo &"  v[{idx}] = {v[idx]}"

      check v.size() == 4

      check v.first() == 100
      check v.front() == 100

      check v.last() == 500
      check v.back() == 500

  suite "beginPtr, endPtr, iterators, $":
    setup:
      var
        v = newVector[cstring]()

      v.add("hi")
      v.add("there")
      v.add("bye")

      echo v.endPtr()[] # This will return an arbitrary value as this returns
                        # the ptr to memory *after* the last element.

      echo "Testing items iterator:"
      for elem in v:
        echo &" {elem}"
      echo ""

      echo "Testing pairs iterator:"
      for idx, elem in v:
        echo &" v[{idx}] = {elem}"

    test "beginPtr":
      check v.beginPtr()[] == "hi"

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
        v2 = v1
        v3 = @[1, 2, 4].toVector()
        v4 = @[1, 2, 3, 0].toVector()

    test "==, <=, >=":
      check v1 == v2
      check v1 <= v2
      check v1 >= v2

    test ">, >=":
      check v3 > v1
      check v3 >= v1

    test ">, unequal vector lengths":
      check v4 > v1
      check v3 > v4

    test "<, <=":
      check v1 < v3
      check v1 <= v3

    test "<, unequal vector lengths":
      check v1 < v4
      check v4 < v3
