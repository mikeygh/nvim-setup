-- Go development setup for Ping Identity SRE interview prep
return {
  -- Override gopls settings (Go extra handles base config) to add stricter analyses for SRE-level code quality.
  -- Merges on top of what the Go extra already configures.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                -- Keep all Go extra defaults plus add:
                shadow          = true,    -- detect shadowed variables
                fieldalignment  = true,    -- detect struct layout inefficiencies
                lostcancel      = true,    -- detect lost cancel contexts
                undeclaredname  = true,    -- detect undeclared names
              },
              -- Local import prefix for organise-on-save during interview prep
              importsLocal = "pingidentity",
              -- Deep security scanning
              vulncheck = "Imports",
            },
          },
        },
      },
    },
  },

  -- Disable golangci-lint from nvim-lint (gopls with staticcheck covers this,
  -- and the nvim-lint integration has compatibility issues with v1.64.8)
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        go = {},
      },
    },
  },

  -- Extra Mason tools beyond what the Go extra already installs
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "gotests",       -- Generate table-driven tests
        "gomodifytags",  -- Struct tag manipulation
        "impl",          -- Generate interface implementations
      })
    end,
  },

  -- Go navigation helpers (crispgm/nvim-go)
  -- Provides GoAddImport, GoRemoveImport, GoIfErr, GoPkg
  {
    "crispgm/nvim-go",
    lazy = true,
    cmd = {
      "GoAddImport",
      "GoRemoveImport",
      "GoIfErr",
      "GoPkg",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {},
  },

  -- Custom keymaps for Go development
  -- Note: <leader>g is reserved for Git by LazyVim, so we use <leader>z instead
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        ["<leader>G"] = { name = "+go" },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    keys = {
      -- Uses commands from crispgm/nvim-go (lazy-loaded via cmd above)
      { "<leader>Gi", "<cmd>GoIfErr<CR>", desc = "Go If Err" },
      { "<leader>Ga", "<cmd>GoAddImport<CR>", desc = "Go Add Import" },
    },
  },
}
