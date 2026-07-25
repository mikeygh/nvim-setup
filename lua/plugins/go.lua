-- Go development setup
--
-- Builds on top of the LazyVim Go extra (imported in lazy.lua):
--   gopls LSP with proper settings, semantic tokens workaround,
--   goimports/gofumpt formatting via conform, golangci-lint via nvim-lint,
--   delve DAP adapter, neotest-golang adapter config.
--
-- This file:
--   1. Overrides gopls with stricter analyses
--   2. Activates optional plugins from the Go extra (neotest, nvim-dap)
--      by providing explicit specs here
--   3. Adds practical keymaps for the Go development workflow
return {
  -- ─── 1. Gopls: stricter analyses ──────────────────────────────
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
                shadow = true, -- detect shadowed variables
                fieldalignment = true, -- detect struct layout inefficiencies
                lostcancel = true, -- detect lost cancel contexts
                undeclaredname = true, -- detect undeclared names
              },
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              vulncheck = "Imports",
            },
          },
        },
      },
    },
  },

  -- ─── 2. Disable golangci-lint from nvim-lint ──────────────────
  -- gopls with staticcheck covers this, and the nvim-lint integration
  -- has compatibility issues with v1.64.8.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        go = {},
      },
    },
  },

  -- ─── 3. Extra Mason tools ─────────────────────────────────────
  -- Beyond what the Go extra already installs (goimports, gofumpt,
  -- gomodifytags, impl, golangci-lint, delve).
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "gotests", -- Generate table-driven tests
      })
    end,
  },

  -- ─── 4. Go helpers (crispgm/nvim-go) ──────────────────────────
  -- Provides: import management, if-err generation, struct tags,
  -- test toggling, gotests integration, formatting.
  {
    "crispgm/nvim-go",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      -- Use gopls formatting instead (it supports gofumpt via the Go extra's config)
      auto_format = false,
      auto_lint = false,
    },
  },

  -- ─── 5. Test runner: neotest + neotest-golang ─────────────────
  -- Activates the optional neotest spec from the Go extra.
  -- Provides visual test feedback in the gutter, summary panel,
  -- and output viewer.
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "fredrikaverpil/neotest-golang",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-golang"] = vim.tbl_deep_extend("force", opts.adapters["neotest-golang"] or {}, {
        go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
        dap_go_enabled = true,
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>t", "", desc = "+test" },
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Tests" },
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Re-run Last Test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop Test Run" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch" },
    },
  },

  -- ─── 6. Debugger: nvim-dap + nvim-dap-go + delve ──────────────
  -- Activates the optional nvim-dap spec from the Go extra.
  -- nvim-dap-go and delve are installed by the extra's Mason config.
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
    },
    -- stylua: ignore
    keys = {
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint() end, desc = "Set Breakpoint" },
      { "<leader>dc", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dC", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.toggle({}, "vertical 40") end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Re-run Last" },
    },
    config = function()
      -- nvim-dap-go sets up delve configurations automatically
      local ok, dapgo = pcall(require, "dap-go")
      if ok then
        dapgo.setup()
      end
    end,
  },

  -- ─── 7. DAP UI ──────────────────────────────────────────────
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      -- Auto-open/close DAP UI when debugging starts/stops
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
