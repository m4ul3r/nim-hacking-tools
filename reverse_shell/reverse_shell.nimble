# Package

version       = "0.1.0"
author        = "m4ul3r"
description   = "reverse shell based off of https://trustfoundry.net/writing-basic-offensive-tooling-in-nim/"
license       = "MIT"
srcDir        = "src"
bin           = @["reverse_shell"]

# Dependencies

requires "nim >= 1.6.6", "argparse"
