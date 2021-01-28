# host
host is a simple, static, web server for easily hosting files over LAN.
host makes no security guarantees, so it should only be used on a LAN that you trust
(no port forwarding and probably no coffee shops).

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
to build and install the project on linux operating systems:

1. install Nim (try your package manager, `pacman -Syu nim` or 
`sudo apt install nim`)

2. clone the git repo `git clone https://github.com/RainbowAsteroids/host`

3. enter into the source code directory `cd host`

4. run the copy task as root `sudo nimble copy`

to uninstall, just run the uncopy task as root `sudo nimble uncopy`.
