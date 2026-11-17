-- Helper: roda `fn` agora e de novo toda vez que o tema mudar
-- (trocar de tema apaga os highlights customizados).
local M = {}

local grupo = vim.api.nvim_create_augroup("CoresCustomizadas", { clear = true })

function M.ao_trocar_tema(fn)
  fn()
  vim.api.nvim_create_autocmd("ColorScheme", { group = grupo, callback = fn })
end

return M
