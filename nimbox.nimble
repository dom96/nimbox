# vim: ft=nim
import strutils

version     = "0.1.0"
author      = "Samadi van Koten"
description = "A Rustbox-inspired termbox wrapper"
license     = "MIT"
skipDirs    = @["examples"]
skipFiles   = @["nimbox/.keep"]

requires "nim >= 0.14.3"

proc init() =
  when defined(windows):
    echo "\x1B[33mNimbox doesn't work on Windows, sorry!\x1B[0m"
    quit 1
  elif not defined(linux):
    echo "\x1B[31mNimbox has not been tested on " & hostOS & ". Proceed with caution!\x1B[0m"

  # Fix integer types
  var buf = """#ifdef C2NIM
  #mangle uint8_t uint8
  #mangle uint16_t uint16
  #mangle uint32_t uint32
  #mangle int8_t int8
  #mangle int16_t int16
  #mangle int32_t int32
  #endif
  """

  var skip = false

  var termbox = readFile("/usr/include/termbox.h")
  for line in termbox.splitLines():
    if skip:
      if line.startsWith("#endif"):
        skip = false
    elif line.startsWith("#if __GNUC__"):
      skip = true
    else:
      if line.startsWith("SO_IMPORT "):
        buf &= line.substr(10)
      else:
        buf &= line
      buf &= "\n"

  writeFile("/tmp/termbox.h", buf)

  exec "c2nim --header --skipcomments --ref --nep1 /tmp/termbox.h -o:nimbox/termbox.nim"

  var nimbuf = "{.passl: \"-Wl,-Bstatic -ltermbox -Wl,-Bdynamic\", emit: \"typedef struct tb_event tb_event;\".}\n"
  nimbuf &= readFile("nimbox/termbox.nim")
  writeFile("nimbox/termbox.nim", nimbuf)

task init, "Create low-level termbox wrapper":
  init()

before install:
  init()

before build:
  init()

