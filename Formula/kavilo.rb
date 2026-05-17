class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.13.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.13.0/kavilo_darwin_arm64.zip"
      sha256 "3e7dcc4011342c769b7a866db9e09f820569fe8a4aa6a6c23099aa5a3b66a288"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.13.0/kavilo_darwin_amd64.zip"
      sha256 "4fa9c76a499b48d2baf44f5efe47f3d25c04471dbbccc2ef95bc10e6df712c54"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.13.0/kavilo_linux_arm64.tar.gz"
      sha256 "24c1121edd031beff79877630f98e204676f2df5efaa009a7209f26cfec6ff85"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.13.0/kavilo_linux_amd64.tar.gz"
      sha256 "1feb8c9828a4fbd058711fdffb9bd12b309ea2bfc5014b95182403be00fca98c"
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
