return {
  -- 1. Ícones bonitos no menu de autocompletar
  { "onsails/lspkind.nvim" },

  -- 2. O Motor de Autocompletar (Cmp) e Snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
          })
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })

      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
      })
    end
  },

  -- 3. Configuração dos Servidores de Linguagem (LSP)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "ray-x/lsp_signature.nvim",
      "smjonas/inc-rename.nvim",
    },
    config = function()
      require("inc_rename").setup()

      local border = "rounded"
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

      -- Diagnostics são checados com mais frequência (padrão é 4000ms).
      -- Isso também deixa o CursorHold abaixo mais responsivo.
      vim.opt.updatetime = 300

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Atalhos SEM leader: convenção padrão do próprio Neovim/LSP, não entram
          -- no esquema de prefixos porque nunca vão conflitar com <leader>algo.
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

          -- Todo atalho de LSP com leader começa com <leader>l
          local function map(sufixo, acao, descricao)
            vim.keymap.set("n", "<leader>l" .. sufixo, acao, { buffer = args.buf, desc = "LSP: " .. descricao })
          end

          map("a", vim.lsp.buf.code_action,     "ação rápida / quick fix")
          map("u", vim.lsp.buf.references,      "usos dessa palavra (find usages)")
          map("i", vim.lsp.buf.implementation,  "ir para implementação")
          map("t", vim.lsp.buf.type_definition, "ir para definição do tipo")
          map("d", vim.diagnostic.open_float,   "mostrar erro/aviso da linha")
          map("p", "<cmd>Trouble diagnostics toggle<cr>", "painel de problemas do projeto")

          -- Liga/desliga o modo "chato" (virtual_lines + update_in_insert) na hora,
          -- pra quando o aviso constante atrapalhar mais do que ajudar.
          map("x", function()
            local atual = vim.diagnostic.config().virtual_lines
            vim.diagnostic.config({
              virtual_lines = not atual,
              update_in_insert = not atual,
            })
            vim.notify("Diagnostics modo chato: " .. tostring(not atual))
          end, "alternar modo chato de diagnostics")

          -- Renomear em tempo real (você vê o resultado enquanto digita, igual JetBrains)
          vim.keymap.set("n", "<leader>lr", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end, { expr = true, buffer = args.buf, desc = "LSP: renomear" })

          -- Dicas de parâmetros ao digitar
          require("lsp_signature").on_attach({
            bind = true,
            handler_opts = { border = border },
            hint_enable = false,
          }, args.buf)

          -- Inlay Hints (dicas fantasmas de tipo)
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })

      -- Mostra o erro da linha automaticamente ao parar o cursor em cima dela.
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
        end,
      })

      -- Customização visual dos erros
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Config "chata" de propósito: avisa enquanto você digita, mostra
      -- sempre o texto do erro (não só quando tem vários na linha), e
      -- ainda desenha a linha completa do diagnóstico embaixo do código
      -- na linha onde o cursor tá. Dá pra desligar com <leader>lx.
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "always",
          severity = { min = vim.diagnostic.severity.HINT },
        },
        virtual_lines = { only_current_line = true },
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = true,
        float = {
          border = border,
          source = "always",
          header = "",
          focusable = false,
        },
      })

      require("mason").setup()

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- "ruff" faz linting (regras de estilo, imports não usados, código morto);
      -- "pyright" faz type-checking. Os dois rodam juntos no Python, sem conflito,
      -- porque cada um cobre diagnostics diferentes.
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff", "rust_analyzer", "clangd", "lua_ls" },
        automatic_installation = true,
      })

      -- Capabilities valem pra todos os servidores por padrão.
      vim.lsp.config('*', { capabilities = capabilities })

      vim.lsp.config('pyright', {
        settings = {
          python = {
            analysis = {
              -- "strict" reporta MUITA coisa que o modo padrão ignora:
              -- tipos implícitos em Any, retornos não anotados, etc.
              -- Se achar exagerado, troca pra "standard".
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace", -- analisa o projeto inteiro, não só o arquivo aberto
            },
          },
        },
      })

      vim.lsp.config('ruff', {
        init_options = {
          settings = {
            -- Deixa o ruff reportar tudo que ele consegue, sem suprimir por padrão.
            logLevel = "warn",
          },
        },
        -- Evita hover duplicado: deixa o pyright cuidar do hover/type info,
        -- o ruff só cuida de diagnostics + code actions de lint.
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
              -- Deixa o lua_ls reclamar de variável não usada, redefinição etc.
              disable = {},
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable({ "pyright", "ruff", "rust_analyzer", "clangd", "lua_ls" })
    end
  },

  -- 4. Painel de Problemas do projeto inteiro, igual ao painel de erros da JetBrains
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
  },

  -- 5. Barra de Contexto no Topo (Breadcrumbs)
  {
    "Bekaboo/dropbar.nvim",
  },

  -- 6. Formatador de Código Automático (Conform)
  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          rust = { "rustfmt", lsp_format = "fallback" },
          javascript = { "prettier" },
          ["_"] = { "trim_whitespace" },
        },
      })

      -- Fica junto do resto dos atalhos de LSP, por isso <leader>lf
      vim.keymap.set({ "n", "v" }, "<leader>lf", function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
      end, { desc = "LSP: formatar código" })
    end,
  }
}
