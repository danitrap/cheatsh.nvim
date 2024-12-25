# CheatSh.nvim

A Neovim plugin that provides quick access to programming language cheatsheets from [cheat.sh](https://cheat.sh/) directly within your editor.

## Features

- Fetch programming cheatsheets without leaving Neovim
- Configurable split behavior (vertical/horizontal)
- Adjustable window size
- Simple and lightweight

## Requirements

- Neovim >= 0.9.0
- curl

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'danitrap/cheatsh.nvim',
    opts = {} -- Optional configuration, you can leave it empty
```

## Configuration

```lua
{
    split = 'vsplit', -- or 'split' for horizontal split
    size = 50, -- size of the window (percentage)
}
```

## Usage

```vim
:CheatSh python list comprehension
:Cheatsh find
:CheatSh awk
:CheatSh tr
```
