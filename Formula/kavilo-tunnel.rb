class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://kavilo-bot.github.io/homebrew-tap/"
  version "0.1.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.4/kavilo-tunnel-v0.1.4-darwin-arm64.tar.gz"
      sha256 "5aa3343f9b57c74352f1e13c32d377efcbacde1551df10ab6cf33b4a2072109f"
    else
      odie "Intel macOS build is not published in v0.1.4."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.4/kavilo-tunnel-v0.1.4-linux-amd64.tar.gz"
      sha256 "8919f57e7997831ccc0eff3b3e0bd9a4b0116a5309c7d7e92fa6f4d4beece99d"
    else
      odie "Linux arm64 build is not published in v0.1.4."
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
    assert_match "kavilo-tunnel 0.1.4", shell_output("#{bin}/kavilo-tunnel --version")
  end
end
