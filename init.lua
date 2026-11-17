vim.loader.enable() -- cache de bytecode dos módulos Lua (menos tempo de boot)

vim.keymap.set({'n', 'i', 'v'}, '<F1>', '<Nop>', { silent = true, desc = "Desativar ajuda" })

require("config")
require("keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- importa de plugins
require("lazy").setup("plugins", {
  change_detection = { notify = false }, -- Desativa avisos chatos ao salvar
  performance = {
    rtp = {
      -- plugins embutidos que você não usa (netrw: o Neo-tree cuida dos arquivos)
      disabled_plugins = { "netrwPlugin", "tutor", "tohtml", "zipPlugin", "tarPlugin", "gzip", "matchit", "rplugin", "spellfile" },
    },
  },
})
