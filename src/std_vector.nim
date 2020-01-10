import std/[strformat]

# https://forum.nim-lang.org/t/3401
type
  Vector*[T] {.importcpp: "std::vector", header: "<vector>".} = object
  # https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-objects
  VectorIterator*[T] {.importcpp: "std::vector<'0>::iterator".} = object

# https://nim-lang.github.io/Nim/manual.html#importcpp-pragma-importcpp-for-procs
proc newVector*[T](): Vector[T] {.importcpp: "std::vector<'*0>()", header: "<vector>", constructor.}
# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
# FIXME Below does not work
proc newVector*[T](size: int): Vector[T] {.importcpp: "std::vector<'*0>(#)", header: "<vector>", constructor.}

# http://www.cplusplus.com/reference/vector/vector/size/
proc size*(v: Vector): int {.importcpp: "#.size()", header: "<vector>".}
proc size*(v: var Vector): int {.importcpp: "#.size()", header: "<vector>".}
proc len*(v: Vector): int {.importcpp: "#.size()", header: "<vector>".}
proc len*(v: var Vector): int {.importcpp: "#.size()", header: "<vector>".}

# https://github.com/nim-lang/Nim/issues/9685#issue-379682147
# http://www.cplusplus.com/reference/vector/vector/push_back/
proc pushBack*[T](v: var Vector[T]; elem: T) {.importcpp: "#.push_back(#)", header: "<vector>".}
proc add*[T](v: var Vector[T], elem: T){.importcpp: "#.push_back(#)", header: "<vector>".}
# http://www.cplusplus.com/reference/vector/vector/pop_back/
proc popBack*[T](v: var Vector[T]) {.importcpp: "pop_back", header: "<vector>".}

# https://en.cppreference.com/w/cpp/container/vector/front
proc front*[T](v: var Vector[T]): T {.importcpp: "front", header: "<vector>".}
proc first*[T](v: var Vector[T]): T {.importcpp: "front", header: "<vector>".}

# http://www.cplusplus.com/reference/vector/vector/back/
proc back*[T](v: var Vector[T]): T {.importcpp: "back", header: "<vector>".}
proc last*[T](v: var Vector[T]): T {.importcpp: "back", header: "<vector>".}

# http://www.cplusplus.com/reference/vector/vector/begin/
proc begin*[T](v: var Vector[T]): VectorIterator[T] {.importcpp: "begin", header: "<vector>".}
proc beginPtr*[T](v: var Vector[T]): ptr T {.importcpp: "begin", header: "<vector>".}

# http://www.cplusplus.com/reference/vector/vector/end/
proc `end`*[T](v: var Vector[T]): VectorIterator[T] {.importcpp: "end", header: "<vector>".}
proc endPtr*[T](v: var Vector[T]): ptr T {.importcpp: "end", header: "<vector>".}

# https://github.com/numforge/agent-smith/blob/a2d9251e/third_party/std_cpp.nim#L23-L31
proc `[]`*[T](v: Vector[T], idx: int): T{.importcpp: "#[#]", header: "<vector>".}
proc `[]`*[T](v: var Vector[T], idx: int): var T{.importcpp: "#[#]", header: "<vector>".}

# Iterators
iterator items*[T](v: Vector[T]): T=
  for idx in 0 ..< v.len():
    yield v[idx]

iterator pairs*[T](v: Vector[T]): (int, T) =
  for idx in 0 ..< v.len():
    yield (idx, v[idx])

# To and from seq
proc toSeq*[T](v: var Vector[T]): seq[T] =
  ## Convert mutable Vector to a sequence.
  for elem in v:
    result.add(elem)
proc toSeq*[T](v: Vector[T]): seq[T] =
  ## Convert immutable Vector to a sequence.
  var
    vMut = v
  return vMut.toSeq()

proc toVector*[T](s: var seq[T]): Vector[T] =
  ## Convert mutable sequence to a Vector.
  result = newVector[T]()
  for elem in s:
    result.add(elem)
proc toVector*[T](s: seq[T]): Vector[T] =
  ## Convert immutable sequence to a Vector.
  var
    sMut = s
  return sMut.toVector()

when isMainModule:
  import std/[unittest]

  # TODO How to use the VectorIterator now?
  # dummy code follows:
  # for vElem in <VectorIterator var>:
  #   echo vElem

  suite "constructor, size":
    setup:
      var
        v1 = newVector[int]()
        v2 = newVector[int](10)

    test "constructor without size specification":
      check:
        v1.size() == 0

    test "constructor with size specification":
      check:
        v2.len() == 10

  suite "push, pop":
    setup:
      var
        v = newVector[int]()

    test "push/add, pop, front/first, back/last":
      check:
        block:
          v.pushBack(100)
          v.size() == 1

        block:
          v.add(200)
          v.size() == 2

        block:
          v.popBack()
          v.size() == 1

        block:
          v.add(300)
          v.add(400)
          v.add(500)

          for idx in 0 ..< v.len():
            echo &"  v[{idx}] = {v[idx]}"

          v.size() == 4

        block:
          v.first() == 100 and v.front() == 100

        block:
          v.last() == 500 and v.back() == 500

  suite "beginPtr, endPtr, iterators":
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
      check:
        v.beginPtr()[] == "hi"

  suite "converting to/from a Vector/mutable sequence":
    setup:
      var
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
        v: Vector[float]

    test "mut seq -> mut Vector -> mut seq":
      check:
        block:
          v = s.toVector()
          v.toSeq() == s

  suite "converting from an immutable sequence":
    setup:
      let
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
      var
        v: Vector[float]

    test "immut seq -> mut Vector -> mut seq":
      check:
        block:
          v = s.toVector()
          v.toSeq() == s

  suite "converting from an immutable Vector":
    setup:
      let
        s = @[1.1, 2.2, 3.3, 4.4, 5.5]
        v = s.toVector()

    test "immut seq -> immut vector -> mut seq":
      check:
        v.toSeq() == s
