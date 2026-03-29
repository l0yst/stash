require "nvchad.options"

local opt = vim.opt

-- 1. SET INDENTATION TO 4 SPACES
opt.smarttab = true
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 4   -- Size of an indent
opt.tabstop = 4      -- Number of spaces tabs count for
opt.softtabstop = 4  -- Number of spaces tabs count for while editing

-- 2. CURSORLINE SETTINGS
-- This makes the line number and the line itself highlight
opt.cursorline = true
opt.cursorlineopt = "both" 

-- 3. ADDITIONAL TWEAKS FOR 0.7 GAMMA
-- Making sure the signcolumn (where git signs/errors are) is always visible
-- so it doesn't "jump" the text when an error appears.
opt.signcolumn = "yes"
