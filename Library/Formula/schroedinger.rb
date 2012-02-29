require 'formula'

class Schroedinger < Formula
  head  'git://diracvideo.org/git/schroedinger.git'
  url 'http://diracvideo.org/download/schroedinger/schroedinger-1.0.9.tar.gz'
  md5 'd67ec48b7c506db8c8b49156bf409e60'
  homepage 'http://diracvideo.org/'

  depends_on 'pkg-config' => :build
  depends_on 'orc'

  if ARGV.build_head? and MacOS.xcode_version >= "4.3"
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "autoreconf -i -f" if ARGV.build_head?
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end
