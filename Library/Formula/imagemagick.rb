# some credit to http://github.com/maddox/magick-installer
require 'formula'

def ghostscript_srsly?
  ARGV.include? '--with-ghostscript'
end

def ghostscript_fonts?
  File.directory? "#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
end

def use_wmf?
  ARGV.include? '--use-wmf'
end

def disable_openmp?
  ARGV.include? '--disable-openmp'
end

def x11?
  # I used this file because old Xcode seems to lack it, and its that old
  # Xcode that loads of people seem to have installed still
  File.file? '/usr/X11/include/ft2build.h'
end

class Imagemagick <Formula
  url 'ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.6.3-9.tar.bz2'
  md5 'd97ea8010f0a46ee9d057a5e006e651b'
  homepage 'http://www.imagemagick.org'

  depends_on 'jpeg'
  depends_on 'libpng' unless x11?

  depends_on 'ghostscript' => :recommended if ghostscript_srsly? and x11?

  depends_on 'libtiff' => :optional
  depends_on 'little-cms' => :optional
  depends_on 'jasper' => :optional
  depends_on 'little-cms' => :optional

  depends_on 'libwmf' if use_wmf?

  def skip_clean? path
    path.extname == '.la'
  end

  def options
    [
      ['--with-ghostscript', 'Compile against ghostscript (not recommended.)'],
      ['--use-wmf', 'Compile with libwmf support.'],
      ['--disable-openmp', 'Disable OpenMP.']
    ]
  end

  def install
    ENV.x11 # Add to PATH for freetype-config on Snow Leopard
    ENV.O3 # takes forever otherwise

    args = [ "--disable-osx-universal-binary",
             "--without-perl", # I couldn't make this compile
             "--prefix=#{prefix}",
             "--disable-dependency-tracking",
             "--enable-shared",
             "--disable-static",
             "--with-modules",
             "--without-magick-plus-plus" ]

    args << "--disable-openmp" if MACOS_VERSION < 10.6 or disable_openmp?
    args << "--without-gslib" unless ghostscript_srsly?
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" \
                unless ghostscript_srsly? or ghostscript_fonts?

    # versioned stuff in main tree is pointless for us
    inreplace 'configure', '${PACKAGE_NAME}-${PACKAGE_VERSION}', '${PACKAGE_NAME}'
    system "./configure", *args
    system "make install"

    # We already copy these into the keg root
    %w[NEWS.txt LICENSE ChangeLog].each {|f| (share+"ImageMagick/#{f}").unlink}
  end

  def caveats
    s = ""
    s += "You don't have X11 from the Xcode DMG installed. Consequently Imagemagick is less fully featured.\n" unless x11?
    s += "Some tools will complain if the ghostscript fonts are not installed in:\n\t#{HOMEBREW_PREFIX}/share/ghostscript/fonts\n" \
            unless ghostscript_fonts? or ghostscript_srsly?
    return nil if s.empty?
    return s
  end

  def test
    system "identify", "/Library/Application Support/Apple/iChat Icons/Flags/Argentina.gif"
  end
end
