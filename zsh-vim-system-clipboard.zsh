# {{{ set system clipboard
zmodload zsh/parameter
declare -A _system_paste_handlers
declare -A _system_copy_handlers
# "(e)*" to remove special meaning of "*"
if (( $+commands[termux-clipboard-get] )); then
	_system_paste_handlers[(e)*]="${_system_paste_handlers[(e)*]:-termux-clipboard-get}"
	_system_paste_handlers[+]="${_system_paste_handlers[+]:-termux-clipboard-get}"
	_system_copy_handlers[(e)*]="${_system_copy_handlers[(e)*]:-termux-clipboard-set}"
	_system_copy_handlers[+]="${_system_copy_handlers[+]:-termux-clipboard-set}"
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	_system_paste_handlers[(e)*]="${_system_paste_handlers[(e)*]:-wl-paste -p -n}"
	_system_paste_handlers[+]="${_system_paste_handlers[+]:-wl-paste -n}"
	_system_copy_handlers[(e)*]="${_system_copy_handlers[(e)*]:-wl-copy -p}"
	_system_copy_handlers[+]="${_system_copy_handlers[+]:-wl-copy}"
elif (( $+DISPLAY & $+commands[xclip] )); then
	_system_paste_handlers[(e)*]="${_system_paste_handlers[(e)*]:-xclip -out}"
	_system_paste_handlers[+]="${_system_paste_handlers[+]:-xclip -selection clipboard -out}"
	_system_copy_handlers[(e)*]="${_system_copy_handlers[(e)*]:-xclip}"
	_system_copy_handlers[+]="${_system_copy_handlers[+]:-xclip -selection clipboard}"
elif (( $+DISPLAY & $+commands[xsel] )); then
	_system_paste_handlers[(e)*]="${_system_paste_handlers[(e)*]:-xsel -o}"
	_system_paste_handlers[+]="${_system_paste_handlers[+]:-xsel -b -o}"
	_system_copy_handlers[(e)*]="${_system_copy_handlers[(e)*]:-xsel -i}"
	_system_copy_handlers[+]="${_system_copy_handlers[+]:-xsel -b -i}"
fi
(( ${#_system_paste_handlers} + ${#_system_copy_handlers} )) || return
# }}}
# {{{ shadow all yank commands
__yank-clipboard(){
	# if no copy handler is registered for the given system register,
	# then run with the default register
	if ! (( ${+_system_copy_handlers[$_system_register]} )); then
		zle "$1"
		return "$?"
	fi
	zle .vi-set-buffer x
	local x
	x=$registers[x]
	zle "$1"
	eval ${_system_copy_handlers[$_system_register]} <<< "${registers[x]}"
	registers[x]="$x"
	unset _system_register
}

vi-delete-clipboard(){ __yank-clipboard .vi-delete }

vi-delete-char-clipboard(){ __yank-clipboard .vi-delete-char }

vi-kill-line-clipboard(){ __yank-clipboard .vi-kill-line }

vi-kill-eol-clipboard(){ __yank-clipboard .vi-kill-eol }

vi-change-clipboard(){ __yank-clipboard .vi-change }

vi-change-eol-clipboard(){ __yank-clipboard .vi-change-eol }

vi-change-whole-line-clipboard(){ __yank-clipboard .vi-change-whole-line }

vi-yank-clipboard(){ __yank-clipboard .vi-yank }

vi-yank-whole-line-clipboard(){ __yank-clipboard .vi-yank-whole-line }

vi-yank-eol-clipboard(){ __yank-clipboard .vi-yank-eol }
# }}}
# {{{ shadow all put commands
__paste-clipboard(){
	if ! (( ${+_system_paste_handlers[$_system_register]} )); then
		zle "$1"
		return "$?"
	fi
	# word splitting
	CUTBUFFER="$(eval ${_system_paste_handlers[$_system_register]})"
	zle .vi-set-buffer ''
	zle "$1"
	unset _system_register
}

vi-put-after-clipboard(){ __paste-clipboard .vi-put-after }

vi-put-before-clipboard(){ __paste-clipboard .vi-put-before }
# }}}
# {{{ shadow vi-set-buffer
vi-set-buffer-clipboard(){
	local v
	read -k 1 v
	case $v in
		''|[a-zA-Z0-9_])
			unset _system_register
			zle .vi-set-buffer "$v"
		;;
		*) _system_register="$v" ;;
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
	zle -N "$w" "${w}-clipboard"
done
# }}}
# vim:foldmethod=marker
