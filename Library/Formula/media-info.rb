require 'formula'

class MediaInfo < Formula
  url 'http://downloads.sourceforge.net/sourceforge/mediainfo/MediaInfo_CLI_0.7.45_GNU_FromSource.tar.bz2'
  homepage 'http://mediainfo.sourceforge.net'
  version '0.7.45'
  md5 '68c78682b58fe1a3081b0eef9220afbf'

  depends_on 'pkg-config' => :build

  def install
    root_dir = Dir.pwd

    Dir.chdir root_dir + '/ZenLib/Project/GNU/Library'
    system "./configure", "--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"

    Dir.chdir root_dir + "/MediaInfoLib/Project/GNU/Library"
    system "./configure", "--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"

    Dir.chdir root_dir + "/MediaInfo/Project/GNU/CLI"
    system "./configure", "--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
