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
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Add svelte to this list
        ensure_installed = { 'lua', 'javascript', 'typescript', 'html', 'css', 'svelte', 'prisma', 'bash' },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = { enable = true }
      })
    end,
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
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
    },
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

local neoscroll = require('neoscroll')

local _keymap = {
  ["<C-u>"] = function() neoscroll.scroll(-0.15, { duration = 100 }) end;
  ["<C-d>"] = function() neoscroll.scroll(0.15, { duration = 100 }) end;
}

local modes = { 'n', 'v', 'x' }

for key, func in pairs(_keymap) do
  keymap(modes, key, func)
end

-- Key mappings
vim.g.mapleader = ' '
vim.g.localleader = ' '

-- Telescope
local builtin = require('telescope.builtin')

keymap('n', '<leader>f', builtin.find_files, { desc = 'Find files' })
keymap('n', '<leader>g', builtin.live_grep, { desc = 'Live grep' })

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
function GetDiagnosisCounts()
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
vim.o.showtabline = 0

-- Line numbers that one can see
vim.api.nvim_set_hl(0, 'LineNr', { fg = 'gray', bold = true })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = 'orange', bold = true })

-- Behavior
vim.opt.hlsearch = true           -- Highlight search results
vim.opt.incsearch = true          -- Show search results as you type
vim.opt.ignorecase = true         -- Ignore case in search
vim.opt.smartcase = true          -- But be case-sensitive if the query has uppercase letters
vim.o.confirm = true

-- Tabs & Indentation
vim.opt.tabstop = 2               -- Number of spaces a <Tab> in the file counts for
vim.opt.shiftwidth = 2            -- Size of an indent
vim.opt.softtabstop = 2           -- Number of spaces to insert for a <Tab>
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.autoindent = true         -- Copy indent from current line when starting a new line

-- Status bar
vim.opt.statusline = '%F%=%{v:lua.GetDiagnosisCounts()}'
-- Turn off mouse
vim.opt.mouse = ''

-- See open buffers
keymap('n', '<leader>b', '<cmd>Telescope buffers<CR>', { desc = 'Open new tab' })

-- Navigate between buffers
keymap('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
keymap('n', '<S-Tab>', '<cmd>bprevious<CR>', { desc = 'Go to previous buffer' })
