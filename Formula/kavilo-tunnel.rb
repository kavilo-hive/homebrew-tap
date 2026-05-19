class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://kavilo-bot.github.io/homebrew-tap/"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.2/kavilo-tunnel-v0.1.2-darwin-arm64.tar.gz"
      sha256 "fcdf89c0d5faaa35a4a90506b1fe67bbb504fa10cd4223eaeb4ca5b031d84160"
    else
      odie "Intel macOS build is not published in v0.1.2."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.2/kavilo-tunnel-v0.1.2-linux-amd64.tar.gz"
      sha256 "87dd835abb45e43a4b7e3b0fea744d1ace9c38223f53beb3204af0bd210670b7"
    else
      odie "Linux arm64 build is not published in v0.1.2."
    end
  end

  def install
    bin.install "kavilo-tunnel"
    doc.install "README.md", "USER-GUIDE.md"
  end

  def caveats
    <<~CAVEATS
      First-time setup:
        kavilo-tunnel login --token <your-token> --endpoint https://<base-host>:7777

      Open a tunnel:
        kavilo-tunnel tunnel --url http://127.0.0.1:3000 --name myapp
    CAVEATS
  end

  test do
    assert_match "kavilo-tunnel 0.1.2", shell_output("#{bin}/kavilo-tunnel --version")
  end
end
