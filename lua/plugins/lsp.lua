return {
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
      -- Rename "completo" (inc-rename + varredura de comentários/strings): lua/lsp_rename.lua
      local rename = require("lsp_rename")
      rename.setup()

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

          -- "Importar" estilo JetBrains (<leader>i): pede ao servidor só as ações de
          -- import (rust-analyzer: `use`, basedpyright: import, clangd: #include) e
          -- aplica direto se só houver uma; se houver várias, abre a lista pra escolher.
          vim.keymap.set("n", "<leader>i", function()
            vim.lsp.buf.code_action({
              apply = true,
              filter = function(acao)
                local titulo = acao.title:lower()
                return titulo:find("import", 1, true)
                  or titulo:find("include", 1, true)
                  or titulo:find("qualify", 1, true)
                  or titulo:find("^use ")
              end,
            })
          end, { buffer = args.buf, desc = "LSP: importar o que está faltando" })

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
          -- e o que sobrar em comentários/strings/docs é oferecido pra troca (lua/lsp_rename.lua).
          vim.keymap.set("n", "<leader>lr", rename.iniciar,
            { expr = true, buffer = args.buf, desc = "LSP: renomear" })

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

      -- Cores do highlight semântico: lua/lsp_cores.lua
      require("lsp_cores").setup()

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

}
