# {{{ set system clipboard
zmodload zsh/parameter
declare -gA ZSH_VIM_SYSTEM_PASTE_HANDLERS
declare -gA ZSH_VIM_SYSTEM_COPY_HANDLERS
# "(e)*" to remove special meaning of "*"
if (( $+commands[termux-clipboard-get] )); then
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]:-termux-clipboard-get}"
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]:-termux-clipboard-get}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]:-termux-clipboard-set}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[+]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[+]:-termux-clipboard-set}"
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]:-wl-paste -p -n}"
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]:-wl-paste -n}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]:-wl-copy -p}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[+]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[+]:-wl-copy}"
elif (( $+DISPLAY & $+commands[xclip] )); then
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]:-xclip -out}"
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]:-xclip -selection clipboard -out}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]:-xclip}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[+]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[+]:-xclip -selection clipboard}"
elif (( $+DISPLAY & $+commands[xsel] )); then
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[(e)*]:-xsel -o}"
	ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]="${ZSH_VIM_SYSTEM_PASTE_HANDLERS[+]:-xsel -b -o}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[(e)*]:-xsel -i}"
	ZSH_VIM_SYSTEM_COPY_HANDLERS[+]="${ZSH_VIM_SYSTEM_COPY_HANDLERS[+]:-xsel -b -i}"
fi
(( ${#ZSH_VIM_SYSTEM_PASTE_HANDLERS} + ${#ZSH_VIM_SYSTEM_COPY_HANDLERS} )) || return
# }}}
# {{{ shadow all vi commands
fpath+="${0:h}"
autoload -Uz __zvsc-paste __zvsc-yank

_zvsc-vi-delete(){ __zvsc-yank .vi-delete }

_zvsc-vi-delete-char(){ __zvsc-yank .vi-delete-char }

_zvsc-vi-kill-line(){ __zvsc-yank .vi-kill-line }

_zvsc-vi-kill-eol(){ __zvsc-yank .vi-kill-eol }

_zvsc-vi-change(){ __zvsc-yank .vi-change }

_zvsc-vi-change-eol(){ __zvsc-yank .vi-change-eol }

_zvsc-vi-change-whole-line(){ __zvsc-yank .vi-change-whole-line }

_zvsc-vi-yank(){ __zvsc-yank .vi-yank }

_zvsc-vi-yank-whole-line(){ __zvsc-yank .vi-yank-whole-line }

_zvsc-vi-yank-eol(){ __zvsc-yank .vi-yank-eol }

_zvsc-vi-put-after(){ __zvsc-paste .vi-put-after }

_zvsc-vi-put-before(){ __zvsc-paste .vi-put-before }
# }}}
# {{{ shadow vi-set-buffer
_zvsc-vi-set-buffer(){
	local v
	read -k 1 v
	case $v in
		''|[a-zA-Z0-9_])
			unset _zvsc_register
			zle .vi-set-buffer "$v"
		;;
		*) _zvsc_register="$v" ;;
	esac
}
# }}}
# {{{ register new widgets
for w in vi-delete vi-delete-char vi-kill-line vi-kill-eol \
	vi-change vi-change-eol vi-change-whole-line \
	vi-yank vi-yank-whole-line vi-yank-eol \
	vi-put-after vi-put-before vi-set-buffer
do
	# TODO: best practice?
	# overwrite old widgets
	zle -N "$w" "_zvsc-${w}"
done
# }}}
# vim:foldmethod=marker
