require 'formula'

class Leiningen <Formula
  version '1.0.1'
  url 'http://github.com/technomancy/leiningen/tarball/1.0.1'
  homepage 'http://github.com/technomancy/leiningen'
  md5 'eb287442bb1bcac2de537d00c4d1b1d3'

  def install
    system "bin/lein self-install"
    prefix.install  %w[bin README.md COPYING NEWS]

    # Install the lein bash completion file
    system "mv bash_completion.bash lein-completion.bash"
    (etc+'bash_completion.d').install 'lein-completion.bash'

  end
end
