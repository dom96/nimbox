import nimbox
import os

when isMainModule:
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
        if evt.key.sym == Symbol.Escape:
          break
        ch = evt.key.ch
      else: discard

