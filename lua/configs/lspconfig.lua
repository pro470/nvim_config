-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "java_language_server", "ts_ls", "pyright", "taplo", "yamlls", "marksman"}
local nvlsp = require "nvchad.configs.lspconfig"

--[[
lspconfig.pyright.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
}
--]]


-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig.ltex.setup {
  settings = {
    ltex = {
      language = "de-DE",
      languageToolHttpServerUri = "http://localhost:8010/",
      completionEnabled = true,
    }
  }
}
lspconfig.texlab.setup {
  filetypes = {"tex", "plaintex", "bib",  "markdown", "markdown.mdx"},
  settings = {
    texlab = {
      diagnostics = {
       allowedPatterns = { "%$%$(.-)%$%$", "%$(.-)%$"},
      },
      symbol = {
       allowedPatterns = { "%$%$(.-)%$%$", "%$(.-)%$"},
      }
    }
  }
}

local function filter_lsp_completion(client, bufnr)
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = bufnr,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            local row, col = cursor_pos[1], cursor_pos[2] + 1 -- Adjust to 1-based indexing
            local current_line = lines[row] or ""

            -- Single-line pattern: $...$
            local single_line_pattern = "%$(.-)%$"
            local single_match = current_line:sub(1, col):match(single_line_pattern)

            -- Multi-line pattern: $$...$$
            local multi_line_pattern = "%$%$"
            local active_block = false
            local block_start, block_end = nil, nil
            local count = 0

            -- Find all occurrences of $$ and track pairs
            for i, line in ipairs(lines) do
                if line:find(multi_line_pattern) then
                    count = count + 1
                    if count % 2 == 1 then
                        -- Start of a new block
                        block_start = i
                    else
                        -- End of a paired block
                        block_end = i
                        if row >= block_start and row <= block_end then
                            active_block = true
                            break
                        end
                    end
                end
            end

            -- Enable or disable completion based on the match
            if single_match or active_block then
                client.server_capabilities.completionProvider = true
            else
                client.server_capabilities.completionProvider = false
            end
        end,
    })
end

require('lspconfig').texlab.setup({
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init;
    capabilities = nvlsp.capabilities,
})

-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }

lspconfig.rustowl.setup {
    trigger = {
        hover = false,
    },
}
