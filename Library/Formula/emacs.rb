require 'formula'

class Emacs < Formula
  url 'http://ftp.gnu.org/pub/gnu/emacs/emacs-23.3.tar.bz2'
  md5 'a673c163b4714362b94ff6096e4d784a'
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
    p = []

    # Fix for building with Xcode 4; harmless on Xcode 3.x.
    unless ARGV.build_head?
      p << "http://repo.or.cz/w/emacs.git/commitdiff_plain/c8bba48c5889c4773c62a10f7c3d4383881f11c1"
    end

    if ARGV.include? "--cocoa"
      # Existing fullscreen patch does not patch cleanly against head.
      unless ARGV.build_head?
        p << "https://github.com/downloads/typester/emacs/feature-fullscreen.patch"
      end
    end

    return p
  end

  fails_with_llvm "Duplicate symbol errors while linking."

  def install
    args = ["--prefix=#{prefix}",
            "--without-dbus",
            "--enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp",
            "--infodir=#{info}/emacs"]

    if ARGV.build_head? and File.exists? "./autogen/copy_autogen"
      opoo "Using copy_autogen"
      puts "See https://github.com/mxcl/homebrew/issues/4852"
      system "autogen/copy_autogen"
    end

    if ARGV.include? "--cocoa"
      args << "--with-ns" << "--disable-ns-self-contained"
      system "./configure", *args
      system "make bootstrap"
      system "make install"
      prefix.install "nextstep/Emacs.app"

      bin.mkpath
      ln_s prefix+'Emacs.app/Contents/MacOS/Emacs', bin+'emacs'
      ln_s prefix+'Emacs.app/Contents/MacOS/bin/emacsclient', bin
      ln_s prefix+'Emacs.app/Contents/MacOS/bin/etags', bin
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
end
