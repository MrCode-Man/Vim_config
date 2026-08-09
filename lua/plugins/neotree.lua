return {
  -- Dependências necessárias para o Neo-tree funcionar e exibir ícones
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },

  -- Configuração do Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = {
          width = 30, -- Largura da barra lateral
        },
        filesystem = {
          filtered_items = {
            visible = true, -- Mostra arquivos ocultos (tipo .gitignore, .config)
          },
          follow_current_file = {
            enabled = true, -- Foca automaticamente no arquivo que você está editando
          },
        },
      })

      -- O atalho que você pediu: aperta \ no modo Normal para abrir/fechar
      vim.keymap.set("n", "<Bslash>", "<cmd>Neotree toggle<CR>", { desc = "Abrir/Fechar Neo-tree" })
    end,
  },
}
