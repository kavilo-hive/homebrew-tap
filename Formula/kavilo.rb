class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.15.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.15.0/kavilo_darwin_arm64.zip"
      sha256 "f8f722b583e055c2e6839ef3d7c21da018b7f641ae81f9b6a033975ea0c88fae"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.15.0/kavilo_darwin_amd64.zip"
      sha256 "f6212675a859f1654f8d84ab193951d107e67b40fdd64879c0f2f4bb74a5d26d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.15.0/kavilo_linux_arm64.tar.gz"
      sha256 "0b0fb29ba6533960851a8ef0ef2a8e24c64048660f93bcc4d88ea4541dd1ccd7"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.15.0/kavilo_linux_amd64.tar.gz"
      sha256 "73ce091208e25188552d416bfc90e5a8aabcafb5e23e3539a611e54e8a507fb8"
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
