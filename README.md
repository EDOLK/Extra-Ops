# Extra-Ops
A few new operators that you may find useful.

Global Replace: Opens your motion in a global substitute command,

Local Replace: First use marks given motion for local replace, second use replaces within marked area:


https://github.com/user-attachments/assets/bd5a9b3f-1cca-491b-98be-3df15a977dec



Search: Searches for given motion like *:
```
/YOUR_MOTION
```
White Space: Removes whitespace from given motion (this includes indentation):
```
Test ([v]ar1, var2, var3) 

<leader>wi(

Test ([v]ar1,var2,var3)
```

## Installation
Required: [yop.nvim](https://github.com/zdcthomas/yop.nvim)

Optional: [mini.clue](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-clue.md) (built-in support)

```vim
Plug 'echasnovski/mini.clue'
Plug 'zdcthomas/yop.nvim'
Plug 'EDOLK/extra-ops'
```
## Setup

A setup call is required.

All operators are explicitly opt-in, if you don't want a particular operator, simply remove it from the setup call.

All options within each operator have defaults and are optional.

```lua
require("extra-ops").setup({
    miniclue = true, -- Optional, set to false or remove if you don't have mini.clue
    global_replace = {
        mode = {"n","v"}
        prefix = "<leader>gr"
    },
    local_replace = {
        mode = {"n","v"}
        prefix = "<leader>lr"
        clear_mapping = "<leader>lc"
        highlight = "Visual"
    },
    search = {
        mode = {"n","v"}
        prefix = "<leader>/"
    },
    white_space = {
        mode = {"n","v"}
        prefix = "<leader>w"
    }
})
```
