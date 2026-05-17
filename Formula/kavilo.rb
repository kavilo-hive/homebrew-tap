class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.17.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.0/kavilo_darwin_arm64.zip"
      sha256 "244ec7f3f6763c65b18e807cc149e6e926244531c53e4cd48968a28c84fed3ce"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.0/kavilo_darwin_amd64.zip"
      sha256 "5cf536799040a5884a6f9c78008d093f07832986b18c4048cce32f12de6bbf64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.0/kavilo_linux_arm64.tar.gz"
      sha256 "3f4b4228a1f82cb4df735fb3e9a898845b50d2e413b0f8c895e6e9d880a0b510"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.0/kavilo_linux_amd64.tar.gz"
      sha256 "f49e70b398be47cbe72a86e22796f1f40c24ba4da6f04b7fd45781b1f0811c60"
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
