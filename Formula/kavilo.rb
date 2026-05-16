class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.2.0/kavilo_darwin_arm64.zip"
      sha256 "ac39d090ece37e92780a3cf79704b83ea6317a88a81444f40ff78df1afb25b58"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.2.0/kavilo_darwin_amd64.zip"
      sha256 "bd93f1b2d5ea0e6c4151f62a2b1424e548a8ba561c06c6d3fc5d14f7c51d001c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.2.0/kavilo_linux_arm64.tar.gz"
      sha256 "969e70970358c4e39ab2dd88cd3ce19042b040de9bfc56b68211f5ba3ceb8c96"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.2.0/kavilo_linux_amd64.tar.gz"
      sha256 "1abc064c2b95eff9f5cf0db8ca7bbedb91745f03da0cbcb78d804afd08329d5a"
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
