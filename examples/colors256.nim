import nimbox
import os

when isMainModule:
  var nb = newNimbox()
  defer: nb.shutdown()

  nb.outputMode = out256

#Colors are defined using xTerm numbers.
  nb.print(0, 0, "Hello, world!", 12, 0, styNone)
  nb.print(0, 1, "Hello, world!", 52, 51, styBold)

  for i in 0..255:
    var x = ((i mod 16) * 3) - 2
    nb.print(x, i div 16 + 2, $i, i, 0, styNone)
  nb.present()
  sleep(1000)

