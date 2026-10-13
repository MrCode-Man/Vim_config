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

-- Atalhos de linha de comando: ao digitar a palavra INTEIRA, ela vira o comando.
-- Só dispara com a linha igual a palavra, então :read, :redo, :resize etc. funcionam.
--   :cmd  -> :terminal
--   :reno -> :%s/   (renomear/substituir no arquivo todo)
local atalhos_de_comando = {
  cmd  = "terminal",
  reno = "%s/",
}

vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup("AtalhosDeComando", { clear = true }),
  callback = function()
    if vim.fn.getcmdtype() ~= ":" then
      return
    end
    local destino = atalhos_de_comando[vim.fn.getcmdline()]
    if destino then
      vim.fn.setcmdline(destino)
    end
  end,
})


-- comentarios coloridos: da palavra (TODO / NOTE / FIXME) ate o fim da linha
local comentarios = {
  { palavra = "TODO",  grupo = "ComentarioTodo",  cor = "#216882" },
  { palavra = "NOTE",  grupo = "ComentarioNote",  cor = "#8F7814" },
  { palavra = "FIXME", grupo = "ComentarioFixme", cor = "#E5336A" },
}

local function definir_cores()
  for _, comentario in ipairs(comentarios) do
    vim.api.nvim_set_hl(0, comentario.grupo, { fg = comentario.cor })
  end
end

local function janela_ja_tem_o_destaque(grupo)
  for _, destaque in ipairs(vim.fn.getmatches()) do
    if destaque.group == grupo then
      return true
    end
  end
  return false
end

local function janela_eh_flutuante()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

-- \v = "very magic", \C = diferencia maiusculas (por causa do seu ignorecase)
-- o padrao exige um marcador de comentario (# // -- /* * ") antes da palavra
local function padrao_do_comentario(palavra)
  return [[\v\C(#|//|--|/\*|\*|")\s*\zs<]] .. palavra .. [[>.*]]
end

local function colorir_comentarios_da_janela()
  if janela_eh_flutuante() then
    return
  end

  for _, comentario in ipairs(comentarios) do
    if not janela_ja_tem_o_destaque(comentario.grupo) then
      vim.fn.matchadd(comentario.grupo, padrao_do_comentario(comentario.palavra), 200)
    end
  end
end

definir_cores()

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("ComentariosColoridos", { clear = true }),
  callback = colorir_comentarios_da_janela,
})

-- trocar de tema apaga as cores customizadas, entao define de novo
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ComentariosColoridosCores", { clear = true }),
  callback = definir_cores,
})
