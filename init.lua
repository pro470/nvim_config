vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.opt.relativenumber = true

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})

local crates = require("crates")
local opts = { silent = true }
local mappings_added = false -- Track whether keymaps are already added

local function manage_crates_keymaps()
    local bufname = vim.fn.expand("%:t")
    local is_cargo_toml = bufname == "Cargo.toml"

    if is_cargo_toml and not mappings_added then
            vim.keymap.set("n", "<leader>ct", crates.toggle, vim.tbl_extend("force", opts, { desc = "Toggle UI elements (virtual text and diagnostics)" }))
            vim.keymap.set("n", "<leader>cr", crates.reload, vim.tbl_extend("force", opts, { desc = "Reload data (clear cache)" }))

            vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Show all versions of the crate" }))
            vim.keymap.set("n", "<leader>cf", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Show features or feature details of the crate" }))
            vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, vim.tbl_extend("force", opts, { desc = "Show dependencies of the crate" }))

            vim.keymap.set("n", "<leader>cu", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Update the crate on the current line" }))
            vim.keymap.set("v", "<leader>cu", crates.update_crates, vim.tbl_extend("force", opts, { desc = "Update the crates in the selected lines" }))
            vim.keymap.set("n", "<leader>co", crates.update_all_crates, vim.tbl_extend("force", opts, { desc = "Update all crates in the buffer" }))
            vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, vim.tbl_extend("force", opts, { desc = "Upgrade the crate on the current line" }))
            vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, vim.tbl_extend("force", opts, { desc = "Upgrade the crates in the selected lines" }))
            vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Upgrade all crates in the buffer" }))

            vim.keymap.set("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, vim.tbl_extend("force", opts, { desc = "Expand a plain crate declaration into an inline table" }))
            vim.keymap.set("n", "<leader>cX", crates.extract_crate_into_table, vim.tbl_extend("force", opts, { desc = "Extract a crate declaration into a table" }))

            vim.keymap.set("n", "<leader>cH", crates.open_homepage, vim.tbl_extend("force", opts, { desc = "Open the homepage of the crate" }))
            vim.keymap.set("n", "<leader>cR", crates.open_repository, vim.tbl_extend("force", opts, { desc = "Open the repository page of the crate" }))
            vim.keymap.set("n", "<leader>cD", crates.open_documentation, vim.tbl_extend("force", opts, { desc = "Open the documentation page of the crate" }))
            vim.keymap.set("n", "<leader>cC", crates.open_crates_io, vim.tbl_extend("force", opts, { desc = "Open the crates.io page of the crate" }))
            vim.keymap.set("n", "<leader>cL", crates.open_lib_rs, vim.tbl_extend("force", opts, { desc = "Open the lib.rs page of the crate" }))
        mappings_added = true
    elseif not is_cargo_toml and mappings_added then
        -- Remove keymaps if not in Cargo.toml and keymaps are added
        vim.api.nvim_del_keymap("n", "<leader>ct")
        vim.api.nvim_del_keymap("n", "<leader>cr")
        vim.api.nvim_del_keymap("n", "<leader>cv")
        vim.api.nvim_del_keymap("n", "<leader>cf")
        vim.api.nvim_del_keymap("n", "<leader>cd")
        vim.api.nvim_del_keymap("n", "<leader>cu")
        vim.api.nvim_del_keymap("v", "<leader>cu")
        vim.api.nvim_del_keymap("n", "<leader>co")
        vim.api.nvim_del_keymap("n", "<leader>cU")
        vim.api.nvim_del_keymap("v", "<leader>cU")
        vim.api.nvim_del_keymap("n", "<leader>cA")
        vim.api.nvim_del_keymap("n", "<leader>cx")
        vim.api.nvim_del_keymap("n", "<leader>cX")
        vim.api.nvim_del_keymap("n", "<leader>cH")
        vim.api.nvim_del_keymap("n", "<leader>cR")
        vim.api.nvim_del_keymap("n", "<leader>cD")
        vim.api.nvim_del_keymap("n", "<leader>cC")
        vim.api.nvim_del_keymap("n", "<leader>cL")

        mappings_added = false
    end
end

-- Auto-command to manage keymaps dynamically
vim.api.nvim_create_autocmd({"BufEnter", "BufLeave"}, {
    callback = manage_crates_keymaps,
})
local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", {})
vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "InsertLeave", "WinEnter", "CmdlineLeave" },
    {
        group = numbertoggle,
        callback = function()
            if vim.opt.number:get() and vim.api.nvim_get_mode() ~= "i" then
                vim.opt.relativenumber = true
            end
        end,
    }
)

vim.api.nvim_create_autocmd(
    { "BufLeave", "FocusLost", "InsertEnter", "WinLeave", "CmdlineEnter" },
    {
        group = numbertoggle,
        callback = function()
            if vim.opt.number:get() then
                vim.opt.relativenumber = false
                vim.cmd("redraw")
            end
        end,
    }
)


local group = vim.api.nvim_create_augroup('rust_autoformat', {})

-- Format on save using LSP (before the file is saved)
vim.api.nvim_create_autocmd('User', {
    pattern = 'AutoSaveWritePre',
    group = group,
    callback = function(opts)
        if not opts.data or not opts.data.saved_buffer then return end
        
        local bufnr = opts.data.saved_buffer
        if vim.bo[bufnr].filetype ~= 'rust' then return end

        -- Format using LSP synchronously, so formatting completes before the save
        vim.lsp.buf.format({
            bufnr = bufnr,
            async = false,  -- Ensure formatting completes before save
        })
    end,
})

vim.schedule(function()
  require "mappings"
end)

