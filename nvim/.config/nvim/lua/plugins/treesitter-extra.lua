return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed or {}, {
      "javascript",
      "typescript",
      "c",
      "rust",
      "org",
    })
  end,
}
