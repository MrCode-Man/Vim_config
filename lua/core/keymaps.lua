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

-- mover linha(s) com Alt+j / Alt+k (ou Alt+setas), como no VSCode.
-- reindenta conforme o novo lugar (==) e, no visual, mantém a seleção
vim.keymap.set("n", "<A-j>", "<cmd>move .+1<CR>==", { desc = "Linha: mover para baixo" })
vim.keymap.set("n", "<A-k>", "<cmd>move .-2<CR>==", { desc = "Linha: mover para cima" })
vim.keymap.set("i", "<A-j>", "<Esc><cmd>move .+1<CR>==gi", { desc = "Linha: mover para baixo" })
vim.keymap.set("i", "<A-k>", "<Esc><cmd>move .-2<CR>==gi", { desc = "Linha: mover para cima" })
vim.keymap.set("v", "<A-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Linhas: mover para baixo" })
vim.keymap.set("v", "<A-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Linhas: mover para cima" })
vim.keymap.set({ "n", "i", "v" }, "<A-Down>", "<A-j>", { remap = true, desc = "Mover para baixo" })
vim.keymap.set({ "n", "i", "v" }, "<A-Up>", "<A-k>", { remap = true, desc = "Mover para cima" })
