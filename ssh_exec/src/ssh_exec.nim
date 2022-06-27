import ssh2
import asyncdispatch

var 
  ip = "127.0.0.1"
  port = 22
  user = "m4ul3r"
  password = ""

proc main() {.async.} =
  var client = newSSHClient()
  defer: client.disconnect()
  await client.connect(ip, user, port.Port, password=password)
  echo await client.execCommand("whoami")
  echo await client.execCommand("uptime")

when isMainModule:
  waitFor main()
