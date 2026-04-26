-- ==============================
-- BASIC SETTINGS
-- ==============================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitkeep = "screen"
vim.g.mapleader = " "
-- Essential for BigBlue Terminal Math Symbols
vim.opt.conceallevel = 2
-- ==============================
-- BOOTSTRAP lazy.nvim
-- ==============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- ==============================
-- PLUGINS
-- ==============================
require("lazy").setup({
  -- Theme
  { "EdenEast/nightfox.nvim", config = function() vim.cmd("colorscheme carbonfox") end },
  -- LSP and Mason
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          side = "left",
          width = 30,
          preserve_window_proportions = true,
        },
        actions = {
          open_file = {
            resize_window = false,
          },
        },
      })
    end,
  },
  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  -- Treesitter (Updated to fix the "module not found" error)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then
        -- Fallback if the module isn't loaded yet
        return
      end
      configs.setup({
        ensure_installed = { "markdown", "markdown_inline", "latex", "html", "yaml", "lua", "vim", "vimdoc" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end
  },
  -- UI
  { "nvim-lualine/lualine.nvim" },
  { "lewis6991/gitsigns.nvim" },
  { "folke/which-key.nvim" },
  -- Practice
  { "ThePrimeagen/vim-be-good" },
-- The Math Renderer (The only one you really need for "pretty")
{
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      -- This ensures it renders in all modes (Normal, Insert, etc.)
      render_modes = { 'n', 'c', 'i', 'v' }, 
      latex = {
        enabled = true,
        position = 'overlay',
      },
      -- ADD THIS: Updates the symbols as you type/move
      anti_conceal = {
        enabled = true,
        ignore = {
            code_foreground = true,
            latex_foreground = true,
        },
      },
      -- This forces a refresh on buffer changes
      on = {
        attach = function()
          require('render-markdown').enable()
        end,
      },
    },
  },
  -- Obsidian
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      ui = { enable = false },
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/Obsidian/",
        },
      },
      preferred_link_style = "wiki",
      -- ADD THE MAPPINGS HERE:
      mappings = {
        -- Overrides the 'gf' (go to file) to work with obsidian links
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes or follow links with <Enter>
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },
    },
  },
  -- VimTeX
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = 'general'
      vim.g.tex_conceal = 'abdmg'
    end
  },
})
-- ==============================
-- LSP CONFIGURATION (NVIM 0.11+)
-- ==============================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright","jdtls", "ts_ls", "rust_analyzer", "clangd" },
  automatic_installation = true,
})
-- New 0.11+ syntax for LSP
vim.lsp.config("pyright", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("rust_analyzer", {})
vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")
vim.lsp.enable("rust_analyzer")
-- ==============================
-- COMPLETION
-- ==============================
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})
-- ==============================
-- UI SETUP
-- ==============================
require("lualine").setup({ options = { theme = "auto" } })
require("gitsigns").setup()
require("which-key").setup()
-- ==============================
-- KEYMAPS
-- ==============================
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")
local term_bufnr = nil
vim.keymap.set("n", "<leader>t", function()
  if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_bufnr then
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  end
  vim.cmd("botright vsplit")
  vim.cmd("vertical resize 70")
  vim.cmd("terminal")
  term_bufnr = vim.api.nvim_get_current_buf()
  vim.cmd("startinsert")
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
end)
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown Preview" })
vim.keymap.set('t', 'jk', [[<C-\><C-n>]], {noremap = true})
-- ==============================
-- REMAPPING (The J/K/H/L enforcer)
-- ==============================
vim.keymap.set({ "n", "i", "v" }, "<Up>", function() print("Use k") end)
vim.keymap.set({ "n", "i", "v" }, "<Down>", function() print("Use j") end)
vim.keymap.set({ "n", "i", "v" }, "<Left>", function() print("Use h") end)
vim.keymap.set({ "n", "i", "v" }, "<Right>", function() print("Use l") end)
-- Fixing tab
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
