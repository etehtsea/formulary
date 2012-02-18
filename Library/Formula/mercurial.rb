require 'formula'

class Mercurial < Formula
  homepage 'http://mercurial.selenic.com/'
  url 'http://mercurial.selenic.com/release/mercurial-2.1.tar.gz'
  sha1 'f649a0b33e0cafb3e5867a2e970f41eb887d3fab'
  head 'http://selenic.com/repo/hg', :using => :hg

  depends_on 'docutils' => :python if ARGV.build_head? or ARGV.include? "--doc"

  def options
    [["--doc", "build the documentation. Depends on 'docutils' module."]]
  end

  # Remove the error codes on things like "no changes found"
  # Will be in next release
  # See: http://selenic.com/hg/rev/a3dcc59054ca
  def patches
    "http://selenic.com/hg/raw-rev/a3dcc59054ca"
  end

  def install
    # Don't add compiler specific flags so we can build against
    # System-provided Python.
    ENV.minimal_optimization

    # Force the binary install path to the Cellar
    inreplace "Makefile",
      "setup.py $(PURE) install",
      "setup.py $(PURE) install --install-scripts=\"#{libexec}\""

    # Make Mercurial into the Cellar.
    # The documentation must be built when using HEAD
    if ARGV.build_head? or ARGV.include? "--doc"
      system "make", "doc"
    end
    system "make", "PREFIX=#{prefix}", "build"
    system "make", "PREFIX=#{prefix}", "install-bin"

    # Now we have lib/python2.x/site-packages/ with Mercurial
    # libs in them. We want to move these out of site-packages into
    # a self-contained folder. Let's choose libexec.
    libexec.install Dir["#{lib}/python*/site-packages/*"]

    # Symlink the hg binary into bin
    bin.install_symlink libexec+'hg'

    # Remove the hard-coded python invocation from hg
    inreplace bin+'hg', %r[#!/.*/python/.*], '#!/usr/bin/env python'

    # Install some contribs
    bin.install 'contrib/hgk'

    # Install man pages
    man1.install 'doc/hg.1'
    man5.install 'doc/hgignore.5', 'doc/hgrc.5'
  end

  def caveats
    s = ""
    if ARGV.build_head?
      s += <<-EOS.undent
        As mercurial is required to get its own repository, there are now two
        installations of mercurial on this machine.
        If the previous installation has been done through Homebrew, the old version
        needs to be removed and the new one needs to be linked :

          brew cleanup mercurial && brew link mercurial

      EOS
    end
    return s
  end
end
