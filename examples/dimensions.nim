import nimbox
import os

when isMainModule:
  var nb = newNimbox()
  defer: nb.shutdown()

  nb.print(0, 0, $nb.width & "x" & $nb.height)
  nb.present()
  sleep(1000)

