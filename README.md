# host
host is a simple, static, web server for easily hosting files over LAN.
host makes no security guarantees, so it should only be used on a LAN that you
trust (no port forwarding and probably no coffee shops).

## why host?
host offers files over http instead of ftp or ssh, making files much more
accessible to any device with a browser (which is every device). your browser
can also render html, svgs, pictures, videos, pdfs, etc. without the need of
additional software. ofcource, host is read-only, so if you need your clients
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

2. clone the git repo `git clone https://github.com/RainbowAsteroids/host`
or download this repo as a zip (download as a zip makes it less convenient
to update, however.)

3. enter into the source code directory `cd host`

4. install host via running `nimble install`

to uninstall, use `nimble uninstall host`

## using host

to quickly host a directory, just type the following into the terminal:
```
host .
```

you can change the port via the `--port` switch:
```
host --port 9001 .
```

you can even host files or from stdin
```
host index.html
```
```
echo "<h1>my first website</h1>" | host
```

at any point, you can look at the stuff being hosted via opening your web
browser and typing in `localhost:PORT` on the machine running host or by
taking your phone or other device on the same network and typing in the
local IP of the host machine, `192.168.0.254:PORT`.

if host is running in directory mode, a directory view can be seen if
the directory does not contain a `index.html` file or if the user
visits the directory with `?ls` at the end of the url.
