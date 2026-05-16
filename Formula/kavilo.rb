class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.3.0/kavilo_darwin_arm64.zip"
      sha256 "152ae7abbbd02eb36a1eb52442d60b15ada6039f52e7f0575ead2e8c65518990"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.3.0/kavilo_darwin_amd64.zip"
      sha256 "3fa75e0636b74327085eefa17904e54bfd5554c6dcbbc17944aae04f17e15165"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.3.0/kavilo_linux_arm64.tar.gz"
      sha256 "94242f1f3fd7b0ebb92718c7ba4f9072e00895cb2d9c776d0d1b895887c56a21"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.3.0/kavilo_linux_amd64.tar.gz"
      sha256 "0ceac4b7fd7ea30e83bc79b244f5ab4dcd87ff249756d11f714d25dfb1eaafb3"
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
