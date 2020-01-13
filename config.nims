import std/[os, strformat]

# Compile and run the test code blocks in doc string using the cpp backend.
switch("define", "doccpp")

task testAll, "Compile and run all files in this library":
  for file in walkDirRec(".", {pcFile}):
    let
      (_, _, ext) = file.splitFile()
    if ext == ".nim":
      echo &"Running {file} .."
      selfExec &"cpp -r -d:release {file}"
      echo ""
