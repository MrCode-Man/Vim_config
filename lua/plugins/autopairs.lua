return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Só carrega o plugin quando você entrar no modo de inserção (economiza memória)
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- Integração com o Treesitter (se você usar no futuro)
        disable_filetype = { "TelescopePrompt", "spectre_panel" }, -- Desativa em telas de busca onde atrapalharia
      })
    end,
  }
}
