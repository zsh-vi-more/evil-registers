# Zsh Evil Registers
Access external clipboards in vi-mode keymaps.

## Supported interfaces:

- xclip
- xsel
- wl-clipboard
- termux-clipboard

## Extensions:

If you have a clipboard (or any other function which you want to act as one),
you can register it by adding it to the associative arrays:

```zsh
ZSH_EVIL_COPY_HANDLERS[$key]="your-command"
ZSH_EVIL_PASTE_HANDLERS[$key]="your-command"
```

`your-command` will be `eval`d.
If you define a function on a normal-use register (examples: `a`, `T`, `3`),
then it will *override* its normal functionality.
As an example, a simple one-directional append-to-text-file board can be implemented:

```zsh
ZSH_EVIL_COPY_HANDLERS[/]=">> $HOME/.scraps"
```
Now you can append to `~/.scraps` with `"/y<vi-motion>`.

## Similar Projects

- [kutsan/zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard)
