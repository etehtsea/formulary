require 'formula'

class Cairo < Formula
  url 'http://cairographics.org/releases/cairo-1.8.10.tar.gz'
  homepage 'http://cairographics.org/'
  md5 'b60a82f405f9400bbfdcf850b1728d25'

  depends_on 'pkg-config' => :build
  depends_on 'pixman'

  # Comes with Snow Leopard, but not Leopard
  keg_only :provided_by_osx

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-x"
    system "make install"
  end
end
