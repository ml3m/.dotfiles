-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move line down and up
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Open netrw explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw" })

-- Paste over selection without overwriting the yank register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- Location list navigation (centered)
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev location" })

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x" })

-- CellularAutomaton animation (requires the plugin)
vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Make it rain" })

-- Obsidian keymaps (active when obsidian.nvim is loaded)
-- vim.keymap.set("n", "<leader>on", "<cmd>ObsidianTemplate<CR>", { desc = "Obsidian template" })
-- vim.keymap.set("n", "<leader>os", function()
--   require("telescope.builtin").live_grep({ search_dirs = { vim.fn.expand("~/obsidian/main") } })
-- end, { desc = "Obsidian search vault" })
-- vim.keymap.set("n", "<leader>oz", function()
--   require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/obsidian/main") })
-- end, { desc = "Obsidian find note" })
-- vim.keymap.set("n", "<leader>of", function()
--   local title = vim.fn.input("Title: ")
--   title = title:gsub("^%d%d%d%d%-%d%d%-%d%d%s*", "")
--   vim.api.nvim_put({ title }, "l", true, true)
-- end, { desc = "Obsidian strip date from title" })
-- 