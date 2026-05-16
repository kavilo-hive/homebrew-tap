class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "2.0.0-alpha.12"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v2.0.0-alpha.12/kavilo_darwin_arm64.zip"
      sha256 "716dcd7b37b50ddc9f47d1c038cbd2e60022737fc9605cf018b787a1cd8373cf"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v2.0.0-alpha.12/kavilo_darwin_amd64.zip"
      sha256 "b8a246dcea102013c2a47ce3dc7e6eba7bdb61c982b7097b6aa5346bf39b6bc8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v2.0.0-alpha.12/kavilo_linux_arm64.tar.gz"
      sha256 "1ac6218547bbd3b93732989d2ec2abc8b0f65b15954b8ca872e26739a44790ab"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v2.0.0-alpha.12/kavilo_linux_amd64.tar.gz"
      sha256 "b515b51b65887ff9bff6d4e0ea0da5104e7bb901e19efbbb6d3a90639e1d9984"
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
