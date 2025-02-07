# Chronovimus

Chronovimus is an advanced buffer history navigation plugin for Neovim. It overcomes the limitations of the standard `:bnext` and `:bprev` commands by keeping a full, non-destructive history of buffer transitions. This makes it easy to navigate through your workflow—even when buffers are opened in a non-linear or branching fashion.

## Motivation

Standard commands like `:bnext` and `:bprev` simply cycle through the list of loaded buffers. Their shortcomings include:

- **Loss of context:** They do not preserve the order in which buffers were actually visited.
- **Lack of branching:** If you navigate backward and then open a new buffer, the "future" buffers are discarded.
- **Duplicates:** Repeatedly switching between buffers (e.g. via commands like `:e #` or using file explorers) can lead to duplicate entries.

Chronovimus addresses these issues by maintaining a full navigation history that:

- Keeps track of buffer transitions as a timeline.
- Creates a branch when you open a new buffer from the middle of your history.
- Removes duplicate entries to keep the history clean.

## How It Works

Chronovimus builds a history stack based on the order in which files are opened. When you are at the end of your history, new buffers are simply appended. However, if you navigate backward and then open a new file, the plugin creates a branch in the history rather than discarding the future buffers.

### Example Diagram

Consider a scenario with numbered files:

1. **Open files in sequence:**

   - Open file **2** → History: `[2]`
   - Open file **3** → History: `[2, 3]`
   - Open file **4** → History: `[2, 3, 4]` _(current file: 4)_

2. **Navigate backward:**

   - Press **HistoryBack** twice → Current file becomes **2**

3. **Open a new file in the middle of history:**
   - While on file **2**, open file **5**  
     This creates a branch so that the history now becomes:
     ```
     Branch History: 5 → 2 → 3 → 4
     ```
4. **Navigating:**
   - Pressing **HistoryBack** from file **5** follows the sequence:  
     **5** → **2** → **3** → **4**
   - Pressing **HistoryForward** reverses the order:  
     **4** → **3** → **2** → **5**

This approach ensures that you always have a complete, deduplicated view of your navigation history.

## Installation

If you use [lazy.nvim](https://github.com/folke/lazy.nvim) as your package manager, you can install Chronovimus with the following configuration:

```lua
return {
  "mr-scrpt/chronovimus",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    -- These keymaps will be used if you don't override them via setup
    { "<leader>bp", ":HistoryBack<CR>", desc = "History Back" },
    { "<leader>bn", ":HistoryForward<CR>", desc = "History Forward" },
    { "<leader>bl", ":HistoryList<CR>", desc = "History List" },
  },
  config = function()
    require("chronovimus").setup({
      debug = true,
      keys = {
        { mode = "n", lhs = "<leader>bp", rhs = ":HistoryBack<CR>", opts = { silent = true, desc = "History Back" } },
        { mode = "n", lhs = "<leader>bn", rhs = ":HistoryForward<CR>", opts = { silent = true, desc = "History Forward" } },
        { mode = "n", lhs = "<leader>bl", rhs = ":HistoryList<CR>", opts = { silent = true, desc = "History List" } },
      },
    })
  end,
}

```
