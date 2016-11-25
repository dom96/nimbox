include nimbox/termbox

type
  Nimbox* = object of RootObj

  Modifier* {.pure.} = enum
    Ctrl
    Alt
    Motion

  Symbol* {.pure.} = enum
    F1
    F2
    F3
    F4
    F5
    F6
    F7
    F8
    F9
    F10
    F11
    F12

    Insert
    Delete
    Home
    End
    Pgup
    Pgdn
    ArrowUp
    ArrowDown
    ArrowLeft
    ArrowRight

    MouseLeft
    MouseRight
    MouseMiddle
    MouseRelease
    MouseWheelUp
    MouseWheelDown

    Escape
    Space
    Tab
    Enter
    Backspace

  Key = object of RootObj
    mods*: seq[Modifier]
    sym*: Symbol
    ch*: char

  EventType* {.pure.} = enum
    None # Better than a nil Event, because it can be matched with case
    Key
    Resize
    Mouse

  Event* = object of RootObj
    kind*: EventType
    key*: Key
    xy*: (int, int) # Dimensions or position

  NimboxError* = object of Exception
  UnsupportedTerminalError* = object of NimboxError
  FailedToOpenTtyError* = object of NimboxError
  PipeTrapError* = object of NimboxError
  UnknownEventTypeError = object of NimboxError
  UnknownKeyError = object of NimboxError

  Color* = enum
    clrDefault = TB_DEFAULT
    clrBlack = TB_BLACK
    clrRed = TB_RED
    clrGreen = TB_GREEN
    clrYellow = TB_YELLOW
    clrBlue = TB_BLUE
    clrMagenta = TB_MAGENTA
    clrCyan = TB_CYAN
    clrWhite = TB_WHITE

  Style* = enum
    styNone = 0
    styBold = TB_BOLD
    styUnderline = TB_UNDERLINE
    styReverse = TB_REVERSE

  InputMode* = enum
    inpCurrent = TB_INPUT_CURRENT
    inpEsc = TB_INPUT_ESC
    inpAlt = TB_INPUT_ALT
    inpMouse = TB_INPUT_MOUSE

  OutputMode* = enum
    outCurrent = TB_OUTPUT_CURRENT
    outNormal = TB_OUTPUT_NORMAL
    out256 = TB_OUTPUT_256
    out216 = TB_OUTPUT_216
    outGrayscale = TB_OUTPUT_GRAYSCALE

proc `and`*[T](a, b: T): int =
  ord(a) or ord(b)

# Setup
proc newNimbox*(): Nimbox =
  result = Nimbox()
  case tbInit():
    of -1: raise newException(UnsupportedTerminalError, "")
    of -2: raise newException(FailedToOpenTtyError, "")
    of -3: raise newException(PipeTrapError, "")
    else: discard

proc `inputMode=`*(_: Nimbox, mode: int) =
  discard tbSelectInputMode(cast[cint](mode))

proc `inputMode=`*(nb: Nimbox, mode: InputMode) =
  nb.inputMode = ord(mode)

proc `outputMode=`*(_: Nimbox, mode: int) =
  discard tbSelectOutputMode(cast[cint](mode))

proc `outputMode=`*(nb: Nimbox, mode: OutputMode) =
  nb.outputMode = ord(mode)

proc shutdown*(_: Nimbox) =
  tbShutdown()

# Attributes
proc `width`*(_: Nimbox): int =
  tbWidth()

proc `height`*(_: Nimbox): int =
  tbHeight()

# Display procedures
proc clear*(_: Nimbox) =
  tbClear()

proc present*(_: Nimbox) =
  tbPresent()

proc print*[T](_: Nimbox, x, y: int, text: string,
               fg: Color, bg: Color, style: T) =
  var styleInt: int
  when style is Style:
    styleInt = ord(style)
  elif style is int:
    styleInt = style

  var
    fgInt = cast[uint16](ord(fg) or styleInt)
    bgInt = cast[uint16](ord(bg))
    yInt = cast[cint](y)

  for i, c in pairs(text):
    tbChangeCell(cast[cint](x + i), yInt, ord(c), fgInt, bgInt)

proc print*(nb: Nimbox, x, y: int, text: string,
            fg: Color = clrDefault, bg: Color = clrDefault) =
  print(nb, x, y, text, fg, bg, styNone)

proc `cursor=`*(_: Nimbox, xy: (int, int)) =
  tbSetCursor(cast[cint](xy[0]), cast[cint](xy[1]))

# proc `cursor=`*(nb: Nimbox, _: nil) =
#   nb.cursor = (TB_HIDE_CURSOR, TB_HIDE_CURSOR)

# Events
proc toEvent(kind: cint, evt: ref TbEvent): Event =
  var evtKind: EventType
  case kind:
    of TB_EVENT_KEY: evtKind = EventType.Key
    of TB_EVENT_RESIZE: evtKind = EventType.Resize
    of TB_EVENT_MOUSE: evtKind = EventType.Mouse

    of 0: evtKind = EventType.None # Timeout
    of -1: raise newException(NimboxError, "") # Unknown error
    else: raise newException(UnknownEventTypeError, "")

  # Keys
  var key = Key(mods: @[], ch: chr(evt.ch))
  if (evt.`mod` and TB_MOD_ALT) != 0:
      key.mods.add(Modifier.Alt)
  if (evt.`mod` and TB_MOD_MOTION) != 0:
      key.mods.add(Modifier.Motion)

  if key.ch == '\0' and (evtKind == EventType.Key or evtKind == EventType.Mouse):
    case evt.key:
      # Mouse
      of TB_KEY_MOUSE_LEFT: key.sym = Symbol.MouseLeft
      of TB_KEY_MOUSE_RIGHT: key.sym = Symbol.MouseRight
      of TB_KEY_MOUSE_MIDDLE: key.sym = Symbol.MouseMiddle
      of TB_KEY_MOUSE_RELEASE: key.sym = Symbol.MouseRelease
      of TB_KEY_MOUSE_WHEEL_UP: key.sym = Symbol.MouseWheelUp
      of TB_KEY_MOUSE_WHEEL_DOWN: key.sym = Symbol.MouseWheelDown

      # Function keys
      of TB_KEY_F1: key.sym = Symbol.F1
      of TB_KEY_F2: key.sym = Symbol.F2
      of TB_KEY_F3: key.sym = Symbol.F3
      of TB_KEY_F4: key.sym = Symbol.F4
      of TB_KEY_F5: key.sym = Symbol.F5
      of TB_KEY_F6: key.sym = Symbol.F6
      of TB_KEY_F7: key.sym = Symbol.F7
      of TB_KEY_F8: key.sym = Symbol.F8
      of TB_KEY_F9: key.sym = Symbol.F9
      of TB_KEY_F10: key.sym = Symbol.F10
      of TB_KEY_F11: key.sym = Symbol.F11
      of TB_KEY_F12: key.sym = Symbol.F12

      # Motion keys
      of TB_KEY_INSERT: key.sym = Symbol.Insert
      of TB_KEY_DELETE: key.sym = Symbol.Delete
      of TB_KEY_HOME: key.sym = Symbol.Home
      of TB_KEY_END: key.sym = Symbol.End
      of TB_KEY_PGUP: key.sym = Symbol.Pgup
      of TB_KEY_PGDN: key.sym = Symbol.Pgdn
      of TB_KEY_ARROW_UP: key.sym = Symbol.ArrowUp
      of TB_KEY_ARROW_DOWN: key.sym = Symbol.ArrowDown
      of TB_KEY_ARROW_LEFT: key.sym = Symbol.ArrowLeft
      of TB_KEY_ARROW_RIGHT: key.sym = Symbol.ArrowRight

      # Control + key
      of TB_KEY_CTRL_2:
        key.ch = '2'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_4:
        key.ch = '4'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_5:
        key.ch = '5'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_6:
        key.ch = '6'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_7:
        key.ch = '7'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_8:
        key.ch = '8'
        key.sym = Symbol.Backspace
        key.mods.add(Modifier.Ctrl)

      of TB_KEY_CTRL_A:
        key.ch = 'A'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_B:
        key.ch = 'B'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_C:
        key.ch = 'C'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_D:
        key.ch = 'D'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_E:
        key.ch = 'E'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_F:
        key.ch = 'F'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_G:
        key.ch = 'G'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_H:
        key.ch = 'H'
        key.sym = Symbol.Backspace
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_I:
        key.ch = 'I'
        key.sym = Symbol.Tab
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_J:
        key.ch = 'J'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_K:
        key.ch = 'K'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_L:
        key.ch = 'L'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_M:
        key.ch = 'M'
        key.sym = Symbol.Enter
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_N:
        key.ch = 'N'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_O:
        key.ch = 'O'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_P:
        key.ch = 'P'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_Q:
        key.ch = 'Q'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_R:
        key.ch = 'R'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_S:
        key.ch = 'S'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_T:
        key.ch = 'T'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_U:
        key.ch = 'U'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_V:
        key.ch = 'V'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_W:
        key.ch = 'W'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_X:
        key.ch = 'X'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_Y:
        key.ch = 'Y'
        key.mods.add(Modifier.Ctrl)
      of TB_KEY_CTRL_Z:
        key.ch = 'Z'
        key.mods.add(Modifier.Ctrl)

      # Spacing
      of TB_KEY_SPACE: key.sym = Symbol.Space

      # Control
      of TB_KEY_ESC:
        key.sym = Symbol.Escape
        key.ch = '['
        key.mods.add(Modifier.Ctrl)

      else: raise newException(UnknownKeyError, $evt.key)

  Event(
    kind: evtKind,
    key: key,
  )

proc peekEvent*(_: Nimbox, timeout: int): Event =
  var evt: ref TbEvent
  new evt

  toEvent(tbPeekEvent(evt, cast[cint](timeout)), evt)

proc pollEvent*(_: Nimbox): Event =
  var evt: ref TbEvent
  new evt
  toEvent(tbPollEvent(evt), evt)

