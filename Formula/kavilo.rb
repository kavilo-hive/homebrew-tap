class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.12.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.12.0/kavilo_darwin_arm64.zip"
      sha256 "5abb91e02e6741300ea6616e5c09e15150f1ee53143befd07e46c0160070eb25"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.12.0/kavilo_darwin_amd64.zip"
      sha256 "29eca7811f40fbe642d61ed3a7e1e6bd049b90758dcc5aaeb2096b2b837a74e5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.12.0/kavilo_linux_arm64.tar.gz"
      sha256 "d791613b79adad8f183adc7bd2ce7a77399d099eca5748de6e7cddf6d29c11d6"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.12.0/kavilo_linux_amd64.tar.gz"
      sha256 "bd6b46ec1788151f9922da11d4ad0938a9d4237acb80b7e8c2573845d2a019ba"
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
