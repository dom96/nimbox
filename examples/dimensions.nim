import nimbox
import os

proc main() =
  var nb = newNimbox()
  defer: nb.shutdown()

  nb.print(0, 0, $nb.width & "x" & $nb.height)
  nb.present()
  sleep(1000)


when isMainModule:
  main()
