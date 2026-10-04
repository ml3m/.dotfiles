return {
    {
        "bjarneo/aether.nvim",
        branch = "v2",
        name = "aether",
        priority = 1000,
        opts = {
            transparent = false,
            colors = {
                -- Background colors
                bg = "#fefefe",
                bg_dark = "#f8de3c",

                fg = "#412a1e",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#0b3075",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#a08060",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#c8472c",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#f8de3c",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#f8de3c",
                -- green: Comments, strings, success states, git additions
                green = "#58acf4",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#105edd",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#58acf4",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#105edd",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#c8472c",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
