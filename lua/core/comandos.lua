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


