require 'formula'

class SbclBootstrapBinaries < Formula
  url 'http://downloads.sourceforge.net/project/sbcl/sbcl/1.0.49/sbcl-1.0.49-x86-darwin-binary.tar.bz2'
  md5 '6ffae170cfa0f1858efb37aa7544aba6'
  version "1.0.49"
end

class Sbcl < Formula
  homepage 'http://www.sbcl.org/'
  url 'http://downloads.sourceforge.net/project/sbcl/sbcl/1.0.50/sbcl-1.0.50-source.tar.bz2'
  md5 '74ce9b24516885d066ec4287cde52e8c'
  head 'git://sbcl.git.sourceforge.net/gitroot/sbcl/sbcl.git'

  fails_with_llvm "Compilation fails with LLVM.", :build => 2334

  skip_clean 'bin'
  skip_clean 'lib'

  def options
    [
      ["--without-threads",  "Build SBCL without support for native threads"],
      ["--with-ldb",  "Include low-level debugger in the build"],
      ["--with-internal-xref",  "Include XREF information for SBCL internals (increases core size by 5-6MB)"]
    ]
  end

  def patches
    base = "http://svn.macports.org/repository/macports/trunk/dports/lang/sbcl/files"
    { :p0 => ["patch-base-target-features.diff",
              "patch-make-doc.diff",
              "patch-posix-tests.diff",
              "patch-use-mach-exception-handler.diff"].map { |file_name| "#{base}/#{file_name}" }
    }
  end

  def write_features
    features = []
    features << ":sb-thread" unless ARGV.include? "--without-threads"
    features << ":sb-ldb" if ARGV.include? "--with-ldb"
    features << ":sb-xref-for-internals" if ARGV.include? "--with-internal-xref"

    File.open("customize-target-features.lisp", "w") do |file|
      file.puts "(lambda (list)"
      features.each do |f|
        file.puts "  (pushnew #{f} list)"
      end
      file.puts "  list)"
    end
  end

  def install
    write_features

    # Remove non-ASCII values from environment as they cause build failures
    # More information: http://bugs.gentoo.org/show_bug.cgi?id=174702
    ENV.delete_if do |key, value|
      value =~ /[\x80-\xff]/
    end

    build_directory = Dir.pwd
    SbclBootstrapBinaries.new.brew {
      # We only need the binaries for bootstrapping, so don't install anything:
      command = Dir.pwd + "/src/runtime/sbcl"
      core = Dir.pwd + "/output/sbcl.core"
      xc_cmdline = "#{command} --core #{core} --disable-debugger --no-userinit --no-sysinit"

      Dir.chdir(build_directory)
      system "./make.sh --prefix='#{prefix}' --xc-host='#{xc_cmdline}'"
    }

    ENV['INSTALL_ROOT'] = prefix
    system "sh install.sh"
  end
end
