local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    
    -- Web Development
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    svelte = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },

    -- Python & Mojo
    -- Mojo usually uses its own formatter, but black works for basic pythonic syntax
    python = { "black" },
    
    -- Shell
    sh = { "shfmt" },
    bash = { "shfmt" },

    -- C/C++
    c = { "clang-format" },
    cpp = { "clang-format" },
    
    -- SQL
    sql = { "sql_formatter" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
