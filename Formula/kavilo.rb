class Kavilo < Formula
  desc "A lightweight personal AI assistant — single binary, zero dependencies"
  homepage "https://github.com/kavilo-bot/kavilo"
  version "0.18.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.4/kavilo_darwin_arm64.zip"
      sha256 "07a29815279a115299e08af573f12147b3f8f4919763f1bcea3bc7ec10303df2"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.4/kavilo_darwin_amd64.zip"
      sha256 "9745ddc4760c862338757a76b27c0ecacb0879df3a08df31a185f935b51055cd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.4/kavilo_linux_arm64.tar.gz"
      sha256 "a62afe1a7e02bf324934afee2d7a5d1fd604cd4c2f2f35c323e53ff63c3e3c91"
    else
      url "https://github.com/kavilo-bot/homebrew-tap/releases/download/v0.18.4/kavilo_linux_amd64.tar.gz"
      sha256 "ebb1adf09f614de99b9c78ee36ed6ce88fb9b97d8c1632897c136fbb0d633770"
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
