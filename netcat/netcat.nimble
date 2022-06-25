# Package

version       = "0.1.0"
author        = "m4ul3r"
description   = "netcat replacement based off of blackhat python"
license       = "MIT"
srcDir        = "src"
bin           = @["netcat"]


# Dependencies

requires "nim >= 1.6.6", "argparse"
