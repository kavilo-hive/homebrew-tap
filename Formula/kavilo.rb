class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.2/kavilo_darwin_arm64.zip"
      sha256 "cab65041e61c097a63f97ea1a032246ad23fd190dd71a95970bae7864e7dd84a"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.2/kavilo_darwin_amd64.zip"
      sha256 "e90e9df743dc1e2880e968222780f1165bdfcfa8f8f09326a4da046d00c76020"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.2/kavilo_linux_arm64.tar.gz"
      sha256 "a31e0c43a5889744e1f1f6718073bd253f0a8ad5f812f6d8409496c9f91ffa99"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.2/kavilo_linux_amd64.tar.gz"
      sha256 "2179e2fef5d10c4806bdde92b8c3859cae00d801519c60a1d20ae7c2375a63ea"
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
