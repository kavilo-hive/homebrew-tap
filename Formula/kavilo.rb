class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.17.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.1/kavilo_darwin_arm64.zip"
      sha256 "7c09f580293644b4dc213793aabb8f291eae4ba047669772602ed9d9ca88455f"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.1/kavilo_darwin_amd64.zip"
      sha256 "68ffeb0653dde0f828092f1ef116d7256ec714dc86b9da7254d3aa0a8e532c04"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.1/kavilo_linux_arm64.tar.gz"
      sha256 "424faa628496890da38abf17f1767059d758787041b4f8b3d48d85979538ee9b"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.17.1/kavilo_linux_amd64.tar.gz"
      sha256 "e7554665edbe678d4b7531acf53c2783a4bfc690980230b691cf701b45b40403"
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
