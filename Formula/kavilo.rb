class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.6/kavilo_darwin_arm64.zip"
      sha256 "48d245d81c1965e55bb8f3df8a9c9dca07b41909380a35905e843a19c06fa8c2"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.6/kavilo_darwin_amd64.zip"
      sha256 "1ae0b3ec39fd9c0d183f8805bf7b95af1098ee17c3e8a68f5fc897682e1b26ce"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.6/kavilo_linux_arm64.tar.gz"
      sha256 "a3b469d101904bab1da06556f157535615ea780418ceb375544f35391aaea3a6"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.6/kavilo_linux_amd64.tar.gz"
      sha256 "33efc2ec62d44dd35f4875a7d77a4e393d8e1c924f2bb335d221e2658b7f6473"
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
