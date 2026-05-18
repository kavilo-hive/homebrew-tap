class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.5/kavilo_darwin_arm64.zip"
      sha256 "a1680cce35f1e6b9f5f6be06348d48c92413d06fe2f49745c6e9010011aa8a8b"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.5/kavilo_darwin_amd64.zip"
      sha256 "8e8bc80150b9a111df57828b0b23bc325abbf85f8615907d32c11c2ca05e19d9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.5/kavilo_linux_arm64.tar.gz"
      sha256 "6c7a6f5c4b0cf841450e2615300c5b9703feae9a001bd367501f903254569831"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.5/kavilo_linux_amd64.tar.gz"
      sha256 "a2e4816c8bebdac4c8db431807570927790300a9daadf5fe73b340a736de8ecd"
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
