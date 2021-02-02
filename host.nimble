# Package

version       = "1.2.0"
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

after install:
  if system.hostOS == "linux":
    echo "Adding man pages to ~/.nimble/man..."

    if not dirExists($getHomeDir() & "/.nimble/man"):
      cpDir("man", $getHomeDir() & "/.nimble/man")
    echo "Man page installed!"

    if not staticExec("manpath").contains(".nimble/man"):
      echo "~/.nimble/man isn't in your manpath! Be sure fix that for access to the host man page."
