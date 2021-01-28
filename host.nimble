# Package

version       = "1.0.0"
author        = "Rainbow Asteroids"
description   = "A program to staticlly host files or directories over HTTP"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["host"]


# Dependencies

requires "nim >= 1.4.2"

# Tasks

task release, "Builds the release version of host and puts it a output/ directory":
  mkDir("output")
  exec("nim c -d:release --outdir:output src/host")

before install:
  echo "Installing through Nimble will not get you the man page. Please head to the GitHub to get it."
  echo "This is a binary nimble package. Make sure you have your NIMBLE_DIR/bin in your path."

before copy:
  if system.hostOS != "linux":
    echo "The copy task only supports linux operating systems."
    return false

  if not fileExists("output/host"):
    echo "Release build appears not to exist. I'll handle that for you."
    exec("nimble release")
  if not fileExists("man/man1/host.1"):
    echo "Man page doesn't exist. What did you do with it?"
    return false

task copy, "Copies the man pages and output/host to their proper places for installation":
  cpFile("output/host", "/usr/bin/host")
  cpDir("man", "/usr/share/man")

before uncopy:
  if system.hostOS != "linux":
    echo "The uncopy task only supports linux operating systems."
    return false

# Those damned nimble devs took "delete" and "remove"!
task uncopy, "The reverse of the copy task.":
  if fileExists("/usr/bin/host"):
    rmFile("/usr/bin/host")
  else:
    echo "host binary doesn't exist. Skipping!"

  if fileExists("/usr/share/man/man1/host.1"):
    rmFile("/usr/share/man/man1/host.1")
  else:
    echo "host man page doesn't exist. Skipping!"
