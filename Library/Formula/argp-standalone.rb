require 'formula'

class ArgpStandalone < Formula
  homepage 'http://www.lysator.liu.se/~nisse/misc/'
  url 'http://www.lysator.liu.se/~nisse/misc/argp-standalone-1.3.tar.gz'
  md5 '720704bac078d067111b32444e24ba69'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"

    include.install 'argp.h', 'argp-fmtstream.h', 'argp-namefrob.h'
    lib.install 'libargp.a'
  end
end
