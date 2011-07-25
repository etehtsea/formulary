require 'formula'

class Graphviz < Formula
  url 'http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.28.0.tar.gz'
  md5 '8d26c1171f30ca3b1dc1b429f7937e58'
  homepage 'http://graphviz.org/'

  depends_on 'pkg-config' => :build

  if ARGV.include? '--with-pdf'
    depends_on 'pango'
    depends_on 'cairo' if MacOS.leopard?
  end

  def options
    [["--with-pdf", "Build with Pango/Cairo to support native PDF output"]]
  end

  def install
    ENV.x11
    # Various language bindings fail with 32/64 issues.
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-qt=no",
                          "--disable-quartz",
                          "--disable-java",
                          "--disable-ocaml",
                          "--disable-perl",
                          "--disable-php",
                          "--disable-python",
                          "--disable-r",
                          "--disable-ruby",
                          "--disable-sharp",
                          "--disable-swig"
    system "make install"
  end
end
