-- keymaps para foco entre janelas (usa Ctrl, não leader -> nunca vai conflitar com o resto)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Janela: focar na da esquerda" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Janela: focar na de baixo" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Janela: focar na de cima" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Janela: focar na da direita" })

-- dividir a tela: agrupado sob <leader>s (de "split"), pra não brigar com
-- <leader>g (git), <leader>t (telescope) e <leader>l (lsp)
vim.keymap.set("n", "<leader>sh", "<cmd>leftabove vsplit<CR>",  { desc = "Dividir: para a esquerda" })
vim.keymap.set("n", "<leader>sj", "<cmd>belowright split<CR>",  { desc = "Dividir: para baixo" })
vim.keymap.set("n", "<leader>sk", "<cmd>leftabove split<CR>",   { desc = "Dividir: para cima" })
vim.keymap.set("n", "<leader>sl", "<cmd>belowright vsplit<CR>", { desc = "Dividir: para a direita" })
