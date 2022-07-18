local cmd = vim.cmd
local o = vim.o
local g = vim.g
local fn = vim.fn
local api = vim.api

require("plugins")


o.scrolloff = 8
o.number = true
o.relativenumber = true
o.swapfile = false
o.tabstop = 4
o.softtabstop = 4

o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

o.termguicolors = true

local function map(mode, keys, command)
    api.nvim_set_keymap(mode, keys, command, {
        noremap = true
    })
end

local function nmap(keys, command)
    map("n", keys, command)
end

local function imap(keys, command)
    map("i", keys, "<Esc>" .. command)
end

local function map_func(mode, keys, func)
    api.nvim_set_keymap(mode, keys, "", {
        noremap = true,
        callback = func
    })
end

cmd 'colorscheme gruvbox'

o.background = "dark"

g.mapleader = " "
nmap("<Leader><Leader>", ":w<CR>:! ./run.sh<CR>")

nmap("<Leader>v", ":Vex<CR>")
nmap("<Leader>g", ":! git add . && git commit -m update && git push<CR>")
nmap("<Leader><CR>", ":so ~/.config/nvim/init.lua<CR>")
nmap("<Leader>ff", ":Telescope find_files<CR>")
nmap("<Leader>fg", ":Telescope live_grep<CR>")
nmap("<Leader>fb", ":Telescope buffers<CR>")
nmap("<Leader>fh", ":Telescope help_tags<CR>")
nmap("<C-p>", ":Telescope find_files<CR>")

nmap("<Left>", "<C-w>h")
nmap("<Down>", "<C-w>j")
nmap("<Up>", "<C-w>k")
nmap("<Right>", "<C-w>l")

imap("<Left>", "<C-w>h")
imap("<Down>", "<C-w>j")
imap("<Up>", "<C-w>k")
imap("<Right>", "<C-w>l")

nmap("<C-j>", ":cnext<CR>")
nmap("<C-k>", ":cprev<CR>")

cmd([[
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$/
]])

api.nvim_create_autocmd("BufWrite", {
    pattern = "*",
    callback = function(args)
        -- print("Saved buffer ! ...." .. vim.inspect(args))
    end,
    desc = "Tell me when I enter a buffer",
})

require('telescope').load_extension('bookmarks')
require('lsp-format').setup {}

local function attach_shortcuts(client)
    -- second K to jump into help
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
    -- adds to tag-stack, ctrl-t leapfrogs jumplist to go back
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0 })
    vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, { buffer = 0 })
    vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, { buffer = 0 })
    -- ctrl-q adds errors to quickfix list
    vim.keymap.set("n", "<leader>dl", ":<cmd>Telescope diagnostics<cr>", { buffer = 0 })
    -- sometimes need :wa afterwards
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = 0 })
    vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { buffer = 0 })

    require "lsp-format".on_attach(client)
end

local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

require("luasnip/loaders/from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require 'lspconfig'
require 'lspconfig'.gopls.setup {
    on_attach = attach_shortcuts,
    capabilities = capabilities,
}

require 'lspconfig'.yamlls.setup {
    on_attach = attach_shortcuts,
    capabilities = capabilities,
}

require 'lspconfig'.tsserver.setup {
    on_attach = attach_shortcuts,
    capabilities = capabilities,
}

require 'lspconfig'.rust_analyzer.setup {
    on_attach = attach_shortcuts,
    capabilities = capabilities,
}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require 'lspconfig'.sumneko_lua.setup {
    on_attach = attach_shortcuts,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
        },
    },
}
