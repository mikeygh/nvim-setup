return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- mocha, macchiato, frappé, latte
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
      },
      color_overrides = {
        mocha = {
          -- base = "#000000",
          -- mantle = "#000000",
          -- crust = "#000000",
        },
      },
      highlight_overrides = {
        -- mocha = function(colors)
        --   return {
        --     -- CmpItemKind = { fg = colors.pink },
        --   }
        -- end,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
