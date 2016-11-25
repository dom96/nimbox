import nimbox
import os

when isMainModule:
  var nb = newNimbox()
  defer: nb.shutdown()

  nb.print(0, 0, "Hello, world!")
  nb.present()
  sleep(1000)

