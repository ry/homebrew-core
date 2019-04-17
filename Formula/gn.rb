class Gn < Formula
  desc "Generate Ninja - Chromium's build system"
  homepage "https://gn.googlesource.com/gn/"

  # gn does not use git tags, but releases of Chromium list a specific commit
  # id. This version of gn is used to build Chromium version 75.0.3767.2.
  # https://github.com/chromium/chromium/blob/75.0.3767.2/DEPS#L291
  url "https://gn.googlesource.com/gn.git",
    :revision => "64b846c96daeb3eaf08e26d8a84d8451c6cb712b"
  version "1554"
  depends_on "ninja"

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
