# Package

version       = "0.1.0"
author        = "m4ul3r"
description   = "fuzz lfi"
license       = "MIT"
srcDir        = "src"
bin           = @["fuzz_lfi"]


# Dependencies

requires "nim >= 1.6.6", "argparse", "puppy", "q"
