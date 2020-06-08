# Package

version       = "0.2.0"
author        = "Kaushal Modi"
description   = "Nim wrapper for C++ std::vector"
license       = "MIT"
srcDir        = "src"

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0"

template echoRun(cmd) =
  echo astToStr(cmd)
  cmd

task test, "test":
  # for lack of something better; this will be used in important_packages
  echoRun exec "nim doc src/std_vector.nim"
