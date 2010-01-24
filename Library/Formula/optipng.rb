require 'formula'

class Optipng <Formula
  url 'http://downloads.sourceforge.net/optipng/optipng-0.6.3.tar.gz'
  homepage 'http://optipng.sourceforge.net/'
  md5 '6cef405197a878acff4c6216cf38e871'

  def install
    inreplace 'src/scripts/gcc.mak.in', '/usr/local', prefix
    inreplace 'src/scripts/gcc.mak.in', 'mandir=$(prefix)/man', 'mandir=$(prefix)/share/man'
    system "./configure", "-with-system-zlib"
    system "make install"
  end
end
