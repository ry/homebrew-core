class Gn < Formula
  desc "Generate Ninja - Chromium's build system"
  homepage "https://gn.googlesource.com/gn/"
  url "https://gn.googlesource.com/gn.git",
    :revision => "f5fc06000379fe2c11fc130431e826e860ea6aae"
  version "1547"
  sha256 "8094c4ac075f918fdb28af10e16c9d4e41481702bd14a2c06cffd50fe03de9ba"
  depends_on "ninja" => :build

  def install
    system "python", "build/gen.py"
    system "ninja", "-C", "out/", "gn"
    bin.install "out/gn"
  end

  test do
    # Check we're running the version we think we are.
    assert_match version.to_s, shell_output("#{bin}/gn --version")

    # Mock out a fake toolchain and project.
    (testpath/".gn").write <<~EOS
      buildconfig = "//BUILDCONFIG.gn"
    EOS

    (testpath/"BUILDCONFIG.gn").write <<~EOS
      set_default_toolchain("//:mock_toolchain")
    EOS

    (testpath/"BUILD.gn").write <<~EOS
      toolchain("mock_toolchain") {
        tool("link") {
          command = "echo LINK"
          outputs = [ "{{output_dir}}/foo" ]
        }
      }
      executable("hello") { }
    EOS

    cd testpath
    out = testpath/"out"
    system bin/"gn", "gen", out
    assert_predicate out/"build.ninja", :exist?,
      "Check we actually generated a build.ninja file"
  end
end
