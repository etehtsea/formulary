require 'formula'

class Opencv <Formula
  # Don't use stable 2.1.0 due to a massive memory leak:
  # https://code.ros.org/trac/opencv/ticket/253
  url 'https://code.ros.org/svn/opencv/trunk/opencv', :using => :svn, :revision => '3478'
  version "2.1.1-pre"
  homepage 'http://opencv.willowgarage.com/wiki/'

  # NOTE: Head builds past the revision above may break on OS X
  head 'https://code.ros.org/svn/opencv/trunk/opencv', :using => :svn

  depends_on 'cmake'
  depends_on 'pkg-config'

  depends_on 'libtiff' => :optional
  depends_on 'jasper'  => :optional
  depends_on 'tbb'     => :optional

  # Can also depend on ffmpeg, but this pulls in a lot of extra stuff that
  # you don't need unless you're doing video analysis, and some of it isn't
  # in Homebrew anyway.

  def install
    system "cmake -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX:PATH=#{prefix} ."
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    The OpenCV Python module will not work until you edit your PYTHONPATH like so:
      export PYTHONPATH="#{HOMEBREW_PREFIX}/lib/python2.6/site-packages/:$PYTHONPATH"

    To make this permanent, put it in your shell's profile (e.g. ~/.profile).
    EOS
  end
end
