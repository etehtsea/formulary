require 'formula'

class GitCola < Formula
  homepage 'http://git-cola.github.com/'
  url 'https://github.com/git-cola/git-cola/tarball/v1.7.6'
  md5 'c6266d2e4f008e072f60c1e6d5fd1bb7'
  head 'https://github.com/git-cola/git-cola.git'

  depends_on 'pyqt'

  def options
    [['--build-docs', "Build man pages using asciidoc and xmlto"]]
  end

  if ARGV.include? '--build-docs'
    # these are needed to build man pages
    depends_on 'asciidoc'
    depends_on 'xmlto'
  end

  def install
    ENV.prepend 'PYTHONPATH', "#{HOMEBREW_PREFIX}/lib/python", ':'
    system "make", "prefix=#{prefix}", "install"

    if ARGV.include? '--build-docs'
      system "make",
             "-C", "share/doc/git-cola",
             "-f", "Makefile.asciidoc",
             "prefix=#{prefix}",
             "install", "install-html"
    end
  end
end
