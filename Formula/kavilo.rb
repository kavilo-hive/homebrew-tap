class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.19.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.19.0/kavilo_darwin_arm64.zip"
      sha256 "25c3c59a5d9baba3e94acbcf0def25c8bdf53a498a6a7f41fb59d72383112e26"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.19.0/kavilo_darwin_amd64.zip"
      sha256 "a35e18b7c05a37950c3bd8277bbc425d1ccdf433f17ec085474c1443322d7d30"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.19.0/kavilo_linux_arm64.tar.gz"
      sha256 "cc479a60102e49ef4bf266f94d8d56b9380ccd6285660b4b6a49c56d0de92e89"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.19.0/kavilo_linux_amd64.tar.gz"
      sha256 "b907ec300304a1f36f0898eaedbe699e20e48e92d1a021f8645acc68ca2c7255"
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
