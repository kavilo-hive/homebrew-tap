class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://kavilo-bot.github.io/homebrew-tap/"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.1/kavilo-tunnel-v0.1.1-darwin-arm64.tar.gz"
      sha256 "9cc4876fe8cc85b6dc192dcbfb60f1265a25042048c0824ec0428f280eff69ef"
    else
      odie "Intel macOS build is not published in v0.1.1."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.1/kavilo-tunnel-v0.1.1-linux-amd64.tar.gz"
      sha256 "f5632cd9ae641d60db3ca10978b403a3daafa673368c61f6593bda1a2a44d2cf"
    else
      odie "Linux arm64 build is not published in v0.1.1."
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

      See the user guide for full details:
        #{HOMEBREW_PREFIX}/share/doc/kavilo-tunnel/USER-GUIDE.md
    CAVEATS
  end

  test do
    assert_match "kavilo-tunnel 0.1.1", shell_output("#{bin}/kavilo-tunnel --version")
  end
end
