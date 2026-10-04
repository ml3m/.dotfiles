require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- Block cursor in all modes
vim.opt.guicursor = ""

-- 4-space indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- No search highlight lingering
vim.opt.hlsearch = false

-- Keep context lines when scrolling
vim.opt.scrolloff = 8

-- Faster completion popup trigger
vim.opt.updatetime = 50

-- 80-char column marker
vim.opt.colorcolumn = "80"

-- Allow conceal (needed for obsidian/render-markdown)
vim.opt.conceallevel = 2
