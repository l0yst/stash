local lspconfig = vim.lsp.config
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require("nvchad.configs.lspconfig")
local servers = { 
  "html", 
  "cssls", 
  "ts_ls", 
  "pyright", 
  "bashls", 
  "clangd", 
  "sqlls", 
}

for _, server_name in ipairs(servers) do
  local cfg = vim.lsp.config[server_name]
  vim.lsp.config(server_name, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
end

vim.lsp.config("svelte", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  root_dir = require("lspconfig.util").root_pattern("package.json", ".git"),
})

vim.lsp.enable(servers)
vim.lsp.enable("svelte")
