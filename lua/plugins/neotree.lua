return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<Bslash>", "<cmd>Neotree toggle<CR>", desc = "Arquivos: abrir/fechar Neo-tree" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
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
    },
  },
}
