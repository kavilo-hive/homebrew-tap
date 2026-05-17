class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.14.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.3/kavilo_darwin_arm64.zip"
      sha256 "975ac6571f9d90f4af5aa103eef3283b85aec44d86de2d57ce538ef934a5dace"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.3/kavilo_darwin_amd64.zip"
      sha256 "dda8f66e435feb97eaee5e1bdc2fd3a191eb218dced67c9ced132ef971982ddb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.3/kavilo_linux_arm64.tar.gz"
      sha256 "bccf236858e5de32b9d1e46236984d5564a6092d0ffcbfe315de1adc8dfe2f55"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.14.3/kavilo_linux_amd64.tar.gz"
      sha256 "a0a1a9a28ef303654a5b6786e3ed7104c4bd38b854feaa3627419cd774c10f12"
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
