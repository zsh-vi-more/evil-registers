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
_system_copy_handlers[$key]="your-command"
_system_paste_handlers[$key]="your-command"
```

`your-command` will be `eval`d.
As an example, a simple one-directional append-to-text-file board can be implemented:

```zsh
_system_copy_handlers[/]=">> $HOME/.scraps"
```
Now you can append to `~/.scraps` with `"/y<vi-motion>`.

## Similar Projects

- [kutsan/zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard)
