# netcat

nim implmentation of the netcat client from [bhp3](https://github.com/EONRaider/blackhat-python3/blob/0083ec168b6782f7275a692d2bc9101d0d1df407/chapter02/bhnet.py#L18)

The server allows clients to change the current working directory of the server, but the change is reflected across all clients.

The asynchronous sockets example used comes from [nim in action](https://ssalewski.de/nimprogramming.html#_a_chat_server_application)

### TODO
- Implement upload completely