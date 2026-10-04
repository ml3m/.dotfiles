return {
  "folke/flash.nvim",
  keys = {
    -- Disable the default 's' mapping so visual-mode substitute works again
    { "s", mode = { "n", "x", "o" }, false },
  },
}
