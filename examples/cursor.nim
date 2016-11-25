import nimbox
import os

when isMainModule:
  var nb = newNimbox()
  defer: nb.shutdown()

  for _ in 1..5:
    nb.cursor = (1, 2)
    nb.present()
    sleep(1000)
    # nb.cursor = nil
    # nb.present()
    # sleep(1000)

