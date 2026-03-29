local workspaces = require("workspaces")

workspaces.setup({
    path = vim.fn.stdpath("data") .. "/workspaces",
    cd_type = "global",
    auto_open = true,
})
