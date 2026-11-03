return {
  -- Formatador de código (conform): ajusta indentação, espaços e imports.
  -- Formata sozinho ao salvar; <leader>lf formata na hora; <leader>lF liga/desliga o automático.
  -- Só carrega quando necessário (primeiro :w, <leader>lf/lF ou :ConformInfo), não no boot.
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    init = function()
      vim.g.formatar_ao_salvar = true
    end,
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ lsp_format = "fallback", async = false, timeout_ms = 1000 })
        end,
        mode = { "n", "v" },
        desc = "LSP: formatar código",
      },
      {
        "<leader>lF",
        function()
          vim.g.formatar_ao_salvar = not vim.g.formatar_ao_salvar
          vim.notify("Formatar ao salvar: " .. tostring(vim.g.formatar_ao_salvar))
        end,
        desc = "LSP: alternar formatar ao salvar",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt", lsp_format = "fallback" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = function()
        if not vim.g.formatar_ao_salvar then
          return nil
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}
