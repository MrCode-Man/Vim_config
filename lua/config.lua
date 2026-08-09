-- 1. NÚMEROS E NAVEGAÇÃO (O que você pediu)
vim.opt.number = true          -- Mostra o número da linha atual
vim.opt.relativenumber = true  -- Linhas relativas (essencial para pular linhas com 10j, 5k, etc.)

-- 2. OPÇÕES ESSENCIAIS DE TODO USUÁRIO DE NVIM
vim.g.mapleader = " "          -- Define a barra de espaço como sua tecla "Leader" (atalho principal)
vim.g.maplocalleader = " "

-- Aparência e Cores
vim.opt.termguicolors = true   -- Ativa suporte a cores de 24-bit (deixa os temas bonitos)
vim.opt.signcolumn = "yes"     -- Deixa a coluna da esquerda sempre aberta para os ícones de erro não ficarem sambando na tela

-- Indentação Inteligente (Padrão para desenvolvimento)
vim.opt.tabstop = 4            -- Largura do Tab igual a 4 espaços
vim.opt.shiftwidth = 4         -- Tamanho da indentação automática
vim.opt.expandtab = true       -- Transforma Tabs em espaços automaticamente
vim.opt.smartindent = true     -- Ativa indentação inteligente baseada na linguagem

-- Comportamento de Telas (Splits)
vim.opt.splitbelow = true      -- Abre novas janelas horizontais para baixo
vim.opt.splitright = true      -- Abre novas janelas verticais para a direita

-- Busca Eficiente
vim.opt.ignorecase = true      -- Ignora maiúsculas/minúsculas na busca...
vim.opt.smartcase = true       -- ...a menos que você digite uma letra maiúscula explicitamente
vim.opt.hlsearch = false       -- Não deixa o texto permanentemente amarelo depois de buscar (evita o desespero de tela poluída)

-- Qualidade de Vida Geral
vim.opt.clipboard = "unnamedplus" -- Sincroniza o CTRL+C / CTRL+V do seu sistema operacional com o Neovim
vim.opt.mouse = ""            -- Permite usar o mouse para rolar ou redimensionar janelas se bater a preguiça
vim.opt.updatetime = 250       -- Deixa o editor mais responsivo para salvar histórico e carregar o LSP 
vim.opt.timeoutlen = 300       -- Tempo de espera para completar um atalho de teclado

-- Mudando :terminal para :cmd
vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup("CmdLowercaseTerminal", { clear = true }),
  callback = function()
    local cmdline = vim.fn.getcmdline()
    if vim.fn.getcmdtype() == ":" and cmdline == "cmd" then
      vim.fn.setcmdline("terminal")
    end
  end,
})

-- %s para re
vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup("CmdLowercaseReplace", { clear = true }),
  callback = function()
    local cmdline = vim.fn.getcmdline()
    if vim.fn.getcmdtype() == ":" and cmdline == "re" then
      vim.fn.setcmdline("%s/")
    end
  end,
})

-- keymaps para foco
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focar na janela da esquerda" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focar na janela de baixo" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focar na janela de cima" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focar na janela da direita" })

-- dividir a tela
vim.keymap.set("n", "<leader>h", "<cmd>leftabove vsplit<CR>", { desc = "Dividir tela para a esquerda" })
vim.keymap.set("n", "<leader>j", "<cmd>belowright split<CR>", { desc = "Dividir tela para baixo" })
vim.keymap.set("n", "<leader>k", "<cmd>leftabove split<CR>", { desc = "Dividir tela para cima" })
vim.keymap.set("n", "<leader>l", "<cmd>belowright vsplit<CR>", { desc = "Dividir tela para a direita" })
