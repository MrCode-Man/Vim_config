-- Cores do highlight semântico: o LSP diz o que cada palavra é
-- (classe, parâmetro, propriedade...) e isso sobrescreve o Treesitter.
-- Use :Inspect em cima de uma palavra pra ver quais grupos estão valendo.
local M = {}

local function cores_semanticas()
  local grupos = {
    ["@lsp.type.class"]          = { fg = "#f9e2af" },
    ["@lsp.type.struct"]         = { fg = "#f9e2af" },
    ["@lsp.type.enum"]           = { fg = "#f9e2af" },
    ["@lsp.type.interface"]      = { fg = "#94e2d5", italic = true },
    ["@lsp.type.typeParameter"]  = { fg = "#f2cdcd", italic = true },
    ["@lsp.type.parameter"]      = { fg = "#eba0ac", italic = true },
    ["@lsp.type.property"]       = { fg = "#b4befe" },
    ["@lsp.type.enumMember"]     = { fg = "#fab387" },
    ["@lsp.type.namespace"]      = { fg = "#fab387", italic = true },
    ["@lsp.type.decorator"]      = { fg = "#f5c2e7" },
    ["@lsp.type.macro"]          = { fg = "#cba6f7" },
    ["@lsp.type.method"]         = { fg = "#89b4fa" },
    ["@lsp.type.function"]       = { fg = "#89b4fa" },
    ["@lsp.typemod.variable.readonly"]        = { fg = "#fab387", bold = true },
    ["@lsp.typemod.variable.constant"]        = { fg = "#fab387", bold = true },
    ["@lsp.typemod.variable.mutable"]         = { underline = true },
    ["@lsp.typemod.function.defaultLibrary"]  = { fg = "#74c7ec" },
    ["@lsp.typemod.class.defaultLibrary"]     = { fg = "#f9e2af", italic = true },
    ["@lsp.typemod.method.defaultLibrary"]    = { fg = "#74c7ec" },
  }
  for grupo, estilo in pairs(grupos) do
    vim.api.nvim_set_hl(0, grupo, estilo)
  end
  -- símbolo marcado como deprecated fica riscado
  for _, tipo in ipairs({ "class", "function", "method", "variable", "property", "type" }) do
    vim.api.nvim_set_hl(0, "@lsp.typemod." .. tipo .. ".deprecated", { strikethrough = true })
  end
end

function M.setup()
  require("cores").ao_trocar_tema(cores_semanticas)
end

return M
