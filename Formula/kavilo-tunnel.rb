class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://kavilo-bot.github.io/homebrew-tap/"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.2/kavilo-tunnel-v0.1.2-darwin-arm64.tar.gz"
      sha256 "c2722f8d6b6f3489cc42955c3d6296da0335abef87d77a082d425be9b27efcdb"
    else
      odie "Intel macOS build is not published in v0.1.2."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/kavilo-tunnel-v0.1.2/kavilo-tunnel-v0.1.2-linux-amd64.tar.gz"
      sha256 "86d35415dfe68860659f959e5a770c5409e3bdcd9530678d45e70f4bfc325396"
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
