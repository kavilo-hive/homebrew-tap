class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.10.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.10.0/kavilo_darwin_arm64.zip"
      sha256 "f0bf575b3b37a352b82d0d0085ad06c4e785eee0cc502c8494d5bb3e4e839ce4"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.10.0/kavilo_darwin_amd64.zip"
      sha256 "7751354e82fa415082384a37f63ba22bfc6a6d048a7b0560fda9c539f2dbea4f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.10.0/kavilo_linux_arm64.tar.gz"
      sha256 "27b77bb158e6135302c54141b2e81a06702ebb576baaf1b4ecca62490209536c"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.10.0/kavilo_linux_amd64.tar.gz"
      sha256 "1c0b2e8104a4c41a31a44d222ab979fec874f2ddeb719e17af853a8bb112a01b"
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
