class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.16.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.16.0/kavilo_darwin_arm64.zip"
      sha256 "ef1a41f615b21e003a6196e67b1724c2b9c47d11e58d3d78e34d721d2f2a4017"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.16.0/kavilo_darwin_amd64.zip"
      sha256 "236c26010c68a009b0bf04051b2aac362607b0e0a4e7b59797853e22202e3f24"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.16.0/kavilo_linux_arm64.tar.gz"
      sha256 "bef775be088bf7d4fb263705b399c0b2f22b40792cae4dc3fe5c60b63053e0fe"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.16.0/kavilo_linux_amd64.tar.gz"
      sha256 "cce0f671ffda9597fd2068816ab2ced1471a741a2c8e527b7fd87ab9086cf528"
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
