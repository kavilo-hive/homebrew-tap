class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.0/kavilo_darwin_arm64.zip"
      sha256 "8eef2bcaf75d466b7eaecde49c88bddf863b2a82512b2677aa7af437c38e2992"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.0/kavilo_darwin_amd64.zip"
      sha256 "7de7e5d6e445473ee2ad9bc0be0eb8d9ce74dbaeffc4ceb8a222f7374075ba25"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.0/kavilo_linux_arm64.tar.gz"
      sha256 "7998826958bd794f030544ffbce1a55ebb8f2bdd7f51ebf5f1ee5bc6447baadb"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.0/kavilo_linux_amd64.tar.gz"
      sha256 "e55bc06eb7a3d056db0e9c3b952bb4ab00476c255adfaa15c377011cde8b29f4"
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
