when defined(linux):
  {.passl: "-Wl,-Bstatic -ltermbox -Wl,-Bdynamic", emit: "typedef struct tb_event tb_event;".}
else:
  {.passl: "-ltermbox", emit: "typedef struct tb_event tb_event;".}

const
  TB_KEY_F1* = (0x0000FFFF - 0)
  TB_KEY_F2* = (0x0000FFFF - 1)
  TB_KEY_F3* = (0x0000FFFF - 2)
  TB_KEY_F4* = (0x0000FFFF - 3)
  TB_KEY_F5* = (0x0000FFFF - 4)
  TB_KEY_F6* = (0x0000FFFF - 5)
  TB_KEY_F7* = (0x0000FFFF - 6)
  TB_KEY_F8* = (0x0000FFFF - 7)
  TB_KEY_F9* = (0x0000FFFF - 8)
  TB_KEY_F10* = (0x0000FFFF - 9)
  TB_KEY_F11* = (0x0000FFFF - 10)
  TB_KEY_F12* = (0x0000FFFF - 11)
  TB_KEY_INSERT* = (0x0000FFFF - 12)
  TB_KEY_DELETE* = (0x0000FFFF - 13)
  TB_KEY_HOME* = (0x0000FFFF - 14)
  TB_KEY_END* = (0x0000FFFF - 15)
  TB_KEY_PGUP* = (0x0000FFFF - 16)
  TB_KEY_PGDN* = (0x0000FFFF - 17)
  TB_KEY_ARROW_UP* = (0x0000FFFF - 18)
  TB_KEY_ARROW_DOWN* = (0x0000FFFF - 19)
  TB_KEY_ARROW_LEFT* = (0x0000FFFF - 20)
  TB_KEY_ARROW_RIGHT* = (0x0000FFFF - 21)
  TB_KEY_MOUSE_LEFT* = (0x0000FFFF - 22)
  TB_KEY_MOUSE_RIGHT* = (0x0000FFFF - 23)
  TB_KEY_MOUSE_MIDDLE* = (0x0000FFFF - 24)
  TB_KEY_MOUSE_RELEASE* = (0x0000FFFF - 25)
  TB_KEY_MOUSE_WHEEL_UP* = (0x0000FFFF - 26)
  TB_KEY_MOUSE_WHEEL_DOWN* = (0x0000FFFF - 27)


const
  TB_KEY_CTRL_TILDE* = 0x00000000
  TB_KEY_CTRL_2* = 0x00000000
  TB_KEY_CTRL_A* = 0x00000001
  TB_KEY_CTRL_B* = 0x00000002
  TB_KEY_CTRL_C* = 0x00000003
  TB_KEY_CTRL_D* = 0x00000004
  TB_KEY_CTRL_E* = 0x00000005
  TB_KEY_CTRL_F* = 0x00000006
  TB_KEY_CTRL_G* = 0x00000007
  TB_KEY_BACKSPACE* = 0x00000008
  TB_KEY_CTRL_H* = 0x00000008
  TB_KEY_TAB* = 0x00000009
  TB_KEY_CTRL_I* = 0x00000009
  TB_KEY_CTRL_J* = 0x0000000A
  TB_KEY_CTRL_K* = 0x0000000B
  TB_KEY_CTRL_L* = 0x0000000C
  TB_KEY_ENTER* = 0x0000000D
  TB_KEY_CTRL_M* = 0x0000000D
  TB_KEY_CTRL_N* = 0x0000000E
  TB_KEY_CTRL_O* = 0x0000000F
  TB_KEY_CTRL_P* = 0x00000010
  TB_KEY_CTRL_Q* = 0x00000011
  TB_KEY_CTRL_R* = 0x00000012
  TB_KEY_CTRL_S* = 0x00000013
  TB_KEY_CTRL_T* = 0x00000014
  TB_KEY_CTRL_U* = 0x00000015
  TB_KEY_CTRL_V* = 0x00000016
  TB_KEY_CTRL_W* = 0x00000017
  TB_KEY_CTRL_X* = 0x00000018
  TB_KEY_CTRL_Y* = 0x00000019
  TB_KEY_CTRL_Z* = 0x0000001A
  TB_KEY_ESC* = 0x0000001B
  TB_KEY_CTRL_LSQ_BRACKET* = 0x0000001B
  TB_KEY_CTRL_3* = 0x0000001B
  TB_KEY_CTRL_4* = 0x0000001C
  TB_KEY_CTRL_BACKSLASH* = 0x0000001C
  TB_KEY_CTRL_5* = 0x0000001D
  TB_KEY_CTRL_RSQ_BRACKET* = 0x0000001D
  TB_KEY_CTRL_6* = 0x0000001E
  TB_KEY_CTRL_7* = 0x0000001F
  TB_KEY_CTRL_SLASH* = 0x0000001F
  TB_KEY_CTRL_UNDERSCORE* = 0x0000001F
  TB_KEY_SPACE* = 0x00000020
  TB_KEY_BACKSPACE2* = 0x0000007F
  TB_KEY_CTRL_8* = 0x0000007F


const
  TB_MOD_ALT* = 0x00000001
  TB_MOD_MOTION* = 0x00000002


const
  TB_DEFAULT* = 0x00000000
  TB_BLACK* = 0x00000001
  TB_RED* = 0x00000002
  TB_GREEN* = 0x00000003
  TB_YELLOW* = 0x00000004
  TB_BLUE* = 0x00000005
  TB_MAGENTA* = 0x00000006
  TB_CYAN* = 0x00000007
  TB_WHITE* = 0x00000008


const
  TB_BOLD* = 0x00000100
  TB_UNDERLINE* = 0x00000200
  TB_REVERSE* = 0x00000400


type
  TbCell* {.importc: "tb_cell", header: "termbox.h".} = object
    ch* {.importc: "ch".}: uint32
    fg* {.importc: "fg".}: uint16
    bg* {.importc: "bg".}: uint16


const
  TB_EVENT_KEY* = 1
  TB_EVENT_RESIZE* = 2
  TB_EVENT_MOUSE* = 3


type
  TbEvent* {.importc: "tb_event", header: "termbox.h".} = object
    `type`* {.importc: "type".}: uint8
    `mod`* {.importc: "mod".}: uint8
    key* {.importc: "key".}: uint16
    ch* {.importc: "ch".}: uint32
    w* {.importc: "w".}: int32
    h* {.importc: "h".}: int32
    x* {.importc: "x".}: int32
    y* {.importc: "y".}: int32



const
  TB_EUNSUPPORTED_TERMINAL* = - 1
  TB_EFAILED_TO_OPEN_TTY* = - 2
  TB_EPIPE_TRAP_ERROR* = - 3


proc tbInit*(): cint {.importc: "tb_init", header: "termbox.h".}
proc tbInitFile*(name: cstring): cint {.importc: "tb_init_file", header: "termbox.h".}
proc tbInitFd*(inout: cint): cint {.importc: "tb_init_fd", header: "termbox.h".}
proc tbShutdown*() {.importc: "tb_shutdown", header: "termbox.h".}

proc tbWidth*(): cint {.importc: "tb_width", header: "termbox.h".}
proc tbHeight*(): cint {.importc: "tb_height", header: "termbox.h".}

proc tbClear*() {.importc: "tb_clear", header: "termbox.h".}
proc tbSetClearAttributes*(fg: uint16; bg: uint16) {.
    importc: "tb_set_clear_attributes", header: "termbox.h".}

proc tbPresent*() {.importc: "tb_present", header: "termbox.h".}
const
  TB_HIDE_CURSOR* = - 1


proc tbSetCursor*(cx: cint; cy: cint) {.importc: "tb_set_cursor", header: "termbox.h".}

proc tbPutCell*(x: cint; y: cint; cell: ref TbCell) {.importc: "tb_put_cell",
    header: "termbox.h".}
proc tbChangeCell*(x: cint; y: cint; ch: uint32; fg: uint16; bg: uint16) {.
    importc: "tb_change_cell", header: "termbox.h".}

proc tbBlit*(x: cint; y: cint; w: cint; h: cint; cells: ref TbCell) {.importc: "tb_blit",
    header: "termbox.h".}

proc tbCellBuffer*(): ref TbCell {.importc: "tb_cell_buffer", header: "termbox.h".}
const
  TB_INPUT_CURRENT* = 0
  TB_INPUT_ESC* = 1
  TB_INPUT_ALT* = 2
  TB_INPUT_MOUSE* = 4


proc tbSelectInputMode*(mode: cint): cint {.importc: "tb_select_input_mode",
                                        header: "termbox.h".}
const
  TB_OUTPUT_CURRENT* = 0
  TB_OUTPUT_NORMAL* = 1
  TB_OUTPUT_256* = 2
  TB_OUTPUT_216* = 3
  TB_OUTPUT_GRAYSCALE* = 4


proc tbSelectOutputMode*(mode: cint): cint {.importc: "tb_select_output_mode",
    header: "termbox.h".}

proc tbPeekEvent*(event: ref TbEvent; timeout: cint): cint {.importc: "tb_peek_event",
    header: "termbox.h".}

proc tbPollEvent*(event: ref TbEvent): cint {.importc: "tb_poll_event",
    header: "termbox.h".}

const
  TB_EOF* = - 1

proc tbUtf8CharLength*(c: char): cint {.importc: "tb_utf8_char_length",
                                    header: "termbox.h".}
proc tbUtf8CharToUnicode*(`out`: ref uint32; c: cstring): cint {.
    importc: "tb_utf8_char_to_unicode", header: "termbox.h".}
proc tbUtf8UnicodeToChar*(`out`: cstring; c: uint32): cint {.
    importc: "tb_utf8_unicode_to_char", header: "termbox.h".}