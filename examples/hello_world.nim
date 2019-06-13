import nimbox
import os

proc main() =
  var nb = newNimbox()
  defer: nb.shutdown()

  nb.print(0, 0, "Hello, world!")
  nb.present()
  sleep(1000)

when isMainModule:
  main()
