import std/[strformat]
# http://www.cplusplus.com/reference/vector/vector/

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

# http://www.cplusplus.com/reference/vector/vector/begin/
proc begin*[T](v: var Vector[T]): VectorIterator[T] {.importcpp: "begin", header: "<vector>".}
proc beginPtr*[T](v: var Vector[T]): ptr T {.importcpp: "begin", header: "<vector>".}

# http://www.cplusplus.com/reference/vector/vector/back/
proc back*[T](v: var Vector[T]): T {.importcpp: "back", header: "<vector>".}

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

when isMainModule:
  var
    v1 = newVector[int]()
    v2 = newVector[int](10)

  echo &"size of v1 = {v1.size()}"
  echo &"size of v2 = {v2.size()}"

  v1.pushBack(100)
  echo &"size of v1 = {v1.len()}"

  v1.add(200)
  echo &"size of v1 = {v1.len()}"

  v1.popBack()
  echo v1.size()

  v1.add(300)
  v1.add(400)
  v1.add(500)
  echo v1.size()

  echo v1.beginPtr()[]
  echo v1.back()

  echo v1.endPtr()[] # Will return an arbitrary value as this returns
                    # the ptr to memory *after* the last element.

  for idx in 0 ..< v1.len():
    echo &"v1[{idx}] = {v1[idx]}"

  for elem in v1:
    echo &"{elem}"

  for idx, elem in v1:
    echo &"v1[{idx}] = {elem}"

  # TODO How to use the VectorIterator now?
  # dummy code follows:
  # for vElem in <VectorIterator var>:
  #   echo vElme

# https://forum.nim-lang.org/t/5787
