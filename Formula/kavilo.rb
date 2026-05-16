class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.6.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.6.0/kavilo_darwin_arm64.zip"
      sha256 "72ae7aaabdba510413c8d69d0bda26c2521620ccdbb7f11e48c08840b9ff940e"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.6.0/kavilo_darwin_amd64.zip"
      sha256 "f3d45f8ecb086e24be43742a01ef7b111efe0431883573a3f130b25c4bacf107"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.6.0/kavilo_linux_arm64.tar.gz"
      sha256 "e13f5fa7682170ea1c639527c1c14bc6311b1b469a9aa92bba00159bfd94128c"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.6.0/kavilo_linux_amd64.tar.gz"
      sha256 "960d55ff9956c5408b4a82cd263b16472490f9371ca879155eb6e9bbb62fde10"
    end
  end

  def install
    bin.install "kavilo"
  end

  service do
    run [opt_bin/"kavilo", "start"]
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path var/"log/kavilo.log"
    error_log_path var/"log/kavilo.err.log"
  end

  def caveats
    <<~CAVEATS
      To run kavilo in the background and restart it at login:
        brew services start kavilo

      To stop it:
        brew services stop kavilo

      On macOS, screen capture is usually more reliable when kavilo is launched
      from a GUI terminal app that already has Screen Recording permission.
    CAVEATS
  end

  test do
    system "#{bin}/kavilo", "version"
  end
end
