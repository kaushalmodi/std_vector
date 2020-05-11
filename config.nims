import std/[os, strformat]

const
  nimVersion = (major: NimMajor, minor: NimMinor, patch: NimPatch)

when nimVersion >= (1, 3, 0):
  # https://github.com/nim-lang/Nim/commit/9502e39b634eea8e04f07ddc110b466387f42322
  switch("backend", "cpp")

task testAll, "Compile and run all files in this library":
  for file in walkDirRec(".", {pcFile}):
    let
      (_, _, ext) = file.splitFile()
    if ext == ".nim":
      echo &"Running {file} .."
      selfExec &"cpp -r -d:release {file}"
      echo ""
