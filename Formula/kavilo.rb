class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.1.0/kavilo_darwin_arm64.zip"
      sha256 "5bce834176c5a1b306470c7c3224a0939a52419d86cf96e6a2f3fa218c4e007b"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.1.0/kavilo_darwin_amd64.zip"
      sha256 "ca36baae76fadd90b4973c2fa25b6100b9da169e6d62983056326886e7ac97bb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.1.0/kavilo_linux_arm64.tar.gz"
      sha256 "e05b84d167d965ba2679d662ef0187a714a18ed86aa59d96ef5829929f5644b4"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.1.0/kavilo_linux_amd64.tar.gz"
      sha256 "e70a91648472889ac4f99af8c35f81113c21a5c059164615bb395c050531a880"
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
