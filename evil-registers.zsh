# {{{ set system clipboard
zmodload zsh/parameter
declare -gA ZSH_EVIL_PASTE_HANDLERS
declare -gA ZSH_EVIL_COPY_HANDLERS
# "(e)*" to remove special meaning of "*"
if (( $+commands[termux-clipboard-get] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-termux-clipboard-get}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-termux-clipboard-get}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-termux-clipboard-set}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-termux-clipboard-set}"
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-wl-paste -p -n}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-wl-paste -n}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-wl-copy -p}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-wl-copy}"
elif (( $+DISPLAY & $+commands[xclip] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-xclip -out}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-xclip -selection clipboard -out}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-xclip}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-xclip -selection clipboard}"
elif (( $+DISPLAY & $+commands[xsel] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-xsel -o}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-xsel -b -o}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-xsel -i}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-xsel -b -i}"
fi
# }}}
# {{{ Handle fpath/$0
# ref: zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html#zero-handling
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
[[ $PMSPEC = *f* ]] || fpath+=("${0:h}/functions")
autoload -Uz .evil-registers::{track-insert,paste,yank} evil-registers_plugin_unload
# }}}
# {{{ shadow vi-set-buffer
.evil-registers::vi-set-buffer(){
	typeset -g _evil_register
	read -k 1 _evil_register
	zle .vi-set-buffer "$_evil_register"
}
# }}}
(){ # {{{ register new widgets
	local w
	# TODO: best practice?
	# overwrite old widgets
	for w (
		vi-delete vi-delete-char vi-kill-line vi-kill-eol
		vi-change vi-change-eol vi-change-whole-line
		vi-yank vi-yank-whole-line vi-yank-eol
	); do
		zle -N "$w" ".evil-registers::yank"
	done
	for w (vi-put-after vi-put-before); do
		zle -N "$w" ".evil-registers::paste"
	done
	zle -N vi-set-buffer .evil-registers::vi-set-buffer
} # }}}

# vim:foldmethod=marker
