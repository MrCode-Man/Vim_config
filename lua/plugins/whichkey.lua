return {
  -- Ao apertar uma tecla de atalho (ex.: <leader>) e esperar, mostra um menu
  -- com tudo que pode vir depois e a descrição (desc) de cada atalho.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300, -- ms parado até o menu aparecer (mesmo valor do timeoutlen)
      spec = {
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "Dividir tela" },
        { "<leader>t", group = "Telescope" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Atalhos: mostrar os do buffer atual",
      },
    },
  },
}
