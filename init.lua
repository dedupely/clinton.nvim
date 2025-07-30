-- Lazyvim setup
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- plugin install
require('lazy').setup({
  -- The tokyonight.nvim colorscheme
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  {
    'akinsho/bufferline.nvim',
    version = "*", -- Pin to the latest version
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- The configuration for bufferline goes here
      -- We will fill this in during Step 2
      ---- Inside the config = function() for bufferline
        require('bufferline').setup({
          options = {
            -- This is the indicator for a modified buffer
            -- A dot ● is a common choice
            modified_icon = '●',

            -- Other nice options:
            separator_style = "slant", -- Adds a cool separator shape
            diagnostics = "nvim_lsp", -- Shows LSP errors/warnings

            -- This is important, otherwise the bufferline disappears
            -- when you only have one buffer open.
            always_show_bufferline = true,
          }
        })
      end
    },
    {
      'nvim-tree/nvim-tree.lua', version = "*", dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require("nvim-tree").setup()
      end,
    },
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.6', -- Pin to a stable version
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        -- This is where you would configure telescope, if you wanted to
        -- For now, we'll just load the fzf extension
        require('telescope').setup({
          defaults = {
            path_display = { 'filename_first' },
            layout_strategy = "horizontal",
            layout_config = {
              horizontal = {
                prompt_position = "top",
                width = { padding = 0 },
                height = { padding = 0 },
                preview_width = 0.5,
              },
            },
            sorting_strategy = "ascending",
          }
        })
        require('telescope').load_extension('fzf')
      end
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- This is a build command that lazy.nvim will run
      build = 'make',
    },
    {
      'folke/tokyonight.nvim',
      lazy = false,    -- make sure we load this during startup
      priority = 1000, -- make sure to load this before all other start plugins
      opts = {},       -- pass any options to the plugin
    },
    { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
    { 'akinsho/toggleterm.nvim', version = "*", 
    config = function()
      require('toggleterm').setup({
        direction = 'float' -- The main option to make it float
      })
    end
  },
  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim', opts = {
      duration_multiplier = 2
    }
  },
  -- The completion engine
  { 'hrsh7th/nvim-cmp' },
  -- Source for nvim-cmp: buffer words
  { 'hrsh7th/cmp-buffer' },
  -- Source for nvim-cmp: file paths
  { 'hrsh7th/cmp-path' },

  -- LSP Configuration
  { 'neovim/nvim-lspconfig' },
  -- Source for nvim-cmp: LSP
  { 'hrsh7th/cmp-nvim-lsp' },

  -- LSP Installer
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },

  -- Icons for completion menu
  { 'onsails/lspkind.nvim' },
})

local keymap = vim.keymap.set

-- Key mappings
vim.g.mapleader = ' '
vim.g.localleader = ' '

-- Telescope
local builtin = require('telescope.builtin')

keymap('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })

-- File tree
keymap('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- Toggle floating terminal
keymap('n', '<leader>t', '<cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })

-- This function will be called when a terminal is opened
local function set_terminal_keymaps()
  -- Set options for the keymap to be buffer-local
  local opts = { buffer = 0 }
  -- Map <Esc> in terminal mode to exit to normal mode
  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
end

-- Create an autocommand that runs our function on the TermOpen event
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*',
  callback = function()
    set_terminal_keymaps()
  end,
  desc = 'Set terminal keymaps on open',
})

vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
  update_in_insert = true
});

-- LSP
local cmp = require('cmp')
local lspkind = require('lspkind')
local types = require('cmp.types')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
    ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
    ['<Enter>'] = cmp.mapping.confirm({ select = false }),
    ['<Esc>'] = cmp.mapping.abort(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
    })
  }
})

-- Setup mason so it can manage LSP servers
require('mason').setup()
require('mason-lspconfig').setup()

-- Setup language servers.
require('mason-lspconfig').setup({
	ensure_installed = { 'html', 'cssls', 'prismals', 'svelte', 'ts_ls', 'jsonls', 'lua_ls', 'bashls' }
})

-- Diagnosis Counts
function getDiagnosisCounts()
    -- Get counts for errors and warnings in the current buffer
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

  if errors > 0 then
    -- If there are errors, the status is red. Also show warning counts.
    local parts = { "🔴 " .. errors }
    if warnings > 0 then
      table.insert(parts, "🟠 " .. warnings)
    end
    return table.concat(parts, " ") .. " "
  elseif warnings > 0 then
    -- If there are only warnings, the status is orange.
    return "🟠 " .. warnings .. " "
  else
    return ""
  end
end

-- Appearance
vim.cmd.colorscheme 'tokyonight'
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true      -- Enable true color support
vim.opt.syntax = 'on'             -- Enable syntax highlighting

-- Line numbers that one can see
vim.api.nvim_set_hl(0, 'LineNr', { fg = 'gray', bold = true })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = 'orange', bold = true })

-- Behavior
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Show search results as you type
vim.opt.ignorecase = true         -- Ignore case in search
vim.opt.smartcase = true          -- But be case-sensitive if the query has uppercase letters

-- Tabs & Indentation
vim.opt.tabstop = 2               -- Number of spaces a <Tab> in the file counts for
vim.opt.shiftwidth = 2            -- Size of an indent
vim.opt.softtabstop = 2           -- Number of spaces to insert for a <Tab>
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.autoindent = true         -- Copy indent from current line when starting a new line

-- Status bar
vim.opt.statusline = '%F%=%{v:lua.getDiagnosisCounts()}'
-- Turn off mouse
vim.opt.mouse = ''

-- Split windows
keymap('n', '<leader>v', '<cmd>:vsplit<CR>', { desc = 'Split vertical' })
keymap('n', '<leader>h', '<cmd>:split<CR>', { desc = 'Split horizontal' })
keymap('n', '<leader>c', '<cmd>:close<CR>', { desc = 'Close current split window' })

-- Move between split windows
keymap('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Move to down window' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Move to up window' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Resize split windows
keymap('n', '<C-A-k>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
keymap('n', '<C-A-j>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
keymap('n', '<C-A-h>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
keymap('n', '<C-A-l>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })

-- Open new tab
keymap('n', '<leader><Tab>', '<cmd>tabnew<CR>', { desc = 'Open new tab' })

-- Close current tab (using a safe keybinding)
keymap('n', '<leader>x', '<cmd>bd<CR>', { desc = 'Close current tab' })

-- Navigate tabs
keymap('n', '<Tab>', '<cmd>tabnext<CR>', { desc = 'Go to next tab' })
keymap('n', '<S-Tab>', '<cmd>tabprevious<CR>', { desc = 'Go to previous tab' })

