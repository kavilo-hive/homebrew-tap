class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://kavilo-bot.github.io/homebrew-tap/"
  version "0.1.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.3/kavilo-tunnel-v0.1.3-darwin-arm64.tar.gz"
      sha256 "e7c3a455538dde48cce7e40e9a27e97d2ecf22d771442b2d04f74059c3d578c6"
    else
      odie "Intel macOS build is not published in v0.1.3."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.3/kavilo-tunnel-v0.1.3-linux-amd64.tar.gz"
      sha256 "45c7f0f6fd028a0135336c528e8f66249439fd30ac0458b7497c02f244ee8c43"
    else
      odie "Linux arm64 build is not published in v0.1.3."
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
    assert_match "kavilo-tunnel 0.1.3", shell_output("#{bin}/kavilo-tunnel --version")
  end
end
