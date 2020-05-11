task pullConfig, "Fetch my global config.nims":
  exec("git submodule add -f -b master https://github.com/kaushalmodi/nim_config")
when fileExists("nim_config/config.nims"):
  include "nim_config/config.nims"

when not compiles(nimVersion):
  const nimVersion = (major: NimMajor, minor: NimMinor, patch: NimPatch)

when nimVersion >= (1, 3, 0):
  # https://github.com/nim-lang/Nim/commit/9502e39b634eea8e04f07ddc110b466387f42322
  switch("backend", "cpp")
