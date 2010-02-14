require 'formula'

# NOTE this should be provided by pip eventually
# currently easy_install doesn't seem to support it

class Pyqt <Formula
  url 'http://www.riverbankcomputing.co.uk/static/Downloads/PyQt4/PyQt-mac-gpl-4.7.tar.gz'
  homepage 'http://www.riverbankcomputing.co.uk/software/pyqt'
  md5 'dc58e2c5afc31a2dd285346bc16081ee'

  depends_on 'sip'
  depends_on 'qt'

  def install
    ENV.prepend 'PYTHONPATH', "#{HOMEBREW_PREFIX}/lib/python", ':'
    
    system "python", "./configure.py", "-g", "--confirm-license",
                                       "--bindir=#{bin}",
                                       "--destdir=#{lib}/python",
                                       "--sipdir=#{share}/sip"
    system "make"
    system "make install"
  end
  
  def caveats; <<-EOS
This formula won't function until you add the following to your PYTHONPATH
environment variable:

#{HOMEBREW_PREFIX}/lib/python

Installing with easy_install would be ideal; then the libraries are installed
to /Library/Python which is in the default OS X Python library path. However
easy_install does not support this formula.
    EOS
  end
end
