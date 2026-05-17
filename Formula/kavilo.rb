class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.14.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.0/kavilo_darwin_arm64.zip"
      sha256 "ebaec2ce11a55efcacdd7d278dfca4aaacd6f6ab65ac9d63cc9160224169efb9"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.0/kavilo_darwin_amd64.zip"
      sha256 "122def8d3a48ddc3ed72ba1ed68a3500b8da196d80c48400f33cc8b53531dc8f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.0/kavilo_linux_arm64.tar.gz"
      sha256 "a399c1da7f89670f301a5f91ec763b05a35e2f8becbb82d43d1bec156c5614dd"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.0/kavilo_linux_amd64.tar.gz"
      sha256 "fc1ad4ff99e5c13fa1eecdba5d3ab8418c0798d6da412bcefe10c9a0fd49410e"
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
