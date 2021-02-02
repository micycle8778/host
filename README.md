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

4. run the copy task as root `sudo nimble copy` if you're on linux (maybe
MacOS?) systems. otherwise, do `nimble release` to build a release version of
host. this build will be in the `build` directory.

to uninstall (on Linux), just run the uncopy task as root `sudo nimble uncopy`.
