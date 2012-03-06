require 'formula'

class GitHg < Formula
  head 'https://github.com/offbytwo/git-hg.git'
  homepage 'http://offbytwo.com/git-hg/'

  def install
    unless which 'hg'
      puts "You may need to install Mercurial before using this software:"
      puts "  brew install mercurial"
    end

    prefix.install Dir['*']
  end
end

