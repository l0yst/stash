return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = require "configs.conform",
    },
    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            filters = {
                -- dotfiles = true,
                custom = {
                    "node_modules",
                    ".git",
                    "dist",
                    "build",
                    "*.pyc",
                    "*.swp",
                    "*.swo",
                    ".DS_Store",
                    "target",
                    "__pycache__",
                },
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                -- Formatters
                "stylua",
                "prettier",
                "black",
                "shfmt",
                "clang-format",
                "sql-formatter",

                -- LSPs
                "lua-language-server",
                "svelte-language-server",
                "pyright",
                "clangd",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },
    { import = "nvchad.blink.lazyspec" },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "lua",
                "bash",
                "svelte",
                "javascript",
                "typescript",
                "html",
                "css",
                "scss",
                "python",
                "sql",
                "r",
                "vim",
                "vimdoc",
                "markdown",
                "markdown_inline",
                "json",
                "yaml",
                "toml",
                "dockerfile",
                "gitignore",
                "c",
                "cpp",
                "rust",
                "go",
            },
            highlight = {
                enable = true,
                use_languagetree = true,
            },
            indent = {
                enable = true,
            },
        },
    },
    {
        "natecraddock/workspaces.nvim",
        lazy = false,
        config = function()
            require "configs.workspaces"
            require("telescope").load_extension "workspaces"
        end,
        cmd = { "WorkspacesOpen", "WorkspacesAdd", "WorkspacesList", "WorkspacesRemove" },
    },
    {
        "fedepujol/move.nvim",
        lazy = false,
        event = "BufReadPost",
        config = function()
            require "configs.move"
        end,
        cmd = { "MoveLine", "MoveBlock" },
    },
}
