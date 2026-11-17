-- Rust: rust-analyzer com tudo que e semantico ligado + clippy
return {
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
          allTargets = true,
          features = "all",
          extraArgs = { "--", "-W", "clippy::pedantic" }, -- lints extras do clippy (barulhento)
        },
        cargo = {
          allFeatures = true,
          targetDir = true, -- build separado: nao trava o seu cargo build/run (lock)
          buildScripts = { enable = true },
        },
        procMacro = { enable = true },
        diagnostics = {
          experimental = { enable = true },
          styleLints = { enable = true }, -- sugestoes de codigo idiomatico
        },
        imports = {
          granularity = { group = "module" },
          prefix = "self",
        },
        completion = {
          autoimport = { enable = true },
          fullFunctionSignatures = { enable = true },
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
