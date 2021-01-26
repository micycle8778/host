import asynchttpserver, asyncdispatch
import strutils, os, re, algorithm

# Embed some important resources
const directory_html = slurp"../assets/directory.html"
const file_html = slurp"../assets/file.html"

var server = newAsyncHttpServer()

let showHidden = false

proc combineDir(sub, tail: string): string =
  let tail = if tail[0] == '/': tail else: '/' & tail
  if sub[^1] == '/': sub[0..^2] & tail
  else: sub & tail

proc generateRequestHandlerFromFile(fileName: string): proc =
  proc requestHandler(req: Request) {.async.} =
    await req.respond(Http200, readFile(fileName))
  requestHandler

proc generateRequestHandlerFromDirectory(dir: string): proc =
  proc requestHandler(req: Request) {.async.} =
    # 0. Check that the user isn't requesting outside of our dir
    # 1. Check if we should invoke directory.html
    # 2. Check if requested file is a directory
    # 2a. No, send file
    # 3. If it is a directory, look for index.html
    # 3a. If found, send index.html
    # 3b. If not found, send directory.html
    # 4. If nothing is found, send a 404

    type Warning = enum
      wNoIndex = "no index.html found"
      wRequested = "directory.html requested"

    type File = object
      name, html: string
      isDir: bool

    proc newFile(name, html: string, isDir: bool): File =
      result.name = name
      result.html = html
      result.isDir = isDir

    var workingPath = combineDir(dir, req.url.path)
    workingPath = workingPath.replace(re"%20", " ")

    echo dir
    echo req.url.path
    echo workingPath
    echo()

    proc DirectoryHtmlRequested(query: seq[string]): bool =
      for q in query:
        if q.split(re"=")[0] == "ls":
          return true

      return false

    proc generateDirectoryDotHtml(warn: Warning): string =
      result = directory_html.replace("{warn}", $warn)
      result = result.replace("{path}", req.url.path.replace(re"%20", " "))
      var files: seq[File]
      var htmlToInsert: string

      for kind, path in walkDir(workingPath, true):
        if not showHidden and path[0] == '.':
          continue # Let's not show showHidden files if we aren't told to

        let truePath = combineDir(workingPath, path) # Path we need to use
        let reqPath = combineDir(req.url.path, path) # Path the client uses
        let isDir = dirExists(truePath) # isDir field for file obj

        var html = file_html.replace("{file_path}", reqPath)
        html = html.replace("{file_name}", if isDir: path & '/' else: path)

        files.add(newFile(path, html, isDir))

      files.sort do (x, y: File) -> int:
        if x.isDir and not y.isDir:
          -1
        elif y.isDir and not x.isDir:
          1
        else:
          cmp(x.name.toLowerAscii, y.name.toLowerAscii)

      for f in files:
        htmlToInsert = htmlToInsert & f.html

      result = result.replace("{files}", htmlToInsert)

    if req.url.path.contains(".."):
      await req.respond(Http400, "Error 400: why are you using `..`?")

    elif not (req.url.query == "") and
         DirectoryHtmlRequested(req.url.query.split("&")):
      if fileExists(workingPath):
        workingPath = parentDir(workingPath)
      await req.respond(Http200, generateDirectoryDotHtml(wRequested))

    elif dirExists(workingPath):
      let indexPath = combineDir(workingPath, "/index.html")
      if fileExists(indexPath):
        await req.respond(Http200, readFile(indexPath))
      else:
        await req.respond(Http200, generateDirectoryDotHtml(wNoIndex))

    elif fileExists(workingPath):
      await req.respond(Http200, readFile(workingPath))

    else:
      await req.respond(Http404, "Could not find file " & req.url.path)

  requestHandler

if paramCount() > 0:
  let f = paramStr(1)
  if fileExists(f):
    echo "Starting server!"
    waitFor server.serve(Port(8080), generateRequestHandlerFromFile(f))
  elif dirExists(f):
    echo "Starting server!"
    waitFor server.serve(Port(8080), generateRequestHandlerFromDirectory(f))
  else:
    echo f, " doesn't exist!"
else:
  echo "You need to the filename to serve."

