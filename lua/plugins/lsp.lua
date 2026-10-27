return {
  -- 1. Ícones bonitos no menu de autocompletar
  { "onsails/lspkind.nvim", lazy = true },

  -- 2. O Motor de Autocompletar (Cmp) e Snippets
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
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

      local function cores_do_cmp()
        vim.api.nvim_set_hl(0, "CmpNormal", { bg = "#313244" })               -- fundo do menu
        vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#cdd6f4", bg = "#313244" }) -- borda branca
        vim.api.nvim_set_hl(0, "CmpSel",    { bg = "#585b70", bold = true })    -- item selecionado
      end
      cores_do_cmp()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("CoresDoCmp", { clear = true }),
        callback = cores_do_cmp,
      })

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        -- Menu de sugestões com borda clara e fundo próprio (cores definidas em
        -- cores_do_cmp() abaixo), pra se destacar do código atrás.
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,Search:None",
          }),
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
          -- select = false: Enter só aceita o item que VOCÊ selecionou (Tab / C-j / C-k)
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then luasnip.jump(-1)
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
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } })
      })
    end
  },

  -- 3. Configuração dos Servidores de Linguagem (LSP)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "ray-x/lsp_signature.nvim",
      "smjonas/inc-rename.nvim",
      -- Renomear/mover arquivo no Neo-tree atualiza os imports (willRenameFiles do LSP)
      {
        "antosha417/nvim-lsp-file-operations",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim" },
        config = function() require("lsp-file-operations").setup() end,
      },
    },
    config = function()
      -- Rename "completo": o LSP troca o símbolo no código; depois uma busca textual
      -- (ripgrep) acha o que o LSP não enxerga (comentários, docstrings, strings,
      -- markdown, configs) e oferece trocar também. Só mexe com palavra inteira.
      local nome_antigo

      local function trocar_restantes(antigo, novo)
        local raiz = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
        vim.system(
          { "rg", "--vimgrep", "--word-regexp", "--fixed-strings", "--case-sensitive", "--", antigo, raiz },
          { text = true },
          vim.schedule_wrap(function(r)
            local itens, arquivos = {}, {}
            for linha in vim.gsplit(r.stdout or "", "\n", { trimempty = true }) do
              local arq, lnum, col, texto = linha:match("^(.-):(%d+):(%d+):(.*)$")
              if arq then
                itens[#itens + 1] = { filename = arq, lnum = tonumber(lnum), col = tonumber(col), text = texto }
                arquivos[arq] = true
              end
            end
            if #itens == 0 then
              return
            end

            vim.fn.setqflist({}, " ", { title = "Restos de '" .. antigo .. "'", items = itens })
            vim.cmd("copen")
            local padrao = [[\C\V\<]] .. vim.fn.escape(antigo, [[\/]]) .. [[\>]]
            local escolha = vim.fn.confirm(
              string.format(
                "Restam %d ocorrência(s) de '%s' em %d arquivo(s) (comentários, strings, docs...).\nTrocar por '%s'?",
                #itens, antigo, vim.tbl_count(arquivos), novo
              ),
              "&Trocar tudo\n&Revisar uma a uma\n&Ignorar", 1
            )
            if escolha == 1 then
              vim.cmd(string.format("silent! cfdo %%s/%s/%s/ge | update", padrao, vim.fn.escape(novo, [[\/&~]])))
              vim.cmd("cclose")
              vim.notify(string.format("Trocadas as %d ocorrência(s) restantes", #itens))
            elseif escolha == 2 then
              vim.fn.setreg("/", padrao)
              vim.fn.feedkeys(
                ":cfdo %s//" .. vim.fn.escape(novo, [[\/&~]]) .. "/gc | update", "n"
              )
            else
              vim.cmd("cclose")
            end
          end)
        )
      end

      -- Depois do rename LSP (igual JetBrains): salva só os arquivos alterados
      -- (inclusive os que o LSP abriu em segundo plano) e avisa o tamanho do estrago.
      require("inc_rename").setup({
        show_message = false, -- a mensagem própria abaixo substitui a do plugin
        post_hook = function(resultado)
          if not resultado then
            return
          end

          -- WorkspaceEdit pode vir como `changes` ou `documentChanges`
          local edicoes = {} -- uri -> quantidade de trocas
          local novo
          for uri, lista in pairs(resultado.changes or {}) do
            edicoes[uri] = #lista
            novo = novo or (lista[1] and lista[1].newText)
          end
          for _, doc in ipairs(resultado.documentChanges or {}) do
            if doc.textDocument and doc.edits then
              local uri = doc.textDocument.uri
              edicoes[uri] = (edicoes[uri] or 0) + #doc.edits
              novo = novo or (doc.edits[1] and doc.edits[1].newText)
            end
          end

          local total, arquivos = 0, 0
          for uri, quantidade in pairs(edicoes) do
            total = total + quantidade
            arquivos = arquivos + 1
            local buf = vim.uri_to_bufnr(uri)
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
              vim.api.nvim_buf_call(buf, function()
                vim.cmd("silent! write")
              end)
            end
          end

          vim.notify(
            string.format("Renomeado: %d ocorrência(s) em %d arquivo(s), tudo salvo", total, arquivos)
          )

          if nome_antigo and novo and nome_antigo ~= novo then
            trocar_restantes(nome_antigo, novo)
          end
        end,
      })

      -- Borda arredondada em hover, signature help e floats (vim.o.winborder fica no config.lua)
      local border = "rounded"

      -- Modo "chato" de diagnostics (liga/desliga com <leader>lx):
      --   ligado    -> avisa enquanto digita; a linha do cursor mostra o erro completo
      --                embaixo do código (virtual_lines) e as outras linhas só o resumo
      --                no fim (virtual_text), então nada aparece duplicado.
      --   desligado -> só o resumo no fim de todas as linhas; o erro completo aparece
      --                num float ao parar o cursor.
      local function diagnostics_modo(chato)
        vim.g.diagnostics_chato = chato
        local virtual_text = {
          prefix = "●",
          source = true,
          severity = { min = vim.diagnostic.severity.HINT },
        }
        if chato then
          virtual_text.current_line = false -- a linha do cursor usa virtual_lines
        end
        vim.diagnostic.config({
          virtual_text = virtual_text,
          virtual_lines = chato and { current_line = true } or false,
          update_in_insert = chato,
        })
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Atalhos SEM leader: convenção padrão do próprio Neovim/LSP, não entram
          -- no esquema de prefixos porque nunca vão conflitar com <leader>algo.
          -- gd usa o Telescope: salta direto se há uma só definição, senão abre lista com preview
          local function sem_leader(tecla, acao, descricao)
            vim.keymap.set("n", tecla, acao, { buffer = args.buf, desc = "LSP: " .. descricao })
          end
          sem_leader("gd", function() require("telescope.builtin").lsp_definitions() end, "ir para definição")
          sem_leader("K", vim.lsp.buf.hover, "documentação / tipo")
          sem_leader("[d", function() vim.diagnostic.jump({ count = -1 }) end, "erro anterior")
          sem_leader("]d", function() vim.diagnostic.jump({ count = 1 }) end, "próximo erro")

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
            diagnostics_modo(not vim.g.diagnostics_chato)
            vim.notify("Diagnostics modo chato: " .. tostring(vim.g.diagnostics_chato))
          end, "alternar modo chato de diagnostics")

          -- Renomear em tempo real (você vê o resultado enquanto digita, igual JetBrains).
          -- O nome atual já vem preenchido; o projeto inteiro é alterado e salvo (post_hook),
          -- e o que sobrar em comentários/strings/docs é oferecido pra troca (trocar_restantes).
          vim.keymap.set("n", "<leader>lr", function()
            nome_antigo = vim.fn.expand("<cword>")
            return ":IncRename " .. nome_antigo
          end, { expr = true, buffer = args.buf, desc = "LSP: renomear" })

          -- Navegação semântica (estilo JetBrains: símbolos, hierarquias)
          map("s", function() require("telescope.builtin").lsp_document_symbols() end,          "símbolos do arquivo (structure)")
          map("S", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "buscar símbolo no projeto")
          map("c", vim.lsp.buf.incoming_calls,                                                   "quem chama essa função")
          map("C", vim.lsp.buf.outgoing_calls,                                                   "o que essa função chama")
          map("T", function() vim.lsp.buf.typehierarchy("subtypes") end,                         "hierarquia: subtipos")
          map("H", function() vim.lsp.buf.typehierarchy("supertypes") end,                       "hierarquia: supertipos")

          -- Reinicia os servidores LSP do buffer (quando ele "esquece" um import/módulo novo)
          map("R", function()
            vim.cmd("LspRestart")
            vim.notify("LSP reiniciado")
          end, "reiniciar servidores LSP")

          -- Alterna o hover automático (doc/tipo ao parar o cursor)
          map("h", function()
            vim.g.hover_automatico = not vim.g.hover_automatico
            vim.notify("Hover automático: " .. tostring(vim.g.hover_automatico))
          end, "alternar hover automático")

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

          -- Destaca todos os usos do símbolo sob o cursor (igual JetBrains)
          if client and client:supports_method("textDocument/documentHighlight") then
            local grupo = vim.api.nvim_create_augroup("LspDocumentHighlight" .. args.buf, { clear = true })
            vim.api.nvim_create_autocmd("CursorHold", {
              group = grupo,
              buffer = args.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
              group = grupo,
              buffer = args.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          -- Code lens (ex.: "Run | Debug" e contagem de referências no rust-analyzer)
          if client and client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable(true, { bufnr = args.buf })
            map("n", vim.lsp.codelens.run, "executar code lens da linha")
          end
        end,
      })

      -- Ao parar o cursor (sem mouse, o "passar o mouse" da JetBrains):
      -- 1) fora do modo chato, se tem erro/aviso embaixo do cursor, mostra ele;
      -- 2) senão, mostra a documentação/tipo do símbolo (hover).
      -- No modo chato o erro já está na tela (virtual_lines), então só rola o hover.
      -- <leader>lh liga/desliga o hover.
      vim.g.hover_automatico = true
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          if vim.fn.mode() ~= "n" or vim.api.nvim_win_get_config(0).relative ~= "" then
            return
          end

          local float = not vim.g.diagnostics_chato
            and vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
          if float or not vim.g.hover_automatico or vim.fn.expand("<cword>") == "" then
            return
          end

          if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) > 0 then
            vim.lsp.buf.hover({ focusable = false, silent = true })
          end
        end,
      })

      -- Cores do highlight semântico: o LSP diz o que cada palavra é
      -- (classe, parâmetro, propriedade...) e isso sobrescreve o Treesitter.
      -- Use :Inspect em cima de uma palavra pra ver quais grupos estão valendo.
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

      cores_semanticas()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("CoresSemanticas", { clear = true }),
        callback = cores_semanticas,
      })

      -- Ícones dos diagnostics (usa a API nova; sign_define está deprecado)
      local icones = {
        [vim.diagnostic.severity.ERROR] = "\u{f057} ",
        [vim.diagnostic.severity.WARN]  = "\u{f071} ",
        [vim.diagnostic.severity.HINT]  = "\u{f0eb} ",
        [vim.diagnostic.severity.INFO]  = "\u{f05a} ",
      }

      vim.diagnostic.config({
        signs = { text = icones },
        underline = true,
        severity_sort = true,
        float = {
          border = border,
          source = true,
          header = "",
          focusable = false,
        },
      })

      diagnostics_modo(true)

      require("mason").setup()

      local capabilities = vim.tbl_deep_extend(
        "force",
        require('cmp_nvim_lsp').default_capabilities(),
        require("lsp-file-operations").default_capabilities()
      )

      -- Padrão usado em todas as linguagens: um servidor faz type-checking,
      -- outro (separado) faz linting. As configs de cada linguagem ficam em
      -- lua/lsp/<linguagem>.lua e cada arquivo devolve { servidor = config }.
      --   Python  -> basedpyright (tipos) + ruff (lint)
      --   Rust    -> rust_analyzer rodando clippy
      --   C/C++   -> clangd com clang-tidy embutido
      --   Lua     -> lua_ls
      local servidores = {}
      for _, linguagem in ipairs({ "python", "rust", "cpp", "lua" }) do
        for nome, config in pairs(require("lsp." .. linguagem)) do
          servidores[nome] = config
        end
      end

      local nomes = vim.tbl_keys(servidores)

      require("mason-lspconfig").setup({
        ensure_installed = nomes,
        automatic_enable = false, -- quem liga os servidores é o vim.lsp.enable abaixo
      })

      -- Capabilities valem pra todos os servidores por padrão.
      vim.lsp.config('*', { capabilities = capabilities })

      for nome, config in pairs(servidores) do
        vim.lsp.config(nome, config)
      end

      vim.lsp.enable(nomes)
    end
  },

  -- 4. Painel de Problemas do projeto inteiro, igual ao painel de erros da JetBrains
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
  },

  -- Instala sozinho os formatadores usados pelo conform
  -- (ruff já vem pelo mason-lspconfig; rustfmt vem do rustup)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "stylua", "clang-format" },
    },
  },

  -- 5. Barra de Contexto no Topo (Breadcrumbs)
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- 6. Formatador de Código Automático (Conform)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_organize_imports", "ruff_format" },
          rust = { "rustfmt", lsp_format = "fallback" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          ["_"] = { "trim_whitespace" },
        },
      })

      -- Fica junto do resto dos atalhos de LSP, por isso <leader>lf
      vim.keymap.set({ "n", "v" }, "<leader>lf", function()
        require("conform").format({
          lsp_format = "fallback",
          async = false,
          timeout_ms = 500,
        })
      end, { desc = "LSP: formatar código" })
    end,
  }
}
