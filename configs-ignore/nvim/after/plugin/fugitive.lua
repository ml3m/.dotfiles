vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>p", function()
            vim.cmd.Git('push')
end, opts)

vim.keymap.set("n", "<leader>P", function()
            vim.cmd.Git({'pull',  '--rebase'})
end, opts)

vim.keymap.set("n", "<leader>aa", ":Git add .", opts);
--vim.keymap.set("n", "<leader>x", "', opts);
