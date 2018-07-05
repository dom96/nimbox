include nimbox/termbox

import unicode

type
  Nimbox* = object of RootObj

  Colors256* = range[0..255]

  Modifier* {.pure.} = enum
    Ctrl
    Alt

  Symbol* {.pure.} = enum
    Character

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
    Up
    Down
    Left
    Right

    Escape
    Space
    Tab
    Enter
    Backspace

  Mouse* {.pure.} = enum
    Motion
    Left
    Right
    Middle
    Release
    WheelUp
    WheelDown

  EventType* {.pure.} = enum
    None # Better than a nil Event, because it can be matched with case
    Key
    Resize
    Mouse

  Event* = object of RootObj
    case kind*: EventType
    of EventType.Key:
      mods*: seq[Modifier]
      sym*: Symbol
      ch*: char
    of EventType.Mouse:
      action*: Mouse
      x*, y*: uint
    of EventType.Resize:
      w*, h*: uint
    of EventType.None: discard

  NimboxError* = object of Exception
  UnsupportedTerminalError* = object of NimboxError
  FailedToOpenTtyError* = object of NimboxError
  PipeTrapError* = object of NimboxError
  UnknownEventTypeError = object of NimboxError
  UnknownKeyError = object of NimboxError
  UnknownMouseActionError = object of NimboxError


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

  var i = 0
  for c in runes(text):
    tbChangeCell(cast[cint](x + i), yInt, c.uint32, fgInt, bgInt)
    i.inc()

proc print*[T](_: Nimbox, x, y: int, text: string,
               fg: Colors256, bg: Colors256, style: T = styNone) =
  var styleInt: int
  when style is Style:
    styleInt = ord(style)
  elif style is int:
    styleInt = style

  var
    fgInt = cast[uint16](fg or styleInt)
    bgInt = cast[uint16](bg)
    yInt = cast[cint](y)

  var i = 0
  for c in runes(text):
    tbChangeCell(cast[cint](x + i), yInt, c.uint32, fgInt, bgInt)
    i.inc()

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

  case evtKind:
    of EventType.Key:
      var
        mods: seq[Modifier] = @[]
        ch = chr(evt.ch)
        sym = Symbol.Character

      if (evt.`mod` and TB_MOD_ALT) != 0:
          mods.add(Modifier.Alt)

      if ch == '\0':
        case evt.key:
          # Function keys
          of TB_KEY_F1: sym = Symbol.F1
          of TB_KEY_F2: sym = Symbol.F2
          of TB_KEY_F3: sym = Symbol.F3
          of TB_KEY_F4: sym = Symbol.F4
          of TB_KEY_F5: sym = Symbol.F5
          of TB_KEY_F6: sym = Symbol.F6
          of TB_KEY_F7: sym = Symbol.F7
          of TB_KEY_F8: sym = Symbol.F8
          of TB_KEY_F9: sym = Symbol.F9
          of TB_KEY_F10: sym = Symbol.F10
          of TB_KEY_F11: sym = Symbol.F11
          of TB_KEY_F12: sym = Symbol.F12

          # Motion keys
          of TB_KEY_INSERT: sym = Symbol.Insert
          of TB_KEY_DELETE: sym = Symbol.Delete
          of TB_KEY_HOME: sym = Symbol.Home
          of TB_KEY_END: sym = Symbol.End
          of TB_KEY_PGUP: sym = Symbol.Pgup
          of TB_KEY_PGDN: sym = Symbol.Pgdn
          of TB_KEY_ARROW_UP: sym = Symbol.Up
          of TB_KEY_ARROW_DOWN: sym = Symbol.Down
          of TB_KEY_ARROW_LEFT: sym = Symbol.Left
          of TB_KEY_ARROW_RIGHT: sym = Symbol.Right

          # Control + key
          of TB_KEY_CTRL_2:
            ch = '2'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_4:
            ch = '4'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_5:
            ch = '5'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_6:
            ch = '6'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_7:
            ch = '7'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_8:
            ch = '8'
            sym = Symbol.Backspace
            mods.add(Modifier.Ctrl)

          of TB_KEY_CTRL_A:
            ch = 'A'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_B:
            ch = 'B'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_C:
            ch = 'C'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_D:
            ch = 'D'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_E:
            ch = 'E'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_F:
            ch = 'F'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_G:
            ch = 'G'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_H:
            ch = 'H'
            sym = Symbol.Backspace
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_I:
            ch = 'I'
            sym = Symbol.Tab
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_J:
            ch = 'J'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_K:
            ch = 'K'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_L:
            ch = 'L'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_M:
            ch = 'M'
            sym = Symbol.Enter
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_N:
            ch = 'N'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_O:
            ch = 'O'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_P:
            ch = 'P'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_Q:
            ch = 'Q'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_R:
            ch = 'R'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_S:
            ch = 'S'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_T:
            ch = 'T'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_U:
            ch = 'U'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_V:
            ch = 'V'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_W:
            ch = 'W'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_X:
            ch = 'X'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_Y:
            ch = 'Y'
            mods.add(Modifier.Ctrl)
          of TB_KEY_CTRL_Z:
            ch = 'Z'
            mods.add(Modifier.Ctrl)

          # Spacing
          of TB_KEY_SPACE: sym = Symbol.Space

          # Control
          of TB_KEY_ESC:
            sym = Symbol.Escape
            ch = '['
            mods.add(Modifier.Ctrl)

          else: raise newException(UnknownKeyError, $evt.key)

      Event(kind: EventType.Key, mods: mods, ch: ch, sym: sym)

    of EventType.Mouse:
      var action: Mouse
      if (evt.`mod` and TB_MOD_MOTION) != 0:
        action = Mouse.Motion

      case evt.key:
        # Mouse
        of TB_KEY_MOUSE_LEFT: action = Mouse.Left
        of TB_KEY_MOUSE_RIGHT: action = Mouse.Right
        of TB_KEY_MOUSE_MIDDLE: action = Mouse.Middle
        of TB_KEY_MOUSE_RELEASE: action = Mouse.Release
        of TB_KEY_MOUSE_WHEEL_UP: action = Mouse.WheelUp
        of TB_KEY_MOUSE_WHEEL_DOWN: action = Mouse.WheelDown
        else: raise newException(UnknownMouseActionError, $evt.key)

      Event(kind: EventType.Mouse, action: action,
            x: cast[uint](evt.x), y: cast[uint](evt.y))

    of EventType.Resize:
      Event(kind: EventType.Resize, w: cast[uint](evt.w), h: cast[uint](evt.h))

    of EventType.None:
      Event(kind: EventType.None)

proc peekEvent*(_: Nimbox, timeout: int): Event =
  var evt: ref TbEvent
  new evt

  toEvent(tbPeekEvent(evt, cast[cint](timeout)), evt)

proc pollEvent*(_: Nimbox): Event =
  var evt: ref TbEvent
  new evt
  toEvent(tbPollEvent(evt), evt)

