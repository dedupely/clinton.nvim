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
  { 'mluders/comfy-line-numbers.nvim' },
  { 'jghauser/mkdir.nvim' },
  { 'petertriho/nvim-scrollbar' },
  { 'rmagatti/auto-session' },
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
            path_display = { 'smart' },
          },
	  old_results_history = {
            num_lines = 10, -- How many previous results to remember
            limit_per_picker = 100, -- Max number of lines to store per picker
          }
        })
        require('telescope').load_extension('fzf')
	require('telescope').load_extension('history')
      end
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- This is a build command that lazy.nvim will run
      build = 'make',
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

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require("comfy-line-numbers").setup();
require("auto-session").setup();
require("scrollbar").setup();

local keymap = vim.keymap.set

-- Key mappings
vim.g.mapleader = ' '
vim.g.localleader = ' '

local neoscroll = require('neoscroll')

local _keymap = {
  ["<C-u>"] = function() neoscroll.scroll(-0.15, { duration = 100 }) end;
  ["<C-d>"] = function() neoscroll.scroll(0.15, { duration = 100 }) end;
}

local modes = { 'n', 'v', 'x' }

for key, func in pairs(_keymap) do
  keymap(modes, key, func)
end

-- Telescope
local builtin = require('telescope.builtin')

vim.api.nvim_create_user_command(
  'LiveGrepFixed',
  function()
    builtin.live_grep({
      -- This flag tells ripgrep (rg) to treat the pattern as a literal string.
      additional_args = { '--fixed-strings' }
    })
  end,
  { desc = 'Live Grep (Fixed Strings/No Regex)' }
)

keymap('n', '<leader>f', builtin.find_files, { desc = 'Find files' })
keymap('n', '<leader>g', ':LiveGrepFixed<CR>', { desc = 'Live grep' })

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

local Terminal = require("toggleterm.terminal").Terminal

local function toggle_term_in_buf_dir()
  local buf_dir = vim.fn.expand("%:p:h")
  if vim.fn.isdirectory(buf_dir) == 1 then
    local term = Terminal:new({
      dir = buf_dir,
      direction = "float", 
      close_on_exit = true,
      hidden = true,

    })
    term:toggle()
  else
    print("No valid directory for current buffer.")
  end
end

-- Set your keybind (normal mode)
keymap("n", "<leader>p", toggle_term_in_buf_dir, { noremap = true, silent = true, desc = 'Open floating terminal in current buffer directory' })

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
    {
      name = 'nvim_lsp',
      entry_filter = function(entry)
        local kind = entry:get_kind()
        return kind ~= types.lsp.CompletionItemKind.Text
           and kind ~= types.lsp.CompletionItemKind.Keyword
           and kind ~= types.lsp.CompletionItemKind.Constant
      end
    },
  }, {
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

keymap('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>', { desc = "Toggle diagnotic" })

-- Diagnosis Counts
function GetDiagnosisCounts()
  -- Get counts for errors and warnings in the current buffer
  local total = #vim.diagnostic.get(0)

  if total > 0 then
    return "🔴" .. tostring(total) .. " "
  else
    return ""
  end
end

function GetErrorLines()
  local max_lines = 3
  local bufnr = vim.api.nvim_get_current_buf()
  -- Get all diagnostics for the buffer, filtered by severity = ERROR
  local diagnostics = vim.diagnostic.get(bufnr)

  if #diagnostics == 0 then
    return ""
  end

  -- Collect unique line numbers (1-based)
  local lines_seen = {}
  local unique_lines = {}

  for _, diag in ipairs(diagnostics) do
    local line = diag.lnum + 1
    if not lines_seen[line] then
      lines_seen[line] = true
      table.insert(unique_lines, line)
      if #unique_lines == max_lines then
        break
      end
    end
  end

  if #unique_lines == 0 then
    return ""
  end

  table.sort(unique_lines) -- optional: sort lines ascending

  return "Lines " .. table.concat(unique_lines, ", ") .. "... "
end

-- Appearance
vim.cmd.colorscheme 'habamax'
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true

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
vim.opt.statusline = '%F%=%{v:lua.GetErrorLines()}%{v:lua.GetDiagnosisCounts()}'
-- Turn off mouse
vim.opt.mouse = ''

-- Define :Q to run the existing :q command
vim.api.nvim_create_user_command("Q", "quit", { nargs = 0 })

-- Define :W to run the existing :w command
vim.api.nvim_create_user_command("W", "write", { nargs = 0 })

-- See open buffers
keymap('n', '<leader>b', '<cmd>Telescope buffers<CR>', { desc = 'Open new tab' })

-- Navigate between buffers
keymap('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
keymap('n', '<S-Tab>', '<cmd>bprevious<CR>', { desc = 'Go to previous buffer' })

function _G.ExpandSnippetsNormal()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- Find the word under the cursor
  local start_col = col
  while start_col > 0 and line:sub(start_col, start_col):match("[%w%+%.]") do
    start_col = start_col - 1
  end
  start_col = start_col + 1

  local end_col = col + 1
  while end_col <= #line and line:sub(end_col, end_col):match("[%w%+%.]") do
    end_col = end_col + 1
  end

  local word = line:sub(start_col, end_col - 1)

  local snippets = {
    ["+server.ts"] = [[
import type { RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async ({ url }) => {
	return new Response('');
};
]],
  }

  local snippet = snippets[word]
  if snippet then
    local before = line:sub(1, start_col - 1)
    local after = line:sub(end_col)
    local new_lines = vim.split(before .. snippet .. after, "\n")

    -- Replace the current line with the snippet
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)
  else
    print("No snippet found for that text")
  end
end
-- Keybind for normal mode (leader + s)
vim.keymap.set('n', '<leader>s', _G.ExpandSnippetsNormal, { desc = "Expand snippet" })
