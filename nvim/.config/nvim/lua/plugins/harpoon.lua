return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

    -- Note: <C-h/j/k/l> shadow LazyVim's window-navigation bindings.
    -- Change these if you prefer to keep split navigation.
    vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon slot 1" })
    vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Harpoon slot 2" })
    vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Harpoon slot 3" })
    vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Harpoon slot 4" })
  end,
}
