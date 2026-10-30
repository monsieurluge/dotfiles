-- leader key --------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- base options --------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- share the clipboard with the system

-- bootstrap lazy.nvim (plugins manager) --------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- plugins --------------------------------------------------

require("lazy").setup({
    ---- Fuzzy Finder
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            winopts = { height = 0.85, width = 0.80 },
        },
        keys = {
            { "<leader>ff", function() require("fzf-lua").files() end,                desc = "Find files" },
            { "<leader>fg", function() require("fzf-lua").live_grep() end,            desc = "Live grep" },
            { "<leader>fb", function() require("fzf-lua").buffers() end,              desc = "Buffers" },
            { "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end, desc = "Symbols" },
            { "<leader>fc", function() require("fzf-lua").commands() end,             desc = "Commands" },
        },
    },
    ---- Mini Files
    {
        "echasnovski/mini.files",
        version = "*",
        opts = {
            mappings = {
                go_in       = ";",
                go_in_plus  = "<CR>",
                go_out      = "j",
                go_out_plus = "J",
            },
        },
        keys = {
            { "<leader>e", function() require("mini.files").open() end, desc = "File explorer" },
        },
    },
    ---- Mason (LSP manager)
    { "williamboman/mason.nvim", opts = {} },
    { "neovim/nvim-lspconfig" },
    ---- Blink (autocomplete)
    {
        "saghen/blink.cmp",
        version = "*",
        opts = {
            keymap = { preset = "default" },
            completion = {
                trigger = {
                    show_on_keyword = false,
                    show_on_trigger_character = false,
                },
            },
        },
    },
    ---- Visual Multi (multi-cursors)
    {
        "mg979/vim-visual-multi",
        init = function()
            vim.g.VM_maps = {
                ["Find Under"]         = "<C-n>", -- select next occurrence
                ["Find Subword Under"] = "<C-n>",
                ["Add Cursor Down"]    = "<C-Down>",
                ["Add Cursor Up"]      = "<C-Up>",
                ["Select All"]         = "<C-S-n>", -- select all occurrences
            }
        end,
    },
    ---- Themes
    { "ellisonleao/gruvbox.nvim",  lazy = true, opts = { contrast = "soft" } },
    { "shaunsingh/solarized.nvim", lazy = true },
    ---- Status Line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "auto",
                section_separators = "",
                component_separators = "",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "filename" },
                lualine_c = { "diagnostics" },
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },
{
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      vue        = { "prettier" },
      json       = { "prettier" },
      css        = { "prettier" },
      html       = { "prettier" },
      markdown   = { "prettier" },
    },
  },
},
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.config").setup({
      ensure_installed = {
        "typescript", "javascript",
        "vue", "html", "css",
        "json", "lua",
        "markdown", "markdown_inline",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    })
  end,
},
})

-- themes --------------------------------------------------

---- defaults
vim.opt.background = "light"
vim.cmd.colorscheme("gruvbox")
---- light/dark switch
vim.keymap.set("n", "<leader>ub", function()
    vim.opt.background = vim.o.background == "light" and "dark" or "light"
end, { desc = "Toggle background" })
---- theme switch
local _themes = { "gruvbox", "solarized" }
local _theme_index = 1
vim.keymap.set("n", "<leader>ut", function()
    _theme_index = (_theme_index % #_themes) + 1
    vim.cmd.colorscheme(_themes[_theme_index])
end, { desc = "Cycle theme" })

-- LSP keymap --------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gr", vim.lsp.buf.references, "References")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("K", vim.lsp.buf.hover, "Hover docs")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("]d", vim.diagnostic.goto_next, "Next diagnostic")
        map("<leader>uh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, "Toggle inlay hints")
    end,
})

-- LSP servers --------------------------------------------------

vim.lsp.config("ts_ls", {
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = vim.fn.stdpath("data") ..
                    "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin",
                languages = { "javascript", "typescript", "vue" },
            },
        },
    },
    filetypes = {
        "javascript", "javascriptreact",
        "typescript", "typescriptreact",
        "vue",
    },
})

vim.lsp.enable({ "ts_ls", "vue_ls", "eslint" })

-- navigation --------------------------------------------------

---- base
vim.keymap.set({ "n", "x", "o" }, "j", "h", { desc = "left" })
vim.keymap.set({ "n", "x", "o" }, "k", "j", { desc = "down" })
vim.keymap.set({ "n", "x", "o" }, "l", "k", { desc = "up" })
vim.keymap.set({ "n", "x", "o" }, ";", "l", { desc = "right" })
vim.keymap.set({ "n", "x", "o" }, "h", ";", { desc = "repeat f/t" })
---- visual
vim.keymap.set({ "n", "x" }, "gk", "gj", { desc = "down (visual)" })
vim.keymap.set({ "n", "x" }, "gl", "gk", { desc = "up (visual)" })
---- panels / splits
vim.keymap.set("n", "<C-w>j", "<C-w>h", { desc = "left split" })
vim.keymap.set("n", "<C-w>k", "<C-w>j", { desc = "bottom split" })
vim.keymap.set("n", "<C-w>l", "<C-w>k", { desc = "top split" })
vim.keymap.set("n", "<C-w>;", "<C-w>l", { desc = "right split" })
---- buffers
vim.keymap.set("n", "[b", "<cmd>bprev<cr>",   { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>",   { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
---- plugins
vim.keymap.set("n", "<leader>kf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file" })
