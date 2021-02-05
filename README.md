# host
host is a simple, static, web server for easily hosting files over LAN.
host makes no security guarantees, so it should only be used on a LAN that you
trust (no port forwarding and probably no coffee shops).

## why host?
host offers files over http instead of ftp or ssh, making files much more
accessible to any device with a browser (which is every device). your browser
can also render html, svgs, pictures, videos, pdfs, etc. without the need of
additional software. of cource, host is read-only, so if you need your clients
to write to your server too, it's better to use real file sharing
software/protocols. any linux box should have built-in support for sftp.

## how do i get host?
host is written in [Nim](https://nim-lang.org) and uses pure Nim standard
libraries, meaning the only thing you need to build host is the Nim compiler.
to build and install the project:

1. install Nim ~~(try your package manager, `sudo pacman -Syu nim` or
`sudo apt install nim`)~~ after some
[helpful people](https://old.reddit.com/r/nim/comments/l74l95/host_is_a_simple_static_web_server_for_lan/gl4rgbk/)
told me that package managers have a tendency of holding outdated versions of
Nim, it is now recommended by this README to get Nim from
[choosenim](https://github.com/dom96/choosenim).

2. install host via running `nimble install host`

to uninstall, use `nimble uninstall host`

# using host

## quick examples

host directory we are in
```
host .
```

host it on port 9001

```
host --port 9001 .
```

host a cool file
```
host my-cool-website.html
```

host something from stdin
```
find | host
```

learn more about host
```
host --help
man host # Linux only!
```

## usage

```
host --help
```

### file/directory mode


```
host [-h] [-q] FILE
```

```
host [--hidden] [--quiet] [--output OUTPUT_FILE] [--port PORT] FILE
```

### stdin mode

```
host -i [-h] [-q]
```

```
host --stdin [--hidden] [--quiet] [--output OUTPUT_FILE] [--port PORT]
```

## description

once host starts, you'll see an IP address and a port. that ip and port combo
need to be used to access host on other devices. take out a phone (or other
device on the same wifi network) and type into the url bar `IP_ADDRESS:PORT`.
if you want to access host from the same machine that is running host, simply
point your web browser of choice to `localhost:PORT`.

### modes

host runs in three different modes: file, directory, and stdin

in file mode, host will respond to all requests with the file inputted as the 
`FILE` parameter, regardless of the path, body, or headers sent. every time
host handles a request in file mode, host will read the file first, then send
it. if this isn't behavior you want, you can use stdin mode
(`cat FILE | host`)

in stdin mode, host will do the same thing as if it was in stdin mode, however,
host will send back the data it got from standard in, instead of the file from
the `FILE` parameter.

in directory mode, host will act like a real server. host will read the path
of any request and act accordingly. if the path points to a file, then host
will send the file back. if the path is a directory, host searches for a
`index.html` in that directory. if host does not find `index.html`, host
will send back a view of all the file and folders in the directory
(otherwise known as `directory.html`). if the `ls` query is sent (so host sees
IP:PORT/path/to/foo/bar/?ls), host will automatically send the directory view 
without checking if the directory has a `index.html` if the path points to 
nothing (in other words, a 404), host will send back a directory view of the 
parent directory (so `IP:PORT/path/to/nothing/404` will return the directory 
view of `path/to/nothing`).

these modes are selected based on the settings host is launched with. if there
is a stdin option (`host -i ...`, `host --stdin ...`), host will start in stdin
mode. if host is given a file for the `FILE` parameter, host will start in file
mode. if host is given a directory for the `FILE` parameter, host will start in
directory mode.

### mimetypes

the way host handles mimetypes depends on the mode host is in. if host is in
directory or file mode, host will respond with the mimetype appropriate for
the file, based on the file extension, with the default being `text/plain`.
if host is started in stdin mode, host will respond with the `text/plain`
mimetype.

using the `--mime` option, and if host is in file or stdin mode, host will
start with the mimetype described. *note: the `--mime` option expects file
extentions, so use `html` instead of `text/html`, `txt` instead of 
`text/plain`, etc*

## options

**--help**

shows host's help text

**-h**, **--hidden**

shows hidden files (the files that start with `.`). this is only useful in
directory mode.

**-i**, **--stdin**

starts host in stdin mode. read the description/modes section for more info

**--mime [mimetype]**

sets the mimetype host will send. `[mimetype]` must be a file extension, not
a normal mimetype. only useful in file and stdin modes. read 
description/mimetypes for more info

**--output [file]**

sets the file host will log requests to.

**--port [port]**

sets the port host will run on

**-q**, **--quiet**

prevents logging
