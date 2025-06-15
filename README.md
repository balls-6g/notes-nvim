# notes-nvim

---

an easy busy neovim note taking plugin with only two configuration options and thanks ot looking for this plugin

## Features

---

- Every thing is in an floating windows
- Notes store under your projects' `notes/` directory
- Fzf for quick finding

## Installation

---

install with lazy.nvim:

```lua
return {
    "balls-6g/notes-nvim",
    dependencies = "ibhagwan/fzf-lua" -- optional for fzf note findings
    config = function() then
        require("notes-nvim").setup {
            auto_save = true, -- auto saving for notes, default true
            file_ext = "norg" -- note filename extension, default as norg
        }
    end
}
```

other plugin manager:
U know how to install, don;t ask me

## Usage & Commands

---

| Commands    | Usages                                |
| ----------- | ------------------------------------- |
| new         | create a new note                     |
| save        | save the current note                 |
| open        | open a note from the projects' note   |
| open-latest | open the latest note you jhave edited |
| fzf         | open your projects' note with fzf     |

## Dependencies

---

- `fzf` (optional) for fuzzy seraching
- `fd` (optional) for fuzzy searching

yes thats all, thanks
