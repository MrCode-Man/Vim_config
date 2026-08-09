return {
     {
       "nvim-telescope/telescope.nvim",
       tag = "0.1.8", -- Versão estável do plugin
       dependencies = { "nvim-lua/plenary.nvim" },
       config = function()
         local telescope = require("telescope")
         
         telescope.setup({
           defaults = {
             -- Deixa o visual mais limpo e focado no seu código
             theme = "dropdown", 
             sorting_strategy = "ascending",
             layout_config = {
               prompt_position = "top",
             },
           },
         })

         -- ATALHOS DE TECLA (Seguindo o padrão do Espaço como Leader)
         local builtin = require("telescope.builtin")

         -- Espaço + f + f (Find Files): Busca arquivos pelo nome no projeto
         vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope buscar arquivos" })

         -- Espaço + f + g (Live Grep): Busca palavras dentro dos arquivos (usa o ripgrep)
         vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope buscar texto" })

         -- Espaço + f + b (Buffers): Mostra os arquivos que já estão abertos na memória
         vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope listar buffers" })
       end,
     },
   }
