require 'formula'

class Scalate <Formula
  url 'http://repo1.maven.org/maven2/org/fusesource/scalate/scalate-distro/1.2/scalate-distro-1.2-unix-bin.tar.gz'
  version '1.2'
  homepage 'http://scalate.fusesource.org/'
  md5 '20b8c3922f24043ae5118aa35efb5791'

  def startup_script
    <<-EOS.undent
    #!/usr/bin/env bash
    # This startup script for Scalate calls the real startup script installed
    # to Homebrew's cellar. This avoids issues with local vs. absolute symlinks.

    #{libexec}/bin/scalate $*
    EOS
  end

  def install
    rm_f Dir["bin/*.bat"]

    prefix.install %w{ LICENSE.txt ReadMe.html }
    libexec.install Dir['*']

    (bin+'scalate').write startup_script
  end

  def caveats
    <<-EOS.undent
    Software was installed to:
      #{libexec}
    EOS
  end
end
