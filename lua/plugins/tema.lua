return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        auto_integrations = false,   -- não varre todos os plugins instalados no boot
        integrations = {
          cmp = true, gitsigns = true, telescope = { enabled = true }, treesitter = true,
          neotree = true, harpoon = true, which_key = true, lsp_trouble = true,
          native_lsp = { enabled = true }, dropbar = { enabled = true }, diffview = true, mason = true, treesitter_context = true,
        },
      })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  }
}
