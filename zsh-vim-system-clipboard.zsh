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


# shadow all yank commands
__yank_disp(){
	(( $+_disp_reg )) || zle "$1"
	local x
	x=$registers[x]
	zle "$1"
	system-clipboard-set <<< "${registers[x]}"
	registers[x]="$x"
	unset _disp_reg
}

vi-yank-disp(){ __yank_disp vi-yank }

vi-yank-whole-line-disp(){ __yank_disp vi-yank-whole-line }

vi-yank-eol-disp(){ __yank_disp vi-yank-eol }

zle -N vi-yank-disp
bindkey -M vicmd y vi-yank-disp

zle -N vi-yank-disp
bindkey -M vicmd Y vi-yank-disp

# shadow all put commands
__paste_disp(){
	(( $+_disp_reg )) || zle "$1"
	local x
	x=$registers[x]
	registers[x]="$(system-clipboard-get "$_disp_reg")"
	zle "$1"
	registers[x]="$x"
	unset _disp_reg
}

vi-put-after-disp(){ __paste_disp vi-put-after }

vi-put-before-disp(){ __paste_disp vi-put-before }

zle -N vi-put-after-disp
bindkey -M vicmd p vi-put-after-disp

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
