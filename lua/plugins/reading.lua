-- Reading-focused plugins: zen mode, dimming, and snacks integration
return {
  -- Distraction-free reading / focus mode
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
    opts = {
      window = {
        width = 0.85,
        height = 0.95,
      },
      plugins = {
        twilight = { enabled = false }, -- don't dim outside content
        gitsigns = { enabled = true },  -- keep git signs visible
        tmux = { enabled = false },
      },
      -- keep lualine and statuscolumn visible
      on_open = function()
        vim.opt.laststatus = 3
        vim.opt.ruler = false
      end,
    },
  },

  -- Enable snacks dim for focusing on the current scope
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Merge dim config without overriding other snacks opts (e.g. indent)
      opts.dim = vim.tbl_deep_extend("force", opts.dim or {}, {
        enabled = true,
        scope = {
          min_size = 5,
          max_size = 20,
          siblings = true,
        },
      })
      return opts
    end,
  },
}
