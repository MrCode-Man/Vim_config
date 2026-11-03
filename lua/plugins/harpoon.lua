-- Harpoon: marca até 5 arquivos do projeto e pula entre eles com uma tecla
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local function lista() return require("harpoon"):list() end

      local teclas = {
        { "<leader>a", function() lista():add() end,    desc = "Harpoon: marcar arquivo atual" },
        { "<leader>A", function() lista():remove() end, desc = "Harpoon: desmarcar arquivo atual" },
        { "<leader>e", function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end, desc = "Harpoon: abrir lista (dd remove, reordena com d/p)" },

        -- Ctrl+Tab só funciona em terminais que o enviam (kitty, wezterm, foot...).
        -- No Windows Terminal/WSL costuma chegar como Tab simples; use Ctrl+P / Ctrl+N.
        { "<C-Tab>",   function() lista():next({ ui_nav_wrap = true }) end, desc = "Harpoon: próximo arquivo" },
        { "<C-S-Tab>", function() lista():prev({ ui_nav_wrap = true }) end, desc = "Harpoon: arquivo anterior" },
        { "<C-p>",     function() lista():next({ ui_nav_wrap = true }) end, desc = "Harpoon: próximo arquivo" },
        { "<C-n>",     function() lista():prev({ ui_nav_wrap = true }) end, desc = "Harpoon: arquivo anterior" },
      }

      -- <leader>1 .. <leader>5 pulam direto pro arquivo da posição
      for i = 1, 5 do
        teclas[#teclas + 1] = {
          "<leader>" .. i,
          function() lista():select(i) end,
          desc = "Harpoon: ir para o arquivo " .. i,
        }
      end
      return teclas
    end,
    config = function()
      require("harpoon"):setup({
        settings = { save_on_toggle = true, sync_on_ui_close = true },
      })
    end,
  },
}
