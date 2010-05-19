require 'formula'

class CoffeeScript <Formula
  url "http://github.com/jashkenas/coffee-script/tarball/0.6.2"
  head "git://github.com/jashkenas/coffee-script.git"
  homepage "http://jashkenas.github.com/coffee-script/"
  md5 'c5a148d7ea5ef8e1b2bb8e6231559331'

  # head coffee-script usually depends on head node and
  # since there isn't a way to specify that just remove
  # the depends_on
  depends_on :node unless ARGV.flag? '--HEAD'

  def caveats
    <<-EOS.undent
    Coffee is a continually evolving language and as such uses new features of
    Node.js as they are added.  To take advantage of these features while using
    HEAD make sure to install the HEAD version of node and keep it updated.

        brew uninstall node
        brew install node --HEAD
    EOS
  end if ARGV.flag? '--HEAD'

  def install
    bin.mkpath
    system "./bin/cake", "install", "--prefix", prefix
  end
end
