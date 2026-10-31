class GptzeroSkill < Formula
  desc "GPTZero document review skill for Claude Code and Codex"
  homepage "https://github.com/volkmar/skills"
  url "https://github.com/volkmar/skills/releases/download/gptzero-skill-v0.1.0/gptzero-skill-0.1.0.tar.gz"
  sha256 "c4843491ad9efb2647a8c3f7369cab483613cc3ed1fd1927639e6f6c3ca7ccd4"

  depends_on "python@3.14"

  def install
    libexec.install "skills", "tools"
    python = formula_opt_bin("python@3.14")/"python3.14"
    (bin/"gptzero-check").write <<~SH
      #!/bin/sh
      exec "#{python}" "#{opt_libexec}/skills/gptzero-check/scripts/check_text.py" "$@"
    SH
    (bin/"gptzero-skill").write <<~SH
      #!/bin/sh
      exec "#{python}" "#{opt_libexec}/tools/gptzero/manage_skill.py" --source "#{opt_libexec}/skills/gptzero-check" "$@"
    SH
  end

  def caveats
    <<~EOS
      Register for automatic discovery in Claude Code and Codex:
        gptzero-skill install
      Verify and save your GPTZero API key (hidden prompt):
        gptzero-check login
      Also accepts GPTZERO_API_KEY or ZERO_API_KEY in .env.
      Default target: human classification with >=90% human probability.
      The agent revises within a default budget of five scans per document.
      GPTZero API access is required; scans consume your API quota.
      Use --agent claude or --agent codex to register for only one agent.
    EOS
  end

  test do
    result = JSON.parse(pipe_output("#{bin}/gptzero-check --dry-run", "Hello world\n", 0))
    assert_equal false, result.fetch("request_sent")
    assert_equal 12, result.fetch("characters")
    system bin/"gptzero-skill", "install", "--skills-dir", testpath/"skills"
    assert_path_exists testpath/"skills/gptzero-check/SKILL.md"
    system bin/"gptzero-skill", "uninstall", "--skills-dir", testpath/"skills"
    refute_path_exists testpath/"skills/gptzero-check"
  end
end
