class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.1/kavilo_darwin_arm64.zip"
      sha256 "57bf1acba5171486fae54bb48347ea83cb4d59eb0416633878cfd405cae5c655"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.1/kavilo_darwin_amd64.zip"
      sha256 "f0c294a1c08154d69f91766dda612fd846695af8c4fc218cbc18f7067a3aa053"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.1/kavilo_linux_arm64.tar.gz"
      sha256 "a80b8e31a1a67f92771cd73f7b4e918c301e057a9ab5aeaff62a5e404ff16e64"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.1/kavilo_linux_amd64.tar.gz"
      sha256 "dfd918ec01344ad35ce7f5e5e6bf7266709eab85c62f24e69199da9ce4ed5d26"
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
