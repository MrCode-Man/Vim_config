return {
  -- Barra de status: modo, git, arquivo, diagnósticos, LSP ativo e posição
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      -- nomes dos servidores LSP anexados ao buffer atual
      local function lsp_ativos()
        local nomes = {}
        for _, cliente in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          nomes[#nomes + 1] = cliente.name
        end
        return #nomes > 0 and table.concat(nomes, ", ") or ""
      end

      return {
        options = {
          theme = "auto", -- acompanha o catppuccin
          globalstatus = true, -- uma barra só, na base da tela
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "diagnostics", { lsp_ativos, icon = "" }, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
}
