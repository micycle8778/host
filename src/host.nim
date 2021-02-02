import asynchttpserver, asyncdispatch
import strutils, os, re, algorithm, tables
import mimetypes, strformat, parseopt, parseutils
import net

# Embed some important resources
const directory_html = slurp"../assets/directory.html"
const file_html = slurp"../assets/file.html"
const help_text = """Usage: host [options] [file]

Options:
  --help              : Show this help text
  -h, --hidden        : Shows hidden files.
  -i, --stdin         : Host from stdin. Ignore file parameter.
  --output [file]     : Output request logs to a file.
  --port [port]       : Host on a specific port (default 8080)
  -q, --quiet         : Hide request logs."""

type
  InputType = enum
    itFile,
    itDir,
    itStdIn

  Input = object
    case inputType: InputType
    of itFile, itDir: path: string
    of itStdIn: str: string

type
  RequestLogType = enum
    rltEcho, rltNone, rltFile

  RequestLogState = object
    case rlType: RequestLogType
    of rltFile: file: File
    else: discard

var showHidden = false
var requestLogState = RequestLogState(rlType: rltEcho)

proc combineDir(sub, tail: string): string =
  let tail = if tail[0] == '/': tail else: '/' & tail
  if sub[^1] == '/': sub[0..^2] & tail
  else: sub & tail

proc logRequest(req: Request) =
  if requestLogState.rlType != rltNone:
    let log = fmt"req: {req.url.path} ; by: {req.hostname}"
    if requestLogState.rlType == rltFile:
      requestLogState.file.write(log & '\n')
    else:
      echo log

proc generateRequestHandlerFromString(data: string): proc =
  proc requestHandler(req: Request) {.async.} =
    req.logRequest()
    await req.respond(Http200, data)
  requestHandler

proc generateRequestHandlerFromFile(fileName: string): proc =
  proc requestHandler(req: Request) {.async.} =
    req.logRequest()
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

    proc generateHeader(mime: string): HttpHeaders =
      [("content-type", fmt"{mime}; charset=UTF-8")].newHttpHeaders

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

    req.logRequest()

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
      await req.respond(Http400, "Error 400: why are you using `..`?",
                        headers = generateHeader("text/plain"))

    elif not (req.url.query == "") and
         DirectoryHtmlRequested(req.url.query.split("&")):
      if fileExists(workingPath):
        workingPath = parentDir(workingPath)
      await req.respond(Http200, generateDirectoryDotHtml(wRequested),
                        headers = generateHeader("text/html"))

    elif dirExists(workingPath):
      let indexPath = combineDir(workingPath, "/index.html")
      if fileExists(indexPath):

        await req.respond(Http200, readFile(indexPath),
                          headers = generateHeader("text/html"))
      else:
        await req.respond(Http200, generateDirectoryDotHtml(wNoIndex),
                          headers = generateHeader("text/html"))

    elif fileExists(workingPath):
      let m = newMimeTypes()
      await req.respond(Http200, readFile(workingPath),
                        headers = generateHeader(m.getMimeType(workingPath.splitFile.ext)))
    else:
      await req.respond(Http404, "Could not find file " & req.url.path,
                        headers=generateHeader("text/plain"))

  requestHandler

proc main(input: Input, port: Natural) =
  var server = newAsyncHttpServer()

  echo "Starting server with IP ", $getPrimaryIPAddr(), " and port ", port
  case input.inputType:
    of itFile:
      waitFor server.serve(Port(port),
                           generateRequestHandlerFromFile(input.path))
    of itDir:
      waitFor server.serve(Port(port),
                           generateRequestHandlerFromDirectory(input.path))
    of itStdIn:
      waitFor server.serve(Port(port),
                           generateRequestHandlerFromString(input.str))

when isMainModule:
  var port = 8080
  var stdinMode = false
  var filename: string

  var p = initOptParser(shortNoVal = {'i', 'h', 'q'},
                        longNoVal = @["stdin", "hidden", "quiet"])
  for kind, key, val in p.getOpt():
    case kind
      of cmdArgument:
        filename = key
      else:
        case key
          of "stdin", "i":
            stdinMode = true
          of "hidden", "h":
            showHidden = true
          of "quiet", "q":
            requestLogState = RequestLogState(rlType: rltNone)
          of "output":
            requestLogState = RequestLogState(rlType: rltFile,
                                              file: open(val, fmWrite))
          of "port":
            discard parseInt(val, port)
          else: # or `of "help"`
            if key != "help": echo fmt"I didn't understand option `{key}`!\n"
            echo help_text
            quit()

  if stdinMode:
    main(Input(inputType: itStdIn, str: stdin.readAll()), port.Natural)
  else:
    if filename == "":
      echo "No filename passed in!\n"
      echo help_text
    elif fileExists(filename):
      main(Input(inputType: itFile, path: filename), port.Natural)
    elif dirExists(filename):
       main(Input(inputType: itDir, path: filename), port.Natural)
    else:
      echo fmt"File {filename} not found!"

