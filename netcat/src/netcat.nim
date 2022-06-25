import argparse
import std/[asyncnet, asyncdispatch, os, osproc, strformat, threadpool]

#[ Global Vars ]#
var 
  listen = false
  command = false
  upload = false
  execute = ""
  target = ""
  upload_destination = ""
  port = 0
  clients {.threadvar.}: seq[AsyncSocket]

proc client_handler(client: AsyncSocket) {.async.} =
  # check for upload
  if len(upload_destination) > 0:
    echo "Uploading file..."
    var file_buffer = ""
    while true:
      var data = await client.recv(1)
      if len(data) == 0:
        break
      file_buffer &= data
    
    # write file
    let f = open(upload_destination, fmWrite)
    defer: f.close()
    f.write(file_buffer)
  
  # check for command execution
  if len(execute) > 0:
    var (output, _) = execCmdEx(execute)
    await client.send(output)
    client.close()
  
  # check for command command shell
  if command:
    while true:
      # show simple prompt

      await client.send(&"nimcat:{getCurrentDir()}$ ")
      let line = await client.recvLine()
      if line.len == 0: break
      # if line.startsWith("cd"):
      #   setCurrentDir(line.split(" ")[1])
      # else:
      if line.startsWith("exit"): 
        client.close()
        echo "[!] Client disconnected"
        break
      else:
        var (output, _) = execCmdEx(line)
        await client.send(output)  
  
proc server_loop(target: string, port: int) {.async.} =
  # Handle incoming connections
  clients = @[]
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(port))
  server.listen()

  while true:
    let client = await server.accept()
    clients.add(client)
    echo "[+] Client Connected!"
    
    asyncCheck client_handler(client)

proc do_client_connect(socket: Asyncsocket, target: string, port: int) {.async.} = 
  await socket.connect(target, Port(port))
  echo(&"[+] Connected to {target}:{port}")
  while true:
    # hacky trick to recv data without newLine
    let line = await socket.recv(1)
    write(stdout, line)
    flushFile(stdout)
    
    

when isMainModule:
  var p = newParser:
    help("netcat replacement")
    flag("-l", "--listen", help="listen on [host]:[port] for incoming connections")
    flag("-c", "--command", help="initialize a command shell")
    option("-u", "--upload", help="upon receiving connection, upload a file and write to [destination]",
                          default=some(""))
    option("-e", "--execute", help="execute the given file upon receiving", default=some(""))
    option("-p", "--port", help="port to listen on", default=some("0"))
    option("-t", "--target", help="target host", default=some(""))

  try:
    let opts = p.parse()
    listen = opts.listen
    target = opts.target
    command = opts.command
    port = parseInt(opts.port)
    upload_destination = opts.upload
    execute = opts.execute
  except ShortCircuit as e:
    if e.flag == "argparse_help":
      echo p.help
      quit(1)
  except UsageError:
    stderr.writeLine(getCurrentExceptionMsg())
    quit(1)

  if not listen and target.len > 0 and port > 0:
    var socket = newAsyncSocket()
    asyncCheck do_client_connect(socket, target, port)
    var userBuffer = spawn stdin.readLine()
    while true:
      if userBuffer.isReady():
        var buf = ^userBuffer
        asyncCheck socket.send(buf & "\c\l")
        userBuffer = spawn stdin.readLine()
        if buf.startsWith("exit"):
          quit()
      asyncdispatch.poll()
  
  echo upload_destination
  if listen:
    echo "[+] Starting server..."
    echo &"[+] Listening on {target}:{port}..."
    asyncCheck server_loop(target, port)
    runForever()
