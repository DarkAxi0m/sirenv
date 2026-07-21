# Neovim Config

Personal Neovim configuration in Lua.

## Entry Points

- `init.lua` loads `chris.packer`, `chris.set`, and `chris.remap`.
- `lua/chris/packer.lua` declares plugins through packer.
- `lua/chris/set.lua` contains editor options.
- `lua/chris/remap.lua` contains global keymaps.
- `after/plugin/*.lua` contains plugin-specific setup and keymaps.

Generated files and dependencies such as `plugin/packer_compiled.lua` and `node_modules/` are not part of the hand-written config.

## Leader

The leader key is space.

```lua
vim.g.mapleader = " "
```

## Keymaps

### General

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `<leader>pv` | Open netrw file explorer with `:Ex`. |
| Normal, Insert | `<F3>` | Save current buffer. |
| Normal, Visual | `<leader>oo` | Run `require('ollama').prompt()`. |
| Normal, Visual | `<leader>oG` | Run `require('ollama').prompt('Generate_Code')`. |
| Normal, Visual | `<leader>y` | Yank to system clipboard. |
| Normal | `<leader>Y` | Yank line to system clipboard. |
| Insert | `<C-c>` | Exit insert mode. |
| Normal | `<leader>cc` | Start a whole-file substitute with `:%s/`. |
| Visual | `<leader>cc` | Start a selection substitute with `:s/`. |
| Normal | `<leader>oi` | Run LSP organize imports code action, intended for Go/gopls. |
| Normal | `<leader>ca` | Run LSP code action. |

### Telescope

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `<leader>pf` | Find files. |
| Normal | `<C-p>` | Find Git-tracked files. |
| Normal | `<leader>ps` | Prompt for text and grep for it. |
| Normal | `<leader>vh` | Search help tags. |

### LSP

These are buffer-local mappings created when an LSP server attaches.

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `gd` | Go to definition. |
| Normal | `K` | Show hover documentation. |
| Normal | `<leader>vws` | Search workspace symbols. |
| Normal | `<leader>vd` | Open diagnostic float. |
| Normal | `[d` | Go to next diagnostic. |
| Normal | `]d` | Go to previous diagnostic. |
| Normal | `<leader>vca` | Run code action. |
| Normal | `<leader>vrr` | Show references. |
| Normal | `<leader>vrn` | Rename symbol. |
| Insert | `<C-h>` | Show signature help. |

### Completion

These mappings are active inside the nvim-cmp completion menu.

| Mode | Key | Action |
| --- | --- | --- |
| Insert | `<C-p>` | Select previous completion item. |
| Insert | `<C-n>` | Select next completion item. |
| Insert | `<C-y>` | Confirm selected completion item. |
| Insert | `<C-Space>` | Open completion menu. |

### Harpoon

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `<leader>a` | Add current file to Harpoon list. |
| Normal | `<C-e>` | Toggle Harpoon quick menu. |
| Normal | `<C-h>` | Select Harpoon item 1. |
| Normal | `<C-t>` | Select Harpoon item 2. |
| Normal | `<C-n>` | Select Harpoon item 3. |
| Normal | `<C-s>` | Select Harpoon item 4. |

### Fugitive

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `<leader>gs` | Open Fugitive Git status. |

### UndoTree

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `<leader>u` | Toggle UndoTree. |

### LuaSnip

| Mode | Key | Action |
| --- | --- | --- |
| Insert | `<C-K>` | Expand snippet. |
| Insert, Select | `<C-L>` | Jump to next snippet placeholder. |
| Insert, Select | `<C-J>` | Jump to previous snippet placeholder. |
| Insert, Select | `<C-E>` | Change active snippet choice. |

## Plugin Commands

These commands are provided by plugins configured in this repo.

| Command | Source |
| --- | --- |
| `:Git` | vim-fugitive, used by `<leader>gs`. |
| `:UndotreeToggle` | undotree, used by `<leader>u`. |
| `:Ollama` | ollama.nvim lazy-loaded command. |
| `:OllamaModel` | ollama.nvim lazy-loaded command. |
| `:OllamaServe` | ollama.nvim lazy-loaded command. |
| `:OllamaServeStop` | ollama.nvim lazy-loaded command. |

No custom user commands are currently defined with `vim.api.nvim_create_user_command` or `:command`.

## Snippets

| Filetype | Trigger | Expands To |
| --- | --- | --- |
| All | `expand` | `als;dfjasldkflasdfj` |
| Lua | `lf` | Local function template. |
| TSX | `usestate` | React `useState` template. |

## Review Notes

- `after/plugin/snippets.lua` prints `LuaSnip` every startup. That is useful while debugging but noisy for daily use.
- `lua/chris/init.lua` also calls `require("chris.packer")` and prints `hello chris`, but `init.lua` does not load `lua/chris/init.lua`. If you intended it to run, it is currently disconnected from the main entry point.
- `ts_ls` is configured by `mason-lspconfig` handlers and then directly again. That has the same duplicate-client risk.
- `<C-h>` is mapped by Harpoon in normal mode and by LSP in insert mode, so there is no direct mode conflict there.
- `<C-p>` is mapped by Telescope in normal mode and nvim-cmp in insert mode, so there is no direct mode conflict there.
