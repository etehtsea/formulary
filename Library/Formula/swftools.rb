require 'formula'

class Swftools <Formula
  url 'http://www.swftools.org/swftools-0.9.0.tar.gz'
  homepage 'http://www.swftools.org'
  md5 '946e7c692301a332745d29140bc74e55'

  depends_on 'jpeg'
  depends_on 'lame' => :optional

  def install
    ENV.minimal_optimization

    # Need to add freetype-config and other X11 utils to the path
    ENV.x11
    ENV.append 'PATH', '/usr/x11/bin', ':'

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end

  def caveats
    <<-EOS
    swfc segfaults under Snow Leopard. Please persue this issue
    with the softare vendor:
      http://lists.nongnu.org/mailman/listinfo/swftools-common
    EOS
  end
end
