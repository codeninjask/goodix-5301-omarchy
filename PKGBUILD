# Maintainer: OpenAI Codex (experimental 27c6:5301 port)
# Based on J0UH/goodix-5201-linux and libfprint.

pkgname=libfprint-goodix-5301
pkgver=0.1.0
pkgrel=4
pkgdesc="Experimental libfprint driver for Goodix 27c6:5301 on Dell Inspiron 5570"
arch=(x86_64)
url="https://github.com/codeninjask/goodix-5301-omarchy"
license=(LGPL-2.1-or-later)
depends=(gcc-libs glib2 glibc libgudev libgusb opencv openssl pixman)
makedepends=(glib2-devel gobject-introspection meson ninja)
provides=("libfprint=1.94.100" libfprint-2.so libfprint-git)
conflicts=(libfprint libfprint-git)
source=("libfprint-goodix-5301-$pkgver.tar.gz"
        77-goodix-5301-mm-ignore.rules)
b2sums=('6aa04b6819b57a77672ebfcde41497e56959f79227adf12798b5d70273ce16c711ed8f6b720a8ec51e7dccbc3639b9c84f8aba4c634b03a07c349056a7b46e0f'
        '7a5b689a2f671a749da7a458f08c3624fc463bdb7a8c13555fc362f1a7373b1342c0f7d47c6eaf5840958a72cdd8925e288017688e8020992e3a22450875901f')

build() {
  arch-meson "libfprint-goodix-5301-$pkgver" build \
    -D drivers=default \
    -D doc=false \
    -D gtk-examples=false \
    -D installed-tests=false
  meson compile -C build
}

package() {
  meson install -C build --destdir "$pkgdir"
  install -Dm644 77-goodix-5301-mm-ignore.rules \
    -t "$pkgdir/usr/lib/udev/rules.d/"
}
