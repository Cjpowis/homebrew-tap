class Transclip < Formula
  desc "YouTube transcripts straight to your clipboard, even over SSH"
  homepage "https://github.com/Cjpowis/transclip"
  url "https://github.com/Cjpowis/transclip/releases/download/v0.1.1/transclip-0.1.1-aarch64-apple-darwin.tar.gz"
  sha256 "58d4952f5f4ef7b9b280ff9f4d9a19731b2ff9a656cabc304da077a7f9ec9424"
  license "MIT"

  depends_on arch: :arm64
  depends_on "ffmpeg"
  depends_on :macos
  depends_on "yt-dlp"

  def install
    bin.install "transclip"
  end

  def caveats
    <<~EOS
      For the most reliable YouTube downloads, switch yt-dlp to its latest code:
        brew reinstall --HEAD yt-dlp
      and update it now and then with:
        brew upgrade --fetch-HEAD yt-dlp

      The first time Transclip transcribes on your Mac it downloads NVIDIA's
      speech model (about 650 MB). To remove it: transclip --delete-model
    EOS
  end

  test do
    assert_match "transclip", shell_output("#{bin}/transclip --version")
  end
end
