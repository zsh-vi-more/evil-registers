(( $+DISPLAY | $+WAYLAND_DISPLAY )) || return
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

elif (( $+DISPLAY & $+command[xclip] )); then
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

elif (( $+DISPLAY & $+command[xsel] )); then
	system-clipboard-get system-clipboard-set(){
		case "$1" in
			'*') xsel ;;
			*  ) xsel -b ;;
		esac
	}
fi

# shadow vi-yank*
vi-yank-disp(){
	(( $+_disp_reg )) || zle vi-yank
	local x
	x=$registers[x]
	zle vi-yank
	system-clipboard-set <<< "${registers[x]}"
	registers[x]="$x"
}
zle -N vi-yank-disp
bindkey -M vicmd y vi-yank-disp

vi-yank-whole-line-disp(){
	(( $+_disp_reg )) || zle vi-yank-whole-line
	local x
	x=$registers[x]
	zle vi-yank-whole-line
	system-clipboard-set <<< "${registers[x]}"
	registers[x]="$x"
}

vi-yank-eol-disp(){
	(( $+_disp_reg )) || zle vi-yank-eol
	local x
	x=$registers[x]
	zle vi-yank-eol
	system-clipboard-set <<< "${registers[x]}"
	registers[x]="$x"
}
zle -N vi-yank-disp
bindkey -M vicmd Y vi-yank-disp

# shadow vi-put*
vi-put-after-disp(){
	(( $+_disp_reg )) || zle vi-put-after
	local x
	x=$registers[x]
	registers[x]="$(system-clipboard-get "$_disp_reg")"
	zle vi-put-after
	registers[x]="$x"
}
zle -N vi-put-after-disp
bindkey -M vicmd p vi-put-after-disp

vi-put-before-disp(){
	(( $+_disp_reg )) || zle vi-put-before
	local x
	x=$registers[x]
	registers[x]="$(system-clipboard-get "$_disp_reg")"
	zle vi-put-before
	registers[x]="$x"
}
zle -N vi-put-before-disp
bindkey -M vicmd P vi-put-before-disp

# shadow vi-set-buffer
vi-set-buffer-disp(){
	read -k 1 v
	case $v in
		[+*])
			_disp_reg="$v"
			zle vi-set-buffer x
		;;
		*)
			unset _disp_reg
			zle vi-set-buffer "$v"
		;;
	esac
}
zle -N vi-set-buffer-disp
bindkey -M vicmd '"' vi-set-buffer-disp
