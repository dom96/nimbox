import nimbox
import os

proc main() =
  var nb = newNimbox()
  defer: nb.shutdown()

  var ch: char
  var evt: Event
  while true:
    nb.clear()
    nb.print(0, 0, "Hello, world! " & ch)
    nb.present()

    evt = nb.peekEvent(1000)
    case evt.kind:
      of EventType.Key:
        if evt.sym == Symbol.Escape:
          break
        ch = evt.ch
      else: discard

when isMainModule:
  main()
