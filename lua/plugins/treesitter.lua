return {
  -- Arvore sintatica: highlight, indentacao e base pros textobjects
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "python", "rust", "c", "cpp", "lua", "vim", "vimdoc", "query",
        "markdown", "markdown_inline", "bash", "json", "toml", "yaml",
        "cmake", "make",
      }

      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
        callback = function(args)
          -- pcall: nao quebra em filetype sem parser
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Mostra a classe/funcao atual fixa no topo (igual sticky lines da JetBrains)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3, trim_scope = "outer" },
  },

  -- Selecionar/mover por estrutura: funcao, classe, parametro
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local move = require("nvim-treesitter-textobjects.move")

      local alvos = {
        { "f", "@function" },
        { "c", "@class" },
        { "a", "@parameter" },
      }

      for _, alvo in ipairs(alvos) do
        local tecla, grupo = alvo[1], alvo[2]
        vim.keymap.set({ "x", "o" }, "a" .. tecla, function() select(grupo .. ".outer", "textobjects") end,
          { desc = "Estrutura: " .. grupo .. " (tudo)" })
        vim.keymap.set({ "x", "o" }, "i" .. tecla, function() select(grupo .. ".inner", "textobjects") end,
          { desc = "Estrutura: " .. grupo .. " (dentro)" })
      end

      -- ]f / [f = proxima/anterior funcao, ]k / [k = proxima/anterior classe
      -- (]c e [c ja sao do git, ]a/[a ficam livres pra parametros)
      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Proxima funcao" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Funcao anterior" })
      vim.keymap.set({ "n", "x", "o" }, "]k", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Proxima classe" })
      vim.keymap.set({ "n", "x", "o" }, "[k", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Classe anterior" })
    end,
  },
}
