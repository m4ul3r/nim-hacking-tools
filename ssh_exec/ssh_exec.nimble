# Package

version       = "0.1.0"
author        = "m4ul3r"
description   = "ssh client example"
license       = "MIT"
srcDir        = "src"
bin           = @["ssh_exec"]


# Dependencies

requires "nim >= 1.6.6", "ssh2"
