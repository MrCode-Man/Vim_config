-- Lua: lua_ls entendendo o runtime do proprio Neovim
return {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = { vim.env.VIMRUNTIME },
          checkThirdParty = false,
        },
        hint = { enable = true, setType = true },
        semantic = { enable = true },
        completion = { callSnippet = "Replace" },
        telemetry = { enable = false },
      },
    },
  },
}
