# Zsh Evil Registers

[![Gitter](https://badges.gitter.im/zsh-vi-more/community.svg)](https://gitter.im/zsh-vi-more/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Matrix](https://img.shields.io/matrix/zsh-vi-more_community:gitter.im)](https://matrix.to/#/#zsh-vi-more_community:gitter.im)

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

## Workflow Examples

- Yank a word to the system clipboard with `"+yaw`
- Paste from the system primary selection (if supported) with `"*p`
- If `zstyle :zle:evil-registers:'[A-Za-z]' editor $your_editor` is set with a supported editor:
  - Delete the current line to your editor's register `a`: `"add`
  - Append the text [within quotes](https://github.com/zsh-vi-more/vi-motions) to your editor's register `q`: `"Qyi"`
  - Put the text from your editor's register `r` before your cursor: `"rP`

See a demo [here](https://asciinema.org/a/q0N73xBvkYDBhBjR8DmD5F78w)!

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

Example:

```zsh
zstyle :zle:evil-registers:'[A-Za-z%#]' editor nvim
```

The function which pulls the registers from Neovim and Vim
have special behavior for `"%` and `"#`,
as they substitute the full path instead.

### Last Insert Register `.`:

The last insert register should work by default,
as long as the function `zle-keymap-select` does not exist.

If your config creates it, you should consider using
`add-zle-hook-widget` instead:

```zsh
function my-zks(){
	...
}
add-zle-hook-widget zle-keymap-select my-zks
```

### Custom Registers:

If you have a clipboard (or any other function which you want to act as one),
you can register it by adding the appropriate `zstyle`:

```zsh
# Here, $p is either a keystroke or a pattern which matches a keystroke
zstyle :zle:evil-registers:$p yank your-command --with --args
zstyle :zle:evil-registers:$p put  your-command --with --args


# The following style will add the register keystroke and the line as arguments to your-command
# Example: With p='[abc]', "byy will run `your-command --which-expects-register b "$line"`
zstyle :zle:evil-registers:$p yanka your-command --which-expects-register

# The following style will add the register keystroke as an argument to your-command
zstyle :zle:evil-registers:$p puta  your-command --which-expects-register

# The following style will substitute the current value of the variable passed:
zstyle :zle:evil-registers:$p putv VAR_NAME
zstyle :zle:evil-registers:$p putv 'array[key]'
```

If you define a function on a normal-use register (examples: `a`, `T`, `3`),
then it will *override* its normal functionality, including the synchronization offered by this plugin.
As an example, a simple one-directional append-to-text-file board can be implemented:

```zsh
zstyle :zle:evil-registers:/ yank eval ">> $HOME/.scraps"
```
Now you can append to `~/.scraps` with `"/y<vi-motion>`.

### Unnamed Register

To set a handler for the unnamed register,
use an empty pattern:
```zsh
zstyle :zle:evil-registers:'' $operation $handler
```

Example: To get the same result as Vim's `set unnamedplus`,
add this after you source this plugin:

```zsh
(){
	local op
	local -a handler
	for op in {yank,put}{,a,v}; do
		# get the current behavior for '+'
		zstyle -a :zle:evil-registers:'+' $op handler
		# if there is a handler, assign it for the empty pattern
		(($#handler)) && zstyle :zle:evil-registers:'' $op $handler
	done
}
```

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
