require 'formula'

def complete?
  ARGV.include? "--complete"
end

def postgres?
  ARGV.include? "--with-postgres"
end

def mysql?
  ARGV.include? "--with-mysql"
end

def no_python?
  ARGV.include? "--without-python"
end

def which_python
  "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
end


def opencl?
  ARGV.include? "--enable-opencl"
end

class Gdal < Formula
  homepage 'http://www.gdal.org/'
  url 'http://download.osgeo.org/gdal/gdal-1.9.0.tar.gz'
  md5 '1853f3d8eb5232ae030abe007840cade'

  head 'https://svn.osgeo.org/gdal/trunk/gdal', :using => :svn

  depends_on 'doxygen' => :build

  depends_on 'jpeg'
  depends_on 'giflib'
  depends_on 'proj'
  depends_on 'geos'

  depends_on "postgresql" if postgres?
  depends_on "mysql" if mysql?

  # Without Numpy, the Python bindings can't deal with raster data.
  depends_on 'numpy' => :python unless no_python?

  if complete?
    # Raster libraries
    depends_on "netcdf" # Also brings in HDF5
    depends_on "jasper" # May need a keg-only GeoJasPer library as this one is
                        # not geo-spatially enabled.
    depends_on "cfitsio"
    depends_on "epsilon"
    depends_on "libdap"
    def patches; DATA; end # Fix a bug in LibDAP detection.

    # Vector libraries
    depends_on "unixodbc" # OS X version is not complete enough
    depends_on "libspatialite"
    depends_on "xerces-c"
    depends_on "poppler"
    depends_on "freexl"

    # Other libraries
    depends_on "xz" # get liblzma compression algorithm library from XZutils
  end

  def options
    [
      ['--complete', 'Use additional Homebrew libraries to provide more drivers.'],
      ['--with-postgres', 'Specify PostgreSQL as a dependency.'],
      ['--with-mysql', 'Specify MySQL as a dependency.'],
      ['--without-python', 'Build without Python support (disables a lot of tools).'],
      ['--enable-opencl', 'Build with support for OpenCL.']
    ]
  end

  def get_configure_args
    args = [
      # Base configuration.
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-local=#{prefix}",
      "--with-threads",
      "--with-libtool",

      # GDAL native backends.
      "--with-libtiff=internal", # For bigTIFF support
      "--with-geotiff=internal",
      "--with-pcraster=internal",
      "--with-pcidsk=internal",
      "--with-bsb",
      "--with-grib",
      "--with-pam",

      # Backends supported by OS X.
      "--with-libz=/usr",
      "--with-png=/usr/X11",
      "--with-expat=/usr",
      "--with-sqlite3=/usr",

      # Default Homebrew backends.
      "--with-jpeg=#{HOMEBREW_PREFIX}",
      "--with-jpeg12",
      "--with-gif=#{HOMEBREW_PREFIX}",
      "--with-curl=/usr/bin/curl-config",

      # GRASS backend explicitly disabled.  Creates a chicken-and-egg problem.
      # Should be installed separately after GRASS installation using the
      # official GDAL GRASS plugin.
      "--without-grass",
      "--without-libgrass"
    ]

    # Optional library support for additional formats.
    if complete?
      args.concat [
        "--with-liblzma=yes",
        "--with-netcdf=#{HOMEBREW_PREFIX}",
        "--with-hdf5=#{HOMEBREW_PREFIX}",
        "--with-jasper=#{HOMEBREW_PREFIX}",
        "--with-cfitsio=#{HOMEBREW_PREFIX}",
        "--with-epsilon=#{HOMEBREW_PREFIX}",
        "--with-odbc=#{HOMEBREW_PREFIX}",
        "--with-spatialite=#{HOMEBREW_PREFIX}",
        "--with-xerces=#{HOMEBREW_PREFIX}",
        "--with-poppler=#{HOMEBREW_PREFIX}",
        "--with-freexl=#{HOMEBREW_PREFIX}",
        "--with-dods-root=#{HOMEBREW_PREFIX}"
      ]
    else
      args.concat [
        "--without-cfitsio",
        "--without-netcdf",
        "--without-ogdi",
        "--without-hdf4",
        "--without-hdf5",
        "--without-openjpeg",
        "--without-jasper",
        "--without-xerces",
        "--without-epsilon",
        "--without-spatialite",
        "--without-libkml",
        "--without-poppler",
        "--without-podofo",
        "--with-freexl=no",
        "--with-dods-root=no",

        # The following libraries are either proprietary or available under
        # non-free licenses.  Interested users will have to install such
        # software manually.
        "--without-msg",
        "--without-mrsid",
        "--without-jp2mrsid",
        "--without-kakadu",
        "--without-fme",
        "--without-ecw",
        "--without-dwgdirect"
      ]
    end

    # Database support.
    args << "--without-pg" unless postgres?
    args << "--without-mysql" unless mysql?
    args << "--without-sde"    # ESRI ArcSDE databases
    args << "--without-ingres" # Ingres databases
    args << "--without-oci"    # Oracle databases
    args << "--without-idb"    # IBM Informix DataBlades

    # Homebrew-provided databases.
    args << "--with-pg=#{HOMEBREW_PREFIX}/bin/pg_config" if postgres?
    args << "--with-mysql=#{HOMEBREW_PREFIX}/bin/mysql_config" if mysql?

    args << "--without-python" # Installed using a separate set of
                                         # steps so that everything winds up
                                         # in the prefix.

    # Scripting APIs that have not been re-worked to respect Homebrew prefixes.
    #
    # Currently disabled as they install willy-nilly into locations outside of
    # the Homebrew prefix.  Enable if you feel like it, but uninstallation may be
    # a manual affair.
    #
    # TODO: Fix installation of script bindings so they install into the
    # Homebrew prefix.
    args << "--without-perl"
    args << "--without-php"
    args << "--without-ruby"

    # OpenCL support
    args << "--with-opencl" if opencl?

    return args
  end

  def install
    # The 1.9.0 release appears to contain a regression where linking flags for
    # Sqlite are not added at a critical moment when the GDAL library is being
    # assembled. This causes the build to fail due to missing symbols.
    #
    # Fortunately, this can be remedied using LDFLAGS.
    ENV.append 'LDFLAGS', '-lsqlite3'
    # Needed by libdap
    ENV.append 'CPPFLAGS', '-I/usr/include/libxml2' if complete?

    # Reset ARCHFLAGS to match how we build.
    if MacOS.prefer_64_bit?
      ENV['ARCHFLAGS'] = "-arch x86_64"
    else
      ENV['ARCHFLAGS'] = "-arch i386"
    end

    system "./configure", *get_configure_args
    system "make"
    system "make install"

    unless no_python?
      # If setuptools happens to be installed, setup.py will cowardly refuse to
      # install to anywhere that is not on the PYTHONPATH.
      #
      # Really setuptools, we're all consenting adults here...
      python_lib = lib + which_python + 'site-packages'
      ENV.append 'PYTHONPATH', python_lib

      # setuptools is also apparently incapable of making the directory it's
      # self
      python_lib.mkpath

      # `python-config` may try to talk us into building bindings for more
      # architectures than we really should.
      if MacOS.prefer_64_bit?
        ENV.append_to_cflags '-arch x86_64'
      else
        ENV.append_to_cflags '-arch i386'
      end

      cd 'swig/python' do
        system "python", "setup.py", "install_lib", "--install-dir=#{python_lib}"
        bin.install Dir['scripts/*']
      end
    end

    # For some reason, the 1.9.0 source contains an empty `man` directory which
    # fools Make into thinking there is nothing that needs to be done.
    rmtree 'man'
    system 'make', 'man'
    system 'make', 'install-man'

    # Clean up any stray doxygen files.
    Dir[bin + '*.dox'].each { |p| rm p }
  end

  unless no_python?
    def caveats
      <<-EOS
This version of GDAL was built with Python support.  In addition to providing
modules that makes GDAL functions available to Python scripts, the Python
binding provides ~18 additional command line tools.

Unless you are using Homebrew's Python, both the bindings and the
additional tools will be unusable unless the following directory is added to
the PYTHONPATH:

    #{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages
      EOS
    end
  end
end

__END__
Fix test for LibDAP >= 3.10.


diff --git a/configure b/configure
index 997bbbf..a1928d5 100755
--- a/configure
+++ b/configure
@@ -24197,7 +24197,7 @@ else
 rm -f islibdappost310.*
 echo '#include "Connect.h"' > islibdappost310.cpp
 echo 'int main(int argc, char** argv) { return 0; } ' >> islibdappost310.cpp
-if test -z "`${CXX} islibdappost310.cpp -c ${DODS_INC} 2>&1`" ; then
+if test -z "`${CXX} islibdappost310.cpp -c ${DODS_INC} ${CPPFLAGS} 2>&1`" ; then
     DODS_INC="$DODS_INC -DLIBDAP_310 -DLIBDAP_39"
     { $as_echo "$as_me:${as_lineno-$LINENO}: result: libdap >= 3.10" >&5
 $as_echo "libdap >= 3.10" >&6; }
