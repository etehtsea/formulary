require 'formula'

# For tips on Cocoa Emacs, see:
# * http://superuser.com/questions/73500/on-os-x-how-do-i-start-cocoa-emacs-and-bring-it-to-front
class Emacs <Formula
  url 'http://ftp.gnu.org/pub/gnu/emacs/emacs-23.2.tar.bz2'
  md5 '057a0379f2f6b85fb114d8c723c79ce2'
  homepage 'http://www.gnu.org/software/emacs/'

  if ARGV.include? "--use-git-head"
    head 'git://repo.or.cz/emacs.git'
  else
    head 'bzr://http://bzr.savannah.gnu.org/r/emacs/trunk'
  end

  def options
    [
      ["--cocoa", "Build a Cocoa version of emacs"],
      ["--with-x", "Include X11 support"],
      ["--use-git-head", "Use repo.or.cz git mirror for HEAD builds"],
    ]
  end

  def patches
    "http://github.com/downloads/typester/emacs/feature-fullscreen.patch" if ARGV.include? "--cocoa"
  end

  def caveats
    s = ""
    if ARGV.include? "--cocoa"
      s += <<-EOS.undent
        Emacs.app was installed to:
          #{prefix}

      EOS
    else
      s += <<-EOS.undent
        Use --cocoa to build a Cocoa-specific Emacs.app.

      EOS
    end

    s += <<-EOS.undent
      To access texinfo documentation, set your INFOPATH to:
        #{info}

      The initial checkout of the bazaar Emacs repository might take a long
      time. You might find that using the repo.or.cz git mirror is faster,
      even after the initial checkout. To use the repo.or.cz git mirror for
      HEAD builds, use the --use-git-head option in addition to --HEAD. Note
      that there is inevitably some lag between checkins made to the
      official Emacs bazaar repository and their appearance on the
      repo.or.cz mirror. See http://repo.or.cz/w/emacs.git for the mirror's
      status. The Emacs devs do not provide support for the git mirror, and
      they might reject bug reports filed with git version information. Use
      it at your own risk.
    EOS

    return s
  end

  def cocoa_startup_script; <<-EOS.undent
    #!/bin/bash
    open -a #{prefix}/Emacs.app/Contents/MacOS/Emacs --args $@
    EOS
  end

  def install
    fails_with_llvm "Duplicate symbol errors while linking."

    args = [
      "--prefix=#{prefix}",
      "--without-dbus",
      "--enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp",
    ]

    if ARGV.include? "--cocoa"
      args << "--with-ns" << "--disable-ns-self-contained"
      system "./configure", *args
      system "make bootstrap"
      system "make install"
      prefix.install "nextstep/Emacs.app"
      (bin+"emacs").write cocoa_startup_script
    else
      if ARGV.include? "--with-x"
        args << "--with-x"
        args << "--with-gif=no" << "--with-tiff=no" << "--with-jpeg=no"
      else
        args << "--without-x"
      end
      system "./configure", *args
      system "make"
      system "make install"
    end
  end
end
