# Zsh Evil Registers
Access external clipboards in vi-mode keymaps,
and synchronize registers to your favorite editors.

## Usage Examples

- Yank a word to the system clipboard with `"+yaw`
- Paste from the system primary selection (if supported) with `"*p`
- If `ZSH_EVIL_SYNC_EDITOR` is set to a supported editor:
  - Delete the current line to your editor's register `a`: `"add`
  - Append the text [within quotes](https://github.com/zsh-vi-more/vi-motions) to your editor's register `q`: `"Qyi"`
  - Put the text from your editor's register `r` before your cursor: `"rP`

## Supported interfaces

#### System Clipboards

- xclip
- xsel
- wl-clipboard
- termux-clipboard

#### Editor Clipboard Sync

- Neovim (requires `nvr`)
- Vim (requires +clientserver support)

## Extensions:

If you have a clipboard (or any other function which you want to act as one),
you can register it by adding it to the associative arrays:

```zsh
ZSH_EVIL_COPY_HANDLERS[$key]="your-command"
ZSH_EVIL_PASTE_HANDLERS[$key]="your-command"
```

`your-command` will be `eval`d.
If you define a function on a normal-use register (examples: `a`, `T`, `3`),
then it will *override* its normal functionality, including the synchronization offered by this plugin.
As an example, a simple one-directional append-to-text-file board can be implemented:

```zsh
ZSH_EVIL_COPY_HANDLERS[/]=">> $HOME/.scraps"
```
Now you can append to `~/.scraps` with `"/y<vi-motion>`.

## Similar Projects

- [kutsan/zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard)
