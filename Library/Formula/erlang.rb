require 'formula'

class ErlangManuals < Formula
  url 'http://erlang.org/download/otp_doc_man_R14B03.tar.gz'
  md5 '357f54b174bb29d41fee97c063a47e8f'
end

class ErlangHtmls < Formula
  url 'http://erlang.org/download/otp_doc_html_R14B03.tar.gz'
  md5 'c9033bc35dbe4631dd2d14a6183b966a'
end

class ErlangHeadManuals < Formula
  url 'http://erlang.org/download/otp_doc_man_R14B03.tar.gz'
  md5 '357f54b174bb29d41fee97c063a47e8f'
end

class ErlangHeadHtmls < Formula
  url 'http://erlang.org/download/otp_doc_html_R14B03.tar.gz'
  md5 'c9033bc35dbe4631dd2d14a6183b966a'
end

class Erlang < Formula
  homepage 'http://www.erlang.org'
  # Download tarball from GitHub; it is served faster than the official tarball.
  url 'https://github.com/erlang/otp/tarball/OTP_R14B03'
  md5 '047f246c4ecb5fadaffb7e049795d80e'
  version 'R14B03'

  bottle 'https://downloads.sf.net/project/machomebrew/Bottles/erlang-R14B03-bottle.tar.gz'
  bottle_sha1 '9b7605c7cf2a7dd0536723e487722e29bd2d2d9b'

  head 'https://github.com/erlang/otp.git', :branch => 'dev'

  # We can't strip the beam executables or any plugins, there isn't really
  # anything else worth stripping and it takes a really, long time to run
  # `file` over everything in lib because there is almost 4000 files (and
  # really erlang guys! what's with that?! Most of them should be in share/erlang!)
  # may as well skip bin too, everything is just shell scripts
  skip_clean ['lib', 'bin']

  def options
    [
      ['--disable-hipe', "Disable building hipe; fails on various OS X systems."],
      ['--time', '"brew test --time" to include a time-consuming test.'],
      ['--no-docs', 'Do not install documentation.']
    ]
  end

  fails_with_llvm "See https://github.com/mxcl/homebrew/issues/issue/120", :build => 2326

  def install
    ohai "Compilation may take a very long time; use `brew install -v erlang` to see progress"
    ENV.deparallelize

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-kernel-poll",
            "--enable-threads",
            "--enable-dynamic-ssl-lib",
            "--enable-smp-support"]

    unless ARGV.include? '--disable-hipe'
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << '--enable-hipe'
    end

    args << "--enable-darwin-64bit" if MacOS.prefer_64_bit?

    system "./configure", *args
    system "touch lib/wx/SKIP" if MacOS.snow_leopard?
    system "make"
    system "make install"

    unless ARGV.include? '--no-docs'
      manuals = ARGV.build_head? ? ErlangHeadManuals : ErlangManuals
      manuals.new.brew { man.install Dir['man/*'] }

      htmls = ARGV.build_head? ? ErlangHeadHtmls : ErlangHtmls
      htmls.new.brew { doc.install Dir['*'] }
    end
  end

  def test
    `#{bin}/erl -noshell -eval 'crypto:start().' -s init stop`

    # This test takes some time to run, but per bug #120 should finish in
    # "less than 20 minutes". It takes a few minutes on a Mac Pro (2009).
    if ARGV.include? "--time"
      `#{bin}/dialyzer --build_plt -r #{lib}/erlang/lib/kernel-2.14.1/ebin/`
    end
  end
end
