-- 1. NÚMEROS E NAVEGAÇÃO (O que você pediu)
vim.opt.number = true          -- Mostra o número da linha atual
vim.opt.relativenumber = true  -- Linhas relativas (essencial para pular linhas com 10j, 5k, etc.)

-- 2. OPÇÕES ESSENCIAIS DE TODO USUÁRIO DE NVIM
vim.g.mapleader = " "          -- Define a barra de espaço como sua tecla "Leader" (atalho principal)
vim.g.maplocalleader = " "

-- Aparência e Cores
vim.opt.termguicolors = true   -- Ativa suporte a cores de 24-bit (deixa os temas bonitos)
vim.opt.signcolumn = "yes"     -- Deixa a coluna da esquerda sempre aberta para os ícones de erro não ficarem sambando na tela
vim.opt.cursorline = true      -- Destaca a linha onde o cursor está
vim.opt.scrolloff = 8          -- Mantém 8 linhas de contexto acima/abaixo do cursor ao rolar
vim.opt.undofile = true        -- Guarda o histórico de desfazer em disco (sobrevive a fechar o arquivo)
vim.opt.showmode = false       -- O modo (INSERT, NORMAL...) já aparece na lualine

-- Indentação Inteligente (Padrão para desenvolvimento)
vim.opt.tabstop = 4            -- Largura do Tab igual a 4 espaços
vim.opt.shiftwidth = 4         -- Tamanho da indentação automática
vim.opt.expandtab = true       -- Transforma Tabs em espaços automaticamente
vim.opt.smartindent = true     -- Ativa indentação inteligente baseada na linguagem

-- Comportamento de Telas (Splits)
vim.opt.splitbelow = true      -- Abre novas janelas horizontais para baixo
vim.opt.splitright = true      -- Abre novas janelas verticais para a direita
vim.opt.cmdheight = 0
vim.o.winborder = "rounded"    -- Borda arredondada em todas as janelas flutuantes (hover, diagnostics...)

-- Busca Eficiente
vim.opt.ignorecase = true      -- Ignora maiúsculas/minúsculas na busca...
vim.opt.smartcase = true       -- ...a menos que você digite uma letra maiúscula explicitamente
vim.opt.hlsearch = false       -- Não deixa o texto permanentemente amarelo depois de buscar (evita o desespero de tela poluída)

-- Qualidade de Vida Geral
vim.opt.clipboard = "unnamedplus" -- Sincroniza o CTRL+C / CTRL+V do seu sistema operacional com o Neovim
vim.opt.mouse = ""             -- Mouse desativado de propósito
vim.opt.updatetime = 300       -- Tempo parado até disparar CursorHold (hover, diagnóstico, destaque de usos) e gravar swap
vim.opt.timeoutlen = 300       -- Tempo de espera para completar um atalho de teclado

