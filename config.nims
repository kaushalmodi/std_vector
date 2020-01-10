import std/[os, strformat]

task testAll, "Compile and run all files in this library":
  for file in walkDirRec(".", {pcFile}):
    let
      (_, _, ext) = file.splitFile()
    if ext == ".nim":
      echo &"Running {file} .."
      selfExec &"cpp -r -d:release {file}"
      echo ""
