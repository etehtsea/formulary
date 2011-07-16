require 'formula'

# This formula for Python 2.7.x
# Python 3.x is available as a separate formula:
# $ brew install python3

class Distribute < Formula
  url 'http://pypi.python.org/packages/source/d/distribute/distribute-0.6.19.tar.gz'
  md5 '45a17940eefee849d4cb8cc06d28d96f'
end


# Was a Framework build requested?
def build_framework?; ARGV.include? '--framework'; end

# Are we installed or installing as a Framework?
def as_framework?
  (self.installed? and File.exists? prefix+"Frameworks/Python.framework") or build_framework?
end

class Python < Formula
  url 'http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tar.bz2'
  homepage 'http://www.python.org/'
  md5 'ba7b2f11ffdbf195ee0d111b9455a5bd'

  depends_on 'readline' => :optional # Prefer over OS X's libedit
  depends_on 'sqlite'   => :optional # Prefer over OS X's older version
  depends_on 'gdbm'     => :optional

  def options
    [
      ["--framework", "Do a 'Framework' build instead of a UNIX-style build."],
      ["--universal", "Build for both 32 & 64 bit Intel."],
      ["--static", "Build static libraries."],
      ["--no-poll", "Remove HAVE_POLL.* options from build."]
    ]
  end

  # Skip binaries so modules will load; skip lib because it is mostly Python files
  skip_clean ['bin', 'lib']

  def install
    if build_framework? and ARGV.include? "--static"
      onoe "Cannot specify both framework and static."
      exit 99
    end

    args = ["--prefix=#{prefix}"]

    if ARGV.build_universal?
      args << "--enable-universalsdk=/" << "--with-universal-archs=intel"
    end

    if build_framework?
      args << "--enable-framework=#{prefix}/Frameworks"
    else
      args << "--enable-shared" unless ARGV.include? '--static'
    end

    # allow sqlite3 module to load extensions
    inreplace "setup.py",
      'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))', ''

    system "./configure", *args

    if ARGV.include? '--no-poll'
      inreplace 'pyconfig.h', /.*?(HAVE_POLL[_A-Z]*).*/, '#undef \1'
    end

    system "make"
    ENV.j1 # Installs must be serialized
    system "make install"

    # Post-install, fix up the site-packages and install-scripts folders
    # so that user-installed Python software survives minor updates, such
    # as going from 2.7.0 to 2.7.1.

    # Remove the site-packages that Python created in its Cellar.
    site_packages.rmtree

    # Create a site-packages in the prefix.
    prefix_site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    ln_s prefix_site_packages, site_packages

    # Tell distutils-based installers where to put scripts
    scripts_folder.mkpath
    (effective_lib+"python2.7/distutils/distutils.cfg").write <<-EOF.undent
      [install]
      install-scripts=#{scripts_folder}
    EOF

    # Install distribute. The user can then do:
    # $ easy_install pip
    # $ pip install --upgrade distribute
    # to get newer versions of distribute outside of Homebrew.
    Distribute.new.brew { system "#{bin}/python", "setup.py", "install" }
  end

  def caveats
    framework_caveats = <<-EOS.undent

      Framework Python was installed to:
        #{prefix}/Frameworks/Python.framework

      You may want to symlink this Framework to a standard OS X location,
      such as:
          mkdir ~/Frameworks
          ln -s "#{prefix}/Frameworks/Python.framework" ~/Frameworks
    EOS

    general_caveats = <<-EOS.undent
      A "distutils.cfg" has been written, specifing the install-scripts folder as:
        #{scripts_folder}

      If you install Python packages via "python setup.py install", easy_install, pip,
      any provided scripts will go into the install-scripts folder above, so you may
      want to add it to your PATH.

      Distribute has been installed, so easy_install is available.
      To update distribute itself outside of Homebrew:
          #{scripts_folder}/easy_install pip
          #{scripts_folder}/pip install --upgrade distribute

      See: https://github.com/mxcl/homebrew/wiki/Homebrew-and-Python
    EOS

    s = general_caveats
    s += framework_caveats if as_framework?
    return s
  end

private

  # Path helpers

  def effective_lib
    # If we're installed or installing as a Framework, then use that location.
    return prefix+"Frameworks/Python.framework/Versions/2.7/lib" if as_framework?
    # Otherwise use just 'lib'
    return lib
  end

  # The Cellar location of site-packages
  def site_packages
    effective_lib+"python2.7/site-packages"
  end

  # The HOMEBREW_PREFIX location of site-packages
  def prefix_site_packages
    HOMEBREW_PREFIX+"lib/python2.7/site-packages"
  end

  def scripts_folder
    HOMEBREW_PREFIX+"share/python"
  end

end
