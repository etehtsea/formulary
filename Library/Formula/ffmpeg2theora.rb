require 'formula'

class Ffmpeg2theora < Formula
  url 'http://v2v.cc/~j/ffmpeg2theora/downloads/ffmpeg2theora-0.28.tar.bz2'
  homepage 'http://v2v.cc/~j/ffmpeg2theora/'
  md5 '31e389bfa0719f489af38b6fb2bd0a1f'

  depends_on 'pkg-config' => :build
  depends_on 'scons' => :build
  depends_on 'ffmpeg'
  depends_on 'libkate' => :optional
  depends_on 'libogg'
  depends_on 'libvorbis'
  depends_on 'theora'

  def install
    args = ["prefix=#{prefix}", "mandir=PREFIX/share/man"]
    args << "libkate=1" if Formula.factory('libkate').installed?
    system "scons", "install", *args
  end
end
