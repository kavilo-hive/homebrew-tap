class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.8.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.8.0/kavilo_darwin_arm64.zip"
      sha256 "48ff54510d9ff5d48336db9c13541ab4098773e360cc870775ffaa8782582fdb"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.8.0/kavilo_darwin_amd64.zip"
      sha256 "5f121e41bbac27b9bbced1eade1e78132c813543c2e377625de8a6810abbe8c5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.8.0/kavilo_linux_arm64.tar.gz"
      sha256 "9d84273532a29031224d4dd6d4c857fee66e95c0fb558e38b1f4e707cd842638"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.8.0/kavilo_linux_amd64.tar.gz"
      sha256 "4a16f16d332e8eb806f783cad3180c14a37c4ce2617a1271075cf077572da6e6"
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
