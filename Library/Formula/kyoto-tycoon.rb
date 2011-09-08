require 'formula'

class KyotoTycoon < Formula
  url 'http://fallabs.com/kyototycoon/pkg/kyototycoon-0.9.51.tar.gz'
  homepage 'http://fallabs.com/kyototycoon/'
  sha1 '18b1707fcf383e2bbc4caca3ab6a9ea79fa5b200'

  depends_on 'lua' unless ARGV.include? "--no-lua"
  depends_on 'kyoto-cabinet'

  def options
    [["--no-lua", "Disable Lua support (and don't force Lua install.)"]]
  end

  def install
    args = ["--prefix=#{prefix}"]
    args << "--enable-lua" unless ARGV.include? "--no-lua"

    system "./configure", *args
    system "make"
    system "make install"
  end
end
