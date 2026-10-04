-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Extra LSP keymaps from macOS config (LazyVim already covers gd, K, [d/]d, etc.)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("mlem_lsp_keymaps", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, remap = false }
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Workspace symbol" }))
    vim.keymap.set("n", "<leader>vd",  vim.diagnostic.open_float,    vim.tbl_extend("force", opts, { desc = "Open diagnostic float" }))
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action,       vim.tbl_extend("force", opts, { desc = "Code action" }))
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references,        vim.tbl_extend("force", opts, { desc = "References" }))
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename,            vim.tbl_extend("force", opts, { desc = "Rename" }))
  end,
})
