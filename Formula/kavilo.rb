class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.7/kavilo_darwin_arm64.zip"
      sha256 "b970261ad631ce7e6fa072fae2e709932a1c288b0d1c142015bbc91658568bd1"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.7/kavilo_darwin_amd64.zip"
      sha256 "28dc695bf56288d00ddc46813cc4398e814e6720d0ac1ad97ae02058becea735"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.7/kavilo_linux_arm64.tar.gz"
      sha256 "6bb2560269022944852dc51ab19fc011d319f7e0ac90405cf19bad911b808d53"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.7/kavilo_linux_amd64.tar.gz"
      sha256 "53ccb7af3bb50ca91ccf61dbad545edee7f55c482ec31ac6944478396fe12d33"
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
