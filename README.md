# Zsh Vim system clipboard
Access system clipboards under the `vicmd` keymap with `"+` and `"*`.

## Supported interfaces:

- xclip
- xsel
- wl-clipboard

## Extensions:

If you have a clipboard (or any other function which you want to act as one),
you can register it by adding it to the associative arrays:

```zsh
ZSH_VIM_SYSTEM_COPY_HANDLERS[$key]="your-command"
ZSH_VIM_SYSTEM_PASTE_HANDLERS[$key]="your-command"
```

`your-command` will be `eval`d.
As an example, a simple one-directional append-to-text-file board can be implemented:

```zsh
ZSH_VIM_SYSTEM_COPY_HANDLERS[/]=">> $HOME/.scraps"
```
Now you can append to `~/.scraps` with `"/y<vi-motion>`.

## Similar Projects

- [kutsan/zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard)
