class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.11.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.11.0/kavilo_darwin_arm64.zip"
      sha256 "523556e6c3fb38cec6783fa3fc3c2c7827ed4923fecfb7008bbc3dfda4677f07"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.11.0/kavilo_darwin_amd64.zip"
      sha256 "f8dc7bc0af208632e9c6021477cc2be43936325f43e4e3071f68cfe87d7ba9cd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.11.0/kavilo_linux_arm64.tar.gz"
      sha256 "e3cd26c6109d4f8279ca05b649a2495372a111a83d609cab433a7a5277c233cc"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.11.0/kavilo_linux_amd64.tar.gz"
      sha256 "050bcd982c42cf04bd600e014e7305521af6e6eab15bf225c727d8a3aaa754fd"
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
