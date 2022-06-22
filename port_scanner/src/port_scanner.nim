import os, net, strformat

when isMainModule:
  if paramCount() != 1:
    quit(&"Usage: {paramStr(0)} <host>")
  
  var 
    target = paramStr(1)
    open_ports = newSeq[int]()

  for i in 1 .. 65535:
    try:
      let socket = newSocket()
      socket.connect(target, Port(i))
      socket.close()
      echo(&"[+] {$i} is open")
      open_ports.add(i)
    except:
      continue

  write(stdout, "\n[+] Open ports: ")
  for i in open_ports.low .. open_ports.high:
    if i == open_ports.high:
      writeLine(stdout, &"{open_ports[i]}")
    else:
      write(stdout, &"{open_ports[i]},")