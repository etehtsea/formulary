require 'formula'

def which_python
  "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
end

def site_package_dir
  "lib/#{which_python}/site-packages"
end

class Opencv < Formula
  url 'http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/2.3.1/OpenCV-2.3.1a.tar.bz2'
  md5 '82e4b6bfa349777233eea09b075e931e'
  homepage 'http://opencv.willowgarage.com/wiki/'


  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build

  depends_on 'libtiff' => :optional
  depends_on 'jasper'  => :optional
  depends_on 'tbb'     => :optional

  depends_on 'numpy' => :python

  # Can also depend on ffmpeg, but this pulls in a lot of extra stuff that
  # you don't need unless you're doing video analysis, and some of it isn't
  # in Homebrew anyway.

  def patches
    # Fix conflict when OpenEXR is installed. See:
    #   http://tech.groups.yahoo.com/group/OpenCV/message/83201
    DATA
  end

  def options
    [['--build32', 'Force a 32-bit build.']]
  end

  def install
    args = std_cmake_parameters.split
    args << "-DOPENCV_EXTRA_C_FLAGS='-arch i386 -m32'" if ARGV.include? '--build32'

    # The CMake `FindPythonLibs` Module is dumber than a bag of hammers when
    # more than one python installation is available---for example, it clings
    # to the Header folder of the system Python Framework like a drowning
    # sailor.
    #
    # This code was cribbed from the VTK formula and uses the output to
    # `python-config` to do the job FindPythonLibs should be doing in the first
    # place.
    python_prefix = `python-config --prefix`.strip
    # Python is actually a library. The libpythonX.Y.dylib points to this lib, too.
    if File.exist? "#{python_prefix}/Python"
      # Python was compiled with --framework:
      args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
      args << "-DPYTHON_INCLUDE_DIR='#{python_prefix}/Headers'"
    else
      python_lib = "#{python_prefix}/lib/lib#{which_python}"
      if File.exists? "#{python_lib}.a"
        args << "-DPYTHON_LIBRARY='#{python_lib}.a'"
      else
        args << "-DPYTHON_LIBRARY='#{python_lib}.dylib'"
      end
      args << "-DPYTHON_INCLUDE_DIR='#{python_prefix}/include/#{which_python}'"
    end
    args << "-DPYTHON_PACKAGES_PATH='#{lib}/#{which_python}/site-packages'"

    system 'cmake', '.', *args
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    The OpenCV Python module will not work until you edit your PYTHONPATH like so:
      export PYTHONPATH="#{HOMEBREW_PREFIX}/#{site_package_dir}:$PYTHONPATH"

    To make this permanent, put it in your shell's profile (e.g. ~/.profile).
    EOS
  end
end

__END__

Fix conflict when OpenEXR is installed. See:
  http://tech.groups.yahoo.com/group/OpenCV/message/83201

diff --git a/modules/highgui/src/grfmt_exr.hpp b/modules/highgui/src/grfmt_exr.hpp
index 642000b..b1414f1 100644
--- a/modules/highgui/src/grfmt_exr.hpp
+++ b/modules/highgui/src/grfmt_exr.hpp
@@ -56,6 +56,7 @@ namespace cv
 
 using namespace Imf;
 using namespace Imath;
+using Imf::PixelType;
 
 /* libpng version only */
 
