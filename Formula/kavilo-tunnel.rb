class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://kavilo-bot.github.io/homebrew-tap/"
  version "0.1.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.5/kavilo-tunnel-v0.1.5-darwin-arm64.tar.gz"
      sha256 "b0f6d2fe545bd4a5f0b6633cd659b45e6ccd05da62b1943253a5d1472fbaf5b1"
    else
      odie "Intel macOS build is not published in v0.1.5."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.5/kavilo-tunnel-v0.1.5-linux-amd64.tar.gz"
      sha256 "2ad1d82a1246f1ddae7e2832b1bf8e46d8210d8980edae4a4fddedb4e275580e"
    else
      odie "Linux arm64 build is not published in v0.1.5."
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
    assert_match "kavilo-tunnel 0.1.5", shell_output("#{bin}/kavilo-tunnel --version")
  end
end
