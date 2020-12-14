# Zsh Evil Registers
Access external clipboards in vi-mode keymaps,
and synchronize registers to your favorite editors.

If you have a supported clipboard program, simply use your familiar vim bindings:
- `"+` to specify the clipboard selection
- `"*` to specify the primary selection (the same as `"+` in some cases)

If you have a clipboard which is not supported,
_but_ there is a program which can set the clipboard from `stdin`,
and a program which can print the contents of the clipboard on `stdout`,
you can set the appropriate handlers like so:
```zsh
zstyle :zle:evil-registers:'+' yank clipboard-program --read-from-stdin
zstyle :zle:evil-registers:'+' put  clipboard-program --print-to-stdout
```

Then send us a pull request or report an issue!
We'd love to support more clipboards.

## Usage Examples

- Yank a word to the system clipboard with `"+yaw`
- Paste from the system primary selection (if supported) with `"*p`
- If `zstyle :zle:evil-registers:sync editor $your_editor` is set with a supported editor:
  - Delete the current line to your editor's register `a`: `"add`
  - Append the text [within quotes](https://github.com/zsh-vi-more/vi-motions) to your editor's register `q`: `"Qyi"`
  - Put the text from your editor's register `r` before your cursor: `"rP`

## Supported interfaces

#### System Clipboards

The following programs are used to set the system clipboard(s)
with registers `+` and `*`.

- xclip
- xsel
- wl-clipboard
- termux-clipboard (Android has no "selection", so both `+` and `*` operate on the same clipboard)

#### Editor Register Sync

Synchronization of the alphabetic registers is supported with these editors:

- Neovim (requires `nvr`)
- Vim (requires +clientserver support)

Also, the `%` and `#` read-only registers prints
the **full** path of the currently opened
and alternate files in the editor.

## Usage:

See a demo [here](https://asciinema.org/a/q0N73xBvkYDBhBjR8DmD5F78w)!

## Extensions:

### Last Insert Register `.`:

To enable the last insert register on `".`,
do one of the following:

- Create or edit the function `zle-keymap-select`
to add the function which tracks the register

```zsh
function zle-keymap-select(){ 
	.evil-registers::track-insert
	...
}
```

- Bind the function directly:

```zsh
zle -N zle-keymap-select .evil-registers::track-insert
```

### User Extensions:

If you have a clipboard (or any other function which you want to act as one),
you can register it by adding the appropriate `zstyle`:

```zsh
zstyle :zle:evil-registers:$key yank your-command --with --args
zstyle :zle:evil-registers:$key put  your-command --with --args
```

`your-command --with-args` will expect 
If you define a function on a normal-use register (examples: `a`, `T`, `3`),
then it will *override* its normal functionality, including the synchronization offered by this plugin.
As an example, a simple one-directional append-to-text-file board can be implemented:

```zsh
zstyle :zle:evil-registers:/ yank sh -c ">> $HOME/.scraps"
```
Now you can append to `~/.scraps` with `"/y<vi-motion>`.

## Installation

**Antigen**:
```zsh
antigen bundle zsh-vi-more/evil-registers
antigen apply
```

**Zgen**:
```zsh
zgen load zsh-vi-more/evil-registers
zgen save
```


**Zplug**:
```zsh
zplug zsh-vi-more/evil-registers
```

**Zplugin**:
```zsh
zplugin ice wait "0"
zplugin light zsh-vi-more/evil-registers

# Optionally, track the latest development version:
zplugin ice wait "0" ver"dev"
zplugin light zsh-vi-more/evil-registers
```

**Manually**: Clone the project, and then source it:
```zsh
source /path/to/evil-registers/evil-registers.zsh
```

## Similar Projects

- [kutsan/zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard)
