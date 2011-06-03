require 'formula'

def build_java?; ARGV.include? "--java"; end
def build_perl?; ARGV.include? "--perl"; end
def build_python?; ARGV.include? "--python"; end
def build_ruby?; ARGV.include? "--ruby"; end
def build_universal?; ARGV.build_universal?; end
def with_unicode_path?; ARGV.include? '--unicode-path'; end

# On 10.5 we need newer versions of apr, neon etc.
# On 10.6 we only need a newer version of neon
class SubversionDeps < Formula
  url 'http://subversion.tigris.org/downloads/subversion-deps-1.6.17.tar.bz2'
  sha1 'ebfda3416c09a91dbcf744a22ea83ed827ad3495'
end

class Subversion < Formula
  homepage 'http://subversion.apache.org/'
  url 'http://subversion.tigris.org/downloads/subversion-1.6.17.tar.bz2'
  sha1 '6e3ed7c87d98fdf5f0a999050ab601dcec6155a1'

  depends_on 'pkg-config' => :build

  # On Snow Leopard, build a new neon. For Leopard, the deps above include this.
  depends_on 'neon' if MacOS.snow_leopard?

  def options
    [
      ['--java', 'Build Java bindings.'],
      ['--perl', 'Build Perl bindings.'],
      ['--python', 'Build Python bindings.'],
      ['--ruby', 'Build Ruby bindings.'],
      ['--universal', 'Build as a Universal Intel binary.'],
      ['--unicode-path', 'Include support for OS X unicode (but see caveats!)']
    ]
  end

  def patches
    # Patch to find Java headers
    p = { :p0 =>
      "http://trac.macports.org/export/73004/trunk/dports/devel/subversion-javahlbindings/files/patch-configure.diff"
    }

    # Patch for subversion handling of OS X Unicode paths (see caveats)
    if with_unicode_path?
      p[:p1] = "https://gist.github.com/raw/434424/subversion-unicode-path.patch"
    end

    return p
  end

  def setup_leopard
    # Slot dependencies into place
    d=Pathname.getwd
    SubversionDeps.new.brew { d.install Dir['*'] }
  end

  def check_neon_arch
    # Check that Neon was built universal if we are building w/ --universal
    neon = Formula.factory('neon')
    if neon.installed?
      neon_arch = archs_for_command(neon.lib+'libneon.dylib')
      unless neon_arch.universal?
        opoo "A universal build was requested, but neon was already built for a single arch."
        puts "You may need to `brew rm neon` first."
      end
    end
  end

  def install
    if build_java?
      unless build_universal?
        opoo "A non-Universal Java build was requested."
        puts "To use Java bindings with various Java IDEs, you might need a universal build:"
        puts "  brew install subversion --universal --java"
      end

      unless (ENV["JAVA_HOME"] or "").empty?
        opoo "JAVA_HOME is set. Try unsetting it if JNI headers cannot be found."
      end
    end

    ENV.universal_binary if build_universal?

    if MacOS.leopard?
      setup_leopard
    else
      check_neon_arch if build_universal?
    end

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-ssl",
            "--with-zlib=/usr",
            # use our neon, not OS X's
            "--disable-neon-version-check",
            "--disable-mod-activation",
            "--without-apache-libexecdir",
            "--without-berkeley-db"]

    args << "--enable-javahl" << "--without-jikes" if build_java?
    args << "--with-ruby-sitedir=#{lib}/ruby" if build_ruby?
    args << "--with-unicode-path" if with_unicode_path?

    # Undo a bit of the MacPorts patch
    inreplace "configure", "@@DESTROOT@@/", ""

    system "./configure", *args
    system "make"
    system "make install"

    if build_python?
      system "make swig-py"
      system "make install-swig-py"
    end

    if build_perl?
      ENV.j1 # This build isn't parallel safe
      # Remove hard-coded ppc target, add appropriate ones
      if build_universal?
        arches = "-arch x86_64 -arch i386"
      elsif MacOS.leopard?
        arches = "-arch i386"
      else
        arches = "-arch x86_64"
      end

      # Use verison-appropriate system Perl
     if MacOS.leopard?
        perl_version = "5.8.8"
      else
        perl_version = "5.10.0"
      end

      inreplace "Makefile" do |s|
        s.change_make_var! "SWIG_PL_INCLUDES",
          "$(SWIG_INCLUDES) #{arches} -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -I/usr/local/include -I/System/Library/Perl/#{perl_version}/darwin-thread-multi-2level/CORE"
      end
      system "make swig-pl"
      system "make install-swig-pl"
    end

    if build_java?
      ENV.j1 # This build isn't parallel safe
      system "make javahl"
      system "make install-javahl"
    end

    if build_ruby?
      ENV.j1 # This build isn't parallel safe
      system "make swig-rb"
      system "make install-swig-rb"
    end
  end

  def caveats
    s = ""

    if with_unicode_path?
      s += <<-EOS.undent
        This unicode-path version implements a hack to deal with composed/decomposed
        unicode handling on Mac OS X which is different from linux and windows.
        It is an implementation of solution 1 from
        http://svn.collab.net/repos/svn/trunk/notes/unicode-composition-for-filenames
        which _WILL_ break some setups. Please be sure you understand what you
        are asking for when you install this version.

      EOS
    end

    if build_python?
      s += <<-EOS.undent
        You may need to add the Python bindings to your PYTHONPATH from:
          #{HOMEBREW_PREFIX}/lib/svn-python

      EOS
    end

    if build_ruby?
      s += <<-EOS.undent
        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby

      EOS
    end

    if build_java?
      s += <<-EOS.undent
        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{HOMEBREW_PREFIX}/lib/libsvnjavahl-1.dylib /Library/Java/Extensions/libsvnjavahl-1.dylib

      EOS
    end

    return s.empty? ? nil : s
  end
end
