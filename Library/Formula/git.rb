require 'formula'

class GitManuals < Formula
  url 'http://kernel.org/pub/software/scm/git/git-manpages-1.7.5.4.tar.bz2'
  md5 '7a74ef1c64395a07301359a8707c828a'
end

class GitHtmldocs < Formula
  url 'http://kernel.org/pub/software/scm/git/git-htmldocs-1.7.5.4.tar.bz2'
  md5 '88226c08c208101db61e345a3598c4af'
end

class Git < Formula
  url 'http://kernel.org/pub/software/scm/git/git-1.7.5.4.tar.bz2'
  md5 '4985b774db84d3bbcc2b8d90952552a3'
  homepage 'http://git-scm.com'

  def install
    # If these things are installed, tell Git build system to not use them
    ENV['NO_FINK']='1'
    ENV['NO_DARWIN_PORTS']='1'
    # If local::lib is used you get a 'Only one of PREFIX or INSTALL_BASE can be given' error
    ENV['PERL_MM_OPT']=''
    # Build verbosely.
    ENV['V']='1'

    inreplace "Makefile" do |s|
      s.remove_make_var! %w{CFLAGS LDFLAGS}
    end

    system "make", "prefix=#{prefix}", "install"

    # Install the Git bash completion file.
    # Put it into the Cellar so that it gets upgraded along with git upgrades.
    (prefix+'etc/bash_completion.d').install 'contrib/completion/git-completion.bash'

    # Install emacs support.
    (share+'doc/git-core/contrib').install 'contrib/emacs'

    # Install contrib files to share/contrib
    (share).install 'contrib'

    # These files are exact copies of the git binary, so like the contents
    # of libexec/git-core lets hard link them.
    # I am assuming this is an overisght by the git devs.
    git_md5 = (bin+'git').md5
    %w[git-receive-pack git-upload-archive].each do |fn|
      fn = bin + fn
      next unless git_md5 == fn.md5
      fn.unlink
      fn.make_link bin+'git'
    end

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    GitManuals.new.brew { man.install Dir['*'] }
    GitHtmldocs.new.brew { (share+'doc/git-doc').install Dir['*'] }
  end

  def caveats; <<-EOS.undent
    Bash completion has been installed to:
      #{etc}/bash_completion.d

    Emacs support has been installed to:
      #{share}/doc/git-core/contrib/emacs

    The rest of the "contrib" has been installed to:
      #{share}/contrib
    EOS
  end
end
