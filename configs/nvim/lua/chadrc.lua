---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "slatedust",
    hl_override = {
        St_NormalMode = { bg = "#a8c292", fg = "#1c2023" },
        St_NormalModeSep = { fg = "#a8c292" },
    },
}

M.ui = {
    cmp = {
        icons = true,
        lspkind_text = true,
        style = "atom_colored",
    },

    telescope = { style = "bordered" },

    statusline = {
        theme = "default",
        separator_style = "round",
    },

    tabufline = {
        enabled = true,
        lazyload = true,
        order = { "treeOffset", "buffers", "tabs", "btns" },
    },

    nvdash = {
        load_on_startup = true,
        header = {
            "           ▄ ▄                   ",
            "       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ",
            "      █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ",
            "    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ",
            "  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ",
            "  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄",
            "▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █",
            "█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █",
            "    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ",
        },
        buttons = {
            { "  Find File", "Spc f f", "Telescope find_files" },
            { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
            { "  Bookmarks", "Spc m a", "Telescope marks" },
            { "  Mappings", "Spc c h", "NvCheatsheet" },
        },
    },
}

-- TERMINAL SETTINGS
M.term = {
    winopts = { number = false, relativenumber = false },
    sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
    float = {
        relative = "editor",
        row = 0.3,
        col = 0.25,
        width = 0.5,
        height = 0.4,
        border = "single",
    },
}

M.lsp = { signature = true }

M.cheatsheet = {
    theme = "grid",
    excluded_groups = { "autopairs", "Nvim", "Opens" },
}

M.mason = { cmd = true, pkgs = {} }

M.mason = {
    cmd = true,
    pkgs = {
        "black",
        "isort",
        "stylua",
        "prettier",
        "shfmt",
        "clang-format",
        "sql-formatter",
        "pyright",
        "typescript-language-server",
        "lua-language-server",
        "svelte-language-server",
    },
}

return M
