require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>wl", "<cmd>Telescope workspaces<cr>", { desc = "Fuzzy find workspaces" })
