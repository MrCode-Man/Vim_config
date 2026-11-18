return {
  -- Renderiza markdown dentro do proprio buffer (titulos, listas, checkboxes,
  -- tabelas, blocos de codigo, citacoes). O texto do arquivo NAO muda: sao
  -- so "virtual text"/conceal desenhados por cima, usando a arvore do Treesitter.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" }, -- so carrega ao abrir um .md (nao pesa no boot)
    -- Atalhos <leader>m (Markdown). Buffer-local: so existem dentro de um .md.
    -- buf_enable/buf_disable valem so pro buffer atual (outros .md nao mudam).
    keys = {
      { "<leader>mv", "<cmd>RenderMarkdown buf_enable<CR>",  ft = "markdown", desc = "Markdown: visualização (renderizado)" },
      { "<leader>me", "<cmd>RenderMarkdown buf_disable<CR>", ft = "markdown", desc = "Markdown: edição (texto cru)" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      file_types = { "markdown" },

      -- Renderiza no modo normal e no visual; no modo de insercao mostra o
      -- texto cru pra voce editar sem a decoracao atrapalhando.
      render_modes = { "n", "c", "t" },

      -- Largura dos blocos de codigo / tabelas segue o texto, nao a janela toda
      code = {
        sign = false,
        width = "block",
        left_pad = 1,
        right_pad = 1,
      },

      heading = {
        sign = false,
        -- Barra de fundo cobrindo so a largura do texto
        width = "block",
        left_pad = 1,
        right_pad = 1,
      },
    },
  },
}
