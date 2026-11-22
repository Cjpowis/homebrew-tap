class Transclip < Formula
  desc "YouTube transcripts straight to your clipboard, even over SSH"
  homepage "https://github.com/Cjpowis/transclip"
  url "https://github.com/Cjpowis/transclip/releases/download/v0.2.0/transclip-0.2.0-aarch64-apple-darwin.tar.gz"
  sha256 "fb87d4d512fd3130ef1c265b37b5e913665fb32d72f4b1235baa729db8553730"
  license "MIT"

  depends_on arch: :arm64
  depends_on "ffmpeg"
  depends_on :macos
  depends_on "yt-dlp"

  # NVIDIA's speech model, installed with Transclip so it's there from the
  # first video without captions. The same files, at the same fixed commit and
  # with the same SHA-256s, as FILES in Transclip's src/transcribe.rs.
  # Transclip looks for them in share/transclip/models.
  MODEL_URL = "https://huggingface.co/bobNight/parakeet-unified-en-0.6b-onnx/resolve/09e9060322d99c5f070010724786e6ee090fd51d".freeze

  resource "tokenizer.model" do
    url "#{MODEL_URL}/tokenizer.model"
    sha256 "07d4e5a63840a53ab2d4d106d2874768143fb3fbdd47938b3910d2da05bfb0a9"
  end

  resource "vocab.txt" do
    url "#{MODEL_URL}/vocab.txt"
    sha256 "ae61c9b743cb47c04ce6fb130444210646ed0f40c953c77ee1855185960af94f"
  end

  resource "decoder_joint.int8.onnx" do
    url "#{MODEL_URL}/decoder_joint.int8.onnx"
    sha256 "7f76ad5f35035f25630075699c6c942a2c0c05ff42cb398f966f3c256d148e1e"
  end

  resource "encoder.int8.onnx.data" do
    url "#{MODEL_URL}/encoder.int8.onnx.data"
    sha256 "3d54dd04646c15677bd2844a84df3770b12cc1ce183481f7b6e0def31c92114a"
  end

  resource "encoder.int8.onnx" do
    url "#{MODEL_URL}/encoder.int8.onnx"
    sha256 "c81adfab77634e00c1668a221a14f244c5fb3409e7c14eeebaf6ac963425910f"
  end

  def install
    bin.install "transclip"
    # The names Transclip's speech library looks for. The encoder's weights
    # keep their name, because the encoder file refers to them by it.
    model = pkgshare/"models/parakeet-unified-en-0.6b-int8"
    {
      "tokenizer.model"         => "tokenizer.model",
      "vocab.txt"               => "vocab.txt",
      "decoder_joint.int8.onnx" => "decoder_joint.onnx",
      "encoder.int8.onnx.data"  => "encoder.int8.onnx.data",
      "encoder.int8.onnx"       => "encoder.onnx",
    }.each do |remote, local|
      resource(remote).stage { model.install remote => local }
    end
  end

  def caveats
    <<~EOS
      For the most reliable YouTube downloads, switch yt-dlp to its latest code:
        brew reinstall --HEAD yt-dlp
      and update it now and then with:
        brew upgrade --fetch-HEAD yt-dlp

      NVIDIA's speech model (about 650 MB) is installed with Transclip, and
      removed with it by brew uninstall transclip.
    EOS
  end

  test do
    assert_match "transclip", shell_output("#{bin}/transclip --version")
    assert_path_exists pkgshare/"models/parakeet-unified-en-0.6b-int8/encoder.onnx"
  end
end
