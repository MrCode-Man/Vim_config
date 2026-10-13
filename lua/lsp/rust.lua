-- Rust: rust-analyzer com tudo que e semantico ligado + clippy
return {
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
          extraArgs = { "--all-targets", "--all-features" },
        },
        cargo = {
          allFeatures = true,
          buildScripts = { enable = true },
        },
        procMacro = { enable = true },
        diagnostics = {
          experimental = { enable = true },
        },
        semanticHighlighting = {
          strings = { enable = true },
          punctuation = { enable = true, specialization = { enable = true } },
          operator = { enable = true, specialization = { enable = true } },
        },
        inlayHints = {
          typeHints = { enable = true },
          parameterHints = { enable = true },
          chainingHints = { enable = true },
          closureReturnTypeHints = { enable = "with_block" },
          lifetimeElisionHints = { enable = "skip_trivial" },
          bindingModeHints = { enable = true },
        },
        lens = {
          enable = true,
          references = { adt = { enable = true }, method = { enable = true } },
        },
      },
    },
  },
}
