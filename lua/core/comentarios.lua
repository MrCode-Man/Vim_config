-- Comentarios coloridos: TODO / NOTE / FIXME.
--   * a linha INTEIRA ganha um fundo da cor (igual ao realce da linha do cursor)
--   * da palavra ate o fim da linha o texto fica na cor do marcador
-- So vale se a palavra vier depois de um marcador de comentario (# // -- /* * ")
--
-- Usa um decoration provider: so desenha as linhas visiveis, em qualquer
-- buffer/janela, sem precisar de autocmd por janela.
-- cor   = cor-base do FUNDO da linha (diluida no fundo do tema)
-- texto = cor das letras (ajustada pra ter contraste parecido em todas)
local comentarios = {
  { nome = "Todo",   palavras = { "TODO" },                 cor = "#216882", texto = "#2E92B7" },
  { nome = "Note",   palavras = { "NOTE" },                 cor = "#8F7814", texto = "#8F7814" },
  { nome = "Fixme",  palavras = { "FIXME", "BUG" },         cor = "#E5336A", texto = "#ED82A3" },
  { nome = "Hack",   palavras = { "HACK", "XXX", "WARN", "WARNING" }, cor = "#C4691E", texto = "#D57221" },
  { nome = "Perf",   palavras = { "PERF", "OPTIMIZE" },     cor = "#7C5CBF", texto = "#987ECC" },
  { nome = "Safety", palavras = { "SAFETY" },               cor = "#3E8E50", texto = "#459D58" }, -- comentario de `unsafe` no Rust
}

local FUNDO_BASE = "#1e1e2e" -- fundo do catppuccin-mocha, onde a cor e diluida
local FORCA_DO_FUNDO = 0.28  -- 0 = sem fundo, 1 = cor cheia

local function misturar(cor, base, forca)
  local function canais(hex)
    return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  end
  local r1, g1, b1 = canais(cor)
  local r2, g2, b2 = canais(base)
  return string.format(
    "#%02x%02x%02x",
    r2 + (r1 - r2) * forca, g2 + (g1 - g2) * forca, b2 + (b1 - b2) * forca
  )
end

local function definir_cores()
  for _, c in ipairs(comentarios) do
    c.grupo_texto = "Comentario" .. c.nome
    c.grupo_linha = c.grupo_texto .. "Linha"
    vim.api.nvim_set_hl(0, c.grupo_texto, { fg = c.texto })
    vim.api.nvim_set_hl(0, c.grupo_linha, { bg = misturar(c.cor, FUNDO_BASE, FORCA_DO_FUNDO) })
    -- \v = "very magic", \C = diferencia maiusculas (por causa do seu ignorecase);
    -- \zs marca onde comeca o trecho colorido (a palavra)
    c.regex = vim.regex([[\v\C(#|//|--|/\*|\*|")\s*\zs<(]] .. table.concat(c.palavras, "|") .. [[)>]])
  end
end

require("core.cores").ao_trocar_tema(definir_cores)

local ns = vim.api.nvim_create_namespace("comentarios_coloridos")

vim.api.nvim_set_decoration_provider(ns, {
  on_win = function(_, win)
    -- nao desenha em janelas flutuantes (hover, completion...)
    return vim.api.nvim_win_get_config(win).relative == ""
  end,
  on_line = function(_, _, buf, row)
    local linha = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
    if not linha then
      return
    end
    for _, c in ipairs(comentarios) do
      local inicio = c.regex:match_str(linha)
      if inicio then
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          ephemeral = true,
          end_row = row,
          end_col = #linha,
          hl_group = c.grupo_linha,
          hl_eol = true, -- estende o fundo ate o fim da janela
          priority = 200,
        })
        vim.api.nvim_buf_set_extmark(buf, ns, row, inicio, {
          ephemeral = true,
          end_row = row,
          end_col = #linha,
          hl_group = c.grupo_texto,
          priority = 201,
        })
        return
      end
    end
  end,
})
