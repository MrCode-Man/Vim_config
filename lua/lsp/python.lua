-- Python: basedpyright faz tipos/semantica, ruff faz lint (sem hover, pra nao duplicar)

-- Ao salvar, aplica as correcoes automaticas do ruff (import nao usado, f-string
-- sem campo, == None...). Roda antes do conform; respeita <leader>lF (formatar ao salvar).
local function ruff_fix_all(client, buf)
  if not vim.g.formatar_ao_salvar then
    return
  end
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "source.fixAll.ruff" }, diagnostics = {} }
  local res = client:request_sync("textDocument/codeAction", params, 1000, buf)
  for _, action in ipairs(res and res.result or {}) do
    if not action.edit then -- o ruff manda a acao "vazia"; o edit vem do resolve
      local resolvido = client:request_sync("codeAction/resolve", action, 1000, buf)
      action = resolvido and resolvido.result or action
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

return {
  basedpyright = {
    settings = {
      basedpyright = {
        disableOrganizeImports = true, -- imports ficam por conta do ruff (sem brigar)
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
      settings = {
        logLevel = "warn",
        lint = {
          -- E/F = padrao; o resto pega bugs reais e modernizacao de codigo
          select = { "E", "F", "I", "B", "UP", "SIM", "C4", "PERF", "RUF", "PL", "N", "PTH", "ASYNC" },
          -- pylint: numero magico, funcao com muito argumento/ramo/linha (barulhento, principalmente com pandas)
          ignore = { "PLR2004", "PLR0911", "PLR0912", "PLR0913", "PLR0915" },
        },
      },
    },
    on_attach = function(client, buf)
      client.server_capabilities.hoverProvider = false
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("RuffFixAll" .. buf, { clear = true }),
        buffer = buf,
        callback = function() ruff_fix_all(client, buf) end,
      })
    end,
  },
}
