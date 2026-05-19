class KaviloTunnel < Formula
  desc "Expose a local HTTP service on the public internet via a kavilo tunnel"
  homepage "https://github.com/kavilo-bot/kavilo-tunnel"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/kavilo-tunnel/releases/download/v0.1.0/kavilo-tunnel-v0.1.0-darwin-arm64.tar.gz"
      sha256 "1da31e6cf3d1e7a51274d82f93c9c0c8cb71c9a84dd04eac20ed879210918863"
    else
      odie "Intel macOS build is not published in v0.1.0. Build from source: `cargo install --git https://github.com/kavilo-bot/kavilo-tunnel kavilo-tunnel`."
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/kavilo-bot/kavilo-tunnel/releases/download/v0.1.0/kavilo-tunnel-v0.1.0-linux-amd64.tar.gz"
      sha256 "fae366388571968a83a34c6094d258f4af0376ce0ba73142a38f2c29ba8cfbb9"
    else
      odie "Linux arm64 build is not published in v0.1.0. Build from source."
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
    assert_match "kavilo-tunnel 0.1.0", shell_output("#{bin}/kavilo-tunnel --version")
  end
end
