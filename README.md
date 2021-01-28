# host
host is a simple, static, web server for easily hosting files over LAN.
host makes no security guarantees, so it should only be used on a LAN that you trust
(no port forwarding and probably no coffee shops).

## why host?
host offers files over http instead of ftp or ssh, making files much more accessible
to any device with a browser (which is every device). your browser can also render html, svgs,
pictures, videos, pdfs, etc. without the need of additional software. ofcource, host is read-only,
so if you need your clients to write to your server too, it's better to use real
file sharing software/protocols. any linux box should have built-in support sftp.

## how do i get host?
host is written in [Nim](https://nim-lang.org) and uses pure Nim standard libraries, meaning
the only thing you need to build host is the Nim compiler. you can see build instructions in
[BUILDING.md](BUILDING.md).

you can also get the prebuilds of host in the
[releases](https://github.com/RainbowAsteroids/host/releases) section.

installing host is a matter of moving the executable into your PATH and the man pages into the
correct location.
