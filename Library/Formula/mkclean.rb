require 'formula'

class Mkclean < Formula
  url 'http://downloads.sourceforge.net/project/matroska/mkclean/mkclean-0.8.5.tar.bz2'
  homepage 'http://www.matroska.org/downloads/mkclean.html'
  md5 'eb1bd84aba2b496efcd61e67cbf2502e'

  def install
    ENV.j1 # Otherwise there are races

    # For 64-bit kernels, just use the Snow Leopard SDK.
    inreplace "corec/tools/coremake/gcc_osx_x64.build" do |s|
      s.gsub! /10\.4u?/, "10.6"
    end

    system "./configure"
    system "make -C mkclean"
    bindir = `corec/tools/coremake/system_output.sh`.chomp
    bin.install "release/#{bindir}/mkclean"
  end
end
