-- C / C++: clangd com clang-tidy, hints e indexacao em background
return {
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--function-arg-placeholders",
      "--all-scopes-completion",
      "--cross-file-rename",
    },
    init_options = {
      -- usado quando nao ha compile_commands.json no projeto
      fallbackFlags = { "-Wall", "-Wextra", "-Wpedantic" },
    },
  },
}
