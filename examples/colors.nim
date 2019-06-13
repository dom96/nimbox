import nimbox
import os

proc main() =
  var nb = newNimbox()
  defer: nb.shutdown()

  nb.print(0, 0, "Hello, world!", clrRed, clrGreen, styUnderline)
  nb.present()
  sleep(1000)

  nb.print(0, 0, "Hello, world!", clrRed, clrGreen, styUnderline and styBold)
  nb.present()
  sleep(1000)


when isMainModule:
  main()
