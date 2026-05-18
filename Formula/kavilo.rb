class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.3/kavilo_darwin_arm64.zip"
      sha256 "9dc3c1b4cd3d5c9b8a2a2820c2200b79c488ad400ac87e66a1cf21d8cea94994"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.3/kavilo_darwin_amd64.zip"
      sha256 "4e7cf42387d56cb1c04e915244824f2673ebb2bc11c80a0b72a250a769f4415a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.3/kavilo_linux_arm64.tar.gz"
      sha256 "bacf8b148d9295914c42abeb4ea92ab21281884acf2e1d5bcf97662abb8ca2fb"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.3/kavilo_linux_amd64.tar.gz"
      sha256 "77e764254ee9799ffdf3d8a54cfb269fbe66a9366d2003c95698998daf85b43f"
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
