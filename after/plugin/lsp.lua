-- lsp.lua

-- Load the lsp-zero library
local lsp = require('lsp-zero')
local lspconfig = require('lspconfig')
local cmp = require('cmp')

-- Configure lsp-zero
lsp.preset('recommended')

-- Load mason.nvim and mason-lspconfig
--require('mason').setup()
--require('mason-lspconfig').setup({
   -- ensure_installed = { 'clangd' },  -- Only ensure clangd, neocmake is handled separately
--})

-- Manually install language servers if Mason fails
local function ensure_server_installed(name)
    local registry = require('mason-registry')
    if not registry.is_installed(name) then
        registry.get_package(name):install()
    end
end

--ensure_server_installed('clangd')

-- Configure clangd
lsp.configure('clangd', {
    cmd = { "clangd" },
    filetypes = { "c", "objc", "objcpp" },
    root_dir = function(fname)
        return lspconfig.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git')(fname) or lspconfig.util.path.dirname(fname)
    end,
    settings = {
        clangd = {
            fallbackFlags = { "-std=c++17" },
        },
    },
})

-- Configure neocmake
lspconfig.neocmake.setup({
    cmd = { "neocmake" },
    filetypes = { "cmake" },
    root_dir = lspconfig.util.root_pattern('CMakeLists.txt', '.git'),
})

-- On attach function to enable completion and other settings
lsp.on_attach(function(client, bufnr)
    local opts = { noremap=true, silent=true }

    -- Mappings for LSP functionality
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end)

-- Setup nvim-cmp
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'luasnip' },
    }
})

-- Setup LSP
lsp.setup()

