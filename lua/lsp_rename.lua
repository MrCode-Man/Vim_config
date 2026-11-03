-- Rename "completo", no estilo JetBrains.
--
-- 1) O LSP (inc-rename) troca o símbolo no código, onde ele sabe que é o mesmo símbolo.
-- 2) Depois do rename, uma busca textual (ripgrep) acha o nome antigo no projeto e
--    oferece trocar SÓ o que está em comentários, strings, docstrings, markdown e
--    arquivos de texto. Ocorrência em CÓDIGO é ignorada de propósito: se o LSP não
--    trocou, é outro símbolo com o mesmo nome (ex.: outra variável em outro escopo).
-- 3) Variações de caixa também entram: calcular_total / calcularTotal / CalcularTotal /
--    CALCULAR_TOTAL / calcular-total viram as variações equivalentes do nome novo.
local M = {}

local nome_antigo

-- ---------------------------------------------------------------------------
-- Variações do nome (snake, camel, pascal, screaming, kebab)
-- ---------------------------------------------------------------------------

local function palavras(nome)
  local s = nome:gsub("([a-z0-9])([A-Z])", "%1_%2"):gsub("([A-Z]+)([A-Z][a-z])", "%1_%2")
  local lista = {}
  for p in s:gmatch("[^_%-%s]+") do
    lista[#lista + 1] = p:lower()
  end
  return lista
end

local function capitalizar(p)
  return p:sub(1, 1):upper() .. p:sub(2)
end

local function formatos(w)
  local pascal = {}
  for i, p in ipairs(w) do
    pascal[i] = capitalizar(p)
  end
  local camel = vim.list_slice(pascal, 1)
  camel[1] = w[1]
  return {
    snake = table.concat(w, "_"),
    kebab = table.concat(w, "-"),
    screaming = table.concat(w, "_"):upper(),
    camel = table.concat(camel),
    pascal = table.concat(pascal),
  }
end

-- lista de { de, para }; o primeiro par é sempre o nome exato
local function pares_de_nomes(antigo, novo)
  local pares = { { antigo, novo } }
  local wa, wn = palavras(antigo), palavras(novo)
  -- nome de uma palavra só não tem variação confiável (evita "Total" no começo de frase)
  if #wa < 2 or #wn < 1 then
    return pares
  end

  local fa, fn = formatos(wa), formatos(wn)
  local vistos = { [antigo] = true }
  for _, chave in ipairs({ "snake", "camel", "pascal", "screaming", "kebab" }) do
    local de, para = fa[chave], fn[chave]
    if not vistos[de] and de ~= para then
      vistos[de] = true
      pares[#pares + 1] = { de, para }
    end
  end
  return pares
end

-- ---------------------------------------------------------------------------
-- Classificação: a ocorrência está em texto (comentário/string/doc) ou em código?
-- ---------------------------------------------------------------------------

-- linguagens em que tudo é texto corrido
local TEXTO_PURO = { markdown = true, text = true, help = true, rst = true, asciidoc = true, gitcommit = true }

-- devolve { texto = true } (tudo vale) ou { root = <nó raiz do treesitter> }
local function carregar_arquivo(arq)
  local f = io.open(arq, "rb")
  if not f then
    return nil
  end
  local fonte = f:read("*a")
  f:close()

  local ft = vim.filetype.match({ filename = arq })
  if not ft or TEXTO_PURO[ft] then
    return { texto = true } -- sem tipo conhecido (.txt, .env, LICENSE...) = texto
  end

  local lang = vim.treesitter.language.get_lang(ft) or ft
  local ok_parser, parser = pcall(function()
    return vim.treesitter.get_string_parser(fonte, lang)
  end)
  if not ok_parser then
    return { texto = true }
  end
  local arvores = parser:parse()
  return { root = arvores[1]:root() }
end

local function esta_em_texto(info, lnum, col)
  if info.texto then
    return true
  end

  local linha, coluna = lnum - 1, col - 1
  local no = info.root:named_descendant_for_range(linha, coluna, linha, coluna + 1)
  while no do
    local tipo = no:type()
    -- f"{nome}" / `${nome}`: dentro da string, mas é código
    if tipo:find("interpolation", 1, true) or tipo:find("substitution", 1, true) then
      return false
    end
    if tipo:find("comment", 1, true) or tipo:find("string", 1, true) then
      return true
    end
    no = no:parent()
  end
  return false
end

-- ---------------------------------------------------------------------------
-- Aplicar as trocas
-- ---------------------------------------------------------------------------

-- Troca uma ocorrência. `desloc` guarda quanto as trocas anteriores empurraram as
-- colunas da mesma linha (o novo nome tem tamanho diferente do antigo).
local function trocar_uma(it, desloc, tocados)
  local existia = vim.fn.bufexists(it.arq) == 1
  local buf = vim.fn.bufadd(it.arq)
  vim.fn.bufload(buf)
  if not existia then
    vim.bo[buf].buflisted = false
  end

  local chave = it.arq .. ":" .. it.lnum
  local col = it.col - 1 + (desloc[chave] or 0)
  local linha = vim.api.nvim_buf_get_lines(buf, it.lnum - 1, it.lnum, false)[1] or ""
  if linha:sub(col + 1, col + #it.de) ~= it.de then
    return false -- o arquivo mudou desde a busca: melhor não mexer
  end

  vim.api.nvim_buf_set_text(buf, it.lnum - 1, col, it.lnum - 1, col + #it.de, { it.para })
  desloc[chave] = (desloc[chave] or 0) + (#it.para - #it.de)
  tocados[buf] = { criado = not existia }
  return true
end

-- salva sem disparar autocmds (não formata nem reorganiza nada além do rename)
local function salvar_tocados(tocados)
  local atual = vim.api.nvim_get_current_buf()
  for buf, info in pairs(tocados) do
    if vim.bo[buf].modified then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("noautocmd silent! write")
      end)
    end
    if info.criado and buf ~= atual and vim.fn.bufwinid(buf) == -1 then
      pcall(vim.api.nvim_buf_delete, buf, {})
    end
  end
end

-- modo = "tudo" ou "revisar" (pergunta uma a uma, com o cursor em cima da ocorrência)
local function aplicar(itens, modo)
  local desloc, tocados = {}, {}
  local trocadas, arquivos, vistos = 0, 0, {}
  local todos = modo == "tudo"

  for i, it in ipairs(itens) do
    local escolha = 1
    if not todos then
      local ok = pcall(function()
        vim.cmd("silent edit " .. vim.fn.fnameescape(it.arq))
        local col = it.col - 1 + (desloc[it.arq .. ":" .. it.lnum] or 0)
        vim.api.nvim_win_set_cursor(0, { it.lnum, col })
        vim.cmd("normal! zz")
        vim.cmd("redraw")
      end)
      if not ok then
        vim.notify("Revisão interrompida: salve ou feche o buffer atual e tente de novo", vim.log.levels.WARN)
        break
      end
      escolha = vim.fn.confirm(
        string.format("[%d/%d] Trocar '%s' por '%s'?", i, #itens, it.de, it.para),
        "&Sim\n&Não\n&Todos os restantes\n&Parar", 1
      )
      if escolha == 3 then
        todos, escolha = true, 1
      end
    end

    if escolha == 4 or escolha == 0 then
      break
    end
    if escolha == 1 and trocar_uma(it, desloc, tocados) then
      trocadas = trocadas + 1
      if not vistos[it.arq] then
        vistos[it.arq] = true
        arquivos = arquivos + 1
      end
    end
  end

  salvar_tocados(tocados)
  vim.cmd("cclose")
  vim.notify(string.format("Trocadas %d ocorrência(s) em %d arquivo(s) (comentários/strings/docs)", trocadas, arquivos))
end

-- ---------------------------------------------------------------------------
-- Busca das sobras
-- ---------------------------------------------------------------------------

local function procurar_sobras(antigo, novo)
  if vim.fn.executable("rg") == 0 then
    vim.notify("Rename: instale o ripgrep (rg) para buscar sobras em comentários/strings", vim.log.levels.WARN)
    return
  end

  local pares = pares_de_nomes(antigo, novo)
  local raiz = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local cmd = {
    "rg", "--vimgrep", "--word-regexp", "--fixed-strings", "--case-sensitive",
    "--max-filesize", "1M",
    "--glob", "!*.lock", "--glob", "!*-lock.json", "--glob", "!*.min.*",
  }
  for _, par in ipairs(pares) do
    vim.list_extend(cmd, { "-e", par[1] })
  end
  vim.list_extend(cmd, { "--", raiz })

  vim.system(cmd, { text = true }, vim.schedule_wrap(function(r)
    local candidatos, em_codigo, cache = {}, 0, {}

    for linha in vim.gsplit(r.stdout or "", "\n", { trimempty = true }) do
      local arq, lnum, col, texto = linha:match("^(.-):(%d+):(%d+):(.*)$")
      if arq then
        lnum, col = tonumber(lnum), tonumber(col)

        -- qual variação casou nessa coluna (a mais longa vence)
        local achado
        for _, par in ipairs(pares) do
          if texto:sub(col, col + #par[1] - 1) == par[1] and (not achado or #par[1] > #achado[1]) then
            achado = par
          end
        end

        if achado then
          if cache[arq] == nil then
            cache[arq] = carregar_arquivo(arq) or false
          end
          local info = cache[arq]
          if info and esta_em_texto(info, lnum, col) then
            candidatos[#candidatos + 1] = {
              arq = arq, lnum = lnum, col = col, de = achado[1], para = achado[2], texto = texto,
            }
          else
            em_codigo = em_codigo + 1
          end
        end
      end
    end

    if em_codigo > 0 then
      vim.notify(
        string.format("%d ocorrência(s) de '%s' ficaram em código (outro símbolo com o mesmo nome) e não foram tocadas", em_codigo, antigo),
        vim.log.levels.INFO
      )
    end
    if #candidatos == 0 then
      return
    end

    table.sort(candidatos, function(a, b)
      if a.arq ~= b.arq then return a.arq < b.arq end
      if a.lnum ~= b.lnum then return a.lnum < b.lnum end
      return a.col < b.col
    end)

    local arquivos = {}
    local itens = {}
    for _, c in ipairs(candidatos) do
      arquivos[c.arq] = true
      itens[#itens + 1] = { filename = c.arq, lnum = c.lnum, col = c.col, text = c.texto }
    end

    vim.fn.setqflist({}, " ", { title = "Sobras de '" .. antigo .. "' (comentários/strings/docs)", items = itens })
    vim.cmd("copen")
    local escolha = vim.fn.confirm(
      string.format(
        "Restam %d ocorrência(s) de '%s' em %d arquivo(s), só em comentários/strings/docs.\nTrocar por '%s'?",
        #candidatos, antigo, vim.tbl_count(arquivos), novo
      ),
      "&Trocar tudo\n&Revisar uma a uma\n&Ignorar", 1
    )

    if escolha == 1 then
      aplicar(candidatos, "tudo")
    elseif escolha == 2 then
      aplicar(candidatos, "revisar")
    else
      vim.cmd("cclose")
    end
  end))
end

-- ---------------------------------------------------------------------------
-- API pública
-- ---------------------------------------------------------------------------

-- Para o atalho: guarda o nome atual e devolve o comando que abre o IncRename
function M.iniciar()
  nome_antigo = vim.fn.expand("<cword>")
  return ":IncRename " .. nome_antigo
end

function M.setup()
  -- Depois do rename LSP (igual JetBrains): salva só os arquivos alterados
  -- (inclusive os que o LSP abriu em segundo plano) e avisa o tamanho do estrago.
  require("inc_rename").setup({
    show_message = false, -- a mensagem própria abaixo substitui a do plugin
    post_hook = function(resultado)
      if not resultado then
        return
      end

      -- WorkspaceEdit pode vir como `changes` ou `documentChanges`
      local edicoes = {} -- uri -> quantidade de trocas
      local novo
      for uri, lista in pairs(resultado.changes or {}) do
        edicoes[uri] = #lista
        novo = novo or (lista[1] and lista[1].newText)
      end
      for _, doc in ipairs(resultado.documentChanges or {}) do
        if doc.textDocument and doc.edits then
          local uri = doc.textDocument.uri
          edicoes[uri] = (edicoes[uri] or 0) + #doc.edits
          novo = novo or (doc.edits[1] and doc.edits[1].newText)
        end
      end

      local total, arquivos = 0, 0
      for uri, quantidade in pairs(edicoes) do
        total = total + quantidade
        arquivos = arquivos + 1
        local buf = vim.uri_to_bufnr(uri)
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
          vim.api.nvim_buf_call(buf, function()
            -- noautocmd: o rename não deve disparar o formatar-ao-salvar
            vim.cmd("noautocmd silent! write")
          end)
        end
      end

      vim.notify(string.format("Renomeado: %d ocorrência(s) em %d arquivo(s), tudo salvo", total, arquivos))

      if nome_antigo and novo and nome_antigo ~= novo then
        procurar_sobras(nome_antigo, novo)
      end
    end,
  })
end

-- exposto só para teste
M._interno = {
  pares_de_nomes = pares_de_nomes,
  carregar_arquivo = carregar_arquivo,
  esta_em_texto = esta_em_texto,
  procurar_sobras = procurar_sobras,
}

return M
