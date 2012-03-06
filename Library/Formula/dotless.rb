require 'formula'

class Dotless < Formula
  homepage "http://www.dotlesscss.org/"
  url "https://github.com/downloads/dotless/dotless/dotless-v1.2.1.0.zip"
  md5 "dd06170b2e6a8f943f715977cfcd254d"

  def install
    mono_path = which 'mono'
    unless mono_path
      opoo "mono not found in path"
      puts "You need to install Mono to run this software:"
      puts "http://www.go-mono.com/mono-downloads/download.html"
      exit 1
    end

    (bin+'dotless').write <<-EOF.undent
      #!/bin/bash
      exec "#{mono_path}" "#{libexec}/dotless.Compiler.exe" "$@"
    EOF

    libexec.install Dir['*.exe']
    (share+'dotless').install Dir['*.txt']
  end
end
