class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.4.0/kavilo_darwin_arm64.zip"
      sha256 "dc7eb96ddae9e5f588293e4b60591228d1d4125383159bcd6d48de5da155d631"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.4.0/kavilo_darwin_amd64.zip"
      sha256 "c37f9c4e3bbef5689bac3da3d060d759c610c9c6c151613010c03c26c0c615af"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.4.0/kavilo_linux_arm64.tar.gz"
      sha256 "5792eb4e93db7ac36e36120ef8f9b7b319d2235aa3121c091bf74ad986728550"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.4.0/kavilo_linux_amd64.tar.gz"
      sha256 "fce65e160261db7fb2a10b1b28ef7f98640f57f66ff0b05776e9adfc7ccea9c7"
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
