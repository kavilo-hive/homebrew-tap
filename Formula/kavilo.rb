class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.9.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.9.0/kavilo_darwin_arm64.zip"
      sha256 "c32c4a0d1daa5812d1e73ef2cddd6b4047051f9eefc71b7dc3190e440be8c828"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.9.0/kavilo_darwin_amd64.zip"
      sha256 "237300476d05733a83ec3f9952cb20b5f16751ef8b7db3a575557eca7183f56e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.9.0/kavilo_linux_arm64.tar.gz"
      sha256 "dbf17d8f4673ce56d9e038cbf8a63546a8c52520bb69096bcfa5b51d82930215"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.9.0/kavilo_linux_amd64.tar.gz"
      sha256 "c1659584fa0087042ac4abdbc9bc8797b8e0a4230fbad7c4d30e79a43d0635f4"
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
