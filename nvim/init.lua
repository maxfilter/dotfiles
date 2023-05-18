-- Neovim config

--------------------------------------------------------------------------------
-- Globals
--------------------------------------------------------------------------------
-- Must be set before lazy.nvim
vim.g.mapleader = ","
vim.g.coq_settings = { auto_start = "shut-up" }

--------------------------------------------------------------------------------
-- Plugin manager (lazy.nvim)
--------------------------------------------------------------------------------
-- Auto-install lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- color themes
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000
    },
    -- indent lines
    { "lukas-reineke/indent-blankline.nvim" },
    -- icons
    { "nvim-tree/nvim-web-devicons" },
    -- status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    -- treesitter (smart sytnax highlighting)
    { "nvim-treesitter/nvim-treesitter",  build = ":tsupdate" },
    -- lsp
    { "williamboman/mason.nvim",          build = ":masonupdate" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "jose-elias-alvarez/null-ls.nvim" },
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
    },
    -- autocomplete
    { "ms-jpq/coq_nvim",      branch = "coq" },
    { "ms-jpq/coq.artifacts", branch = "artifacts" },
    -- fuzzy search
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
        dependencies = { "nvim-lua/plenary.nvim" }
    }
})

--------------------------------------------------------------------------------
-- plugin configs
--------------------------------------------------------------------------------
-- Treesitter (syntax highlighting support)
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "python",
        "bash",
        "c",
        "markdown",
        "markdown_inline",
    },
    highlight = {
        enable = true
    },
})

-- Status line
require("lualine").setup({})

--------------------------------------------------------------------------------
-- General configs
--------------------------------------------------------------------------------
-- UI
vim.opt.termguicolors = true
vim.cmd.colorscheme("tokyonight-night")
vim.opt.number = true         -- show current line number
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.ruler = true          -- show cursor position
vim.opt.colorcolumn = "80"    -- add vertical ruler

-- Indent & Tab
vim.opt.autoindent = true -- use current indent on next line
vim.opt.shiftwidth = 4    -- n spaces to use for each step of (auto)indent
vim.opt.softtabstop = 4   -- n spaces that a <Tab> counts for while inserting a <Tab>
vim.opt.tabstop = 4       -- n spaces that a <Tab> in the file counts for
vim.opt.expandtab = true  -- use the appropriate number of spaces to insert a <Tab>

-- Search
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.hlsearch = true   -- highlight all search matches (undo with `:noh`)
vim.opt.incsearch = true  -- show incremental search results as you type

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------
-- Basic
vim.keymap.set("i", "jk", "<ESC>") -- remap esc to "jk"

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- LSP
local lsp_server_keymaps = function(opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>di", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>fo", function()
        vim.lsp.buf.format({ async = true })
    end, opts)
end

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------
-- Language servers to install with Mason
local lsp_servers = {
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    pylsp = {
        pylsp = {
            plugins = {
                mccabe = { enabled = true },
                flake8 = { enabled = true, ignore = "E501" },
                pycodestyle = { enabled = true },
            }
        },
    },
    lua_ls = { Lua = { diagnostics = { globals = { "vim" } } } },
}
-- Styling
-- use `:h nvim_open_win` to see all options
local lsp_ui_opts = {
    border = "single",
    style = "minimal",
}
-- LSP boxes
local lsp_server_handlers = {
    ["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, lsp_ui_opts),
    ["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, lsp_ui_opts),
}
-- Diagnostic boxes (warnings, errors, ...)
vim.diagnostic.config({
    virtual_text = false,    -- hide virtual text that appears to right
    float = lsp_ui_opts,     -- use floating boxes instead, style like docs
    underline = true,
    severity_sort = true,    -- show higher severity diagnostics first
    update_in_insert = true, -- udpate diagnostic while in insert mode
})
-- Setup Mason and hook up to LSP
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = lsp_servers,
    automatic_installation = true,
})
-- Apply keymaps, settings, and styling for each LSP server
local coq = require("coq")
for lsp, settings in pairs(lsp_servers) do
    require("lspconfig")[lsp].setup(coq.lsp_ensure_capabilities({
        on_attach = function(_, buffer)
            lsp_server_keymaps({ buffer = buffer })
        end,
        settings = settings,
        handlers = lsp_server_handlers,
    }))
end
-- Setup NullLs for formatting and linting
require("null-ls").setup()
require("mason-null-ls").setup({
    ensure_installed = {
        "black",
        "stylua",
    },
    automatic_installation = true,
})
