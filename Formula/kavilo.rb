class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.7.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.7.0/kavilo_darwin_arm64.zip"
      sha256 "6429be218c88da370919940eb59fbe005904d30b25c2777ba178410152bc02fa"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.7.0/kavilo_darwin_amd64.zip"
      sha256 "0c0b5a841b83f59936f4d6376f0bdbe425b91d787bf194da43687244bd17d9d6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.7.0/kavilo_linux_arm64.tar.gz"
      sha256 "bd73d0a89d66e49601d606c1329ef6ed7f313adf28e7ce0f042fcfc4af00cd85"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.7.0/kavilo_linux_amd64.tar.gz"
      sha256 "ac86bf46de90a0dc751919e2388991cd88465aa210736d0a5b3a73b98642d147"
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
