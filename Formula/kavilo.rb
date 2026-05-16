class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.5.0/kavilo_darwin_arm64.zip"
      sha256 "c967da69fa0ab5ae6cc6ef5f37520a197ed7aa3968d9fa6757bfeb157db117af"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.5.0/kavilo_darwin_amd64.zip"
      sha256 "90ab88ecf6aae870c54d866a32ae4401dbfcfbde958b7e6c7b9987a88e35e279"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.5.0/kavilo_linux_arm64.tar.gz"
      sha256 "d4c77fa9ff3a69e5d59f203b2452e93626296f0881565c0d9cdb8b6ce653d50c"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.5.0/kavilo_linux_amd64.tar.gz"
      sha256 "e4cd2c05ba8746cc98045d38269d6605d7daff7a68977c02a47517b67e42fa1b"
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
