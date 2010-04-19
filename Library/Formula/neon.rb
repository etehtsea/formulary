require 'formula'

class Neon <Formula
  url 'http://www.webdav.org/neon/neon-0.29.3.tar.gz'
  md5 'ba1015b59c112d44d7797b62fe7bee51'
  homepage 'http://www.webdav.org/neon/'

  def keg_only?
    :provided_by_osx
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--enable-shared",
                          "--disable-static",
                          "--with-ssl"
    system "make install"
  end
end
