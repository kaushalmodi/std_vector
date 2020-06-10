import std/[os,strformat]

template runCmd(cmd) =
  echo cmd
  doAssert execShellCmd(cmd) == 0

proc main* =
  # xxx at least adding a few sanity checks would be nice
  const nim = getCurrentCompilerExe()
  runCmd fmt"{nim} doc src/std_vector.nim"
main()
