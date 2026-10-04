return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = "org",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("orgmode").setup({
      -- Adapt these paths to wherever your org files live on Linux
      org_agenda_files = { "~/org/**/*" },
      org_default_notes_file = "~/org/notes.org",
      org_todo_keywords = { "TODO", "IN-PROGRESS", "REVIEW", "|", "DONE", "CANCELED" },
      org_log_done = "note",
      org_log_into_drawer = "LOGBOOK",
      mappings = {
        global = {
          org_agenda = "gA",
          org_capture = "gC",
        },
      },
    })
  end,
}
