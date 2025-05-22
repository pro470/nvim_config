return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
{
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
},
  {
    'saecki/crates.nvim',
    event = { "BufRead Cargo.toml" },
    config = function()
        require('crates').setup({
        lsp = {
          enabled = true,
          on_attach = require("nvchad.configs.lspconfig").on_attach,
          actions = true,
          completion = true,
          hover = true,
    },
      })
    end,
  },
  {
      "GeorgesAlkhouri/nvim-aider",
      cmd = {
        "AiderTerminalToggle",
      },
      keys = {
        { "<leader>a/", "<cmd>AiderTerminalToggle<cr>", desc = "Open Aider" },
        { "<leader>as", "<cmd>AiderTerminalSend<cr>", desc = "Send to Aider", mode = { "n", "v" } },
        { "<leader>ac", "<cmd>AiderQuickSendCommand<cr>", desc = "Send Command To Aider" },
        { "<leader>ab", "<cmd>AiderQuickSendBuffer<cr>", desc = "Send Buffer To Aider" },
        { "<leader>a+", "<cmd>AiderQuickAddFile<cr>", desc = "Add File to Aider" },
        { "<leader>a-", "<cmd>AiderQuickDropFile<cr>", desc = "Drop File from Aider" },
      },
      dependencies = {
        "folke/snacks.nvim",
        "nvim-telescope/telescope.nvim",
        --- The below dependencies are optional
        "catppuccin/nvim",
      },
      config = true,
    },
  { 'echasnovski/mini.surround', version = false },
  { 'echasnovski/mini.ai', version = false },
  { 'echasnovski/mini.align', version = false },
  { 'echasnovski/mini.move', version = false },
  { 'echasnovski/mini.operators', version = false },

  {
    "okuuva/auto-save.nvim",
    enabled = true,
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
      trigger_events = { -- See :h events
        -- -- vim events that trigger an immediate save
        -- -- I'm disabling this, as it's autosaving when I leave the buffer and
        -- -- that's autoformatting stuff if on insert mode and following a tutorial
        -- -- Re-enabling this to only save if NOT in insert mode in the condition below
        -- immediate_save = { nil },
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend", {"InsertLeave", pattern = {"*.rs"}} }, -- vim events that trigger an immediate save
        -- vim events that trigger a deferred save (saves after `debounce_delay`)
        defer_save = {
          "InsertLeave",
          "TextChanged",
          { "User", pattern = "VisualLeave" },
          { "User", pattern = "FlashJumpEnd" },
        },
        cancel_deferred_save = {
          "InsertEnter",
          { "User", pattern = "VisualEnter" },
          { "User", pattern = "FlashJumpStart" },
        },
      },
      -- function that takes the buffer handle and determines whether to save the current buffer or not
      -- return true: if buffer is ok to be saved
      -- return false: if it's not ok to be saved
      -- if set to `nil` then no specific condition is applied
      condition = function(buf)
        -- Do not save when I'm in insert mode
        -- Do NOT ADD VISUAL MODE HERE or the cancel_deferred_save wont' work
        -- If I STAY in insert mode and switch to another app, like YouTube to
        -- take notes, the BufLeave or FocusLost immediate_save will be ignored
        -- and the save will not be triggered
        local mode = vim.fn.mode()
        if mode == "i" then
          return false
        end

        -- Disable auto-save for the harpoon plugin, otherwise it just opens and closes
        -- https://github.com/ThePrimeagen/harpoon/issues/434
        --
        -- don't save for `sql` file types
        -- I do this so when working with dadbod the file is not saved every time
        -- I make a change, and a SQL query executed
        -- Run `:set filetype?` on a dadbod query to make sure of the filetype
        local filetype = vim.bo[buf].filetype
        if filetype == "harpoon" or filetype == "mysql" then
          return false
        end

        -- Skip autosave if you're in an active snippet
        if require("luasnip").in_snippet() then
          return false
        end

        return true
      end,
      write_all_buffers = false, -- write all buffers when the current one meets `condition`
      -- Do not execute autocmds when saving
      -- If you set noautocmd = true, autosave won't trigger an auto format
      -- https://github.com/okuuva/auto-save.nvim/issues/55
      noautocmd = false,
      lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
      -- delay after which a pending save is executed (default 1000)
      debounce_delay = 1000,
      -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
      debug = false,
    },
  },

{
  'cordx56/rustowl',
  version = '*', -- Latest stable version
  build = 'cargo install --path . --locked',
  lazy = false, -- This plugin is already lazy
  opts = {
    auto_enable = true,
    client = {
      on_attach = function(_, buffer)
        vim.keymap.set('n', '<leader>o', function()
          require('rustowl').toggle(buffer)
        end, { buffer = buffer, desc = 'Toggle RustOwl' })
      end
    },
  },
},

{
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  init = function ()
      -- Configure rustaceanvim here
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      -- you can also put keymaps in here
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
        ['cargo'] = {
          ['buildScripts'] = {
            ['enable'] = true,
            ['rebuildOnSave '] = true,
          }
        },
        ['procMacro'] = {
          ['enable'] = true,
          ['attributes'] = {
            ['enable'] = true,
          }
        }
      },
    },
  },
  -- DAP configuration
  dap = {
  },
}
  end,
  lazy = false, -- This plugin is already lazy
},
  --
  -- Tabby plugin
  {
    "TabbyML/vim-tabby",
    lazy = false,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.g.tabby_agent_start_command = {"npx", "tabby-agent", "--stdio"}
      vim.g.tabby_inline_completion_trigger = "auto"
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
