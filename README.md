# 🛠️ My Neovim Configuration

A modern, minimal, and fast Neovim setup powered by **Lazy.nvim**. This config is optimized for web development, LSP support, terminal workflows, and smooth navigation.

---

## 🔑 Key Mappings

> `Leader key`: `<space>`

### 🔍 Telescope (Fuzzy Finder)

| Mapping         | Mode | Action                         |
|-----------------|------|--------------------------------|
| `<leader>f`     | `n`  | Find files                     |
| `<leader>g`     | `n`  | Live grep                      |
| `<leader>b`     | `n`  | List open buffers              |

### 🧠 Diagnostics

| Mapping         | Mode | Action                             |
|-----------------|------|------------------------------------|
| `<leader>d`     | `n`  | Show diagnostic popup              |

### 🖥️ Terminal (toggleterm)

| Mapping         | Mode | Action                                               |
|-----------------|------|------------------------------------------------------|
| `<leader>t`     | `n`  | Toggle floating terminal (default behavior)          |
| `<leader>p`     | `n`  | Open floating terminal in current buffer's directory |
| `<Esc>`         | `t`  | Exit terminal insert mode                            |

### 🔄 Buffer Navigation

| Mapping         | Mode | Action               |
|-----------------|------|----------------------|
| `<Tab>`         | `n`  | Go to next buffer    |
| `<S-Tab>`       | `n`  | Go to previous buffer|

### ⬇️ Smooth Scrolling (Neoscroll)

| Mapping         | Mode    | Action                      |
|-----------------|---------|-----------------------------|
| `<C-d>`         | `n/v/x` | Smooth scroll down          |
| `<C-u>`         | `n/v/x` | Smooth scroll up            |

---

## 🔌 Plugins Used

Plugins are managed with [`lazy.nvim`](https://github.com/folke/lazy.nvim).

### 🌐 Core Tools

- [`lazy.nvim`](https://github.com/folke/lazy.nvim) - Plugin manager

### 🌈 UI/UX

- [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting, indentation
- [`nvim-web-devicons`](https://github.com/nvim-tree/nvim-web-devicons) - File icons
- [`indent-blankline.nvim`](https://github.com/lukas-reineke/indent-blankline.nvim) - Indentation guides
- [`neoscroll.nvim`](https://github.com/karb94/neoscroll.nvim) - Smooth scrolling
- [`toggleterm.nvim`](https://github.com/akinsho/toggleterm.nvim) - Floating and split terminal integration

### 🔍 Fuzzy Finder

- [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) - File and text search
- [`telescope-fzf-native.nvim`](https://github.com/nvim-telescope/telescope-fzf-native.nvim) - Native sorter (requires `make`)
- [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim) - Dependency for telescope

### 🧠 LSP & Autocompletion

- [`nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig) - LSP client config
- [`mason.nvim`](https://github.com/williamboman/mason.nvim) - Portable LSP server installer
- [`mason-lspconfig.nvim`](https://github.com/williamboman/mason-lspconfig.nvim) - Mason + LSP integration
- [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp) - Autocompletion engine
- [`cmp-nvim-lsp`](https://github.com/hrsh7th/cmp-nvim-lsp) - LSP completion source
- [`cmp-buffer`](https://github.com/hrsh7th/cmp-buffer) - Buffer completion source
- [`cmp-path`](https://github.com/hrsh7th/cmp-path) - Path completion source
- [`lspkind.nvim`](https://github.com/onsails/lspkind.nvim) - Icons in completion menu

---

## 🧠 LSP Servers Ensured via Mason

These are automatically installed:

- `html`
- `cssls`
- `prismals`
- `svelte`
- `tsserver`
- `jsonls`
- `lua_ls`
- `bashls`

---

## 🧪 Appearance & Behavior

- **Colorscheme**: `habamax`
- **Line Numbers**: Enabled (absolute + relative)
- **Cursor Line**: Highlighted
- **Search**: Smart case, incremental
- **Tabs**: 2 spaces (expandtab)
- **Mouse**: Disabled
- **Statusline**: Custom diagnostic line & error line indicators

---

## 📦 Treesitter Languages Installed

- `lua`
- `javascript`
- `typescript`
- `html`
- `css`
- `svelte`
- `prisma`
- `bash`

---

## 📜 Status Line Extras

Shows:
- Diagnostic count (🔴 for issues)
- First 3 lines with diagnostics (e.g. `Lines 4, 10, 22...`)

---

> Feel free to extend this setup with additional plugins, keymaps, or colorschemes.

