require 'formula'

def coreutils_aliases
  s = "brew_prefix=`brew --prefix`\n"

  %w{
    base64 basename cat chcon chgrp chmod chown chroot cksum comm cp csplit
    cut date dd df dir dircolors dirname du echo env expand expr factor false
    fmt fold groups head hostid id install join kill link ln logname ls md5sum
    mkdir mkfifo mknod mktemp mv nice nl nohup od paste pathchk pinky pr
    printenv printf ptx pwd readlink rm rmdir runcon seq sha1sum sha225sum
    sha256sum sha384sum sha512sum shred shuf sleep sort split stat stty sum
    sync tac tail tee test touch tr true tsort tty uname unexpand uniq unlink
    uptime users vdir wc who whoami yes
    }.each do |g|
    s += "alias #{g}=\"$brew_prefix/bin/g#{g}\"\n"
  end

  s += "alias '['=\"$brew_prefix/bin/g\\[\"\n"

  return s
end

class Coreutils < Formula
  homepage 'http://www.gnu.org/software/coreutils'
  url 'http://ftpmirror.gnu.org/coreutils/coreutils-8.14.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/coreutils/coreutils-8.14.tar.xz'
  sha256 '0d120817c19292edb19e92ae6b8eac9020e03d51e0af9cb116cf82b65d18b02d'

  def install
    system "./configure", "--prefix=#{prefix}", "--program-prefix=g"
    system "make install"

    (prefix+'aliases').write(coreutils_aliases)
  end

  def caveats
    <<-EOS
All commands have been installed with the prefix 'g'.

A file that aliases these commands to their normal names is available
and may be used in your bashrc like:

    source #{prefix}/aliases

But note that sourcing these aliases will cause them to be used instead
of Bash built-in commands, which may cause problems in shell scripts.
The Bash "printf" built-in behaves differently than gprintf, for instance,
which is known to cause problems with "bash-completion".

The man pages are still referenced with the g-prefix.
    EOS
    end
  end
end
