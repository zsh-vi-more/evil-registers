# {{{ set system clipboard
(( $+DISPLAY | $+WAYLAND_DISPLAY )) || return
zmodload zsh/parameter
if (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	system-clipboard-get(){
		case "$1" in
			'*') wl-paste -p -n ;;
			*  ) wl-paste -n ;;
		esac
	}
	
	system-clipboard-set(){
		case "$1" in
			'*') wl-copy -p ;;
			*  ) wl-copy ;;
		esac
	}

elif (( $+DISPLAY & $+commands[xclip] )); then
	system-clipboard-get(){
		case "$1" in
			'*') xclip -out ;;
			*  ) xclip -selection clipboard -out ;;
		esac
	}

	system-clipboard-set(){
		case "$1" in
			'*') xclip ;;
			*  ) xclip -selection clipboard;;
		esac
	}

elif (( $+DISPLAY & $+commands[xsel] )); then
	system-clipboard-get system-clipboard-set(){
		case "$1" in
			'*') xsel ;;
			*  ) xsel -b ;;
		esac
	}
fi
# }}}
# {{{ shadow all yank commands
__yank-clipboard(){
	if (( $+_system_register )); then
		zle "$1"
		return "$?"
	fi
	zle .vi-set-buffer x
	local x
	x=$registers[x]
	zle "$1"
	system-clipboard-set "$_system_register" <<< "${registers[x]}"
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
	if (( $+_system_register )); then
		zle "$1"
		return "$?"
	fi
	CUTBUFFER="$(system-clipboard-get "$_system_register")"
	zle .vi-set-buffer ''
	zle "$1"
	unset _system_register
}

vi-put-after-clipboard(){ __paste-clipboard .vi-put-after }

vi-put-before-clipboard(){ __paste-clipboard .vi-put-before }
# }}}
# {{{ shadow vi-set-buffer
vi-set-buffer-clipboard(){
	read -k 1 v
	case $v in
		[+*]) _system_register="$v" ;;
		*)
			unset _system_register
			zle .vi-set-buffer "$v"
		;;
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
