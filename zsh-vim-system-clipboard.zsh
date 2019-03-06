# {{{ set system clipboard
zmodload zsh/parameter
declare -gA zvsc_paste_handlers
declare -gA zvsc_copy_handlers
# "(e)*" to remove special meaning of "*"
if (( $+commands[termux-clipboard-get] )); then
	zvsc_paste_handlers[(e)*]="${zvsc_paste_handlers[(e)*]:-termux-clipboard-get}"
	zvsc_paste_handlers[+]="${zvsc_paste_handlers[+]:-termux-clipboard-get}"
	zvsc_copy_handlers[(e)*]="${zvsc_copy_handlers[(e)*]:-termux-clipboard-set}"
	zvsc_copy_handlers[+]="${zvsc_copy_handlers[+]:-termux-clipboard-set}"
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	zvsc_paste_handlers[(e)*]="${zvsc_paste_handlers[(e)*]:-wl-paste -p -n}"
	zvsc_paste_handlers[+]="${zvsc_paste_handlers[+]:-wl-paste -n}"
	zvsc_copy_handlers[(e)*]="${zvsc_copy_handlers[(e)*]:-wl-copy -p}"
	zvsc_copy_handlers[+]="${zvsc_copy_handlers[+]:-wl-copy}"
elif (( $+DISPLAY & $+commands[xclip] )); then
	zvsc_paste_handlers[(e)*]="${zvsc_paste_handlers[(e)*]:-xclip -out}"
	zvsc_paste_handlers[+]="${zvsc_paste_handlers[+]:-xclip -selection clipboard -out}"
	zvsc_copy_handlers[(e)*]="${zvsc_copy_handlers[(e)*]:-xclip}"
	zvsc_copy_handlers[+]="${zvsc_copy_handlers[+]:-xclip -selection clipboard}"
elif (( $+DISPLAY & $+commands[xsel] )); then
	zvsc_paste_handlers[(e)*]="${zvsc_paste_handlers[(e)*]:-xsel -o}"
	zvsc_paste_handlers[+]="${zvsc_paste_handlers[+]:-xsel -b -o}"
	zvsc_copy_handlers[(e)*]="${zvsc_copy_handlers[(e)*]:-xsel -i}"
	zvsc_copy_handlers[+]="${zvsc_copy_handlers[+]:-xsel -b -i}"
fi
(( ${#zvsc_paste_handlers} + ${#zvsc_copy_handlers} )) || return
# }}}
# {{{ shadow all yank commands
__zvsc-yank(){
	# if no copy handler is registered for the given system register,
	# then run with the default register
	if ! (( ${+zvsc_copy_handlers[$_zvsc_register]} )); then
		zle "$1"
		return "$?"
	fi
	zle .vi-set-buffer x
	local x
	x=$registers[x]
	zle "$1"
	eval ${zvsc_copy_handlers[$_zvsc_register]} <<< "${registers[x]}"
	registers[x]="$x"
	unset _zvsc_register
}

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
# }}}
# {{{ shadow all put commands
__zvsc-paste(){
	if ! (( ${+zvsc_paste_handlers[$_zvsc_register]} )); then
		zle "$1"
		return "$?"
	fi
	# word splitting
	CUTBUFFER="$(eval ${zvsc_paste_handlers[$_zvsc_register]})"
	zle .vi-set-buffer ''
	zle "$1"
	unset _zvsc_register
}

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
