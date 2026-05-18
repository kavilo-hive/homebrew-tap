class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.8/kavilo_darwin_arm64.zip"
      sha256 "8e5fe58eafcb48f1d91cb4fdf783ece288166a5a5f5a47770f6bbe123c1e4743"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.8/kavilo_darwin_amd64.zip"
      sha256 "860f29b66405591525e8c2ca8b5535dab74e6dffb54a0a5688c9dd7d500c1a20"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.8/kavilo_linux_arm64.tar.gz"
      sha256 "d09560366a6a2858878f586800486af002122333f07d60d619877dbc0d05eb74"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.8/kavilo_linux_amd64.tar.gz"
      sha256 "8767eb54587bdc98e424245d6070bd4e8fe0c2086bc5ef0ec903e25ffba5682a"
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
