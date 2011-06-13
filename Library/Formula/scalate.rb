require 'formula'
require 'find'

class Scalate < Formula
  url 'http://repo.fusesource.com/nexus/content/repositories/public/org/fusesource/scalate/scalate-distro/1.5.0/scalate-distro-1.5.0-unix-bin.tar.gz'
  version '1.5.0'
  homepage 'http://scalate.fusesource.org/'
  md5 '7574d29b29c05c086f1fa977f23ed4a5'

  def startup_script
    <<-EOS.undent
    #!/bin/bash
    # This startup script for Scalate calls the real startup script installed
    # to Homebrew's cellar. This avoids issues with local vs. absolute symlinks.

    #{libexec}/bin/scalate $*
    EOS
  end

  def install

    # Recursively fix the permissions of extracted regular files excluding the bin directory contents.
    %w{ archetypes docs lib samples license.txt readme.html }.each do |name|
      Find.find(name) do |path|
        if File.file?(path)
          File.chmod(0644, path)
        end
      end
    end

    prefix.install %w{ license.txt readme.html }
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
