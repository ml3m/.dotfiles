return {
  "tpope/vim-fugitive",
  keys = {
    -- Note: <leader>gs conflicts with gitsigns "Stage hunk" in LazyVim.
    -- Fugitive wins here since this spec runs after LazyVim's gitsigns setup.
    { "<leader>gs", vim.cmd.Git, desc = "Git status (fugitive)" },
    { "<leader>p",  function() vim.cmd.Git("push") end, desc = "Git push" },
    { "<leader>P",  function() vim.cmd.Git({ "pull", "--rebase" }) end, desc = "Git pull --rebase" },
    { "<leader>aa", "<cmd>Git add .<CR>", desc = "Git add all" },
  },
}
