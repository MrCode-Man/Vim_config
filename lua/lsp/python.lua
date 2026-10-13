-- Python: basedpyright faz tipos/semantica, ruff faz lint (sem hover, pra nao duplicar)
return {
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "standard",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          autoImportCompletions = true,
          inlayHints = {
            variableTypes = true,
            callArgumentNames = true,
            functionReturnTypes = true,
            genericTypes = false,
          },
        },
      },
    },
  },

  ruff = {
    init_options = {
      settings = { logLevel = "warn" },
    },
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
  },
}
