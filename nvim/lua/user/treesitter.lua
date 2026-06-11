require("ts_context_commentstring").setup {
  enable = true,
  enable_autocmd = false,
}
vim.g.skip_ts_context_commentstring_module = true

require("treesitter-context").setup {
  enable = true,
  max_lines = 0,
  trim_scope = "outer",
  min_window_height = 0,
  patterns = {
    default = {
      "class",
      "function",
      "method",
      "for",
      "while",
      "if",
      "switch",
      "case",
    },
    json = { "pair" },
    yaml = { "block_mapping_pair" },
  },
  zindex = 20,
  mode = "cursor",
  separator = nil,
}
