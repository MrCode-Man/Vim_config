local original_notify = vim.notify
vim.notify = function(msg, log_level, opts)
  if log_level == vim.log.levels.INFO and msg and msg:find("some_specific_harmless_string") then
    return
  end
  original_notify(msg, log_level, opts)
end

vim.keymap.set({'n', 'i', 'v'}, '<F1>', '<Nop>', { silent = true })

require("config")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- importa de plugins
require("lazy").setup("plugins", {
  change_detection = { notify = false }, -- Desativa avisos chatos ao salvar
})
