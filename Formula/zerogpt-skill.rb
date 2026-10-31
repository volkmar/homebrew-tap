class ZerogptSkill < Formula
  desc "Codex skill for ZeroGPT checks and feedback-guided draft revisions"
  homepage "https://github.com/volkmar/zerogpt-skill"
  url "https://github.com/volkmar/zerogpt-skill/releases/download/v0.1.0/zerogpt-skill-0.1.0.tar.gz"
  sha256 "6508107bfc6e9419249d5d3b5335f1acc5aa0b319fdabe509eee0bdb8924a2e3"

  depends_on "python@3.14"

  def install
    libexec.install "skills", "tools"
    python = formula_opt_bin("python@3.14")/"python3.14"
    (bin/"zerogpt-check").write <<~SH
      #!/bin/sh
      exec "#{python}" "#{opt_libexec}/skills/zerogpt-check/scripts/check_text.py" "$@"
    SH
    (bin/"zerogpt-skill").write <<~SH
      #!/bin/sh
      exec "#{python}" "#{opt_libexec}/tools/manage_skill.py" --source "#{opt_libexec}/skills/zerogpt-check" "$@"
    SH
  end

  def caveats
    <<~EOS
      Register for automatic Codex skill discovery:
        zerogpt-skill install
      Log into your ZeroGPT Business account (hidden password prompt):
        zerogpt-check login
      Default target: AI score <=10%, at most five scans per document.
      Scans require funded API access. Passwords are not saved.
      Existing skills are preserved; see --help for migration options.
    EOS
  end

  test do
    result = JSON.parse(pipe_output("#{bin}/zerogpt-check --dry-run", "Hello world\n", 0))
    assert_equal false, result.fetch("request_sent")
    assert_equal 12, result.fetch("characters")
    system bin/"zerogpt-skill", "install", "--skills-dir", testpath/"skills"
    assert_path_exists testpath/"skills/zerogpt-check/SKILL.md"
    system bin/"zerogpt-skill", "uninstall", "--skills-dir", testpath/"skills"
    refute_path_exists testpath/"skills/zerogpt-check"
  end
end
